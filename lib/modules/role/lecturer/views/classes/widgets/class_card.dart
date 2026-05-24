import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/classes_controller.dart';
import '../../../models/class_model.dart';
import 'stat_box_classes.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = classModel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
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
                        c.code,
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
                  Expanded(child: StatBox(value: ClassesController.studentsLabel(c), label: 'Students', valueColor: AppColors.californiaBlue)),
                  const SizedBox(width: 6),
                  Expanded(child: StatBox(value: ClassesController.avgDoneLabel(c),  label: 'Avg Done', valueColor: AppColors.mikadoYellow)),
                  const SizedBox(width: 6),
                  Expanded(child: StatBox(value: ClassesController.atRiskLabel(c),   label: 'At Risk',  valueColor: ClassesController.atRiskColor(c))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '📅 ${c.semester}',
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
                    color: c.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}