import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> login(BuildContext context, {required VoidCallback onError}) async {
    // Clear previous errors
    emailError = null;
    passwordError = null;
    onError(); // Tells the screen to rebuild and hide errors

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      emailError = 'Email cannot be empty';
      onError();
      return;
    }
    if (password.isEmpty) {
      passwordError = 'Password cannot be empty';
      onError();
      return;
    }

    try {
      // Connect to Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Note: We don't need to navigate here manually because your
      // AuthProvider is listening to Firebase and will switch screens automatically!
    } on FirebaseAuthException catch (e) {
      // Show specific Firebase errors on the UI
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        emailError = 'Invalid email or user not found';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        passwordError = 'Incorrect password';
      } else {
        passwordError = e.message;
      }
      onError(); // Tell the screen to show the new error text
    }
  }
}