import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/study_plan_model.dart';

class DateSelection extends StatelessWidget {
  final WeekPlan weekPlan;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;

  static const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  const DateSelection({
    super.key,
    required this.weekPlan,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = weekPlan.days[i];
          final isSelected = i == selectedDayIndex;
          final hasBlocks = day.blocks.isNotEmpty;

          return GestureDetector(
            onTap: () => onDaySelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(
                        alpha: AppColors.glassTileOpacity,
                      ),
                borderRadius: BorderRadius.circular(
                  AppColors.glassTileBorderRadius,
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.black
                      : Colors.white.withValues(
                          alpha: AppColors.glassBorderOpacity,
                        ),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: FontStyles.titleSmall,
                      fontWeight: FontStyles.weightMedium,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${day.date.day}',
                    style: TextStyle(
                      color: AppColors.black,
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
                          : AppColors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
