import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../services/sync_manager.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  bool _syncInProgress = false;
  String? _syncError;

  // Sync-related services
  final SyncManager? _syncManager;
  final AuthService? _authService;

  // Getters
  bool get isLoading => _isLoading;
  bool get syncInProgress => _syncInProgress;
  String? get syncError => _syncError;
  List<Note> get notes => [..._notes];

  // Constructor with optional sync services
  NoteProvider({SyncManager? syncManager, AuthService? authService})
      : _syncManager = syncManager,
        _authService = authService {
    _loadSettings();
  }
  // Get notes by task ID
  List<Note> getNotesByTaskId(String taskId) {
    return _notes.where((note) => note.taskId == taskId).toList();
  }

  // Get standalone notes (notes without taskId or with empty taskId)
  List<Note> getStandaloneNotes() {
    return _notes.where((note) => note.taskId.isEmpty).toList();
  }

  // Get all task-related notes
  List<Note> getTaskNotes() {
    return _notes.where((note) => note.taskId.isNotEmpty).toList();
  }

  // Get notes by category
  List<Note> getNotesByCategory(String category) {
    return _notes.where((note) => note.category == category).toList();
  }

  // Get color for a specific category name
  Color getCategoryColor(String categoryName) {
    // First check predefined categories
    for (var category in AppTheme.predefinedCategories) {
      if (category['name'] == categoryName) {
        return category['color'] as Color;
      }
    }

    // Then check custom categories (can be implemented if you have access to CategoryProvider)
    // For now return a default color if not found
    return Colors.grey;
  }

  // Get color for a specific category name with CategoryProvider support
  Color getCategoryColorWithProvider(
      BuildContext context, String categoryName) {
    // First check predefined categories
    for (var category in AppTheme.predefinedCategories) {
      if (category['name'] == categoryName) {
        return category['color'] as Color;
      }
    }

    // Then check custom categories from CategoryProvider
    try {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final category = categoryProvider.categories.firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => Category(name: '', color: Colors.grey));

      if (category.name.isNotEmpty) {
        return category.color;
      }
    } catch (e) {
      debugPrint('Error getting category color: $e');
    }

    // Return a default color if not found
    return Colors.grey;
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadNotes();

      // Attempt to sync with cloud if authenticated
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        await syncWithCloud();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync with cloud
  Future<void> syncWithCloud() async {
    if (_syncManager == null ||
        _authService == null ||
        !_authService!.isLoggedIn) {
      return;
    }

    try {
      _syncInProgress = true;
      _syncError = null;
      notifyListeners();

      // First check if offline mode is enabled
      final isOffline = await _authService!.isOfflineModeEnabled();
      if (isOffline) {
        _syncInProgress = false;
        notifyListeners();
        return;
      }

      // Get notes from cloud
      final remoteNotes = await _syncManager!.fetchNotesFromCloud();

      // Merge with local notes
      if (remoteNotes.isNotEmpty) {
        _notes = _mergeNotes(_notes, remoteNotes);
        await _saveNotes();
      }

      // Push local notes to cloud
      await _syncManager!.syncNotesToCloud(_notes);
    } catch (e) {
      debugPrint('Error syncing with cloud: $e');
      _syncError = 'Error syncing with cloud';
    } finally {
      _syncInProgress = false;
      notifyListeners();
    }
  }

  // Merge local and remote notes (preferring newer versions)
  List<Note> _mergeNotes(List<Note> localNotes, List<Note> remoteNotes) {
    final Map<String, Note> noteMap = {};

    // Add all local notes to map
    for (final note in localNotes) {
      noteMap[note.id] = note;
    }

    // Update map with remote notes (overwrite if newer)
    for (final remoteNote in remoteNotes) {
      final localNote = noteMap[remoteNote.id];
      if (localNote == null ||
          remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
        noteMap[remoteNote.id] = remoteNote;
      }
    }

    return noteMap.values.toList();
  }

  void addNote(Note note) {
    _notes.add(note);
    _saveNotes();

    // Sync with cloud if possible
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      _syncManager!.syncNoteToCloud(note);
    }

    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final noteIndex = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (noteIndex >= 0) {
      _notes[noteIndex] = updatedNote;
      _saveNotes();

      // Sync with cloud if possible
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        _syncManager!.syncNoteToCloud(updatedNote);
      }

      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();

    // Delete from cloud if possible
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      _syncManager!.deleteNoteFromCloud(id);
    }

    notifyListeners();
  }

  void deleteNotesByTaskId(String taskId) {
    final notesToDelete =
        _notes.where((note) => note.taskId == taskId).toList();
    _notes.removeWhere((note) => note.taskId == taskId);
    _saveNotes();

    // Delete from cloud if possible
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      for (final note in notesToDelete) {
        _syncManager!.deleteNoteFromCloud(note.id);
      }
    }

    notifyListeners();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      try {
        final List<dynamic> decodedData = jsonDecode(notesJson);
        _notes = decodedData.map((item) => Note.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading notes: $e');
        _notes = [];
      }
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = jsonEncode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString('notes', notesJson);
  }
}
