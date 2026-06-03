import 'app_enums.dart';

class Task {
  final String id;
  final String title;
  final double estimatedHours;
  final TaskStatus status;
  final DateTime? startedAt;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    required this.estimatedHours,
    required this.status,
    this.startedAt,
    this.dueDate,
  });

  String get estimatedTime => 'Est. $estimatedHours hrs';

  String get statusLabel {
    switch (status) {
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.dueSoon:
        return 'Due Soon';
      case TaskStatus.overdue:
        return 'Overdue';
      case TaskStatus.dueToday:
        return 'Due Today';
      case TaskStatus.upcoming:
        return 'Upcoming';
      default:
        return '';
    }
  }

  Task copyWith({
    String? id,
    String? title,
    double? estimatedHours,
    TaskStatus? status,
    DateTime? startedAt,
    DateTime? dueDate,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        estimatedHours: estimatedHours ?? this.estimatedHours,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        dueDate: dueDate ?? this.dueDate,
      );

  factory Task.fromJson(Map<String, dynamic> json) {
    // 1. Safe status conversion that handles both camelCase and snake_case backend strings
    final String statusStr = (json['status'] ?? 'toDo').toString();
    TaskStatus mappedStatus;

    if (statusStr == 'inProgress') {
      mappedStatus = TaskStatus.inProgress;
    } else if (statusStr == 'dueSoon') {
      mappedStatus = TaskStatus.dueSoon;
    } else if (statusStr == 'dueToday') {
      mappedStatus = TaskStatus.dueToday;
    }
    else if (statusStr == 'overdue') {
      mappedStatus = TaskStatus.overdue;
    } else if (statusStr == 'completed') {
      mappedStatus = TaskStatus.completed;
    } else if (statusStr == 'upcoming') {
      mappedStatus = TaskStatus.upcoming;
    } else {
      mappedStatus = TaskStatus.toDo;
    }

    // 2. Fallback safeguards for snake_case vs camelCase field maps
    final rawHours = json['estimated_hours'] ?? json['estimatedHours'] ?? 0.0;
    final double hours = (rawHours is num) ? rawHours.toDouble() : double
        .tryParse(rawHours.toString()) ?? 0.0;

    final rawDueDate = json['due_date'] ?? json['dueDate'];
    final rawStartedAt = json['started_at'] ?? json['startedAt'];

    return Task(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? 'Task').toString(),
      estimatedHours: hours,
      status: mappedStatus,
      startedAt: rawStartedAt != null ? DateTime.tryParse(
          rawStartedAt.toString()) : null,
      dueDate: rawDueDate != null
          ? DateTime.tryParse(rawDueDate.toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'title': title,
        'estimated_hours': estimatedHours,
        'status': status.name,
        'started_at': startedAt?.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
      };
}

class SubjectGroup {
  final String id;
  final String name;
  final String colorKey;
  final List<Task> tasks;

  const SubjectGroup({
    required this.id,
    required this.name,
    this.colorKey = 'blue',
    required this.tasks,
  });

  factory SubjectGroup.fromJson(Map<String, dynamic> json) {
    // Check both potential storage keys for array mappings
    final List<dynamic> rawTasks = json['tasks'] ?? json['tasksList'] ?? [];

    return SubjectGroup(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['subjectName'] ?? json['classId'] ??
          'Unknown Subject',
      colorKey: json['colorKey']?.toString() ?? 'blue',
      tasks: rawTasks
          .map((t) => Task.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'colorKey': colorKey,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks
          .where((t) => t.status == TaskStatus.completed)
          .length;

  SubjectGroup copyWith({
    String? id,
    String? name,
    String? colorKey,
    List<Task>? tasks,
  }) =>
      SubjectGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        colorKey: colorKey ?? this.colorKey,
        tasks: tasks ?? this.tasks,
      );
}