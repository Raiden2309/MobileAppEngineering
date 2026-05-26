import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/my_tasks_header.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/subject_group_list.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/task_filter_bar.dart';
import '../../controllers/tasks_controller.dart';

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