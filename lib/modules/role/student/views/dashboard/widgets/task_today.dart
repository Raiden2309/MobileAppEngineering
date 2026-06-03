import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/dashboard_models.dart';
import '../../../providers/dashboard_provider.dart';
import '../../central_student_navigation.dart';
import 'task_card.dart';

class TaskToday extends StatelessWidget {
  const TaskToday({super.key});

  @override
  Widget build(BuildContext context) {
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
        StreamBuilder<List<TaskItem>>(
          stream: context.read<StudentDashboardProvider>().todayTasksStream,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];

            if (tasks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No tasks for today.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }

            final provider = context.watch<StudentDashboardProvider>();

            return Column(
              children: List.generate(tasks.length, (index) {
                final item = tasks[index];
                final isLoading = provider.completingTasks.contains(item.taskId);
                return TaskCard(
                  task: item,
                  isLoading: isLoading,
                  onToggle: isLoading
                      ? null
                      : () => context.read<StudentDashboardProvider>()
                      .toggleTaskCompletion(item.classId, item.taskId),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}