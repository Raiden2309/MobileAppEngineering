import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class LecturerAlertsPage extends StatefulWidget {
  const LecturerAlertsPage({super.key});

  @override
  State<LecturerAlertsPage> createState() => _LecturerAlertsPageState();
}

class _LecturerAlertsPageState extends State<LecturerAlertsPage> {
  String selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'burnout', 'label': 'Burnout'},
    {'key': 'behind', 'label': 'Falling Behind'},
    {'key': 'read', 'label': 'Read'},
  ];

  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'burnout',
      'emoji': '🔥',
      'title': 'Burnout Risk — Amirul Haikal',
      'meta': 'CT124 System Proposal · Studied 6+ hrs/day for 4 days, task completion dropped to 30%',
      'color': AppColors.red,
      'unread': true,
      'read': false,
    },
    {
      'type': 'burnout',
      'emoji': '🔥',
      'title': 'Burnout Risk — Nurul Farhana',
      'meta': 'RM302 Research Methods · High workload pattern detected, 2 tasks overdue',
      'color': AppColors.red,
      'unread': true,
      'read': false,
    },
    {
      'type': 'behind',
      'emoji': '⚠️',
      'title': 'Falling Behind — Haziq Zulkifli',
      'meta': 'CT124 System Proposal · 4 tasks overdue, no activity in 3 days',
      'color': AppColors.mikadoYellow,
      'unread': false,
      'read': false,
    },
    {
      'type': 'behind',
      'emoji': '⚠️',
      'title': 'Falling Behind — Izzati Roslan',
      'meta': 'MOB401 Mobile Development · Completion rate dropped from 70% to 35% this week',
      'color': AppColors.mikadoYellow,
      'unread': false,
      'read': false,
    },
    {
      'type': 'behind',
      'emoji': '📋',
      'title': 'Low Engagement — Farid Iskandar',
      'meta': 'RM302 Research Methods · Only 2 of 5 tasks started this semester',
      'color': AppColors.californiaBlue,
      'unread': false,
      'read': false,
    },
    {
      'type': 'read',
      'emoji': '🔥',
      'title': 'Burnout Risk — Siti Hajar · Resolved',
      'meta': 'CT124 · Marked as reviewed 2 days ago',
      'color': null,
      'unread': false,
      'read': true,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (selectedFilter == 'all') return _alerts;
    if (selectedFilter == 'read') return _alerts.where((a) => a['read'] == true).toList();
    return _alerts.where((a) => a['type'] == selectedFilter && a['read'] == false).toList();
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
                'Alerts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Student at-risk & burnout notifications',
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
              children: _filtered.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AlertRow(alert: a),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  final Map<String, dynamic> alert;
  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final bool isRead = alert['read'] == true;
    final bool isUnread = alert['unread'] == true;
    final Color dotColor = alert['color'] ?? Colors.white.withValues(alpha: 0.3);

    return Opacity(
      opacity: isRead ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top row: dot + title + unread badge ──
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${alert['emoji']} ${alert['title']}',
                    style: TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightHeavy,
                      color: isRead
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.black,
                    ),
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // ── Meta ─────────────────────────────────
            Text(
              alert['meta'],
              style: TextStyle(
                fontSize: FontStyles.titleTiny,
                color: AppColors.legendText,
                height: 1.4,
              ),
            ),

            // ── Action link ───────────────────────────
            if (!isRead) ...[
              const SizedBox(height: 8),
              Text(
                'View student profile ›',
                style: TextStyle(
                  fontSize: FontStyles.titleTiny,
                  fontWeight: FontStyles.weightHeavy,
                  color: dotColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}