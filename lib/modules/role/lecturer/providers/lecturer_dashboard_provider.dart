import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/stat_card_model.dart'; // Ensure this import matches your repo file layout

class LecturerDashboardProvider with ChangeNotifier {
  String _lecturerName = 'Dr. Angela';
  String _greeting = 'Good Morning';
  String _subtitleText = 'Here is your update for today';
  String _dateLabel = 'Tuesday, May 26';
  int _atRiskCount = 3;

  String get lecturerName => _lecturerName;
  String get greeting => _greeting;
  String get subtitleText => _subtitleText;
  String get dateLabel => _dateLabel;
  int get atRiskCount => _atRiskCount;

  List<StatCardModel> get stats => [
    StatCardModel(
        label: 'Total Students',
        value: '72',
        sub: 'Enrolled',
        icon: Icons.people,
        accent: Colors.blue
    ),
    StatCardModel(
        label: 'At Risk',
        value: '$_atRiskCount',
        sub: 'Students',
        icon: Icons.warning,
        accent: Colors.red
    ),
    StatCardModel(
        label: 'Avg Attendance',
        value: '94%',
        sub: 'Class Rate',
        icon: Icons.check_circle,
        accent: Colors.green
    ),
  ];

  final List<ClassModel> classes = [
    ClassModel(
      id: "mock_1",
      lecturerId: "uid_1",
      name: "Mobile Application Engineering",
      code: "SE_LEVEL1_MAE",
      semester: "Semester 2",
      accentColor: const Color(0xFF4CAF50),
      studentCount: 28,
      avgCompletion: 74.0,
      atRiskCount: 3,
    ),
    ClassModel(
      id: "mock_2",
      lecturerId: "uid_1",
      name: "Human Computer Interaction",
      code: "SE_LEVEL1_HCI",
      semester: "Semester 2",
      accentColor: const Color(0xFF2196F3),
      studentCount: 24,
      avgCompletion: 88.0,
      atRiskCount: 0,
    ),
    ClassModel(
      id: "mock_3",
      lecturerId: "uid_1",
      name: "Object-Oriented Programming",
      code: "SE_LEVEL1_OOP",
      semester: "Semester 2",
      accentColor: const Color(0xFF9C27B0),
      studentCount: 20,
      avgCompletion: 61.0,
      atRiskCount: 5,
    ),
  ];

  void updateLecturerName(String name) {
    _lecturerName = name;
    notifyListeners();
  }

  void updateGreeting(String greeting) {
    _greeting = greeting;
    notifyListeners();
  }

  void updateDateLabel(String label) {
    _dateLabel = label;
    notifyListeners();
  }

  void updateAtRiskCount(int count) {
    _atRiskCount = count;
    notifyListeners();
  }
}