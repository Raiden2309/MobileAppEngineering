import 'app_enums.dart';

class Task {
  final String id;
  final String title;
  final double estimatedHours;
  final TaskStatus status;
  final DateTime? startedAt;
  final DateTime? dueDate; // --- NEW: Track calendar deadline target dates ---

  const Task({
    required this.id,
    required this.title,
    required this.estimatedHours,
    required this.status,
    this.startedAt,
    this.dueDate, // --- Optional calendar date target parameter ---
  });

  String get estimatedTime => 'Est. $estimatedHours hrs';

  String get statusLabel {
    switch (status) {
      case TaskStatus.completed:  return 'Completed';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.toDo:       return 'To Do';
      case TaskStatus.dueSoon:    return 'Due Soon';
      default:                    return '';
    }
  }

  Task copyWith({
    String? id,
    String? title,
    double? estimatedHours,
    TaskStatus? status,
    DateTime? startedAt,
    DateTime? dueDate,
  }) => Task(
    id:             id             ?? this.id,
    title:          title          ?? this.title,
    estimatedHours: estimatedHours ?? this.estimatedHours,
    status:         status         ?? this.status,
    startedAt:      startedAt      ?? this.startedAt,
    dueDate:        dueDate        ?? this.dueDate,
  );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id:             json['id'].toString(),
    title:          json['title'] as String,
    estimatedHours: (json['estimated_hours'] as num).toDouble(),
    status:         TaskStatus.values.byName(json['status'] as String),
    startedAt:      json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
    dueDate:        json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null, // --- Parse due date string safely ---
  );

  Map<String, dynamic> toJson() => {
    'id':              id,
    'title':           title,
    'estimated_hours': estimatedHours,
    'status':          status.name,
    'started_at':      startedAt?.toIso8601String(),
    'due_date':        dueDate?.toIso8601String(), // --- Export due date string safely ---
  };
}

class SubjectGroup {
  final String id;
  final String name;
  final String colorKey;
  final int totalTasks;
  final int completedTasks;
  final List<Task> tasks;

  const SubjectGroup({
    required this.id,
    required this.name,
    this.colorKey = 'blue',
    this.totalTasks = 0,
    this.completedTasks = 0,
    required this.tasks,
  });

  SubjectGroup copyWith({
    String? id,
    String? name,
    String? colorKey,
    int? totalTasks,
    int? completedTasks,
    List<Task>? tasks,
  }) => SubjectGroup(
    id:             id             ?? this.id,
    name:           name           ?? this.name,
    colorKey:       colorKey       ?? this.colorKey,
    totalTasks:     totalTasks     ?? this.totalTasks,
    completedTasks: completedTasks ?? this.completedTasks,
    tasks:          tasks          ?? this.tasks,
  );

  static List<SubjectGroup> mockData() => [
    SubjectGroup(
      id: 'mock_1',
      name: 'Sigma',
      colorKey: 'purple',
      totalTasks: 3,
      completedTasks: 1,
      tasks: [
        Task(id: 't1', title: 'Review Chapter 1 Documentation', estimatedHours: 2.0, status: TaskStatus.toDo),
        Task(id: 't2', title: 'Complete Core Formula Sheet', estimatedHours: 1.5, status: TaskStatus.inProgress),
        Task(id: 't3', title: 'Submit Initial Benchmark Logs', estimatedHours: 1.0, status: TaskStatus.completed),
      ],
    ),
  ];
}