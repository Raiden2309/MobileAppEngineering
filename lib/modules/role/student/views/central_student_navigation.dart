import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/settings/student_settings.dart';
import '../controllers/semester_progress_controller.dart';
import '../controllers/study_plan_controller.dart';
import '../controllers/tasks_controller.dart';
import '../providers/burnout_alert_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/semester_progress_provider.dart';
import '../providers/student_settings_provider.dart';
import '../providers/study_plan_provider.dart';
import '../providers/task_provider.dart';
import '../controllers/burnout_alert_controller.dart';
import '../controllers/student_settings_controller.dart';
import 'tasks/tasks.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/student/student_header.dart';
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
  int currentNavIndex = 0;
  final List<int> navHistory = [];

  late final TaskController _taskController;
  late final StudyPlanController _studyPlanController;
  late final SemesterProgressController _semesterProgressController;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    _taskController = TaskController(context.read<TasksProvider>());
    _studyPlanController = StudyPlanController(context.read<StudyPlanProvider>());
    _semesterProgressController = SemesterProgressController(context.read<SemesterProvider>());

    pages = [
      StudentDashboard(),
      MyTasksPage(controller: _taskController),
      StudyPlanPage(controller: _studyPlanController),
      SemesterProgressPage(controller: _semesterProgressController),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BurnoutAlertProvider>().loadMock();
      context.read<StudentSettingsProvider>().loadMock();
      context.read<SemesterProvider>().loadMock();
      context.read<StudyPlanProvider>().loadMock();
      context.read<TasksProvider>().loadMock();
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _studyPlanController.dispose();
    _semesterProgressController.dispose();
    super.dispose();
  }

  void goToTab(int index) {
    if (index == currentNavIndex) return;
    setState(() {
      navHistory.add(currentNavIndex);
      currentNavIndex = index;
    });
  }

  void goBack() {
    if (navHistory.isEmpty) return;
    setState(() {
      currentNavIndex = navHistory.removeLast();
    });
  }

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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: StudentHeader(
                  burnoutAlertController: BurnoutAlertController(context),
                  settingsController: StudentSettingsController(),
                  onProfileTapped: () {
                    context
                        .read<NavigationProvider>()
                        .setCurrentIndex(currentNavIndex);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StudentSettingsPage(),
                      ),
                    );
                  },
                ),
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
        onTap: goToTab,
        role: 1,
      ),
    );
  }
}