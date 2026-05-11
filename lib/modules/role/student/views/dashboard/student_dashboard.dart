import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/current_task_popup.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/stat_card.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/task_today.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/todays_plan.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/widgets/workload_monitor.dart';
import '../../controllers/student_dashboard_controller.dart';
import 'widgets/dashboard_greeting.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => StudentDashboardState();
}

class StudentDashboardState extends State<StudentDashboard> {
  final StudentDashboardController controller = StudentDashboardController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardGreeting(controller: controller),
            const CurrentTaskPopup(),
            const TaskStatisticsSection(),
            const WorkloadMonitor(),
            const TaskToday(),
            const TodaysPlan(),
          ],
        ),
      ),
    );
  }
}