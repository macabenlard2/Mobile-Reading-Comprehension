import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/models/student_model.dart';
import 'package:reading_comprehension/teacher/mark_miscues_page.dart';
import 'package:reading_comprehension/teacher/student_detail_page.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:auto_size_text/auto_size_text.dart';

class StudentListPage extends StatefulWidget {
  final String teacherId;

  const StudentListPage({super.key, required this.teacherId});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  String _searchText = '';
  String _selectedGrade = 'All';
  String _selectedGender = 'All';
  bool _isAscending = true;
  String? _activeSchoolYear;
  bool _isLoadingSchoolYear = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _fetchActiveSchoolYear();
  }

  // -------- Helpers

  String _norm(String? v) =>
      (v ?? '').toLowerCase().replaceAll(' ', '').trim(); // "Post test" => "posttest"

  bool _typeIsPre(String? v) => _norm(v) == 'pretest';
  bool _typeIsPost(String? v) => _norm(v) == 'posttest';

  // -------- Settings: school year

  Future<void> _fetchActiveSchoolYear() async {
    try {
      final doc = await _firestore.collection('Settings').doc('SchoolYear').get();
      if (doc.exists && mounted) {
        setState(() {
          _activeSchoolYear = doc.data()?['active'];
          _isLoadingSchoolYear = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingSchoolYear = false);
      }
    } catch (e) {
      debugPrint('Error fetching active school year: $e');
      if (mounted) {
        setState(() => _isLoadingSchoolYear = false);
      }
    }
  }

  // -------- Fetch data for Mark Miscues

  Future<Map<String, dynamic>> _fetchQuizAndStoryIds(String studentId) async {
    try {
      // Get current school year from student document
      final studentDoc = await _firestore.collection('Students').doc(studentId).get();
      final currentSchoolYear = studentDoc.data()?['schoolYear'] as String?;
      if (currentSchoolYear == null || currentSchoolYear.isEmpty) {
        return {'error': 'Student has no school year assigned'};
      }

      // Verify active assessment trigger for current SY
      final triggerDoc = await _firestore
          .collection('Students')
          .doc(studentId)
          .collection('Triggers')
          .doc('AssessmentTrigger')
          .get();

      if (!triggerDoc.exists || !(triggerDoc.data()?['start'] ?? false)) {
        return {'error': 'Assessment not properly triggered for this student'};
      }

      // Get all performances for current SY (not just completed ones)
      final snapshot = await _firestore
          .collection('StudentPerformance')
          .where('studentId', isEqualTo: studentId)
          .where('schoolYear', isEqualTo: currentSchoolYear)
          .get();

      // Check completion status - ONLY for current school year
      final miscueCompletion = await _isMiscueCompletedStream(studentId).first;
      if (miscueCompletion) {
        return {'error': 'All miscues already marked for current school year'};
      }

      // Check if pretest is completed - ONLY for current school year
      final hasCompletedPretest = await _hasCompletedType(studentId, 'pretest');
      final hasCompletedPosttest = await _hasCompletedType(studentId, 'posttest');

      // If pretest is not completed, only look for pretest performances
      if (!hasCompletedPretest) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final type = data['type']?.toString();
          
          if (_typeIsPre(type)) {
            final miscues = await _firestore
                .collection('MiscueRecords')
                .where('performanceId', isEqualTo: doc.id)
                .where('schoolYear', isEqualTo: currentSchoolYear)
                .limit(1)
                .get();

            if (miscues.docs.isEmpty) {
              return {
                'quizId': data['quizId'] as String?,
                'storyId': data['storyId'] as String?,
                'type': _norm(type),
                'performanceId': doc.id,
                'schoolYear': currentSchoolYear,
                'isReadingInProgress': !(data['doneReading'] ?? false),
                'teacherId': data['teacherId'] as String?, // Include teacherId
              };
            }
          }
        }
        return {'error': 'No unmarked pre-test miscues available'};
      }
      
      // If pretest is completed but posttest is not, look for posttest performances
      if (hasCompletedPretest && !hasCompletedPosttest) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final type = data['type']?.toString();
          
          if (_typeIsPost(type)) {
            final miscues = await _firestore
                .collection('MiscueRecords')
                .where('performanceId', isEqualTo: doc.id)
                .where('schoolYear', isEqualTo: currentSchoolYear)
                .limit(1)
                .get();

            if (miscues.docs.isEmpty) {
              return {
                'quizId': data['quizId'] as String?,
                'storyId': data['storyId'] as String?,
                'type': _norm(type),
                'performanceId': doc.id,
                'schoolYear': currentSchoolYear,
                'isReadingInProgress': !(data['doneReading'] ?? false),
                'teacherId': data['teacherId'] as String?, // Include teacherId
              };
            }
          }
        }
        return {'error': 'Pre-test completed but no post-test performance found'};
      }

      return {'error': 'No unmarked miscues available'};
    } catch (e) {
      debugPrint('❌ Error in _fetchQuizAndStoryIds: $e');
      return {'error': 'System error: ${e.toString()}'};
    }
  }

  Future<bool> _hasCompletedType(String studentId, String typeWanted) async {
    // Get current school year from student document
    final studentDoc = await _firestore.collection('Students').doc(studentId).get();
    final sy = studentDoc.data()?['schoolYear'] as String? ?? '';

    final snapshot = await _firestore
        .collection('StudentPerformance')
        .where('studentId', isEqualTo: studentId)
        .where('schoolYear', isEqualTo: sy)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final t = _norm(data['type']?.toString());
      if (t == _norm(typeWanted)) {
        final miscues = await _firestore
            .collection('MiscueRecords')
            .where('performanceId', isEqualTo: doc.id)
            .where('schoolYear', isEqualTo: sy)
            .limit(1)
            .get();
        if (miscues.docs.isNotEmpty) return true;
      }
    }
    return false;
  }

  Stream<bool> _isMiscueCompletedStream(String studentId) {
    return _firestore.collection('Students').doc(studentId).snapshots().asyncMap((studentDoc) async {
      if (!studentDoc.exists) return false;

      final sy = studentDoc.data()?['schoolYear'] as String? ?? '';
      if (sy.isEmpty) return false;

      final perf = await _firestore
          .collection('StudentPerformance')
          .where('studentId', isEqualTo: studentId)
          .where('schoolYear', isEqualTo: sy)
          .get();

      bool hasPre = false;
      bool hasPost = false;

      for (var doc in perf.docs) {
        final data = doc.data();
        final t = _norm(data['type']?.toString());

        final miscues = await _firestore
            .collection('MiscueRecords')
            .where('performanceId', isEqualTo: doc.id)
            .where('schoolYear', isEqualTo: sy)
            .limit(1)
            .get();

        if (miscues.docs.isNotEmpty) {
          if (t == 'pretest') {
            hasPre = true;
          } else if (t == 'posttest') {
            hasPost = true;
          }
        }
      }

      return hasPre && hasPost;
    });
  }

  Stream<QuerySnapshot> _getStudentsStream() {
    if (_activeSchoolYear == null) return const Stream.empty();
    return _firestore
        .collection('Students')
        .where('teacherId', isEqualTo: widget.teacherId)
        .where('schoolYear', isEqualTo: _activeSchoolYear)
        .snapshots();
  }

  Future<void> _triggerAssessment(Student student, String type) async {
    final normalized = _norm(type); // accept "Pretest", "Post test", etc.

    // Check if student is in the current school year
    if (student.schoolYear != _activeSchoolYear) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("❌ Cannot trigger ${normalized == 'pretest' ? 'pre-test' : 'post-test'} for ${student.firstName} - student is not in the current school year"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Trigger ${normalized == 'pretest' ? 'Pre-test' : 'Post-test'}"),
        content: Text(
          "Are you sure you want to send the ${normalized == 'pretest' ? 'pre-test' : 'post-test'} trigger to ${student.firstName}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: const Text("Cancel", style: TextStyle(color: Colors.red))
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), 
            child: const Text("Yes, Send", style: TextStyle(color: Colors.green))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection('Students')
          .doc(student.id)
          .collection('Triggers')
          .doc('AssessmentTrigger')
          .set({
        'start': true,
        'type': normalized, // store normalized to avoid "Post test" vs "posttest" issues
        'schoolYear': _activeSchoolYear,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("📢 ${normalized == 'pretest' ? 'Pre-test' : 'Post-test'} trigger sent to ${student.firstName}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("❌ Failed to trigger ${normalized == 'pretest' ? 'pre-test' : 'post-test'}: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // -------- UI

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const Text('Student List', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              if (_activeSchoolYear != null) Text('SY: $_activeSchoolYear', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          backgroundColor: const Color(0xFF15A323),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Background(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => setState(() => _searchText = value),
                  decoration: InputDecoration(
                    labelText: 'Search Students',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        onChanged: (value) => setState(() => _selectedGrade = value!),
                        decoration: InputDecoration(
                          labelText: 'Select Grade',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        items: <String>['All', '5', '6'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text('Grade $value'));
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (value) => setState(() => _selectedGender = value!),
                        decoration: InputDecoration(
                          labelText: 'Select Gender',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        items: <String>['All', 'Male', 'Female'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.green),
                      onPressed: () => setState(() => _isAscending = !_isAscending),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoadingSchoolYear
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: _getStudentsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const Center(child: Text('Error loading students.'));
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('No students found for'),
                                  Text('School Year: $_activeSchoolYear', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }

                          var students = snapshot.data!.docs.map((doc) => Student.fromFirestore(doc)).toList();

                          if (_searchText.isNotEmpty) {
                            students = students.where((s) {
                              final fullName = '${s.firstName} ${s.lastName}'.toLowerCase();
                              return fullName.contains(_searchText.toLowerCase());
                            }).toList();
                          }
                          if (_selectedGrade != 'All') {
                            students = students.where((s) => s.gradeLevel == _selectedGrade).toList();
                          }
                          if (_selectedGender != 'All') {
                            students = students.where((s) => s.gender == _selectedGender).toList();
                          }

                          students.sort((a, b) {
                            final cmp = a.firstName.compareTo(b.firstName);
                            return _isAscending ? cmp : -cmp;
                          });

                          return ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];

                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: (student.profilePictureUrl).isNotEmpty
                                        ? NetworkImage(student.profilePictureUrl)
                                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                                  ),
                                  title: AutoSizeText(
                                    '${student.firstName} ${student.lastName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                    maxLines: 2,
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        'Grade: ${student.gradeLevel} | Gender: ${student.gender}',
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 1,
                                        minFontSize: 5,
                                      ),
                                      const SizedBox(height: 4),
                                      AutoSizeText(
                                        'SchoolYear: ${student.schoolYear}',
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 1,
                                        minFontSize: 5,
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      StreamBuilder<bool>(
                                        stream: _isMiscueCompletedStream(student.id),
                                        builder: (context, snap) {
                                          final isComplete = snap.data ?? false;
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: isComplete
                                                  ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]
                                                  : null,
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: isComplete
                                                      ? null
                                                      : () async {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (context) =>
                                                                const Center(child: CircularProgressIndicator(color: Color(0xFF15A323))),
                                                          );

                                                          try {
                                                            final ids = await _fetchQuizAndStoryIds(student.id);

                                                            if (ids.containsKey('error')) {
                                                              if (mounted) {
                                                                Navigator.of(context).pop();
                                                                
                                                                // Custom messages based on error type
                                                                String message;
                                                                Color backgroundColor;
                                                                
                                                                if (ids['error'] == 'No unmarked pre-test miscues available') {
                                                                  message = '🚫 No Assessment to mark yet. Student has not started reading.';
                                                                  backgroundColor = Colors.red;
                                                                } else if (ids['error'] == 'Pre-test completed but no post-test performance found') {
                                                                  message = 'ℹ️ Pre-test completed. Waiting for student to start post-test reading.';
                                                                  backgroundColor = Colors.blue;
                                                                } else if (ids['error'] == 'All miscues already marked for current school year') {
                                                                  message = '✅ All miscues completed for this school year.';
                                                                  backgroundColor = Colors.green;
                                                                } else if (ids['error'] == 'Assessment not properly triggered for this student') {
                                                                  message = '⚠️ Please trigger assessment first.';
                                                                  backgroundColor = Colors.orange;
                                                                } else {
                                                                  message = ids['error']!;
                                                                  backgroundColor = Colors.orange;
                                                                }
                                                                
                                                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(message),
                                                                    backgroundColor: backgroundColor,
                                                                    duration: const Duration(seconds: 3),
                                                                  ));
                                                              }
                                                              return;
                                                            }

                                                            final quizId = ids['quizId'];
                                                            final storyId = ids['storyId'];
                                                            final type = ids['type']; // already normalized in builder
                                                            final performanceId = ids['performanceId'];
                                                            final isReadingInProgress = ids['isReadingInProgress'] ?? false;
                                                            final teacherId = ids['teacherId']; // Get teacherId from performance

                                                            if (mounted) Navigator.of(context).pop();

                                                            if (quizId == null ||
                                                                storyId == null ||
                                                                type == null ||
                                                                performanceId == null) {
                                                              if (mounted) {
                                                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        "⚠️ Cannot mark miscues. Student hasn't started reading yet."),
                                                                    backgroundColor: Colors.orange,
                                                                    duration: const Duration(seconds: 3),
                                                                  ),
                                                                );
                                                              }
                                                              return;
                                                            }

                                                            if (mounted) {
                                                              await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => MarkMiscuesPage(
                                                                    studentId: student.id,
                                                                    type: type, // normalized
                                                                    performanceId: performanceId,
                                                                    storyId: storyId!,
                                                                    isReadingInProgress: isReadingInProgress,
                                                                    teacherId: teacherId ?? widget.teacherId, // Pass teacherId to MarkMiscuesPage
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (mounted) {
                                                              Navigator.of(context).pop();
                                                              _scaffoldMessengerKey.currentState?.showSnackBar(
                                                                SnackBar(
                                                                  content: Text('❌ Error: $e'), 
                                                                  backgroundColor: Colors.red,
                                                                  duration: const Duration(seconds: 3),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: isComplete ? Colors.grey[300] : const Color(0xFF15A323),
                                                    foregroundColor: isComplete ? Colors.grey : Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      side: isComplete ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                    elevation: isComplete ? 0 : 2,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(isComplete ? 'Completed' : 'Mark Miscue'),
                                                      if (isComplete)
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 4),
                                                          child: Icon(Icons.lock_outline, size: 16),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (isComplete)
                                                  Positioned(
                                                    right: -4,
                                                    top: -4,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration:
                                                          const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.record_voice_over_rounded, color: Colors.blue),
                                        tooltip: 'Trigger Assessment',
                                        onSelected: (t) async => _triggerAssessment(student, t),
                                        itemBuilder: (context) => const [
                                          PopupMenuItem<String>(value: 'Pretest', child: Text('Trigger Pre-test')),
                                          PopupMenuItem<String>(value: 'Post test', child: Text('Trigger Post-test')),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => StudentDetailPage(student: student)),
                                    );
                                  },
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
      ),
    );
  }
}