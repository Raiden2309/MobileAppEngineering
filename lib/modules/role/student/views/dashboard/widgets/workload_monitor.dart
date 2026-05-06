import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class WorkloadMonitor extends StatelessWidget {
  const WorkloadMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          "Workload Monitor",
          style: TextStyle(
            fontSize: FontStyles.titleLarge,
            fontWeight: FontStyles.weightHeavy,
            color: AppColors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Today\'s Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontStyles.titleWeight),
              ),
              SizedBox(height: 8),
              Text(
                'No tasks yet.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
