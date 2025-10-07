import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

class PromotionConfigScreen extends StatefulWidget {
  final Set<String> selectedStudentIds;
  final List<Map<String, dynamic>> users;
  final String? selectedTeacherId;
  final VoidCallback onStudentsPromoted;
  final String? currentSchoolId;

  const PromotionConfigScreen({
    super.key,
    required this.selectedStudentIds,
    required this.users,
    required this.selectedTeacherId,
    required this.onStudentsPromoted,
    this.currentSchoolId,
  });

  @override
  State<PromotionConfigScreen> createState() => _PromotionConfigScreenState();
}

class _PromotionConfigScreenState extends State<PromotionConfigScreen> {
  bool promoteGradeLevel = true;
  bool promoteSchoolYear = true;
  bool assignNewPretest = true;
  Map<String, int> studentGstValues = {};
  String? selectedTeacherId;
  bool isLoading = false;
  bool isSchoolLoading = false;
  List<Map<String, dynamic>> filteredTeachers = [];
  Map<String, List<Map<String, dynamic>>> schoolGroups = {};
  Map<String, String> schoolNames = {};

  @override
  void initState() {
    super.initState();
    selectedTeacherId = widget.selectedTeacherId;
    
    for (final studentId in widget.selectedStudentIds) {
      final student = widget.users.firstWhere(
        (u) => u['id'] == studentId && u['role'] == 'student');
      studentGstValues[studentId] = student['gstScore'] ?? 0;
    }
    
    schoolGroups = _groupStudentsBySchool();
    _loadTeachersForSchool();
    _loadSchoolNames();
    
    FlutterError.onError = (details) {
      FirebaseFirestore.instance.collection('ErrorLogs').add({
        'error': details.exception.toString(),
        'stack': details.stack?.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'screen': 'PromotionConfig',
      });
    };
  }

  Future<void> _loadSchoolNames() async {
    if (schoolGroups.isEmpty) return;
    
    setState(() => isSchoolLoading = true);
    
    try {
      final schoolIds = schoolGroups.keys.toList();
      final schoolsSnapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .where(FieldPath.documentId, whereIn: schoolIds)
          .get();

      final tempSchoolNames = <String, String>{};
      for (var doc in schoolsSnapshot.docs) {
        tempSchoolNames[doc.id] = doc['name'] ?? 'Unknown School';
      }

      setState(() => schoolNames = tempSchoolNames);
    } catch (e) {
      debugPrint('Error loading school names: $e');
      final tempSchoolNames = <String, String>{};
      for (var id in schoolGroups.keys) {
        tempSchoolNames[id] = 'Unknown School';
      }
      setState(() => schoolNames = tempSchoolNames);
    } finally {
      setState(() => isSchoolLoading = false);
    }
  }

  Future<void> _loadTeachersForSchool() async {
    setState(() => isLoading = true);
    
    try {
      if (widget.currentSchoolId != null) {
        final schoolTeachersSnapshot = await FirebaseFirestore.instance
            .collection('Teachers')
            .where('schoolId', isEqualTo: widget.currentSchoolId)
            .get();

        final schoolTeacherIds = schoolTeachersSnapshot.docs.map((doc) => doc.id).toSet();
        
        setState(() {
          filteredTeachers = widget.users.where((user) => 
            user['role'] == 'teacher' && schoolTeacherIds.contains(user['id'])
          ).toList();
          
          if (selectedTeacherId != null && 
              !filteredTeachers.any((t) => t['id'] == selectedTeacherId)) {
            selectedTeacherId = filteredTeachers.isNotEmpty ? filteredTeachers.first['id'] : null;
          }
        });
      } else {
        setState(() {
          filteredTeachers = widget.users.where((u) => u['role'] == 'teacher').toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load teachers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupStudentsBySchool() {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    
    for (final studentId in widget.selectedStudentIds) {
      final student = widget.users.firstWhere(
        (u) => u['id'] == studentId && u['role'] == 'student');
      
      final schoolId = student['schoolId'] ?? '';
      if (!groups.containsKey(schoolId)) {
        groups[schoolId] = [];
      }
      groups[schoolId]!.add(student);
    }
    
    return groups;
  }

  String _getSchoolName(String schoolId) {
    return schoolNames.containsKey(schoolId) ? schoolNames[schoolId]! : 'Loading...';
  }

  Future<void> _promoteStudents() async {
    if (widget.selectedStudentIds.isEmpty) return;

    setState(() => isLoading = true);
    
    try {
      final schoolYearDoc = await FirebaseFirestore.instance
          .collection('Settings')
          .doc('SchoolYear')
          .get();
      final currentSchoolYear = schoolYearDoc.data()?['active'] ?? '';

      for (final studentId in widget.selectedStudentIds) {
        final student = widget.users.firstWhere(
          (u) => u['id'] == studentId && u['role'] == 'student');
        
        final nextGrade = promoteGradeLevel 
            ? _getNextGrade(student['gradeLevel']) 
            : student['gradeLevel'];
        final nextYear = promoteSchoolYear 
            ? _getNextSchoolYear(student['schoolYear']) 
            : currentSchoolYear;
        final gstValue = studentGstValues[studentId] ?? 0;

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final studentDoc = await transaction.get(
            FirebaseFirestore.instance.collection('Students').doc(studentId));

          if (!studentDoc.exists) return;

          transaction.update(studentDoc.reference, {
            'gradeLevel': nextGrade,
            'schoolYear': nextYear,
            'teacherId': selectedTeacherId,
            'lastPromoted': FieldValue.serverTimestamp(),
            'isPromoted': true,
            'needsAssessmentRefresh': true,
          });

          transaction.set(
            FirebaseFirestore.instance.collection('PromotedStudents').doc(),
            {
              'originalStudentId': studentId,
              'previousGrade': student['gradeLevel'],
              'newGrade': nextGrade,
              'previousYear': student['schoolYear'],
              'newYear': nextYear,
              'previousTeacher': student['teacherId'],
              'newTeacher': selectedTeacherId,
              'promotedAt': FieldValue.serverTimestamp(),
              'gstScore': gstValue,
              'schoolId': student['schoolId'],
            }
          );
        });

        if (assignNewPretest) {
          await _assignPretest(studentId, gstValue, nextGrade, nextYear);
        }
      }

      widget.onStudentsPromoted();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully promoted ${widget.selectedStudentIds.length} students'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promotion failed: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _getNextSchoolYear(String currentYear) {
    try {
      final parts = currentYear.split('-');
      if (parts.length != 2) return currentYear;
      
      final start = int.tryParse(parts[0]) ?? 0;
      final end = int.tryParse(parts[1]) ?? 0;
      
      if (currentYear == '2024-2025') {
        return '2025-2026';
      }
      
      if (end != start + 1) {
        return '${start + 1}-${start + 2}';
      }
      
      return '${start + 1}-${end + 1}';
    } catch (e) {
      return currentYear;
    }
  }

  String _getNextGrade(String currentGrade) {
    return currentGrade == '5' ? '6' : currentGrade;
  }

  String _getAssignedGradeLevel(String currentGrade, int gstScore) {
    if (gstScore >= 14) return 'Discontinue testing';
    
    int current = int.parse(currentGrade);
    int adjusted = gstScore <= 7 ? current - 3 : current - 2;
    adjusted = adjusted.clamp(1, 6);
    
    return 'Grade $adjusted (${gstScore <= 7 ? '3 levels below' : '2 levels below'})';
  }

  Future<void> _assignPretest(String userId, int gstScore, String gradeLevel, String schoolYear) async {
    try {
      if (gstScore >= 14) {
        await FirebaseFirestore.instance.collection('Students').doc(userId).update({
          'pretestCompleted': true,
          'readingLevel': 'Independent',
          'lastAssessmentUpdate': FieldValue.serverTimestamp(),
        });
        return;
      }

      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(userId)
          .get();
      
      if (!studentDoc.exists) {
        throw Exception('Student document not found');
      }

      final existingAssessments = await FirebaseFirestore.instance
          .collection('Students')
          .doc(userId)
          .collection('AssignedAssessments')
          .where('schoolYear', isEqualTo: schoolYear)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in existingAssessments.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      int adjustedGradeLevel = gstScore <= 7 
          ? int.parse(gradeLevel) - 3 
          : int.parse(gradeLevel) - 2;
      adjustedGradeLevel = adjustedGradeLevel.clamp(1, 6);

      final globalAssignments = await FirebaseFirestore.instance
          .collection('GlobalAssignments')
          .doc('assignments')
          .get();

      if (!globalAssignments.exists) {
        throw Exception('Global assignments configuration not found');
      }

      final globalAssignmentData = globalAssignments.data()!;
      final sets = ['A', 'B', 'C', 'D'];
      String leastAssignedSet = sets.first;
      int minCount = globalAssignmentData['Set $leastAssignedSet'] ?? 0;
      
      for (final set in sets) {
        final count = globalAssignmentData['Set $set'] ?? 0;
        if (count < minCount) {
          leastAssignedSet = set;
          minCount = count;
        }
      }

      await FirebaseFirestore.instance
          .collection('GlobalAssignments')
          .doc('assignments')
          .update({'Set $leastAssignedSet': FieldValue.increment(1)});

      final storyQuery = await FirebaseFirestore.instance
          .collection('Stories')
          .where('set', isEqualTo: 'Set $leastAssignedSet')
          .where('type', isEqualTo: 'pretest')
          .where('gradeLevel', isEqualTo: 'Grade $adjustedGradeLevel')
          .limit(1)
          .get();

      if (storyQuery.docs.isEmpty) {
        throw Exception('No stories found for Grade $adjustedGradeLevel, Set $leastAssignedSet');
      }
      
      final story = storyQuery.docs.first;
      final quizQuery = await FirebaseFirestore.instance
          .collection('Quizzes')
          .where('set', isEqualTo: 'Set $leastAssignedSet')
          .where('storyId', isEqualTo: story.id)
          .where('type', isEqualTo: 'pretest')
          .limit(1)
          .get();

      if (quizQuery.docs.isEmpty) {
        throw Exception('No quiz found for story ${story.id}');
      }
      final quiz = quizQuery.docs.first;

      final newAssignmentData = {
        'assignedAt': FieldValue.serverTimestamp(),
        'assignedGradeLevel': 'Grade $adjustedGradeLevel',
        'set': leastAssignedSet,
        'type': 'Pretest',
        'quizId': quiz.id,
        'storyId': story.id,
        'quizTitle': quiz['title'],
        'storyTitle': story['title'],
        'schoolYear': schoolYear,
        'gstScore': gstScore,
        'originalGradeLevel': gradeLevel,
        'status': 'pending',
        'assignedBy': 'system',
        'promotionBatch': true,
        'schoolId': studentDoc.data()?['schoolId'],
      };

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          FirebaseFirestore.instance
              .collection('Students')
              .doc(userId)
              .collection('AssignedAssessments')
              .doc(), 
          newAssignmentData
        );

        transaction.update(
          FirebaseFirestore.instance.collection('Students').doc(userId),
          {
            'readingLevel': gstScore <= 7 ? 'Frustration' : 'Instructional',
            'assignedAssessment': true,
            'lastAssessmentUpdate': FieldValue.serverTimestamp(),
            'currentAssessment': newAssignmentData,
          }
        );
      });
    } catch (e) {
      await FirebaseFirestore.instance.collection('ErrorLogs').add({
        'error': 'Assessment assignment failed',
        'studentId': userId,
        'gstScore': gstScore,
        'gradeLevel': gradeLevel,
        'schoolYear': schoolYear,
        'timestamp': FieldValue.serverTimestamp(),
        'stackTrace': e.toString(),
      });
      rethrow;
    }
  }

  Widget _buildStudentGstInputCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(
                    student['firstName'][0],
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student['firstName']} ${student['lastName']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Grade ${student['gradeLevel']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: (studentGstValues[student['id']] ?? 0).toString(),
                    decoration: InputDecoration(
                      labelText: 'GST Score (0-14)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final score = int.tryParse(value);
                      if (score != null && score >= 0 && score <= 14) {
                        setState(() => studentGstValues[student['id']] = score);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getGradeLevelColor(studentGstValues[student['id']] ?? 0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getGradeLevelColor(studentGstValues[student['id']] ?? 0).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getAssignedGradeLevel(student['gradeLevel'], studentGstValues[student['id']] ?? 0),
                    style: TextStyle(
                      color: _getGradeLevelColor(studentGstValues[student['id']] ?? 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGstIndicator(String score, String text, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      label: Text('$score: $text', 
        style: TextStyle(color: color, fontSize: 12)),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Color _getGradeLevelColor(int gstScore) {
    if (gstScore >= 14) return Colors.red;
    return gstScore <= 7 ? Colors.blue : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final currentSchoolStudents = widget.currentSchoolId != null 
        ? schoolGroups[widget.currentSchoolId] ?? []
        : widget.selectedStudentIds.map((id) => 
            widget.users.firstWhere((u) => u['id'] == id)).toList();

    final currentSchoolName = widget.currentSchoolId != null
        ? _getSchoolName(widget.currentSchoolId!)
        : schoolGroups.length == 1 
            ? _getSchoolName(schoolGroups.keys.first)
            : 'Multiple Schools';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Promotion'),
        backgroundColor: Colors.green,
      ),
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current School',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (isSchoolLoading)
                                const LinearProgressIndicator()
                              else
                                Text(
                                  currentSchoolName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (schoolGroups.length > 1) ...[
                    const Text(
                      'Available Schools:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: schoolGroups.keys.map((schoolId) {
                          final schoolName = _getSchoolName(schoolId);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: isSchoolLoading
                                  ? const SizedBox(
                                      width: 100,
                                      height: 24,
                                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    )
                                  : Text('$schoolName (${schoolGroups[schoolId]!.length})'),
                              backgroundColor: schoolId == widget.currentSchoolId
                                  ? Colors.green[100]
                                  : Colors.grey[200],
                              labelStyle: TextStyle(
                                color: schoolId == widget.currentSchoolId 
                                    ? Colors.green[700]
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    'Teacher Assignment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.currentSchoolId != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Teachers from $currentSchoolName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (filteredTeachers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: const Text(
                        'No teachers available for this school',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedTeacherId,
                      decoration: InputDecoration(
                        labelText: 'Assign to Teacher',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: filteredTeachers.map<DropdownMenuItem<String>>((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['id'],
                          child: Text(
                            teacher['name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedTeacherId = value),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Promotion Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: promoteGradeLevel,
                    onChanged: (v) => setState(() => promoteGradeLevel = v),
                    title: const Text('Promote to next grade level'),
                    subtitle: const Text('Current grade → Next grade (e.g., Grade 5 → Grade 6)'),
                  ),
                  SwitchListTile(
                    value: promoteSchoolYear,
                    onChanged: (v) => setState(() => promoteSchoolYear = v),
                    title: const Text('Promote to next school year'),
                    subtitle: const Text('Current SY → Next SY (e.g., 2023-2024 → 2024-2025)'),
                  ),
                  SwitchListTile(
                    value: assignNewPretest,
                    onChanged: (v) => setState(() => assignNewPretest = v),
                    title: const Text('Assign new pretest'),
                    subtitle: const Text('Automatically assign appropriate reading pretest'),
                  ),
                  const SizedBox(height: 24),
                  
                  if (assignNewPretest) ...[
                    const Text(
                      'Reading Level Assessment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Based on Phil-IRI Graded Silent Test (0-14)'),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildGstIndicator('0-7', 'Frustration (3 levels below)', Colors.red),
                        _buildGstIndicator('8-13', 'Instructional (2 levels below)', Colors.orange),
                        _buildGstIndicator('14', 'Independent (Current level)', Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Enter GST Scores for Selected Students:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    ...currentSchoolStudents.map((student) {
                      return _buildStudentGstInputCard(student);
                    }).toList(),
                  ],
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _promoteStudents,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('Confirm Promotion', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}