import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class LecturerGreeting extends StatelessWidget {
  const LecturerGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Dr. Lim 👋',
          style: TextStyle(
            fontSize: FontStyles.titleLarge,
            fontWeight: FontStyles.weightHeavy,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You have 2 at-risk student alerts today',
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
            '📅 Thursday, 26 March 2026',
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