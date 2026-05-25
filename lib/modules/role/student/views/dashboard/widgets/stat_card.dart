import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color accent;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
    required this.icon,
  });

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: FontStyles.titleGreeting,
                      fontWeight: FontStyles.titleWeight,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              Icon(icon, color: accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}