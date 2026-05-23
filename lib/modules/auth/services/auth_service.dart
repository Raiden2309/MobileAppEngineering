import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const storage = FlutterSecureStorage();
  static const tokenKey = 'auth_token';
  static const setupKey = 'is_setup_complete';
  static const roleKey = 'user_role';

  // --- Role Management ---
  static Future<void> saveRole(int role) async {
    await storage.write(key: roleKey, value: role.toString());
  }

  static Future<int?> getRole() async {
    final value = await storage.read(key: roleKey);
    return value != null ? int.tryParse(value) : null;
  }

  // --- Firebase Auth ---
  static Future<bool> isLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }

  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Fetches and caches the Firebase ID token in secure storage.
  /// Set [forceRefresh] to true to always get a fresh token from Firebase.
  static Future<String?> getToken({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken(forceRefresh);
    if (token != null) await storage.write(key: tokenKey, value: token);
    return token;
  }

  /// Returns the cached token from secure storage without hitting Firebase.
  /// Useful for quick reads where a slightly stale token is acceptable.
  static Future<String?> getCachedToken() async {
    return await storage.read(key: tokenKey);
  }

  static Future<void> clearToken() async {
    await storage.delete(key: tokenKey);
  }

  // --- Setup Management ---
  static Future<void> completeSetup() async {
    await storage.write(key: setupKey, value: 'true');
  }

  static Future<bool> isSetupComplete() async {
    final value = await storage.read(key: setupKey);
    return value == 'true';
  }

  static Future<void> clearSetup() async {
    await storage.delete(key: setupKey);
  }

  // --- Logout (signs out of Firebase, clears token — keeps setup flag) ---
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await storage.delete(key: tokenKey);
  }

  static Future<void> clearAll() async {
    await FirebaseAuth.instance.signOut();
    await storage.delete(key: tokenKey);
    await storage.delete(key: roleKey);
    await storage.delete(key: setupKey);
  }
}