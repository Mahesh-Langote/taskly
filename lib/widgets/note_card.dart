import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../screens/add_edit_note_screen.dart';
import '../screens/view_note_screen.dart';
import '../utils/color_utils.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final Function(String) onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: widget.note.color,
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
          // Show detailed note view
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ViewNoteScreen(
                note: widget.note,
              ),
            ),
          );
        },
        onLongPress: () {
          // Toggle expanded state on long press
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.note.color.darken(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (widget.note.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  if (widget.note.isPinned) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: getTextColor(widget.note.color),
                          ),
                        ),
                        if (widget.note.category != null &&
                            widget.note.category!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.note.category!,
                              style: TextStyle(
                                fontSize: 12,
                                color: getTextColor(widget.note.color)
                                    .withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action buttons in header
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditNoteScreen(
                            taskId: widget.note.taskId,
                            note: widget.note,
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
            ),

            // Content preview (always visible, max 4 lines when collapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content preview
                  if (!_isExpanded)
                    Text(
                      // Strip markdown formatting for preview
                      _stripMarkdown(widget.note.content),
                      style: TextStyle(
                        fontSize: 14,
                        color: getTextColor(widget.note.color),
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    MarkdownBody(
                      data: widget.note.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          color: getTextColor(widget.note.color),
                          height: 1.4,
                        ),
                        h1: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(widget.note.color),
                        ),
                        h2: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(widget.note.color),
                        ),
                        h3: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(widget.note.color),
                        ),
                        blockquote: TextStyle(
                          fontSize: 14,
                          color:
                              getTextColor(widget.note.color).withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        code: TextStyle(
                          fontSize: 13,
                          color: getTextColor(widget.note.color),
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
                          color: getTextColor(widget.note.color),
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

                  // "Show more" / "Show less" indicator
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'Show less' : 'Show more',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.primaryColor,
                            ),
                          ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Additional details (only visible when expanded)
            if (_isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),

                  // Tags
                  if (widget.note.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.note.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "#$tag",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: getTextColor(widget.note.color),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                  // Date and location
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy • HH:mm')
                              .format(widget.note.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: getTextColor(widget.note.color)
                                .withOpacity(0.6),
                          ),
                        ),
                        if (widget.note.location != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: getTextColor(widget.note.color)
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.note.location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: getTextColor(widget.note.color)
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ).animate().fadeIn(duration: 200.ms).slideY(
                    begin: -0.05,
                    end: 0,
                    duration: 200.ms,
                    curve: Curves.easeOutQuad,
                  ),
          ],
        ),
      ),
    );
  }

  // Helper method to strip basic markdown formatting for preview
  String _stripMarkdown(String markdown) {
    String result = markdown;
    // Remove headers
    result = result.replaceAll(RegExp(r'#{1,6}\s'), '');
    // Remove bold/italic markers
    result = result.replaceAll(RegExp(r'\*\*|__|\*|_'), '');
    // Remove code blocks
    result = result.replaceAll(RegExp(r'```.*?```', dotAll: true), '');
    // Remove inline code
    result = result.replaceAll(RegExp(r'`[^`]*`'), '');
    // Remove blockquotes
    result = result.replaceAll(RegExp(r'>\s.*'), '');
    // Remove links but keep text
    result = result.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (match) => match.group(1) ?? '',
    );
    // Remove images
    result = result.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');
    // Remove HTML tags
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');

    return result.trim();
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
              widget.onDelete(widget.note.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

// Note: ColorExtension is now imported from utils/color_utils.dart
