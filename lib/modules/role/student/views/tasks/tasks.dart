import 'package:flutter/material.dart';
import 'package:mae_assignment/modules/role/student/views/tasks/widget/task_card.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../controllers/tasks_controller.dart';
import '../../models/tasks_model.dart';

class MyTasksPage extends StatefulWidget {
  final TaskController controller;

  const MyTasksPage({super.key, required this.controller});

  @override
  State<MyTasksPage> createState() => MyTasksPageState();
}

class MyTasksPageState extends State<MyTasksPage> {
  static const filters = [
    ('all',        'All'),
    ('inProgress', 'In Progress'),
    ('toDo',       'To Do'),
    ('completed',  'Completed'),
    ('dueSoon',    'Due Soon'),
  ];

  TaskController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: FontStyles.titleLarge,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Semester 4 · ${controller.completionSummary}',
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Filter chips ──────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final (key, label) = filters[i];
              final isActive = controller.activeFilter == key;
              return GestureDetector(
                onTap: () => controller.setFilter(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: isActive
                      ? AppColors.glassBadge()
                      : BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: AppColors.glassTileOpacity),
                    borderRadius: BorderRadius.circular(
                        AppColors.glassBadgeBorderRadius),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: AppColors.glassBorderOpacity),
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
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Task list ─────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...controller.visibleGroups.map((group) => SubjectGroupSection(
                group: SubjectGroup(
                  name: group.name,
                  colorKey: group.colorKey,
                  totalTasks: group.totalTasks,
                  completedTasks: group.completedTasks,
                  tasks: controller.filteredTasksFor(group),
                ),
              )),

              const SizedBox(height: 8),

              // ── Add task button ────────────────────────
              Container(
                width: double.infinity,
                decoration: AppColors.glassCard(),
                child: OutlinedButton.icon(
                  onPressed: () => controller.onAddTask(context),
                  icon: const Icon(Icons.add, size: 18, color: AppColors.black),
                  label: const Text('Add new task'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: BorderSide.none,
                    backgroundColor: AppColors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppColors.glassBorderRadius),
                    ),
                    textStyle: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}