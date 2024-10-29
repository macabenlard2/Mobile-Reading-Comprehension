import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background_reading.dart'; // Import the Background widget

class QuizPage extends StatefulWidget {
  final String quizId;
  final int readingTime; // Accept reading time from the previous page
  final int passageWordCount; // Accept the word count

  const QuizPage({
    super.key,
    required this.quizId,
    required this.readingTime, // Accept reading time
    required this.passageWordCount, // Accept passage word count
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    try {
      var quizSnapshot = await FirebaseFirestore.instance.collection('Quizzes').doc(widget.quizId).get();
      var quizData = quizSnapshot.data();

      if (quizData != null && quizData.containsKey('questions')) {
        var questionsList = List<Map<String, dynamic>>.from(quizData['questions']);
        setState(() {
          questions = questionsList.map((question) {
            if (question['answers'] == null) {
              question['answers'] = {'A': '', 'B': '', 'C': '', 'D': ''};
            } else {
              for (var key in ['A', 'B', 'C', 'D']) {
                if (!question['answers'].containsKey(key)) {
                  question['answers'][key] = '';
                }
              }
            }
            return question;
          }).toList();
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions available for this quiz.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error loading quiz: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load quiz: $e')),
      );
      Navigator.pop(context);
    }
  }

  void submitAnswer() {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option.'),
        ),
      );
      return;
    }

    if (questions[currentIndex]['correctAnswer'] == selectedOption) {
      score++;
    }
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    // Calculate reading speed
    double readingTimeInMinutes = widget.readingTime / 60;
    double readingSpeed = widget.passageWordCount / readingTimeInMinutes;

    // Calculate comprehension score percentage
    double comprehensionScorePercentage = (score / questions.length) * 100;

    // Display both comprehension score and reading speed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Result'),
        content: Text(
          'Reading Speed: ${readingSpeed.toStringAsFixed(2)} words per minute\n'
          'Comprehension Score: $score out of ${questions.length} (${comprehensionScorePercentage.toStringAsFixed(2)}%)',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF15A323),
      ),
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                '${currentIndex + 1}. ${question['question'] ?? 'No question provided'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 30,
                thickness: 0.5,
                color: Colors.black,
              ),
              Column(
                children: ['A', 'B', 'C', 'D'].map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            question['answers'][option] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: submitAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15A323),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('NEXT'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
