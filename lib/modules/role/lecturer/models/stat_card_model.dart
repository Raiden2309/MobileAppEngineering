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
}