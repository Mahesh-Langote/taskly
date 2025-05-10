import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../screens/add_edit_note_screen.dart';

class NotesSection extends StatelessWidget {
  final String taskId;

  const NotesSection({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final notes = noteProvider.getNotesByTaskId(taskId);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Sort notes with pinned ones first, then by updated date (newest first)
    final sortedNotes = [...notes];
    sortedNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt); // Newest first
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes section header with add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 20,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notes (${notes.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditNoteScreen(taskId: taskId),
                  ),
                );
              },
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

        // Notes or empty state
        sortedNotes.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 48,
                        color: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add notes to keep track of important details',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Add Note Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditNoteScreen(taskId: taskId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Note'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                        duration: 400.ms,
                        delay: 200.ms,
                      ),
                ),
              )
            : Column(
                children: sortedNotes
                    .asMap()
                    .entries
                    .map(
                      (entry) => NoteCard(
                        note: entry.value,
                        onDelete: (noteId) {
                          noteProvider.deleteNote(noteId);
                        },
                      ).animate().fadeIn(
                            duration: 300.ms,
                            delay: Duration(milliseconds: 100 + entry.key * 50),
                          ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}
