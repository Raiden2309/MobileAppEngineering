import 'package:flutter/material.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../models/study_plan_model.dart';

class StudySchedule extends StatelessWidget {
  final DayPlan dayPlan;

  const StudySchedule({super.key, required this.dayPlan});

  @override
  Widget build(BuildContext context) {
    if (dayPlan.blocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 44,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No sessions planned for this day',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(dayPlan.blocks.length, (i) {
        return ScheduleRow(
          block: dayPlan.blocks[i],
          isLast: i == dayPlan.blocks.length - 1,
        );
      }),
    );
  }
}

class ScheduleRow extends StatelessWidget {
  final StudyBlock block;
  final bool isLast;

  const ScheduleRow({super.key, required this.block, required this.isLast});

  Color get dotColor {
    if (block.type == BlockType.blocked) return Colors.white30;
    if (block.type == BlockType.breakSlot) return AppColors.nectarine;
    switch (block.status) {
      case BlockStatus.completed:
        return AppColors.greenSheen;
      case BlockStatus.inProgress:
        return AppColors.californiaBlue;
      case BlockStatus.dueSoon:
        return AppColors.red;
      default:
        return Colors.white;
    }
  }

  String get subtitleText {
    final parts = <String>[];
    if (block.subject != null) parts.add(block.subject!);
    parts.add(block.durationLabel);
    final s = block.statusLabel;
    if (s.isNotEmpty) parts.add(s);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Text(
                block.startTime,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Timeline column
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 15),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (block.type != BlockType.blocked)
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 1.5,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BlockCard(
                block: block,
                accentColor: dotColor,
                subtitleText: subtitleText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlockCard extends StatelessWidget {
  final StudyBlock block;
  final Color accentColor;
  final String subtitleText;

  const BlockCard({super.key,
    required this.block,
    required this.accentColor,
    required this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = block.type == BlockType.blocked;

    return Container(
      // Use a fixed width for the bar (e.g., 4px) via gradient stops
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          // This creates a hard stop at the 4px mark
          stops: const [0.012, 0.012],
          colors: [accentColor, Colors.white],
        ),
      ),
      child: Padding(
        // Increase left padding to account for the "bar" space
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              block.title,
              style: TextStyle(
                color: isBlocked ? Colors.grey.shade500 : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitleText,
              style: TextStyle(
                color: isBlocked ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
