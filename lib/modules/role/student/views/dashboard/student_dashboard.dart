import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/current_task_popup.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/dashboard_greeting.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/task_statistics.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/task_today.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/todays_plan.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../models/student_subject_model.dart';
import '../../models/dashboard_models.dart'; // Ensure this model import path is correct
import '../../providers/dashboard_provider.dart';
import '../../providers/semester_progress_provider.dart';
import 'widgets/workload_monitor.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final semId = context.read<SemesterProvider>().currentSemesterId;
        context.read<StudentDashboardProvider>().updateActiveSemester(semId);
        context.read<StudentDashboardProvider>().listenToLiveDashboardStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<StudentDashboardProvider>();
    final semId = context.watch<SemesterProvider>().currentSemesterId;

    dashboardProvider.updateActiveSemester(semId);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      // FIXED: Listens to the single master enrollment query snapshot directly
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('enrollments')
            .where('studentId', isEqualTo: uid)
            .where('semester', isEqualTo: semId ?? '')
            .snapshots(),
        builder: (context, enrollmentSnapshot) {
          if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.californiaBlue),
            );
          }

          int totalCompletedTasks = 0;
          int totalPendingTasks = 0;
          double accumulatedBurnout = 0.0;
          int enrolledClassesCount = 0;

          if (enrollmentSnapshot.hasData && enrollmentSnapshot.data!.docs.isNotEmpty) {
            enrolledClassesCount = enrollmentSnapshot.data!.docs.length;
            for (var doc in enrollmentSnapshot.data!.docs) {
              final dataMap = doc.data() as Map<String, dynamic>;
              totalCompletedTasks += (dataMap['completedTasks'] as num? ?? 0).toInt();
              totalPendingTasks += (dataMap['pendingTasks'] as num? ?? 0).toInt();
              accumulatedBurnout += (dataMap['burnoutIndex'] as num? ?? 0.0).toDouble();
            }
          }

          int totalTasksCount = totalCompletedTasks + totalPendingTasks;
          double overallProgress = totalTasksCount > 0 ? (totalCompletedTasks / totalTasksCount) : 0.0;
          double meanBurnoutValue = enrolledClassesCount > 0 ? (accumulatedBurnout / enrolledClassesCount) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardGreeting(),
                const SizedBox(height: 16),

                // Live Updating Stats safely synced with alphanumeric enrollment documents
                WorkloadMonitor(
                  pendingTasksCount: totalPendingTasks,
                  completionProgress: overallProgress,
                  burnoutRatio: meanBurnoutValue,
                ),
                const SizedBox(height: 16),
                const TaskStatisticsSection(),
                const CurrentTaskPopup(),
                const TodaysPlan(),
                const SizedBox(height: 16),

                // Displays the underlying TaskToday layout block matching todayTasksStream properties
                const TaskToday(),
              ],
            ),
          );
        },
      ),
    );
  }
}