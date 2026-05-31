import 'package:flutter/material.dart';

class StudentModel {
  final String id;
  final String name;
  final String email;
  final String programme;
  final TimeOfDay dayStart;
  final TimeOfDay dayEnd;
  final List<String> blockedSlots;
  final String? currentSemesterId;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.programme,
    required this.dayStart,
    required this.dayEnd,
    required this.blockedSlots,
    this.currentSemesterId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    programme: json['programme'],
    dayStart: TimeOfDay(
      hour: json['dayStart']['hour'],
      minute: json['dayStart']['minute'],
    ),
    dayEnd: TimeOfDay(
      hour: json['dayEnd']['hour'],
      minute: json['dayEnd']['minute'],
    ),
    blockedSlots: List<String>.from(json['blockedSlots'] ?? []),
    currentSemesterId: json['currentSemesterId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'programme': programme,
    'dayStart': {'hour': dayStart.hour, 'minute': dayStart.minute},
    'dayEnd': {'hour': dayEnd.hour, 'minute': dayEnd.minute},
    'blockedSlots': blockedSlots,
    'currentSemesterId': currentSemesterId,
  };
}

class SemesterModel {
  final String id;
  final int semester;
  final int year;
  final DateTime? semStart;
  final DateTime? semEnd;
  final List<DateTime> examDates;
  final List<Map<String, String>> subjects;

  const SemesterModel({
    required this.id,
    required this.semester,
    required this.year,
    this.semStart,
    this.semEnd,
    this.examDates = const [],
    required this.subjects,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) => SemesterModel(
    id: json['id'],
    semester: json['semester'],
    year: json['year'],
    semStart: json['semStart'] != null ? DateTime.parse(json['semStart']) : null,
    semEnd: json['semEnd'] != null ? DateTime.parse(json['semEnd']) : null,
    examDates: (json['examDates'] as List<dynamic>? ?? [])
        .map((e) => DateTime.parse(e as String))
        .toList(),
    subjects: List<Map<String, String>>.from(
      (json['subjects'] as List? ?? []).map((s) => Map<String, String>.from(s)),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'semester': semester,
    'year': year,
    'semStart': semStart?.toIso8601String(),
    'semEnd': semEnd?.toIso8601String(),
    'examDates': examDates.map((d) => d.toIso8601String()).toList(),
    'subjects': subjects,
  };
}