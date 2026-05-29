import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/styles/app_colors.dart';

class ClassStudentModel {
  // 1. Database Engine Data (from ClassEnrollmentModel)
  final String studentId;
  final String name;
  final double weeklyStudyHours;
  final double burnoutIndex;

  // 2. UI Display Data (calculated on the fly)
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'S';
  Color get chipColor => burnoutIndex > 0.7 ? AppColors.red : AppColors.green;
  String get meta => "Study Hours: $weeklyStudyHours";
  String get chip => burnoutIndex > 0.7 ? "At Risk" : "Stable";

  const ClassStudentModel({
    required this.studentId,
    required this.name,
    required this.weeklyStudyHours,
    required this.burnoutIndex,
  });

  factory ClassStudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ClassStudentModel(
      studentId: data['studentId'] ?? '',
      name: data['studentName'] ?? 'Student',
      weeklyStudyHours: (data['weeklyStudyHours'] as num?)?.toDouble() ?? 0.0,
      burnoutIndex: (data['burnoutIndex'] as num?)?.toDouble() ?? 0.0,
    );
  }
}