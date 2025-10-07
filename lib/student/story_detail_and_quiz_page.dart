import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background_reading.dart';
import 'quiz_page.dart';

class StoryDetailAndQuizPage extends StatefulWidget {
  final String storyId;
  final String quizId;
  final String studentId;
  final DateTime startTime;
  final String performanceId;

  const StoryDetailAndQuizPage({
    super.key,
    required this.storyId,
    required this.quizId,
    required this.studentId,
    required this.startTime,
    required this.performanceId,
  });

  @override
  _StoryDetailAndQuizPageState createState() => _StoryDetailAndQuizPageState();
}

class _StoryDetailAndQuizPageState extends State<StoryDetailAndQuizPage> {
  bool _isProcessing = false;
  late Timer _timer;
  int _secondsElapsed = 0;
  int _wordCount = 0;
  bool _assessmentStarted = false;

  @override
  void initState() {
    super.initState();
    // Lock device orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    // Restore system UI and orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// ✅ This now blocks BOTH Android back button and iOS swipe
Future<bool> _onWillPop() async {
  if (_assessmentStarted) {
    // 🚫 Block Android back button if quiz already started
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Assessment In Progress"),
        content: const Text("You cannot exit once you have started. Please finish the quiz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
    return false;
  } else {
    // ✅ If student exits BEFORE starting the quiz → cleanup StudentPerformance
    try {
      final performanceRef = FirebaseFirestore.instance.collection('StudentPerformance');
      final querySnapshot = await performanceRef
          .where('studentId', isEqualTo: widget.studentId)
          .where('quizId', isEqualTo: widget.quizId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint("Cleaned up unfinished performance records.");
    } catch (e) {
      debugPrint("Error deleting unfinished performance: $e");
    }

    return true; // allow back press
  }
}



  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void stopTimer() {
    _timer.cancel();
  }

  Future<void> updateReadingStatus() async {
    try {
      final performanceRef = FirebaseFirestore.instance.collection('StudentPerformance');
      final querySnapshot = await performanceRef
          .where('studentId', isEqualTo: widget.studentId)
          .where('quizId', isEqualTo: widget.quizId)
          .get();

      final quizSnapshot = await FirebaseFirestore.instance
          .collection('Quizzes')
          .doc(widget.quizId)
          .get();
      String quizType = quizSnapshot.data()?['type'] ?? 'unknown';

      if (querySnapshot.docs.isEmpty) {
        await performanceRef.add({
          'studentId': widget.studentId,
          'quizId': widget.quizId,
          'type': quizType,
          'doneReading': true,
          'miscuesMarked': false,
          'readingTime': _secondsElapsed,
          'passageWordCount': _wordCount,
          'timestamp': Timestamp.now(),
        });
      } else {
        final performanceDoc = querySnapshot.docs.first;
        final data = performanceDoc.data();

        bool isAlreadyPosttest = data['type'] == "post test";

        await performanceDoc.reference.update({
          'doneReading': true,
          'type': isAlreadyPosttest ? "post test" : quizType,
          'readingTime': _secondsElapsed,
          'passageWordCount': _wordCount,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('Error updating reading status: $e');
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int calculateWordCount(String content) {
    return content.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'STORY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false, // 🔒 disables back button
          backgroundColor: Colors.green,
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

              _wordCount = calculateWordCount(storyContent);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Time Elapsed: ${formatTime(_secondsElapsed)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
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
                            storyContent,
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
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Start Quiz"),
                                    content: const Text("Are you sure you want to proceed to the quiz? You won't be able to go back once started."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.green,
                                        ),
                                        child: const Text("Yes, Proceed"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;

                                setState(() {
                                  _isProcessing = true;
                                  _assessmentStarted = true;
                                });

                                try {
                                  stopTimer();
                                  await updateReadingStatus();

                                  // ✅ Disable iOS swipe back by using PageRouteBuilder
                                  await Navigator.of(context).push(
                                    PageRouteBuilder(
                                      fullscreenDialog: true, // removes swipe back
                                      pageBuilder: (context, _, __) => QuizPage(
                                        quizId: widget.quizId,
                                        studentId: widget.studentId,
                                        readingTime: _secondsElapsed,
                                        passageWordCount: _wordCount,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint("Error navigating to quiz: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Something went wrong. Please try again.")),
                                  );
                                } finally {
                                  setState(() {
                                    _assessmentStarted = false;
                                    _isProcessing = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15A323),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Start Quiz'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
