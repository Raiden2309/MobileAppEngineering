import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85), // strong white bg
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'AT-RISK ALERTS',
                style: TextStyle(
                  fontSize: FontStyles.titleTiny,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.red,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '2 students showing burnout symptoms',
            style: TextStyle(
              fontSize: FontStyles.titleMedium,
              fontWeight: FontStyles.titleWeight,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Across CT124 System Proposal and Research Methods classes',
            style: TextStyle(
              fontSize: FontStyles.titleSmall,
              color: AppColors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Needs attention',
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    fontWeight: FontStyles.weightMedium,
                    color: AppColors.red,
                  ),
                ),
              ),
              const Text(
                'View alerts →',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.titleWeight,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}