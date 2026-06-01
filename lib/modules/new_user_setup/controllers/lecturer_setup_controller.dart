import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../../modules/auth/services/auth_service.dart';
import '../../role/lecturer/views/central_lecturer_navigation.dart';
import '../provider/lecturer_provider.dart';

class LecturerSetupController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController subjectNameController = TextEditingController();

  String? _generatedJoinCode;
  String? get generatedJoinCode => _generatedJoinCode;

  bool _generating = false;
  bool get generating => _generating;

  final Map<String, String?> _errors = {};
  String? getError(String fieldKey) => _errors[fieldKey];

  void setGenerating(bool status) {
    _generating = status;
    notifyListeners();
  }

  /// Generates and assigns a clean 6-character uppercase class code
  String generateRandomClassCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excludes lookalikes (1, I, 0, O)
    final rand = Random.secure();
    _generatedJoinCode = List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
    notifyListeners();
    return _generatedJoinCode!;
  }

  bool validateAll() {
    _errors.clear();
    if (nameController.text.trim().isEmpty) {
      _errors['name'] = 'Lecturer name parameter cannot be empty';
    }
    if (subjectNameController.text.trim().isEmpty) {
      _errors['subjectName'] = 'Subject class title parameter cannot be empty';
    }
    notifyListeners();
    return _errors.isEmpty;
  }

  Future<void> completeSetup(BuildContext context) async {
    if (!validateAll()) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final String classDocId = _db.collection('classes').doc().id;
      final String finalClassCode = _generatedJoinCode ?? generateRandomClassCode();

      // 1. Unified account reference sync across user profiles
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': _auth.currentUser?.email,
        'name': nameController.text.trim(),
        'role': 2,
        'department': 'Computing',
        'createdAt': FieldValue.serverTimestamp(),
        'isSetupComplete': true,
      }, SetOptions(merge: true));

      // 2. Initialize the class with correct model properties to prevent view drops
      await _db.collection('classes').doc(classDocId).set({
        'id': classDocId,
        'name': subjectNameController.text.trim(),
        'section': 'Section 1',
        'subjectCode': subjectNameController.text.trim().split(' ').first.toUpperCase(),
        'classCode': finalClassCode,
        'semester': 'Semester 1',
        'lecturerId': uid,
        'studentCount': 0,
        'avgCompletion': 0.0,
        'atRiskCount': 0,
        'initialTasks': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await AuthService.completeSetup();
      await AuthService.saveRole(2);

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CentralLecturerNavigation()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Aborted setup database write sequence operation: $e");
    }
  }
}