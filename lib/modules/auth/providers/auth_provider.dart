import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../../../shared/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? token;
  String? role;
  User?   user;

  bool get isLoggedIn => token != null;

  Future<void> loadFromStorage() async {
    token = await AuthService.getToken();
    role  = await AuthService.getRole();
    if (token != null) ApiService.setToken(token!);
    notifyListeners();
  }

  Future<void> login(String newToken, String newRole) async {
    await AuthService.saveToken(newToken);
    await AuthService.saveRole(newRole);
    token = newToken;
    role  = newRole;
    ApiService.setToken(newToken);
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      final json = await ApiService.get('/auth/me');
      user = User.fromJson(json);
      notifyListeners();
    } catch (e) {
      // handle silently
    }
  }

  Future<void> logout() async {
    await AuthService.clearAll();
    ApiService.clearToken();
    token = null;
    role  = null;
    user  = null;
    notifyListeners();
  }
}