import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'story_detail_and_quiz_page.dart';

class StudentAssessment extends StatefulWidget {
  final String studentId;

  const StudentAssessment({super.key, required this.studentId});

  @override
  State<StudentAssessment> createState() => _StudentAssessmentState();
}

class _StudentAssessmentState extends State<StudentAssessment> {
  bool _isProcessing = false;
  List<DocumentSnapshot> assignedItems = [];
  bool isLoading = true;

  // quizId -> details (score, type)
  Map<String, Map<String, dynamic>> quizDetails = {};

  // Completion (per current SY)
  bool pretestCompleted = false;
  bool posttestCompleted = false;

  late final FirebaseFirestore _firestore;

  String? currentTeacherId;
  String? currentTeacherName;

  StreamSubscription<QuerySnapshot>? _assessmentsSubscription;
  StreamSubscription<DocumentSnapshot>? _studentSubscription;
  StreamSubscription<DocumentSnapshot>? _teacherSubscription;
  StreamSubscription<DocumentSnapshot>? _triggerSubscription;

  bool _assessmentTriggerActive = false;
  String? _triggerTypeRaw; // as stored
  String? _triggerType; // normalized ("pretest"/"posttest")

  String? _currentSchoolYear;

  // ------ helpers

  String _norm(String? v) => (v ?? '').toLowerCase().replaceAll(' ', '').trim();
  bool _isPre(String? v) => _norm(v) == 'pretest';
  bool _isPost(String? v) => _norm(v) == 'posttest';

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _setupListeners();
    _checkPromotionStatus();
    _loadCurrentSchoolYear();
  }

  Future<void> _loadCurrentSchoolYear() async {
    final doc = await _firestore.collection('Settings').doc('SchoolYear').get();
    if (doc.exists) {
      setState(() => _currentSchoolYear = doc.data()?['active']);
    }
  }

  void _setupListeners() {
    // Trigger listener — normalize type here
    _triggerSubscription = _firestore
        .collection('Students')
        .doc(widget.studentId)
        .collection('Triggers')
        .doc('AssessmentTrigger')
        .snapshots()
        .listen((snapshot) {
      final active = snapshot.exists ? (snapshot.data()?['start'] ?? false) : false;
      final rawType = snapshot.exists ? (snapshot.data()?['type']?.toString()) : null;
      setState(() {
        _assessmentTriggerActive = active;
        _triggerTypeRaw = rawType;
        _triggerType = _norm(rawType); // <-- IMPORTANT (fixes "Post test" vs "posttest")
      });
    });

    // Assigned list listener
    _assessmentsSubscription = _firestore
        .collection('Students')
        .doc(widget.studentId)
        .collection('AssignedAssessments')
        .snapshots()
        .listen((_) => loadAssignedItems());

    // Student + Teacher listeners
    _studentSubscription = _firestore.collection('Students').doc(widget.studentId).snapshots().listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final newSY = data['schoolYear'];
      setState(() {
        currentTeacherId = data['teacherId'];
        _currentSchoolYear = newSY ?? _currentSchoolYear;
      });

      if (currentTeacherId != null) {
        _teacherSubscription?.cancel();
        _teacherSubscription = _firestore.collection('Teachers').doc(currentTeacherId).snapshots().listen((tSnap) {
          if (tSnap.exists) {
            setState(() => currentTeacherName = tSnap['name']);
          }
        });
      }

      // Recompute completion status for the current SY from performance records
      await _computeCompletionFromPerformance();
    });
  }

  // FIXED: Only check completion for CURRENT school year
  Future<void> _computeCompletionFromPerformance() async {
    final sy = _currentSchoolYear;
    if (sy == null || sy.isEmpty) return;

    bool hasPre = false;
    bool hasPost = false;

    // Only get performances for the CURRENT school year
    final perf = await _firestore
        .collection('StudentPerformance')
        .where('studentId', isEqualTo: widget.studentId)
        .where('schoolYear', isEqualTo: sy)
        .get();

    for (var d in perf.docs) {
      final data = d.data() as Map<String, dynamic>;
      final t = _norm(data['type']?.toString());

      final done = await _firestore
          .collection('MiscueRecords')
          .where('performanceId', isEqualTo: d.id)
          .where('schoolYear', isEqualTo: sy) // Only check miscues for current SY
          .limit(1)
          .get();

      if (done.docs.isNotEmpty) {
        if (t == 'pretest') {
          hasPre = true;
        } else if (t == 'posttest') {
          hasPost = true;
        }
      }
    }

    if (mounted) {
      setState(() {
        pretestCompleted = hasPre;
        posttestCompleted = hasPost;
      });
    }
  }

  Future<void> _checkPromotionStatus() async {
    final studentDoc = await _firestore.collection('Students').doc(widget.studentId).get();
    if (studentDoc.exists && (studentDoc.data()?['needsAssessmentRefresh'] == true)) {
      await _firestore.collection('Students').doc(widget.studentId).update({'needsAssessmentRefresh': false});
      await loadAssignedItems();
    }
  }

  bool _isAssessmentVisible(String quizId, String type) {
    // Already completed -> always visible
    if (quizDetails.containsKey(quizId)) return true;

    // Requires teacher trigger
    if (!_assessmentTriggerActive) return false;

    // Normalize both
    return _norm(type) == _triggerType;
  }

  // FIXED: Removed the check for completion in any school year
  bool _isAssessmentEnabled(String quizId, String type) {
    if (quizDetails.containsKey(quizId)) return false;
    if (!_assessmentTriggerActive) return false;

    final t = _norm(type);
    if (t == 'pretest') return !pretestCompleted;
    if (t == 'posttest') return pretestCompleted && !posttestCompleted;
    return false;
  }

  Future<void> loadAssignedItems() async {
    try {
      setState(() => isLoading = true);

      // Load active SY
      final syDoc = await _firestore.collection('Settings').doc('SchoolYear').get();
      final activeSY = syDoc.data()?['active'] ?? '';
      if (activeSY.isEmpty) throw Exception('Active SchoolYear not set');

      _currentSchoolYear = activeSY;

      // ✅ Only pull assessments for CURRENT SY
      final assignedAssessments = await _firestore
          .collection('Students')
          .doc(widget.studentId)
          .collection('AssignedAssessments')
          .where('schoolYear', isEqualTo: activeSY)
          .orderBy('assignedAt', descending: true)
          .get();

      // ✅ Only pull performances for CURRENT SY
      final performanceSnapshot = await _firestore
          .collection('StudentPerformance')
          .where('studentId', isEqualTo: widget.studentId)
          .where('schoolYear', isEqualTo: activeSY)
          .get();

      // ✅ Build quiz details scoped per SY
      final Map<String, Map<String, dynamic>> details = {};
      for (var doc in performanceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final qz = (data['quizId'] ?? '') as String;
        final total = (data['totalQuestions'] ?? 0) as int;
        final score = (data['totalScore'] ?? 0) as int;

        details[qz] = {
          'score': '$score/${total == 0 ? 1 : total}',
          'type': data['type'] ?? 'Unknown',
          'schoolYear': activeSY, // ✅ keep year reference
        };
      }

      // ✅ recompute completion strictly per current SY
      await _computeCompletionFromPerformance();

      if (mounted) {
        setState(() {
          assignedItems = assignedAssessments.docs;
          quizDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading assigned items: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load assessments: ${e.toString()}')),
        );
      }
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<String?> createOrUpdateStudentPerformanceRecord(
    String studentId,
    String storyId,
    String quizId,
    String type,
  ) async {
    try {
      final schoolYearDoc = await _firestore.collection('Settings').doc('SchoolYear').get();
      final sy = _currentSchoolYear ?? schoolYearDoc.data()?['active'] ?? '';

      // If already exists for this SY + quizId, reuse
      final existing = await _firestore
          .collection('StudentPerformance')
          .where('studentId', isEqualTo: studentId)
          .where('quizId', isEqualTo: quizId)
          .where('schoolYear', isEqualTo: sy)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return existing.docs.first.id;

      // Get teacher info from student document
      final studentDoc = await _firestore.collection('Students').doc(studentId).get();
      final teacherId = studentDoc.data()?['teacherId'] ?? '';
      
      // Get teacher name
      String teacherName = '';
      if (teacherId.isNotEmpty) {
        final teacherDoc = await _firestore.collection('Teachers').doc(teacherId).get();
        teacherName = teacherDoc.data()?['name'] ?? '';
      }

      final newRef = await _firestore.collection('StudentPerformance').add({
        'studentId': studentId,
        'storyId': storyId,
        'quizId': quizId,
        'startTime': Timestamp.now(),
        'type': _norm(type), // store normalized type
        'doneReading': false,
        'miscueMarks': {},
        'totalScore': 0,
        'totalQuestions': 0,
        'schoolYear': sy,
        'teacherId': teacherId, // Record teacher ID
        
      });

      return newRef.id;
    } catch (e) {
      debugPrint("Error creating performance record: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _triggerSubscription?.cancel();
    _assessmentsSubscription?.cancel();
    _studentSubscription?.cancel();
    _teacherSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Loading...', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ASSIGNED PASSAGES', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        leading: null,
      ),
      body: Stack(
        children: [
          Background(
            child: Column(
              children: [
                if (currentTeacherName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Current Teacher: $currentTeacherName',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                if (_assessmentTriggerActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Active: ${_triggerType == 'pretest' ? 'Pre-test' : 'Post-test'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                if (_currentSchoolYear != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'School Year: $_currentSchoolYear',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => loadAssignedItems(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10.0),
                      itemCount: assignedItems.length,
                      itemBuilder: (context, index) {
                        final item = assignedItems[index];
                        final storyId = item['storyId'] as String;
                        final quizId = item['quizId'] as String;
                        final rawType = item['type'] as String? ?? 'Unknown';
                        final typeNorm = _norm(rawType);

                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore.collection('Stories').doc(storyId).get(),
                          builder: (context, storySnapshot) {
                            if (storySnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (storySnapshot.hasError || !storySnapshot.hasData || !storySnapshot.data!.exists) {
                              return const Center(child: Text('Story not found', style: TextStyle(color: Colors.white)));
                            }

                            final storyData = storySnapshot.data!;
                            final storyTitle = storyData['title'] as String? ?? 'No Title';
                            final isCompleted = quizDetails.containsKey(quizId);
                            final quizDetail = quizDetails[quizId] ?? {};
                            final score = quizDetail["score"] ?? '0/0';
                            final bool isEnabled = _isAssessmentEnabled(quizId, typeNorm);
                            final bool isVisible = _isAssessmentVisible(quizId, typeNorm);

                            if (!isVisible) return const SizedBox.shrink();

                            return Card(
                              color: isCompleted ? Colors.amber : Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        storyTitle,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (_assessmentTriggerActive && _triggerType == typeNorm)
                                      const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                                    if (isCompleted) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Type: ${typeNorm == 'pretest' ? 'Pretest' : typeNorm == 'posttest' ? 'Post-test' : rawType}",
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    if (isCompleted)
                                      Text("Score: $score", style: const TextStyle(color: Colors.white, fontSize: 14)),
                                    if (!isEnabled && !isCompleted)
                                      Text(
                                        typeNorm == 'posttest' && !pretestCompleted
                                            ? 'Complete pretest first'
                                            : 'Waiting for teacher...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: (isEnabled && !_isProcessing) ? () => _startAssessment(storyId, quizId, typeNorm) : null,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    backgroundColor: isEnabled ? Colors.white : Colors.grey,
                                  ),
                                  child: Text(isCompleted ? 'Completed' : 'Read & Quiz'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Future<void> _startAssessment(String storyId, String quizId, String typeNorm) async {
    setState(() => _isProcessing = true);

    try {
      final performanceId = await createOrUpdateStudentPerformanceRecord(
        widget.studentId,
        storyId,
        quizId,
        typeNorm,
      );

      if (performanceId != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryDetailAndQuizPage(
              storyId: storyId,
              quizId: quizId,
              studentId: widget.studentId,
              startTime: DateTime.now(),
              performanceId: performanceId,
            ),
          ),
        );
        loadAssignedItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assessment error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}