import 'package:flutter/material.dart';

class EngagementStudentModel {
  final String initials;
  final String name;
  final String meta;
  final String workload;
  final Color? workloadColor;
  final List<String> classes;

  const EngagementStudentModel({
    required this.initials,
    required this.name,
    required this.meta,
    required this.workload,
    required this.classes,
    this.workloadColor,
  });

  factory EngagementStudentModel.fromJson(Map<String, dynamic> json) {
    return EngagementStudentModel(
      initials:      json['initials'] as String,
      name:          json['name'] as String,
      meta:          json['meta'] as String,
      workload:      json['workload'] as String,
      workloadColor: json['workload_color'] != null
          ? Color(int.parse('FF${json['workload_color'] as String}', radix: 16))
          : null,
      classes: List<String>.from(json['classes'] as List),
    );
  }

  EngagementStudentModel copyWith({
    String? initials,
    String? name,
    String? meta,
    String? workload,
    Color? workloadColor,
    List<String>? classes,
  }) =>
      EngagementStudentModel(
        initials:      initials      ?? this.initials,
        name:          name          ?? this.name,
        meta:          meta          ?? this.meta,
        workload:      workload      ?? this.workload,
        workloadColor: workloadColor ?? this.workloadColor,
        classes:       classes       ?? this.classes,
      );
}