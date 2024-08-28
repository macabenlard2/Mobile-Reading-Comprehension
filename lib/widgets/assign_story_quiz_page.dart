import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

class AssignStoryQuizPage extends StatefulWidget {
  final String teacherId;

  const AssignStoryQuizPage({super.key, required this.teacherId});

  @override
  // ignore: library_private_types_in_public_api
  _AssignStoryQuizPageState createState() => _AssignStoryQuizPageState();
}

class _AssignStoryQuizPageState extends State<AssignStoryQuizPage> {
  String? selectedStudent;
  String? selectedStory;
  String? selectedQuiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Passage',
          style: TextStyle(
            color: Colors.white,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Students').where('teacherId', isEqualTo: widget.teacherId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    var students = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedStudent,
                      hint: const Text('Select Student'),
                      onChanged: (value) {
                        setState(() {
                          selectedStudent = value;
                        });
                      },
                      items: students.map((student) {
                        String name = (student['firstName'] ?? 'No Firstname') + ' ' + (student['lastName'] ?? 'No Lastname');
                        return DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(name),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Stories').where('teacherId', isEqualTo: widget.teacherId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    var stories = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedStory,
                      hint: const Text('Select Story'),
                      onChanged: (value) {
                        setState(() {
                          selectedStory = value;
                        });
                      },
                      items: stories.map((story) {
                        return DropdownMenuItem<String>(
                          value: story.id,
                          child: Text(story['title'] ?? 'No Title'),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Quizzes').where('teacherId', isEqualTo: widget.teacherId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    var quizzes = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedQuiz,
                      hint: const Text('Select Quiz'),
                      onChanged: (value) {
                        setState(() {
                          selectedQuiz = value;
                        });
                      },
                      items: quizzes.map((quiz) {
                        return DropdownMenuItem<String>(
                          value: quiz.id,
                          child: Text(quiz['title'] ?? 'No Title'),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStudent != null && selectedStory != null && selectedQuiz != null) {
                      FirebaseFirestore.instance.collection('AssignedQuizzes').add({
                        'studentId': selectedStudent,
                        'storyId': selectedStory,
                        'quizId': selectedQuiz,
                        'teacherId': widget.teacherId,
                      }).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Story and Quiz Assigned Successfully')),
                        );
                        Navigator.pop(context);
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to assign: $error')),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15A323),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Assign', style: TextStyle(
                    color: Colors.black,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
