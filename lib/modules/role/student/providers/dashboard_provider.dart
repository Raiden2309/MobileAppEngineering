import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../lecturer/models/class_student_model.dart';

class StudentDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  // Real-time stream tracking student modules from the enrollments collection
  Stream<List<ClassStudentModel>> get myEnrolledClassesStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    return _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ClassStudentModel.fromFirestore(doc))
        .toList());
  }

  // Placeholder fallback mock loader if requested by the views
  void loadMock() {}

  // Dummy data getter container preventing crashes inside legacy metrics sub-widgets
  dynamic get data => null;
}