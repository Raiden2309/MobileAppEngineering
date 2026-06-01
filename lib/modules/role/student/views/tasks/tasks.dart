import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/my_tasks_header.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/subject_group_list.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/task_filter_bar.dart';
import '../../controllers/tasks_controller.dart';
import '../../providers/student_settings_provider.dart';
import '../../providers/task_provider.dart';

class MyTasksPage extends StatefulWidget {
  final TaskController controller;

  const MyTasksPage({super.key, required this.controller});

  @override
  State<MyTasksPage> createState() => MyTasksPageState();
}

class MyTasksPageState extends State<MyTasksPage> {
  TaskController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = context.read<StudentSettingsProvider>();
      final semester = settings.currentSemesterId ?? '';
      if (semester.isNotEmpty) {
        controller.init(semester);
      } else {
        // Wait for settings to resolve
        settings.addListener(_onSettingsReady);
      }
    });
  }

  void _onSettingsReady() {
    final settings = context.read<StudentSettingsProvider>();
    final semester = settings.currentSemesterId ?? '';
    if (semester.isNotEmpty) {
      settings.removeListener(_onSettingsReady);
      controller.init(semester);
    }
  }

  @override
  void dispose() {
    context.read<StudentSettingsProvider>().removeListener(_onSettingsReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TasksProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTasksHeader(completionSummary: controller.completionSummary),
        const SizedBox(height: 12),
        TaskFilterBar(
          activeFilter: controller.activeFilter,
          onFilterChanged: controller.setFilter,
          onAddTask: () => controller.onAddTask(context),
        ),
        const SizedBox(height: 16),
        SubjectGroupList(controller: controller),
      ],
    );
  }
}