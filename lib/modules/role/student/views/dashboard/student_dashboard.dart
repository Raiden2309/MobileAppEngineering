import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../lecturer/models/class_student_model.dart';
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
      context.read<StudentDashboardProvider>().loadMock();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.read<StudentDashboardProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<ClassStudentModel>>(
        stream: dashboardProvider.myEnrolledClassesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.californiaBlue));
          }

          final enrolledCourses = snapshot.data ?? [];

          double totalStudyHours = 0.0;
          double highestBurnoutIndex = 0.0;

          for (var courseData in enrolledCourses) {
            totalStudyHours += courseData.weeklyStudyHours;
            if (courseData.burnoutIndex > highestBurnoutIndex) {
              highestBurnoutIndex = courseData.burnoutIndex;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Workload monitor component displaying accumulated study times
                const WorkloadMonitor(),
                const SizedBox(height: 16),

                if (enrolledCourses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        "You haven't joined any classes yet.\nGo to settings to enroll in courses!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: enrolledCourses.length,
                    itemBuilder: (context, index) {
                      final joinedClass = enrolledCourses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  joinedClass.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  joinedClass.meta,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: joinedClass.chipColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: joinedClass.chipColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                joinedClass.chip,
                                style: TextStyle(color: joinedClass.chipColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}