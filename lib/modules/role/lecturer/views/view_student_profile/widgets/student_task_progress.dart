import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../../../../../shared/styles/font_styles.dart';
import '../../../models/class_enrollment_model.dart';
import 'student_section_label.dart';
import 'student_task_count_tile.dart';

class StudentTaskProgress extends StatelessWidget {
  final ClassStudentModel student;

  const StudentTaskProgress({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final totalTasks = student.completedTasks + student.pendingTasks;
    final progressPercent =
    totalTasks > 0 ? (student.completedTasks / totalTasks) : 0.0;
    final progressColor = progressPercent >= 0.7
        ? AppColors.green
        : progressPercent >= 0.4
        ? AppColors.mikadoYellow
        : AppColors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudentSectionLabel('TASK PROGRESS'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Completion',
                    style: TextStyle(
                        fontSize: FontStyles.titleMedium,
                        fontWeight: FontStyles.weightMedium,
                        color: AppColors.black),
                  ),
                  Text(
                    '${(progressPercent * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: FontStyles.titleMedium,
                        fontWeight: FontStyles.titleWeight,
                        color: AppColors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.legendText.withAlpha(20),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StudentTaskCountTile(
                      label: 'Completed',
                      count: student.completedTasks,
                      color: AppColors.green,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StudentTaskCountTile(
                      label: 'Pending',
                      count: student.pendingTasks,
                      color: AppColors.mikadoYellow,
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StudentTaskCountTile(
                      label: 'Total',
                      count: totalTasks,
                      color: AppColors.californiaBlue,
                      icon: Icons.list_alt_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}