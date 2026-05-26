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

  // 1. Alias Getter to match 'classes' view requirements
  List<ClassModel> get classes => availableClasses;

  // 2. Alias Method to support 'addClass' calls from create_class_sheet.dart
  Future<void> addClass(ClassModel newClass) async {
    await _db.collection('classes').doc(newClass.id).set(newClass.toFirestore());
    await fetchAllClasses();
  }

  // 3. Delete Class Method
  Future<void> deleteClass(ClassModel targetClass) async {
    await _db.collection('classes').doc(targetClass.id).delete();
    await fetchAllClasses();
  }

  // 4. Fetch All Classes
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

  // 5. Query Active Students matching a Course ID reference code
  Stream<List<ClassStudentModel>> getStudents(String classId) {
    return _db
        .collection('enrollments')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ClassStudentModel.fromFirestore(doc))
        .toList());
  }
}