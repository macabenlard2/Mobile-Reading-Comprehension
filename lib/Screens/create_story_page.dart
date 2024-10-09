import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

class CreateStoryPage extends StatefulWidget {
  final String teacherId;

  const CreateStoryPage({super.key, required this.teacherId});

  @override
  _CreateStoryPageState createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = 'custom'; // Default to custom, but can be changed
  String _selectedSet = 'A'; // Default set
  String _selectedGradeLevel = '2'; // Default grade level

  Future<void> _addStoryAndQuiz() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    try {
      // Log to see if the function is called
      print('Adding story...');

      // Add the story to the teacher-specific subcollection
      DocumentReference storyRef = await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(widget.teacherId)
          .collection('TeacherStories') // Collection for individual teacher stories
          .add({
        'title': _titleController.text,
        'content': _contentController.text,
        'teacherId': widget.teacherId,
        'type': _selectedType, // Ensure the type is saved correctly
        'set': _selectedSet, // Set the selected set
        'gradeLevel': _selectedGradeLevel, // Set the selected grade level
        'createdAt': Timestamp.now(),
      });

      print('Story added with ID: ${storyRef.id}');

      // Automatically create a corresponding quiz for the story in the teacher-specific subcollection
      await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(widget.teacherId)
          .collection('TeacherQuizzes') // Collection for individual teacher quizzes
          .add({
        'title': _titleController.text,
        'storyId': storyRef.id,
        'teacherId': widget.teacherId,
        'type': _selectedType, // Match the quiz type to the story type
        'set': _selectedSet, // Set the selected set for quiz
        'gradeLevel': _selectedGradeLevel, // Set the selected grade level for quiz
        'questions': [], // Placeholder for questions
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story and corresponding quiz added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add story and quiz: $e')),
      );
      print('Error adding story: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Story & Quiz',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'pretest', child: Text('Pretest')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                    DropdownMenuItem(value: 'posttest', child: Text('Posttest')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Story Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedSet,
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('Set A')),
                    DropdownMenuItem(value: 'B', child: Text('Set B')),
                    DropdownMenuItem(value: 'C', child: Text('Set C')),
                    DropdownMenuItem(value: 'D', child: Text('Set D')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSet = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Set',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGradeLevel,
                  items: const [
                    DropdownMenuItem(value: '2', child: Text('Grade 2')),
                    DropdownMenuItem(value: '3', child: Text('Grade 3')),
                    DropdownMenuItem(value: '4', child: Text('Grade 4')),
                    DropdownMenuItem(value: '5', child: Text('Grade 5')),
                    DropdownMenuItem(value: '6', child: Text('Grade 6')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGradeLevel = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Grade Level',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  maxLines: 8,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addStoryAndQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15A323),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add Story & Quiz',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
