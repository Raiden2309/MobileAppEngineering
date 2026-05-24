import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../controllers/engagement_controller.dart';
import '../../../providers/engagement_provider.dart';

class EngagementFilterChips extends StatelessWidget {
  const EngagementFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngagementProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.filters.map((f) {
          final isActive = provider.selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => EngagementController.setFilter(context, f['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: isActive
                        ? FontStyles.weightHeavy
                        : FontStyles.weightMedium,
                    color: AppColors.black.withValues(alpha: isActive ? 1.0 : 0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}