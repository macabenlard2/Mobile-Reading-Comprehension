import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

class AssignTeacherScreen extends StatefulWidget {
  final Set<String> selectedStudentIds;
  final List<Map<String, dynamic>> users;
  final String? selectedTeacherId;
  final VoidCallback onTeacherAssigned;
  final String? schoolId; // Add this line

  const AssignTeacherScreen({
    super.key,
    required this.selectedStudentIds,
    required this.users,
    required this.selectedTeacherId,
    required this.onTeacherAssigned,
    required this.schoolId, // Add this line
  });

  @override
  State<AssignTeacherScreen> createState() => _AssignTeacherScreenState();
}

class _AssignTeacherScreenState extends State<AssignTeacherScreen> {
  String? selectedTeacherId;
  bool isLoading = false;
  List<Map<String, dynamic>> filteredTeachers = [];

  @override
  void initState() {
    super.initState();
    selectedTeacherId = widget.selectedTeacherId;
    _loadTeachersForSchool();
  }

  Future<void> _loadTeachersForSchool() async {
    setState(() => isLoading = true);
    
    try {
      // First get all teachers from the users list that belong to the same school
      final allTeachers = widget.users.where((u) => u['role'] == 'teacher').toList();
      
      if (widget.schoolId != null) {
        // Fetch teachers that are assigned to the same school
        final schoolTeachersSnapshot = await FirebaseFirestore.instance
            .collection('Teachers')
            .where('schoolId', isEqualTo: widget.schoolId)
            .get();

        final schoolTeacherIds = schoolTeachersSnapshot.docs.map((doc) => doc.id).toSet();
        
        setState(() {
          filteredTeachers = allTeachers.where((teacher) => 
            schoolTeacherIds.contains(teacher['id'])
          ).toList();
          
          // Reset selected teacher if it's not in the filtered list
          if (selectedTeacherId != null && 
              !filteredTeachers.any((t) => t['id'] == selectedTeacherId)) {
            selectedTeacherId = filteredTeachers.isNotEmpty ? filteredTeachers.first['id'] : null;
          }
        });
      } else {
        // If no school is selected, show all teachers
        setState(() {
          filteredTeachers = allTeachers;
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

  Future<void> _assignTeacherOnly() async {
    if (widget.selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student')),
      );
      return;
    }

    if (selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a teacher')),
      );
      return;
    }

    setState(() => isLoading = true);
    final batch = FirebaseFirestore.instance.batch();

    try {
      for (final studentId in widget.selectedStudentIds) {
        final studentRef = FirebaseFirestore.instance.collection('Students').doc(studentId);
        batch.update(studentRef, {
          'teacherId': selectedTeacherId,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully assigned ${widget.selectedStudentIds.length} students to teacher'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onTeacherAssigned();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assignment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Teacher'),
        backgroundColor: Colors.blue,
      ),
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Teacher for Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.schoolId != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Showing teachers from the same school',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTeachers.isEmpty
                          ? const Text(
                              'No teachers available for this school',
                              style: TextStyle(color: Colors.red),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedTeacherId,
                              decoration: InputDecoration(
                                labelText: 'Assign to Teacher',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: filteredTeachers.map<DropdownMenuItem<String>>((teacher) => DropdownMenuItem<String>(
                                value: teacher['id'],
                                child: Text(teacher['name']),
                              )).toList(),
                              onChanged: (value) => setState(() => selectedTeacherId = value),
                            ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selected Students:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.selectedStudentIds.map((studentId) {
                    final student = widget.users.firstWhere((u) => u['id'] == studentId);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          student['firstName'][0],
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      title: Text('${student['firstName']} ${student['lastName']}'),
                      subtitle: Text('Grade ${student['gradeLevel']} - Current Teacher: ${student['teacherName']}'),
                    );
                  }).toList(),
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
                          onPressed: filteredTeachers.isEmpty ? null : _assignTeacherOnly,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filteredTeachers.isEmpty ? Colors.grey : Colors.blue,
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
                              : const Text('Confirm Assignment', style: TextStyle(color: Colors.black)),
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