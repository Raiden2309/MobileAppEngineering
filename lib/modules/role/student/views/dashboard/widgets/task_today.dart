import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../central_student_navigation.dart';

enum TaskStatus { done, inProgress, dueToday, upcoming }

class TaskItem {
  final String title;
  final String subtitle;
  final TaskStatus status;
  final bool checked;

  const TaskItem({
    required this.title,
    required this.subtitle,
    required this.status,
    this.checked = false,
  });
}

class TaskToday extends StatefulWidget {
  const TaskToday({super.key});

  @override
  State<TaskToday> createState() => TaskTodayState();
}

class TaskTodayState extends State<TaskToday> {
  List<TaskItem> tasks = const [
    TaskItem(
      title: 'Review affinity analysis notes',
      subtitle: 'Research Methods · 45 min',
      status: TaskStatus.done,
      checked: true,
    ),
    TaskItem(
      title: 'Write use case diagrams',
      subtitle: 'CT124 System Proposal · 2 hrs',
      status: TaskStatus.inProgress,
    ),
    TaskItem(
      title: 'Prepare functional requirements',
      subtitle: 'CT124 System Proposal · 1 hr',
      status: TaskStatus.dueToday,
    ),
    TaskItem(
      title: 'Prepare survey questions',
      subtitle: 'Research Methods · 1.5 hrs',
      status: TaskStatus.upcoming,
    ),
  ];

  void toggleTask(int index) {
    setState(() {
      final t = tasks[index];
      tasks = List.from(tasks)
        ..[index] = TaskItem(
          title: t.title,
          subtitle: t.subtitle,
          status: t.status,
          checked: !t.checked,
        );
    });
  }

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
                onTap: () {
                  context
                      .findAncestorStateOfType<CentralStudentNavigationState>()
                      ?.setState(() {
                        context
                                .findAncestorStateOfType<
                                  CentralStudentNavigationState
                                >()
                                ?.currentNavIndex =
                            1;
                      });
                },
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
            final task = tasks[index];
            return TaskCard(task: task, onToggle: () => toggleTask(index));
          }),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black),
      ),
      child: Row(
        children: [
          TaskCheckbox(
            checked: task.checked,
            accent: AppColors.greenSheen,
            onTap: onToggle,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    decoration: task.checked
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusBadge(status: task.status),
        ],
      ),
    );
  }
}

class TaskCheckbox extends StatelessWidget {
  final bool checked;
  final Color accent;
  final VoidCallback onTap;

  const TaskCheckbox({
    super.key,
    required this.checked,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: checked ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: checked ? accent : AppColors.black,
            width: 2,
          ),
        ),
        child: checked ? Icon(Icons.check, color: accent, size: 18) : null,
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      TaskStatus.done => ('Done', AppColors.completed, AppColors.greenSheen),
      TaskStatus.inProgress => (
        'In Progress',
        AppColors.inProgress,
        AppColors.mikadoYellow,
      ),
      TaskStatus.dueToday => (
        'Due Today',
        AppColors.dueSoon,
        AppColors.nectarine,
      ),
      TaskStatus.upcoming => (
        'Upcoming',
        AppColors.toDo,
        AppColors.californiaBlue,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
