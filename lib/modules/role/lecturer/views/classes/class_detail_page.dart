import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../controllers/classes_controller.dart';
import '../../models/class_model.dart';
import '../../models/class_student_model.dart';
import '../../providers/classes_provider.dart';
import 'widgets/assign_task_sheet.dart';
import 'widgets/add_student_sheet.dart';

class ClassDetailPage extends StatelessWidget {
  final ClassModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  BoxDecoration _whiteCard() => BoxDecoration(
    color: AppColors.white.withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
    border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
  );

  @override
  Widget build(BuildContext context) {
    final classCode = classModel.subjectCode;
    final classesProvider = context.read<ClassesProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Assign Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          AssignTaskSheet.show(
            context,
            classModel.id,
            classModel.subjectCode,
          );
        },
      ),
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
              _buildBackNav(context, classModel),
              Expanded(
                // STREAM 1: Listens to the master class document for real-time task additions
                child: StreamBuilder<ClassModel>(
                  stream: classesProvider.streamClassDetails(classModel.id),
                  initialData: classModel,
                  builder: (context, classSnapshot) {
                    final dynamicClassModel = classSnapshot.data ?? classModel;

                    // STREAM 2: Listens to student enrollments for progress computations
                    return StreamBuilder<List<ClassStudentModel>>(
                      stream: classesProvider.getStudents(classCode),
                      builder: (context, studentSnapshot) {
                        if (studentSnapshot.connectionState == ConnectionState.waiting && !classSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        }

                        final students = studentSnapshot.data ?? [];
                        final int totalStudents = students.length;

                        int lowCount = 0;
                        int medCount = 0;
                        int highCount = 0;
                        double totalBurnoutSum = 0.0;

                        for (var student in students) {
                          totalBurnoutSum += student.burnoutIndex;

                          if (student.burnoutIndex >= 0.70) {
                            highCount++;
                          } else if (student.burnoutIndex >= 0.40) {
                            medCount++;
                          } else {
                            lowCount++;
                          }
                        }

                        final double calculatedAvgProgress = totalStudents > 0
                            ? (1.0 - (totalBurnoutSum / totalStudents))
                            : 0.0;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHero(dynamicClassModel, totalStudents, calculatedAvgProgress, highCount),
                              const SizedBox(height: 16),
                              _buildCompletionBar(calculatedAvgProgress),
                              const SizedBox(height: 16),
                              _buildWorkloadMonitor(totalStudents, lowCount, medCount, highCount),
                              const SizedBox(height: 16),

                              // LIVE UPDATING: Uses dynamic stream payload data safely
                              _buildAssignedTasksTracker(dynamicClassModel, students),
                              const SizedBox(height: 16),

                              // Refactored to pass down the list and handle visibility consistently
                              _buildStudentList(context, students),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackNav(BuildContext context, ClassModel c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: _whiteCard(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chevron_left, color: AppColors.black, size: 18),
                  Text(
                    'All Classes',
                    style: TextStyle(
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            c.code.split(' ·').first,
            style: TextStyle(
              fontSize: FontStyles.titleMedium,
              fontWeight: FontStyles.weightHeavy,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildHero(ClassModel c, int totalStudents, double avgProgress, int atRisk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.accentColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontStyles.weightHeavy,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.subjectCode} · Diploma in Computer Science · Sem 4',
                    style: TextStyle(
                      fontSize: FontStyles.titleTiny,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: _whiteCard(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Join Code',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.black.withValues(alpha: 0.5),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                c.classCode,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.californiaBlue,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '📋 Copy',
                style: TextStyle(fontSize: 11, color: AppColors.californiaBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _miniStat('Students', '$totalStudents', AppColors.californiaBlue),
            const SizedBox(width: 8),
            _miniStat('Avg Done', '${(avgProgress * 100).toStringAsFixed(0)}%',  AppColors.mikadoYellow),
            const SizedBox(width: 8),
            _miniStat('At Risk',  '$atRisk',   atRisk > 0 ? AppColors.red : AppColors.greenSheen),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: _whiteCard(),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontStyles.weightHeavy, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.black.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBar(double avgProgress) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Class Completion', style: TextStyle(fontSize: FontStyles.titleTiny, color: AppColors.black.withValues(alpha: 0.6))),
              Text('${(avgProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: FontStyles.titleSmall, fontWeight: FontStyles.weightHeavy, color: AppColors.californiaBlue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: avgProgress,
              minHeight: 8,
              backgroundColor: AppColors.black.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.californiaBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Live curriculum engagement average tracked across registered profiles',
            style: TextStyle(fontSize: 11, color: AppColors.black.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadMonitor(int total, int low, int med, int high) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Workload Monitor', style: TextStyle(fontSize: FontStyles.titleMedium, fontWeight: FontStyles.weightHeavy, color: AppColors.black)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _whiteCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Class workload distribution', style: TextStyle(fontSize: FontStyles.titleTiny, color: AppColors.black.withValues(alpha: 0.6))),
              const SizedBox(height: 12),
              _workloadBar('Low',            low, total, AppColors.greenSheen),
              const SizedBox(height: 8),
              _workloadBar('Moderate',       med, total, AppColors.mikadoYellow),
              const SizedBox(height: 8),
              _workloadBar('High / At Risk', high, total, AppColors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workloadBar(String label, int count, int total, Color color) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label, style: TextStyle(fontSize: 12, color: color))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              minHeight: 8,
              backgroundColor: AppColors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontStyles.weightHeavy, color: color), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildAssignedTasksTracker(ClassModel c, List<ClassStudentModel> students) {
    final List<dynamic> taskBlueprints = c.initialTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Tasks Tracking',
          style: TextStyle(fontSize: FontStyles.titleMedium, fontWeight: FontStyles.weightHeavy, color: AppColors.black),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: _whiteCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (taskBlueprints.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No tasks assigned to this class yet.\nTap "Assign Task" below to start.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                )
              else
                ...taskBlueprints.map((task) {
                  final String taskTitle = task['title']?.toString() ?? 'Untitled Task';
                  final String description = task['description']?.toString() ?? '';

                  int activeCount = 0;
                  for (var s in students) {
                    if (s.burnoutIndex < 0.70) {
                      activeCount++;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.assignment_outlined, color: AppColors.californiaBlue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  taskTitle,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    description,
                                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.californiaBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$activeCount Doing it',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.californiaBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList(BuildContext context, List<ClassStudentModel> students) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Students', style: TextStyle(fontSize: FontStyles.titleMedium, fontWeight: FontStyles.weightHeavy, color: AppColors.black)),

            GestureDetector(
              onTap: () {
                AddStudentBottomSheet.show(
                  context,
                  className: classModel.name,
                  subjectCode: classModel.subjectCode,
                );
              },
              child: const Text(
                '+ Add',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.californiaBlue,
                  fontWeight: FontStyles.weightMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Displays empty placeholder below the persistent header if snapshot payload returns zero items
        if (students.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No students enrolled in this class.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          )
        else
          ...students.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: _whiteCard(),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: s.chipColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(s.initials, style: TextStyle(fontSize: 12, fontWeight: FontStyles.weightHeavy, color: s.chipColor)),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: FontStyles.titleSmall, fontWeight: FontWeight.w500, color: AppColors.black), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 1),
                        Text(s.meta, style: TextStyle(fontSize: 11, color: AppColors.black.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: s.chipColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(s.chip, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: s.chipColor)),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }
}