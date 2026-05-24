import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../models/class_model.dart';
import '../models/class_student_model.dart';

class ClassesProvider extends ChangeNotifier {
  final List<ClassModel> classes = const [
    ClassModel(
      name: 'CT124 System Proposal',
      code: 'CT124 · Diploma in Computer Science',
      semester: 'Sem 4 · Mar – Jul 2026',
      studentCount: 28,
      avgCompletion: 62,
      atRiskCount: 1,
      accentColor: AppColors.californiaBlue,
    ),
    ClassModel(
      name: 'Research Methods',
      code: 'RM302 · Diploma in Computer Science',
      semester: 'Sem 4 · Mar – Jul 2026',
      studentCount: 24,
      avgCompletion: 54,
      atRiskCount: 1,
      accentColor: AppColors.mikadoYellow,
    ),
    ClassModel(
      name: 'Mobile Development',
      code: 'MOB401 · Diploma in Computer Science',
      semester: 'Sem 4 · Mar – Jul 2026',
      studentCount: 20,
      avgCompletion: 59,
      atRiskCount: 0,
      accentColor: AppColors.softPurple,
    ),
  ];

  final Map<String, List<ClassStudentModel>> studentsByClass = {
    'CT124': [
      ClassStudentModel(initials: 'AH', name: 'Amirul Haikal',  meta: '7/11 tasks · 🔥 Burnout risk', chip: 'At Risk', chipColor: AppColors.red),
      ClassStudentModel(initials: 'AN', name: 'Ahmad Naqib',    meta: '11/11 tasks · All done',        chip: '100%',    chipColor: AppColors.californiaBlue),
      ClassStudentModel(initials: 'SP', name: 'Siti Putri',     meta: '10/11 tasks',                   chip: '91%',     chipColor: AppColors.californiaBlue),
      ClassStudentModel(initials: 'HZ', name: 'Haziq Zulkifli', meta: '4/11 tasks · 4 overdue',        chip: 'Behind',  chipColor: AppColors.mikadoYellow),
      ClassStudentModel(initials: 'RA', name: 'Raihana Azlan',  meta: '8/11 tasks',                    chip: '73%',     chipColor: AppColors.californiaBlue),
      ClassStudentModel(initials: 'FI', name: 'Farid Iskandar', meta: '6/11 tasks',                    chip: '55%',     chipColor: AppColors.mikadoYellow),
    ],
  };

  List<ClassStudentModel> getStudents(String classCode) {
    return studentsByClass[classCode] ?? [];
  }
}