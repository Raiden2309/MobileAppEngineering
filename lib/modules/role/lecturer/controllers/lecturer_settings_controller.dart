import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/views/change_password.dart';
import '../providers/lecturer_settings_provider.dart';

class LecturerSettingsController {
  static Future<void> load(BuildContext context) =>
      context.read<LecturerSettingsProvider>().load();

  static Future<void> toggleBurnoutAlerts(BuildContext context) =>
      context.read<LecturerSettingsProvider>().toggleBurnoutAlerts();

  static Future<void> toggleFallingBehindAlerts(BuildContext context) =>
      context.read<LecturerSettingsProvider>().toggleFallingBehindAlerts();

  static Future<void> toggleWeeklyEngagementReport(BuildContext context) =>
      context.read<LecturerSettingsProvider>().toggleWeeklyEngagementReport();

  static Future<void> updateUserName(BuildContext context, String name) =>
      context.read<LecturerSettingsProvider>().updateUserName(name);

  static Future<void> updateAvatar(BuildContext context, XFile file) =>
      context.read<LecturerSettingsProvider>().updateAvatar(file);

  static Future<void> signOut(BuildContext context) =>
      context.read<LecturerSettingsProvider>().signOut(context);

  static void openChangePassword(BuildContext context) {
    final data = context.read<LecturerSettingsProvider>().data;
    if (data == null) return;
    ChangePassword.startChangePassword(context, userId: data.userId);
  }
}