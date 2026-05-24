import 'package:flutter/material.dart';

class StatCardModel {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;

  const StatCardModel({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accent,
  });

  StatCardModel copyWith({
    String? label,
    String? value,
    String? sub,
    IconData? icon,
    Color? accent,
  }) =>
      StatCardModel(
        label: label ?? this.label,
        value: value ?? this.value,
        sub: sub ?? this.sub,
        icon: icon ?? this.icon,
        accent: accent ?? this.accent,
      );
}