import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lecturer_dashboard_provider.dart';

class LecturerDashboardController {
  static void onViewAlerts(BuildContext context) {
    // TODO: navigate to alerts screen
  }

  static void onSeeAllClasses(BuildContext context, VoidCallback? onNavigate) {
    if (onNavigate != null) onNavigate();
  }

  static void updateLecturerName(BuildContext context, String name) {
    context.read<LecturerDashboardProvider>().updateLecturerName(name);
  }

  static void updateGreeting(BuildContext context, String greeting) {
    context.read<LecturerDashboardProvider>().updateGreeting(greeting);
  }

  static void updateDateLabel(BuildContext context, String label) {
    context.read<LecturerDashboardProvider>().updateDateLabel(label);
  }

  static void updateAtRiskCount(BuildContext context, int count) {
    context.read<LecturerDashboardProvider>().updateAtRiskCount(count);
  }
}