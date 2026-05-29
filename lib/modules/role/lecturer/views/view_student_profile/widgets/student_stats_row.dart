import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../models/class_enrollment_model.dart';
import 'student_section_label.dart';
import 'student_stat_tile.dart';

class StudentStatsRow extends StatelessWidget {
  final ClassStudentModel student;

  const StudentStatsRow({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final burnout = student.burnoutIndex;
    final burnoutColor = burnout > 0.7
        ? AppColors.red
        : burnout > 0.4
        ? AppColors.mikadoYellow
        : AppColors.green;
    final burnoutLabel = burnout > 0.7
        ? 'High Risk'
        : burnout > 0.4
        ? 'Moderate'
        : 'Stable';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudentSectionLabel('OVERVIEW'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StudentStatTile(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.californiaBlue,
                label: 'Study Hours',
                value: '${student.weeklyStudyHours.toStringAsFixed(1)}h',
                sub: 'This week',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StudentStatTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: burnoutColor,
                label: 'Burnout Index',
                value: '${(burnout * 100).toStringAsFixed(0)}%',
                sub: burnoutLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}