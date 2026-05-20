import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const storage = FlutterSecureStorage();
  static const tokenKey = 'auth_token';
  static const setupKey = 'is_setup_complete';
  static const roleKey = 'user_role';

  static Future<void> saveRole(int role) async {
    await storage.write(key: roleKey, value: role.toString());
  }

  static Future<int?> getRole() async {
    // final value = await storage.read(key: roleKey);
    // return value != null ? int.tryParse(value) : null;
    return 2; // placeholder
  }

  // --- Auth ---
  static Future<void> saveToken(String token) async {
    await storage.write(key: tokenKey, value: token);
  }

  static Future<bool> isLoggedIn() async {
    final token = await storage.read(key: tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() async {
    return await storage.read(key: tokenKey);
  }

  static Future<void> clearToken() async {
    await storage.delete(key: tokenKey);
  }

  // --- Setup ---
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

  // --- Logout (clears token but NOT setup) ---
  static Future<void> logout() async {
    await storage.delete(key: tokenKey);
  }

  static Future<void> clearAll() async {
    await storage.delete(key: tokenKey);
    await storage.delete(key: roleKey);
    await storage.delete(key: setupKey);
  }
}