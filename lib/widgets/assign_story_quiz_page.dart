import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'dart:ui';
import 'package:reading_comprehension/utils/school_year_util.dart';

Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

class AssignStoryQuizPage extends StatefulWidget {
  final String teacherId;
  const AssignStoryQuizPage({super.key, required this.teacherId});

  @override
  _AssignStoryQuizPageState createState() => _AssignStoryQuizPageState();
}

class _AssignStoryQuizPageState extends State<AssignStoryQuizPage> {
  List<String> selectedStudents = [];
  String searchQuery = '';
  String? selectedGradeLevel = 'All';
  String? selectedStoryType;
  String? selectedPassageSet;
  String? selectedStoryId;
  Map<String, dynamic>? selectedStoryQuiz;
  List<Map<String, dynamic>> cachedStories = [];
  bool selectAll = false;
  bool _loading = false;
  String currentSchoolYear = '';

  @override
  void initState() {
    super.initState();
    _getCurrentSchoolYear();
  }

  Future<void> _getCurrentSchoolYear() async {
    currentSchoolYear = await getCurrentSchoolYear();
    setState(() {});
  }

  Future<Set<String>> _getStudentsWithAssignedTest(String testType) async {
    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('Students')
        .where('teacherId', isEqualTo: widget.teacherId)
        .where('schoolYear', isEqualTo: currentSchoolYear)
        .get();

    final Set<String> assignedStudentIds = {};

    for (var studentDoc in studentsSnapshot.docs) {
      final assignments = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentDoc.id)
          .collection('AssignedAssessments')
          .where('type', isEqualTo: testType)
          .where('schoolYear', isEqualTo: currentSchoolYear)
          .get();

      if (assignments.docs.isNotEmpty) {
        assignedStudentIds.add(studentDoc.id);
      }
    }

    return assignedStudentIds;
  }

  Future<List<Map<String, dynamic>>> _getAvailableStories(String type, String set) async {
    final storiesSnapshot = await FirebaseFirestore.instance
        .collection('Stories')
        .where('type', isEqualTo: type.toLowerCase())
        .where('set', isEqualTo: 'Set ${set.toUpperCase()}')
        .get();

    return storiesSnapshot.docs.map((doc) {
      return {
        'storyId': doc.id,
        'title': doc['title'],
        'gradeLevel': doc['gradeLevel'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Story & Quiz', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
      ),
      body: Background(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentSchoolYear.isEmpty)
                        const LinearProgressIndicator()
                      else
                        Text('Current School Year: $currentSchoolYear',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: ['Post test', 'Pretest'].contains(selectedStoryType) ? selectedStoryType : null,
                              decoration: InputDecoration(
                                labelText: 'Story Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: ['Post test', 'Pretest']
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStoryType = value;
                                  selectedPassageSet = null;
                                  selectedStoryQuiz = null;
                                  cachedStories.clear();
                                  selectedStudents.clear();
                                  selectAll = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: ['A', 'B', 'C', 'D'].contains(selectedPassageSet) ? selectedPassageSet : null,
                              decoration: InputDecoration(
                                labelText: 'Passage Set',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: ['A', 'B', 'C', 'D']
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPassageSet = value;
                                  selectedStoryQuiz = null;
                                  cachedStories.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStoryQuizDropdown(),
                      const Divider(thickness: 2, color: Colors.grey),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Search Students',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Select All'),
                        value: selectAll,
                        onChanged: (isChecked) async {
                          setState(() {
                            selectAll = isChecked ?? false;
                          });

                          if (selectAll) {
                            final students = await _getEligibleStudents();
                            setState(() {
                              selectedStudents = students.map((s) => s.id).toList();
                            });
                          } else {
                            setState(() {
                              selectedStudents.clear();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: _buildStudentList(),
                      ),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: validateBeforeAssigning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15A323),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Assign', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoryQuizDropdown() {
    if (selectedStoryType == null || selectedPassageSet == null) {
      return const Center(
        child: Text(
          'Please select Story Type and Passage Set first.',
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAvailableStories(selectedStoryType!, selectedPassageSet!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No stories available for the selected filters.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        cachedStories = snapshot.data!;
        cachedStories.sort((a, b) => a['title'].toString().toLowerCase().compareTo(b['title'].toString().toLowerCase()));

        return DropdownButtonFormField<String>(
          value: selectedStoryId,
          decoration: const InputDecoration(
            labelText: 'Select Story',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: cachedStories.map((story) {
            return DropdownMenuItem<String>(
              value: story['storyId'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    story['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${story['gradeLevel'] ?? "?"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedStoryId = value;
              selectedStoryQuiz =
                  cachedStories.firstWhere((story) => story['storyId'] == value);
            });
          },
          selectedItemBuilder: (context) {
            return cachedStories.map((story) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        story['title'],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${story['gradeLevel'] ?? "?"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 8,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          menuMaxHeight: 300.0,
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _getEligibleStudents() async {
    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('Students')
        .where('teacherId', isEqualTo: widget.teacherId)
        .where('schoolYear', isEqualTo: currentSchoolYear)
        .get();

    if (selectedStoryType == null) {
      return studentsSnapshot.docs;
    }

    final assignedStudentIds = await _getStudentsWithAssignedTest(selectedStoryType!);
    return studentsSnapshot.docs.where((doc) => !assignedStudentIds.contains(doc.id)).toList();
  }

  Widget _buildStudentList() {
    if (currentSchoolYear.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<DocumentSnapshot>>(
      future: _getEligibleStudents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final eligibleStudents = snapshot.data!;

        if (eligibleStudents.isEmpty) {
          return Center(
            child: Text(
              selectedStoryType == null 
                ? 'No students found for current school year.'
                : 'All current students already have a $selectedStoryType assigned.',
            ),
          );
        }

        final filteredStudents = eligibleStudents.where((student) {
          final name = '${student['firstName']} ${student['lastName']}'.toLowerCase();
          return name.contains(searchQuery);
        }).toList();

        if (filteredStudents.isEmpty) {
          return const Center(child: Text('No students match your search.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredStudents.length,
          itemBuilder: (context, index) {
            final student = filteredStudents[index];
            final name = '${student['firstName']} ${student['lastName']}';

            return CheckboxListTile(
              title: Text(name),
              subtitle: Text('Grade ${student['gradeLevel'] ?? 'Unknown'}'),
              value: selectedStudents.contains(student.id),
              onChanged: (isSelected) {
                setState(() {
                  if (isSelected == true) {
                    selectedStudents.add(student.id);
                  } else {
                    selectedStudents.remove(student.id);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  void validateBeforeAssigning() async {
    if (selectedStoryQuiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid story and quiz.')),
      );
      return;
    }

    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final quizQuerySnapshot = await FirebaseFirestore.instance
          .collection('Quizzes')
          .where('storyId', isEqualTo: selectedStoryQuiz!['storyId'])
          .get();

      if (quizQuerySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quiz found for the selected story.')),
        );
        return;
      }

      await assignQuizToStudents();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> assignQuizToStudents() async {
    if (selectedStoryQuiz == null || selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a story, quiz, and students.')),
      );
      return;
    }

    final storyId = selectedStoryQuiz!['storyId'];
    final storyTitle = selectedStoryQuiz!['title'];

    try {
      final quizQuerySnapshot = await FirebaseFirestore.instance
          .collection('Quizzes')
          .where('storyId', isEqualTo: storyId)
          .get();

      if (quizQuerySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quiz found for the selected story.')),
        );
        return;
      }

      final quizId = quizQuerySnapshot.docs.first.id;

      for (var studentId in selectedStudents) {
        // Check if this exact assignment already exists for current school year
        final existingAssignments = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .collection('AssignedAssessments')
          .where('type', isEqualTo: selectedStoryType)
          .where('storyId', isEqualTo: storyId)
          .where('schoolYear', isEqualTo: currentSchoolYear)
          .get();

        if (existingAssignments.docs.isNotEmpty) {
          continue; // Skip if already assigned
        }

        final studentDoc = await FirebaseFirestore.instance
            .collection('Students')
            .doc(studentId)
            .get();

        if (!studentDoc.exists) {
          continue;
        }
        
        final studentData = studentDoc.data()!;
        final gradeLevel = studentData['gradeLevel'] ?? 'Unknown';

        await FirebaseFirestore.instance
            .collection('Students')
            .doc(studentId)
            .collection('AssignedAssessments')
            .add({
          'storyId': storyId,
          'storyTitle': storyTitle,
          'quizId': quizId,
          'quizTitle': selectedStoryQuiz!['title'],
          'assignedAt': Timestamp.now(),
          'teacherId': widget.teacherId,
          'assignedGradeLevel': gradeLevel,
          'type': selectedStoryType,
          'set': selectedPassageSet,
          'schoolYear': currentSchoolYear,
          'status': 'pending',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment successful!')),
      );

      setState(() {
        selectedStudents.clear();
        selectAll = false;
        selectedStoryQuiz = null;
        selectedStoryId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error assigning quiz. Please try again.')),
      );
    }
  }
}