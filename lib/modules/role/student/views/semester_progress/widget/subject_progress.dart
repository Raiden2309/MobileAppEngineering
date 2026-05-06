import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                subject.code,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar row
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
                      backgroundColor: const Color(0xFFE5E7EB),
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
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              StatChip(
                value: subject.completed,
                label: 'Completed',
                valueColor: AppColors.greenSheenDark,
              ),
              const SizedBox(width: 8),
              StatChip(
                value: subject.remaining,
                label: 'Remaining',
                valueColor: AppColors.mikadoYellowDark,
              ),
              const SizedBox(width: 8),
              StatChip(
                value: subject.dueSoon,
                label: 'Due soon',
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

  const StatChip({super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}