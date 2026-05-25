import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../providers/dashboard_provider.dart';

class WorkloadMonitor extends StatelessWidget {
  const WorkloadMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final workloadPlan = context.watch<DashboardProvider>().data?.workloadPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Workload Monitor',
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
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workloadPlan?.planLabel ?? "Today's Plan",
                style: const TextStyle(
                  fontSize: FontStyles.titleMedium,
                  fontWeight: FontStyles.titleWeight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                workloadPlan == null || workloadPlan.isEmpty
                    ? 'No tasks yet.'
                    : '${workloadPlan.tasks.length} tasks planned',
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.legendText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}