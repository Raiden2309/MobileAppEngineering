import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../../../../../shared/styles/font_styles.dart';

class StudentTaskCountTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const StudentTaskCountTile({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
        BorderRadius.circular(AppColors.glassIconBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
                fontSize: FontStyles.titleMedium,
                fontWeight: FontStyles.weightHeavy,
                color: color),
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: FontStyles.titleTiny, color: AppColors.black)),
        ],
      ),
    );
  }
}