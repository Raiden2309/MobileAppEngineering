import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/api_service.dart';
import '../../../auth/controllers/login_controller.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/views/login_page.dart';
import '../models/student_settings_models.dart';
import '../models/semester_details_model.dart';

class StudentSettingsController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  StudentSettingsModel? data;

  static const _keyStudyStart      = 'settings_study_start';
  static const _keyStudyEnd        = 'settings_study_end';
  static const _keyBlockedSlots    = 'settings_blocked_slots';
  static const _keySubjects        = 'settings_subjects';
  static const _keySemesters       = 'settings_semesters';
  static const _keyTaskReminders   = 'settings_task_reminders';
  static const _keySlotEndPrompts  = 'settings_slot_end_prompts';
  static const _keyBurnoutWarnings = 'settings_burnout_warnings';
  static const _keyWeeklyReset     = 'settings_weekly_reset_summary';
  static const _keyUserId          = 'settings_user_id';
  static const _keyUserName        = 'settings_user_name';
  static const _keySemester        = 'settings_semester';
  static const _keyYear            = 'settings_year';
  static const _keySubjectCount    = 'settings_subject_count';
  static const _keyBlockedCount    = 'settings_blocked_slots_count';
  static const _keyAppVersion      = 'settings_app_version';

  TimeOfDay studyStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay studyEnd   = const TimeOfDay(hour: 22, minute: 0);

  Set<String> blockedSlots = {};

  List<Map<String, String>> subjects  = [];
  List<Map<String, String>> semesters = [];

  bool taskReminders     = false;
  bool slotEndPrompts    = false;
  bool burnoutWarnings   = false;
  bool weeklyResetSummary = false;

  bool    loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error   = null;
    notifyListeners();

    await _loadFromCache();
    loading = false;
    notifyListeners();

    try {
      final json = await ApiService.get('/student/settings');
      _applyFromApi(json);
      await _saveToCache();
      notifyListeners();
    } catch (_) {}
  }

  void _applyFromApi(Map<String, dynamic> json) {
    data = StudentSettingsModel.fromJson(json);

    studyStart         = _parseTimeString(data!.studyHoursStart);
    studyEnd           = _parseTimeString(data!.studyHoursEnd);
    taskReminders      = data!.taskReminders;
    slotEndPrompts     = data!.slotEndPrompts;
    burnoutWarnings    = data!.burnoutWarnings;
    weeklyResetSummary = data!.weeklyResetSummary;
    semesters          = data!.semesters.map((s) => {
      'name':            s.name,
      'isCurrent':       s.isCurrent.toString(),
      'subjectCount':    s.subjectCount.toString(),
      'studyHoursStart': s.studyHoursStart,
      'studyHoursEnd':   s.studyHoursEnd,
    }).toList();

    if (json['blocked_slots'] != null) {
      blockedSlots = Set<String>.from(json['blocked_slots'] as List);
    }
    if (json['subjects'] != null) {
      subjects = (json['subjects'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    }
  }

  Future<void> _loadFromCache() async {
    final start      = await _storage.read(key: _keyStudyStart);
    final end        = await _storage.read(key: _keyStudyEnd);
    final slots      = await _storage.read(key: _keyBlockedSlots);
    final subjRaw    = await _storage.read(key: _keySubjects);
    final semRaw     = await _storage.read(key: _keySemesters);
    final trRaw      = await _storage.read(key: _keyTaskReminders);
    final sepRaw     = await _storage.read(key: _keySlotEndPrompts);
    final bwRaw      = await _storage.read(key: _keyBurnoutWarnings);
    final wrsRaw     = await _storage.read(key: _keyWeeklyReset);
    final userIdRaw  = await _storage.read(key: _keyUserId);
    final userNameRaw = await _storage.read(key: _keyUserName);
    final semesterRaw = await _storage.read(key: _keySemester);
    final yearRaw    = await _storage.read(key: _keyYear);
    final subjCountRaw = await _storage.read(key: _keySubjectCount);
    final blockedCountRaw = await _storage.read(key: _keyBlockedCount);
    final appVersionRaw = await _storage.read(key: _keyAppVersion);

    if (start   != null) studyStart      = _parseTimeString(start);
    if (end     != null) studyEnd        = _parseTimeString(end);
    if (slots   != null) blockedSlots    = Set<String>.from(jsonDecode(slots) as List);
    if (subjRaw != null) {
      subjects = (jsonDecode(subjRaw) as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    }
    if (semRaw != null) {
      semesters = (jsonDecode(semRaw) as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    }
    if (trRaw  != null) taskReminders      = trRaw  == 'true';
    if (sepRaw != null) slotEndPrompts     = sepRaw == 'true';
    if (bwRaw  != null) burnoutWarnings    = bwRaw  == 'true';
    if (wrsRaw != null) weeklyResetSummary = wrsRaw == 'true';

    if (semesters.isNotEmpty || userIdRaw != null) {
      data = StudentSettingsModel(
        userId:            int.tryParse(userIdRaw ?? '0') ?? 0,
        userName:          userNameRaw ?? '',
        semester:          semesterRaw ?? '',
        year:              int.tryParse(yearRaw ?? '0') ?? 0,
        subjectCount:      int.tryParse(subjCountRaw ?? '0') ?? 0,
        studyHoursStart:   _formatTime(studyStart),
        studyHoursEnd:     _formatTime(studyEnd),
        blockedSlotsCount: int.tryParse(blockedCountRaw ?? '0') ?? 0,
        taskReminders:     taskReminders,
        slotEndPrompts:    slotEndPrompts,
        burnoutWarnings:   burnoutWarnings,
        weeklyResetSummary: weeklyResetSummary,
        appVersion:        appVersionRaw ?? 'v1.0',
        semesters: semesters.map((s) => SemesterModel(
          name:            s['name'] ?? '',
          isCurrent:       s['isCurrent'] == 'true',
          subjectCount:    int.tryParse(s['subjectCount'] ?? '0') ?? 0,
          studyHoursStart: s['studyHoursStart'] ?? '',
          studyHoursEnd:   s['studyHoursEnd'] ?? '',
        )).toList(),
      );
    }
  }

  Future<void> _saveToCache() async {
    await _storage.write(key: _keyStudyStart,      value: _formatTime(studyStart));
    await _storage.write(key: _keyStudyEnd,        value: _formatTime(studyEnd));
    await _storage.write(key: _keyBlockedSlots,    value: jsonEncode(blockedSlots.toList()));
    await _storage.write(key: _keySubjects,        value: jsonEncode(subjects));
    await _storage.write(key: _keySemesters,       value: jsonEncode(semesters));
    await _storage.write(key: _keyTaskReminders,   value: taskReminders.toString());
    await _storage.write(key: _keySlotEndPrompts,  value: slotEndPrompts.toString());
    await _storage.write(key: _keyBurnoutWarnings, value: burnoutWarnings.toString());
    await _storage.write(key: _keyWeeklyReset,     value: weeklyResetSummary.toString());
    if (data != null) {
      await _storage.write(key: _keyUserId,       value: data!.userId.toString());
      await _storage.write(key: _keyUserName,     value: data!.userName);
      await _storage.write(key: _keySemester,     value: data!.semester);
      await _storage.write(key: _keyYear,         value: data!.year.toString());
      await _storage.write(key: _keySubjectCount, value: data!.subjectCount.toString());
      await _storage.write(key: _keyBlockedCount, value: data!.blockedSlotsCount.toString());
      await _storage.write(key: _keyAppVersion,   value: data!.appVersion);
    }
  }

  Future<void> toggleTaskReminders() async {
    taskReminders = !taskReminders;
    data = data?.copyWith(taskReminders: taskReminders);
    await _persistToggle('task_reminders', taskReminders);
  }

  Future<void> toggleSlotEndPrompts() async {
    slotEndPrompts = !slotEndPrompts;
    data = data?.copyWith(slotEndPrompts: slotEndPrompts);
    await _persistToggle('slot_end_prompts', slotEndPrompts);
  }

  Future<void> toggleBurnoutWarnings() async {
    burnoutWarnings = !burnoutWarnings;
    data = data?.copyWith(burnoutWarnings: burnoutWarnings);
    await _persistToggle('burnout_warnings', burnoutWarnings);
  }

  Future<void> toggleWeeklyResetSummary() async {
    weeklyResetSummary = !weeklyResetSummary;
    data = data?.copyWith(weeklyResetSummary: weeklyResetSummary);
    await _persistToggle('weekly_reset_summary', weeklyResetSummary);
  }

  Future<void> _persistToggle(String apiKey, bool value) async {
    await _saveToCache();
    _tryApiPatch({apiKey: value});
    notifyListeners();
  }

  Future<void> saveStudyHours(TimeOfDay start, TimeOfDay end) async {
    studyStart = start;
    studyEnd   = end;
    await _saveToCache();
    _tryApiPatch({'study_hours_start': _formatTime(start), 'study_hours_end': _formatTime(end)});
    notifyListeners();
  }

  Future<void> saveBlockedSlots(Set<String> slots) async {
    blockedSlots = slots;
    await _saveToCache();
    _tryApiPatch({'blocked_slots': slots.toList()});
    notifyListeners();
  }

  Future<void> saveSubjects(List<Map<String, String>> updated) async {
    subjects = updated;
    await _saveToCache();
    _tryApiPatch({'subjects': updated});
    notifyListeners();
  }

  Future<void> saveSemesters(List<Map<String, String>> updated) async {
    semesters = updated;
    data = data?.copyWith(
      semesters: updated.map((s) => SemesterModel(
        name:            s['name'] ?? '',
        isCurrent:       s['isCurrent'] == 'true',
        subjectCount:    int.tryParse(s['subjectCount'] ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '',
        studyHoursEnd:   s['studyHoursEnd'] ?? '',
      )).toList(),
    );
    await _saveToCache();
    _tryApiPatch({'semesters': updated});
    notifyListeners();
  }

  void selectSemester(String name) {
    semesters = semesters.map((s) {
      return {...s, 'isCurrent': (s['name'] == name).toString()};
    }).toList();
    data = data?.copyWith(
      semesters: semesters.map((s) => SemesterModel(
        name:            s['name'] ?? '',
        isCurrent:       s['isCurrent'] == 'true',
        subjectCount:    int.tryParse(s['subjectCount'] ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '',
        studyHoursEnd:   s['studyHoursEnd'] ?? '',
      )).toList(),
    );
    _saveToCache();
    _tryApiPatch({'semesters': semesters});
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await LoginController.clearSession();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void clear() {
    data               = null;
    studyStart         = const TimeOfDay(hour: 8,  minute: 0);
    studyEnd           = const TimeOfDay(hour: 22, minute: 0);
    blockedSlots       = {};
    subjects           = [];
    semesters          = [];
    taskReminders      = false;
    slotEndPrompts     = false;
    burnoutWarnings    = false;
    weeklyResetSummary = false;
    loading            = false;
    error              = null;
    notifyListeners();
  }

  void _tryApiPatch(Map<String, dynamic> body) async {
    try {
      await ApiService.patch('/student/settings', body);
    } catch (_) {}
  }

  TimeOfDay _parseTimeString(String s) {
    s = s.trim();
    if (s.contains(':')) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final isPm = s.toUpperCase().contains('PM');
    final isAm = s.toUpperCase().contains('AM');
    final num  = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int hour   = num;
    if (isPm && hour != 12) hour += 12;
    if (isAm && hour == 12) hour  = 0;
    return TimeOfDay(hour: hour, minute: 0);
  }

  String _formatTime(TimeOfDay t) {
    final h    = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h $ampm';
  }

  String get studyHoursDisplay =>
      '${_formatTime(studyStart)} – ${_formatTime(studyEnd)}';

  int get blockedSlotsCount => blockedSlots.length;
  int get subjectCount      => subjects.length;

  String? get currentSemesterName =>
      semesters.firstWhere(
            (s) => s['isCurrent'] == 'true',
        orElse: () => {},
      )['name'];



  void setData(StudentSettingsModel model) {
    data = model;
    studyStart         = _parseTimeString(model.studyHoursStart);
    studyEnd           = _parseTimeString(model.studyHoursEnd);
    taskReminders      = model.taskReminders;
    slotEndPrompts     = model.slotEndPrompts;
    burnoutWarnings    = model.burnoutWarnings;
    weeklyResetSummary = model.weeklyResetSummary;
    semesters          = model.semesters.map((s) => {
      'name':            s.name,
      'isCurrent':       s.isCurrent.toString(),
      'subjectCount':    s.subjectCount.toString(),
      'studyHoursStart': s.studyHoursStart,
      'studyHoursEnd':   s.studyHoursEnd,
    }).toList();
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setError(String message) {
    error   = message;
    loading = false;
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    data = data?.copyWith(userName: name);
    await _storage.write(key: _keyUserName, value: name);
    _tryApiPatch({'name': name});
    notifyListeners();
  }
}