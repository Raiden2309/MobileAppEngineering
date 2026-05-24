import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../providers/engagement_provider.dart';

class AvgCompletionCard extends StatelessWidget {
  const AvgCompletionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngagementProvider>();
    final pct = '${(provider.avgCompletion * 100).toInt()}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: provider.avgCompletion,
                  strokeWidth: 5,
                  backgroundColor: AppColors.greenSheen.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.greenSheen),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  pct,
                  style: TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightHeavy,
                    color: AppColors.greenSheen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avg Subject Completion',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.black.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pct,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.greenSheen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'tasks under your subjects · ${provider.totalStudents} students',
                style: TextStyle(
                  fontSize: FontStyles.titleTiny,
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}