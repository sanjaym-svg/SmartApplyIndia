import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

/// ChangeNotifier-based auth state management with persistent sessions
class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storage = StorageService();

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isMockMode => _authService.isMockMode;

  AuthState() {
    _init();
  }

  void _init() {
    _authService.init();

    // Restore saved session from local storage
    _restoreSession();

    // Listen to auth changes (only for Firebase mode)
    if (!_authService.isMockMode) {
      _authService.authStateChanges.listen((user) {
        _user = user;
        notifyListeners();
      });
    }
  }

  /// Restore user session from SharedPreferences
  void _restoreSession() {
    if (!_storage.isReady) return;

    if (_storage.isLoggedIn) {
      final userData = _storage.loadUser();
      if (userData.isNotEmpty && userData['uid'] != null) {
        _user = AppUser.fromStorage(userData);
        // Also set the mock user in AuthService so currentUser works
        _authService.setMockUser(_user);
        notifyListeners();
      }
    }
  }

  /// Save user session to SharedPreferences
  Future<void> _persistUser(AppUser user) async {
    await _storage.saveUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phone: user.phone,
      bio: user.bio,
      photoUrl: user.photoUrl,
    );
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      await _supabaseService.syncUser(_user!);
      await _persistUser(_user!);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      await _supabaseService.syncUser(_user!);
      await _persistUser(_user!);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signInWithGoogle();
      await _supabaseService.syncUser(_user!);
      await _persistUser(_user!);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile fields
  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? bio,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      displayName: displayName,
      phone: phone,
      bio: bio,
    );
    _authService.setMockUser(_user);
    await _persistUser(_user!);
    await _supabaseService.syncUser(_user!);
    notifyListeners();
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      await _storage.clearUser();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    print('Auth Error: $msg');
    if (msg.contains('user-not-found')) return 'No account found with this email';
    if (msg.contains('wrong-password')) return 'Incorrect password';
    if (msg.contains('email-already-in-use')) return 'Email already registered';
    if (msg.contains('weak-password')) return 'Password is too weak';
    if (msg.contains('invalid-email')) return 'Invalid email address';
    if (msg.contains('cancelled')) return 'Sign-in was cancelled';
    if (msg.contains('network')) return 'Network error. Check your connection';
    if (msg.contains('invalid-credential')) return 'Invalid credentials. Check your email/password.';
    
    // Better fallback mapping:
    if (msg.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    if (msg.contains('operation-not-allowed')) return 'Login method not enabled in Firebase. Check console.';
    if (msg.contains('API key not valid')) return 'Firebase API key is invalid. Check env.dart.';
    
    final stripped = msg.replaceFirst(RegExp(r'^\[.*?\]\s*'), ''); // Return exact error without the plugin prefix
    return stripped.trim() == 'Error' ? msg : stripped;
  }
}
