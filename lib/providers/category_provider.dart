import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';
import '../services/sync_manager.dart';
import '../services/auth_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _syncInProgress = false;

  // Sync-related services
  final SyncManager? _syncManager;
  final AuthService? _authService;

  // Getters
  List<Category> get categories => [..._categories];
  bool get isLoading => _isLoading;
  bool get syncInProgress => _syncInProgress;

  // Constructor with optional sync services
  CategoryProvider({SyncManager? syncManager, AuthService? authService})
      : _syncManager = syncManager,
        _authService = authService {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First populate with predefined categories
      _loadPredefinedCategories();

      // Then try to load any custom categories from storage
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('categories');

      if (categoriesJson != null) {
        try {
          final List<dynamic> decodedData = jsonDecode(categoriesJson);
          final loadedCategories =
              decodedData.map((item) => Category.fromJson(item)).toList();

          // Add only categories that don't exist yet (by name)
          for (final category in loadedCategories) {
            if (!_categories.any((c) => c.name == category.name)) {
              _categories.add(category);
            }
          }
          notifyListeners();
        } catch (e) {
          debugPrint('Error loading categories: $e');
        }
      }

      // Attempt to sync with cloud if authenticated
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        await syncWithCloud();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadPredefinedCategories() {
    _categories = AppTheme.predefinedCategories
        .map((category) => Category(
            name: category['name'] as String,
            color: category['color'] as Color))
        .toList();
  }

  Future<void> _saveCategories() async {
    // Save only custom categories (non-predefined ones)
    final predefinedCategoryNames = AppTheme.predefinedCategories
        .map((category) => category['name'] as String)
        .toSet();

    final customCategories = _categories
        .where((category) => !predefinedCategoryNames.contains(category.name))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = jsonEncode(
        customCategories.map((category) => category.toJson()).toList());
    await prefs.setString('categories', categoriesJson);
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
      notifyListeners();

      // First check if offline mode is enabled
      final isOffline = await _authService!.isOfflineModeEnabled();
      if (isOffline) {
        _syncInProgress = false;
        notifyListeners();
        return;
      }

      // Get categories from cloud
      final remoteCategories = await _syncManager!.fetchCategoriesFromCloud();

      // Merge with local categories (add if not exists)
      if (remoteCategories.isNotEmpty) {
        // Add remote categories that don't exist locally
        for (final remoteCategory in remoteCategories) {
          if (!_categories.any((c) => c.name == remoteCategory.name)) {
            _categories.add(remoteCategory);
          }
        }
        await _saveCategories();
      }

      // Push local categories to cloud
      await _syncManager!.syncCategoriesToCloud(_categories);
    } catch (e) {
      debugPrint('Error syncing categories with cloud: $e');
    } finally {
      _syncInProgress = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, Color color) async {
    final category = Category(name: name, color: color);

    // Only add if not already exists
    if (!_categories.any((c) => c.name == name)) {
      _categories.add(category);
      await _saveCategories();

      // Sync with cloud if possible
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        await _syncManager!.syncCategoriesToCloud([category]);
      }

      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    // Find the category by ID
    final category = _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => Category(name: '', color: Colors.transparent),
    );

    if (category.name.isEmpty) {
      return; // Category not found
    }

    // Don't allow deleting predefined categories
    final predefinedCategoryNames = AppTheme.predefinedCategories
        .map((category) => category['name'] as String)
        .toList();

    if (predefinedCategoryNames.contains(category.name)) {
      return;
    }
    _categories.removeWhere((category) => category.id == id);
    await _saveCategories();

    // Delete from cloud if possible
    if (_syncManager != null &&
        _authService != null &&
        _authService!.isLoggedIn) {
      final userId = _authService!.getUserId();
      if (userId != null) {
        await _syncManager!.deleteCategory(category.name);
      }
    }

    notifyListeners();
  }

  Future<void> updateCategory(String id, String newName, Color color) async {
    // Find the category by ID
    final category = _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => Category(name: '', color: Colors.transparent),
    );

    if (category.name.isEmpty) {
      return; // Category not found
    }

    final oldName = category.name;
    final index = _categories.indexWhere((category) => category.id == id);
    if (index != -1) {
      // Remove the old category
      _categories.removeAt(index);

      // Add the updated category
      final updatedCategory = Category(name: newName, color: color);
      _categories.add(updatedCategory);

      await _saveCategories();

      // Sync with cloud if possible
      if (_syncManager != null &&
          _authService != null &&
          _authService!.isLoggedIn) {
        // Delete old category name and add new one
        final userId = _authService!.getUserId();
        if (userId != null) {
          await _syncManager!.deleteCategory(oldName);
          await _syncManager!.syncCategoriesToCloud([updatedCategory]);
        }
      }

      notifyListeners();
    }
  }
}
