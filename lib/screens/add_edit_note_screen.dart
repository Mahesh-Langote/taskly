import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/markdown_toolbar.dart';
import '../widgets/markdown_help_dialog.dart';

class AddEditNoteScreen extends StatefulWidget {
  final String taskId;
  final Note? note; // If null, we're adding a new note

  const AddEditNoteScreen({
    super.key,
    required this.taskId,
    this.note,
  });

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _locationController;
  late TextEditingController _categoryController;
  late TextEditingController _tagController;

  List<String> _tags = [];
  Color _selectedColor = Colors.white;
  bool _isPinned = false;
  List<String> _attachments = [];
  // This will be populated with task categories
  late List<String> _suggestedCategories;

  // For tab controller to switch between edit and preview
  late TabController _tabController;

  // Predefined colors for notes
  final List<Color> _colorOptions = [
    Colors.white,
    Colors.red.shade100,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.deepPurple.shade100,
    Colors.blue.shade100,
    Colors.cyan.shade100,
    Colors.teal.shade100,
    Colors.green.shade100,
    Colors.lime.shade100,
    Colors.yellow.shade100,
    Colors.amber.shade100,
    Colors.orange.shade100,
  ];
  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with note data if editing
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _locationController = TextEditingController(text: note?.location ?? '');
    _categoryController = TextEditingController(text: note?.category ?? '');
    _tagController = TextEditingController();

    if (note != null) {
      _tags = [...note.tags];
      _selectedColor = note.color;
      _isPinned = note.isPinned;
      _attachments = [...note.attachments];
    }

    // Initialize categories from AppTheme (same as tasks)
    _suggestedCategories = AppTheme.predefinedCategories
        .map((category) => category['name'] as String)
        .toList();

    // Get any custom categories in the next frame after providers are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomCategories();
    });
  }

  void _loadCustomCategories() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final predefinedCategoryNames = AppTheme.predefinedCategories
        .map((category) => category['name'] as String)
        .toSet();

    final customCategories = categoryProvider.categories
        .map((category) => category.name)
        .where((name) => !predefinedCategoryNames.contains(name))
        .toList();

    setState(() {
      _suggestedCategories = [..._suggestedCategories, ...customCategories];
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      final updatedNote = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        taskId: widget.taskId,
        color: _selectedColor,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        tags: _tags,
        attachments: _attachments,
        isPinned: _isPinned,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
      );

      if (widget.note == null) {
        // Adding new note
        noteProvider.addNote(updatedNote);
      } else {
        // Updating existing note
        noteProvider.updateNote(updatedNote);
      }

      // Manually trigger cloud sync
      await noteProvider.syncWithCloud();

      // Show a snackbar indicating sync status
      if (!mounted) return;

      final syncError = noteProvider.syncError;
      if (syncError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note saved locally. Sync error: $syncError'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(noteProvider.syncInProgress
                ? 'Note saved. Syncing with cloud...'
                : 'Note saved and synced with cloud'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                theme.primaryColor.withOpacity(0.8),
                theme.primaryColor.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            tooltip: 'Save Note',
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Note Color Selection
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pin Button
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: _isPinned
                              ? theme.primaryColor
                              : isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                        ),
                        tooltip: _isPinned ? 'Unpin Note' : 'Pin Note',
                        onPressed: () {
                          setState(() {
                            _isPinned = !_isPinned;
                          });
                        },
                      ),
                    ),

                    // Color Selection
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final color in _colorOptions)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = color;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedColor == color
                                          ? theme.primaryColor
                                          : Colors.grey.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(
                    begin: -0.1,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutQuad,
                  ),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _selectedColor,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutQuad,
                    delay: 100.ms,
                  ),

              const SizedBox(height: 16),

              // Category Field with Suggestions
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      hintText: 'Enter or select a category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.shade100,
                      prefixIcon: const Icon(Icons.category),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Category Suggestions
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestedCategories
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ActionChip(
                                  label: Text(category),
                                  backgroundColor:
                                      _categoryController.text == category
                                          ? theme.primaryColor.withOpacity(0.2)
                                          : null,
                                  onPressed: () {
                                    setState(() {
                                      _categoryController.text = category;
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutQuad,
                    delay: 150.ms,
                  ),

              const SizedBox(height: 16), // Content Field with Markdown support
              Column(
                children: [
                  // Tab bar for Edit/Preview
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'EDIT'),
                        Tab(text: 'PREVIEW'),
                      ],
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor:
                          isDarkMode ? Colors.white70 : Colors.black54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: Theme.of(context).primaryColor,
                    ),
                  ),

                  // Content area (Edit/Preview)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    height: 300, // Fixed height for content area
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Edit Tab
                        Column(
                          children: [
                            // Markdown Toolbar
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: MarkdownToolbar(
                                controller: _contentController,
                                onInsert:
                                    (String _) {}, // Just for state update
                              ),
                            ),

                            // Text editor
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: TextField(
                                  controller: _contentController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Type your note here. Supports Markdown formatting.',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textAlignVertical: TextAlignVertical.top,
                                  expands: true,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Preview Tab
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Markdown(
                            data: _contentController.text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                              h1: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              h2: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              h3: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              blockquote: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                              code: TextStyle(
                                fontSize: 13,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
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
                            ),
                            onTapLink: (text, href, title) {
                              if (href != null) {
                                final uri = Uri.parse(href);
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            shrinkWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Helper text for markdown with help button
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        TextButton.icon(
                          icon: const Icon(Icons.help_outline, size: 14),
                          label: Text(
                            'Markdown Help',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const MarkdownHelpDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutQuad,
                    delay: 200.ms,
                  ),

              const SizedBox(height: 16),

              // Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: 'Add a tag',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.shade800.withOpacity(0.5)
                                : Colors.grey.shade100,
                            prefixIcon: const Icon(Icons.tag),
                          ),
                          onFieldSubmitted: _addTag,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addTag(_tagController.text),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Display tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor:
                                  theme.primaryColor.withOpacity(0.2),
                            ))
                        .toList(),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutQuad,
                    delay: 250.ms,
                  ),

              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutQuad,
                    delay: 300.ms,
                  ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.note == null ? 'Add Note' : 'Save Changes',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
