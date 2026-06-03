import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      TaskStatus.completed  => ('Done',        AppColors.completed,  AppColors.greenSheen),
      TaskStatus.inProgress => ('In Progress', AppColors.inProgress, AppColors.mikadoYellow),
      TaskStatus.overdue   => ('Overdue',   AppColors.dueSoon,    AppColors.red),
      TaskStatus.dueToday   => ('Due Today',   AppColors.dueSoon,    AppColors.red),
      TaskStatus.dueSoon    => ('Due Soon',    AppColors.dueSoon,    AppColors.nectarine),
      TaskStatus.upcoming   => ('Upcoming',    AppColors.toDo,       AppColors.californiaBlue),
      TaskStatus.toDo       => ('To Do',       AppColors.toDo,       AppColors.californiaBlue),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppColors.glassBadgeBorderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: FontStyles.titleSmall,
          fontWeight: FontStyles.weightMedium,
          color: fg,
        ),
      ),
    );
  }
}