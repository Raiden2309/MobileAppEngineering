import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../providers/lecturer_dashboard_provider.dart';

class LecturerGreeting extends StatelessWidget {
  const LecturerGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerDashboardProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${provider.greeting}, ${provider.lecturerName} 👋',
          style: TextStyle(
            fontSize: FontStyles.titleLarge,
            fontWeight: FontStyles.weightHeavy,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          provider.subtitleText,
          style: TextStyle(
            fontSize: FontStyles.titleSmall,
            color: AppColors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: AppColors.glassBadge(),
          child: Text(
            provider.dateLabel,
            style: TextStyle(
              fontSize: FontStyles.titleTiny,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}