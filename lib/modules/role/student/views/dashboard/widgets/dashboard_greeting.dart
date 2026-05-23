import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/student_dashboard_controller.dart';

class DashboardGreeting extends StatelessWidget {
  final StudentDashboardController controller;
  const DashboardGreeting({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Text(
            'Good Morning, ${controller.userName}',
            style: const TextStyle(fontSize: FontStyles.titleGreeting, fontWeight: FontStyles.titleWeight, color: AppColors.black, letterSpacing: 0.5, height: 1),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            'You have ${controller.amountOfTasks} tasks scheduled for today',
            style: const TextStyle(fontSize: FontStyles.titleMedium, color: AppColors.black, letterSpacing: 0.5, height: 2),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, color: AppColors.black, size: 18),
              const SizedBox(width: 8),
              Text(controller.getFormattedDate(), style: const TextStyle(color: Colors.black, fontSize: FontStyles.titleMedium, fontWeight: FontStyles.weightMedium)),
            ],
          ),
        ),
      ],
    );
  }
}