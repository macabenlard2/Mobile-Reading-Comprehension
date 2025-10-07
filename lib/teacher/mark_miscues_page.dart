import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:reading_comprehension/utils/school_year_util.dart';

class MarkMiscuesPage extends StatefulWidget {
  final String studentId;
  final String type;
  final String performanceId;
  final String storyId;
  final bool isReadingInProgress;

  const MarkMiscuesPage({
    super.key, 
    required this.studentId, 
    required this.type, 
    required this.performanceId,
    required this.storyId,
    required this.isReadingInProgress, required teacherId,
  });

  @override
  _MarkMiscuesPageState createState() => _MarkMiscuesPageState();
}

class _MarkMiscuesPageState extends State<MarkMiscuesPage> {
  int totalMiscueScore = 0;
  String selectedType = "pretest";
  bool isLoading = true;
  bool _isSaving = false;
  int _passageWordCount = 0;
  bool _isReadingInProgress = true; // Track reading status locally
  StreamSubscription<DocumentSnapshot>? _performanceSubscription;

  Map<String, int> miscues = {
    'Mispronunciation': 0,
    'Omission': 0,
    'Substitution': 0,
    'Insertion': 0,
    'Repetition': 0,
    'Transposition': 0,
    'Reversal': 0,
  };

  @override
  void initState() {
    super.initState();
    _isReadingInProgress = widget.isReadingInProgress;
    _determineMiscueType();
    _setupPerformanceListener();
  }

  @override
  void dispose() {
    _performanceSubscription?.cancel();
    super.dispose();
  }

  void _setupPerformanceListener() {
    _performanceSubscription = FirebaseFirestore.instance
        .collection('StudentPerformance')
        .doc(widget.performanceId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final doneReading = data?['doneReading'] ?? false;
        
        if (mounted) {
          setState(() {
            _isReadingInProgress = !doneReading;
          });
        }
      }
    });
  }

  Future<void> _determineMiscueType() async {
    try {
      final performanceDoc = await FirebaseFirestore.instance
          .collection('StudentPerformance')
          .doc(widget.performanceId) 
          .get();

      if (!performanceDoc.exists) {
        debugPrint("❌ Error: No StudentPerformance record found for ID ${widget.performanceId}");
        return;
      }

      var performanceData = performanceDoc.data();
      if (performanceData == null) {
        debugPrint("❌ Error: Performance data is null");
        return;
      }

      String latestTestType = performanceData['type']?.toString().toLowerCase() ?? "pretest";

      // Get passage word count from performance or story
      _passageWordCount = performanceData['passageWordCount'] ?? 0;
      
      // If not available in performance, get from story
      if (_passageWordCount == 0) {
        final storyDoc = await FirebaseFirestore.instance
            .collection('Stories')
            .doc(widget.storyId)
            .get();
            
        if (storyDoc.exists) {
          _passageWordCount = storyDoc.data()?['wordCount'] ?? 0;
        }
      }

      setState(() {
        selectedType = latestTestType;
        miscues = {
          'Mispronunciation': 0,
          'Omission': 0,
          'Substitution': 0,
          'Insertion': 0,
          'Repetition': 0,
          'Transposition': 0,
          'Reversal': 0,
        };
        totalMiscueScore = 0;
      });

      debugPrint('✅ Marking Miscues for Type: $selectedType (RESET to 0)');
    } catch (e) {
      debugPrint('❌ Error determining miscue type: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMiscueRecords() async {
    try {
      final schoolYear = await getCurrentSchoolYear();
      final querySnapshot = await FirebaseFirestore.instance
          .collection('MiscueRecords')
          .where('studentId', isEqualTo: widget.studentId)
          .where('type', isEqualTo: selectedType)
          .where('schoolYear', isEqualTo: schoolYear)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final miscuesData = querySnapshot.docs.first.data();
        setState(() {
          miscues = Map<String, int>.from(miscuesData['miscues']);
          totalMiscueScore = miscuesData['totalMiscueScore'] ?? 0;
        });
      } else {
        debugPrint('No previous miscues found for $selectedType');
      }
    } catch (e) {
      debugPrint('❌ Error loading miscues: $e');
    }
  }

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

  Future<void> _saveMiscueScore() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing... Please wait'),
          duration: Duration(seconds: 2),
        ),
      );

      final performanceDoc = await FirebaseFirestore.instance
          .collection('StudentPerformance')
          .doc(widget.performanceId)
          .get();

      if (!performanceDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No performance record found.'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('⚠️ No performance record found for performanceId: ${widget.performanceId}');
        setState(() => _isSaving = false);
        return;
      }

      final performanceData = performanceDoc.data() as Map<String, dynamic>;
      final schoolYear = await getCurrentSchoolYear();

      // Calculate word reading score
      double wordReadingScore = ((_passageWordCount - totalMiscueScore) / _passageWordCount) * 100;

      // Save to Firestore
      await FirebaseFirestore.instance.collection('MiscueRecords').add({
        'studentId': widget.studentId,
        'type': selectedType,
        'performanceId': widget.performanceId,
        'miscues': miscues,
        'totalMiscueScore': totalMiscueScore,
        'wordReadingScore': wordReadingScore,
        'timestamp': Timestamp.now(),
        'schoolYear': schoolYear, 
      });

      // Update performance record with miscue data
      await FirebaseFirestore.instance
          .collection('StudentPerformance')
          .doc(widget.performanceId)
          .update({
            'miscueMarked': true,
            'miscueScore': totalMiscueScore,
            'wordReadingScore': wordReadingScore,
          });

      // If pretest is completed, mark it in Firestore
      if (selectedType == "pretest") {
        await FirebaseFirestore.instance
            .collection('StudentPerformance')
            .doc(widget.performanceId)
            .update({'pretestCompleted': true});
        debugPrint('✅ Pretest completed.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${selectedType == 'pretest' ? 'Pre-test' : 'Post-test'} miscues saved successfully! '
           
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to the student list
      Navigator.pop(context);

    } catch (e) {
      debugPrint('❌ Error saving miscues: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error saving record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Score Miscues - ${selectedType == 'pretest' ? 'Pre-test' : 'Post-test'}'),
        backgroundColor: const Color(0xFF15A323),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Background(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'Total Miscue Score: $totalMiscueScore',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isReadingInProgress ? 'Student is currently reading' : 'Student Finished Reading',
                        style: TextStyle(
                          color: _isReadingInProgress ? Colors.orange[700] : Colors.green[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...miscues.keys.map((miscueType) => _buildMiscueRow(miscueType)).toList(),
                  ],
                ),
              ),
            ),
          ),
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveMiscueScore,
        icon: _isSaving 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? 'Processing...' : 'Save Miscues',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15A323),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMiscueRow(String miscueType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(miscueType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red), 
                    onPressed: () => _decrementMiscueScore(miscueType)
                  ),
                  Text('${miscues[miscueType]}', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green), 
                    onPressed: () => _incrementMiscueScore(miscueType)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}