import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/plan_widget.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';
import '../../../models/dashboard_models.dart';
import '../../../models/study_plan_model.dart';
import '../../../providers/study_plan_provider.dart';
import '../../central_student_navigation.dart';
import 'study_block_tile.dart';

class TodaysPlan extends StatelessWidget {
  const TodaysPlan({super.key});

  String _totalHoursLabel(List<StudyBlock> blocks) {
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

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<StudyPlanProvider>().plan;
    final now = DateTime.now();
    final todayPlan = plan?.days.firstWhere(
          (d) => d.date.day == now.day && d.date.month == now.month && d.date.year == now.year,
      orElse: () => DayPlan(date: now, blocks: const []),
    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            const PlanEmptyState()
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
                  const Icon(Icons.access_time_rounded, color: AppColors.black, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _totalHoursLabel(blocks),
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: FontStyles.titleSmall,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => context
                          .findAncestorStateOfType<CentralStudentNavigationState>()
                          ?.goToTab(2),
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
}