import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContentFormDialog extends StatefulWidget {
  final DocumentSnapshot? doc;
  final Function(String, String, String, String, String, List<Map<String, dynamic>>) onSubmit;

  const ContentFormDialog({
    super.key,
    this.doc,
    required this.onSubmit,
  });

  @override
  State<ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends State<ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _gradeLevel = 'Grade 5';
  String _set = 'Set A';
  String _type = 'pretest';
  List<Map<String, dynamic>> _quizQuestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.doc != null) {
      final data = widget.doc!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _gradeLevel = data['gradeLevel'] ?? 'Grade 5';
      _set = data['set'] ?? 'Set A';
      _type = data['type'] ?? 'pretest';
    }
    _quizQuestions = [
      {
        'question': '',
        'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
        'correctAnswer': 'A'
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doc == null ? 'Add Passage' : 'Edit Passage',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFormFields(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Grade', _gradeLevel, ['Grade 3', 'Grade 4', 'Grade 5', 'Grade 6'],
                  (val) => _gradeLevel = val!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown('Set', _set, ['Set A', 'Set B', 'Set C', 'Set D'],
                  (val) => _set = val!),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDropdown('Type', _type, ['pretest', 'post test'], (val) => _type = val!),
        if (widget.doc == null) _buildQuizSection(),
      ],
    );
  }

  Widget _buildQuizSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Quiz Questions', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._quizQuestions.asMap().entries.map((entry) => _buildQuestionCard(entry.key, entry.value)).toList(),
        ElevatedButton(
          onPressed: () => setState(() {
            _quizQuestions.add({
              'question': '',
              'answers': {'A': '', 'B': '', 'C': '', 'D': ''},
              'correctAnswer': 'A'
            });
          }),
          child: const Text('Add Question'),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int idx, Map<String, dynamic> q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: q['question'],
              decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
              onChanged: (v) => q['question'] = v,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120, // Fixed height for answer grid
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: ['A', 'B', 'C', 'D'].map((ansKey) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      initialValue: q['answers'][ansKey],
                      decoration: InputDecoration(labelText: ansKey, border: const OutlineInputBorder()),
                      onChanged: (v) => q['answers'][ansKey] = v,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Correct:'),
                const SizedBox(width: 8),
                _buildDropdown('', q['correctAnswer'], ['A', 'B', 'C', 'D'],
                    (val) => setState(() => q['correctAnswer'] = val!)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _quizQuestions.length > 1
                      ? () => setState(() => _quizQuestions.removeAt(idx))
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item == 'pretest' || item == 'post test' 
            ? item[0].toUpperCase() + item.substring(1)
            : item),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15A323)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                _titleController.text,
                _contentController.text,
                _gradeLevel,
                _set,
                _type,
                _quizQuestions,
              );
              Navigator.pop(context);
            }
          },
          child: Text(widget.doc == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}