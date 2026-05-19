import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const storage = FlutterSecureStorage();
  static const setupKey = 'is_setup_complete';
  static const roleKey = 'user_role';

  // --- Role Management (Kept local for fast UI checks) ---
  static Future<void> saveRole(String role) async {
    await storage.write(key: roleKey, value: role);
  }

  static Future<String?> getRole() async {
    return await storage.read(key: roleKey);
  }

  // --- Firebase Auth ---
  static Future<bool> isLoggedIn() async {
    // Check if Firebase currently has a logged-in user
    return FirebaseAuth.instance.currentUser != null;
  }

  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
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

  // --- Logout ---
  static Future<void> logout() async {
    // Sign out of Firebase
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> clearAll() async {
    await FirebaseAuth.instance.signOut();
    await storage.delete(key: roleKey);
    await storage.delete(key: setupKey);
  }
}