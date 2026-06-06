import 'package:flutter/material.dart';
import 'task_card.dart';
import '../../../controllers/tasks_controller.dart';
import '../../../models/tasks_model.dart';

class SubjectGroupList extends StatelessWidget {
  final TaskController controller;

  const SubjectGroupList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...controller.visibleGroups.map((group) =>
                  SubjectGroupSection(
                    controller: controller,
                    group: SubjectGroup(
                      id: group.id,
                      name: group.name,
                      colorKey: group.colorKey,
                      tasks: controller.filteredTasksFor(group),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}