import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

class EditQuizScreen extends StatefulWidget {
  final String quizId;
  final String teacherId;

  const EditQuizScreen({super.key, required this.quizId, required this.teacherId});

  @override
  _EditQuizScreenState createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  List<TextEditingController> _questionControllers = [];
  List<List<TextEditingController>> _answerControllers = [];
  String? _quizTitle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var answerList in _answerControllers) {
      for (var controller in answerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadQuizData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
        .collection('Quizzes')
        .doc(widget.quizId)
        .get();

    if (quizSnapshot.exists) {
      final data = quizSnapshot.data() as Map<String, dynamic>?;

      setState(() {
        _quizTitle = data?['title'] ?? 'Untitled Quiz';
        _questions = (data?['questions'] as List<dynamic>? ?? []).map((question) {
          return {
            'question': question['question'] ?? '',
            'answers': Map<String, String>.from(question['answers'] ?? {}),
            'correctAnswer': question['correctAnswer'] ?? 'A',
          };
        }).toList();

        _questionControllers = _questions.map((q) => TextEditingController(text: q['question'])).toList();

        _answerControllers = _questions.map((q) {
          final answers = Map<String, String>.from(q['answers'] ?? {});
          return answers.values.map((a) => TextEditingController(text: a)).toList();
        }).toList();

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz not found')),
      );
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load quiz: $e')),
    );
  }
}


  void _addQuestion() {
    setState(() {
      Map<String, dynamic> newQuestion = {
        'question': '',
        'answers': {'A': '', 'B': '', 'C': ''},
        'correctAnswer': 'A',
      };
      _questions.add(newQuestion);

      _questionControllers.add(TextEditingController());
      _answerControllers.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      final answers = _questions[questionIndex]['answers'] as Map<String, String>;
      final newKey = String.fromCharCode(65 + answers.length);
      answers[newKey] = '';

      _answerControllers[questionIndex].add(TextEditingController());
    });
  }

  void _removeAnswer(int questionIndex, String answerKey) {
    setState(() {
      final answers = _questions[questionIndex]['answers'] as Map<String, String>;
      final answerKeys = answers.keys.toList();
      final answerIndex = answerKeys.indexOf(answerKey);

      if (answers.length > 3) {
        answers.remove(answerKey);

        _answerControllers[questionIndex][answerIndex].dispose();
        _answerControllers[questionIndex].removeAt(answerIndex);

        if (_questions[questionIndex]['correctAnswer'] == answerKey) {
          _questions[questionIndex]['correctAnswer'] = answers.keys.first;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A question must have at least 3 answers')),
        );
      }
    });
  }

  Future<void> _deleteQuestion(int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question and all its answers?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      setState(() {
        _questionControllers[index].dispose();
        for (var controller in _answerControllers[index]) {
          controller.dispose();
        }

        _questions.removeAt(index);
        _questionControllers.removeAt(index);
        _answerControllers.removeAt(index);
      });

      try {
        await FirebaseFirestore.instance.collection('Quizzes').doc(widget.quizId).update({
          'questions': _questions,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete question: $e')),
        );
      }
    }
  }

  void _clearAnswer(int questionIndex, String answerKey) {
    setState(() {
      final answers = _questions[questionIndex]['answers'] as Map<String, String>;
      final answerKeys = answers.keys.toList();
      final answerIndex = answerKeys.indexOf(answerKey);

      answers[answerKey] = '';
      _answerControllers[questionIndex][answerIndex].text = '';
    });
  }

  Future<void> _saveQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      for (int i = 0; i < _questions.length; i++) {
        _questions[i]['question'] = _questionControllers[i].text;

        final answers = _questions[i]['answers'] as Map<String, String>;
        final answerKeys = answers.keys.toList();
        for (int j = 0; j < answerKeys.length; j++) {
          answers[answerKeys[j]] = _answerControllers[i][j].text;
        }
      }

      await FirebaseFirestore.instance.collection('Quizzes').doc(widget.quizId).update({
        'questions': _questions,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quiz: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Quiz",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Background(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_quizTitle != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _quizTitle!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(index);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton('Add Question', _addQuestion),
                  const SizedBox(height: 20),
                  _buildActionButton('Save Changes', _saveQuiz),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final Map<String, String> answers = Map<String, String>.from(_questions[index]['answers']);
    final String correctAnswer = _questions[index]['correctAnswer'] ?? 'A';
    final answerKeys = answers.keys.toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                    ),
                    controller: _questionControllers[index],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(index),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(answers.length, (answerIndex) {
                String answerKey = answerKeys[answerIndex];
                return _buildAnswerRow(index, answerIndex, answerKey, correctAnswer);
              }),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addAnswer(index),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Answer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: answers.length > 3 ? () => _removeAnswer(index, answerKeys.last) : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove Answer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(int questionIndex, int answerIndex, String answerKey, String correctAnswer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: 'Answer $answerKey',
                border: const OutlineInputBorder(),
              ),
              controller: _answerControllers[questionIndex][answerIndex],
            ),
          ),
          const SizedBox(width: 10),
          Radio<String>(
            value: answerKey,
            groupValue: correctAnswer,
            onChanged: (value) => _updateCorrectAnswer(questionIndex, value),
          ),
          const Text('Correct'),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.orange),
            onPressed: () => _clearAnswer(questionIndex, answerKey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15A323),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _updateCorrectAnswer(int questionIndex, String? value) {
    setState(() {
      _questions[questionIndex]['correctAnswer'] = value!;
    });
  }
}
