import 'package:flutter/material.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';
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
    ('overDue',    'Overdue'),
  ];

  TaskStatus getLiveStatus(Task task) {
    return _getLiveStatus(task);
  }

  TaskStatus _getLiveStatus(Task task) {
    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.inProgress) {
      return task.status;
    }
    if (task.dueDate == null) return task.status;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    if (taskDate.isBefore(todayDate)) return TaskStatus.overdue;
    if (taskDate.isAtSameMomentAs(todayDate)) return TaskStatus.dueToday;

    final diff = taskDate.difference(todayDate).inDays;
    if (diff <= 3) return TaskStatus.dueSoon;

    return task.status;
  }

  void setFilter(String filter) => _provider.setFilter(filter);

  List<Task> filteredTasksFor(SubjectGroup group) =>
      _provider.filteredTasks(group.tasks);

  List<SubjectGroup> get visibleGroups =>
      groups.where((g) => filteredTasksFor(g).isNotEmpty).toList();

  int get totalTasks     => groups.fold(0, (sum, g) => sum + g.totalTasks);
  int get completedTasks => groups.fold(0, (sum, g) => sum + g.completedTasks);

  int get dueSoonCount => groups
      .expand((g) => g.tasks)
      .where((t) {
    final liveStatus = _getLiveStatus(t); // Calls the function here 👈
    return liveStatus == TaskStatus.dueSoon || liveStatus == TaskStatus.dueToday;
  })
      .length;

  int get inProgressCount => groups
      .expand((g) => g.tasks)
      .where((t) => _getLiveStatus(t) == TaskStatus.inProgress) // Calls the function here 👈
      .length;

  String get completionSummary => '$completedTasks of $totalTasks completed';

  Future<void> init(String semester) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.listenToLiveTasks(semester: semester);
    });
  }

  Future<void> fetch()   async => _provider.fetch();
  void         load()      => _provider.load();
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
    DateTime? dueDate,
  }) => _provider.addTask(
    groupId: groupId,
    title: title,
    estimatedHours: estimatedHours,
    status: status,
    dueDate: dueDate,
  );

  Future<void> updateTask(Task task) => _provider.updateTask(task);
  Future<void> deleteTask(Task task) => _provider.deleteTask(task);
  void refreshCache() => _provider.saveCache();

  Future<void> syncTaskStatuses() async {
    bool hasChanges = false;
    for (final group in groups) {
      for (final task in group.tasks) {
        final liveStatus = _getLiveStatus(task);
        if (liveStatus != task.status) {
          hasChanges = true;
          await _provider.updateTask(task.copyWith(status: liveStatus));
        }
      }
    }
    if (hasChanges) notifyListeners();
  }

  void _onProviderUpdate() => notifyListeners();


  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    super.dispose();
  }
}