import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../../../shared/styles/font_styles.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../models/dashboard_models.dart';
import '../../central_student_navigation.dart';

class TodaysPlan extends StatelessWidget {
  const TodaysPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final weekPlan = WeekPlan.mockData();
    final now = DateTime.now();

    final todayIndex = weekPlan.days.indexWhere(
          (d) =>
      d.date.day == now.day &&
          d.date.month == now.month &&
          d.date.year == now.year,
    );

    final todayPlan = todayIndex >= 0 ? weekPlan.days[todayIndex] : null;
    final blocks = todayPlan?.blocks ?? [];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppColors.glassIcon(),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.black,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Today's Study Plan",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: FontStyles.titleMedium,
                      fontWeight: FontStyles.titleWeight,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (blocks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: AppColors.glassBadge(),
                    child: Text(
                      '${blocks.length} blocks',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: FontStyles.titleSmall,
                        fontWeight: FontStyles.weightMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.black),

          if (blocks.isEmpty)
            const EmptyState()
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (int i = 0; i < blocks.length; i++) ...[
                    StudyBlockTile(block: blocks[i]),
                    if (i < blocks.length - 1)
                      TimeGapIndicator(
                        fromBlock: blocks[i],
                        toBlock: blocks[i + 1],
                      ),
                  ],
                ],
              ),
            ),

          if (blocks.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.black),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.black,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    totalHoursLabel(blocks),
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: FontStyles.titleSmall,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        context
                            .findAncestorStateOfType<CentralStudentNavigationState>()
                            ?.goToTab(2);
                      },
                      child: const Text(
                        'View full plan >',
                        style: TextStyle(
                          fontSize: FontStyles.titleSmall,
                          fontWeight: FontStyles.titleWeight,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String totalHoursLabel(List<StudyBlock> blocks) {
    final totalMinutes = blocks
        .where((b) => b.type == BlockType.study)
        .fold(0, (sum, b) => sum + b.durationMinutes);
    if (totalMinutes <= 0) return '${blocks.length} blocks today';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m of study today';
    if (m == 0) return '${h}h of study today';
    return '${h}h ${m}m of study today';
  }
}

class StudyBlockTile extends StatelessWidget {
  final StudyBlock block;

  const StudyBlockTile({super.key, required this.block});

  static const List<Color> subjectAccentColors = [
    AppColors.californiaBlue,
    AppColors.greenSheen,
    AppColors.softPurple,
    AppColors.skyCyan,
    AppColors.nectarine,
    AppColors.pink,
    AppColors.lime,
    AppColors.mikadoYellow,
  ];

  Color get accentColor {
    if (block.type == BlockType.blocked) return AppColors.red;
    if (block.type == BlockType.breakSlot) return AppColors.black;
    final key = block.subject ?? block.title;
    return subjectAccentColors[key.hashCode.abs() % subjectAccentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppColors.glassTile().copyWith(
        border: Border.all(color: AppColors.black),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.titleWeight,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (block.subject != null && block.subject!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    block.subject!,
                    style: const TextStyle(
                      color: AppColors.legendText,
                      fontSize: FontStyles.titleTiny,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          Text(
            '${block.startTime} – ${block.endTime}',
            style: const TextStyle(
              color: AppColors.legendText,
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.weightMedium,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeGapIndicator extends StatelessWidget {
  final StudyBlock fromBlock;
  final StudyBlock toBlock;

  const TimeGapIndicator({
    super.key,
    required this.fromBlock,
    required this.toBlock,
  });

  int get gapMinutes {
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
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gap = gapMinutes;
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

class EmptyState extends StatelessWidget {
  const EmptyState();

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