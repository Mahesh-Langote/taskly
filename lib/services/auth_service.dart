import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  // Firebase instances that will only be used when not in offline mode
  FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;

  // Current user
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // Offline mode flag
  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  // Constructor to initialize the user
  AuthService({bool isOfflineMode = false}) {
    _isOfflineMode = isOfflineMode;

    // Only initialize Firebase services if NOT in offline mode
    if (!_isOfflineMode) {
      try {
        _firebaseAuth = FirebaseAuth.instance;
        _googleSignIn = GoogleSignIn();
        _initUser();
      } catch (e) {
        debugPrint('Error creating Firebase Auth: $e');
        _isOfflineMode = true;
      }
    }

    _loadOfflineMode();
  }

  // Initialize user from Firebase Auth
  void _initUser() {
    if (!_isOfflineMode && _firebaseAuth != null) {
      try {
        _user = _firebaseAuth!.currentUser;

        // Listen for auth state changes
        _firebaseAuth!.authStateChanges().listen((User? user) {
          _user = user;
          notifyListeners();
        });
      } catch (e) {
        debugPrint('Error initializing auth: $e');
        // Set to offline mode if there's an auth error
        _isOfflineMode = true;
      }
    }
    notifyListeners();
  }

  // Load offline mode preference
  Future<void> _loadOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOfflineMode = prefs.getBool('isOfflineMode') ?? false;

      // If the saved preference is offline OR we're forcing offline due to initialization error
      _isOfflineMode = savedOfflineMode || _isOfflineMode;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Set offline mode
  Future<void> setOfflineMode(bool value) async {
    _isOfflineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOfflineMode', value);
    notifyListeners();
  }

  // Get current user ID
  String? getUserId() {
    if (_isOfflineMode) {
      return 'local-user';
    }
    return _user?.uid;
  }

  // Email and password sign up
  Future<User?> signUpWithEmail(String email, String password) async {
    if (_isOfflineMode || _firebaseAuth == null) {
      throw Exception('Cannot sign up in offline mode');
    }

    try {
      final UserCredential result =
          await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      rethrow;
    }
  }

  // Email and password sign in
  Future<User?> signInWithEmail(String email, String password) async {
    if (_isOfflineMode || _firebaseAuth == null) {
      throw Exception('Cannot sign in in offline mode');
    }

    try {
      final UserCredential result =
          await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  // Google sign in
  Future<User?> signInWithGoogle() async {
    if (_isOfflineMode || _firebaseAuth == null || _googleSignIn == null) {
      throw Exception('Cannot sign in in offline mode');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create the credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result =
          await _firebaseAuth!.signInWithCredential(credential);
      _user = result.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    // If in offline mode, just toggle offline mode off
    if (_isOfflineMode) {
      await setOfflineMode(false);
      return;
    }

    try {
      if (_googleSignIn != null) await _googleSignIn!.signOut();
      if (_firebaseAuth != null) await _firebaseAuth!.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    if (_isOfflineMode || _firebaseAuth == null) {
      throw Exception('Cannot reset password in offline mode');
    }

    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (_isOfflineMode || _user == null || _firebaseAuth == null) {
      throw Exception('Cannot update profile in offline mode');
    }

    try {
      await _user!.updateDisplayName(displayName);
      await _user!.updatePhotoURL(photoURL);

      // Reload user to get updated info
      await _user!.reload();
      _user = _firebaseAuth!.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Check if offline mode is enabled
  Future<bool> isOfflineModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isOfflineMode') ?? false;
    } catch (e) {
      debugPrint('Error checking offline mode: $e');
      return false;
    }
  }
}
