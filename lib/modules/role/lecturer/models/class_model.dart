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
    this.accentColor = const Color(0xff4F86C6),
    this.studentCount = 0,
    this.avgCompletion = 0.0,
    this.atRiskCount = 0,
  });

  /// Factory constructor required by ClassesProvider mapping pipelines
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
      accentColor: const Color(0xff4F86C6),
      studentCount: (data['studentCount'] as num? ?? 0).toInt(),
      avgCompletion: (data['avgCompletion'] as num? ?? 0.0).toDouble(),
      atRiskCount: (data['atRiskCount'] as num? ?? 0).toInt(),
    );
  }

  /// Map converter utility required by creation sub-forms
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subjectCode': subjectCode,
      'classCode': classCode,
      'semester': semester,
      'lecturerId': lecturerId,
      'studentCount': studentCount,
      'avgCompletion': avgCompletion,
      'atRiskCount': atRiskCount,
      'initialTasks': [],
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}