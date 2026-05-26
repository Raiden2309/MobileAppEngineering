import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../controllers/classes_controller.dart';
import '../../models/class_model.dart';
import '../../models/class_student_model.dart';
import '../../providers/classes_provider.dart';

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
    final c = classModel;
    final classCode = c.code.split(' ·').first.trim();

    return Scaffold(
      backgroundColor: Colors.transparent,
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
              _buildBackNav(context, c),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(c),
                      _buildCompletionBar(c),
                      const SizedBox(height: 16),
                      _buildWorkloadMonitor(c),
                      const SizedBox(height: 16),

                      StreamBuilder<List<ClassStudentModel>>(
                        stream: context.read<ClassesProvider>().getStudents(classCode),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text("No students enrolled.");
                          }
                          // This replaces your _buildStudentList(students) call
                          return _buildStudentList(snapshot.data!);
                        },
                      ),
                    ],
                  ),
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

  Widget _buildHero(ClassModel c) {
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
                    '${c.code.split('·').first.trim()} · Diploma in Computer Science · Sem 4',
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
                'Class Code',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.black.withValues(alpha: 0.5),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${c.code.split(' ·').first}–A2',
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
            _miniStat('Students', ClassesController.studentsLabel(c), AppColors.californiaBlue),
            const SizedBox(width: 8),
            _miniStat('Avg Done', ClassesController.avgDoneLabel(c),  AppColors.mikadoYellow),
            const SizedBox(width: 8),
            _miniStat('At Risk',  ClassesController.atRiskLabel(c),   ClassesController.atRiskColor(c)),
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

  Widget _buildCompletionBar(ClassModel c) {
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
              Text(ClassesController.avgDoneLabel(c), style: const TextStyle(fontSize: FontStyles.titleSmall, fontWeight: FontStyles.weightHeavy, color: AppColors.californiaBlue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: c.avgCompletion / 100,
              minHeight: 8,
              backgroundColor: AppColors.black.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.californiaBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '173 of 308 tasks completed across all students',
            style: TextStyle(fontSize: 11, color: AppColors.black.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadMonitor(ClassModel c) {
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
              _workloadBar('Low',            11, c.studentCount, AppColors.greenSheen),
              const SizedBox(height: 8),
              _workloadBar('Moderate',       16, c.studentCount, AppColors.mikadoYellow),
              const SizedBox(height: 8),
              _workloadBar('High / At Risk', c.atRiskCount, c.studentCount, AppColors.red),
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

  Widget _buildStudentList(List<ClassStudentModel> students) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Students', style: TextStyle(fontSize: FontStyles.titleMedium, fontWeight: FontStyles.weightHeavy, color: AppColors.black)),
            const Text('+ Add', style: TextStyle(fontSize: FontStyles.titleSmall, color: AppColors.californiaBlue, fontWeight: FontStyles.weightMedium)),
          ],
        ),
        const SizedBox(height: 10),
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
                      Text(s.name, style: const TextStyle(fontSize: FontStyles.titleSmall, fontWeight: FontStyles.weightMedium, color: AppColors.black), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 1),
                      Text(s.meta, style: TextStyle(fontSize: 11, color: AppColors.black.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: s.chipColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(s.chip, style: TextStyle(fontSize: 11, fontWeight: FontStyles.weightMedium, color: s.chipColor)),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}