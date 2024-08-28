import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile_page.dart'; // Import the profile page

class StudentDrawer extends StatefulWidget {
  final String studentId;

  const StudentDrawer({super.key, required this.studentId});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  String firstName = '';
  String lastName = '';
  String profilePictureUrl = '';
  bool isLoading = true;
  bool showCameraIcon = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      print('Fetching data for studentId: ${widget.studentId}');
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(widget.studentId)
          .get();

      if (studentDoc.exists) {
        print('Student document exists');
        setState(() {
          firstName = studentDoc['firstName'];
          lastName = studentDoc['lastName'];
          profilePictureUrl = studentDoc['profilePictureUrl'] ?? '';
          isLoading = false;
        });
        print('Fetched data: First Name: $firstName, Last Name: $lastName, Profile Picture URL: $profilePictureUrl');
      } else {
        print('Student document does not exist');
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

  Future<void> _uploadProfilePicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String fileName = '${widget.studentId}.jpg';
        UploadTask uploadTask = FirebaseStorage.instance.ref().child('profile_pictures/$fileName').putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        
        await FirebaseFirestore.instance.collection('Students').doc(widget.studentId).update({'profilePictureUrl': downloadUrl});
        
        setState(() {
          profilePictureUrl = downloadUrl;
          showCameraIcon = false;
        });
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building drawer with First Name: $firstName, Last Name: $lastName, Profile Picture URL: $profilePictureUrl');
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF15A323),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                maxRadius: 50,
                                backgroundImage: profilePictureUrl.isNotEmpty
                                    ? NetworkImage(profilePictureUrl)
                                    : const AssetImage("assets/images/default_profile.png") as ImageProvider,
                              ),
                              if (showCameraIcon)
                                Positioned(
                                  bottom: 0, // Adjust the position here
                                  child: GestureDetector(
                                    onTap: _uploadProfilePicture,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, color: Colors.white, size: 30),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Student",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_filled, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text("Home", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text("Profile", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(studentId: widget.studentId),
                ),
              );
            },
          ),
          const SizedBox(
            height: 170,
          ),
          const Divider(thickness: 1, color: Colors.black),
          ListTile(
            leading: const Icon(Icons.logout, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text("Log Out", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
