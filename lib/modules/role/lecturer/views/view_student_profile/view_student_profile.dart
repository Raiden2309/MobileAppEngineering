import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../models/class_enrollment_model.dart';
import 'widgets/student_profile_header.dart';
import 'widgets/student_stats_row.dart';
import 'widgets/student_task_progress.dart';
import 'widgets/student_burnout_breakdown.dart';

class ViewStudentProfilePage extends StatelessWidget {
  final ClassStudentModel student;

  const ViewStudentProfilePage({super.key, required this.student});

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Student Profile',
                        style: TextStyle(
                          fontSize: FontStyles.titleLarge,
                          fontWeight: FontStyles.weightHeavy,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StudentProfileHeader(student: student),
                      const SizedBox(height: 20),
                      StudentStatsRow(student: student),
                      const SizedBox(height: 20),
                      StudentTaskProgress(student: student),
                      const SizedBox(height: 20),
                      StudentBurnoutBreakdown(student: student),
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
}