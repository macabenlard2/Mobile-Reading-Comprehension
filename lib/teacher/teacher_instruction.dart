import 'package:flutter/material.dart';
import 'package:reading_comprehension/widgets/background_reading.dart'; // Import your Background widget

class TeacherInstructionPage extends StatelessWidget {
  const TeacherInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold background transparent
        appBar: AppBar(
          title: const Text('Teacher Instructions'),
          backgroundColor: Colors.transparent, // Transparent AppBar to show the background
          elevation: 0, // Remove shadow under the AppBar
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
         
              Text(
                'Here\'s how you can use the app:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '1. Home Page:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '   - The Home Page gives you quick access to the most important features of the app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '2. Assessment:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '   - Tap the "Assessment" button to create, view, and manage assessments. You can add new assessments, edit existing ones, or delete those that are no longer needed.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '3. Student List:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '   - Tap the "Student List" button to view and manage the list of students. , And view detailed information about each student.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '4. Navigation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '   - Use the navigation drawer to access other features like settings, help, and more.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '5. Logout:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '   - To log out, press the back button twice or use the logout option in the navigation drawer. You will be asked to confirm your decision.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Feel free to explore the app and discover all its features!',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Happy Teaching!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
