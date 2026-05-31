import 'package:flutter/material.dart';

class AlertModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String time;
  final String emoji;
  final String meta;
  final String studentId;
  final String studentName;
  final String className;
  final double burnoutIndex;
  final String riskLevel;
  final bool read;
  final DateTime timestamp;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.emoji = '⚠️',
    this.meta = 'Urgent Review Needed',
    this.studentId = '',
    this.studentName = '',
    this.className = '',
    this.burnoutIndex = 0.0,
    this.riskLevel = '',
    this.read = false,
    required this.timestamp,
  });

  /// CopyWith modifier required by AlertProvider unread switch updates
  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? time,
    String? emoji,
    String? meta,
    String? studentId,
    String? studentName,
    String? className,
    double? burnoutIndex,
    String? riskLevel,
    bool? read,
    DateTime? timestamp,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      emoji: emoji ?? this.emoji,
      meta: meta ?? this.meta,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      className: className ?? this.className,
      burnoutIndex: burnoutIndex ?? this.burnoutIndex,
      riskLevel: riskLevel ?? this.riskLevel,
      read: read ?? this.read,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}