import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/settings/student_settings.dart';
import '../controllers/burnout_alert_controller.dart';
import '../controllers/semester_progress_controller.dart';
import '../controllers/student_settings_controller.dart';
import '../controllers/study_plan_controller.dart';
import '../controllers/tasks_controller.dart';
import '../providers/burnout_alert_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/semester_progress_provider.dart';
import '../providers/student_settings_provider.dart';
import '../providers/study_plan_provider.dart';
import '../providers/task_provider.dart';
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
  // ── Burnout ───────────────────────────────────────────────
  final BurnoutAlertController burnoutController = BurnoutAlertController();
  late final BurnoutAlertProvider burnoutProvider;

  // ── Settings ──────────────────────────────────────────────
  final StudentSettingsController settingsController =
  StudentSettingsController();
  late final StudentSettingsProvider settingsProvider;

  // ── Semester progress ─────────────────────────────────────
  late final SemesterProvider semesterProvider;
  late final SemesterProgressController semesterController;

  // ── Study plan ────────────────────────────────────────────
  late final StudyPlanProvider studyPlanProvider;
  late final StudyPlanController studyPlanController;

  // ── Tasks ─────────────────────────────────────────────────
  late final TasksProvider tasksProvider;
  late final TaskController taskController;

  // ── Navigation ────────────────────────────────────────────
  final NavigationProvider navigationProvider = NavigationProvider();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // Burnout
    burnoutProvider = BurnoutAlertProvider(burnoutController);
    burnoutProvider.loadMock();

    // Settings
    settingsProvider = StudentSettingsProvider(settingsController);
    settingsProvider.loadMock();

    // Semester progress
    semesterProvider = SemesterProvider();
    semesterController = SemesterProgressController(semesterProvider);
    semesterProvider.loadMock();

    // Study plan
    studyPlanProvider = StudyPlanProvider();
    studyPlanController = StudyPlanController(studyPlanProvider);
    studyPlanProvider.loadMock();

    // Tasks
    tasksProvider = TasksProvider();
    taskController = TaskController(tasksProvider);
    tasksProvider.loadMock();

    pages = [
      const StudentDashboard(),
      MyTasksPage(controller: taskController),
      StudyPlanPage(controller: studyPlanController),
      SemesterProgressPage(controller: semesterController),
    ];
  }

  int currentNavIndex = 0;
  final List<int> navHistory = [];

  void goToTab(int index) {
    if (index == currentNavIndex) return;
    setState(() {
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
  void dispose() {
    burnoutController.dispose();
    settingsController.dispose();
    semesterController.dispose();
    studyPlanController.dispose();
    taskController.dispose();
    super.dispose();
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
              if (currentNavIndex != 4)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: StudentHeader(
                    burnoutAlertController: burnoutController,
                    settingsController: settingsController,
                    onProfileTapped: () {
                      navigationProvider.setCurrentIndex(currentNavIndex);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudentSettingsPage(
                            controller: settingsController,
                            navigationProvider: navigationProvider,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 68),
                  child: IndexedStack(index: currentNavIndex, children: pages),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onTap: goToTab, role: 1,
      ),
    );
  }
}