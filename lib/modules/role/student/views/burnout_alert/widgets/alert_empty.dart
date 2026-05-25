import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../widgets/alert_sheet_handle.dart';

class AlertEmptyState extends StatelessWidget {
  const AlertEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        decoration: BoxDecoration(
          color: AppColors.darkNavyBlue,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AlertSheetHandle(),
            Icon(
              Icons.insights_rounded,
              size: 48,
              color: AppColors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'No data yet',
              style: TextStyle(
                fontSize: FontStyles.titleMedium,
                fontWeight: FontStyles.titleWeight,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your burnout status will appear here\nonce your session data is available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                color: AppColors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}