import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class CurrentTaskPopup extends StatelessWidget {
  const CurrentTaskPopup({super.key});

  @override
  Widget build(BuildContext context) {
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
          Text('Current Task Reminder', style: TextStyle(fontSize: FontStyles.titleMedium, fontWeight: FontStyles.titleWeight)),
          const SizedBox(height: 8),
          const Text('No tasks yet.', style: TextStyle(fontSize: FontStyles.titleSmall, color: AppColors.legendText)),
        ],
      ),
    );
  }
}