import 'package:flutter/material.dart';
import 'tasks/tasks.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/student_header.dart';
import 'dashboard/student_dashboard.dart';
import 'study_plan/study_plan.dart';
import 'semester_progress/semester_progress.dart';

class CentralStudentNavigation extends StatefulWidget {
  const CentralStudentNavigation({super.key});

  @override
  State<CentralStudentNavigation> createState() =>
      CentralStudentNavigationState();
}

class CentralStudentNavigationState extends State<CentralStudentNavigation> {
  void goToTab(int index) {
    setState(() {
      currentNavIndex = index;
    });
  }

  int currentNavIndex = 0;

  final List<Widget> pages = const [
    StudentDashboard(),
    MyTasksPage(),
    StudyPlanPage(),
    SemesterProgressPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
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
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: StudentHeader(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 68),
                  child: IndexedStack(
                    index: currentNavIndex,
                    children: pages,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onTap: (i) => setState(() => currentNavIndex = i),
      ),
    );
  }
}