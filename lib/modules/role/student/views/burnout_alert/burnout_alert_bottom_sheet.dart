import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../controllers/burnout_alert_controller.dart';
import '../../models/burnout_alert_model.dart';

class AlertTheme {
  final List<Color> progressGradient;
  final List<Color> buttonGradient;
  final Color titleColor;
  final Color levelColor;

  const AlertTheme({
    required this.progressGradient,
    required this.buttonGradient,
    required this.titleColor,
    required this.levelColor,
  });

  static AlertTheme of(BurnoutAlertType type) {
    switch (type) {
      case BurnoutAlertType.burnout:
        return AlertTheme(
          progressGradient: [AppColors.mikadoYellow, AppColors.red],
          buttonGradient: [AppColors.red, AppColors.redDark],
          titleColor: AppColors.red,
          levelColor: AppColors.red,
        );
      case BurnoutAlertType.allGood:
        return AlertTheme(
          progressGradient: [AppColors.greenSheen, AppColors.greenSheenDark],
          buttonGradient: [AppColors.greenSheen, AppColors.greenSheenDark],
          titleColor: AppColors.greenSheen,
          levelColor: AppColors.greenSheen,
        );
      case BurnoutAlertType.warning:
        return AlertTheme(
          progressGradient: [AppColors.mikadoYellow, AppColors.nectarine],
          buttonGradient: [AppColors.mikadoYellow, AppColors.nectarine],
          titleColor: AppColors.mikadoYellow,
          levelColor: AppColors.mikadoYellow,
        );
      case BurnoutAlertType.overload:
        return AlertTheme(
          progressGradient: [AppColors.red, AppColors.softPurple],
          buttonGradient: [AppColors.softPurple, AppColors.darkIndigoBlue],
          titleColor: AppColors.red,
          levelColor: AppColors.red,
        );
    }
  }
}

class BurnoutAlertBottomSheet extends StatelessWidget {
  final BurnoutAlertController controller;

  const BurnoutAlertBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final alert = controller.currentAlert;

        if (alert == null) {
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
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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

        return SheetContent(alert: alert, controller: controller);
      },
    );
  }
}

class SheetContent extends StatelessWidget {
  final BurnoutAlertModel alert;
  final BurnoutAlertController controller;

  const SheetContent({super.key, required this.alert, required this.controller});

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
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            alert.alertIcon,
            size: 48,
            color: theme.titleColor,
          ),
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
          PrimaryButton(
            label: alert.primaryActionLabel,
            gradient: theme.buttonGradient,
            onTap: () => controller.onPrimaryAction(context),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => controller.onDismiss(context),
            child: Text(
              alert.dismissLabel,
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkloadCard extends StatelessWidget {
  final BurnoutAlertModel alert;
  final AlertTheme theme;

  const WorkloadCard({super.key, required this.alert, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppColors.glassTile(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S WORKLOAD",
            style: TextStyle(
              fontSize: FontStyles.titleTiny,
              fontWeight: FontStyles.weightMedium,
              color: AppColors.white.withValues(alpha: 0.6),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: AppColors.white.withValues(alpha: 0.1)),
                  FractionallySizedBox(
                    widthFactor: alert.workloadProgress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: theme.progressGradient,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${alert.workloadLevelLabel} · ${alert.hoursStudied.toStringAsFixed(1)} hrs studied',
            style: TextStyle(
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.weightMedium,
              color: theme.levelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const PrimaryButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            splashColor: AppColors.white.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                label,
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
    );
  }
}