import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/semester_progress/widget/overall_progress_card.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/semester_progress/widget/subject_progress.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/semester_progress/widget/timeline_progress_card.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../controllers/semester_progress_controller.dart';
import '../../models/semester_progress_model.dart';
import '../settings/bottom_sheet_widgets/subjects_sheet.dart';

class SemesterProgressPage extends StatelessWidget {
  final SemesterProgressController controller;

  const SemesterProgressPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data ?? SemesterProgressModel.mockData();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.californiaBlue, AppColors.greenSheen],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semester Progress',
              style: TextStyle(
                color: AppColors.black,
                fontSize: FontStyles.titleLarge,
                fontWeight: FontStyles.titleWeight,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${data.semesterName} · ${data.dateRange}',
              style: TextStyle(color: AppColors.black, fontSize: 13),
            ),

            const SizedBox(height: 20),

            OverallProgressCard(model: data),

            const SizedBox(height: 14),

            TimelineCard(model: data),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Subjects',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: FontStyles.titleMedium,
                    fontWeight: FontStyles.weightMedium,
                  ),
                ),
                GestureDetector(
                  onTap: () => SubjectsSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: AppColors.white),
                        SizedBox(width: 4),
                        Text(
                          'Add Subject',
                          style: TextStyle(
                            fontSize: FontStyles.titleSmall,
                            fontWeight: FontStyles.weightMedium,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...data.subjects.map((s) => SubjectProgressCard(subject: s)),
          ],
        ),
      ),
    );
  }
}