import 'package:flutter_test/flutter_test.dart';
import 'package:smartapply_india/services/auth_service.dart';

void main() {
  group('AppUser', () {
    test('mock() creates user with default values', () {
      final user = AppUser.mock();
      expect(user.uid, startsWith('mock_'));
      expect(user.email, 'demo@smartapply.in');
      expect(user.displayName, 'Demo User');
      expect(user.phone, isNull);
      expect(user.bio, isNull);
    });

    test('mock() creates user with custom values', () {
      final user = AppUser.mock(email: 'test@example.com', name: 'Test');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test');
    });

    test('fromStorage() restores user from map', () {
      final data = {
        'uid': 'test_uid_123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'phone': '9876543210',
        'bio': 'A test bio',
        'photoUrl': null,
      };
      final user = AppUser.fromStorage(data);
      expect(user.uid, 'test_uid_123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.phone, '9876543210');
      expect(user.bio, 'A test bio');
    });

    test('copyWith() updates only specified fields', () {
      final user = AppUser.mock(email: 'a@b.com', name: 'OldName');
      final updated = user.copyWith(displayName: 'NewName', phone: '1234');
      expect(updated.displayName, 'NewName');
      expect(updated.phone, '1234');
      expect(updated.email, 'a@b.com'); // unchanged
      expect(updated.uid, user.uid); // unchanged
    });
  });

  group('AuthService (mock mode)', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      authService.init();
    });

    test('isMockMode is true when Firebase is not configured', () {
      // Firebase keys are empty in env.dart, so mock mode should be true
      expect(authService.isMockMode, isTrue);
    });

    test('signUpWithEmail returns mock user', () async {
      final user = await authService.signUpWithEmail(
        email: 'test@test.com',
        password: 'password123',
        displayName: 'Test User',
      );
      expect(user.email, 'test@test.com');
      expect(user.displayName, 'Test User');
      expect(authService.currentUser, isNotNull);
    });

    test('signInWithEmail returns mock user', () async {
      final user = await authService.signInWithEmail(
        email: 'login@test.com',
        password: 'password123',
      );
      expect(user.email, 'login@test.com');
      expect(authService.currentUser, isNotNull);
    });

    test('signInWithGoogle returns mock user', () async {
      final user = await authService.signInWithGoogle();
      expect(user.email, 'google@smartapply.in');
      expect(user.displayName, 'Google User');
    });

    test('signOut clears current user', () async {
      await authService.signUpWithEmail(
        email: 'test@test.com',
        password: 'pass',
        displayName: 'User',
      );
      expect(authService.currentUser, isNotNull);

      await authService.signOut();
      expect(authService.currentUser, isNull);
    });

    test('setMockUser sets and clears user', () {
      final user = AppUser.mock(email: 'set@test.com');
      authService.setMockUser(user);
      expect(authService.currentUser?.email, 'set@test.com');

      authService.setMockUser(null);
      expect(authService.currentUser, isNull);
    });
  });
}
