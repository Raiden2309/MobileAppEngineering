import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/classes_controller.dart';
import '../../../models/class_model.dart';
import 'stat_box_classes.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.onTap,
    this.onDelete,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete Class?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${classModel.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: Text('Delete', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = classModel;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null ? () => _confirmDelete(context) : null,
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
                if (onDelete != null)
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.red),
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