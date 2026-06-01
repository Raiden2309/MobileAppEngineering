import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';
import '../../../models/dashboard_models.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isCheckedVisual = task.checked ||
        task.status == TaskStatus.completed ||
        task.status.name == 'completed' ||
        task.status.name == 'done';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCheckedVisual
                    ? AppColors.lime.withValues(alpha: AppColors.glassIconOpacity)
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.black, width: 2),
              ),
              child: isCheckedVisual
                  ? const Icon(Icons.check, color: AppColors.lime, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Fixed missing comma here
              children: [ // Fixed missing comma/syntax breaking point here
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: FontStyles.titleMedium,
                    fontWeight: FontStyles.weightMedium,
                    color: isCheckedVisual ? AppColors.legendText : AppColors.black,
                    decoration: isCheckedVisual ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.legendText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.legendText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusBadge(status: task.status),
        ],
      ),
    );
  }
}