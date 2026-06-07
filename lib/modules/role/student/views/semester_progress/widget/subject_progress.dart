import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/semester_progress_model.dart';

class SubjectProgressCard extends StatelessWidget {
  final SubjectProgress subject;

  const SubjectProgressCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = subject.color;
    final pct = (subject.progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontStyles.weightMedium,
                    fontSize: FontStyles.titleMedium,
                  ),
                ),
              ),
              Text(
                subject.code,
                style: const TextStyle(
                  color: AppColors.legendText,
                  fontSize: FontStyles.titleSmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.black, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: subject.progress,
                      backgroundColor: Colors.white.withValues(alpha: AppColors.glassTileOpacity),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$pct%',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontStyles.weightHeavy,
                  fontSize: FontStyles.titleSmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              StatChip(
                value: subject.completed,
                label: 'Completed',
                valueColor: AppColors.lime,
              ),
              const SizedBox(width: 8),
              StatChip(
                value: subject.remaining,
                label: 'Remaining',
                valueColor: AppColors.mikadoYellow,
              ),
              const SizedBox(width: 8),
              StatChip(
                value: subject.dueSoon,
                label: 'Overdue',
                valueColor: subject.dueSoon > 0
                    ? AppColors.redDark
                    : AppColors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final int value;
  final String label;
  final Color valueColor;

  const StatChip({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: AppColors.glassTile(borderRadius: 10).copyWith(
          border: Border.all(color: AppColors.black),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: valueColor,
                fontWeight: FontStyles.weightHeavy,
                fontSize: FontStyles.titleLarge,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: FontStyles.titleTiny,
              ),
            ),
          ],
        ),
      ),
    );
  }
}