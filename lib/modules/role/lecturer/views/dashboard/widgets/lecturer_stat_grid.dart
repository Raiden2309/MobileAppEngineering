import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class LecturerStatGrid extends StatelessWidget {
  const LecturerStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Overview',
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
                  Expanded(
                    child: _StatCard(
                      label: 'MY CLASSES',
                      value: '3',
                      sub: 'active this sem',
                      icon: Icons.class_outlined,
                      accent: AppColors.californiaBlue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'STUDENTS',
                      value: '72',
                      sub: 'across all classes',
                      icon: Icons.people_outline,
                      accent: AppColors.softPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: _StatCard(
                      label: 'AVG COMPLETION',
                      value: '58%',
                      sub: 'tasks this week',
                      icon: Icons.bar_chart_rounded,
                      accent: AppColors.mikadoYellow,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'AT RISK',
                      value: '2',
                      sub: 'burnout indicators',
                      icon: Icons.warning_amber,
                      accent: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: AppColors.glassCard(),
        child: Padding(
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
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      color: AppColors.black,
                    ),
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
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      color: AppColors.legendText,
                    ),
                  ),
                ],
              ),
              Icon(icon, color: accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}