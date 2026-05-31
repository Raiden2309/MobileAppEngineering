import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/study_plan/widget/date_selection.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../controllers/study_plan_controller.dart';
import '../study_plan/widget/study_schedule.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../models/study_plan_model.dart';

class StudyPlanPage extends StatefulWidget {
  final StudyPlanController controller;

  const StudyPlanPage({super.key, required this.controller});

  @override
  State<StudyPlanPage> createState() => StudyPlanPageState();
}

class StudyPlanPageState extends State<StudyPlanPage> {
  static const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  StudyPlanController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerUpdate);
    controller.init();
  }

  void _onControllerUpdate() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekPlan = controller.plan;
    final selectedDayIndex = controller.selectedDayIndex;

    if (weekPlan == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.californiaBlue),
      );
    }

    final selectedPlan = weekPlan.days[selectedDayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed header ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Study Plan',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: FontStyles.titleLarge,
                  fontWeight: FontStyles.titleWeight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Optimised for your deadlines & energy',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: FontStyles.titleSmall,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'AI-generated · Last updated today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: FontStyles.titleSmall,
                        fontWeight: FontStyles.weightMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Day selector ───────────────────────
              DateSelection(
                weekPlan: weekPlan,
                selectedDayIndex: selectedDayIndex,
                onDaySelected: (i) {
                  controller.selectDay(i);
                },
              ),

              const SizedBox(height: 14),

              // ── Regenerate button ──────────────────
              GestureDetector(
                onTap: () {
                  // Triggers a local rebuild frame pass so the layout repaints with fresh timeline data
                  setState(() {
                    widget.controller.regenerate();
                  });

                  // Clean inline push notification to confirm the optimization completed successfully
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Study Plan re-optimised!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.californiaBlue,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: AppColors.black, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Regenerate this week's plan",
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontStyles.weightMedium,
                          fontSize: FontStyles.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── Scrollable schedule ───────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: StudySchedule(dayPlan: selectedPlan),
          ),
        ),
      ],
    );
  }
}