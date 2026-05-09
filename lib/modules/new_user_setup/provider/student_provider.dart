import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';
import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
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

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/student/profile');
      student = StudentModel.fromJson(data);
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save(StudentModel model) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await ApiService.post('/student/profile', model.toJson());
      student = model;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void setStudent(StudentModel model) {
    student = model;
    notifyListeners();
  }

  void clear() {
    student = null;
    error = null;
    notifyListeners();
  }
}