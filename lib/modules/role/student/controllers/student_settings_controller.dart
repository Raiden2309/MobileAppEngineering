import 'package:flutter/material.dart';
import '../models/student_settings_models.dart';

class StudentSettingsController extends ChangeNotifier {
  StudentSettingsModel? data;
  bool loading = false;
  String? error;

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setError(String message) {
    error = message;
    loading = false;
    notifyListeners();
  }

  void setData(StudentSettingsModel model) {
    data = model;
    loading = false;
    error = null;
    notifyListeners();
  }

  void toggleTaskReminders() {
    if (data == null) return;
    data = data!.copyWith(taskReminders: !data!.taskReminders);
    notifyListeners();
  }

  void toggleSlotEndPrompts() {
    if (data == null) return;
    data = data!.copyWith(slotEndPrompts: !data!.slotEndPrompts);
    notifyListeners();
  }

  void toggleBurnoutWarnings() {
    if (data == null) return;
    data = data!.copyWith(burnoutWarnings: !data!.burnoutWarnings);
    notifyListeners();
  }

  void toggleWeeklyResetSummary() {
    if (data == null) return;
    data = data!.copyWith(weeklyResetSummary: !data!.weeklyResetSummary);
    notifyListeners();
  }

  void signOut(BuildContext context) {
    // TODO: clear session and navigate to login
  }

  void clear() {
    data = null;
    loading = false;
    error = null;
    notifyListeners();
  }
}