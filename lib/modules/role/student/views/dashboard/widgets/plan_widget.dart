import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/study_plan_model.dart';

class TimeGapIndicator extends StatelessWidget {
  final StudyBlock fromBlock;
  final StudyBlock toBlock;

  const TimeGapIndicator({
    super.key,
    required this.fromBlock,
    required this.toBlock,
  });

  int get _gapMinutes {
    try {
      final endParts = fromBlock.endTime.split(':');
      final startParts = toBlock.startTime.split(':');
      final now = DateTime.now();
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      return start.difference(end).inMinutes;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gap = _gapMinutes;
    if (gap <= 0) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Container(width: 1, height: 14, color: AppColors.black),
          const SizedBox(width: 10),
          Text(
            '${gap}min break',
            style: const TextStyle(
              color: AppColors.legendText,
              fontSize: FontStyles.titleTiny,
            ),
          ),
        ],
      ),
    );
  }
}

class PlanEmptyState extends StatelessWidget {
  const PlanEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.wb_sunny_rounded, color: AppColors.black, size: 32),
            SizedBox(height: 10),
            Text(
              'No study blocks scheduled today',
              style: TextStyle(
                color: AppColors.black,
                fontSize: FontStyles.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
