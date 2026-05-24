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

  EngagementStudentModel copyWith({
    String? initials,
    String? name,
    String? meta,
    String? workload,
    Color? workloadColor,
    List<String>? classes,
  }) =>
      EngagementStudentModel(
        initials: initials ?? this.initials,
        name: name ?? this.name,
        meta: meta ?? this.meta,
        workload: workload ?? this.workload,
        workloadColor: workloadColor ?? this.workloadColor,
        classes: classes ?? this.classes,
      );
}