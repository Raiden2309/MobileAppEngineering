import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final Color? labelColor;
  final String? value;
  final VoidCallback onTap;
  final bool showArrow;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.value,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppColors.glassIconBorderRadius),
              ),
              child: Icon(icon, size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: labelColor ?? AppColors.white,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.legendText,
                ),
              ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.white.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}