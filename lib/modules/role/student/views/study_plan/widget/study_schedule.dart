import 'package:flutter/material.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
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
                color: AppColors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No sessions planned for this day',
                style: TextStyle(
                  color: AppColors.legendText,
                  fontSize: FontStyles.titleSmall,
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

// ── ScheduleRow ───────────────────────────────────────────

class ScheduleRow extends StatelessWidget {
  final StudyBlock block;
  final bool isLast;

  const ScheduleRow({super.key, required this.block, required this.isLast});

  Color get dotColor {
    if (block.type == BlockType.blocked) return AppColors.legendText;
    if (block.type == BlockType.breakSlot) return AppColors.nectarine;
    switch (block.status) {
      case BlockStatus.completed:
        return AppColors.greenSheen;
      case BlockStatus.inProgress:
        return AppColors.californiaBlue;
      case BlockStatus.dueSoon:
        return AppColors.red;
      default:
        return AppColors.white;
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
          // ── Time label ─────────────────────────────
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Text(
                block.startTime,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.legendText,
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Timeline column ────────────────────────
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
                        color: AppColors.white.withValues(alpha: AppColors.glassDividerOpacity),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ── Block card ─────────────────────────────
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

// ── BlockCard ─────────────────────────────────────────────

class BlockCard extends StatelessWidget {
  final StudyBlock block;
  final Color accentColor;
  final String subtitleText;

  const BlockCard({
    super.key,
    required this.block,
    required this.accentColor,
    required this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = block.type == BlockType.blocked;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.glassTileBorderRadius),
        border: Border.all(
          color: AppColors.white.withValues(alpha: AppColors.glassBorderOpacity),
        ),
        gradient: LinearGradient(
          stops: const [0.02, 0.02],
          colors: [
            accentColor,
            AppColors.white.withValues(alpha: AppColors.glassTileOpacity),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              block.title,
              style: TextStyle(
                color: isBlocked ? AppColors.legendText : AppColors.black,
                fontSize: FontStyles.titleMedium,
                fontWeight: FontStyles.weightMedium,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitleText,
              style: const TextStyle(
                color: AppColors.legendText,
                fontSize: FontStyles.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}