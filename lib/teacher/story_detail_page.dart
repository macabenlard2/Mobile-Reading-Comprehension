import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background_reading.dart';

class StoryDetailPage extends StatefulWidget {
  final String docId;
  final String title;
  final String content;
  final bool isTeacherStory;
  final String? teacherId;

  const StoryDetailPage({
    super.key,
    required this.docId,
    required this.title,
    required this.content,
    required this.isTeacherStory,
    this.teacherId,
  });

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);

    // Debugging teacherId
    if (widget.teacherId == null || widget.teacherId!.isEmpty) {
      print("Error: Teacher ID is missing for a teacher story!");
    } else {
      print("Teacher ID: ${widget.teacherId}");
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Story Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF15A323),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: deleteStory,
          ),
        ],
      ),
      body: Background(
        child: Stack(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(widget.isTeacherStory && widget.teacherId != null && widget.teacherId!.isNotEmpty
                      ? 'Teachers/${widget.teacherId}/TeacherStories'
                      : 'Stories')
                  .doc(widget.docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (widget.isTeacherStory && (widget.teacherId == null || widget.teacherId!.isEmpty)) {
                  print("Error: Teacher ID is missing for a teacher story!");
                  return const Center(child: Text("Invalid teacher ID or story not found."));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  print("No data found for docId: ${widget.docId}");
                  return const Center(child: Text('Story not found or already deleted'));
                }

                var storyData = snapshot.data!;
                titleController.text = storyData['title'] ?? 'No Title';
                contentController.text = storyData['content'] ?? 'No Content';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    isEditing
                        ? TextFormField(
                            controller: titleController,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            storyData['title'] ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                            textAlign: TextAlign.center,
                          ),
                    const SizedBox(height: 20),
                    isEditing
                        ? TextFormField(
                            controller: contentController,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: null,
                          )
                        : Text(
                            storyData['content'] ?? 'No Content',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
                            textAlign: TextAlign.center,
                          ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (isEditing) {
                                updateStoryAndQuizTitle();
                              } else {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15A323),
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isEditing ? 'Update' : 'Edit',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

 Future<void> deleteStory() async {
  bool confirmed = await _showDeleteConfirmationDialog();

  if (confirmed) {
    setState(() {
      isLoading = true;
    });

    try {
      if (widget.docId.isNotEmpty) {
        // Determine collection path based on whether it is a teacher story or not
        String storyCollectionPath = widget.isTeacherStory && widget.teacherId != null && widget.teacherId!.isNotEmpty
            ? 'Teachers/${widget.teacherId}/TeacherStories'
            : 'Stories';

        // Delete the story from Firestore
        await FirebaseFirestore.instance.collection(storyCollectionPath).doc(widget.docId).delete();

        // Check for and delete the associated quiz
        String quizCollectionPath = widget.isTeacherStory && widget.teacherId != null && widget.teacherId!.isNotEmpty
            ? 'Teachers/${widget.teacherId}/TeacherQuizzes'
            : 'Quizzes';

        // Query the quiz based on the storyId and delete it
        var quizSnapshot = await FirebaseFirestore.instance
            .collection(quizCollectionPath)
            .where('storyId', isEqualTo: widget.docId)
            .get();

        for (var doc in quizSnapshot.docs) {
          await doc.reference.delete();
        }

        // After deleting both story and associated quiz
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story and associated quiz deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document ID is empty')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete story: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}


  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this story and its associated quiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void updateStoryAndQuizTitle() {
    // Logic to update the story and associated quiz title in Firestore
  }

  void _navigateToStoryDetail(String docId, String title, String content, bool isTeacherStory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailPage(
          docId: docId,
          title: title,
          content: content,
          isTeacherStory: isTeacherStory,
          teacherId: isTeacherStory ? widget.teacherId : null,
        ),
      ),
    );
  }
}
