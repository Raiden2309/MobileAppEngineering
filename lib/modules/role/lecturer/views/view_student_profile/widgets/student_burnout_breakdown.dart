import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../models/class_enrollment_model.dart';
import 'student_section_label.dart';
import 'student_burnout_bar.dart';

class StudentBurnoutBreakdown extends StatelessWidget {
  final ClassStudentModel student;

  const StudentBurnoutBreakdown({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final burnout = student.burnoutIndex;
    final burnoutColor = burnout > 0.7
        ? AppColors.red
        : burnout > 0.4
        ? AppColors.mikadoYellow
        : AppColors.green;
    final totalTasks = student.completedTasks + student.pendingTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudentSectionLabel('BURNOUT BREAKDOWN'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              StudentBurnoutBar(
                label: 'Burnout Index',
                value: burnout,
                color: burnoutColor,
              ),
              const SizedBox(height: 12),
              StudentBurnoutBar(
                label: 'Task Load',
                value: totalTasks > 0 ? student.pendingTasks / totalTasks : 0,
                color: AppColors.mikadoYellow,
              ),
              const SizedBox(height: 12),
              StudentBurnoutBar(
                label: 'Study Hours Load',
                value: (student.weeklyStudyHours / 40).clamp(0, 1),
                color: AppColors.californiaBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}