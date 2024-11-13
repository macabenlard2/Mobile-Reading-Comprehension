import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background_reading.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String studentId;
  final int readingTime;
  final int passageWordCount;

  const QuizPage({
    super.key,
    required this.quizId,
    required this.studentId,
    required this.readingTime,
    required this.passageWordCount,
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
          questions = questionsList;
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
        const SnackBar(content: Text('Please select an option.')),
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
    double readingTimeInMinutes = widget.readingTime / 60;
    double readingSpeed = widget.passageWordCount / readingTimeInMinutes;
    double comprehensionScorePercentage = (score / questions.length) * 100;

    // Calculate comprehension level based on Phil-IRI standards
    String comprehensionLevel = determineComprehensionLevel(readingSpeed, comprehensionScorePercentage);
          print("Student ID: ${widget.studentId}"); // Debug statement
    // Store quiz results and comprehension level
    _storeQuizResults(readingSpeed, comprehensionScorePercentage, comprehensionLevel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Result'),
        content: Text(
          'Reading Speed: ${readingSpeed.toStringAsFixed(2)} words per minute\n'
          'Comprehension Score: $score out of ${questions.length} (${comprehensionScorePercentage.toStringAsFixed(2)}%)\n'
          'Comprehension Level: $comprehensionLevel',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst); // Pop back to the main screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _storeQuizResults(double readingSpeed, double comprehensionScore, String comprehensionLevel) async {
    await FirebaseFirestore.instance.collection('StudentPerformance').add({
      'studentId': widget.studentId,  // Ensure this field is added correctly
      'quizId': widget.quizId,
      'readingTime': widget.readingTime,
      'readingSpeed': readingSpeed,
      'comprehensionScore': comprehensionScore,
      'totalScore': score,
      'comprehensionLevel': comprehensionLevel,
      'timestamp': Timestamp.now(),
    });
  }

  String determineComprehensionLevel(double readingSpeed, double comprehensionScore) {
    // Define logic based on Phil-IRI standards for determining comprehension level.
    if (comprehensionScore >= 80 && readingSpeed > 100) {
      return "Independent";
    } else if (comprehensionScore >= 60) {
      return "Instructional";
    } else {
      return "Frustration";
    }
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
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
              const Divider(height: 30, thickness: 0.5, color: Colors.black),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('NEXT'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
