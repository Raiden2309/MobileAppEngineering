import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/tasks_controller.dart';
import '../../../models/app_enums.dart';
import '../../../models/tasks_model.dart';
import 'dart:async';

import 'confirm_delete_widget.dart'; // --- Added for runtime interval loops ---

Color subjectColor(String key) {
  switch (key) {
    case 'blue':
      return AppColors.summerCampBlue;
    case 'lime':
      return AppColors.lime;
    case 'yellow':
      return AppColors.mikadoYellow;
    case 'orange':
      return AppColors.nectarine;
    default:
      return AppColors.californiaBlue;
  }
}

Color chipBg(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
      return AppColors.completed;
    case TaskStatus.inProgress:
      return AppColors.inProgress;
    case TaskStatus.dueSoon:
      return AppColors.dueSoon;
    case TaskStatus.overdue:
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
      return AppColors.greenSheen;
    case TaskStatus.inProgress:
      return AppColors.mikadoYellow;
    case TaskStatus.dueSoon:
      return AppColors.nectarine;
    case TaskStatus.overdue:
    case TaskStatus.dueToday:
      return AppColors.red;
    case TaskStatus.toDo:
    case TaskStatus.upcoming:
      return AppColors.californiaBlue;
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  final SubjectGroup group;
  final TaskController controller;

  const TaskCard({
    super.key,
    required this.task,
    required this.group,
    required this.controller,
  });

  @override
  State<TaskCard> createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  bool get isCompleted => widget.task.status == TaskStatus.completed;

  @override
  void initState() {
    super.initState();
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
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final newStatus = widget.task.status == TaskStatus.completed
                  ? TaskStatus.toDo
                  : TaskStatus.completed;
              await widget.controller.updateTask(
                widget.task.copyWith(status: newStatus),
              );
            },
            child: TaskCheckbox(isCompleted: isCompleted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
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
                    // --- WIRED SELF-UPDATING LIVE TIMER ---
                    _TaskCardCountdownText(task: widget.task),
                    const SizedBox(width: 8),
                    StatusChip(
                      task: widget.task,
                      status: widget.controller.getLiveStatus(widget.task),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.controller.onEditTask(
              context,
              widget.group,
              widget.task,
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            color: AppColors.black.withValues(alpha: 0.35),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
          IconButton(
            onPressed: () => ConfirmDeleteWidget.show(
              context,
              onConfirm: () => widget.controller.deleteTask(widget.task),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            color: AppColors.red.withValues(alpha: 0.6),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class TaskCheckbox extends StatelessWidget {
  final bool isCompleted;

  const TaskCheckbox({super.key, required this.isCompleted});

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

class StatusChip extends StatelessWidget {
  final Task task;
  final TaskStatus status;

  const StatusChip({
    super.key,
    required this.task,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg(status),
        borderRadius: BorderRadius.circular(
          AppColors.glassBadgeBorderRadius,
        ),
        border: Border.all(
          color: chipFg(status).withValues(
            alpha: AppColors.glassBorderOpacity,
          ),
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: FontStyles.titleTiny,
          fontWeight: FontStyles.weightHeavy,
          color: chipFg(status),
        ),
      ),
    );
  }
}

class SubjectGroupSection extends StatelessWidget {
  final SubjectGroup group;
  final TaskController controller;

  const SubjectGroupSection({
    super.key,
    required this.group,
    required this.controller,
  });

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
        ...group.tasks.map(
          (task) => TaskCard(task: task, group: group, controller: controller),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// --- SELF-CONTAINED SUB-TICKER IMPLEMENTATION WITH LIFECYCLE REBIND OVERRIDES ---
class _TaskCardCountdownText extends StatefulWidget {
  final Task task;

  const _TaskCardCountdownText({required this.task});

  @override
  State<_TaskCardCountdownText> createState() => _TaskCardCountdownTextState();
}

class _TaskCardCountdownTextState extends State<_TaskCardCountdownText> {
  Timer? _cardTicker;
  late String _cardDisplayString;

  @override
  void initState() {
    super.initState();
    _refreshCardRemainingTime();

    if (widget.task.status == TaskStatus.inProgress &&
        widget.task.startedAt != null) {
      _cardTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        _refreshCardRemainingTime();
      });
    }
  }

  @override
  void didUpdateWidget(_TaskCardCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.status != widget.task.status ||
        oldWidget.task.startedAt != widget.task.startedAt) {
      _cardTicker?.cancel();
      _refreshCardRemainingTime();
      if (widget.task.status == TaskStatus.inProgress &&
          widget.task.startedAt != null) {
        _cardTicker = Timer.periodic(const Duration(seconds: 1), (_) {
          _refreshCardRemainingTime();
        });
      }
    }
  }

  void _refreshCardRemainingTime() {
    if (widget.task.status != TaskStatus.inProgress ||
        widget.task.startedAt == null) {
      _cardDisplayString = widget.task.estimatedTime;
      return;
    }

    final totalMinutesLimit = (widget.task.estimatedHours * 60).round();
    final elapsedMinutes = DateTime.now()
        .difference(widget.task.startedAt!)
        .inMinutes;
    final minutesLeft = totalMinutesLimit - elapsedMinutes;

    if (minutesLeft <= 0) {
      if (mounted) {
        setState(() {
          _cardDisplayString = "Time Overdue!";
        });
      }
      return;
    }

    final hoursOut = minutesLeft ~/ 60;
    final minutesOut = minutesLeft % 60;

    if (mounted) {
      setState(() {
        if (hoursOut > 0) {
          _cardDisplayString = '$hoursOut hr $minutesOut min left';
        } else {
          _cardDisplayString = '$minutesOut min left';
        }
      });
    }
  }

  @override
  void dispose() {
    _cardTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInProgress = widget.task.status == TaskStatus.inProgress;

    return Text(
      _cardDisplayString,
      style: TextStyle(
        fontSize: FontStyles.titleSmall,
        color: isInProgress ? AppColors.californiaBlue : AppColors.legendText,
        fontWeight: isInProgress ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
