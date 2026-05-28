import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../providers/dashboard_provider.dart';
import '../../central_student_navigation.dart';
import 'task_card.dart';

class TaskToday extends StatelessWidget {
  const TaskToday({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentDashboardProvider>();
    final tasks = provider.data?.todayTasks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Tasks",
              style: TextStyle(
                fontSize: FontStyles.titleLarge,
                fontWeight: FontStyles.weightHeavy,
                color: AppColors.black,
                letterSpacing: 0.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => context
                    .findAncestorStateOfType<CentralStudentNavigationState>()
                    ?.goToTab(1),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontStyles.titleWeight,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(tasks.length, (index) {
            return TaskCard(
              task: tasks[index],
              onToggle: () => provider.toggleTask(index),
            );
          }),
        ),
      ],
    );
  }
}