import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassStudentModel {
  // --- UI Display Fields ---
  final String studentId;
  final String name;
  final String initials;
  final Color chipColor;

  // --- Data Analytics Fields (Mapped from Firestore) ---
  final DateTime joinedAt;
  final double weeklyStudyHours;
  final int completedTasks;
  final int pendingTasks;
  final double burnoutIndex;

  // --- Legacy UI Bridge Fields ---
  final String meta;
  final String chip;

  const ClassStudentModel({
    required this.studentId,
    required this.name,
    required this.initials,
    required this.chipColor,
    required this.joinedAt,
    required this.weeklyStudyHours,
    required this.completedTasks,
    required this.pendingTasks,
    required this.burnoutIndex,
    required this.meta,
    required this.chip,
  });

  factory ClassStudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Parse numeric fields
    double burnout = (data['burnoutIndex'] as num?)?.toDouble() ?? 0.0;
    double studyHours = (data['weeklyStudyHours'] as num?)?.toDouble() ?? 0.0;

    return ClassStudentModel(
      studentId: data['studentId'] ?? '',
      name: data['studentName'] ?? 'Student',
      initials: (data['studentName'] as String? ?? 'S')[0].toUpperCase(),
      chipColor: burnout > 0.7 ? Colors.red : Colors.green,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weeklyStudyHours: studyHours,
      completedTasks: (data['completedTasks'] as num?)?.toInt() ?? 0,
      pendingTasks: (data['pendingTasks'] as num?)?.toInt() ?? 0,
      burnoutIndex: burnout,

      // UI Bridge
      meta: "Study Hours: $studyHours",
      chip: burnout > 0.7 ? "At Risk" : "Stable",
    );
  }
}