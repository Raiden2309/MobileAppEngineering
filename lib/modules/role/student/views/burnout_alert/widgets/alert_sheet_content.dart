import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/burnout_alert_controller.dart';
import '../../../models/burnout_alert_model.dart';
import 'alert_sheet_handle.dart';
import 'alert_theme.dart';
import 'workload_card.dart';
import 'alert_actions.dart';

class AlertSheetContent extends StatelessWidget {
  final BurnoutAlertModel alert;

  const AlertSheetContent({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AlertTheme.of(alert.type);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.darkNavyBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AlertSheetHandle(),
          Icon(alert.alertIcon, size: 48, color: theme.titleColor),
          const SizedBox(height: 16),
          Text(
            alert.title,
            style: TextStyle(
              fontSize: FontStyles.titleLarge,
              fontWeight: FontStyles.titleWeight,
              color: theme.titleColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              alert.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: FontStyles.titleSmall,
                color: AppColors.white,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          WorkloadCard(alert: alert, theme: theme),
          const SizedBox(height: 20),
          AlertActions(
            primaryLabel: alert.primaryActionLabel,
            primaryGradient: theme.buttonGradient,
            onPrimaryTap: () => BurnoutAlertController.onPrimaryAction(context),
            dismissLabel: alert.dismissLabel,
            onDismissTap: () => BurnoutAlertController.onDismiss(context),
          ),
        ],
      ),
    );
  }
}