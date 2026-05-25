import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../providers/dashboard_provider.dart';
import 'stat_card.dart';

class TaskStatisticsSection extends StatelessWidget {
  const TaskStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<DashboardProvider>().data?.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Tasks Statistics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontStyles.weightHeavy,
              color: AppColors.black,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: 'TASKS DONE',
                  value: '${stats?.tasksDone ?? 0}',
                  sub: 'of ${stats?.totalTasks ?? 0} total',
                  accent: AppColors.black,
                  icon: Icons.check,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'DUE SOON',
                  value: '${stats?.dueSoon ?? 0}',
                  sub: 'within ${stats?.dueSoonDays ?? 0} days',
                  accent: AppColors.black,
                  icon: Icons.bolt,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: 'OVERDUE',
                  value: '${stats?.overdue ?? 0}',
                  sub: 'need attention',
                  accent: AppColors.black,
                  icon: Icons.warning_amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'WEEK',
                  value: '${stats?.currentWeek ?? 0}',
                  sub: 'of ${stats?.totalWeeks ?? 0} in sem',
                  accent: AppColors.black,
                  icon: Icons.calendar_month,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}