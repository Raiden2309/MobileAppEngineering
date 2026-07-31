import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db;
  StudentProvider({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  StudentModel? student;
  SemesterModel? currentSemester;
  bool loading = false;
  String? error;

  Future<void> fetch(String uid) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        student = StudentModel.fromJson(doc.data()!);
        final semId = student!.currentSemesterId;
        if (semId != null) {
          final semDoc = await _db
              .collection('users')
              .doc(uid)
              .collection('semesters')
              .doc(semId)
              .get();
          if (semDoc.exists && semDoc.data() != null) {
            currentSemester = SemesterModel.fromJson(semDoc.data()!);
          }
        }
      }
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save(StudentModel model, SemesterModel semester) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final semId = 'sem_${semester.semester}_yr${semester.year}';
      final semWithId = SemesterModel(
        id: semId,
        semester: semester.semester,
        year: semester.year,
        semStart: semester.semStart,
        semEnd: semester.semEnd,
        subjects: semester.subjects,
      );

      final studentWithSemId = StudentModel(
        id: model.id,
        name: model.name,
        email: model.email,
        programme: model.programme,
        dayStart: model.dayStart,
        dayEnd: model.dayEnd,
        blockedSlots: model.blockedSlots,
        currentSemesterId: semId,
      );

      // Save top-level student document (global fields)
      await _db.collection('users').doc(model.id).set({
        ...studentWithSemId.toJson(),
        'uid': model.id,
        'role': 1,
        'setupCompleted': true,
        'study_hours_start': '${model.dayStart.hour}:${model.dayStart.minute}',
        'study_hours_end': '${model.dayEnd.hour}:${model.dayEnd.minute}',
        'blocked_slots': model.blockedSlots,
        'currentSemesterId': semId,
      });

      // Save semester as subcollection document
      await _db
          .collection('users')
          .doc(model.id)
          .collection('semesters')
          .doc(semId)
          .set(semWithId.toJson());

      student = studentWithSemId;
      currentSemester = semWithId;
    } catch (e) {
      error = e.toString();
      debugPrint('Error saving student: $e');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clear() {
    student = null;
    currentSemester = null;
    error = null;
    notifyListeners();
  }

  void reset() {
    student = null;
    currentSemester = null;
    error = null;
    loading = false;
    notifyListeners();
  }
}
