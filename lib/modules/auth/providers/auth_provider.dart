import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider, User;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? token; // This now holds the Firebase UID
  int? role;
  User? user;

  bool get isLoggedIn => token != null;

  // ── Call this during app startup (e.g., in your Splash Screen) ──
  Future<void> loadFromStorage() async {
    token = await AuthService.getToken();
    role  = await AuthService.getRole();

    if (token != null) {
      // If a cached session exists, automatically load the full profile details
      await loadUser();
    }
    notifyListeners();
  }

  // ── Call this immediately after a successful login or registration ──
  Future<void> login(String newToken, int newRole) async {
    await AuthService.saveToken(newToken);
    await AuthService.saveRole(newRole);
    token = newToken;
    role  = newRole;
    notifyListeners();
  }

  // ── Migrated: Fetch user profile data directly from Cloud Firestore ──
  Future<void> loadUser() async {
    // Fallback security check: if there's no UID, we can't search the database
    final String? currentUid = token ?? FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) return;

    try {
      // Look up the specific user file matching their unique Firebase UID
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        // Map the Firestore JSON fields directly into your existing User model
        user = User.fromJson(userDoc.data() as Map<String, dynamic>);

        // Safety sync: Ensure our local app role variable matches what's in the DB
        role = user?.role;
        await AuthService.saveRole(role ?? 1);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading user profile from Firestore: $e");
    }
  }

  // ── Update User Role (Used during Role Setup) ──
  Future<void> updateUserRole(int newRole) async {
    final String? currentUid = token ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .update({'role': newRole});

      role = newRole;
      await AuthService.saveRole(newRole);
      await loadUser(); // Refresh the user object
    } catch (e) {
      debugPrint("Error updating user role: $e");
    }
  }

  // ── Logout ──
  Future<void> logout() async {
    // 1. Sign out of Google/Firebase auth sessions
    await FirebaseAuth.instance.signOut();

    // 2. Clear out all local encrypted device storage keys
    await AuthService.clearAll();

    // 3. Clear our current runtime memory state variables
    token = null;
    role  = null;
    user  = null;

    notifyListeners();
  }
}