import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:reading_comprehension/Screens/splash_screen.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  _TeacherProfilePageState createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  String firstName = '';
  String lastName = '';
  String? profileImageUrl;
  String teacherCode = '';
  String email = '';

  bool isLoading = true;
  bool showCameraIcon = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
    
  }

  void _showEditNameDialog() {
  final TextEditingController firstNameController = TextEditingController(text: firstName);
  final TextEditingController lastNameController = TextEditingController(text: lastName);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Edit Name',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15A323)),
          onPressed: () async {
            final newFirst = firstNameController.text.trim();
            final newLast = lastNameController.text.trim();

            if (newFirst.isNotEmpty && newLast.isNotEmpty) {
              final uid = FirebaseAuth.instance.currentUser!.uid;

              await FirebaseFirestore.instance
                  .collection('Teachers')
                  .doc(uid)
                  .update({
                'firstname': newFirst,
                'lastname': newLast,
              });

              setState(() {
                firstName = newFirst;
                lastName = newLast;
              });

              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}


Future<void> _fetchTeacherData() async {
  String teacherId = FirebaseAuth.instance.currentUser!.uid;

  try {
    // Fetch from Teachers collection
    DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
        .collection('Teachers')
        .doc(teacherId)
        .get();

    // Fetch from Users collection (for email)
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(teacherId)
        .get();

    if (teacherDoc.exists) {
      var teacherData = teacherDoc.data() as Map<String, dynamic>;
      var userData = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        firstName = teacherData['firstname'] ?? '';
        lastName = teacherData['lastname'] ?? '';
        profileImageUrl = teacherData['profilePictureUrl'];
        teacherCode = teacherData['teacherCode'] ?? 'N/A';
        email = userData?['email'] ?? 'No email'; // ✅ Corrected source
        isLoading = false;
      });
    }
  } catch (e) {
    print('❌ Error fetching teacher data: $e');
    setState(() => isLoading = false);
  }
}


  Future<void> _uploadProfilePicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String teacherId = FirebaseAuth.instance.currentUser!.uid;
        String fileName = '$teacherId.jpg';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('teacher_profile_pictures/$fileName')
            .putFile(file);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Teachers')
            .doc(teacherId)
            .update({'profilePictureUrl': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
          showCameraIcon = false;
        });
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/background.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showCameraIcon = !showCameraIcon;
                                      });
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: profileImageUrl != null
                                              ? NetworkImage(profileImageUrl!)
                                              : const AssetImage("assets/images/default_profile.png") as ImageProvider,
                                        ),
                                        if (showCameraIcon)
                                          Positioned(
                                            bottom: 0,
                                            child: GestureDetector(
                                              onTap: _uploadProfilePicture,
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                "$firstName $lastName",
                                                style: const TextStyle(
                                                  fontSize: 23,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                minFontSize: 16,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.white),
                                              onPressed: _showEditNameDialog,
                                              tooltip: 'Edit Name',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Teacher",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Teacher Code",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      teacherCode,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Email Address",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
        ],
      ),
    ),
    const SizedBox(height: 20), // Extra space to avoid bottom overflow
  
    
  ],
),
                        ),
                      ),

              ],
            ),
    );
  }
}
