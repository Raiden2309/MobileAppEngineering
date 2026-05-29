import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../../../../../shared/styles/font_styles.dart';

class StudentBurnoutBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const StudentBurnoutBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: FontStyles.titleSmall, color: AppColors.black)),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.legendText.withAlpha(20),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}