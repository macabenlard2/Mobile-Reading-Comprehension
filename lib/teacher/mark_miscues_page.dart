import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart'; // Import Background widget

class MarkMiscuesPage extends StatefulWidget {
  final String studentId;
  final String passageId;

  const MarkMiscuesPage({super.key, required this.studentId, required this.passageId});

  @override
  _MarkMiscuesPageState createState() => _MarkMiscuesPageState();
}

class _MarkMiscuesPageState extends State<MarkMiscuesPage> {
  int totalMiscueScore = 0; // To track the total miscues score

  @override
  void initState() {
    super.initState();
    // No need to load passage content anymore
  }

  void _incrementMiscueScore(String miscueType) {
    setState(() {
      totalMiscueScore++; // Increase total score for each miscue
    });
  }

  void _decrementMiscueScore(String miscueType) {
    setState(() {
      if (totalMiscueScore > 0) {
        totalMiscueScore--; // Decrease total score, but it shouldn't go below zero
      }
    });
  }

  void _saveMiscueScore() async {
    // Save the total miscues score to Firestore
    await FirebaseFirestore.instance.collection('MiscueScores').add({
      'studentId': widget.studentId,
      'passageId': widget.passageId,
      'miscueScore': totalMiscueScore,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Miscue score saved successfully')));
    Navigator.pop(context); // Return to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Miscues'),
        backgroundColor: const Color(0xFF15A323),
      ),
      body: Background(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Display the total miscue score
            Text(
              'Total Miscue Score: $totalMiscueScore',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Buttons to increment/decrement score based on miscues
            _buildMiscueRow('Mispronunciation'),
            _buildMiscueRow('Omission'),
            _buildMiscueRow('Substitution'),
            _buildMiscueRow('Insertion'),
            _buildMiscueRow('Repetition'),
            _buildMiscueRow('Transposition'),
            _buildMiscueRow('Reversal'),
            // Add more miscue types as needed
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF15A323),
        onPressed: _saveMiscueScore,
        child: const Icon(Icons.save),
      ),
    );
  }

  // Helper to build the buttons for each miscue type with increment and decrement
  Widget _buildMiscueRow(String miscueType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(miscueType, style: const TextStyle(fontSize: 18)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.red),
                onPressed: () => _decrementMiscueScore(miscueType),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () => _incrementMiscueScore(miscueType),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
