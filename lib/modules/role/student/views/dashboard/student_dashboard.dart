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
import '../../providers/dashboard_provider.dart';
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
        context.read<StudentDashboardProvider>().listenToLiveDashboardStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<StudentDashboardProvider>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<StudentSubjectModel>>(
        stream: dashboardProvider.myEnrolledClassesStream,
        builder: (context, classSnapshot) {
          if (classSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.californiaBlue),
            );
          }

          final enrolledCourses = classSnapshot.data ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('enrollments')
                .where('studentId', isEqualTo: uid)
                .snapshots(),
            builder: (context, enrollmentSnapshot) {
              int totalCompletedTasks = 0;
              int totalPendingTasks = 0;
              double accumulatedBurnout = 0.0;

              if (enrollmentSnapshot.hasData) {
                for (var doc in enrollmentSnapshot.data!.docs) {
                  final dataMap = doc.data() as Map<String, dynamic>;
                  totalCompletedTasks += (dataMap['completedTasks'] as num? ?? 0).toInt();
                  totalPendingTasks += (dataMap['pendingTasks'] as num? ?? 0).toInt();
                  accumulatedBurnout += (dataMap['burnoutIndex'] as num? ?? 0.0).toDouble();
                }
              }

              int totalTasksCount = totalCompletedTasks + totalPendingTasks;
              double overallProgress = totalTasksCount > 0 ? (totalCompletedTasks / totalTasksCount) : 0.0;
              double meanBurnoutValue = enrolledCourses.isNotEmpty ? (accumulatedBurnout / enrolledCourses.length) : 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardGreeting(),
                    const SizedBox(height: 16),
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
                    const TaskToday(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}