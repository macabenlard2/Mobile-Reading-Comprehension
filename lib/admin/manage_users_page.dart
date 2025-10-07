import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/Screens/assign_teacher_screen.dart';
import 'package:reading_comprehension/Screens/promotion_config_screen.dart';
import 'package:reading_comprehension/widgets/background.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});
  static const int maxGstScore = 14;
  static const int thresholdScore = 7;

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  String searchQuery = '';
  bool isLoading = false;
  bool isSchoolLoading = false;
  Map<String, int> studentGstValues = {};
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> schools = [];
  Set<String> selectedStudentIds = {};
  List<String> schoolYears = [];
  String? selectedSchoolYear;
  String? selectedTeacherId;
  String? selectedSchoolId;
  Map<String, String> schoolNames = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await _loadSchoolYears();
    if (selectedSchoolYear != null) {
      await _loadSchools();
      await _loadUsers();
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadSchoolYears() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Settings')
          .doc('SchoolYears')
          .collection('List')
          .get();
      
      final now = DateTime.now();
      final currentMonth = now.month;
      int currentYear = now.year;
      
      if (currentMonth < 8) {
        currentYear -= 1;
      }
      
      final allYears = snapshot.docs.map((doc) => doc.id).toList();
      allYears.sort((a, b) => b.compareTo(a));
      
      String? activeYear;
      for (final year in allYears) {
        final parts = year.split('-');
        if (parts.length == 2) {
          final startYear = int.tryParse(parts[0]);
          if (startYear == currentYear) {
            activeYear = year;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        schoolYears = allYears;
        selectedSchoolYear = activeYear ?? (schoolYears.isNotEmpty ? schoolYears.first : null);
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load school years: $e');
      }
    }
  }

  Future<void> _loadSchools() async {
    try {
      setState(() => isSchoolLoading = true);
      final schoolsSnapshot = await FirebaseFirestore.instance.collection('Schools').get();
      
      final tempSchools = schoolsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? 'Unknown School',
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        schools = tempSchools;
        schoolNames = {for (var school in schools) school['id']: school['name']};
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load schools: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isSchoolLoading = false);
      }
    }
  }

  Future<void> _loadUsers() async {
    if (selectedSchoolYear == null) return;
    
    try {
      setState(() {
        isLoading = true;
        users = [];
        selectedStudentIds.clear();
        studentGstValues.clear();
      });
      
      final teachersSnap = await FirebaseFirestore.instance.collection('Teachers').get();
      final studentsQuery = selectedSchoolId != null
          ? FirebaseFirestore.instance
              .collection('Students')
              .where('schoolYear', isEqualTo: selectedSchoolYear)
              .where('schoolId', isEqualTo: selectedSchoolId)
          : FirebaseFirestore.instance
              .collection('Students')
              .where('schoolYear', isEqualTo: selectedSchoolYear);

      final studentsSnap = await studentsQuery.get();

      final teachers = teachersSnap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': '${data['firstname']} ${data['lastname']}',
          'role': 'teacher',
          'schoolId': data['schoolId'],
        };
      }).toList();

      final students = studentsSnap.docs.map((doc) {
        final data = doc.data();
        final teacherId = data['teacherId'];
        final teacher = teachers.firstWhere(
          (t) => t['id'] == teacherId,
          orElse: () => {'name': 'None', 'schoolId': ''},
        );
        
        return {
          'id': doc.id,
          'email': data['email'],
          'role': 'student',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'teacherId': teacherId,
          'teacherName': teacher['name'],
          'gradeLevel': data['gradeLevel'] ?? '5',
          'schoolYear': data['schoolYear'],
          'originalStudentId': data['originalStudentId'] ?? doc.id,
          'schoolId': data['schoolId'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        users = [...teachers, ...students];
        selectedTeacherId = teachers.isNotEmpty ? teachers.first['id'] : null;
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load users: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

 void _toggleSelectAll(bool? selectAll) {
  if (selectAll ?? false) {
    final filtered = _getFilteredStudents();

    // Check if all students belong to the same school
    final schoolIds = filtered.map((s) => s['schoolId']).toSet();
    if (schoolIds.length > 1) {
      _showErrorSnackbar('Cannot select all: Students belong to different schools.');
      return;
    }

    setState(() {
      for (var student in filtered) {
        selectedStudentIds.add(student['id']);
        studentGstValues.putIfAbsent(student['id'], () => 0);
      }
    });
  } else {
    setState(() {
      selectedStudentIds.clear();
      studentGstValues.clear();
    });
  }
}


  List<Map<String, dynamic>> _getFilteredStudents() {
    return users.where((u) => 
      u['role'] == 'student' &&
      '${u['firstName']} ${u['lastName']}'.toLowerCase().contains(searchQuery.toLowerCase()) &&
      (selectedSchoolId == null || u['schoolId'] == selectedSchoolId)
    ).toList();
  }

  String? _getCommonSchoolId() {
    if (selectedStudentIds.isEmpty) return null;
    
    String? commonSchoolId;
    for (final studentId in selectedStudentIds) {
      final student = users.firstWhere((u) => u['id'] == studentId && u['role'] == 'student');
      final schoolId = student['schoolId'];
      
      if (commonSchoolId == null) {
        commonSchoolId = schoolId;
      } else if (commonSchoolId != schoolId) {
        return null; // Multiple schools found
      }
    }
    
    return commonSchoolId;
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();
    final allSelected = filteredStudents.isNotEmpty && 
        selectedStudentIds.length == filteredStudents.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Student Promotion', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFilterSection(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildStudentListSection(filteredStudents, allSelected),
                ),
                if (selectedStudentIds.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildFilterSection() {
  return Column(
    children: [
      // 🔍 Search Field
      Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search students",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value.trim()),
            ),
          ),
          const SizedBox(width: 10),

          // 🎓 School Year Dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: selectedSchoolYear,
              hint: const Text("SY"),
              underline: Container(),
              items: schoolYears.map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (year) async {
                if (year != null && year != selectedSchoolYear) {
                  setState(() {
                    selectedSchoolYear = year;
                    isLoading = true;
                  });
                  try {
                    await _loadUsers();
                  } catch (e) {
                    _showErrorSnackbar('Failed to load students: $e');
                  } finally {
                    if (mounted) {
                      setState(() => isLoading = false);
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),

      // 🏫 School Dropdown
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButton<String>(
          value: selectedSchoolId,
          hint: const Text("All Schools"),
          underline: Container(),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text("All Schools"),
            ),
            ...schools.map((school) => DropdownMenuItem<String>(
              value: school['id'],
              child: Text(school['name']),
            )),
          ],
          onChanged: (schoolId) async {
            setState(() {
              selectedSchoolId = schoolId;
              isLoading = true;
            });
            try {
              await _loadUsers();
            } catch (e) {
              _showErrorSnackbar('Failed to filter students: $e');
            } finally {
              if (mounted) {
                setState(() => isLoading = false);
              }
            }
          },
        ),
      ),
    ],
  );
}


  Widget _buildStudentListSection(List<Map<String, dynamic>> students, bool allSelected) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          if (students.isNotEmpty) Padding(
            padding: const EdgeInsets.all(8.0),
            child: CheckboxListTile(
              title: const Text('Select All'),
              value: allSelected,
              onChanged: _toggleSelectAll,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No students found'),
                      ))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final isSelected = selectedStudentIds.contains(student['id']);
                          final schoolName = schoolNames[student['schoolId']] ?? 'Unknown School';
                          
                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                             onChanged: (checked) {
                              final currentSchoolId = student['schoolId'];
                              final selectedSchoolId = _getCommonSchoolId();

                              if (checked == true) {
                                // Allow if no students are selected or if all selected students belong to same school
                                if (selectedSchoolId == null || selectedSchoolId == currentSchoolId) {
                                  setState(() {
                                    selectedStudentIds.add(student['id']);
                                    studentGstValues.putIfAbsent(student['id'], () => 0);
                                  });
                                } else {
                                  _showErrorSnackbar('Cannot select students from different schools.');
                                }
                              } else {
                                setState(() {
                                  selectedStudentIds.remove(student['id']);
                                  studentGstValues.remove(student['id']);
                                });
                              }
                            },

                            ),
                            title: Text('${student['firstName']} ${student['lastName']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Grade: ${student['gradeLevel']} | Teacher: ${student['teacherName']}'),
                                Text('School: $schoolName'),
                              ],
                            ),
                            trailing: Text('SY: ${student['schoolYear']}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final commonSchoolId = _getCommonSchoolId();
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignTeacherScreen(
                    selectedStudentIds: selectedStudentIds,
                    users: users,
                    selectedTeacherId: selectedTeacherId,
                    onTeacherAssigned: () {
                      _loadUsers();
                      setState(() {
                        selectedStudentIds.clear();
                      });
                    },
                    schoolId: commonSchoolId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Assign Teacher Only', style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PromotionConfigScreen(
                    selectedStudentIds: selectedStudentIds,
                    users: users,
                    selectedTeacherId: selectedTeacherId,
                    onStudentsPromoted: () {
                      _loadUsers();
                      setState(() {
                        selectedStudentIds.clear();
                        studentGstValues.clear();
                      });
                    },
                    currentSchoolId: commonSchoolId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Configure Promotion', style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}