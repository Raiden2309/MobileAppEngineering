import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String code;
  final String subjectCode;
  final String classCode;
  final String semester;
  final String lecturerId;
  final String joinCode;
  final Color accentColor;
  int studentCount;
  double avgCompletion;
  int atRiskCount;

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    this.subjectCode = '',
    this.classCode = '',
    this.semester = 'Semester 1',
    this.lecturerId = '',
    this.joinCode = '',
    this.accentColor = const Color(0xff4F86C6),
    this.studentCount = 0,
    this.avgCompletion = 0.0,
    this.atRiskCount = 0,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ClassModel(
      id: doc.id,
      name: data['name']?.toString() ?? 'Unknown Class',
      code: data['subjectCode']?.toString() ?? data['classCode']?.toString() ?? 'COMP000',
      subjectCode: data['subjectCode']?.toString() ?? '',
      classCode: data['classCode']?.toString() ?? '',
      semester: data['semester']?.toString() ?? 'Semester 1',
      lecturerId: data['lecturerId']?.toString() ?? '',
      joinCode: data['join_code']?.toString() ?? '',
      accentColor: const Color(0xff4F86C6),
      studentCount: (data['studentCount'] as num? ?? 0).toInt(),
      avgCompletion: (data['avgCompletion'] as num? ?? 0.0).toDouble(),
      atRiskCount: (data['atRiskCount'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subjectCode': subjectCode,
      'classCode': classCode,
      'semester': semester,
      'lecturerId': lecturerId,
      'join_code': joinCode,
      'accentColor': '0x${accentColor.value.toRadixString(16).toUpperCase()}',
      'studentCount': studentCount,
      'avgCompletion': avgCompletion,
      'atRiskCount': atRiskCount,
      'initialTasks': [],
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}