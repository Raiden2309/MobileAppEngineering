import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

class CompletionBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const CompletionBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.weightMedium,
              color: AppColors.black,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: FontStyles.titleSmall,
            fontWeight: FontStyles.weightHeavy,
            color: color,
          ),
        ),
      ],
    );
  }
}