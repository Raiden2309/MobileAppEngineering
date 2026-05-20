import 'package:flutter/cupertino.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class StudentRow extends StatelessWidget {
  final Map<String, dynamic> student;
  const StudentRow({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final Color? workloadColor = student['workloadColor'];
    final bool isInactive = student['workload'] == 'Inactive';
    final chipColor = workloadColor ?? AppColors.black.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar
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
              student['initials'],
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                fontWeight: FontStyles.weightHeavy,
                color: chipColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: const TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightHeavy,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student['meta'],
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.legendText,
                  ),
                ),
              ],
            ),
          ),

          // Workload chip
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: chipColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  student['workload'],
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