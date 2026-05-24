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
      // 1. Sign in with Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 2. Fetch Firestore user document
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        emailError = 'User profile not found in database.';
        onError();
        return;
      }

      // 3. Safely parse role (handles both int and string in Firestore)
      final rawRole = userDoc.get('role');
      final int role = rawRole is int
          ? rawRole
          : int.tryParse(rawRole.toString()) ?? 0;
      debugPrint('Role from Firestore: $role');

      // 4. Get auth token
      try {
        await AuthService.getToken();
      } catch (tokenError) {
        debugPrint('getToken failed: $tokenError');
        // Continue anyway — token failure shouldn't block login
      }

      if (!context.mounted) return;

      // 5. Update global auth state
      final auth = context.read<AuthProvider>();
      await auth.login(role);

      if (!context.mounted) return;

      // 6. Route based on role
      if (role == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSetupPage()),
        );
      } else if (role == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CentralStudentNavigation()),
        );
      } else if (role == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CentralLecturerNavigation()),
        );
      }

    } on FirebaseAuthException catch (firebaseError) {
      debugPrint('Firebase code: ${firebaseError.code}');
      debugPrint('Firebase message: ${firebaseError.message}');

      const invalidCodes = {
        'user-not-found',
        'wrong-password',
        'invalid-credential',
        'invalid-email',
        'internal-error',
        'network-request-failed',
      };

      if (invalidCodes.contains(firebaseError.code)) {
        emailError    = 'Invalid email or password.';
        passwordError = 'Invalid email or password.';
      } else {
        emailError = firebaseError.message ?? 'Authentication failed.';
      }
      onError();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}