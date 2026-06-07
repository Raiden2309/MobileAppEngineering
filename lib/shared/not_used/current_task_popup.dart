import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../styles/app_colors.dart';
import '../styles/font_styles.dart';
import '../../modules/role/student/providers/dashboard_provider.dart';

class CurrentTaskPopup extends StatelessWidget {
  const CurrentTaskPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTask = context.watch<StudentDashboardProvider>().data?.currentTask;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Task Reminder',
            style: TextStyle(
              fontSize: FontStyles.titleMedium,
              fontWeight: FontStyles.titleWeight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentTask != null ? currentTask.title : 'No tasks yet.',
            style: const TextStyle(
              fontSize: FontStyles.titleSmall,
              color: AppColors.legendText,
            ),
          ),
          if (currentTask != null) ...[
            const SizedBox(height: 4),
            Text(
              currentTask.subtitle,
              style: const TextStyle(
                fontSize: FontStyles.titleSmall,
                color: AppColors.legendText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}