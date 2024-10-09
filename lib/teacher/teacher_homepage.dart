import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reading_comprehension/teacher/student_list_page.dart';
import 'package:reading_comprehension/teacher/teacher_drawer.dart';
import 'package:reading_comprehension/teacher/assessment_page.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherHomePage extends StatefulWidget {
  final String teacherId;

  const TeacherHomePage({super.key, required this.teacherId});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _backButtonCount = 0;
  late String teacherId;
  String? teacherCode;

  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    _fetchTeacherCode();
    _checkShowInstructionOverlay();
  }

  Future<void> _fetchTeacherCode() async {
    try {
      DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        setState(() {
          teacherCode = teacherDoc['teacherCode'];
        });
      } else {
        setState(() {
          teacherCode = 'No code found';
        });
      }
    } catch (e) {
      setState(() {
        teacherCode = 'Error fetching code';
      });
    }
  }

  Future<void> _checkShowInstructionOverlay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
    });
  }

  Future<void> _setShowInstructionOverlay(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showInstructionOverlay', value);
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_backButtonCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Press back again to log out'),
          ));
          setState(() {
            _backButtonCount++;
          });
          return false;
        } else {
          await _confirmLogout();
          return false;
        }
      },
      child: Background(
        child: Scaffold(
           appBar: AppBar(
            backgroundColor: const Color(0xFF15A323),
            elevation: 4,  
            centerTitle: true,
            title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,  
            child: Image.asset(
            "assets/images/appbar.png",  
            fit: BoxFit.contain,  
              ),
            ),
              ],
           ),
              actions: [
              IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {

            },
           tooltip: 'Settings',
            ),
             ],
),


          drawer: TeacherDrawer(teacherId: teacherId),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Teacher Code: ${teacherCode ?? 'No code generated'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentPage(teacherId: teacherId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15A323),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Assessment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentListPage(teacherId: teacherId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15A323),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Student List',
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
            ],
          ),
        ),
      ),
    );
  }
}
