import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../models/class_model.dart';
import '../views/classes/class_detail_page.dart';

class ClassesController {
  static String studentsMeta(ClassModel c) =>
      '${c.studentCount} students · ${c.avgCompletion.toStringAsFixed(0)}% avg completion';

  static String studentsLabel(ClassModel c) => '${c.studentCount}';

  static String avgDoneLabel(ClassModel c) =>
      '${c.avgCompletion.toStringAsFixed(0)}%';

  static String atRiskLabel(ClassModel c) => '${c.atRiskCount}';

  static Color atRiskColor(ClassModel c) =>
      c.atRiskCount > 0 ? AppColors.red : AppColors.greenSheen;

  static void openClass(BuildContext context, ClassModel c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClassDetailPage(classModel: c)),
    );
  }
}