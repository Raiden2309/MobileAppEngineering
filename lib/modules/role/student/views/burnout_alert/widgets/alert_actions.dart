import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class AlertActions extends StatelessWidget {
  final String primaryLabel;
  final List<Color> primaryGradient;
  final VoidCallback onPrimaryTap;
  final String dismissLabel;
  final VoidCallback onDismissTap;

  const AlertActions({
    super.key,
    required this.primaryLabel,
    required this.primaryGradient,
    required this.onPrimaryTap,
    required this.dismissLabel,
    required this.onDismissTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: primaryGradient.last.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: onPrimaryTap,
                borderRadius: BorderRadius.circular(50),
                splashColor: AppColors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    primaryLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: FontStyles.titleMedium,
                      fontWeight: FontStyles.titleWeight,
                      color: AppColors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onDismissTap,
          child: Text(
            dismissLabel,
            style: TextStyle(
              fontSize: FontStyles.titleSmall,
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
