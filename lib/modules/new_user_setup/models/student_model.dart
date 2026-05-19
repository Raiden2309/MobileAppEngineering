import 'package:flutter/material.dart';

class StudentModel {
  final String id;
  final String name;
  final String email;
  final String programme;
  final int semester;
  final int year;
  final DateTime? semStart;
  final DateTime? semEnd;
  final TimeOfDay dayStart;
  final TimeOfDay dayEnd;
  final List<String> blockedSlots;
  final List<Map<String, String>> subjects;
  final List<DateTime> examDates;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.programme,
    required this.semester,
    required this.year,
    this.semStart,
    this.semEnd,
    required this.dayStart,
    required this.dayEnd,
    required this.blockedSlots,
    required this.subjects,
    this.examDates = const [],
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    programme: json['programme'],
    semester: json['semester'],
    year: json['year'],
    semStart: json['semStart'] != null ? DateTime.parse(json['semStart']) : null,
    semEnd: json['semEnd'] != null ? DateTime.parse(json['semEnd']) : null,
    dayStart: TimeOfDay(
      hour: json['dayStart']['hour'],
      minute: json['dayStart']['minute'],
    ),
    dayEnd: TimeOfDay(
      hour: json['dayEnd']['hour'],
      minute: json['dayEnd']['minute'],
    ),
    blockedSlots: List<String>.from(json['blockedSlots']),
    subjects: List<Map<String, String>>.from(
      json['subjects'].map((s) => Map<String, String>.from(s)),
    ),
    examDates: (json['examDates'] as List<dynamic>? ?? [])
        .map((e) => DateTime.parse(e as String))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'programme': programme,
    'semester': semester,
    'year': year,
    'semStart': semStart?.toIso8601String(),
    'semEnd': semEnd?.toIso8601String(),
    'dayStart': {'hour': dayStart.hour, 'minute': dayStart.minute},
    'dayEnd': {'hour': dayEnd.hour, 'minute': dayEnd.minute},
    'blockedSlots': blockedSlots,
    'subjects': subjects,
    'examDates': examDates.map((d) => d.toIso8601String()).toList(),
  };
}