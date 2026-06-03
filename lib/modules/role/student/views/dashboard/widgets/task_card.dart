import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';
import '../../../models/dashboard_models.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onToggle;
  final bool isLoading;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.isLoading = false,
  });

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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.black, width: 2),
              ),
              child: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(4),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.californiaBlue,
                ),
              )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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