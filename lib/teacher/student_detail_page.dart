import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/models/student_model.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:auto_size_text/auto_size_text.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;

  const StudentDetailPage({super.key, required this.student});

  // Fetch student performance logs from Firestore
  Stream<QuerySnapshot> fetchStudentLogs() {
    return FirebaseFirestore.instance
        .collection('StudentPerformance')
        .where('studentId', isEqualTo: student.id)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Fetch miscues for a specific performance record
  Future<int> fetchTotalMiscues(String performanceId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('MiscueRecords')
          .where('performanceId', isEqualTo: performanceId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data()['totalMiscueScore'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching miscues: $e');
      return 0;
    }
  }

  // Fetch teacher's name by ID
  Future<String> fetchTeacherName(String teacherId) async {
    try {
      if (teacherId.isEmpty) return 'No Teacher Assigned';
      
      final teacherDoc = await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(teacherId)
          .get();
      
      if (teacherDoc.exists) {
        final teacherData = teacherDoc.data() as Map<String, dynamic>;
        final firstName = teacherData['firstName'] ?? 
                         teacherData['firstname'] ?? 
                         teacherData['first_name'] ?? '';
        
        final lastName = teacherData['lastName'] ?? 
                        teacherData['lastname'] ?? 
                        teacherData['last_name'] ?? '';
        
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          return '$firstName $lastName';
        } else if (firstName.isNotEmpty) {
          return firstName;
        } else if (lastName.isNotEmpty) {
          return lastName;
        } else {
          return 'Teacher Name Not Available';
        }
      }
      return 'Teacher Not Found';
    } catch (e) {
      debugPrint('Error fetching teacher: $e');
      return 'Error Loading Teacher';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const Divider(height: 40, thickness: 1),
              const Text(
                'Performance Logs:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildPerformanceLogs()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          student.profilePictureUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(student.profilePictureUrl),
                  radius: 45,
                )
              : const Icon(
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
            'School Year: ${student.schoolYear.isNotEmpty ? student.schoolYear : 'N/A'}',
            style: const TextStyle(fontSize: 16),
          ),
          // Display teacher information
          FutureBuilder<String>(
            future: fetchTeacherName(student.teacherId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  'Teacher: Loading...',
                  style: TextStyle(fontSize: 16),
                );
              } else if (snapshot.hasError) {
                return Text(
                  'Teacher: Error loading',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                );
              } else {
                return Text(
                  'Current Teacher: ${snapshot.data}',
                  style: const TextStyle(fontSize: 16),
                );
              }
            },
          ),
          AutoSizeText(
            'Email: ${student.email.isNotEmpty ? student.email : 'N/A'}',
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildPerformanceLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchStudentLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No records found.'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            var logData = doc.data() as Map<String, dynamic>;
            return FutureBuilder<int>(
              future: fetchTotalMiscues(doc.id),
              builder: (context, miscuesSnapshot) {
                final miscues = miscuesSnapshot.data ?? 0;
                return _buildPerformanceCard(logData, miscues, doc.id);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPerformanceCard(
    Map<String, dynamic> logData,
    int miscues,
    String performanceId,
  ) {
    final date = logData['timestamp'] != null
        ? (logData['timestamp'] as Timestamp).toDate()
        : null;

    // Get school year from performance data
    final schoolYear = logData['schoolYear'] ?? 'Unknown';

    // Ensure proper type conversion to handle int/double issues
    final int passageWordCount = (logData['passageWordCount'] ?? 1) is int 
        ? (logData['passageWordCount'] ?? 1) 
        : (logData['passageWordCount'] ?? 1).toInt();
    
    final double wordReadingScore = ((passageWordCount - miscues) / passageWordCount) * 100;
    
    // Convert values to double to avoid type issues
    final double totalScore = (logData['totalScore'] ?? 0).toDouble();
    final double totalQuestions = (logData['totalQuestions'] ?? 1).toDouble();
    final double comprehensionScore = totalQuestions > 0 
        ? (totalScore / totalQuestions) * 100 
        : 0.0;
    
    // Ensure readingSpeed is converted to double
    final double readingSpeed = (logData['readingSpeed'] ?? 0.0).toDouble();

    final wordReadingLevel = _determineWordReadingLevel(wordReadingScore);
    final comprehensionLevel = _determineComprehensionLevel(comprehensionScore);
    final oralReadingProfile = _determineOralReadingProfile(wordReadingScore, comprehensionScore);

    String quizType = (logData['type'] ?? 'Unknown').toString().toUpperCase();

    bool showMore = false;
    Map<String, int> detailedMiscues = {};

    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Quizzes').doc(logData['quizId']).get(),
          builder: (context, quizSnapshot) {
            String quizTitle = 'Unknown Quiz';
            
            if (quizSnapshot.connectionState == ConnectionState.done && quizSnapshot.hasData) {
              final quizData = quizSnapshot.data!.data() as Map<String, dynamic>?;
              quizTitle = quizData?['title'] ?? 'Unknown Quiz';
            }

            return FutureBuilder<String>(
              future: fetchTeacherName(logData['teacherId'] ?? ''),
              builder: (context, teacherSnapshot) {
                String teacherName = 'Loading teacher...';
                if (teacherSnapshot.connectionState == ConnectionState.done) {
                  teacherName = teacherSnapshot.data ?? 'Unknown Teacher';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                quizTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                schoolYear,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Type: $quizType',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Teacher: $teacherName',
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        Text(
                          'Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'N/A'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text('Word Reading Score: ${wordReadingScore.toStringAsFixed(2)}% ($wordReadingLevel)'),
                        Text('Comprehension Score: ${comprehensionScore.toStringAsFixed(2)}% ($comprehensionLevel)'),
                        Text('Reading Rate: ${readingSpeed.toStringAsFixed(2)} words per minute'),
                        Text('Reading Time: ${logData['readingTime'] != null ? _formatDuration(logData['readingTime']) : 'N/A'}'),
                        Text('Total Miscues: $miscues'),
                        Text('Oral Reading Profile: $oralReadingProfile', style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            if (!showMore) {
                              // Fetch miscues breakdown from Firestore
                              final miscueDoc = await FirebaseFirestore.instance
                                  .collection('MiscueRecords')
                                  .where('performanceId', isEqualTo: performanceId)
                                  .limit(1)
                                  .get();

                              if (miscueDoc.docs.isNotEmpty) {
                                final data = miscueDoc.docs.first.data();
                                if (data.containsKey('miscues')) {
                                  final miscuesMap = Map<String, dynamic>.from(data['miscues']);
                                  setState(() {
                                    detailedMiscues = miscuesMap.map((key, value) => MapEntry(key, (value ?? 0).toInt()));
                                    showMore = true;
                                  });
                                }
                              }
                            } else {
                              setState(() => showMore = false);
                            }
                          },
                          child: Text(showMore ? 'Hide' : 'See More'),
                        ),
                        if (showMore)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: detailedMiscues.entries.map((entry) {
                              return Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 14));
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _determineWordReadingLevel(double wordReadingScore) {
    if (wordReadingScore >= 97) {
      return "Independent";
    } else if (wordReadingScore >= 90) {
      return "Instructional";
    } else {
      return "Frustration";
    }
  }

  String _determineComprehensionLevel(double comprehensionScore) {
    if (comprehensionScore >= 80) {
      return "Independent";
    } else if (comprehensionScore >= 60) {
      return "Instructional";
    } else {
      return "Frustration";
    }
  }

  String _determineOralReadingProfile(double wordReadingScore, double comprehensionScore) {
    if (wordReadingScore >= 97 && comprehensionScore >= 80) {
      return "Independent";
    } else if (wordReadingScore >= 90 && comprehensionScore >= 60) {
      return "Instructional";
    } else {
      return "Frustration";
    }
  }
}

String _formatDuration(dynamic readingTime) {
  int seconds;
  if (readingTime is int) {
    seconds = readingTime;
  } else if (readingTime is double) {
    seconds = readingTime.toInt();
  } else {
    return 'Invalid';
  }

  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;

  if (minutes > 0) {
    return '${minutes}m ${remainingSeconds}s';
  } else {
    return '${remainingSeconds}s';
  }
}