import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_organizaer/models/task.dart';
import 'package:task_organizaer/models/category.dart';
import 'package:task_organizaer/models/note.dart'; // Add Note import

class DatabaseService {
  // Make Firestore nullable and initialize it only when needed
  FirebaseFirestore? _firestore;
  final bool _isOfflineMode;

  // Constructor that accepts offline mode flag
  DatabaseService({bool isOfflineMode = false})
      : _isOfflineMode = isOfflineMode {
    if (!_isOfflineMode) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint('Error initializing Firestore: $e');
      }
    }
  }

  // Collection references with null safety
  CollectionReference? get _usersCollection => _firestore?.collection('users');
  CollectionReference? _tasksCollection(String userId) =>
      _usersCollection?.doc(userId).collection('tasks');
  CollectionReference? _categoriesCollection(String userId) =>
      _usersCollection?.doc(userId).collection('categories');
  CollectionReference? _notesCollection(String userId) =>
      _usersCollection?.doc(userId).collection('notes'); // Add notes collection

  // Add or update a task in Firestore
  Future<void> saveTask(String userId, Task task) async {
    if (_isOfflineMode || _firestore == null) {
      // Just return successfully in offline mode
      return;
    }

    try {
      final collection = _tasksCollection(userId);
      if (collection != null) {
        await collection.doc(task.id).set(task.toJson());
      }
    } catch (e) {
      debugPrint('Error saving task: $e');
      rethrow;
    }
  }

  // Delete a task from Firestore
  Future<void> deleteTask(String userId, String taskId) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final collection = _tasksCollection(userId);
      if (collection != null) {
        await collection.doc(taskId).delete();
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // Get all tasks for a user
  Future<List<Task>> getTasks(String userId) async {
    if (_isOfflineMode || _firestore == null) {
      return [];
    }

    try {
      final collection = _tasksCollection(userId);
      if (collection != null) {
        final snapshot = await collection.get();
        return snapshot.docs
            .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      return [];
    }
  }

  // Stream of tasks for real-time updates
  Stream<List<Task>> streamTasks(String userId) {
    if (_isOfflineMode || _firestore == null) {
      // Return an empty stream in offline mode
      return Stream.value([]);
    }

    final collection = _tasksCollection(userId);
    if (collection == null) {
      return Stream.value([]);
    }

    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Save a category to Firestore
  Future<void> saveCategory(String userId, Category category) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final collection = _categoriesCollection(userId);
      if (collection != null) {
        final categoryMap = {
          'name': category.name,
          'colorValue': category.color.value,
        };
        await collection.doc(category.name).set(categoryMap);
      }
    } catch (e) {
      debugPrint('Error saving category: $e');
      rethrow;
    }
  }

  // Get all categories for a user
  Future<List<Category>> getCategories(String userId) async {
    if (_isOfflineMode || _firestore == null) {
      return [];
    }

    try {
      final collection = _categoriesCollection(userId);
      if (collection != null) {
        final snapshot = await collection.get();
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Category(
            name: data['name'] as String,
            color: Color(data['colorValue'] as int),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  // Delete a category from Firestore
  Future<void> deleteCategory(String userId, String categoryName) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final collection = _categoriesCollection(userId);
      if (collection != null) {
        await collection.doc(categoryName).delete();
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  // Save a note to Firestore
  Future<void> saveNote(String userId, Note note) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final collection = _notesCollection(userId);
      if (collection != null) {
        await collection.doc(note.id).set(note.toJson());
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      rethrow;
    }
  }

  // Get all notes for a user
  Future<List<Note>> getNotes(String userId) async {
    if (_isOfflineMode || _firestore == null) {
      return [];
    }

    try {
      final collection = _notesCollection(userId);
      if (collection != null) {
        final snapshot = await collection.get();
        return snapshot.docs
            .map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting notes: $e');
      return [];
    }
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String userId, String noteId) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final collection = _notesCollection(userId);
      if (collection != null) {
        await collection.doc(noteId).delete();
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  // Batch upload tasks for initial sync
  Future<void> batchUploadTasks(String userId, List<Task> tasks) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final batch = _firestore!.batch();
      final collection = _tasksCollection(userId);

      if (collection != null) {
        for (final task in tasks) {
          final docRef = collection.doc(task.id);
          batch.set(docRef, task.toJson());
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error batch uploading tasks: $e');
      rethrow;
    }
  }

  // Batch upload categories for initial sync
  Future<void> batchUploadCategories(
      String userId, List<Category> categories) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final batch = _firestore!.batch();
      final collection = _categoriesCollection(userId);

      if (collection != null) {
        for (final category in categories) {
          final docRef = collection.doc(category.name);
          batch.set(docRef, {
            'name': category.name,
            'colorValue': category.color.value,
          });
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error batch uploading categories: $e');
      rethrow;
    }
  }

  // Batch upload notes for initial sync
  Future<void> batchUploadNotes(String userId, List<Note> notes) async {
    if (_isOfflineMode || _firestore == null) {
      return;
    }

    try {
      final batch = _firestore!.batch();
      final collection = _notesCollection(userId);

      if (collection != null) {
        for (final note in notes) {
          final docRef = collection.doc(note.id);
          batch.set(docRef, note.toJson());
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error batch uploading notes: $e');
      rethrow;
    }
  }

  // Check if this is the user's first sync
  Future<bool> isFirstSync(String userId) async {
    if (_isOfflineMode || _firestore == null || _usersCollection == null) {
      return true;
    }

    try {
      final userDoc = await _usersCollection!.doc(userId).get();
      return !userDoc.exists ||
          !(userDoc.data() as Map<String, dynamic>)['hasInitialSync'] == true;
    } catch (e) {
      debugPrint('Error checking first sync: $e');
      return true;
    }
  }

  // Mark user as having completed initial sync
  Future<void> markInitialSyncComplete(String userId) async {
    if (_isOfflineMode || _firestore == null || _usersCollection == null) {
      return;
    }

    try {
      await _usersCollection!.doc(userId).set({
        'hasInitialSync': true,
        'lastSyncTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error marking initial sync complete: $e');
      rethrow;
    }
  }

  // Update user's last sync timestamp
  Future<void> updateLastSyncTimestamp(String userId) async {
    if (_isOfflineMode || _firestore == null || _usersCollection == null) {
      return;
    }

    try {
      await _usersCollection!.doc(userId).update({
        'lastSyncTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last sync timestamp: $e');
      rethrow;
    }
  }
}
