import 'package:flutter/material.dart';
import 'class_enrollment_model.dart';

class ClassModel {
  final String name;
  final String code;
  final String semester;
  final int studentCount;
  final double avgCompletion;
  final int atRiskCount;
  final Color accentColor;
  final List<ClassEnrollmentModel> enrollments;

  const ClassModel({
    required this.name,
    required this.code,
    required this.semester,
    required this.studentCount,
    required this.avgCompletion,
    required this.atRiskCount,
    required this.accentColor,
    this.enrollments = const [],
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      name:          json['name'] as String,
      code:          json['code'] as String,
      semester:      json['semester'] as String,
      studentCount:  json['student_count'] as int,
      avgCompletion: (json['avg_completion'] as num).toDouble(),
      atRiskCount:   json['at_risk_count'] as int,
      accentColor:   Color(int.parse('FF${json['accent_color'] as String}', radix: 16)),
      enrollments: (json['enrollments'] as List<dynamic>? ?? [])
          .map((e) => ClassEnrollmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ClassModel copyWith({
    String? name,
    String? code,
    String? semester,
    int? studentCount,
    double? avgCompletion,
    int? atRiskCount,
    Color? accentColor,
    List<ClassEnrollmentModel>? enrollments,
  }) =>
      ClassModel(
        name:          name          ?? this.name,
        code:          code          ?? this.code,
        semester:      semester      ?? this.semester,
        studentCount:  studentCount  ?? this.studentCount,
        avgCompletion: avgCompletion ?? this.avgCompletion,
        atRiskCount:   atRiskCount   ?? this.atRiskCount,
        accentColor:   accentColor   ?? this.accentColor,
        enrollments:   enrollments   ?? this.enrollments,
      );
}