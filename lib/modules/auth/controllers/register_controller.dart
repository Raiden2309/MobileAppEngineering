import 'package:flutter/material.dart';

class RegisterController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void register(BuildContext context, {required VoidCallback onError}) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    emailError = null;
    passwordError = null;
    confirmPasswordError = null;

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
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}