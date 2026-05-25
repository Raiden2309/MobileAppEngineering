import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/task_statistics.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/study_plan_provider.dart';
import 'widgets/dashboard_greeting.dart';
import 'widgets/current_task_popup.dart';
import 'widgets/workload_monitor.dart';
import 'widgets/task_today.dart';
import 'widgets/todays_plan.dart';

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
      context.read<DashboardProvider>().loadMock();
      context.read<StudyPlanProvider>().loadMock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            DashboardGreeting(),
            CurrentTaskPopup(),
            TaskStatisticsSection(),
            WorkloadMonitor(),
            TaskToday(),
            TodaysPlan(),
          ],
        ),
      ),
    );
  }
}