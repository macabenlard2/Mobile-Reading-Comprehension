import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_scaffold.dart';

class ManageContentPage extends StatefulWidget {
  const ManageContentPage({super.key});

  @override
  State<ManageContentPage> createState() => _ManageContentPageState();
}

class _ManageContentPageState extends State<ManageContentPage> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _gradeLevel = 'Grade 5';
  String _set = 'Set A';
  String _type = 'pretest';
  List<Map<String, dynamic>> _quizQuestions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> _sortDocuments(List<DocumentSnapshot> docs) {
    docs.sort((a, b) {
      final aTitle = (a.data() as Map<String, dynamic>)['title']?.toString() ?? '';
      final bTitle = (b.data() as Map<String, dynamic>)['title']?.toString() ?? '';
      return aTitle.compareTo(bTitle);
    });
    return docs;
  }

  void _showQuizEditDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List questions = data['questions'] ?? [];
    List<Map<String, dynamic>> editableQuestions = questions
        .map<Map<String, dynamic>>((q) => {
              'question': q['question'] ?? '',
              'answers': {
                'A': q['answers']['A'] ?? '',
                'B': q['answers']['B'] ?? '',
                'C': q['answers']['C'] ?? '',
                'D': q['answers']['D'] ?? ''
              },
              'correctAnswer': q['correctAnswer'] ?? 'A'
            })
        .toList();
    if (editableQuestions.isEmpty) {
      editableQuestions.add({
        'question': '',
        'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
        'correctAnswer': 'A'
      });
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Quiz: ${data['title'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: editableQuestions.length,
                    itemBuilder: (ctx, idx) {
                      var q = editableQuestions[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                initialValue: q['question'],
                                decoration: const InputDecoration(
                                  labelText: 'Question',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                ),
                                onChanged: (v) => q['question'] = v,
                              ),
                              const SizedBox(height: 12),
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: ['A', 'B', 'C', 'D'].map((ansKey) {
                                  return TextFormField(
                                    initialValue: q['answers'][ansKey] ?? '',
                                    decoration: InputDecoration(
                                      labelText: "Option $ansKey",
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 12),
                                    ),
                                    onChanged: (v) => q['answers'][ansKey] = v,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    "Correct:",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: q['correctAnswer'],
                                    items: ['A', 'B', 'C', 'D']
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ))
                                        .toList(),
                                    onChanged: (val) => 
                                        setState(() => q['correctAnswer'] = val!),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, 
                                        color: Colors.red),
                                    tooltip: 'Delete question',
                                    onPressed: editableQuestions.length > 1
                                        ? () {
                                            setState(() {
                                              editableQuestions.removeAt(idx);
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text("Add Question"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        editableQuestions.add({
                          'question': '',
                          'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
                          'correctAnswer': 'A'
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15A323),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Quizzes')
                    .doc(doc.id)
                    .update({
                  'questions': editableQuestions,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quiz updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryQuizDialog(BuildContext context, [DocumentSnapshot? doc]) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _gradeLevel = data['gradeLevel'] ?? 'Grade 5';
      _set = data['set'] ?? 'Set A';
      _type = data['type'] ?? 'pretest';
      _quizQuestions = [
        {
          'question': '',
          'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
          'correctAnswer': 'A'
        }
      ];
    } else {
      _titleController.clear();
      _contentController.clear();
      _gradeLevel = 'Grade 5';
      _set = 'Set A';
      _type = 'pretest';
      _quizQuestions = [
        {
          'question': '',
          'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
          'correctAnswer': 'A'
        }
      ];
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      doc == null ? 'Add Passage' : 'Edit Passage',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Content',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            minLines: 5,
                            maxLines: 10,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gradeLevel,
                                  items: ['Grade 3', 'Grade 4', 'Grade 5', 'Grade 6']
                                      .map((g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
                                          ))
                                      .toList(),
                                  onChanged: (val) => 
                                      setState(() => _gradeLevel = val!),
                                  decoration: const InputDecoration(
                                    labelText: 'Grade',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _set,
                                  items: ['Set A', 'Set B', 'Set C', 'Set D']
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ))
                                      .toList(),
                                  onChanged: (val) => 
                                      setState(() => _set = val!),
                                  decoration: const InputDecoration(
                                    labelText: 'Set',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _type,
                            items: ['pretest', 'post test']
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t[0].toUpperCase() + 
                                          t.substring(1)),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _type = val!),
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (doc == null) ...[
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              'Quiz Questions',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ..._quizQuestions.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final q = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue: q['question'],
                                        decoration: const InputDecoration(
                                          labelText: 'Question',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (v) => q['question'] = v,
                                        validator: (v) => 
                                            v!.isEmpty ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 12),
                                      GridView.count(
                                        shrinkWrap: true,
                                        crossAxisCount: 2,
                                        childAspectRatio: 3,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        children: ['A', 'B', 'C', 'D']
                                            .map((ansKey) {
                                          return TextFormField(
                                            initialValue: q['answers'][ansKey],
                                            decoration: InputDecoration(
                                              labelText: ansKey,
                                              border: const OutlineInputBorder(),
                                            ),
                                            onChanged: (v) => 
                                                q['answers'][ansKey] = v,
                                            validator: (v) => 
                                                v!.isEmpty ? 'Required' : null,
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text('Correct:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          DropdownButton<String>(
                                            value: q['correctAnswer'],
                                            items: ['A', 'B', 'C', 'D']
                                                .map((c) => DropdownMenuItem(
                                                      value: c,
                                                      child: Text(c),
                                                    ))
                                                .toList(),
                                            onChanged: (val) => setState(
                                                () => q['correctAnswer'] = val!),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.delete, 
                                                color: Colors.red),
                                            onPressed: _quizQuestions.length > 1
                                                ? () {
                                                    setState(() {
                                                      _quizQuestions.removeAt(idx);
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add Question'),
                              onPressed: () {
                                setState(() {
                                  _quizQuestions.add({
                                    'question': '',
                                    'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
                                    'correctAnswer': 'A'
                                  });
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15A323),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (doc == null) {
                                final storyDoc = await FirebaseFirestore.instance
                                    .collection('Stories')
                                    .add({
                                  'title': _titleController.text,
                                  'content': _contentController.text,
                                  'gradeLevel': _gradeLevel,
                                  'set': _set,
                                  'type': _type,
                                  'isDefault': false,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                                final quizDoc = await FirebaseFirestore.instance
                                    .collection('Quizzes')
                                    .add({
                                  'title': _titleController.text + " Quiz",
                                  'questions': _quizQuestions,
                                  'type': _type,
                                  'set': _set,
                                  'storyId': storyDoc.id,
                                  'gradeLevel': _gradeLevel,
                                  'isDefault': false,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                                await FirebaseFirestore.instance
                                    .collection('Stories')
                                    .doc(storyDoc.id)
                                    .update({
                                  'quizId': quizDoc.id,
                                });
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('Stories')
                                    .doc(doc.id)
                                    .update({
                                  'title': _titleController.text,
                                  'content': _contentController.text,
                                  'gradeLevel': _gradeLevel,
                                  'set': _set,
                                  'type': _type,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(doc == null
                                        ? 'Passage added!'
                                        : 'Passage updated!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(doc == null ? 'Add Passage' : 'Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentItem(DocumentSnapshot doc, bool isStory) {
    final data = doc.data() as Map<String, dynamic>;
    final isDefault = data['isDefault'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No Title',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (isStory) ...[
                        const SizedBox(height: 8),
                        Text(
                          data['content']?.length > 100
                              ? '${data['content'].substring(0, 100)}...'
                              : data['content'] ?? 'No Content',
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDefault) ...[
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (isStory) const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        isStory
                            ? _showStoryQuizDialog(context, doc)
                            : _showQuizEditDialog(context, doc);
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text(
                                'Delete this passage and its associated quiz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          if (isStory && data['quizId'] != null) {
                            await FirebaseFirestore.instance
                                .collection('Quizzes')
                                .doc(data['quizId'])
                                .delete();
                          }
                          await FirebaseFirestore.instance
                              .collection(isStory ? 'Stories' : 'Quizzes')
                              .doc(doc.id)
                              .delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Deleted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(data['gradeLevel'] ?? ''),
                  backgroundColor: Colors.blue[50],
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(data['set'] ?? ''),
                  backgroundColor: Colors.green[50],
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(data['type'] == 'pretest' ? 'Pre Test' : 'Post Test'),
                  backgroundColor: Colors.orange[50],
                  visualDensity: VisualDensity.compact,
                ),
                if (!isStory) Chip(
                  label: Text('${(data['questions'] as List?)?.length ?? 0} Questions'),
                  backgroundColor: Colors.purple[50],
                  visualDensity: VisualDensity.compact,
                ),
                if (isDefault) const Chip(
                  label: Text('Default'),
                  backgroundColor: Colors.grey,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(String collection, bool isStory) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy('title')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading ${isStory ? 'passages' : 'quizzes'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = _sortDocuments(snapshot.data!.docs);
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isStory ? Icons.auto_stories : Icons.quiz,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${isStory ? 'passages' : 'quizzes'} found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showStoryQuizDialog(context),
                  child: Text('Add ${isStory ? 'Passage' : 'Quiz'}'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => 
              _buildContentItem(docs[index], isStory),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manage Content',
      showAppBar: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Content Management",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showStoryQuizDialog(context),
                    tooltip: 'Add Content',
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.6),
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.auto_stories), text: 'Passages'),
                Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildContentList('Stories', true),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'To delete a quiz, delete its associated passage. Default quizzes cannot be edited or deleted.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildContentList('Quizzes', false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}