import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/models/student_model.dart';
import 'package:reading_comprehension/widgets/background.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;

  const StudentDetailPage({super.key, required this.student});

  // Fetch student performance logs from Firestore
  Stream<QuerySnapshot> fetchStudentLogs() {
    return FirebaseFirestore.instance
        .collection('StudentPerformance')
        .where('studentId', isEqualTo: student.id)
        .snapshots();
  }

  // Fetch the quiz title from the Quizzes collection
  Future<String> getQuizTitle(String quizId) async {
    var quizSnapshot = await FirebaseFirestore.instance
        .collection('Quizzes')
        .doc(quizId)
        .get();
    return quizSnapshot.data()?['title'] ?? 'Unknown Quiz';
  }

  // Fetch all miscues for a student
  Stream<QuerySnapshot> fetchStudentMiscues() {
    return FirebaseFirestore.instance
        .collection('MiscueRecords')
        .where('studentId', isEqualTo: student.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: const Color(0xFF15A323),
      ),
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture and Info Section
              Center(
                child: Column(
                  children: [
                    student.profilePictureUrl.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(student.profilePictureUrl),
                            radius: 45,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 90,
                            color: Colors.black,
                          ),
                    const SizedBox(height: 10),
                    Text(
                      '${student.firstName} ${student.lastName}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Grade: ${student.gradeLevel.isNotEmpty ? student.gradeLevel : 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Gender: ${student.gender.isNotEmpty ? student.gender : 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Divider(height: 40, thickness: 1),
              // Student Logs Section
              const Text(
                'Performance Logs:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Fetch and Display Logs from Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: fetchStudentLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No records found.'));
                    }
                    // Display logs in a ListView
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        var logData = doc.data() as Map<String, dynamic>;
                        return FutureBuilder<String>(
                          future: getQuizTitle(logData['quizId']),
                          builder: (context, quizTitleSnapshot) {
                            String quizTitle = quizTitleSnapshot.data ?? 'Loading...';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Quiz Title and Date
                                    Text(
                                      quizTitle,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Date: ${logData['timestamp'] != null ? (logData['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'N/A'}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                    // Scores and Reading Speed
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Comprehension Score: ${logData['comprehensionScore'] ?? 'N/A'}%',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            'Reading Speed: ${logData['readingSpeed']?.toStringAsFixed(2) ?? 'N/A'} wpm',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Total Score: ${logData['totalScore'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Comprehension Level: ${logData['comprehensionLevel'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    // Display Miscue Records Section
                                    StreamBuilder<QuerySnapshot>(
                                      stream: fetchStudentMiscues(),
                                      builder: (context, miscueSnapshot) {
                                        if (miscueSnapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        if (!miscueSnapshot.hasData || miscueSnapshot.data!.docs.isEmpty) {
                                          return const Text('No miscue records found.');
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: miscueSnapshot.data!.docs.map((miscueDoc) {
                                            var miscueData = miscueDoc.data() as Map<String, dynamic>;
                                            
                                            // Display miscues map
                                            Map<String, dynamic> miscuesMap = miscueData['miscues'] ?? {};

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Miscue Score: ${miscueData['totalMiscueScore'] ?? 'N/A'}',
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                const Divider(),
                                                ...miscuesMap.entries.map((entry) {
                                                  return Text(
                                                    '${entry.key}: ${entry.value}',
                                                    style: const TextStyle(fontSize: 14),
                                                  );
                                                }).toList(),
                                              ],
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
