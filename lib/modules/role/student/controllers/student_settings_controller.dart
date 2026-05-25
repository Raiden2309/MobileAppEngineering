import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/views/login_page.dart';
import '../models/student_settings_models.dart';
import '../providers/student_settings_provider.dart';

class StudentSettingsController {
  static Future<void> load(BuildContext context) {
    return context.read<StudentSettingsProvider>().load();
  }

  static Future<void> toggleTaskReminders(BuildContext context) {
    return context.read<StudentSettingsProvider>().toggleTaskReminders();
  }

  static Future<void> toggleSlotEndPrompts(BuildContext context) {
    return context.read<StudentSettingsProvider>().toggleSlotEndPrompts();
  }

  static Future<void> toggleBurnoutWarnings(BuildContext context) {
    return context.read<StudentSettingsProvider>().toggleBurnoutWarnings();
  }

  static Future<void> toggleWeeklyResetSummary(BuildContext context) {
    return context.read<StudentSettingsProvider>().toggleWeeklyResetSummary();
  }

  static Future<void> saveStudyHours(BuildContext context, TimeOfDay start, TimeOfDay end) {
    return context.read<StudentSettingsProvider>().saveStudyHours(start, end);
  }

  static Future<void> saveBlockedSlots(BuildContext context, Set<String> slots) {
    return context.read<StudentSettingsProvider>().saveBlockedSlots(slots);
  }

  static Future<void> saveSubjects(BuildContext context, List<Map<String, String>> updated) {
    return context.read<StudentSettingsProvider>().saveSubjects(updated);
  }

  static Future<void> saveSemesters(BuildContext context, List<Map<String, String>> updated) {
    return context.read<StudentSettingsProvider>().saveSemesters(updated);
  }

  static void selectSemester(BuildContext context, String name) {
    context.read<StudentSettingsProvider>().selectSemester(name);
  }

  static Future<void> updateUserName(BuildContext context, String name) {
    return context.read<StudentSettingsProvider>().updateUserName(name);
  }

  static Future<void> updateAvatar(BuildContext context, XFile file) {
    return context.read<StudentSettingsProvider>().updateAvatar(file);
  }

  static Future<bool> joinClass(BuildContext context, String code) {
    return context.read<StudentSettingsProvider>().joinClass(code);
  }

  static Future<void> leaveClass(BuildContext context, String classId) {
    return context.read<StudentSettingsProvider>().leaveClass(classId);
  }

  static Future<void> signOut(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
}