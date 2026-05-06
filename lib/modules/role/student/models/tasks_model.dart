import '../views/dashboard/widgets/task_today.dart';

enum TaskStatus { completed, inProgress, toDo, dueSoon }

class Task {
  final String name;
  final String estimatedTime;
  final TaskStatus status;
  final String statusLabel;

  const Task({
    required this.name,
    required this.estimatedTime,
    required this.status,
    required this.statusLabel,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name:          json['name'] as String,
      estimatedTime: json['estimated_time'] as String,
      status:        TaskStatus.values.byName(json['status'] as String),
      statusLabel:   json['status_label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name':           name,
    'estimated_time': estimatedTime,
    'status':         status.name,
    'status_label':   statusLabel,
  };
}

class SubjectGroup {
  final String name;
  final String colorKey;
  final int totalTasks;
  final int completedTasks;
  final List<Task> tasks;

  const SubjectGroup({
    required this.name,
    required this.colorKey,
    required this.totalTasks,
    required this.completedTasks,
    required this.tasks,
  });

  factory SubjectGroup.fromJson(Map<String, dynamic> json) {
    return SubjectGroup(
      name:           json['name'] as String,
      colorKey:       json['color_key'] as String,
      totalTasks:     json['total_tasks'] as int,
      completedTasks: json['completed_tasks'] as int,
      tasks: (json['tasks'] as List<dynamic>)
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name':            name,
    'color_key':       colorKey,
    'total_tasks':     totalTasks,
    'completed_tasks': completedTasks,
    'tasks':           tasks.map((t) => t.toJson()).toList(),
  };
}