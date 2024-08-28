import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart'; // Import the Background widget

class ProfilePage extends StatefulWidget {
  final String studentId;

  const ProfilePage({super.key, required this.studentId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String profilePictureUrl = '';
  String gender = '';
  String grade = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(widget.studentId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          profilePictureUrl = data['profilePictureUrl'] ?? '';
          gender = data['gender'] ?? 'Not specified'; // Correct field name with space
          grade = data['gradeLevel'] ?? 'Not specified'; // Use 'gradeLevel' instead of 'grade'
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Background( // Use Background widget
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20), // Add some space at the top
                      CircleAvatar(
                        radius: 90, // Increased the radius for a larger picture
                        backgroundImage: profilePictureUrl.isNotEmpty
                            ? NetworkImage(profilePictureUrl)
                            : const AssetImage("assets/images/default_profile.png") as ImageProvider,
                      ),
                      const SizedBox(height: 30),
                      Text('Name: $firstName $lastName', style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text('Gender: $gender', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text('Grade: $grade', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
