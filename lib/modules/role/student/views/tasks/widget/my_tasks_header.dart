import 'package:flutter/material.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class MyTasksHeader extends StatelessWidget {
  final String completionSummary;

  const MyTasksHeader({super.key, required this.completionSummary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Tasks',
            style: TextStyle(
              fontSize: FontStyles.titleLarge,
              fontWeight: FontStyles.weightHeavy,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semester 4 · $completionSummary',
            style: const TextStyle(
              fontSize: FontStyles.titleSmall,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}