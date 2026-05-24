import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

class StatusCard extends StatelessWidget {
  final String label;
  final String count;
  final String sub;
  final Color? color;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.sub,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.black;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
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
                    count,
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
                      color: AppColors.legendText,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: AppColors.glassIconOpacity),
                  borderRadius: BorderRadius.circular(AppColors.glassIconBorderRadius),
                  border: Border.all(
                    color: c.withValues(alpha: AppColors.glassBorderOpacity),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: c, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}