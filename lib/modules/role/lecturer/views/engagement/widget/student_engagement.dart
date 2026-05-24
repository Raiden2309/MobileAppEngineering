import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

import '../../../models/engagement_student_model.dart';

class StudentRow extends StatelessWidget {
  final EngagementStudentModel student;
  const StudentRow({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final bool isInactive = student.workload == 'Inactive';
    final chipColor = student.workloadColor ?? AppColors.black.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: chipColor.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                fontWeight: FontStyles.weightHeavy,
                color: chipColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightHeavy,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.meta,
                  style: const TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.legendText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: chipColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  student.workload,
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    fontWeight: FontStyles.weightHeavy,
                    color: chipColor,
                  ),
                ),
              ),
              if (!isInactive) ...[
                const SizedBox(height: 2),
                Text(
                  'Workload',
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}