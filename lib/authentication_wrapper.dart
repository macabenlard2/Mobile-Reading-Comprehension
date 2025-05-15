import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/Screens/login_page.dart';
import 'package:reading_comprehension/main.dart';
import 'package:reading_comprehension/teacher/teacher_homepage.dart';
import 'package:reading_comprehension/student/student_home_page.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define fade animation for the gradient
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50).withOpacity(_fadeAnimation.value),
                const Color(0xFFFFEB3B).withOpacity(_fadeAnimation.value),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
      child: user == null
          ? const MyHomePage()
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.expand(); // No extra loading indicator
                }

                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return const SignIn();
                }

                final role = snapshot.data!['role'];
                if (role == 'teacher') {
                  return TeacherHomePage(teacherId: user.uid);
                } else if (role == 'student') {
                  return StudentHomePage(studentId: user.uid);
                }

                return const SignIn();
              },
            ),
    );
  }
}
