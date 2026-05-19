import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> register(BuildContext context, {required VoidCallback onError}) async {
    // Clear errors
    nameError = null;
    emailError = null;
    passwordError = null;
    confirmPasswordError = null;
    onError();

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Local check before sending to database
    if (password != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
      onError();
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If successful, take them back to the login page
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      emailError = e.message;
      onError();
    }
  }
}