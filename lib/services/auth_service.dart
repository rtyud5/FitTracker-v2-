import 'package:firebase_core/firebase_core.dart';

import 'package:fittracker_source/core/session/session_store.dart';

import 'auth_gateway.dart';
import 'legacy_firestore_auth_gateway.dart';

class AuthResult {
  final bool isSuccess;
  final String? message;
  final String? userId;
  final String? username;
  final Map<String, dynamic>? userData;

  const AuthResult._({
    required this.isSuccess,
    this.message,
    this.userId,
    this.username,
    this.userData,
  });

  factory AuthResult.success({
    required String userId,
    required String username,
    required Map<String, dynamic> userData,
  }) {
    return AuthResult._(
      isSuccess: true,
      userId: userId,
      username: username,
      userData: userData,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}

class RegisterResult {
  final bool isSuccess;
  final String? message;
  final String? userId;
  final String? username;

  const RegisterResult._({
    required this.isSuccess,
    this.message,
    this.userId,
    this.username,
  });

  factory RegisterResult.success({required String userId, required String username}) {
    return RegisterResult._(isSuccess: true, userId: userId, username: username);
  }

  factory RegisterResult.failure(String message) {
    return RegisterResult._(isSuccess: false, message: message);
  }
}

class AuthService {
  AuthService._();

  static final AuthGateway _gateway = LegacyFirestoreAuthGateway();

  static Future<void> ensureFirebaseInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      await ensureFirebaseInitialized();
      final result = await _gateway.login(username: username, password: password);
      if (!result.isSuccess || result.userId == null || result.username == null || result.userData == null) {
        return AuthResult.failure(result.message ?? 'Login failed');
      }

      await SessionStore.saveAuthenticatedSession(
        userId: result.userId!,
        username: result.username!,
      );

      return AuthResult.success(
        userId: result.userId!,
        username: result.username!,
        userData: result.userData!,
      );
    } catch (e) {
      return AuthResult.failure('Login error: $e');
    }
  }

  static Future<RegisterResult> register({
    required String username,
    required String password,
    required Map<String, dynamic> localProfile,
  }) async {
    try {
      await ensureFirebaseInitialized();
      final result = await _gateway.register(
        username: username,
        password: password,
        localProfile: localProfile,
      );
      if (!result.isSuccess || result.userId == null || result.username == null) {
        return RegisterResult.failure(result.message ?? 'Registration failed');
      }

      // Save session so user is immediately authenticated after registration
      await SessionStore.saveAuthenticatedSession(
        userId: result.userId!,
        username: result.username!,
      );

      return RegisterResult.success(userId: result.userId!, username: result.username!);
    } catch (e) {
      return RegisterResult.failure('Registration failed: $e');
    }
  }

  static Future<void> logout({bool keepHasLoggedOnce = true}) async {
    await _gateway.logout();
    await SessionStore.clearSession(keepHasLoggedOnce: keepHasLoggedOnce);
  }
}
