import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/role_setup.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/central_lecturer_navigation.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/central_student_navigation.dart';

import '../services/auth_service.dart';

class LoginController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  // ── Login Flow ───────────────────────────────────────────
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
      // 1. Authenticate the email and password with Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 2. Fetch the user's role profile document directly from Cloud Firestore
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        emailError = 'User profile data not found in database.';
        onError();
        return;
      }

      // Grab the exact numerical role (1 = student, 2 = lecturer)
      final int role = (userDoc.get('role') as int?) ?? 0;
      debugPrint("Role from Firestore: $role");

      await AuthService.getToken();

      if (!context.mounted) return;

      // 4. Update state globally using AuthProvider
      final auth = context.read<AuthProvider>();
      await auth.login(role);


      if (!context.mounted) return;

      // 5. Smart Routing based on registration status or role
      if (role == 0) {
        // Fallback safety flow if they registered via Google but bypassed role picking
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSetupPage()),
        );
      } else if (role == 1) {
        // ROUTE DIRECTLY TO STUDENT WORKSPACE
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CentralStudentNavigation()),
        );
      } else if (role == 2) {
        // ROUTE DIRECTLY TO LECTURER WORKSPACE
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CentralLecturerNavigation()),
        );
      }

    } on FirebaseAuthException catch (firebaseError) {
      // Handle login-specific errors gracefully without crashing
      if (firebaseError.code == 'user-not-found' || firebaseError.code == 'wrong-password' || firebaseError.code == 'invalid-credential') {
        emailError    = 'Invalid email or password.';
        passwordError = 'Invalid email or password.';
      } else {
        emailError = firebaseError.message ?? 'Authentication failed.';
      }
      onError();
    } catch (e) {
      emailError = 'An unexpected server error occurred.';
      onError();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}