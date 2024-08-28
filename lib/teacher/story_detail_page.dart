import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reading_comprehension/widgets/background_reading.dart';

class StoryDetailPage extends StatefulWidget {
  final String docId;

  const StoryDetailPage({
    super.key,
    required this.docId,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

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
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> updateStoryAndQuizTitle() async {
    setState(() {
      isLoading = true; // Show loading animation
    });

    try {
      if (widget.docId.isNotEmpty) {
        // Update the story title and content
        await FirebaseFirestore.instance.collection('Stories').doc(widget.docId).update({
          'title': titleController.text,
          'content': contentController.text,
        });

        // Update the associated quiz title
        var quizSnapshot = await FirebaseFirestore.instance
            .collection('Quizzes')
            .where('storyId', isEqualTo: widget.docId)
            .get();

        for (var doc in quizSnapshot.docs) {
          await doc.reference.update({
            'title': titleController.text,
          });
        }

        setState(() {
          isEditing = false;
          isLoading = false; // Hide loading animation after update
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story and quiz titles updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document ID is empty')),
        );
        setState(() {
          isLoading = false; // Hide loading animation on failure
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update story and quiz titles: $e')),
      );
      setState(() {
        isLoading = false; // Hide loading animation on failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          
          'Story Details', style: TextStyle(
           color: Colors.white,
           fontSize: 20,
           fontWeight: FontWeight.bold,
          ),
         
        
        
        
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF15A323), // Green color for the AppBar
        automaticallyImplyLeading: true,
         leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),



        ),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white,),
            onPressed: deleteStory,
          ),
        ],
      ),
      body: Background(
        child: Stack(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Stories')
                  .doc(widget.docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Deleting Process'));
                }

                var storyData = snapshot.data!;
                titleController.text = storyData['title'] ?? '';
                contentController.text = storyData['content'] ?? '';

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
                    color: Colors.green, // Green color for the loading animation
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
        isLoading = true; // Show loading animation
      });

      try {
        if (widget.docId.isNotEmpty) {
          // Delete the story
          await FirebaseFirestore.instance.collection('Stories').doc(widget.docId).delete();
          
          // Delete the associated quiz
          var quizSnapshot = await FirebaseFirestore.instance
              .collection('Quizzes')
              .where('storyId', isEqualTo: widget.docId)
              .get();

          for (var doc in quizSnapshot.docs) {
            await doc.reference.delete();
          }

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
          isLoading = false; // Hide loading animation after deletion
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
}
