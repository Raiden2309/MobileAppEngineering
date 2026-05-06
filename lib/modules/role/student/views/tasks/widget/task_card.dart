import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../models/tasks_model.dart';

Color subjectColor(String key) {
  switch (key) {
    case 'blue':   return AppColors.summerCampBlue;
    case 'teal':   return AppColors.greenSheen;
    case 'yellow': return AppColors.mikadoYellow;
    case 'orange': return AppColors.nectarine;
    default:       return AppColors.californiaBlue;
  }
}

Color chipBg(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:  return AppColors.completed;
    case TaskStatus.inProgress: return AppColors.inProgress;
    case TaskStatus.dueSoon:    return AppColors.dueSoon;
    case TaskStatus.toDo:       return AppColors.toDo;
  }
}

Color chipFg(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:  return AppColors.greenSheen;
    case TaskStatus.inProgress: return AppColors.mikadoYellow;
    case TaskStatus.dueSoon:    return AppColors.red;
    case TaskStatus.toDo:       return AppColors.californiaBlue;
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.black, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(                                    // ← wrap in GestureDetector
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.dayLabel : AppColors.black,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.dayLabel,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      widget.task.estimatedTime,
                      style: const TextStyle(fontSize: 12, color: AppColors.dayLabel),
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

// ── Checkbox ─────────────────────────────────────────────────────────────────

class Checkbox extends StatelessWidget {
  final bool isCompleted;
  const Checkbox({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.greenSheen.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isCompleted ? AppColors.greenSheen : AppColors.black.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.greenSheen)
          : null,
    );
  }
}

// ── StatusChip ───────────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  final Task task;
  const StatusChip({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg(task.status),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipFg(task.status).withOpacity(0.4), width: 1),
      ),
      child: Text(
        task.statusLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                '${group.completedTasks}/${group.totalTasks} completed',
                style: const TextStyle(fontSize: 12, color: AppColors.legendText),
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