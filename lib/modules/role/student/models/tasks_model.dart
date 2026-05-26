import 'app_enums.dart';

class Task {
  final String id;
  final String title;
  final double estimatedHours;
  final TaskStatus status;

  const Task({
    required this.id,
    required this.title,
    required this.estimatedHours,
    required this.status,
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
  }) => Task(
    id:             id             ?? this.id,
    title:          title          ?? this.title,
    estimatedHours: estimatedHours ?? this.estimatedHours,
    status:         status         ?? this.status,
  );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id:             json['id'].toString(),
    title:          json['title'] as String,
    estimatedHours: (json['estimated_hours'] as num).toDouble(),
    status:         TaskStatus.values.byName(json['status'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id':              id,
    'title':           title,
    'estimated_hours': estimatedHours,
    'status':          status.name,
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
    required this.colorKey,
    required this.totalTasks,
    required this.completedTasks,
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

  factory SubjectGroup.fromJson(Map<String, dynamic> json) => SubjectGroup(
    id:             json['id'].toString(),
    name:           json['name'] as String,
    colorKey:       json['color_key'] as String,
    totalTasks:     json['total_tasks'] as int,
    completedTasks: json['completed_tasks'] as int,
    tasks: (json['tasks'] as List<dynamic>)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'name':           name,
    'color_key':      colorKey,
    'total_tasks':    totalTasks,
    'completed_tasks': completedTasks,
    'tasks':          tasks.map((t) => t.toJson()).toList(),
  };

  static List<SubjectGroup> mockData() => [
    SubjectGroup(
      id: '1', name: 'CT124 System Proposal', colorKey: 'blue',
      totalTasks: 5, completedTasks: 2,
      tasks: [
        Task(id: '1', title: 'Complete system proposal introduction', estimatedHours: 1.5, status: TaskStatus.completed),
        Task(id: '2', title: 'Create system context diagram',         estimatedHours: 1.0, status: TaskStatus.completed),
        Task(id: '3', title: 'Write use case diagrams',               estimatedHours: 2.0, status: TaskStatus.inProgress),
        Task(id: '4', title: 'Prepare functional requirements',       estimatedHours: 1.0, status: TaskStatus.dueSoon),
        Task(id: '5', title: 'Write non-functional requirements',     estimatedHours: 1.0, status: TaskStatus.toDo),
      ],
    ),
    SubjectGroup(
      id: '2', name: 'Research Methods', colorKey: 'yellow',
      totalTasks: 4, completedTasks: 2,
      tasks: [
        Task(id: '6', title: 'Review affinity analysis notes', estimatedHours: 0.75, status: TaskStatus.completed),
        Task(id: '7', title: 'Literature review draft',        estimatedHours: 2.0,  status: TaskStatus.completed),
        Task(id: '8', title: 'Prepare survey questions',       estimatedHours: 1.5,  status: TaskStatus.dueSoon),
        Task(id: '9', title: 'Analyse qualitative data',       estimatedHours: 3.0,  status: TaskStatus.toDo),
      ],
    ),
    SubjectGroup(
      id: '3', name: 'Mobile Development', colorKey: 'orange',
      totalTasks: 3, completedTasks: 1,
      tasks: [
        Task(id: '10', title: 'Set up Flutter project',  estimatedHours: 0.5, status: TaskStatus.completed),
        Task(id: '11', title: 'Build login screen UI',   estimatedHours: 2.0, status: TaskStatus.inProgress),
        Task(id: '12', title: 'Integrate Firebase auth', estimatedHours: 3.0, status: TaskStatus.toDo),
      ],
    ),
    SubjectGroup(
      id: '4', name: 'Software Engineering', colorKey: 'teal',
      totalTasks: 2, completedTasks: 0,
      tasks: [
        Task(id: '13', title: 'Design class diagram',  estimatedHours: 2.0, status: TaskStatus.toDo),
        Task(id: '14', title: 'Write unit test cases', estimatedHours: 2.0, status: TaskStatus.dueSoon),
      ],
    ),
  ];
}