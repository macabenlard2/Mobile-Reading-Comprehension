import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/teacher/story_detail_page.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:reading_comprehension/screens/create_story_page.dart';
import 'assessment_quizzes.dart';
import 'package:reading_comprehension/widgets/assign_story_quiz_page.dart';

class AssessmentPage extends StatefulWidget {
  final String teacherId;

  const AssessmentPage({super.key, required this.teacherId});

  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color passagesColor = Colors.yellow;
  Color quizzesColor = Colors.white;

  String? selectedSet;
  String? selectedGradeLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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
                _buildNavigationTab(
                  label: 'Passages',
                  color: passagesColor,
                  onTap: () {},
                ),
                _buildVerticalDivider(),
                _buildNavigationTab(
                  label: 'Quizzes',
                  color: quizzesColor,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssessmentQuizzesPage(teacherId: widget.teacherId),
                      ),
                    );
                  },
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
                    _buildStoryListView('pretest'),
                    _buildStoryListView('custom'),
                    _buildStoryListView('posttest'),
                  ],
                ),
              ),
              _buildBottomSection(), // Added bottom section for add and assign buttons
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTab({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 2,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
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

  Widget _buildStoryListView(String testType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Stories')
          .where('teacherId', isEqualTo: widget.teacherId)
          .where('type', isEqualTo: testType)
          .where('set', isEqualTo: selectedSet)
          .where('gradeLevel', isEqualTo: selectedGradeLevel)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data found'),
          );
        }

        var stories = snapshot.data!.docs;

        return ListView.builder(
          itemCount: stories.length,
          itemBuilder: (context, index) {
            var data = stories[index].data() as Map<String, dynamic>;
            var title = data['title'] ?? 'Untitled';
            var gradeLevel = data['gradeLevel'] ?? 'N/A';
            var set = data['set'] ?? 'N/A';

            return ListTile(
              title: Text(
                '$title',
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text('Grade Level: $gradeLevel, Set: $set'),
              onTap: () {
                _navigateToStoryDetail(title);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateStoryPage(teacherId: widget.teacherId),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Passage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16), // Space between the two buttons
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to the AssignStoryQuizPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignStoryQuizPage(teacherId: widget.teacherId),
                  ),
                );
              },
              icon: const Icon(Icons.assignment),
              label: const Text('Assign Passage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStoryDetail(String title) {
    FirebaseFirestore.instance
        .collection('Stories')
        .where('title', isEqualTo: title)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailPage(
              docId: doc.id,
              title: doc['title'],
              content: doc['content'],
            ),
          ),
        );
      }
    });
  }
}
