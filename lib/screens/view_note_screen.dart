import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../screens/add_edit_note_screen.dart';
import '../utils/color_utils.dart';

class ViewNoteScreen extends StatelessWidget {
  final Note note;

  const ViewNoteScreen({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: note.color,
      appBar: AppBar(
        backgroundColor: note.color.darken(0.1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Note Details',
          style: TextStyle(
            color: getTextColor(note.color),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: getTextColor(note.color),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: getTextColor(note.color),
            ),
            onPressed: () {
              final noteProvider =
                  Provider.of<NoteProvider>(context, listen: false);
              final updatedNote = note.copyWith(
                isPinned: !note.isPinned,
                updatedAt: DateTime.now(),
              );
              noteProvider.updateNote(updatedNote);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      updatedNote.isPinned ? 'Note pinned' : 'Note unpinned'),
                  backgroundColor: theme.primaryColor,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: getTextColor(note.color),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => AddEditNoteScreen(
                    taskId: note.taskId,
                    note: note,
                  ),
                ),
              )
                  .then((_) {
                // Just pop this view after editing
                Navigator.of(context).pop();
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: getTextColor(note.color),
            ),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and category
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    note.color,
                    note.color.darken(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: getTextColor(note.color),
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: -0.2,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                      ),

                  const SizedBox(height: 12),

                  // Category
                  if (note.category != null && note.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: getTextColor(note.color).withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            note.category!,
                            style: TextStyle(
                              fontSize: 14,
                              color: getTextColor(note.color),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutQuad,
                        ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content with Markdown
                  Card(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.1)
                        : Colors.white.withOpacity(0.6),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                color:
                                    getTextColor(note.color).withOpacity(0.7),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Content',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: getTextColor(note.color),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          MarkdownBody(
                            data: note.content,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 16,
                                color: getTextColor(note.color),
                                height: 1.6,
                              ),
                              h1: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: getTextColor(note.color),
                              ),
                              h2: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: getTextColor(note.color),
                              ),
                              h3: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: getTextColor(note.color),
                              ),
                              blockquote: TextStyle(
                                fontSize: 16,
                                color:
                                    getTextColor(note.color).withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              code: TextStyle(
                                fontSize: 14,
                                color: getTextColor(note.color),
                                backgroundColor: isDarkMode
                                    ? Colors.black54
                                    : Colors.grey[200],
                                fontFamily: 'monospace',
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.black54
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              listBullet: TextStyle(
                                fontSize: 16,
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
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            shrinkWrap: true,
                            softLineBreak: true,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(
                        begin: 0.05,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                      ),

                  const SizedBox(height: 24),

                  // Information section
                  Card(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.1)
                        : Colors.white.withOpacity(0.6),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color:
                                    getTextColor(note.color).withOpacity(0.7),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Note Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: getTextColor(note.color),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Dates
                          _buildInfoRow(
                            context,
                            'Created',
                            DateFormat('MMM dd, yyyy • HH:mm')
                                .format(note.createdAt),
                            Icons.calendar_today,
                            note.color,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Updated',
                            DateFormat('MMM dd, yyyy • HH:mm')
                                .format(note.updatedAt),
                            Icons.update,
                            note.color,
                          ),

                          // Location (if available)
                          if (note.location != null &&
                              note.location!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'Location',
                              note.location!,
                              Icons.location_on,
                              note.color,
                            ),
                          ],

                          // Task info (if attached to a task)
                          if (note.taskId.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'Task ID',
                              note.taskId,
                              Icons.task_alt,
                              note.color,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(
                        begin: 0.05,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                      ),

                  const SizedBox(height: 24),

                  // Tags
                  if (note.tags.isNotEmpty)
                    Card(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white.withOpacity(0.6),
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tag,
                                  color:
                                      getTextColor(note.color).withOpacity(0.7),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tags',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getTextColor(note.color),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: note.tags
                                  .map((tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: theme.primaryColor
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          "#$tag",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode
                                                ? theme.primaryColor
                                                    .lighten(0.2)
                                                : theme.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 700.ms).slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutQuad,
                        ),

                  // Attachments (placeholder for future implementation)
                  if (note.attachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Card(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.1)
                            : Colors.white.withOpacity(0.6),
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attachment,
                                    color: getTextColor(note.color)
                                        .withOpacity(0.7),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Attachments (${note.attachments.length})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: getTextColor(note.color),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: note.attachments.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 16),
                                itemBuilder: (context, index) {
                                  final attachment = note.attachments[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.insert_drive_file,
                                        color: theme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      attachment.split('/').last,
                                      style: TextStyle(
                                        color: getTextColor(note.color),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.open_in_new,
                                      size: 18,
                                      color: theme.primaryColor,
                                    ),
                                    onTap: () {
                                      // Handle attachment viewing
                                      try {
                                        final uri = Uri.parse(attachment);
                                        launchUrl(uri,
                                            mode: LaunchMode.platformDefault);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Cannot open attachment'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutQuad,
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(BuildContext context, String label, String value,
      IconData icon, Color backgroundColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getTextColor(backgroundColor) == Colors.white
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: getTextColor(backgroundColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: getTextColor(backgroundColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: getTextColor(backgroundColor).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Delete Note'),
          ],
        ),
        content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
            onPressed: () {
              final noteProvider =
                  Provider.of<NoteProvider>(context, listen: false);
              noteProvider.deleteNote(note.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to previous screen

              // Show a snackbar confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note deleted'),
                  backgroundColor: theme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
