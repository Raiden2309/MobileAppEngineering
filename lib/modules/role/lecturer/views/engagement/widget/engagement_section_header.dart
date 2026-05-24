import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

class EngagementSectionHeader extends StatelessWidget {
  final String title;
  const EngagementSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: FontStyles.titleMedium,
        fontWeight: FontStyles.weightHeavy,
        color: AppColors.black,
      ),
    );
  }
}