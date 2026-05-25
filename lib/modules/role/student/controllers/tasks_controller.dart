import 'package:flutter/material.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';
import '../providers/task_provider.dart';

class TaskController extends ChangeNotifier {
  final TasksProvider _provider;

  TaskController(this._provider) {
    _provider.addListener(_onProviderUpdate);
  }

  // ── Provider passthrough ──────────────────────────────────

  List<SubjectGroup> get groups => _provider.groups;
  String get activeFilter => _provider.activeFilter;
  bool get loading => _provider.loading;
  String? get error => _provider.error;
  bool get hasData => groups.isNotEmpty;

  // ── Filter ────────────────────────────────────────────────

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

  /// Returns only groups that have at least one task visible under the active filter.
  List<SubjectGroup> get visibleGroups => groups
      .where((g) => filteredTasksFor(g).isNotEmpty)
      .toList();

  // ── Derived totals ────────────────────────────────────────

  int get totalTasks =>
      groups.fold(0, (sum, g) => sum + g.totalTasks);

  int get completedTasks =>
      groups.fold(0, (sum, g) => sum + g.completedTasks);

  int get dueSoonCount => groups
      .expand((g) => g.tasks)
      .where((t) => t.status == TaskStatus.dueSoon)
      .length;

  int get inProgressCount => groups
      .expand((g) => g.tasks)
      .where((t) => t.status == TaskStatus.inProgress)
      .length;

  String get completionSummary => '$completedTasks of $totalTasks completed';

  // ── Data loading ──────────────────────────────────────────

  Future<void> init() async {
    if (hasData) return;
    await fetch();
  }

  Future<void> fetch() async => _provider.fetch();

  void loadMock() => _provider.loadMock();

  Future<void> refresh() async => _provider.fetch();

  // ── Actions ───────────────────────────────────────────────

  /// Placeholder called by the Add Task button — replace with your navigation/dialog logic.
  void onAddTask(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Add Task…')),
    );
  }

  // ── Provider sync ─────────────────────────────────────────

  void _onProviderUpdate() => notifyListeners();

  // ── Cleanup ───────────────────────────────────────────────

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    super.dispose();
  }
}