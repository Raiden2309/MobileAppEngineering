import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/burnout_alert_provider.dart'; // Ensure you import your live alert provider

class WorkloadMonitor extends StatelessWidget {
  final int pendingTasksCount;
  final double completionProgress;
  final double burnoutRatio;

  const WorkloadMonitor({
    super.key,
    this.pendingTasksCount = 0,
    this.completionProgress = 0.0,
    this.burnoutRatio = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Read current schedule task matching calendar slot parameters automatically
    final liveScheduledTask = context.watch<StudentDashboardProvider>().activeScheduleTask;

    // LINKED: Listen directly to the live burnout state metrics for unified reporting
    final burnoutProvider = context.watch<BurnoutAlertProvider>();
    final liveAlert = burnoutProvider.alert;

    // Pull the real mathematical percentage from our engine (e.g., 0.60 becomes 60%)
    final double displayProgress = liveAlert?.workloadProgress ?? 0.0;
    final String riskLabel = liveAlert?.workloadLevelLabel ?? 'Low';

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
                "Current Activity: $liveScheduledTask",
                style: const TextStyle(
                  fontSize: FontStyles.titleMedium,
                  fontWeight: FontStyles.titleWeight,
                  color: AppColors.californiaBlue,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress Made',
                        style: TextStyle(fontSize: 12, color: AppColors.legendText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(completionProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // UPDATED: Dynamic subtitle updates with status label names
                      Text(
                        '$riskLabel Risk',
                        style: const TextStyle(fontSize: 12, color: AppColors.legendText),
                      ),
                      const SizedBox(height: 2),
                      // UPDATED: Multiplies progress ratio cleanly into a percentage view representation
                      Text(
                        '${(displayProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.red),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remaining Tasks',
                        style: TextStyle(fontSize: 12, color: AppColors.legendText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$pendingTasksCount tasks left',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}