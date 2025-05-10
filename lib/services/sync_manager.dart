import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_organizaer/models/task.dart';
import 'package:task_organizaer/models/category.dart';
import 'package:task_organizaer/models/note.dart'; // Add Note import
import 'package:task_organizaer/services/auth_service.dart';
import 'package:task_organizaer/services/database_service.dart';

class SyncManager {
  final AuthService _authService;
  final DatabaseService _databaseService;

  // Sync status
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Stream controller for notifying about sync status
  final StreamController<bool> _syncStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  // Constructor
  SyncManager({
    required AuthService authService,
    required DatabaseService databaseService,
  })  : _authService = authService,
        _databaseService = databaseService;

  // Dispose resources
  void dispose() {
    _syncStatusController.close();
  }

  // Sync tasks to the cloud
  Future<void> syncTasksToCloud(List<Task> tasks) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      // Check if this is the first sync
      bool isFirstSync = await _databaseService.isFirstSync(userId);

      if (isFirstSync) {
        // Initial sync: upload all tasks in batch
        await _databaseService.batchUploadTasks(userId, tasks);
        await _databaseService.markInitialSyncComplete(userId);
      } else {
        // Regular sync: handle individual tasks
        for (final task in tasks) {
          await _databaseService.saveTask(userId, task);
        }
      }

      // Update last sync timestamp
      await _databaseService.updateLastSyncTimestamp(userId);
    } catch (e) {
      debugPrint('Error syncing tasks to cloud: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Sync a single task to the cloud
  Future<void> syncTaskToCloud(Task task) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      await _databaseService.saveTask(userId, task);
    } catch (e) {
      debugPrint('Error syncing task to cloud: $e');
    }
  }

  // Delete task from cloud
  Future<void> deleteTaskFromCloud(String taskId) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      await _databaseService.deleteTask(userId, taskId);
    } catch (e) {
      debugPrint('Error deleting task from cloud: $e');
    }
  }

  // Fetch tasks from cloud
  Future<List<Task>> fetchTasksFromCloud() async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return [];
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      final tasks = await _databaseService.getTasks(userId);
      return tasks;
    } catch (e) {
      debugPrint('Error fetching tasks from cloud: $e');
      return [];
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Sync categories to the cloud
  Future<void> syncCategoriesToCloud(List<Category> categories) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      // Check if this is the first sync
      bool isFirstSync = await _databaseService.isFirstSync(userId);

      if (isFirstSync) {
        // Initial sync: upload all categories in batch
        await _databaseService.batchUploadCategories(userId, categories);
      } else {
        // Regular sync: handle individual categories
        for (final category in categories) {
          await _databaseService.saveCategory(userId, category);
        }
      }
    } catch (e) {
      debugPrint('Error syncing categories to cloud: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Fetch categories from cloud
  Future<List<Category>> fetchCategoriesFromCloud() async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return [];
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      final categories = await _databaseService.getCategories(userId);
      return categories;
    } catch (e) {
      debugPrint('Error fetching categories from cloud: $e');
      return [];
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Setup real-time sync for tasks
  Stream<List<Task>>? setupTasksRealTimeSync() {
    final userId = _authService.getUserId();
    if (userId == null) return null;

    return _databaseService.streamTasks(userId);
  }

  // Delete category from cloud
  Future<void> deleteCategory(String categoryName) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      await _databaseService.deleteCategory(userId, categoryName);
    } catch (e) {
      debugPrint('Error deleting category from cloud: $e');
    }
  }

  // Sync a single note to the cloud
  Future<void> syncNoteToCloud(Note note) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      await _databaseService.saveNote(userId, note);
    } catch (e) {
      debugPrint('Error syncing note to cloud: $e');
    }
  }

  // Sync all notes to the cloud
  Future<void> syncNotesToCloud(List<Note> notes) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      // Check if this is the first sync
      bool isFirstSync = await _databaseService.isFirstSync(userId);

      if (isFirstSync) {
        // Initial sync: upload all notes in batch
        await _databaseService.batchUploadNotes(userId, notes);
      } else {
        // Regular sync: handle individual notes
        for (final note in notes) {
          await _databaseService.saveNote(userId, note);
        }
      }
    } catch (e) {
      debugPrint('Error syncing notes to cloud: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Fetch notes from the cloud
  Future<List<Note>> fetchNotesFromCloud() async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return [];
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      final notes = await _databaseService.getNotes(userId);
      return notes;
    } catch (e) {
      debugPrint('Error fetching notes from cloud: $e');
      return [];
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Delete note from cloud
  Future<void> deleteNoteFromCloud(String noteId) async {
    final userId = _authService.getUserId();
    if (userId == null || await _authService.isOfflineModeEnabled()) {
      return;
    }

    try {
      await _databaseService.deleteNote(userId, noteId);
    } catch (e) {
      debugPrint('Error deleting note from cloud: $e');
    }
  }
}
