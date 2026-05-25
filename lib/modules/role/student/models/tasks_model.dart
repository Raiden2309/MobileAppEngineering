import 'app_enums.dart';

class Task {
  final String name;
  final String estimatedTime;
  final TaskStatus status;

  const Task({
    required this.name,
    required this.estimatedTime,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case TaskStatus.completed:  return 'Completed';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.toDo:       return 'To Do';
      case TaskStatus.dueSoon:    return 'Due Soon';
      default:                    return '';
    }
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name:          json['name'] as String,
      estimatedTime: json['estimated_time'] as String,
      status:        TaskStatus.values.byName(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'name':           name,
    'estimated_time': estimatedTime,
    'status':         status.name,
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

  static List<SubjectGroup> mockData() {
    return const [
      SubjectGroup(
        name: 'CT124 System Proposal',
        colorKey: 'blue',
        totalTasks: 11,
        completedTasks: 7,
        tasks: [
          Task(name: 'Complete system proposal introduction', estimatedTime: 'Est. 1.5 hrs', status: TaskStatus.completed),
          Task(name: 'Create system context diagram',         estimatedTime: 'Est. 1 hr',    status: TaskStatus.completed),
          Task(name: 'Write use case diagrams',               estimatedTime: 'Est. 2 hrs',   status: TaskStatus.inProgress),
          Task(name: 'Prepare functional requirements',       estimatedTime: 'Est. 1 hr',    status: TaskStatus.dueSoon),
          Task(name: 'Write non-functional requirements',     estimatedTime: 'Est. 1 hr',    status: TaskStatus.toDo),
        ],
      ),
      SubjectGroup(
        name: 'Research Methods',
        colorKey: 'yellow',
        totalTasks: 5,
        completedTasks: 2,
        tasks: [
          Task(name: 'Review affinity analysis notes', estimatedTime: 'Est. 45 min',  status: TaskStatus.completed),
          Task(name: 'Literature review draft',        estimatedTime: 'Est. 2 hrs',   status: TaskStatus.completed),
          Task(name: 'Prepare survey questions',       estimatedTime: 'Est. 1.5 hrs', status: TaskStatus.dueSoon),
          Task(name: 'Analyse qualitative data',       estimatedTime: 'Est. 3 hrs',   status: TaskStatus.toDo),
        ],
      ),
      SubjectGroup(
        name: 'Mobile Development',
        colorKey: 'orange',
        totalTasks: 4,
        completedTasks: 1,
        tasks: [
          Task(name: 'Set up Flutter project',  estimatedTime: 'Est. 30 min', status: TaskStatus.completed),
          Task(name: 'Build login screen UI',   estimatedTime: 'Est. 2 hrs',  status: TaskStatus.inProgress),
          Task(name: 'Integrate Firebase auth', estimatedTime: 'Est. 3 hrs',  status: TaskStatus.toDo),
        ],
      ),
      SubjectGroup(
        name: 'Software Engineering',
        colorKey: 'teal',
        totalTasks: 4,
        completedTasks: 0,
        tasks: [
          Task(name: 'Design class diagram',  estimatedTime: 'Est. 2 hrs', status: TaskStatus.toDo),
          Task(name: 'Write unit test cases', estimatedTime: 'Est. 2 hrs', status: TaskStatus.dueSoon),
        ],
      ),
    ];
  }
}