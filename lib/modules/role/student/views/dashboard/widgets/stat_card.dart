import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';

import '../../../../../../shared/styles/font_styles.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color accent;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: AppColors.glassCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontSize: FontStyles.titleSmall, color: AppColors.black),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: FontStyles.titleGreeting,
                          fontWeight: FontStyles.titleWeight,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        sub,
                        style: const TextStyle(fontSize: FontStyles.titleSmall, color: AppColors.black),
                      ),
                    ],
                  ),
                  Icon(icon, color: accent, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskStatisticsSection extends StatelessWidget {
  const TaskStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            "Tasks Statistics",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontStyles.weightHeavy,
              color: AppColors.black,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: StatCard(label: 'TASKS DONE', value: '10', sub: 'of 20 total',   accent: AppColors.black, icon: Icons.check)),
                  SizedBox(width: 12),
                  Expanded(child: StatCard(label: 'DUE SOON',   value: '3',  sub: 'within 3 days', accent: AppColors.black, icon: Icons.bolt)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: StatCard(label: 'OVERDUE', value: '1', sub: 'need attention', accent: AppColors.black, icon: Icons.warning_amber)),
                  SizedBox(width: 12),
                  Expanded(child: StatCard(label: 'WEEK',    value: '8', sub: 'of 14 in sem',  accent: AppColors.black, icon: Icons.calendar_month)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
