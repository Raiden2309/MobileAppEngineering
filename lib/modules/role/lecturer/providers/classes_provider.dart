import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/class_model.dart';
import '../models/class_student_model.dart';

class ClassesProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ClassModel> availableClasses = [];
  bool isLoading = false;

  List<ClassModel> get classes => availableClasses;

  Future<void> addClass(ClassModel newClass) async {
    await _db.collection('classes').doc(newClass.id).set(newClass.toFirestore());
    await fetchAllClasses();
  }

  Future<void> deleteClass(ClassModel targetClass) async {
    await _db.collection('classes').doc(targetClass.id).delete();
    await fetchAllClasses();
  }

  Future<void> fetchAllClasses() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('classes').get();
      availableClasses = snapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Error gathering classes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ClassStudentModel>> getStudents(String classId) {
    return _db
        .collection('enrollments')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ClassStudentModel.fromFirestore(doc))
        .toList());
  }

  // --- Student Integration Interface Queries ---
  Future<List<ClassModel>> getAllAvailableClasses() async {
    try {
      final snapshot = await _db.collection('classes').get();
      return snapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all classes for student browse: $e");
      return [];
    }
  }

  Future<void> enrollInClass(ClassModel targetClass, {String semester = ''}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final enrollmentId = "${uid}_${targetClass.id}";

    await _db.collection('enrollments').doc(enrollmentId).set({
      'studentId': uid,
      'classId': targetClass.id,
      'studentName': _auth.currentUser?.displayName ?? 'Edwin Chin',
      'joinedAt': FieldValue.serverTimestamp(),
      'weeklyStudyHours': 0.0,
      'completedTasks': 0,
      'pendingTasks': 0,
      'burnoutIndex': 0.0,
      'semester': semester,
    });

    notifyListeners();
  }
}