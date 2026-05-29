import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../models/student_subject_model.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/workload_monitor.dart';
import 'widgets/subject_tasks_sheet.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.read<StudentDashboardProvider>();
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

          // Query live tasks parameters matching enrollment tracking collections
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
                    const SizedBox(height: 16),

                    // Display work metric widgets using live aggregated calculations
                    WorkloadMonitor(
                      pendingTasksCount: totalPendingTasks,
                      completionProgress: overallProgress,
                      burnoutRatio: meanBurnoutValue,
                    ),

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
                          final classNameStr = joinedClass.name;
                          final courseCodeStr = joinedClass.code;
                          final colorString = joinedClass.colorHex;

                          final cardAccentColor = Color(int.tryParse(colorString.replaceAll('#', '0xFF')) ?? 0xFF60A5FA);

                          // Generate matching document identifier to locate target collection row paths
                          final docId = '${uid}_${classNameStr.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').replaceAll(RegExp(r'[\s-]'), '_')}';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Open task popup window cleanly on tap action triggers
                                  SubjectTasksSheet.show(
                                    context,
                                    enrollmentDocId: docId,
                                    subjectName: classNameStr,
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
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
                                            classNameStr,
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            courseCodeStr,
                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: cardAccentColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: cardAccentColor.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          'Sem ${joinedClass.semesterId}',
                                          style: TextStyle(color: cardAccentColor, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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