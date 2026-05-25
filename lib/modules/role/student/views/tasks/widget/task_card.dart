import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';
import '../../../models/tasks_model.dart';

Color subjectColor(String key) {
  switch (key) {
    case 'blue':   return AppColors.summerCampBlue;
    case 'lime':   return AppColors.lime;
    case 'yellow': return AppColors.mikadoYellow;
    case 'orange': return AppColors.nectarine;
    default:       return AppColors.californiaBlue;
  }
}

Color chipBg(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
    case TaskStatus.done:
      return AppColors.completed;
    case TaskStatus.inProgress:
      return AppColors.inProgress;
    case TaskStatus.dueSoon:
    case TaskStatus.dueToday:
      return AppColors.dueSoon;
    case TaskStatus.toDo:
    case TaskStatus.upcoming:
      return AppColors.toDo;
  }
}

Color chipFg(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
    case TaskStatus.done:
      return AppColors.greenSheen;
    case TaskStatus.inProgress:
      return AppColors.mikadoYellow;
    case TaskStatus.dueSoon:
    case TaskStatus.dueToday:
      return AppColors.red;
    case TaskStatus.toDo:
    case TaskStatus.upcoming:
      return AppColors.californiaBlue;
  }
}

// ── TaskCard ──────────────────────────────────────────────────────────────────

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.task.status == TaskStatus.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => isCompleted = !isCompleted),
            child: Checkbox(isCompleted: isCompleted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.name,
                  style: TextStyle(
                    fontSize: FontStyles.titleMedium,
                    fontWeight: FontStyles.weightMedium,
                    color: isCompleted ? AppColors.legendText : AppColors.black,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.legendText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      widget.task.estimatedTime,
                      style: const TextStyle(
                        fontSize: FontStyles.titleSmall,
                        color: AppColors.legendText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(task: widget.task),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Checkbox ──────────────────────────────────────────────────────────────────

class Checkbox extends StatelessWidget {
  final bool isCompleted;
  const Checkbox({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.lime.withValues(alpha: AppColors.glassIconOpacity)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.lime)
          : null,
    );
  }
}

// ── StatusChip ────────────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  final Task task;
  const StatusChip({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg(task.status),
        borderRadius: BorderRadius.circular(AppColors.glassBadgeBorderRadius),
        border: Border.all(
          color: chipFg(task.status).withValues(alpha: AppColors.glassBorderOpacity),
          width: 1,
        ),
      ),
      child: Text(
        task.statusLabel,
        style: TextStyle(
          fontSize: FontStyles.titleTiny,
          fontWeight: FontStyles.weightHeavy,
          color: chipFg(task.status),
        ),
      ),
    );
  }
}

// ── SubjectGroupSection ───────────────────────────────────────────────────────

class SubjectGroupSection extends StatelessWidget {
  final SubjectGroup group;
  const SubjectGroupSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final color = subjectColor(group.colorKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: FontStyles.titleMedium,
                    fontWeight: FontStyles.weightHeavy,
                    color: AppColors.black,
                  ),
                ),
              ),
              Text(
                '${group.completedTasks}/${group.totalTasks} completed',
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.titleWeight,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        ...group.tasks.map((task) => TaskCard(task: task)),
        const SizedBox(height: 12),
      ],
    );
  }
}