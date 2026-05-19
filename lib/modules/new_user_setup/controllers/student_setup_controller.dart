import 'package:flutter/material.dart';

class SetupController extends ChangeNotifier {
  final nameController = TextEditingController();
  TimeOfDay dayStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay dayEnd = const TimeOfDay(hour: 22, minute: 0);

  final Set<String> blockedSlots = {};

  final programmeController = TextEditingController();
  int semester = 1;
  int year = 1;
  DateTime? semStart;
  DateTime? semEnd;
  List<DateTime> examDates = [];

  final List<Map<String, String>> subjects = [
    {'name': 'CT124 System Proposal', 'color': '#2dd4bf'},
    {'name': 'Research Methods',      'color': '#f59e0b'},
    {'name': 'Mobile Development',    'color': '#a78bfa'},
  ];

  final newSubjectController = TextEditingController();

  void setDayStart(TimeOfDay t) { dayStart = t; notifyListeners(); }
  void setDayEnd(TimeOfDay t)   { dayEnd = t; notifyListeners(); }

  void toggleSlot(String key) {
    if (blockedSlots.contains(key)) {
      blockedSlots.remove(key);
    } else {
      blockedSlots.add(key);
    }
    notifyListeners();
  }

  String generateColor(int index) {
    final hues = [168, 45, 262, 210, 152, 0, 30, 290, 120, 330];
    final hue = hues[index % hues.length];
    return 'FF${hslToHex(hue, 0.65, 0.55)}';
  }

  String hslToHex(int h, double s, double l) {
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;
    double r, g, b;
    if (h < 60)       { r = c; g = x; b = 0; }
    else if (h < 120) { r = x; g = c; b = 0; }
    else if (h < 180) { r = 0; g = c; b = x; }
    else if (h < 240) { r = 0; g = x; b = c; }
    else if (h < 300) { r = x; g = 0; b = c; }
    else              { r = c; g = 0; b = x; }
    String toHex(double v) => ((v + m) * 255).round().toRadixString(16).padLeft(2, '0');
    return '${toHex(r)}${toHex(g)}${toHex(b)}';
  }

  void addSubject() {
    final name = newSubjectController.text.trim();
    if (name.isEmpty) return;
    final color = '#${generateColor(subjects.length).substring(2)}'; // strip FF prefix
    subjects.add({'name': name, 'color': color});
    newSubjectController.clear();
    notifyListeners();
  }

  void removeSubject(int index) {
    subjects.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    programmeController.dispose();
    newSubjectController.dispose();
    super.dispose();
  }

  final Map<String, String?> errors = {};
  String? getError(String key) => errors[key];

  bool validate(String value, String errorKey, {
    int minLength = 2,
    String? emptyMessage,
    String? shortMessage,
  }) {
    if (value.trim().isEmpty) {
      errors[errorKey] = emptyMessage ?? 'This field is required';
      notifyListeners();
      return false;
    }
    if (value.trim().length < minLength) {
      errors[errorKey] = shortMessage ?? 'Must be at least $minLength characters';
      notifyListeners();
      return false;
    }
    errors[errorKey] = null;
    notifyListeners();
    return true;
  }

  bool validateSubjects() {
    if (subjects.isEmpty) {
      errors['subjects'] = 'Please add at least one subject';
      notifyListeners();
      return false;
    }
    errors['subjects'] = null;
    notifyListeners();
    return true;
  }

}