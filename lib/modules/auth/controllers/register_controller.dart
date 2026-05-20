import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/api_service.dart';
import '../../new_user_setup/views/role_setup.dart';
import '../providers/auth_provider.dart';

class RegisterController {
  final nameController            = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  Future<void> register(BuildContext context, {required VoidCallback onError}) async {
    final name            = nameController.text.trim();
    final email           = emailController.text.trim();
    final password        = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    nameError            = null;
    emailError           = null;
    passwordError        = null;
    confirmPasswordError = null;

    if (name.isEmpty) {
      nameError = 'Name is required';
      onError();
      return;
    }
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
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
      onError();
      return;
    }
    if (password != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
      onError();
      return;
    }

    try {
      final response = await ApiService.post('/auth/register', {
        'name':     name,
        'email':    email,
        'password': password,
      });

      final token = response['token'] as String;
      final role  = response['role']  as int;

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
      emailError = 'Registration failed. Please try again.';
      onError();
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}