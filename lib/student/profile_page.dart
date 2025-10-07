import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:reading_comprehension/Screens/splash_screen.dart';

class ProfilePage extends StatefulWidget {
  final String studentId;

  const ProfilePage({super.key, required this.studentId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State variables
  String firstName = '';
  String lastName = '';
  String profilePictureUrl = '';
  String gender = '';
  String grade = '';
  String teacherName = 'Loading...';
  bool isLoading = true;
  List<Map<String, dynamic>> performanceLogs = [];
  Map<String, String> quizTitles = {};
  Map<String, String> teacherNames = {}; // Store teacher names by ID

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    _fetchPerformanceData();
  }

  Future<void> _fetchStudentData() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(widget.studentId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          profilePictureUrl = data['profilePictureUrl'] ?? '';
          gender = data['gender'] ?? 'Not specified';
          grade = data['gradeLevel'] ?? 'Not specified';
        });

        // Fetch teacher name
        final teacherId = data['teacherId']?.toString().trim() ?? '';
        if (teacherId.isNotEmpty) {
          DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
              .collection('Teachers')
              .doc(teacherId)
              .get();

          if (teacherDoc.exists) {
            final teacherData = teacherDoc.data() as Map<String, dynamic>;
            final teacherFirstName = teacherData['firstname']?.toString().trim() ?? '';
            final teacherLastName = teacherData['lastname']?.toString().trim() ?? '';
            
            setState(() {
              teacherName = teacherFirstName.isNotEmpty && teacherLastName.isNotEmpty
                  ? '$teacherFirstName $teacherLastName'
                  : 'Teacher name not available';
            });
          } else {
            setState(() {
              teacherName = 'Teacher record not found';
            });
          }
        } else {
          setState(() {
            teacherName = 'No teacher assigned';
          });
        }
      } else {
        setState(() {
          teacherName = 'Student record not found';
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() {
        teacherName = 'Error loading teacher info';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPerformanceData() async {
    try {
      // Get all performance logs for this student
      QuerySnapshot performanceSnapshot = await FirebaseFirestore.instance
          .collection('StudentPerformance')
          .where('studentId', isEqualTo: widget.studentId)
          .orderBy('timestamp', descending: true)
          .get();

      // Extract all unique quiz IDs and teacher IDs
      Set<String> quizIds = {};
      Set<String> teacherIds = {};
      List<Map<String, dynamic>> logs = [];
      
      for (var doc in performanceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        logs.add(data);
        if (data['quizId'] != null) {
          quizIds.add(data['quizId']);
        }
        if (data['teacherId'] != null) {
          teacherIds.add(data['teacherId']);
        }
      }

      // Fetch all quiz titles at once
      Map<String, String> titles = {};
      if (quizIds.isNotEmpty) {
        QuerySnapshot quizSnapshot = await FirebaseFirestore.instance
            .collection('Quizzes')
            .where(FieldPath.documentId, whereIn: quizIds.toList())
            .get();

        for (var doc in quizSnapshot.docs) {
          titles[doc.id] = doc['title'] ?? 'Untitled Quiz';
        }
      }

      // Fetch all teacher names at once
      Map<String, String> teacherNameMap = {};
      if (teacherIds.isNotEmpty) {
        QuerySnapshot teacherSnapshot = await FirebaseFirestore.instance
            .collection('Teachers')
            .where(FieldPath.documentId, whereIn: teacherIds.toList())
            .get();

        for (var doc in teacherSnapshot.docs) {
          final teacherData = doc.data() as Map<String, dynamic>;
          final teacherFirstName = teacherData['firstname']?.toString().trim() ?? '';
          final teacherLastName = teacherData['lastname']?.toString().trim() ?? '';
          teacherNameMap[doc.id] = '$teacherFirstName $teacherLastName';
        }
      }

      setState(() {
        performanceLogs = logs;
        quizTitles = titles;
        teacherNames = teacherNameMap;
      });
    } catch (e) {
      print('Error fetching performance data: $e');
    }
  }

  void _showEditNameDialog() {
    final TextEditingController firstNameController = TextEditingController(text: firstName);
    final TextEditingController lastNameController = TextEditingController(text: lastName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Edit Name', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15A323)),
              onPressed: () async {
                final newFirst = firstNameController.text.trim();
                final newLast = lastNameController.text.trim();

                if (newFirst.isNotEmpty && newLast.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('Students')
                      .doc(widget.studentId)
                      .update({
                    'firstName': newFirst,
                    'lastName': newLast,
                  });

                  setState(() {
                    firstName = newFirst;
                    lastName = newLast;
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profilePictureUrl.isNotEmpty
                  ? NetworkImage(profilePictureUrl)
                  : const AssetImage("assets/images/default_profile.png") as ImageProvider,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          '$firstName $lastName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          minFontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black87),
                        tooltip: 'Edit Name',
                        onPressed: _showEditNameDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gender: $gender',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Grade Level: $grade',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                 Text(
                        'Current Teacher: $teacherName',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildPerformanceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        const Text(
          'All school years:',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPerformanceLogs() {
    if (performanceLogs.isEmpty) {
      return const Center(
        child: Text(
          'No performance logs found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: performanceLogs.length,
      itemBuilder: (context, index) {
        final data = performanceLogs[index];
        final quizTitle = quizTitles[data['quizId']] ?? 'Loading...';
        return _buildPerformanceCard(data, quizTitle);
      },
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic> performance, String quizTitle) {
    final date = performance['timestamp'] != null
        ? (performance['timestamp'] as Timestamp).toDate()
        : null;
    final schoolYear = performance['schoolYear'] ?? 'Unknown';
    
    // Get teacher information for this assessment
    final teacherId = performance['teacherId'] ?? '';
    final assessmentTeacher = teacherId.isNotEmpty 
        ? (teacherNames[teacherId] ?? 'Unknown Teacher') 
        : 'No Teacher Recorded';

    final String oralReadingProfile = performance['oralReadingProfile'] ?? 'N/A';
    final String wordReadingLevel = performance['wordReadingLevel'] ?? 'N/A';
    final String comprehensionLevel = performance['comprehensionLevel'] ?? 'N/A';
    final String type = performance['type'] ?? 'N/A';

    final int totalMiscues = performance['totalMiscues'] ?? 0;
    final int passageWordCount = performance['passageWordCount'] ?? 0;
    final double wordReadingScore = passageWordCount > 0
        ? ((passageWordCount - totalMiscues) / passageWordCount) * 100
        : 0.0;

    final int totalScore = performance['totalScore'] ?? 0;
    final int totalQuestions = performance['totalQuestions'] ?? 1;
    final double comprehensionScore = (totalScore / totalQuestions) * 100;

    final double readingSpeed = performance['readingSpeed'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 10),
            Text('Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'N/A'}'),
            Text(
              'Assessing Teacher: $assessmentTeacher',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text(
              'Word Reading Score: $totalMiscues miscues = ${wordReadingScore.toStringAsFixed(1)}%: $wordReadingLevel',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Comprehension Score: $totalScore out of $totalQuestions = ${comprehensionScore.toStringAsFixed(1)}%: $comprehensionLevel',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Reading Rate: ${readingSpeed.toStringAsFixed(1)} words per minute',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Type: $type',
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Oral Reading Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  oralReadingProfile,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getProfileColor(oralReadingProfile),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProfileColor(String profile) {
    if (profile == 'Independent') {
      return Colors.green;
    } else if (profile == 'Instructional') {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
      ),
      body: Background(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 10),
                    _buildPerformanceHeader(),
                    const SizedBox(height: 10),
                    Expanded(child: _buildPerformanceLogs()),
                  ],
                ),
              ),
      ),
    );
  }
}