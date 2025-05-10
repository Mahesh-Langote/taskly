import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../screens/add_edit_note_screen.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Function(String) onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: note.color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditNoteScreen(
                taskId: note.taskId,
                note: note,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: note.color.darken(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (note.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  if (note.isPinned) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: getTextColor(note.color),
                          ),
                        ),
                        if (note.category != null && note.category!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note.category!,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    getTextColor(note.color).withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (note.category != null && note.category!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Consumer<NoteProvider>(
                              builder: (context, noteProvider, _) {
                                final categoryColor =
                                    noteProvider.getCategoryColorWithProvider(
                                        context,
                                        note.category ?? "Uncategorized");
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: categoryColor, width: 1),
                                  ),
                                  child: Text(
                                    note.category ?? "Uncategorized",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: categoryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action buttons
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditNoteScreen(
                            taskId: note.taskId,
                            note: note,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
            ), // Content with enhanced markdown support
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: MarkdownBody(
                data: note.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 14,
                    color: getTextColor(note.color),
                    height: 1.4,
                  ),
                  h1: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(note.color),
                  ),
                  h2: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(note.color),
                  ),
                  h3: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(note.color),
                  ),
                  blockquote: TextStyle(
                    fontSize: 14,
                    color: getTextColor(note.color).withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  code: TextStyle(
                    fontSize: 13,
                    color: getTextColor(note.color),
                    backgroundColor:
                        isDarkMode ? Colors.black54 : Colors.grey[200],
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isDarkMode ? Colors.black54 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  listBullet: TextStyle(
                    fontSize: 14,
                    color: getTextColor(note.color),
                  ),
                  a: TextStyle(
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href != null) {
                    final uri = Uri.parse(href);
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                shrinkWrap: true,
                softLineBreak: true,
              ),
            ),
            // Footer with metadata
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and tags
                  if (note.category != null || note.tags.isNotEmpty)
                    Row(
                      children: [
                        if (note.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              note.category!,
                              style: TextStyle(
                                fontSize: 12,
                                color: getTextColor(note.color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: note.tags.isNotEmpty
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: note.tags
                                        .map((tag) => Container(
                                              margin: const EdgeInsets.only(
                                                  right: 6),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "#$tag",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      getTextColor(note.color),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Date and location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm')
                            .format(note.updatedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: getTextColor(note.color).withOpacity(0.6),
                        ),
                      ),
                      if (note.location != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: getTextColor(note.color).withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.location!,
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    getTextColor(note.color).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              onDelete(note.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

// Extension to darken or lighten colors
extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
