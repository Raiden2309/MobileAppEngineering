import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class ClassDetailPage extends StatelessWidget {
  final String name;
  final String code;
  final String students;
  final String avgDone;
  final String atRisk;
  final Color accentColor;
  final Color atRiskColor;
  final String semester;

  const ClassDetailPage({
    super.key,
    required this.name,
    required this.code,
    required this.students,
    required this.avgDone,
    required this.atRisk,
    required this.accentColor,
    required this.atRiskColor,
    required this.semester,
  });

  BoxDecoration _whiteCard() => BoxDecoration(
    color: AppColors.white.withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
    border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildBackNav(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(context),
                      _buildCompletionBar(),
                      const SizedBox(height: 16),
                      _buildWorkloadMonitor(),
                      const SizedBox(height: 16),
                      _buildStudentList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: _whiteCard(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chevron_left, color: AppColors.black, size: 18),
                  Text(
                    'All Classes',
                    style: TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            code.split(' ·').first,
            style: TextStyle(
              fontSize: FontStyles.titleMedium,
              fontWeight: FontStyles.weightHeavy,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontStyles.weightHeavy,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${code.split('·').first.trim()} · Diploma in Computer Science · Sem 4',
                    style: TextStyle(
                      fontSize: FontStyles.titleTiny,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: _whiteCard(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Class Code',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.black.withValues(alpha: 0.5),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${code.split(' ·').first}–A2',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.californiaBlue,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '📋 Copy',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.californiaBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _miniStat('Students', students, AppColors.californiaBlue),
            const SizedBox(width: 8),
            _miniStat('Avg Done', avgDone, AppColors.mikadoYellow),
            const SizedBox(width: 8),
            _miniStat('At Risk', atRisk, atRiskColor),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: _whiteCard(),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontStyles.weightHeavy,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBar() {
    final pct = double.tryParse(avgDone.replaceAll('%', '')) ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Completion',
                style: TextStyle(
                  fontSize: FontStyles.titleTiny,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              Text(
                avgDone,
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.californiaBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: AppColors.black.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.californiaBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '173 of 308 tasks completed across all students',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadMonitor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workload Monitor',
          style: TextStyle(
            fontSize: FontStyles.titleMedium,
            fontWeight: FontStyles.weightHeavy,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _whiteCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class workload distribution',
                style: TextStyle(
                  fontSize: FontStyles.titleTiny,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              _workloadBar('Low', 11, 28, AppColors.greenSheen),
              const SizedBox(height: 8),
              _workloadBar('Moderate', 16, 28, AppColors.mikadoYellow),
              const SizedBox(height: 8),
              _workloadBar('High / At Risk', 1, 28, AppColors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workloadBar(String label, int count, int total, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 8,
              backgroundColor: AppColors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontStyles.weightHeavy,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    final studentList = [
      _StudentData('AH', 'Amirul Haikal', '7/11 tasks · 🔥 Burnout risk', 'At Risk', AppColors.red),
      _StudentData('AN', 'Ahmad Naqib', '11/11 tasks · All done', '100%', AppColors.californiaBlue),
      _StudentData('SP', 'Siti Putri', '10/11 tasks', '91%', AppColors.californiaBlue),
      _StudentData('HZ', 'Haziq Zulkifli', '4/11 tasks · 4 overdue', 'Behind', AppColors.mikadoYellow),
      _StudentData('RA', 'Raihana Azlan', '8/11 tasks', '73%', AppColors.californiaBlue),
      _StudentData('FI', 'Farid Iskandar', '6/11 tasks', '55%', AppColors.mikadoYellow),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Students',
              style: TextStyle(
                fontSize: FontStyles.titleMedium,
                fontWeight: FontStyles.weightHeavy,
                color: AppColors.black,
              ),
            ),
            const Text(
              '+ Add',
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                color: AppColors.californiaBlue,
                fontWeight: FontStyles.weightMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...studentList.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: _whiteCard(),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: s.chipColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      s.initials,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontStyles.weightHeavy,
                        color: s.chipColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: FontStyles.titleSmall,
                          fontWeight: FontStyles.weightMedium,
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        s.meta,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: s.chipColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.chip,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontStyles.weightMedium,
                      color: s.chipColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _StudentData {
  final String initials, name, meta, chip;
  final Color chipColor;
  const _StudentData(this.initials, this.name, this.meta, this.chip, this.chipColor);
}