import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:reading_comprehension/main.dart';
import 'package:reading_comprehension/teacher/student_list_page.dart';
import 'package:reading_comprehension/widgets/reading_profile_dynamic_table.dart';
import 'teacher_drawer.dart';
import 'package:reading_comprehension/widgets/gender_pie_chart.dart';
import 'package:reading_comprehension/widgets/grade_bar_chart.dart';
import "package:reading_comprehension/teacher/assessment_tab_page.dart";
import "package:reading_comprehension/widgets/miscue_bar_chart.dart";

class TeacherHomePage extends StatefulWidget {
  final String teacherId;

  const TeacherHomePage({super.key, required this.teacherId});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  String firstName = '';
  String lastName = '';
  String teacherCode = '';
  int studentCount = 0;
  int _currentIndex = 1;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _verifyTeacherId();
  }

  Future<void> _verifyTeacherId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    if (currentUser.uid != widget.teacherId) return;
    _fetchTeacherData();
    _fetchStudentCount();
  }

  Future<void> _fetchTeacherData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(widget.teacherId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstName = data['firstname'] ?? '';
          lastName = data['lastname'] ?? '';
          teacherCode = data['teacherCode'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching teacher data: $e');
    }
  }

 Future<void> _fetchStudentCount() async {
  try {
    // Get active school year first
    final schoolYearDoc = await FirebaseFirestore.instance
        .collection('Settings')
        .doc('SchoolYear')
        .get();
    
    final activeSchoolYear = schoolYearDoc.data()?['active']?.toString() ?? '';

    if (activeSchoolYear.isEmpty) {
      setState(() => studentCount = 0);
      return;
    }

    // Count students ONLY for the active school year
    final query = await FirebaseFirestore.instance
        .collection('Students')
        .where('teacherId', isEqualTo: widget.teacherId)
        .where('schoolYear', isEqualTo: activeSchoolYear)
        .get();

    setState(() => studentCount = query.docs.length);
  } catch (e) {
    debugPrint('Error fetching student count: $e');
    setState(() => studentCount = 0);
  }
}

  /// 🔁 Real-time active school year stream
  Stream<String> get schoolYearStream async* {
    yield* FirebaseFirestore.instance
        .collection('Settings')
        .doc('SchoolYear')
        .snapshots()
        .map((snapshot) => snapshot.data()?['active']?.toString() ?? '');
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Press BACK again to log out."),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Do you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return false;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MyHomePage()),
        (_) => false,
      );
    }
    return false;
  }

Widget _buildHomePageWithSchoolYear(String activeSchoolYear) {
  final today = DateFormat('MMMM dd, yyyy').format(DateTime.now());

  return Stack(
    children: [
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 320,
              height: 320,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),

            Text(
              "Hello Teacher $firstName $lastName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              "Today is $today.",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            /// ✅ Real-time School Year Display
            Text(
              "Active School Year: $activeSchoolYear",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),

            const SizedBox(height: 20),
            // Replace the static student count with a StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Students')
                  .where('teacherId', isEqualTo: widget.teacherId)
                  .where('schoolYear', isEqualTo: activeSchoolYear)
                  .snapshots(),
              builder: (context, snapshot) {
                final studentCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Text(
                  "You currently have $studentCount student(s) enrolled in SY: $activeSchoolYear",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 20),

            Text(
              "Class Code: $teacherCode",
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueAccent
              ),
            ),
            const SizedBox(height: 70),

            GenderPieChart(teacherId: widget.teacherId),
            const SizedBox(height: 70),
            GradeBarChart(isTeacher: true, teacherId: widget.teacherId),
            MiscueBarChart(teacherId: widget.teacherId),
            ReadingProfileGlassTable(teacherId: widget.teacherId, type: "pretest"),
            const SizedBox(height: 32),
            ReadingProfileGlassTable(teacherId: widget.teacherId, type: "posttest"),
          ],
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: _onWillPop,
    child: Scaffold(
      appBar: _currentIndex == 1
          ? AppBar(
              backgroundColor: const Color(0xFF15A323),
              title: const Text('Teacher Home',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      drawer: _currentIndex == 1 ? TeacherDrawer(teacherId: widget.teacherId) : null,
      body: _currentIndex == 1
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Settings')
                  .doc('SchoolYear')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final activeSchoolYear = snapshot.data?.data() != null
                    ? (snapshot.data!.data() as Map<String, dynamic>)['active'] ?? ''
                    : '';

                return _buildHomePageWithSchoolYear(activeSchoolYear);
              },
            )
          : _currentIndex == 0
              ? AssessmentTabPage(teacherId: widget.teacherId)
              : StudentListPage(teacherId: widget.teacherId),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Assessments'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Students'),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    ),
  );
}


    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _currentIndex == 1
            ? AppBar(
                backgroundColor: const Color(0xFF15A323),
                title: const Text('Teacher Home',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                centerTitle: true,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              )
            : null,
        drawer: _currentIndex == 1 ? TeacherDrawer(teacherId: widget.teacherId) : null,
        body: _currentIndex == 1
            ? StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Settings')
                    .doc('SchoolYear')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final activeSchoolYear = snapshot.data?.data() != null
                      ? (snapshot.data!.data() as Map<String, dynamic>)['active'] ?? ''
                      : '';

                  return _buildHomePageWithSchoolYear(activeSchoolYear);
                },
              )
            : _currentIndex == 0
                ? AssessmentTabPage(teacherId: widget.teacherId)
                : StudentListPage(teacherId: widget.teacherId),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Assessments'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Students'),
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
