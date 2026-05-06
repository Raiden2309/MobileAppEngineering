import 'package:flutter/material.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../study_plan/widget/study_schedule.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../models/study_plan_model.dart';

class StudyPlanPage extends StatefulWidget {
  const StudyPlanPage({super.key});

  @override
  State<StudyPlanPage> createState() => StudyPlanPageState();
}

class StudyPlanPageState extends State<StudyPlanPage> {
  late WeekPlan weekPlan;
  late int selectedDayIndex;

  static const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    weekPlan = WeekPlan.mock();
    final now = DateTime.now();
    selectedDayIndex = weekPlan.days.indexWhere(
          (d) =>
      d.date.day == now.day &&
          d.date.month == now.month &&
          d.date.year == now.year,
    );
    if (selectedDayIndex < 0) selectedDayIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✨', style: TextStyle(fontSize: FontStyles.titleSmall)),
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

              // ── Day selector (stays fixed) ─────────
              SizedBox(
                height: 78,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final day = weekPlan.days[i];
                    final isSelected = i == selectedDayIndex;
                    final hasBlocks = day.blocks.isNotEmpty;

                    return GestureDetector(
                      onTap: () => setState(() => selectedDayIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 54,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.2),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayLabels[i],
                              style: TextStyle(
                                color: isSelected ? Colors.black54 : Colors.white.withValues(alpha: 0.6),
                                fontSize: FontStyles.titleSmall,
                                fontWeight: FontStyles.weightMedium,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${day.date.day}',
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: FontStyles.titleLarge,
                                fontWeight: FontStyles.titleWeight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasBlocks
                                    ? (isSelected
                                    ? AppColors.californiaBlue
                                    : Colors.white.withValues(alpha: 0.55))
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // ── Regenerate button (stays fixed) ────
              GestureDetector(
                onTap: () => setState(() => weekPlan = WeekPlan.mock()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, color: AppColors.californiaBlue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Regenerate this week's plan",
                        style: TextStyle(
                          color: AppColors.californiaBlue,
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