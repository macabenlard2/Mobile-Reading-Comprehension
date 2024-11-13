import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/models/student_model.dart';
import 'package:reading_comprehension/teacher/mark_miscues_page.dart';
import 'package:reading_comprehension/teacher/student_detail_page.dart';
import 'package:reading_comprehension/widgets/background.dart';

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

  // Mock fetching passage ID, replace this function with actual fetching logic
  Future<String?> _fetchPassageId(String studentId) async {
    return 'examplePassageId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student List',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedGrade,
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value!;
                        });
                      },
                      items: <String>['All', '1', '2', '3', '4', '5', '6', '7']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('Grade $value'),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      items: <String>['All', 'Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                    onPressed: () {
                      setState(() {
                        _isAscending = !_isAscending;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Students')
                    .where('teacherId', isEqualTo: widget.teacherId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading students.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No students found.'));
                  }

                 var students = snapshot.data!.docs.map((doc) {
                     return Student.fromFirestore(doc); // Pass the DocumentSnapshot
                    }).toList();


                  if (_searchText.isNotEmpty) {
                    students = students.where((student) {
                      final fullName = '${student.firstName ?? ''} ${student.lastName ?? ''}'.toLowerCase();
                      return fullName.contains(_searchText.toLowerCase());
                    }).toList();
                  }

                  if (_selectedGrade != 'All') {
                    students = students.where((student) {
                      return student.gradeLevel == _selectedGrade;
                    }).toList();
                  }

                  if (_selectedGender != 'All') {
                    students = students.where((student) {
                      return student.gender == _selectedGender;
                    }).toList();
                  }

                  students.sort((a, b) {
                    final comparison = (a.firstName ?? '').compareTo(b.firstName ?? '');
                    return _isAscending ? comparison : -comparison;
                  });

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentId = student.id;

                      return ListTile(
                        title: Text('${student.firstName ?? ''} ${student.lastName ?? ''}'),
                        subtitle: Text('Grade: ${student.gradeLevel}\nGender: ${student.gender}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.book, color: Colors.black),
                          onPressed: () async {
                            if (studentId == null) {
                              print('Error: studentId is null');
                              return;
                            }
                            print('Button pressed for student: $studentId');
                            String? passageId = await _fetchPassageId(studentId);
                            print('Fetched passage ID: $passageId');
                            if (passageId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MarkMiscuesPage(
                                    studentId: studentId,
                                    passageId: passageId,
                                  ),
                                ),
                              );
                            } else {
                              print('Error: passageId is null');
                            }
                          },
                        ),
                        leading: CircleAvatar(
                          backgroundImage: (student.profilePictureUrl ?? '').isNotEmpty
                              ? NetworkImage(student.profilePictureUrl!)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailPage(student: student),
                            ),
                          );
                        },
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
