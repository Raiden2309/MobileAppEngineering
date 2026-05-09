import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/tasks/widget/task_card.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../models/tasks_model.dart';

// Data

final List<SubjectGroup> subjectGroups = [
  SubjectGroup(
    name: 'CT124 System Proposal',
    colorKey: 'blue',
    totalTasks: 11,
    completedTasks: 7,
    tasks: [
      Task(name: 'Complete system proposal introduction', estimatedTime: 'Est. 1.5 hrs', status: TaskStatus.completed),
      Task(name: 'Create system context diagram',         estimatedTime: 'Est. 1 hr',   status: TaskStatus.completed),
      Task(name: 'Write use case diagrams',               estimatedTime: 'Est. 2 hrs',  status: TaskStatus.inProgress),
      Task(name: 'Prepare functional requirements',       estimatedTime: 'Est. 1 hr',   status: TaskStatus.dueSoon),
      Task(name: 'Write non-functional requirements',     estimatedTime: 'Est. 1 hr',   status: TaskStatus.toDo),
    ],
  ),
  SubjectGroup(
    name: 'Research Methods',
    colorKey: 'yellow',
    totalTasks: 5,
    completedTasks: 2,
    tasks: [
      Task(name: 'Review affinity analysis notes', estimatedTime: 'Est. 45 min',  status: TaskStatus.completed),
      Task(name: 'Literature review draft',         estimatedTime: 'Est. 2 hrs',   status: TaskStatus.completed),
      Task(name: 'Prepare survey questions',        estimatedTime: 'Est. 1.5 hrs', status: TaskStatus.dueSoon),
      Task(name: 'Analyse qualitative data',        estimatedTime: 'Est. 3 hrs',   status: TaskStatus.toDo),
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
    colorKey: 'lime',
    totalTasks: 4,
    completedTasks: 0,
    tasks: [
      Task(name: 'Design class diagram',  estimatedTime: 'Est. 2 hrs', status: TaskStatus.toDo),
      Task(name: 'Write unit test cases', estimatedTime: 'Est. 2 hrs', status: TaskStatus.dueSoon),
    ],
  ),
];

// MyTasksPage

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => MyTasksPageState();
}

class MyTasksPageState extends State<MyTasksPage> {
  String activeFilter = 'all';

  static const filters = [
    ('all',        'All'),
    ('inProgress', 'In Progress'),
    ('toDo',       'To Do'),
    ('completed',  'Completed'),
    ('dueSoon',    'Due Soon'),
  ];

  List<Task> filterTasks(List<Task> tasks) {
    if (activeFilter == 'all') return tasks;
    return tasks.where((t) {
      switch (activeFilter) {
        case 'completed':  return t.status == TaskStatus.completed;
        case 'inProgress': return t.status == TaskStatus.inProgress;
        case 'toDo':       return t.status == TaskStatus.toDo;
        case 'dueSoon':    return t.status == TaskStatus.dueSoon;
        default:           return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const totalTasks = 20;
    const completedTasks = 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: FontStyles.titleLarge,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Semester 4 · $completedTasks of $totalTasks completed',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Filter chips ──────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final (key, label) = filters[i];
              final isActive = activeFilter == key;
              return GestureDetector(
                onTap: () => setState(() => activeFilter = key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: isActive
                      ? AppColors.glassBadge()
                      : BoxDecoration(
                    color: Colors.white.withValues(
                        alpha: AppColors.glassTileOpacity),
                    borderRadius: BorderRadius.circular(
                        AppColors.glassBadgeBorderRadius),
                    border: Border.all(
                      color: Colors.white.withValues(
                          alpha: AppColors.glassBorderOpacity),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                      color: isActive
                          ? AppColors.black
                          : AppColors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Task list ─────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...subjectGroups.map((group) {
                final filtered = filterTasks(group.tasks);
                if (filtered.isEmpty) return const SizedBox.shrink();
                return SubjectGroupSection(
                  group: SubjectGroup(
                    name: group.name,
                    colorKey: group.colorKey,
                    totalTasks: group.totalTasks,
                    completedTasks: group.completedTasks,
                    tasks: filtered,
                  ),
                );
              }),

              const SizedBox(height: 8),

              // ── Add task button ────────────────────────
              Container(
                width: double.infinity,
                decoration: AppColors.glassCard(),
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Add Task…')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18, color: AppColors.black),
                  label: const Text('Add new task'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: BorderSide.none,
                    backgroundColor: AppColors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
                    ),
                    textStyle: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}