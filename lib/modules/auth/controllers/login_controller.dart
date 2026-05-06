import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/auth/controllers/test.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/role_setup.dart';

import '../services/auth_service.dart';


class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  Future<void> login(BuildContext context, {required VoidCallback onError}) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    emailError = null;
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

    if (email == testEmail && password == testPassword) {
      await AuthService.saveToken(testToken);
      await AuthService.saveRole('student');
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSetupPage()),
      );
    } else {
      emailError = 'Invalid credentials';
      passwordError = 'Invalid credentials';
      onError();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}