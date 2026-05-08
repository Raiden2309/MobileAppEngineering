import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/role_setup.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/api_service.dart';
import '../providers/auth_provider.dart';

class LoginController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

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
      final role  = response['role'] as String;

      if (!context.mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.login(token, role);
      await auth.loadUser(); // fetch and store user data in memory

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