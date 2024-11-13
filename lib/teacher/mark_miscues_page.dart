import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';

// Mark Miscues Page
class MarkMiscuesPage extends StatefulWidget {
  final String studentId;

  const MarkMiscuesPage({super.key, required this.studentId,});

  @override
  _MarkMiscuesPageState createState() => _MarkMiscuesPageState();
}

class _MarkMiscuesPageState extends State<MarkMiscuesPage> {
  int totalMiscueScore = 0;
  Map<String, int> miscues = {
    'Mispronunciation': 0,
    'Omission': 0,
    'Substitution': 0,
    'Insertion': 0,
    'Repetition': 0,
    'Transposition': 0,
    'Reversal': 0,
  };

  void _incrementMiscueScore(String miscueType) {
    setState(() {
      miscues[miscueType] = (miscues[miscueType] ?? 0) + 1;
      totalMiscueScore++;
    });
  }

  void _decrementMiscueScore(String miscueType) {
    setState(() {
      if (miscues[miscueType]! > 0) {
        miscues[miscueType] = miscues[miscueType]! - 1;
        totalMiscueScore--;
      }
    });
  }

  void _saveMiscueScore() async {
    final docId = '${widget.studentId}_}';

    await FirebaseFirestore.instance.collection('MiscueRecords').doc(docId).set({
      'studentId': widget.studentId,
      'miscues': miscues,
      'totalMiscueScore': totalMiscueScore,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Miscue record saved successfully')),
    );
    Navigator.pop(context);
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
            Text(
              'Total Miscue Score: $totalMiscueScore',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            for (String miscueType in miscues.keys) _buildMiscueRow(miscueType),
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

  Widget _buildMiscueRow(String miscueType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$miscueType: ${miscues[miscueType]}', style: const TextStyle(fontSize: 18)),
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