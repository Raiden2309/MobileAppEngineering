import 'app_enums.dart';
import 'study_plan_model.dart';

class DashboardModel {
  final DashboardSummary summary;
  final DashboardStats stats;
  final CurrentTask? currentTask;
  final WorkloadPlan workloadPlan;
  final List<TaskItem> todayTasks;

  const DashboardModel({
    required this.summary,
    required this.stats,
    required this.currentTask,
    required this.workloadPlan,
    required this.todayTasks,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      summary:      DashboardSummary.fromJson(json['summary']),
      stats:        DashboardStats.fromJson(json['stats']),
      currentTask:  json['current_task'] != null
          ? CurrentTask.fromJson(json['current_task'])
          : null,
      workloadPlan: WorkloadPlan.fromJson(json['workload_plan']),
      todayTasks:   (json['today_tasks'] as List<dynamic>)
          .map((t) => TaskItem.fromJson(t))
          .toList(),
    );
  }
}

class DashboardSummary {
  final String userName;
  final int taskCountToday;
  final DateTime date;

  const DashboardSummary({
    required this.userName,
    required this.taskCountToday,
    required this.date,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      userName:       json['user_name'] as String,
      taskCountToday: json['task_count_today'] as int,
      date:           DateTime.parse(json['date'] as String),
    );
  }
}

class DashboardStats {
  final int tasksDone;
  final int totalTasks;
  final int dueSoon;
  final int dueSoonDays;
  final int overdue;
  final int currentWeek;
  final int totalWeeks;

  const DashboardStats({
    required this.tasksDone,
    required this.totalTasks,
    required this.dueSoon,
    required this.dueSoonDays,
    required this.overdue,
    required this.currentWeek,
    required this.totalWeeks,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      tasksDone:   json['tasks_done'] as int,
      totalTasks:  json['total_tasks'] as int,
      dueSoon:     json['due_soon'] as int,
      dueSoonDays: json['due_soon_days'] as int,
      overdue:     json['overdue'] as int,
      currentWeek: json['current_week'] as int,
      totalWeeks:  json['total_weeks'] as int,
    );
  }
}

class CurrentTask {
  final String title;
  final String subtitle;
  final TaskStatus status;
  final DateTime? dueAt;

  const CurrentTask({
    required this.title,
    required this.subtitle,
    required this.status,
    this.dueAt,
  });

  factory CurrentTask.fromJson(Map<String, dynamic> json) {
    return CurrentTask(
      title:    json['title'] as String,
      subtitle: json['subtitle'] as String,
      status:   TaskStatus.values.byName(json['status'] as String),
      dueAt:    json['due_at'] != null
          ? DateTime.parse(json['due_at'] as String)
          : null,
    );
  }
}

class WorkloadPlan {
  final String planLabel;
  final List<TaskItem> tasks;

  const WorkloadPlan({required this.planLabel, required this.tasks});

  bool get isEmpty => tasks.isEmpty;

  factory WorkloadPlan.fromJson(Map<String, dynamic> json) {
    return WorkloadPlan(
      planLabel: json['plan_label'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((t) => TaskItem.fromJson(t))
          .toList(),
    );
  }
}

class TaskItem {
  final String title;
  final String subtitle;
  final TaskStatus status;
  final bool checked;
  final String classId;
  final String taskId;

  const TaskItem({
    required this.title,
    required this.subtitle,
    required this.status,
    this.checked = false,
    this.classId = '',
    this.taskId = '',
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title:    json['title'] as String,
      subtitle: json['subtitle'] as String,
      status:   TaskStatus.values.byName(json['status'] as String),
      checked:  json['checked'] as bool? ?? false,
    );
  }

  TaskItem copyWith({bool? checked}) {
    return TaskItem(
      title:    title,
      subtitle: subtitle,
      status:   status,
      checked:  checked ?? this.checked,
      classId: classId,
      taskId: taskId,
    );
  }
}