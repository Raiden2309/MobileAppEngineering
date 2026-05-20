import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/classes/widgets/stat_box_classes.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class ClassCard extends StatelessWidget {
  // final String emoji;
  final String name;
  final String code;
  final String students;
  final String avgDone;
  final String atRisk;
  final Color atRiskColor;
  final Color accentColor;
  final String semester;

  const ClassCard({
    // required this.emoji,
    required this.name,
    required this.code,
    required this.students,
    required this.avgDone,
    required this.atRisk,
    required this.atRiskColor,
    required this.accentColor,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                // child: Center(
                //   child: Text(emoji, style: const TextStyle(fontSize: 17)),
                // ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: FontStyles.titleMedium,
                        fontWeight: FontStyles.weightHeavy,
                        color: AppColors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: FontStyles.titleTiny,
                        color: AppColors.black.withValues(alpha: 0.55),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: StatBox(
                    value: students,
                    label: 'Students',
                    valueColor: AppColors.californiaBlue,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: StatBox(
                    value: avgDone,
                    label: 'Avg Done',
                    valueColor: AppColors.mikadoYellow,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: StatBox(
                    value: atRisk,
                    label: 'At Risk',
                    valueColor: atRiskColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '📅 $semester',
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.black.withValues(alpha: 0.55),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'View class ›',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}