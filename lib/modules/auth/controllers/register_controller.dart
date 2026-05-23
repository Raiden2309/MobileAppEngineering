import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Hides Firebase's AuthProvider to prevent naming clashes
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
// Imports Firestore for your database
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../../new_user_setup/views/role_setup.dart';

class RegisterController {
  final nameController            = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  // Make sure selectedRole is passed in from your UI
  Future<void> register(
      BuildContext context, {
        required int selectedRole,
        required VoidCallback onError,
      }) async {
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
      // 1. Create the user in Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // 2. Save directly to Firestore (Notice: NO 'response' variables used here)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      // 3. Log them in locally using their new Firebase UID
      final auth = context.read<AuthProvider>();
      await auth.login(selectedRole);


      if (!context.mounted) return;

      // 4. Send them to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSetupPage()),
      );

    } on FirebaseAuthException catch (firebaseError) {
      if (firebaseError.code == 'email-already-in-use') {
        emailError = 'This email is already registered.';
      } else if (firebaseError.code == 'weak-password') {
        passwordError = 'The password provided is too weak.';
      } else {
        emailError = firebaseError.message ?? 'Registration failed.';
      }
      onError();
    } catch (e) {
      emailError = 'An unexpected error occurred. Please try again.';
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