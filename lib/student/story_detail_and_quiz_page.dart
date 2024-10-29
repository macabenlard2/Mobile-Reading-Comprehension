import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background_reading.dart'; // Import the Background widget
import 'quiz_page.dart';

class StoryDetailAndQuizPage extends StatefulWidget {
  final String storyId;
  final String quizId;

  const StoryDetailAndQuizPage({
    super.key,
    required this.storyId,
    required this.quizId, required DateTime startTime,
  });

  @override
  _StoryDetailAndQuizPageState createState() => _StoryDetailAndQuizPageState();
}

class _StoryDetailAndQuizPageState extends State<StoryDetailAndQuizPage> {
  late Timer _timer; // Timer to update UI
  int _secondsElapsed = 0; // Track the number of seconds elapsed
  int _wordCount = 0; // Track the word count of the passage (story content)

  @override
  void initState() {
    super.initState();
    startTimer(); // Start the timer when the screen loads
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void stopTimer() {
    _timer.cancel(); // Stop the timer
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Method to calculate word count from story content
  int calculateWordCount(String content) {
    List<String> words = content
        .split(RegExp(r'\s+')) // Split by whitespace
        .where((word) => word.isNotEmpty) // Remove empty elements
        .toList();
    return words.length; // Return the count of words
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'STORY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF15A323),
      ),
      body: Background(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Stories').doc(widget.storyId).get(),
          builder: (context, storySnapshot) {
            if (!storySnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var storyData = storySnapshot.data;
            var storyTitle = storyData?['title'] ?? 'No Title';
            var storyContent = storyData?['content'] ?? 'No Content';

            // Ensure accurate word count by counting only the story content
            _wordCount = calculateWordCount(storyContent);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Time Elapsed: ${formatTime(_secondsElapsed)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  ), // Display timer on the screen
                  const SizedBox(height: 20),
                  Text(
                    storyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          storyContent, // Display the actual content
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        stopTimer(); // Stop the timer when the quiz starts
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              quizId: widget.quizId,
                              readingTime: _secondsElapsed, // Pass the reading time to QuizPage
                              passageWordCount: _wordCount, // Pass the accurate word count
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15A323),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Start Quiz'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
