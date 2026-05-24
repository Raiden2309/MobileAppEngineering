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
}