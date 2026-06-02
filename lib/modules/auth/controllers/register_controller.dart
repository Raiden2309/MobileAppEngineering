import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Hides Firebase's AuthProvider to prevent naming clashes
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
// Imports Firestore for your database
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../../new_user_setup/views/role_setup.dart';
import '../services/google_sign_in_stub.dart';

class RegisterController {
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  // Make sure selectedRole is passed in from your UI
  Future<void> register(
      BuildContext context, {
        required int selectedRole,
        required VoidCallback onError,
      }) async {
    final email           = emailController.text.trim();
    final password        = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    emailError           = null;
    passwordError        = null;
    confirmPasswordError = null;


    if (email.isEmpty) emailError = 'Email is required';
    if (password.isEmpty) passwordError = 'Password is required';
    if (confirmPassword.isEmpty) confirmPasswordError = 'Please confirm your password';
    if (password.isNotEmpty && confirmPassword.isNotEmpty && password != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }
    if (emailError != null || passwordError != null || confirmPasswordError != null) {
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
        passwordError = 'The password provided is too weak. At least 6 characters.';
      } else {
        emailError = firebaseError.message ?? 'Registration failed.';
      }
      onError();
    } catch (e) {
      emailError = 'An unexpected error occurred. Please try again.';
      onError();
    }
  }

  Future<void> registerWithGoogle(BuildContext context, {required VoidCallback onError}) async {
    try {
      // Handshake calls the correct runtime file directly (Web popup vs Mobile credential)
      final UserCredential userCredential = await GoogleSignInService.authenticate();
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception("Failed to acquire Google profile properties.");

      if (!context.mounted) return;

      // Check if a structural account collection profile record exists for this account
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final auth = context.read<AuthProvider>();

      if (!userDoc.exists) {
        // First-time signup registration entry point creation logic
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'New User',
          'email': firebaseUser.email ?? '',
          'role': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await auth.login(0);

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSetupPage()),
        );
      } else {
        // Account exists — fetch profile data and skip selection layout
        final rawRole = userDoc.get('role');
        final int role = rawRole is int ? rawRole : int.tryParse(rawRole.toString()) ?? 0;

        await auth.login(role);

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSetupPage()),
        );
      }
    } catch (e) {
      debugPrint("Google Registration Interruption: $e");
      onError();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}