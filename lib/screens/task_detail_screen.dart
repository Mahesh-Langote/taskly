import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/task_form_bottom_sheet.dart';
import '../widgets/notes_section.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Extract URLs from description for preview
    final RegExp urlRegExp = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    final urls = urlRegExp
        .allMatches(task.description)
        .map((match) => match.group(0))
        .where((url) => url != null)
        .map((url) => url!)
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode
          ? Color.lerp(theme.colorScheme.background, Colors.black, 0.3)
          : Color.lerp(theme.colorScheme.background, Colors.white, 0.5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
            ),
            tooltip: 'Edit Task',
            onPressed: () {
              _showEditTaskBottomSheet(context, task);
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: Colors.white70,
              ),
              tooltip: 'Delete Task',
              onPressed: () {
                _showDeleteConfirmationDialog(context, taskProvider);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header with task title and category
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    task.categoryColor.withOpacity(0.8),
                    task.categoryColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: task.categoryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and priority
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task.category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildPriorityBadge(task.priority),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: -0.2,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                      ),

                  const SizedBox(height: 20),

                  // Task Title
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(
                        begin: -0.1,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                        delay: 100.ms,
                      ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Task Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Due Date',
                          value: AppDateUtils.formatDate(task.dueDate),
                          iconColor: _getDateColor(task.dueDate),
                          delay: 150.ms,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.access_time_rounded,
                          title: 'Due Time',
                          value: AppDateUtils.formatTime(task.dueDate),
                          iconColor: task.categoryColor,
                          delay: 200.ms,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status Card
                  _buildInfoCard(
                    context,
                    icon: task.isCompleted
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    title: 'Status',
                    value: task.isCompleted ? 'Completed' : 'Pending',
                    iconColor: task.isCompleted ? Colors.green : Colors.orange,
                    fullWidth: true,
                    delay: 250.ms,
                  ),

                  const SizedBox(height: 32),

                  // Description Section Header
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 20,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideX(
                        begin: -0.1,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                        delay: 300.ms,
                      ),

                  const SizedBox(height: 16),

                  // Description Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.surface.withOpacity(0.8)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: task.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: task.description.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Markdown content
                              MarkdownBody(
                                data: task.description,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                  h1: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  h2: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  h3: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  code: TextStyle(
                                    backgroundColor: isDarkMode
                                        ? Colors.black26
                                        : const Color(0xFFF3F3F3),
                                    fontFamily: 'monospace',
                                    color: isDarkMode
                                        ? Colors.amber
                                        : Colors.deepPurple,
                                  ),
                                  blockquote: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  listBullet: TextStyle(
                                    color: task.categoryColor,
                                  ),
                                ),
                                onTapLink: (text, href, title) {
                                  if (href != null) {
                                    _launchUrl(href);
                                  }
                                },
                              ),

                              // URL previews (if any)
                              if (urls.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const Divider(thickness: 1),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.link_rounded,
                                      size: 18,
                                      color: task.categoryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Linked Content',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: task.categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...urls.map((url) => Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: LinkPreview(
                                        enableAnimation: true,
                                        onPreviewDataFetched: (data) {
                                          // Optional callback when preview data is fetched
                                        },
                                        text: url,
                                        previewData:
                                            null, // Will be fetched automatically
                                        onLinkPressed: (url) {
                                          _launchUrl(url);
                                        },
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    )),
                              ]
                            ],
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 40,
                                    color: isDarkMode
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No description provided',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                        delay: 350.ms,
                      ),

                  const SizedBox(height: 36),

                  // Notes Section
                  NotesSection(taskId: task.id),

                  const SizedBox(height: 36),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            taskProvider.toggleTaskCompletion(task.id);
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            task.isCompleted
                                ? Icons.replay
                                : Icons.check_circle,
                          ),
                          label: Text(
                            task.isCompleted
                                ? 'Mark as Incomplete'
                                : 'Mark as Complete',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: task.isCompleted
                                ? Colors.orange
                                : task.categoryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                        delay: 400.ms,
                      ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    bool fullWidth = false,
    required Duration delay,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.8)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: -0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutQuad,
          delay: delay,
        );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildPriorityBadge(int priority) {
    String text = '';
    IconData icon;
    Color badgeColor = Colors.grey;

    switch (priority) {
      case 1:
        text = 'Low';
        icon = Icons.keyboard_arrow_down;
        badgeColor = Colors.green;
        break;
      case 2:
        text = 'Medium';
        icon = Icons.remove;
        badgeColor = Colors.orange;
        break;
      case 3:
        text = 'High';
        icon = Icons.keyboard_arrow_up;
        badgeColor = Colors.red;
        break;
      default:
        text = 'Medium';
        icon = Icons.remove;
        badgeColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: badgeColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDateColor(DateTime date) {
    if (AppDateUtils.isOverdue(date)) {
      return Colors.red;
    } else if (AppDateUtils.isToday(date)) {
      return Colors.blue;
    } else if (AppDateUtils.isTomorrow(date)) {
      return Colors.orange;
    } else {
      return Colors.teal;
    }
  }

  void _showEditTaskBottomSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormBottomSheet(task: task),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, TaskProvider taskProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 10),
              const Text('Delete Task'),
            ],
          ),
          content: const Text(
              'Are you sure you want to delete this task? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                taskProvider.deleteTask(task.id);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
