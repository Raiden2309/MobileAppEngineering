import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../models/engagement_student_model.dart';

class EngagementProvider extends ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'All Classes'}
  ];
  List<Map<String, String>> get filters => _filters;

  List<EngagementStudentModel> _students = [];
  List<EngagementStudentModel> get students => _students;

  bool isLoading = false;

  double _avgCompletion = 0.0;
  double get avgCompletion => _avgCompletion;

  int _totalStudents = 0;
  int get totalStudents => _totalStudents;

  StreamSubscription? _classesSubscription;
  StreamSubscription? _enrollmentsSubscription;

  EngagementProvider({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    initLiveEngagementStream();
  }

  /// DYNAMIC GETTER: Computes live status card aggregates from your filtered student subset
  Map<String, int> get workloadCounts {
    int high = 0;
    int medium = 0;
    int low = 0;

    for (var student in filteredStudents) {
      if (student.workload == 'High') high++;
      else if (student.workload == 'Medium') medium++;
      else if (student.workload == 'Low') low++;
    }

    return {
      'High': high,
      'Medium': medium,
      'Low': low,
    };
  }

  /// DYNAMIC GETTER: Calculates completion rates for progress bars indexed by unique subject codes
  Map<String, double> get subjectCompletions {
    final Map<String, List<double>> completionGroups = {};

    for (var doc in _students) {
      for (var classCode in doc.classes) {
        final RegExp regExp = RegExp(r'Burnout Index:\s*(\d+)%');
        final Match? match = regExp.firstMatch(doc.meta);

        if (match != null) {
          final double burnoutValue = double.tryParse(match.group(1) ?? '0') ?? 0.0;
          final double simulatedProgress = (100.0 - burnoutValue) / 100.0;

          completionGroups.putIfAbsent(classCode, () => []).add(simulatedProgress);
        }
      }
    }

    final Map<String, double> targetAverages = {};
    completionGroups.forEach((subjectKey, numericList) {
      if (numericList.isNotEmpty) {
        targetAverages[subjectKey] = numericList.reduce((valA, valB) => valA + valB) / numericList.length;
      }
    });

    return targetAverages;
  }

  void initLiveEngagementStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    _classesSubscription?.cancel();
    _classesSubscription = _db
        .collection('classes')
        .where('lecturerId', isEqualTo: user.uid)
        .snapshots()
        .listen((classesSnapshot) {

      final List<Map<String, String>> activeFilters = [
        {'key': 'all', 'label': 'All Classes'}
      ];
      final List<String> managedClassNames = [];

      for (var doc in classesSnapshot.docs) {
        final data = doc.data();
        final String name = data['name']?.toString() ?? '';
        final String code = (data['subjectCode'] ?? data['classCode'] ?? '').toString().toLowerCase();

        if (name.isNotEmpty && code.isNotEmpty) {
          managedClassNames.add(name);
          activeFilters.add({
            'key': code,
            'label': name,
          });
        }
      }

      _filters = activeFilters;

      if (managedClassNames.isEmpty) {
        _students = [];
        _avgCompletion = 0.0;
        _totalStudents = 0;
        isLoading = false;
        notifyListeners();
        return;
      }

      _enrollmentsSubscription?.cancel();
      _enrollmentsSubscription = _db
          .collection('enrollments')
          .where('classId', whereIn: managedClassNames)
          .snapshots()
          .listen((enrollmentSnapshot) {

        double totalProgressSum = 0.0;
        int dynamicStudentCount = 0;

        _students = enrollmentSnapshot.docs.map((doc) {
          final data = doc.data();
          final String sName = data['studentName']?.toString() ?? 'Student';
          final String classId = data['classId']?.toString() ?? 'General';
          final String subCode = (data['subjectCode'] ?? '').toString().toLowerCase();

          final double burnout = (data['burnoutIndex'] as num? ?? 0.0).toDouble();
          final int completed = (data['completedTasks'] as num? ?? 0).toInt();
          final int pending = (data['pendingTasks'] as num? ?? 0).toInt();

          final int combinedTasks = completed + pending;
          if (combinedTasks > 0) {
            totalProgressSum += (completed / combinedTasks);
            dynamicStudentCount++;
          }

          String workloadLabel = 'Low';
          Color workloadColor = AppColors.greenSheen;

          if (burnout >= 0.70 || pending > 3) {
            workloadLabel = 'High';
            workloadColor = AppColors.red;
          } else if (burnout >= 0.40 || pending > 1) {
            workloadLabel = 'Medium';
            workloadColor = AppColors.mikadoYellow;
          }

          return EngagementStudentModel(
            initials: sName.isNotEmpty ? sName[0].toUpperCase() : 'S',
            name: sName,
            meta: '$classId · Burnout Index: ${(burnout * 100).toStringAsFixed(0)}%',
            workload: workloadLabel,
            workloadColor: workloadColor,
            classes: [subCode],
          );
        }).toList();

        _totalStudents = enrollmentSnapshot.docs.length;
        _avgCompletion = dynamicStudentCount > 0 ? (totalProgressSum / dynamicStudentCount) : 0.0;

        isLoading = false;
        notifyListeners();
      });
    });
  }

  List<EngagementStudentModel> get filteredStudents {
    if (_selectedFilter == 'all') return _students;
    return _students.where((s) => s.classes.contains(_selectedFilter)).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  @override
  void dispose() {
    _classesSubscription?.cancel();
    _enrollmentsSubscription?.cancel();
    super.dispose();
  }
}