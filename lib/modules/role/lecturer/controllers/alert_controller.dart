import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../models/alert_model.dart';
import '../providers/alert_provider.dart';

class AlertController {
  static Color colorFor(AlertModel a) => switch (a.type) {
    'burnout' => AppColors.red,
    'behind'  => AppColors.mikadoYellow,
    _         => AppColors.californiaBlue,
  };

  static bool isUnread(AlertModel a) => !a.read;

  static void selectFilter(BuildContext context, String filter) {
    context.read<AlertProvider>().setFilter(filter);
  }

  static void markAsRead(BuildContext context, AlertModel alert) {
    context.read<AlertProvider>().markAsRead(alert);
  }
}