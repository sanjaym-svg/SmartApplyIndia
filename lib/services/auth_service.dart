import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../core/config/env.dart';

/// Unified user model for both mock and Firebase auth
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phone;
  final String? bio;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phone,
    this.bio,
  });

  factory AppUser.fromFirebase(fb.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
      photoUrl: user.photoURL,
    );
  }

  factory AppUser.mock({String? email, String? name}) {
    return AppUser(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email ?? 'demo@smartapply.in',
      displayName: name ?? 'Demo User',
    );
  }

  /// Restore user from locally saved session data
  factory AppUser.fromStorage(Map<String, String?> data) {
    return AppUser(
      uid: data['uid'] ?? 'stored_user',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'User',
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      bio: data['bio'],
    );
  }

  /// Create a copy with updated fields
  AppUser copyWith({
    String? displayName,
    String? phone,
    String? bio,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
    );
  }
}

/// Auth service that wraps Firebase Auth with mock fallback.
/// Uses Firebase GoogleAuthProvider signInWithPopup for Google sign-in on web.
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  fb.FirebaseAuth? _firebaseAuth;
  AppUser? _mockUser;

  void init() {
    if (!Env.isMockMode && Env.isFirebaseConfigured) {
      _firebaseAuth = fb.FirebaseAuth.instance;
    }
  }

  bool get isMockMode => Env.isMockMode;

  AppUser? get currentUser {
    if (isMockMode) return _mockUser;
    final fbUser = _firebaseAuth?.currentUser;
    return fbUser != null ? AppUser.fromFirebase(fbUser) : null;
  }

  /// Set mock user directly (used for restoring sessions)
  void setMockUser(AppUser? user) {
    if (isMockMode) {
      _mockUser = user;
    }
  }

  Stream<AppUser?> get authStateChanges {
    if (isMockMode) {
      return Stream.value(_mockUser);
    }
    return _firebaseAuth!.authStateChanges().map(
          (user) => user != null ? AppUser.fromFirebase(user) : null,
        );
  }

  // ─── Email/Password Sign Up ────────────────────────────
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (isMockMode) {
      _mockUser = AppUser.mock(email: email, name: displayName);
      return _mockUser!;
    }

    final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    return AppUser.fromFirebase(credential.user!);
  }

  // ─── Email/Password Sign In ────────────────────────────
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (isMockMode) {
      _mockUser = AppUser.mock(email: email);
      return _mockUser!;
    }

    final credential = await _firebaseAuth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser.fromFirebase(credential.user!);
  }

  // ─── Google Sign In (Firebase Auth popup for Web) ──────
  Future<AppUser> signInWithGoogle() async {
    if (isMockMode) {
      _mockUser = AppUser.mock(
        email: 'google@smartapply.in',
        name: 'Google User',
      );
      return _mockUser!;
    }

    // Uses Firebase Auth's built-in GoogleAuthProvider
    // On web, this opens a popup for Google sign-in
    final provider = fb.GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    final userCredential =
        await _firebaseAuth!.signInWithPopup(provider);
    return AppUser.fromFirebase(userCredential.user!);
  }

  // ─── Sign Out ──────────────────────────────────────────
  Future<void> signOut() async {
    if (isMockMode) {
      _mockUser = null;
      return;
    }
    await _firebaseAuth!.signOut();
  }
}
