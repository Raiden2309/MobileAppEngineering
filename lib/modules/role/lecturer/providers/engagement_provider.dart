import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../models/engagement_student_model.dart';

class EngagementProvider extends ChangeNotifier {
  String _selectedFilter = 'all';

  String get selectedFilter => _selectedFilter;

  final List<Map<String, String>> filters = const [
    {'key': 'all', 'label': 'All Classes'},
    {'key': 'ct124', 'label': 'CT124'},
    {'key': 'rm302', 'label': 'RM302'},
    {'key': 'mob401', 'label': 'MOB401'},
  ];

  final List<EngagementStudentModel> students = [
    EngagementStudentModel(
      initials: 'AH',
      name: 'Amirul Haikal',
      meta: 'CT124 · Last active: today',
      workload: 'High',
      workloadColor: AppColors.red,
      classes: ['ct124'],
    ),
    EngagementStudentModel(
      initials: 'AN',
      name: 'Ahmad Naqib',
      meta: 'CT124 · Last active: today',
      workload: 'Low',
      workloadColor: AppColors.greenSheen,
      classes: ['ct124'],
    ),
    EngagementStudentModel(
      initials: 'HZ',
      name: 'Haziq Zulkifli',
      meta: 'CT124 · Last active: 3 days ago',
      workload: 'Medium',
      workloadColor: AppColors.mikadoYellow,
      classes: ['ct124'],
    ),
    EngagementStudentModel(
      initials: 'FI',
      name: 'Farid Iskandar',
      meta: 'RM302 · Last active: 5 days ago',
      workload: 'Inactive',
      workloadColor: null,
      classes: ['rm302'],
    ),
  ];

  final double avgCompletion = 0.58;
  final int totalStudents = 72;

  List<EngagementStudentModel> get filteredStudents {
    if (_selectedFilter == 'all') return students;
    return students
        .where((s) => s.classes.contains(_selectedFilter))
        .toList();
  }

  void setFilter(String key) {
    _selectedFilter = key;
    notifyListeners();
  }
}