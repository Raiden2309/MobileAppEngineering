import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../../../../../shared/styles/font_styles.dart';
import '../../../models/class_enrollment_model.dart';

class StudentProfileHeader extends StatelessWidget {
  final ClassStudentModel student;

  const StudentProfileHeader({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final burnout = student.burnoutIndex;
    final burnoutLabel = burnout > 0.7
        ? 'High Risk'
        : burnout > 0.4
        ? 'Moderate'
        : 'Stable';
    final burnoutColor = burnout > 0.7
        ? AppColors.red
        : burnout > 0.4
        ? AppColors.mikadoYellow
        : AppColors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.californiaBlue.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.californiaBlue, width: 2),
            ),
            child: Center(
              child: Text(
                student.initials,
                style: const TextStyle(
                  fontSize: FontStyles.titleGreeting,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: FontStyles.titleLarge,
                    fontWeight: FontStyles.weightHeavy,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined ${_formatDate(student.joinedAt)}',
                  style: const TextStyle(
                    fontSize: FontStyles.titleSmall,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: burnoutColor.withValues(alpha: 0.15),
                    borderRadius:
                    BorderRadius.circular(AppColors.glassBadgeBorderRadius),
                    border: Border.all(
                        color: burnoutColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        burnout > 0.7
                            ? Icons.local_fire_department_rounded
                            : burnout > 0.4
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        size: 12,
                        color: burnoutColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        burnoutLabel,
                        style: TextStyle(
                          fontSize: FontStyles.titleSmall,
                          fontWeight: FontStyles.weightMedium,
                          color: burnoutColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}