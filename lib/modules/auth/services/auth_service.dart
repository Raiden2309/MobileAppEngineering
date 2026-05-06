import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _setupKey = 'is_setup_complete';

  static const _roleKey = 'user_role';

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  // --- Auth ---
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- Setup ---
  static Future<void> completeSetup() async {
    await _storage.write(key: _setupKey, value: 'true');
  }

  static Future<bool> isSetupComplete() async {
    final value = await _storage.read(key: _setupKey);
    return value == 'true';
  }

  static Future<void> clearSetup() async {
    await _storage.delete(key: _setupKey);
  }

  // --- Logout (clears token but NOT setup) ---
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}