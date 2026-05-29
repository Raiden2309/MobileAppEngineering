import 'package:flutter/material.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';
import '../models/app_enums.dart';
import '../../../../../../modules/role/student/models/tasks_model.dart';
import '../providers/task_provider.dart';
import '../views/tasks/widget/task_bottom_sheet.dart';

class TaskController extends ChangeNotifier {
  final TasksProvider _provider;

  TaskController(this._provider) {
    _provider.addListener(_onProviderUpdate);
  }

  List<SubjectGroup> get groups => _provider.groups;
  String get activeFilter => _provider.activeFilter;
  bool get loading => _provider.loading;
  String? get error => _provider.error;
  bool get hasData => groups.isNotEmpty;

  static const filters = [
    ('all',        'All'),
    ('inProgress', 'In Progress'),
    ('toDo',       'To Do'),
    ('completed',  'Completed'),
    ('dueSoon',    'Due Soon'),
  ];

  void setFilter(String filter) => _provider.setFilter(filter);

  List<Task> filteredTasksFor(SubjectGroup group) =>
      _provider.filteredTasks(group.tasks);

  List<SubjectGroup> get visibleGroups =>
      groups.where((g) => filteredTasksFor(g).isNotEmpty).toList();

  int get totalTasks     => groups.fold(0, (sum, g) => sum + g.totalTasks);
  int get completedTasks => groups.fold(0, (sum, g) => sum + g.completedTasks);

  int get dueSoonCount => groups
      .expand((g) => g.tasks)
      .where((t) => t.status == TaskStatus.dueSoon)
      .length;

  int get inProgressCount => groups
      .expand((g) => g.tasks)
      .where((t) => t.status == TaskStatus.inProgress)
      .length;

  String get completionSummary => '$completedTasks of $totalTasks completed';

  Future<void> init() async {
    _provider.listenToLiveTasks();
  }

  Future<void> fetch()   async => _provider.fetch();
  void         loadMock()      => _provider.loadMock();
  Future<void> refresh() async => _provider.fetch();

  void onAddTask(BuildContext context) {
    TaskBottomSheet.show(context, controller: this, groups: groups);
  }

  void onEditTask(BuildContext context, SubjectGroup group, Task task) {
    TaskBottomSheet.show(
      context,
      controller: this,
      groups: groups,
      group: group,
      existing: task,
    );
  }

  Future<void> addTask({
    required String groupId,
    required String title,
    required double estimatedHours,
    required TaskStatus status,
  }) => _provider.addTask(
    groupId: groupId,
    title: title,
    estimatedHours: estimatedHours,
    status: status,
  );

  Future<void> updateTask(Task task) => _provider.updateTask(task);
  Future<void> deleteTask(Task task) => _provider.deleteTask(task);

  void _onProviderUpdate() => notifyListeners();

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    super.dispose();
  }
}