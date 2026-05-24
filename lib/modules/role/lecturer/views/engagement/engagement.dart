import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/average_completion_card.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/engagement_filter_chips.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/engagement_section_header.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/student_engagement.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/student_status_grid.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/engagement/widget/subject_completion_card.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

import '../../providers/engagement_provider.dart';


class LecturerEngagementPage extends StatelessWidget {
  const LecturerEngagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final students = context.watch<EngagementProvider>().filteredStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              const EngagementFilterChips(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AvgCompletionCard(),
                const SizedBox(height: 20),
                const EngagementSectionHeader(title: 'Student Status'),
                const SizedBox(height: 10),
                const StudentStatusGrid(),
                const SizedBox(height: 20),
                const SubjectCompletionCard(),
                const EngagementSectionHeader(title: 'Student Activity'),
                const SizedBox(height: 4),
                Text(
                  'Workload level and last active time per student.',
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 10),
                ...students.map((s) => Padding(
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