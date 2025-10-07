import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentItemWidget extends StatelessWidget {
  final DocumentSnapshot doc;
  final bool isStory;
  final Function(DocumentSnapshot) onEdit;
  final Function(DocumentSnapshot)? onDelete;

  const ContentItemWidget({
    super.key,
    required this.doc,
    required this.isStory,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isStory) ...[
                        const SizedBox(height: 8),
                        Text(
                          data['content']?.length > 100
                              ? '${data['content'].substring(0, 100)}...'
                              : data['content'] ?? 'No Content',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    final items = <PopupMenuItem<String>>[
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                    ];

                    if (onDelete != null) {
                      items.add(
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Delete'),
                            ],
                          ),
                        ),
                      );
                    }

                    return items;
                  },
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(doc);
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!(doc);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(context, data['gradeLevel'] ?? ''),
                _buildInfoChip(context, data['set'] ?? ''),
                _buildInfoChip(
                  context,
                  data['type'] == 'pretest' ? 'Pre-Test' : 'Post-Test',
                  color: data['type'] == 'pretest' ? Colors.blue : Colors.green,
                ),
                if (!isStory) ...[
                  _buildInfoChip(
                    context,
                    '${(data['questions'] as List?)?.length ?? 0} Questions',
                    color: Colors.purple,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, {Color? color}) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color ?? theme.colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: color?.withOpacity(0.1) ?? theme.colorScheme.primaryContainer,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}