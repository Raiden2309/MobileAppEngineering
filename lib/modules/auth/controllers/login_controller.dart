import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/role_setup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_service.dart';
import '../providers/auth_provider.dart';

class LoginController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  // ── Keys ────────────────────────────────────────────────
  static const _keyEmail    = 'cached_email';
  static const _keyPassword = 'cached_password';
  static const _keyToken    = 'cached_token';
  static const _keyRole     = 'cached_role';

  // ── Read local token (call this on app start) ────────────
  /// Returns the cached token+role, or null if not logged in.
  static Future<({String token, int role})?> readLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final role  = prefs.getInt(_keyRole);
    if (token == null || role == null) return null;
    return (token: token, role: role);
  }

  // ── Pre-fill saved credentials on the login page ─────────
  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email    = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);
    if (email    != null) emailController.text    = email;
    if (password != null) passwordController.text = password;
  }

  // ── Save credentials + session after successful login ────
  Future<void> _saveSession(String email, String password, String token, int role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail,    email);
    await prefs.setString(_keyPassword, password);
    await prefs.setString(_keyToken,    token);
    await prefs.setInt(_keyRole,     role);
  }

  // ── Wipe everything on logout ────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
  }

  // ── Login ────────────────────────────────────────────────
  Future<void> login(BuildContext context, {required VoidCallback onError}) async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    emailError    = null;
    passwordError = null;

    if (email.isEmpty) {
      emailError = 'Email is required';
      onError();
      return;
    }
    if (password.isEmpty) {
      passwordError = 'Password is required';
      onError();
      return;
    }

    try {
      final response = await ApiService.post('/auth/login', {
        'email':    email,
        'password': password,
      });

      final token = response['token'] as String;
      final role  = response['role']  as int;

      // cache locally
      await _saveSession(email, password, token, role);

      if (!context.mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.login(token, role);
      await auth.loadUser();

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSetupPage()),
      );
    } catch (e) {
      emailError    = 'Invalid credentials';
      passwordError = 'Invalid credentials';
      onError();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}