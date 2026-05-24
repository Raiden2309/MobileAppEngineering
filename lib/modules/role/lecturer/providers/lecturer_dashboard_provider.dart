import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../models/class_model.dart';
import '../models/stat_card_model.dart';

class LecturerDashboardProvider extends ChangeNotifier {
  String _lecturerName = 'Dr. Lim';
  String _greeting = 'Good morning';
  String _dateLabel = '📅 Thursday, 26 March 2026';
  int _atRiskCount = 2;

  String get lecturerName => _lecturerName;
  String get greeting => _greeting;
  String get dateLabel => _dateLabel;
  int get atRiskCount => _atRiskCount;
  String get subtitleText => 'You have $_atRiskCount at-risk student alerts today';

  final List<StatCardModel> stats = const [
    StatCardModel(
      label: 'MY CLASSES',
      value: '3',
      sub: 'active this sem',
      icon: Icons.class_outlined,
      accent: AppColors.californiaBlue,
    ),
    StatCardModel(
      label: 'STUDENTS',
      value: '72',
      sub: 'across all classes',
      icon: Icons.people_outline,
      accent: AppColors.softPurple,
    ),
    StatCardModel(
      label: 'AVG COMPLETION',
      value: '58%',
      sub: 'tasks this week',
      icon: Icons.bar_chart_rounded,
      accent: AppColors.mikadoYellow,
    ),
    StatCardModel(
      label: 'AT RISK',
      value: '2',
      sub: 'burnout indicators',
      icon: Icons.warning_amber,
      accent: AppColors.red,
    ),
  ];

  final List<ClassModel> classes = const [
    ClassModel(
      name: 'CT124 System Proposal',
      code: 'CT124 · Diploma in Computer Science',
      semester: 'Sem 4 · Mar – Jul 2026',
      studentCount: 28,
      avgCompletion: 62,
      atRiskCount: 1,
      accentColor: AppColors.californiaBlue,
    ),
    ClassModel(
      name: 'Research Methods',
      code: 'RM302 · Diploma in Computer Science',
      semester: 'Sem 4 · Mar – Jul 2026',
      studentCount: 24,
      avgCompletion: 54,
      atRiskCount: 1,
      accentColor: AppColors.mikadoYellow,
    ),
    ClassModel(
      name: 'Mobile Development',
      code: 'MOB401 · Diploma in Computer Science',
      semester: 'Sem 4 · Mar – Jul 2026',
      studentCount: 20,
      avgCompletion: 59,
      atRiskCount: 0,
      accentColor: AppColors.softPurple,
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