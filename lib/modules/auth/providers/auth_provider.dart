import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider, User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? uid;
  int?    role;
  User?   user;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ── Call this during app startup (e.g., in your Splash Screen) ──
  Future<void> loadFromStorage() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    uid  = firebaseUser.uid;
    role = await AuthService.getRole();

    await loadUser();
    notifyListeners();
  }

  // ── Call this immediately after a successful login or registration ──
  Future<void> login(int newRole) async {
    uid  = FirebaseAuth.instance.currentUser?.uid;
    role = newRole;
    await AuthService.saveRole(newRole);
    await loadUser();
    notifyListeners();
  }

  // ── Fetch user profile data from Cloud Firestore ──
  Future<void> loadUser() async {
    final String? currentUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        user = User.fromJson(userDoc.data() as Map<String, dynamic>);

        // Sync role from Firestore as source of truth
        role = user?.role ?? 0;
        if (role != null) await AuthService.saveRole(role!);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading user profile from Firestore: $e");
    }
  }

  // ── Update User Role (Used during Role Setup) ──
  Future<void> updateUserRole(int newRole) async {
    final String? currentUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .update({'role': newRole});

      role = newRole;
      await AuthService.saveRole(newRole);
      await loadUser();
    } catch (e) {
      debugPrint("Error updating user role: $e");
    }
  }

  Future<void> logout() async {
    await AuthService.clearAll();

    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    uid  = null;
    role = null;
    user = null;

    notifyListeners();
  }
}