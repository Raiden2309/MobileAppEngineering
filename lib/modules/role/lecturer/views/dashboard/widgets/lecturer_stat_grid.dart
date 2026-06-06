import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../models/stat_card_model.dart';
import '../../../providers/lecturer_dashboard_provider.dart';

class LecturerStatGrid extends StatelessWidget {
  const LecturerStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<LecturerDashboardProvider>().stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontStyles.weightHeavy,
              color: AppColors.black,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StatCard(model: stats[0])),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(model: stats[1])),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StatCard(model: stats[2])),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(model: stats[3])),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatCardModel model;

  const _StatCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED: Wrapped the Column in an Expanded widget to isolate content scaling boundaries cleanly
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Safely drops trailing characters into ... if text room fails
                      style: const TextStyle(
                        fontSize: FontStyles.titleSmall,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      model.value,
                      style: const TextStyle(
                        fontSize: FontStyles.titleGreeting,
                        fontWeight: FontStyles.titleWeight,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      model.sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Protects sub-labels text elements from wrap spills
                      style: const TextStyle(
                        fontSize: FontStyles.titleSmall,
                        color: AppColors.legendText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // Ensures a mandatory minimum whitespace gap between layout elements
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: model.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: model.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(model.icon, color: model.accent, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}