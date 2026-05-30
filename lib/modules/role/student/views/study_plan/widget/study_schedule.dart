import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';
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
                color: AppColors.white.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No sessions planned for this day',
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

    return Column(
      children: List.generate(dayPlan.blocks.length, (i) {
        return ScheduleRow(
          block: dayPlan.blocks[i],
          isFirst: i == 0,
          isLast: i == dayPlan.blocks.length - 1,
        );
      }),
    );
  }
}

class ScheduleRow extends StatelessWidget {
  final StudyBlock block;
  final bool isFirst;
  final bool isLast;

  const ScheduleRow({
    super.key,
    required this.block,
    required this.isFirst,
    required this.isLast,
  });

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
    const double dotSize = 10;
    const double dotTopOffset = 15;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // FIXED: Dynamic card matching bounds constraints
        children: [
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: dotTopOffset - 2),
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

          SizedBox(
            width: 18,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isFirst)
                  Positioned(
                    top: 0,
                    height: dotTopOffset,
                    child: Container(width: 1.5, color: AppColors.black),
                  ),
                if (!isLast)
                  Positioned(
                    top: dotTopOffset + dotSize,
                    bottom: 0,
                    child: Container(width: 1.5, color: AppColors.black),
                  ),
                Positioned(
                  top: dotTopOffset,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (block.type != BlockType.blocked)
                          BoxShadow(
                            color: dotColor.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12), // FIXED: Extra padding guard to prevent RenderFlex edge collision
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
        color: AppColors.white, // FIXED: Ensure background color is explicitly set inside layout limits
        borderRadius: BorderRadius.circular(AppColors.glassTileBorderRadius),
        border: Border.all(color: AppColors.black),
        gradient: LinearGradient(
          stops: const [0.02, 0.02],
          colors: [
            accentColor,
            AppColors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // Center text layouts cleanly within row lines
          children: [
            Text(
              block.title,
              style: TextStyle(
                color: isBlocked ? AppColors.legendText : AppColors.black,
                fontSize: FontStyles.titleMedium,
                fontWeight: FontStyles.weightMedium,
              ),
            ),
            const SizedBox(height: 4),
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