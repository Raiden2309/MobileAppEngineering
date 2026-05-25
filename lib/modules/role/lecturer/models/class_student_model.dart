import 'package:flutter/material.dart';

class ClassStudentModel {
  final String initials;
  final String name;
  final String meta;
  final String chip;
  final Color chipColor;

  const ClassStudentModel({
    required this.initials,
    required this.name,
    required this.meta,
    required this.chip,
    required this.chipColor,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      initials:  json['initials'] as String,
      name:      json['name'] as String,
      meta:      json['meta'] as String,
      chip:      json['chip'] as String,
      chipColor: Color(int.parse('FF${json['chip_color'] as String}', radix: 16)),
    );
  }

  ClassStudentModel copyWith({
    String? initials,
    String? name,
    String? meta,
    String? chip,
    Color? chipColor,
  }) =>
      ClassStudentModel(
        initials:  initials  ?? this.initials,
        name:      name      ?? this.name,
        meta:      meta      ?? this.meta,
        chip:      chip      ?? this.chip,
        chipColor: chipColor ?? this.chipColor,
      );
}