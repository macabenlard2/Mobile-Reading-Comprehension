import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant.dart';
import 'story_detail_and_quiz_page.dart';
import 'package:reading_comprehension/widgets/background.dart'; // Ensure this import is correct

class StudentAssessment extends StatefulWidget {
  final String studentId;

  const StudentAssessment({super.key, required this.studentId});

  @override
  State<StudentAssessment> createState() => _StudentAssessmentState();
}

class _StudentAssessmentState extends State<StudentAssessment> {
  List<DocumentSnapshot> assignedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAssignedItems();
  }

  Future<void> loadAssignedItems() async {
    try {
      // Fetch the automatically assigned assessments from AssignedAssessments collection
      var assignedAssessmentsSnapshot = await FirebaseFirestore.instance
          .collection('Students')
          .doc(widget.studentId)
          .collection('AssignedAssessments')
          .get();

      // Fetch the manually assigned quizzes from AssignedQuizzes collection
      var assignedQuizzesSnapshot = await FirebaseFirestore.instance
          .collection('AssignedQuizzes')
          .where('studentId', isEqualTo: widget.studentId)
          .get();

      // Combine the results from both collections
      List<DocumentSnapshot> combinedDocs = [
        ...assignedAssessmentsSnapshot.docs,
        ...assignedQuizzesSnapshot.docs,
      ];

      setState(() {
        assignedItems = combinedDocs;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching assigned items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Loading...', style: TextStyle(color: neutralColor)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          shadowColor: const Color.fromARGB(255, 0, 0, 0),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            AppBar(
              title: const Text('ASSIGNED PASSAGES', style: TextStyle(color: neutralColor)),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.green,
              shadowColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20.0),
                itemCount: assignedItems.length,
                itemBuilder: (context, index) {
                  var item = assignedItems[index];
                  var storyId = item['storyId'];
                  var quizId = item['quizId'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('Stories').doc(storyId).get(),
                    builder: (context, storySnapshot) {
                      if (storySnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (storySnapshot.hasError) {
                        return Center(child: Text('Error: ${storySnapshot.error}'));
                      } else if (!storySnapshot.hasData || !storySnapshot.data!.exists) {
                        return const Center(child: Text('Story not found'));
                      }

                      var storyData = storySnapshot.data;
                      var storyTitle = storyData?['title'] ?? 'No Title';

                      return Card(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        child: ListTile(
                          title: Text(
                            storyTitle,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              DateTime startTime = DateTime.now(); // Capture start time when button is clicked
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoryDetailAndQuizPage(
                                    storyId: storyId,
                                    quizId: quizId,
                                    startTime: startTime, // Pass start time
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.green, backgroundColor: Colors.white,
                            ),
                            child: const Text('Read & Quiz'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
