import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

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
  String? selectedReadingType;
  String? selectedStoryType;
  String? selectedPassageSet;
  String? selectedStory;
  String? selectedQuiz;
  bool selectAll = false;

  // To track the open state of each filter card
  bool isReadingTypeOpen = false;
  bool isStoryTypePassageSetOpen = false;
  bool isStoryQuizOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Passage',
          style: TextStyle(
            color: Colors.white, // Ensure the title is white
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Filters Section in Expandable Panels
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: [
                    _buildExpandableFilterCard(
                      title: 'Reading Type',
                      icon: Icons.filter_list,
                      isOpen: isReadingTypeOpen,
                      onToggle: () {
                        setState(() {
                          // Close other panels when this one opens
                          isReadingTypeOpen = !isReadingTypeOpen;
                          isStoryTypePassageSetOpen = false;
                          isStoryQuizOpen = false;
                        });
                      },
                      children: [
                        _buildDropdown(
                          label: 'Reading Type',
                          value: selectedReadingType,
                          items: ['Oral', 'Silent']
                              .map((type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type, style: const TextStyle(color: Colors.black)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedReadingType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableFilterCard(
                      title: 'Story Type & Passage Set',
                      icon: Icons.book,
                      isOpen: isStoryTypePassageSetOpen,
                      onToggle: () {
                        setState(() {
                          isStoryTypePassageSetOpen = !isStoryTypePassageSetOpen;
                          isReadingTypeOpen = false;
                          isStoryQuizOpen = false;
                        });
                      },
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Story Type',
                                value: selectedStoryType,
                                items: ['Custom', 'Pretest', 'Posttest']
                                    .map((type) => DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type, style: const TextStyle(color: Colors.black)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStoryType = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Passage Set',
                                value: selectedPassageSet,
                                items: ['A', 'B', 'C', 'D']
                                    .map((set) => DropdownMenuItem<String>(
                                          value: set,
                                          child: Text(set, style: const TextStyle(color: Colors.black)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedPassageSet = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableFilterCard(
                      title: 'Select Story & Quiz',
                      icon: Icons.question_answer,
                      isOpen: isStoryQuizOpen,
                      onToggle: () {
                        setState(() {
                          isStoryQuizOpen = !isStoryQuizOpen;
                          isReadingTypeOpen = false;
                          isStoryTypePassageSetOpen = false;
                        });
                      },
                      children: [
                        _buildStoryDropdown(), // Call the method for both Stories and TeacherStories
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 2, color: Colors.grey), // Enhanced Divider
              const SizedBox(height: 8),
              // Search and Grade Level combined with Select All
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Students')
                    .where('teacherId', isEqualTo: widget.teacherId)
                    .where('gradeLevel', isEqualTo: selectedGradeLevel != 'All' ? selectedGradeLevel : null)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var students = snapshot.data!.docs;

                  return Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value.toLowerCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Search Students',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF15A323)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _buildDropdown(
                                  label: 'Grade Level',
                                  value: selectedGradeLevel,
                                  items: ['All', '3', '4', '5', '6']
                                      .map((grade) => DropdownMenuItem<String>(
                                            value: grade,
                                            child: Text(grade, style: const TextStyle(color: Colors.black)),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGradeLevel = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  Checkbox(
                                    value: selectAll,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        selectAll = value ?? false;
                                        selectedStudents.clear();
                                        if (selectAll) {
                                          selectedStudents.addAll(students.map((doc) => doc.id));
                                        }
                                      });
                                    },
                                    activeColor: const Color(0xFF15A323),
                                  ),
                                  const Text(
                                    "All",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // List of Students with Checkboxes
                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(8),
                            child: ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                var student = students[index];
                                String name = (student['firstName'] ?? 'No Firstname') +
                                    ' ' +
                                    (student['lastName'] ?? 'No Lastname');
                                return CheckboxListTile(
                                  title: Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                                  value: selectedStudents.contains(student.id),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected!) {
                                        selectedStudents.add(student.id);
                                      } else {
                                        selectedStudents.remove(student.id);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: const Color(0xFF15A323),
                                  checkColor: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  assignQuizToStudents();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15A323),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Assign to Students',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for creating expandable filter cards
  Widget _buildExpandableFilterCard({
    required String title,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF15A323)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        onExpansionChanged: (expanded) {
          onToggle();
        },
        initiallyExpanded: isOpen,
        children: children,
      ),
    );
  }

  // Helper method for creating dropdowns
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  // Fetch associated quiz when a story is selected
  void fetchAssociatedQuiz(String? storyId) {
    FirebaseFirestore.instance
        .collection('Quizzes')
        .where('storyId', isEqualTo: storyId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          selectedQuiz = snapshot.docs.first.id;
        });
      } else {
        // If not found in default Quizzes, check TeacherQuizzes
        FirebaseFirestore.instance
            .collection('Teachers')
            .doc(widget.teacherId)
            .collection('TeacherQuizzes')
            .where('storyId', isEqualTo: storyId)
            .get()
            .then((teacherQuizSnapshot) {
          if (teacherQuizSnapshot.docs.isNotEmpty) {
            setState(() {
              selectedQuiz = teacherQuizSnapshot.docs.first.id;
            });
          }
        });
      }
    });
  }

  // Function to assign the selected story and quiz to the selected students
  void assignQuizToStudents() {
    if (selectedStory == null || selectedQuiz == null || selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a story, quiz, and students to assign.'),
        ),
      );
      return;
    }

    for (var studentId in selectedStudents) {
      FirebaseFirestore.instance.collection('AssignedQuizzes').add({
        'studentId': studentId,
        'storyId': selectedStory,
        'quizId': selectedQuiz,
        'teacherId': widget.teacherId,
        'assignedAt': Timestamp.now(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assigned quiz to selected students.'),
      ),
    );

    Navigator.of(context).pop();
  }

  // Fetch both default Stories and TeacherStories
  Widget _buildStoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Stories')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var defaultStories = snapshot.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Teachers')
              .doc(widget.teacherId)
              .collection('TeacherStories')
              .snapshots(),
          builder: (context, teacherSnapshot) {
            if (!teacherSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var teacherStories = teacherSnapshot.data!.docs;

            // Combine default and teacher-specific stories
            var combinedStories = [...defaultStories, ...teacherStories];

            return _buildDropdown(
              label: 'Select Story',
              value: selectedStory,
              items: combinedStories
                  .map((story) {
                    // Safely access the 'title' field, provide a fallback if it doesn't exist
                    Map<String, dynamic>? storyData = story.data() as Map<String, dynamic>?;
                    String storyTitle = storyData != null && storyData.containsKey('title') && storyData['title'] != null
                        ? storyData['title']
                        : 'Untitled'; // Fallback title if the field does not exist or is null
                    
                    return DropdownMenuItem<String>(
                      value: story.id,
                      child: Text(storyTitle, style: const TextStyle(color: Colors.black)),
                    );
                  })
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStory = value;
                  selectedQuiz = null; // Reset quiz selection
                  fetchAssociatedQuiz(value);
                });
              },
            );
          },
        );
      },
    );
  }
}
