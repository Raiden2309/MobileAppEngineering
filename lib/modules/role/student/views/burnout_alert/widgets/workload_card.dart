import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/burnout_alert_model.dart';
import 'alert_theme.dart';

class WorkloadCard extends StatelessWidget {
  final BurnoutAlertModel alert;
  final AlertTheme theme;

  const WorkloadCard({super.key, required this.alert, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppColors.glassTile(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S WORKLOAD",
            style: TextStyle(
              fontSize: FontStyles.titleTiny,
              fontWeight: FontStyles.weightMedium,
              color: AppColors.white.withValues(alpha: 0.6),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          _WorkloadProgressBar(
            progress: alert.workloadProgress,
            gradient: theme.progressGradient,
          ),
          const SizedBox(height: 6),
          Text(
            '${alert.workloadLevelLabel} · ${alert.hoursStudied.toStringAsFixed(1)} hrs studied',
            style: TextStyle(
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.weightMedium,
              color: theme.levelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkloadProgressBar extends StatelessWidget {
  final double progress;
  final List<Color> gradient;

  const _WorkloadProgressBar({required this.progress, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            Container(color: AppColors.white.withValues(alpha: 0.1)),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}