import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.white,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.lime,
              activeTrackColor: AppColors.lime.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.white.withValues(alpha: 0.4),
              inactiveTrackColor: AppColors.white.withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}