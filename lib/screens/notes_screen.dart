import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../providers/note_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // List for categories dropdown
  late List<String> _categories = ['All', 'Uncategorized'];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = 'All';

    // Add task categories to the categories list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _loadCategories() {
    // Add the predefined task categories to our list
    final categoryNames = AppTheme.predefinedCategories
        .map((category) => category['name'] as String)
        .toList();

    // Get any custom categories from the provider
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final customCategories = categoryProvider.categories
        .map((category) => category.name)
        .where((name) => !categoryNames.contains(name))
        .toList();

    setState(() {
      _categories = [
        'All',
        ...categoryNames,
        ...customCategories,
        'Uncategorized'
      ];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get all standalone notes (notes without taskId or with empty taskId)
    List<Note> standaloneNotes = noteProvider.getStandaloneNotes();

    // Get task-related notes
    List<Note> taskNotes = noteProvider.getTaskNotes();

    // Filter notes based on search query and selected category
    List<Note> filteredStandaloneNotes = _filterNotes(standaloneNotes);
    List<Note> filteredTaskNotes = _filterNotes(taskNotes);

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
          ),
        ),
        title: const Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'STANDALONE NOTES'),
                  Tab(text: 'TASK NOTES'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          },
                          backgroundColor: _getCategoryChipBackgroundColor(
                              category, isDarkMode),
                          selectedColor:
                              _getCategoryChipSelectedColor(category),
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? _getCategoryChipTextColor(category)
                                : isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // Note lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Standalone Notes Tab
                _buildNotesList(
                  filteredStandaloneNotes,
                  noteProvider,
                  'standalone',
                  isDarkMode,
                  theme,
                ),

                // Task Notes Tab
                _buildNotesList(
                  filteredTaskNotes,
                  noteProvider,
                  'task',
                  isDarkMode,
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // For standalone notes, we pass null or empty string as taskId
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditNoteScreen(taskId: ''),
            ),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Note> _filterNotes(List<Note> notes) {
    // If search query is empty and selected category is 'All', return all notes
    if (_searchQuery.isEmpty && _selectedCategory == 'All') {
      return notes;
    }

    // Filter by search query
    List<Note> filteredNotes = notes;
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by selected category
    if (_selectedCategory != 'All') {
      filteredNotes = filteredNotes
          .where((note) => _selectedCategory == 'Uncategorized'
              ? (note.category == null || note.category!.isEmpty)
              : note.category == _selectedCategory)
          .toList();
    }

    return filteredNotes;
  }

  Widget _buildNotesList(
    List<Note> notes,
    NoteProvider noteProvider,
    String type,
    bool isDarkMode,
    ThemeData theme,
  ) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'standalone' ? 'No standalone notes' : 'No task notes',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'standalone'
                  ? 'Add notes independent of tasks'
                  : 'Notes attached to specific tasks will appear here',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade700,
              ),
            ),
            if (type == 'standalone')
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditNoteScreen(taskId: ''),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Your First Note'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onDelete: (noteId) {
            noteProvider.deleteNote(noteId);
            setState(() {}); // Refresh the UI
          },
        );
      },
    );
  }

  // Helper methods for category chip colors
  Color _getCategoryChipBackgroundColor(String category, bool isDarkMode) {
    if (category == 'All') {
      return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    } else if (category == 'Uncategorized') {
      return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    }

    // Try to find category color from predefined categories
    for (var predefinedCategory in AppTheme.predefinedCategories) {
      if (predefinedCategory['name'] == category) {
        Color baseColor = predefinedCategory['color'] as Color;
        return baseColor.withOpacity(0.15);
      }
    }

    // If category not found in predefined ones, try to get from provider
    try {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final categoryObj = categoryProvider.categories.firstWhere(
        (c) => c.name == category,
        orElse: () => Category(name: '', color: Colors.grey),
      );
      if (categoryObj.name.isNotEmpty) {
        return categoryObj.color.withOpacity(0.15);
      }
    } catch (e) {
      // Use default color if there's an error
    }

    return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
  }

  Color _getCategoryChipSelectedColor(String category) {
    if (category == 'All' || category == 'Uncategorized') {
      return Theme.of(context).primaryColor.withOpacity(0.7);
    }

    // Try to find category color from predefined categories
    for (var predefinedCategory in AppTheme.predefinedCategories) {
      if (predefinedCategory['name'] == category) {
        Color baseColor = predefinedCategory['color'] as Color;
        return baseColor;
      }
    }

    // If category not found in predefined ones, try to get from provider
    try {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final categoryObj = categoryProvider.categories.firstWhere(
        (c) => c.name == category,
        orElse: () => Category(name: '', color: Theme.of(context).primaryColor),
      );
      if (categoryObj.name.isNotEmpty) {
        return categoryObj.color;
      }
    } catch (e) {
      // Use default color if there's an error
    }

    return Theme.of(context).primaryColor.withOpacity(0.7);
  }

  Color _getCategoryChipTextColor(String category) {
    if (category == 'All' || category == 'Uncategorized') {
      return Colors.white;
    }

    // For custom categories, return white for better contrast
    return Colors.white;
  }
}
