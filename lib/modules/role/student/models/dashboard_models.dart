// Enums

enum TaskStatus { done, inProgress, dueToday, upcoming }

enum BlockType { blocked, study, breakSlot }

enum BlockStatus { none, completed, inProgress, dueSoon, toDo }

// ── Study Block ───────────────────────────────────────────

class StudyBlock {
  final String title;
  final String? subject;
  final String startTime;
  final int durationMinutes;
  final BlockType type;
  final BlockStatus status;

  const StudyBlock({
    required this.title,
    this.subject,
    required this.startTime,
    required this.durationMinutes,
    required this.type,
    this.status = BlockStatus.none,
  });

  factory StudyBlock.fromJson(Map<String, dynamic> json) {
    return StudyBlock(
      title:           json['title'] as String,
      subject:         json['subject'] as String?,
      startTime:       json['start_time'] as String,
      durationMinutes: json['duration_minutes'] as int,
      type:            BlockType.values.byName(json['type'] as String),
      status:          json['status'] != null
          ? BlockStatus.values.byName(json['status'] as String)
          : BlockStatus.none,
    );
  }

  // Computes end time string (e.g. "10:00" + 120min → "12:00")
  String get endTime {
    final parts = startTime.split(':');
    final startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final endMinutes = startMinutes + durationMinutes;
    final h = endMinutes ~/ 60;
    final m = endMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  String get statusLabel {
    switch (status) {
      case BlockStatus.completed:  return '✓ Done';
      case BlockStatus.inProgress: return 'In Progress';
      case BlockStatus.dueSoon:    return 'Due Soon';
      case BlockStatus.toDo:       return 'To Do';
      case BlockStatus.none:       return '';
    }
  }
}

// ── Day Plan ─────────────────────────────────────────────

class DayPlan {
  final DateTime date;
  final List<StudyBlock> blocks;

  const DayPlan({required this.date, required this.blocks});

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      date:   DateTime.parse(json['date'] as String),
      blocks: (json['blocks'] as List<dynamic>)
          .map((b) => StudyBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Week Plan ─────────────────────────────────────────────

class WeekPlan {
  final List<DayPlan> days;
  final DateTime lastUpdated;

  const WeekPlan({required this.days, required this.lastUpdated});

  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      days: (json['days'] as List<dynamic>)
          .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  factory WeekPlan.mockData() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return WeekPlan(
      lastUpdated: now,
      days: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day.day == now.day &&
            day.month == now.month &&
            day.year == now.year;
        final isPast = day.isBefore(DateTime(now.year, now.month, now.day));

        return DayPlan(
          date:   day,
          blocks: isToday ? todayBlocks : isPast ? pastBlocks : [],
        );
      }),
    );
  }

  static const List<StudyBlock> todayBlocks = [
    StudyBlock(title: 'CT124 Lecture',                  subject: 'Blocked',              startTime: '8:00',  durationMinutes: 60,  type: BlockType.blocked),
    StudyBlock(title: 'Review affinity analysis notes', subject: 'Research Methods',      startTime: '9:00',  durationMinutes: 45,  type: BlockType.study,     status: BlockStatus.completed),
    StudyBlock(title: 'Short break',                    subject: 'Recommended',           startTime: '9:45',  durationMinutes: 15,  type: BlockType.breakSlot),
    StudyBlock(title: 'Write use case diagrams',        subject: 'CT124 System Proposal', startTime: '10:00', durationMinutes: 120, type: BlockType.study,     status: BlockStatus.inProgress),
    StudyBlock(title: 'Lunch break',                    subject: 'Recommended',           startTime: '12:00', durationMinutes: 45,  type: BlockType.breakSlot),
    StudyBlock(title: 'Draft literature review',        subject: 'Research Methods',      startTime: '13:00', durationMinutes: 90,  type: BlockType.study,     status: BlockStatus.toDo),
    StudyBlock(title: 'Prepare presentation slides',    subject: 'CT124 System Proposal', startTime: '14:30', durationMinutes: 60,  type: BlockType.study,     status: BlockStatus.toDo),
  ];

  static const List<StudyBlock> pastBlocks = [
    StudyBlock(title: 'Morning study session', subject: 'Research Methods', startTime: '9:00',  durationMinutes: 90, type: BlockType.study, status: BlockStatus.completed),
    StudyBlock(title: 'Assignment review',     subject: 'CT124',            startTime: '11:00', durationMinutes: 60, type: BlockType.study, status: BlockStatus.completed),
  ];
}

// ── Dashboard Models ──────────────────────────────────────

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

  factory DashboardModel.mockData() {
    return DashboardModel(
      summary: DashboardSummary(
        userName: 'John',
        taskCountToday: 4,
        date: DateTime(2026, 5, 8),
      ),
      stats: const DashboardStats(
        tasksDone:   10,
        totalTasks:  20,
        dueSoon:     3,
        dueSoonDays: 3,
        overdue:     1,
        currentWeek: 8,
        totalWeeks:  14,
      ),
      currentTask: const CurrentTask(
        title:    'Write use case diagrams',
        subtitle: 'CT124 System Proposal · 2 hrs',
        status:   TaskStatus.inProgress,
      ),
      workloadPlan: const WorkloadPlan(
        planLabel: "Today's Plan",
        tasks:     [],
      ),
      todayTasks: const [
        TaskItem(title: 'Review affinity analysis notes', subtitle: 'Research Methods · 45 min',     status: TaskStatus.done,       checked: true),
        TaskItem(title: 'Write use case diagrams',        subtitle: 'CT124 System Proposal · 2 hrs', status: TaskStatus.inProgress),
        TaskItem(title: 'Prepare functional requirements',subtitle: 'CT124 System Proposal · 1 hr',  status: TaskStatus.dueToday),
        TaskItem(title: 'Prepare survey questions',       subtitle: 'Research Methods · 1.5 hrs',    status: TaskStatus.upcoming),
      ],
    );
  }
}

// ── Dashboard Summary ─────────────────────────────────────

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

// ── Dashboard Stats ───────────────────────────────────────

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
      tasksDone:    json['tasks_done'] as int,
      totalTasks:   json['total_tasks'] as int,
      dueSoon:      json['due_soon'] as int,
      dueSoonDays:  json['due_soon_days'] as int,
      overdue:      json['overdue'] as int,
      currentWeek:  json['current_week'] as int,
      totalWeeks:   json['total_weeks'] as int,
    );
  }
}

// ── Current Task ──────────────────────────────────────────

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

// ── Workload Plan ─────────────────────────────────────────

class WorkloadPlan {
  final String planLabel;
  final List<TaskItem> tasks;

  const WorkloadPlan({
    required this.planLabel,
    required this.tasks,
  });

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

// ── Task Item ─────────────────────────────────────────────

class TaskItem {
  final String title;
  final String subtitle;
  final TaskStatus status;
  final bool checked;

  const TaskItem({
    required this.title,
    required this.subtitle,
    required this.status,
    this.checked = false,
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
    );
  }
}