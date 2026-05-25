import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../models/app_enums.dart';
import '../../../models/burnout_alert_model.dart';

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