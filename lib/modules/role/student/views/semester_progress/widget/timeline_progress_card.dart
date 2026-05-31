import 'package:flutter/material.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/semester_progress_model.dart';

class TimelineCard extends StatelessWidget {
  final SemesterProgressModel model;

  const TimelineCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIXED: Removed 'const' keyword to allow dynamic model strings
              Text(
                '${model.semesterName} Timeline',
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontStyles.weightMedium,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Week ${model.currentWeek} of ${model.totalWeeks}',
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: model.timelineProgress,
                    backgroundColor: Colors.white.withValues(alpha: AppColors.glassTileOpacity),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.lime,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(model.timelineProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontStyles.weightHeavy,
                  fontSize: FontStyles.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${model.weeksRemaining} weeks remaining · Final exams: ${model.finalExamDate}',
            style: TextStyle(color: AppColors.black, fontSize: FontStyles.titleSmall),
          ),
        ],
      ),
    );
  }
}