import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/teacher/assessment_page.dart';
import '../Screens/edit_quiz_screen.dart';
import '../widgets/background.dart';

class AssessmentQuizzesPage extends StatefulWidget {
  final String teacherId;

  const AssessmentQuizzesPage({super.key, required this.teacherId});

  @override
  _AssessmentQuizzesPageState createState() => _AssessmentQuizzesPageState();
}

class _AssessmentQuizzesPageState extends State<AssessmentQuizzesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color passagesColor = Colors.white;
  Color quizzesColor = Colors.yellow;

  String? selectedSet;
  String? selectedGradeLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Custom tab as default
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF15A323),
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssessmentPage(teacherId: widget.teacherId),
                      ),
                    );
                  },
                  child: Text(
                    'Passages',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: passagesColor,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Quizzes',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: quizzesColor,
                    ),
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pretest'),
                Tab(text: 'Custom'),
                Tab(text: 'Posttest'),
              ],
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuizListView('pretest'),
                    _buildQuizListView('custom'),
                    _buildQuizListView('posttest'),
                  ],
                ),
              ),
              // Removed bottom section for add and assign buttons
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownButton<String>(
            value: selectedSet,
            hint: const Text('Select Set'),
            items: ['A', 'B', 'C', 'D'].map((set) {
              return DropdownMenuItem(
                value: set,
                child: Text(set),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSet = value;
              });
            },
          ),
          DropdownButton<String>(
            value: selectedGradeLevel,
            hint: const Text('Select Grade Level'),
            items: ['Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6'].map((grade) {
              return DropdownMenuItem(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGradeLevel = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedSet = null;
                selectedGradeLevel = null;
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizListView(String quizType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Quizzes')
          .where('teacherId', isEqualTo: widget.teacherId)
          .where('type', isEqualTo: quizType) // Filter quizzes by type
          .orderBy('gradeLevel')
          .orderBy('set')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var quizzes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            var quiz = quizzes[index];
            var data = quiz.data() as Map<String, dynamic>?;
            var title = data != null && data.containsKey('title') ? data['title'] : 'No Title';
            var gradeLevel = data != null && data.containsKey('gradeLevel') ? data['gradeLevel'] : 'N/A';
            var set = data != null && data.containsKey('set') ? data['set'] : 'N/A';

            return ListTile(
              title: Text(
                '$title',
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text('Grade Level: $gradeLevel,  Set: $set'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditQuizScreen(quizId: quiz.id, teacherId: widget.teacherId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
