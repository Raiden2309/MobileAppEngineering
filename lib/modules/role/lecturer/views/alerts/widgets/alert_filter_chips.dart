import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/alert_controller.dart';
import '../../../providers/alert_provider.dart';

class AlertFilterChips extends StatelessWidget {
  const AlertFilterChips({super.key});

  static const List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'burnout', 'label': 'Burnout'},
    {'key': 'behind', 'label': 'Falling Behind'},
    {'key': 'read', 'label': 'Read'},
  ];

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AlertProvider>().selectedFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final isActive = selected == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => AlertController.selectFilter(context, f['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
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
                    color: isActive
                        ? AppColors.white
                        : AppColors.black.withValues(alpha: 0.6),
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
