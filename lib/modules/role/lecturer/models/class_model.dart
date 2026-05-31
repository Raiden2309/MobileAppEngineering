import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassModel {
  final String id;
  final String lecturerId;
  final String name;
  final String code;
  final String semester;
  final String joinCode;
  final Color accentColor;

  final int studentCount;
  final double avgCompletion;
  final int atRiskCount;

  ClassModel({
    required this.id,
    required this.lecturerId,
    required this.name,
    required this.code,
    required this.semester,
    required this.accentColor,
    this.joinCode = '',   // ← added
    this.studentCount = 0,
    this.avgCompletion = 0.0,
    this.atRiskCount = 0,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    String colorStr = data['accentColor'] ?? '0xFF4CAF50';
    int colorValue = int.tryParse(colorStr) ?? 0xFF4CAF50;

    return ClassModel(
      id: doc.id,
      lecturerId: data['lecturerId'] ?? '',
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      semester: data['semester'] ?? '',
      joinCode: data['join_code'] ?? '',
      accentColor: Color(colorValue),
      studentCount: data['studentCount'] ?? 0,
      avgCompletion: (data['avgCompletion'] as num?)?.toDouble() ?? 0.0,
      atRiskCount: data['atRiskCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lecturerId': lecturerId,
      'name': name,
      'code': code,
      'semester': semester,
      'join_code': joinCode,  // ← added
      'accentColor': '0x${accentColor.value.toRadixString(16).toUpperCase()}',
      'studentCount': studentCount,
      'avgCompletion': avgCompletion,
      'atRiskCount': atRiskCount,
    };
  }
}