enum BlockType { blocked, study, breakSlot }

enum BlockStatus { none, completed, inProgress, dueSoon, toDo }

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

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  String get statusLabel {
    switch (status) {
      case BlockStatus.completed:
        return '✓ Done';
      case BlockStatus.inProgress:
        return 'In Progress';
      case BlockStatus.dueSoon:
        return 'Due Soon';
      case BlockStatus.toDo:
        return 'To Do';
      case BlockStatus.none:
        return '';
    }
  }
}

class DayPlan {
  final DateTime date;
  final List<StudyBlock> blocks;
  const DayPlan({required this.date, required this.blocks});
}

class WeekPlan {
  final List<DayPlan> days;
  final DateTime lastUpdated;

  const WeekPlan({required this.days, required this.lastUpdated});

  factory WeekPlan.mock() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return WeekPlan(
      lastUpdated: now,
      days: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday =
            day.day == now.day && day.month == now.month && day.year == now.year;
        final isPast = day.isBefore(DateTime(now.year, now.month, now.day));

        return DayPlan(
          date: day,
          blocks: isToday
              ? todayBlocks
              : isPast
              ? pastBlocks
              : [],
        );
      }),
    );
  }

  static const List<StudyBlock> todayBlocks = [
    StudyBlock(
      title: 'CT124 Lecture',
      subject: 'Blocked',
      startTime: '8:00',
      durationMinutes: 60,
      type: BlockType.blocked,
    ),
    StudyBlock(
      title: 'Review affinity analysis notes',
      subject: 'Research Methods',
      startTime: '9:00',
      durationMinutes: 45,
      type: BlockType.study,
      status: BlockStatus.completed,
    ),
    StudyBlock(
      title: 'Short break',
      subject: 'Recommended',
      startTime: '9:45',
      durationMinutes: 15,
      type: BlockType.breakSlot,
    ),
    StudyBlock(
      title: 'Write use case diagrams',
      subject: 'CT124 System Proposal',
      startTime: '10:00',
      durationMinutes: 120,
      type: BlockType.study,
      status: BlockStatus.inProgress,
    ),
    StudyBlock(
      title: 'Lunch break',
      subject: 'Recommended',
      startTime: '12:00',
      durationMinutes: 45,
      type: BlockType.breakSlot,
    ),
    StudyBlock(
      title: 'Draft literature review',
      subject: 'Research Methods',
      startTime: '13:00',
      durationMinutes: 90,
      type: BlockType.study,
      status: BlockStatus.toDo,
    ),
    StudyBlock(
      title: 'Prepare presentation slides',
      subject: 'CT124 System Proposal',
      startTime: '14:30',
      durationMinutes: 60,
      type: BlockType.study,
      status: BlockStatus.toDo,
    ),
  ];

  static const List<StudyBlock> pastBlocks = [
    StudyBlock(
      title: 'Morning study session',
      subject: 'Research Methods',
      startTime: '9:00',
      durationMinutes: 90,
      type: BlockType.study,
      status: BlockStatus.completed,
    ),
    StudyBlock(
      title: 'Assignment review',
      subject: 'CT124',
      startTime: '11:00',
      durationMinutes: 60,
      type: BlockType.study,
      status: BlockStatus.completed,
    ),
  ];
}