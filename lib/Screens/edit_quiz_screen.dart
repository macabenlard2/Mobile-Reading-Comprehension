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
  String? _quizTitle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
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
        setState(() {
          _quizTitle = quizSnapshot['title'];
          _questions = List<Map<String, dynamic>>.from(quizSnapshot['questions'] as List);
          _isLoading = false;
        });
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
      _questions.add({
        'question': '',
        'answers': {'A': '', 'B': '', 'C': ''},
        'correctAnswer': 'A',
      });
    });
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      final answers = _questions[questionIndex]['answers'] as Map<String, String>;
      final newKey = String.fromCharCode(65 + answers.length); // Generate keys A, B, C, D, etc.
      answers[newKey] = '';
    });
  }

  void _removeAnswer(int questionIndex, String answerKey) {
    setState(() {
      final answers = _questions[questionIndex]['answers'] as Map<String, String>;
      if (answers.length > 3) {
        answers.remove(answerKey);
        if (_questions[questionIndex]['correctAnswer'] == answerKey) {
          _questions[questionIndex]['correctAnswer'] = answers.keys.first;
        }
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
        _questions.removeAt(index);
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
      _questions[questionIndex]['answers'][answerKey] = '';
    });
  }

  Future<void> _saveQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
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
    final String questionText = _questions[index]['question'] ?? '';
    final Map<String, String> answers = Map<String, String>.from(_questions[index]['answers']);
    final String correctAnswer = _questions[index]['correctAnswer'] ?? 'A';

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
                    onChanged: (value) => _updateQuestionText(index, value),
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: questionText,
                    ),
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
              children: answers.keys.map((answerKey) => _buildAnswerRow(index, answerKey, answers, correctAnswer)).toList(),
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
                    padding: EdgeInsets.symmetric(horizontal: 8), // Adjust padding
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: answers.length > 3 ? () => _removeAnswer(index, answers.keys.last) : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove Answer'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8), // Adjust padding
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(int index, String answerKey, Map<String, String> answers, String correctAnswer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => _updateAnswerText(index, answerKey, value),
              decoration: InputDecoration(
                labelText: 'Answer $answerKey',
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: answers[answerKey]!,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Radio<String>(
            value: answerKey,
            groupValue: correctAnswer,
            onChanged: (value) => _updateCorrectAnswer(index, value),
          ),
          const Text('Correct'),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.orange),
            onPressed: () => _clearAnswer(index, answerKey),
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

  void _updateQuestionText(int index, String value) {
    setState(() {
      _questions[index]['question'] = value;
    });
  }

  void _updateAnswerText(int index, String answerKey, String value) {
    setState(() {
      _questions[index]['answers'][answerKey] = value;
    });
  }

  void _updateCorrectAnswer(int index, String? value) {
    setState(() {
      _questions[index]['correctAnswer'] = value!;
    });
  }
}
