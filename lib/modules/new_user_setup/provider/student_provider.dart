import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StudentModel? student;
  bool loading = false;
  String? error;

  void loadMock() {
    student = const StudentModel(
      id: 'mock-001',
      name: 'Alex Johnson',
      email: 'alex@student.edu',
      programme: 'Diploma in Computer Science',
      semester: 2,
      year: 1,
      semStart: null,
      semEnd: null,
      dayStart: TimeOfDay(hour: 8, minute: 0),
      dayEnd: TimeOfDay(hour: 22, minute: 0),
      blockedSlots: ['0_0', '0_1', '1_0', '1_1', '2_2', '3_3'],
      subjects: [
        {'name': 'Mathematics', 'color': 'F87171'},
        {'name': 'Web Development', 'color': '60A5FA'},
        {'name': 'Database Systems', 'color': '34D399'},
        {'name': 'Networking', 'color': 'FBBF24'},
      ],
    );
    notifyListeners();
  }

  // ─── ADDED: THE SAVE METHOD EXPECTED BY YOUR SETUP WIZARD ───
  Future<void> save(StudentModel model) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // Update our local app state memory reference
      student = model;

      // Save the primary student profile document data into the global users collection
      await _db.collection('users').doc(model.id).set({
        'uid': model.id,
        'name': model.name,
        'email': model.email,
        'programme': model.programme,
        'semester': model.semester,
        'year': model.year,
        'semStart': model.semStart != null ? Timestamp.fromDate(model.semStart!) : null,
        'semEnd': model.semEnd != null ? Timestamp.fromDate(model.semEnd!) : null,
        'dayStart': '${model.dayStart.hour}:${model.dayStart.minute}',
        'dayEnd': '${model.dayEnd.hour}:${model.dayEnd.minute}',
        'blockedSlots': model.blockedSlots,
        'setupCompleted': true,
        'role': 'student',
      });

    } catch (e) {
      error = e.toString();
      debugPrint("Error storing student metadata: $e");
      rethrow; // Pass error up to the UI layout page to display alert snacks
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clear() {
    student = null;
    error = null;
    notifyListeners();
  }
}