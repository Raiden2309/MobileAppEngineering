enum TaskStatus {
  inProgress,
  dueToday,
  upcoming,
  toDo,
  dueSoon,
  completed,
  overdue,
}

enum BlockType { blocked, study, breakSlot }

enum BlockStatus { none, completed, inProgress, dueSoon, toDo }

enum BurnoutAlertType { burnout, allGood, warning, overload }

enum WorkloadLevel { low, moderate, high, critical }

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.toDo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.completed => 'Completed',
    TaskStatus.dueSoon => 'Due Soon',
    TaskStatus.dueToday => 'Due Today',
    TaskStatus.upcoming => 'Upcoming',
    TaskStatus.overdue => "Overdue",
  };
}
