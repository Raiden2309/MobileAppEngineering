import 'package:flutter/material.dart';
import 'app_enums.dart';

class BurnoutAlertModel {
  final BurnoutAlertType type;
  final String title;
  final String description;
  final double hoursStudied;
  final double workloadProgress;
  final WorkloadLevel workloadLevel;
  final String primaryActionLabel;
  final String dismissLabel;

  const BurnoutAlertModel({
    required this.type,
    required this.title,
    required this.description,
    required this.hoursStudied,
    required this.workloadProgress,
    required this.workloadLevel,
    required this.primaryActionLabel,
    this.dismissLabel = 'Dismiss',
  });

  String get workloadLevelLabel {
    switch (workloadLevel) {
      case WorkloadLevel.low:      return 'Low';
      case WorkloadLevel.moderate: return 'Moderate';
      case WorkloadLevel.high:     return 'High';
      case WorkloadLevel.critical: return 'Critical';
    }
  }

  IconData get alertIcon {
    switch (type) {
      case BurnoutAlertType.burnout:  return Icons.local_fire_department;
      case BurnoutAlertType.allGood:  return Icons.check_circle_rounded;
      case BurnoutAlertType.warning:  return Icons.warning_amber_rounded;
      case BurnoutAlertType.overload: return Icons.crisis_alert_rounded;
    }
  }

  factory BurnoutAlertModel.fromJson(Map<String, dynamic> json) {
    return BurnoutAlertModel(
      type:               BurnoutAlertType.values.byName(json['type'] as String),
      title:              json['title'] as String,
      description:        json['description'] as String,
      hoursStudied:       (json['hours_studied'] as num).toDouble(),
      workloadProgress:   (json['workload_progress'] as num).toDouble(),
      workloadLevel:      WorkloadLevel.values.byName(json['workload_level'] as String),
      primaryActionLabel: json['primary_action_label'] as String,
      dismissLabel:       json['dismiss_label'] as String? ?? 'Dismiss',
    );
  }

  factory BurnoutAlertModel.burnoutPreset({double hoursStudied = 5.5}) =>
      BurnoutAlertModel(
        type:               BurnoutAlertType.burnout,
        title:              'Burnout Alert',
        description:        "You've been studying for 5+ hours today with few breaks, and your task completion has slowed down. Your body and mind need a rest.\n\nIt's recommended to take a longer break or stop studying for the day. Your plan will be adjusted for tomorrow.",
        hoursStudied:       hoursStudied,
        workloadProgress:   0.85,
        workloadLevel:      WorkloadLevel.high,
        primaryActionLabel: 'Take a break',
        dismissLabel:       'Dismiss warning',
      );

  factory BurnoutAlertModel.allGoodPreset({double hoursStudied = 1.5}) =>
      BurnoutAlertModel(
        type:               BurnoutAlertType.allGood,
        title:              "You're on Fire!",
        description:        "Great momentum today! You've completed your tasks efficiently and taken regular breaks. Keep up the excellent pace — your study plan is right on track.",
        hoursStudied:       hoursStudied,
        workloadProgress:   0.35,
        workloadLevel:      WorkloadLevel.low,
        primaryActionLabel: 'Keep going',
        dismissLabel:       'Got it',
      );

  factory BurnoutAlertModel.warningPreset({double hoursStudied = 3.5}) =>
      BurnoutAlertModel(
        type:               BurnoutAlertType.warning,
        title:              'Heads Up',
        description:        "You've been at it for a while. Your focus might start dipping soon. Consider taking a short 10–15 min break to recharge before continuing.",
        hoursStudied:       hoursStudied,
        workloadProgress:   0.60,
        workloadLevel:      WorkloadLevel.moderate,
        primaryActionLabel: 'Take a short break',
        dismissLabel:       'Continue studying',
      );

  factory BurnoutAlertModel.overloadPreset({double hoursStudied = 7.0}) =>
      BurnoutAlertModel(
        type:               BurnoutAlertType.overload,
        title:              'Overload Detected',
        description:        "You've pushed really hard today — way beyond your usual limit. Studying more now is likely counterproductive. Rest is part of learning. Call it a day.",
        hoursStudied:       hoursStudied,
        workloadProgress:   1.0,
        workloadLevel:      WorkloadLevel.critical,
        primaryActionLabel: 'Stop for today',
        dismissLabel:       'Ignore',
      );
}