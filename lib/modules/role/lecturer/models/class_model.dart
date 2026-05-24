import 'package:flutter/material.dart';

class ClassModel {
  final String name;
  final String code;
  final String semester;
  final int studentCount;
  final double avgCompletion;
  final int atRiskCount;
  final Color accentColor;

  const ClassModel({
    required this.name,
    required this.code,
    required this.semester,
    required this.studentCount,
    required this.avgCompletion,
    required this.atRiskCount,
    required this.accentColor,
  });

  ClassModel copyWith({
    String? name,
    String? code,
    String? semester,
    int? studentCount,
    double? avgCompletion,
    int? atRiskCount,
    Color? accentColor,
  }) =>
      ClassModel(
        name: name ?? this.name,
        code: code ?? this.code,
        semester: semester ?? this.semester,
        studentCount: studentCount ?? this.studentCount,
        avgCompletion: avgCompletion ?? this.avgCompletion,
        atRiskCount: atRiskCount ?? this.atRiskCount,
        accentColor: accentColor ?? this.accentColor,
      );
}