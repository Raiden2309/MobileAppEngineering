import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/completion_bar.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/engagement_status_card.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/student_engagement.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class LecturerEngagementPage extends StatefulWidget {
  const LecturerEngagementPage({super.key});

  @override
  State<LecturerEngagementPage> createState() => LecturerEngagementPageState();
}

class LecturerEngagementPageState extends State<LecturerEngagementPage> {
  String selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'key': 'all', 'label': 'All Classes'},
    {'key': 'ct124', 'label': 'CT124'},
    {'key': 'rm302', 'label': 'RM302'},
    {'key': 'mob401', 'label': 'MOB401'},
  ];

  final List<Map<String, dynamic>> _students = [
    {
      'initials': 'AH',
      'name': 'Amirul Haikal',
      'meta': 'CT124 · Last active: today',
      'workload': 'High',
      'workloadColor': AppColors.red,
      'classes': ['ct124'],
    },
    {
      'initials': 'AN',
      'name': 'Ahmad Naqib',
      'meta': 'CT124 · Last active: today',
      'workload': 'Low',
      'workloadColor': AppColors.greenSheen,
      'classes': ['ct124'],
    },
    {
      'initials': 'HZ',
      'name': 'Haziq Zulkifli',
      'meta': 'CT124 · Last active: 3 days ago',
      'workload': 'Medium',
      'workloadColor': AppColors.mikadoYellow,
      'classes': ['ct124'],
    },
    {
      'initials': 'FI',
      'name': 'Farid Iskandar',
      'meta': 'RM302 · Last active: 5 days ago',
      'workload': 'Inactive',
      'workloadColor': null,
      'classes': ['rm302'],
    },
  ];

  List<Map<String, dynamic>> get _filteredStudents {
    if (selectedFilter == 'all') return _students;
    return _students
        .where((s) => (s['classes'] as List).contains(selectedFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Fixed header ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Engagement',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on subject-related activity only',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),

              // ── Filter chips ──────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isActive = selectedFilter == f['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFilter = f['key']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            f['label'],
                            style: TextStyle(
                              fontSize: FontStyles.titleSmall,
                              fontWeight: isActive
                                  ? FontStyles.weightHeavy
                                  : FontStyles.weightMedium,
                              color: AppColors.black
                                  .withValues(alpha: isActive ? 1.0 : 0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Scrollable body ───────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Avg completion ring card ──────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 0.58,
                              strokeWidth: 5,
                              backgroundColor:
                              AppColors.greenSheen.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.greenSheen),
                              strokeCap: StrokeCap.round,
                            ),
                            Text(
                              '58%',
                              style: TextStyle(
                                fontSize: FontStyles.titleSmall,
                                fontWeight: FontStyles.weightHeavy,
                                color: AppColors.greenSheen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avg Subject Completion',
                            style: TextStyle(
                              fontSize: FontStyles.titleSmall,
                              fontWeight: FontStyles.weightMedium,
                              color: AppColors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '58%',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontStyles.weightHeavy,
                              color: AppColors.greenSheen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'tasks under your subjects · 72 students',
                            style: TextStyle(
                              fontSize: FontStyles.titleTiny,
                              color: AppColors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Student status ────────────────────
                SectionHeader(title: 'Student Status'),
                const SizedBox(height: 10),
                Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(
                            child: StatusCard(
                              label: 'On Track',
                              count: '54',
                              sub: 'students',
                              icon: Icons.check_circle_outline,
                              color: AppColors.greenSheenDark,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: StatusCard(
                              label: 'Falling Behind',
                              count: '16',
                              sub: 'students',
                              icon: Icons.trending_down_rounded,
                              color: AppColors.mikadoYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(
                            child: StatusCard(
                              label: 'Burnout Risk',
                              count: '2',
                              sub: 'students',
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.red,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: StatusCard(
                              label: 'Inactive',
                              count: '4',
                              sub: 'no activity 3+ days',
                              icon: Icons.hourglass_empty_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Subject completion bars ───────────
                SectionHeader(title: 'Subject Completion'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppColors.glassCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average completion rate of tasks students have tagged under each of your subjects.',
                        style: TextStyle(
                          fontSize: FontStyles.titleTiny,
                          color: AppColors.black.withValues(alpha: 0.5),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CompletionBar(
                          label: 'CT124', value: 0.62, color: AppColors.californiaBlue),
                      const SizedBox(height: 10),
                      CompletionBar(
                          label: 'RM302', value: 0.54, color: AppColors.mikadoYellow),
                      const SizedBox(height: 10),
                      CompletionBar(
                          label: 'MOB401', value: 0.59, color: AppColors.softPurple),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Student activity ──────────────────
                SectionHeader(title: 'Student Activity'),
                const SizedBox(height: 4),
                Text(
                  'Workload level and last active time per student.',
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 10),
                ..._filteredStudents.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StudentRow(student: s),
                )),

              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section header ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: FontStyles.titleMedium,
        fontWeight: FontStyles.weightHeavy,
        color: AppColors.black,
      ),
    );
  }
}