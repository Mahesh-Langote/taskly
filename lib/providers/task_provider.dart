import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/sync_manager.dart';
import '../services/auth_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _showCompletedTasks = true;
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

  List<Task> get tasks {
    if (_showCompletedTasks) {
      return [..._tasks];
    } else {
      return _tasks.where((task) => !task.isCompleted).toList();
    }
  }

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get todayTasks => _tasks.where((task) {
        final today = DateTime.now();
        return task.dueDate.year == today.year &&
            task.dueDate.month == today.month &&
            task.dueDate.day == today.day;
      }).toList();

  List<Task> get upcomingTasks => _tasks.where((task) {
        final today = DateTime.now();
        final tomorrow = DateTime(today.year, today.month, today.day + 1);
        return task.dueDate.isAfter(tomorrow) && !task.isCompleted;
      }).toList();

  bool get showCompletedTasks => _showCompletedTasks;

  // Constructor with optional sync-related services
  TaskProvider({SyncManager? syncManager, AuthService? authService})
      : _syncManager = syncManager,
        _authService = authService {
    _loadSettings();

    // Listen for real-time updates if sync manager is provided
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      _setupRealTimeSync();
    }
  }

  // Setup real-time sync with Firestore
  void _setupRealTimeSync() {
    final taskStream = _syncManager?.setupTasksRealTimeSync();
    if (taskStream != null) {
      taskStream.listen((remoteTasks) {
        // Only update if we have remote tasks and are not currently syncing
        if (remoteTasks.isNotEmpty && !_syncInProgress) {
          _tasks = _mergeTasks(_tasks, remoteTasks);
          _saveTasks();
          notifyListeners();
        }
      }, onError: (error) {
        debugPrint('Error in real-time sync: $error');
        _syncError = 'Real-time sync error';
        notifyListeners();
      });
    }
  }

  // Merge local and remote tasks (preferring newer versions)
  List<Task> _mergeTasks(List<Task> localTasks, List<Task> remoteTasks) {
    final Map<String, Task> taskMap = {};

    // Add all local tasks to map
    for (final task in localTasks) {
      taskMap[task.id] = task;
    }

    // Update map with remote tasks (overwrite if newer)
    for (final remoteTask in remoteTasks) {
      final localTask = taskMap[remoteTask.id];
      if (localTask == null ||
          remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
        taskMap[remoteTask.id] = remoteTask;
      }
    }

    return taskMap.values.toList();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _showCompletedTasks = prefs.getBool('showCompletedTasks') ?? true;
      await loadTasks();

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

      // Get tasks from cloud
      final remoteTasks = await _syncManager!.fetchTasksFromCloud();

      // Merge with local tasks
      if (remoteTasks.isNotEmpty) {
        _tasks = _mergeTasks(_tasks, remoteTasks);
        await _saveTasks();
      }

      // Push local tasks to cloud
      await _syncManager!.syncTasksToCloud(_tasks);
    } catch (e) {
      debugPrint('Error syncing with cloud: $e');
      _syncError = 'Error syncing with cloud';
    } finally {
      _syncInProgress = false;
      notifyListeners();
    }
  }

  Future<void> setShowCompletedTasks(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _showCompletedTasks = value;
    await prefs.setBool('showCompletedTasks', value);
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();

    // Sync with cloud if possible
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      _syncManager!.syncTaskToCloud(task);
    }

    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex >= 0) {
      _tasks[taskIndex] = updatedTask;
      _saveTasks();

      // Sync with cloud if possible
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        _syncManager!.syncTaskToCloud(updatedTask);
      }

      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveTasks();

    // Delete from cloud if possible
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      _syncManager!.deleteTaskFromCloud(id);
    }

    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex >= 0) {
      final updatedTask = _tasks[taskIndex].copyWith(
        isCompleted: !_tasks[taskIndex].isCompleted,
        updatedAt: DateTime.now(),
      );

      _tasks[taskIndex] = updatedTask;
      _saveTasks();

      // Sync with cloud if possible
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        _syncManager!.syncTaskToCloud(updatedTask);
      }

      notifyListeners();
    }
  }

  List<Task> getTasksByCategory(String category) {
    if (_showCompletedTasks) {
      return _tasks.where((task) => task.category == category).toList();
    } else {
      return _tasks
          .where((task) => task.category == category && !task.isCompleted)
          .toList();
    }
  }

  Future<void> deleteAllTasks() async {
    _tasks.clear();
    await _saveTasks();

    // If authenticated, batch delete all tasks from cloud
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      for (final task in _tasks) {
        await _syncManager!.deleteTaskFromCloud(task.id);
      }
    }

    notifyListeners();
  }

  Future<void> deleteCompletedTasks() async {
    final completedTaskIds = _tasks
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();

    _tasks.removeWhere((task) => task.isCompleted);
    await _saveTasks();

    // If authenticated, delete completed tasks from cloud
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      for (final taskId in completedTaskIds) {
        await _syncManager!.deleteTaskFromCloud(taskId);
      }
    }

    notifyListeners();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      try {
        final List<dynamic> decodedData = jsonDecode(tasksJson);
        _tasks = decodedData.map((item) => Task.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading tasks: $e');
        _tasks = [];
      }
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }
}
