import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

const _filters = [
  ('all',        'All'),
  ('inProgress', 'In Progress'),
  ('toDo',       'To Do'),
  ('completed',  'Completed'),
  ('dueSoon',    'Due Soon'),
  ('dueToday',    'Due Today'),
  ('overdue',    'Overdue'),
];

class TaskFilterBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAddTask;

  const TaskFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Filter chips
          ..._filters.map((f) {
            final (key, label) = f;
            final isActive = activeFilter == key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onFilterChanged(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: isActive
                      ? AppColors.glassBadge()
                      : BoxDecoration(
                    color: Colors.white.withValues(alpha: AppColors.glassTileOpacity),
                    borderRadius: BorderRadius.circular(AppColors.glassBadgeBorderRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: AppColors.glassBorderOpacity),
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Add task chip
          GestureDetector(
            onTap: onAddTask,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppColors.glassBadgeBorderRadius),
                border: Border.all(
                  color: AppColors.black.withValues(alpha: 0.15),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: AppColors.black),
                  SizedBox(width: 4),
                  Text(
                    'Add Task',
                    style: TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}