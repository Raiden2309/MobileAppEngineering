import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/services/api_service.dart';
import '../models/student_settings_models.dart';
import '../models/semester_details_model.dart';

class StudentSettingsProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _keyStudyStart = 'settings_study_start';
  static const _keyStudyEnd = 'settings_study_end';
  static const _keyBlockedSlots = 'settings_blocked_slots';
  static const _keySubjects = 'settings_subjects';
  static const _keySemesters = 'settings_semesters';
  static const _keyTaskReminders = 'settings_task_reminders';
  static const _keySlotEndPrompts = 'settings_slot_end_prompts';
  static const _keyBurnoutWarnings = 'settings_burnout_warnings';
  static const _keyWeeklyReset = 'settings_weekly_reset_summary';
  static const _keyUserId = 'settings_user_id';
  static const _keyUserName = 'settings_user_name';
  static const _keySemester = 'settings_semester';
  static const _keyYear = 'settings_year';
  static const _keySubjectCount = 'settings_subject_count';
  static const _keyBlockedCount = 'settings_blocked_slots_count';
  static const _keyAppVersion = 'settings_app_version';
  static const _keyAvatarUrl = 'settings_avatar_url';
  static const _keyJoinedClasses = 'settings_joined_classes';

  StudentSettingsModel? data;

  // --- LIVE VARIABLE OVERRIDES ---
  String currentLiveName = 'Edwin Chin Chun Wui';
  String currentLiveSemester = '1';
  int currentLiveYear = 1;

  TimeOfDay studyStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay studyEnd = const TimeOfDay(hour: 22, minute: 0);

  Set<String> blockedSlots = {};
  List<Map<String, String>> subjects = [];
  List<Map<String, String>> semesters = [];
  List<JoinedClassModel> joinedClasses = [];

  bool taskReminders = false;
  bool slotEndPrompts = false;
  bool burnoutWarnings = false;
  bool weeklyResetSummary = false;

  String? avatarUrl;
  bool loading = false;
  String? error;

  String get studyHoursDisplay =>
      '${_formatTime(studyStart)} – ${_formatTime(studyEnd)}';

  int get blockedSlotsCount => blockedSlots.length;
  int get subjectCount => subjects.length;
  int get joinedClassCount => joinedClasses.length;

  String? get currentSemesterName => semesters.firstWhere(
        (s) => s['isCurrent'] == 'true',
    orElse: () => {},
  )['name'];

  void loadMock() {
    setData(StudentSettingsModel.mockData());
  }

  /// DYNAMIC: Loads configurations and explicitly updates active state variables
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    await _loadFromCache();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final userDoc = await _db.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final docMap = userDoc.data();

          // Pull variables straight out of your Firestore document fields
          currentLiveName = docMap?['name']?.toString() ?? 'Edwin Chin Chun Wui';
          currentLiveSemester = docMap?['semester']?.toString() ?? '1';
          currentLiveYear = (docMap?['year'] as num? ?? 1).toInt();

          // Force reconstruct the main data model used by your layout widgets
          data = StudentSettingsModel(
            userId: data?.userId ?? 1,
            userName: currentLiveName,
            semester: currentLiveSemester,
            year: currentLiveYear,
            subjectCount: subjectCount,
            studyHoursStart: _formatTime(studyStart),
            studyHoursEnd: _formatTime(studyEnd),
            blockedSlotsCount: blockedSlotsCount,
            taskReminders: taskReminders,
            slotEndPrompts: slotEndPrompts,
            burnoutWarnings: burnoutWarnings,
            weeklyResetSummary: weeklyResetSummary,
            appVersion: data?.appVersion ?? 'v1.0',
            joinedClassCount: joinedClassCount,
            semesters: data?.semesters ?? [],
            avatarUrl: avatarUrl,
          );

          await _saveToCache();
        }
      }
    } catch (e) {
      debugPrint("Firebase Profile Fetch Failed: $e");
    }

    loading = false;
    notifyListeners();
  }

  void _applyFromApi(Map<String, dynamic> json) {
    data = StudentSettingsModel.fromJson(json);
    avatarUrl = data!.avatarUrl;
    studyStart = _parseTimeString(data!.studyHoursStart);
    studyEnd = _parseTimeString(data!.studyHoursEnd);
    taskReminders = data!.taskReminders;
    slotEndPrompts = data!.slotEndPrompts;
    burnoutWarnings = data!.burnoutWarnings;
    weeklyResetSummary = data!.weeklyResetSummary;
    semesters = data!.semesters.map((s) => {
      'name': s.name,
      'isCurrent': s.isCurrent.toString(),
      'subjectCount': s.subjectCount.toString(),
      'studyHoursStart': s.studyHoursStart,
      'studyHoursEnd': s.studyHoursEnd,
    }).toList();

    if (json['blocked_slots'] != null) {
      blockedSlots = Set<String>.from(json['blocked_slots'] as List);
    }
    if (json['subjects'] != null) {
      subjects = (json['subjects'] as List).map((e) => Map<String, String>.from(e as Map)).toList();
    }
    if (json['joined_classes'] != null) {
      joinedClasses = (json['joined_classes'] as List).map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data != null) {
      data = data!.copyWith(
        joinedClassCount: joinedClasses.length,
      );
    }
  }

  Future<void> _loadFromCache() async {
    final start = await _storage.read(key: _keyStudyStart);
    final end = await _storage.read(key: _keyStudyEnd);
    final slots = await _storage.read(key: _keyBlockedSlots);
    final subjRaw = await _storage.read(key: _keySubjects);
    final semRaw = await _storage.read(key: _keySemesters);
    final trRaw = await _storage.read(key: _keyTaskReminders);
    final sepRaw = await _storage.read(key: _keySlotEndPrompts);
    final bwRaw = await _storage.read(key: _keyBurnoutWarnings);
    final wrsRaw = await _storage.read(key: _keyWeeklyReset);
    final userIdRaw = await _storage.read(key: _keyUserId);
    final userNameRaw = await _storage.read(key: _keyUserName);
    final semesterRaw = await _storage.read(key: _keySemester);
    final yearRaw = await _storage.read(key: _keyYear);
    final subjCountRaw = await _storage.read(key: _keySubjectCount);
    final blockedCountRaw = await _storage.read(key: _keyBlockedCount);
    final appVersionRaw = await _storage.read(key: _keyAppVersion);
    final avatarRaw = await _storage.read(key: _keyAvatarUrl);
    final classesRaw = await _storage.read(key: _keyJoinedClasses);

    if (avatarRaw != null) avatarUrl = avatarRaw;
    if (start != null) studyStart = _parseTimeString(start);
    if (end != null) studyEnd = _parseTimeString(end);
    if (slots != null) blockedSlots = Set<String>.from(jsonDecode(slots) as List);

    if (subjRaw != null) {
      subjects = (jsonDecode(subjRaw) as List).map((e) => Map<String, String>.from(e as Map)).toList();
    }
    if (semRaw != null) {
      semesters = (jsonDecode(semRaw) as List).map((e) => Map<String, String>.from(e as Map)).toList();
    }
    if (classesRaw != null) {
      joinedClasses = (jsonDecode(classesRaw) as List).map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    if (trRaw != null) taskReminders = trRaw == 'true';
    if (sepRaw != null) slotEndPrompts = sepRaw == 'true';
    if (bwRaw != null) burnoutWarnings = bwRaw == 'true';
    if (wrsRaw != null) weeklyResetSummary = wrsRaw == 'true';

    currentLiveName = userNameRaw ?? 'Edwin Chin Chun Wui';
    currentLiveSemester = semesterRaw ?? '1';
    currentLiveYear = int.tryParse(yearRaw ?? '1') ?? 1;

    if (semesters.isNotEmpty || userIdRaw != null) {
      data = StudentSettingsModel(
        userId: int.tryParse(userIdRaw ?? '0') ?? 0,
        userName: currentLiveName,
        semester: currentLiveSemester,
        year: currentLiveYear,
        subjectCount: int.tryParse(subjCountRaw ?? '0') ?? 0,
        studyHoursStart: _formatTime(studyStart),
        studyHoursEnd: _formatTime(studyEnd),
        blockedSlotsCount: int.tryParse(blockedCountRaw ?? '0') ?? 0,
        taskReminders: taskReminders,
        slotEndPrompts: slotEndPrompts,
        burnoutWarnings: burnoutWarnings,
        weeklyResetSummary: weeklyResetSummary,
        appVersion: appVersionRaw ?? 'v1.0',
        joinedClassCount: joinedClasses.length,
        semesters: semesters.map((s) => SemesterModel(
          name: s['name'] ?? '',
          isCurrent: s['isCurrent'] == 'true',
          subjectCount: int.tryParse(s['subjectCount'] ?? '0') ?? 0,
          studyHoursStart: s['studyHoursStart'] ?? '',
          studyHoursEnd: s['studyHoursEnd'] ?? '',
        )).toList(),
      );
    }
  }

  Future<void> _saveToCache() async {
    await _storage.write(key: _keyStudyStart, value: _formatTime(studyStart));
    await _storage.write(key: _keyStudyEnd, value: _formatTime(studyEnd));
    await _storage.write(key: _keyBlockedSlots, value: jsonEncode(blockedSlots.toList()));
    await _storage.write(key: _keySubjects, value: jsonEncode(subjects));
    await _storage.write(key: _keySemesters, value: jsonEncode(semesters));
    await _storage.write(key: _keyTaskReminders, value: taskReminders.toString());
    await _storage.write(key: _keySlotEndPrompts, value: slotEndPrompts.toString());
    await _storage.write(key: _keyBurnoutWarnings, value: burnoutWarnings.toString());
    await _storage.write(key: _keyWeeklyReset, value: weeklyResetSummary.toString());
    await _storage.write(key: _keyJoinedClasses, value: jsonEncode(joinedClasses.map((c) => {'id': c.id, 'name': c.name}).toList()));

    if (data != null) {
      await _storage.write(key: _keyUserId, value: data!.userId.toString());
      await _storage.write(key: _keyUserName, value: currentLiveName);
      await _storage.write(key: _keySemester, value: currentLiveSemester);
      await _storage.write(key: _keyYear, value: currentLiveYear.toString());
      await _storage.write(key: _keySubjectCount, value: subjectCount.toString());
      await _storage.write(key: _keyBlockedCount, value: blockedSlotsCount.toString());
      await _storage.write(key: _keyAppVersion, value: data!.appVersion);
      if (avatarUrl != null) {
        await _storage.write(key: _keyAvatarUrl, value: avatarUrl!);
      }
    }
  }

  Future<bool> joinClass(String code) async {
    try {
      final response = await ApiService.post('/student/classes/join', {'code': code});
      debugPrint('joinClass response: $response');
      final joined = JoinedClassModel.fromJson(response as Map<String, dynamic>);
      if (!joinedClasses.any((c) => c.id == joined.id)) {
        joinedClasses = [...joinedClasses, joined];
        data = data?.copyWith(joinedClassCount: joinedClasses.length);
        await _saveToCache();
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('joinClass error: $e');
      return false;
    }
  }

  Future<void> leaveClass(String classId) async {
    joinedClasses = joinedClasses.where((c) => c.id != classId).toList();
    data = data?.copyWith(joinedClassCount: joinedClasses.length);
    await _saveToCache();
    _tryApiDelete('/student/classes/$classId');
    notifyListeners();
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
    studyEnd = end;
    await _saveToCache();
    _tryApiPatch({
      'study_hours_start': _formatTime(start),
      'study_hours_end': _formatTime(end),
    });
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
        name: s['name'] ?? '',
        isCurrent: s['isCurrent'] == 'true',
        subjectCount: int.tryParse(s['subjectCount'] ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '',
        studyHoursEnd: s['studyHoursEnd'] ?? '',
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
        name: s['name'] ?? '',
        isCurrent: s['isCurrent'] == 'true',
        subjectCount: int.tryParse(s['subjectCount'] ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '',
        studyHoursEnd: s['studyHoursEnd'] ?? '',
      )).toList(),
    );
    _saveToCache();
    _tryApiPatch({'semesters': semesters});
    notifyListeners();
  }

  /// Writes modifications back into the user documentation node in Firestore
  Future<void> updateUserName(String name) async {
    currentLiveName = name;
    if (data != null) {
      data = StudentSettingsModel(
        userId: data!.userId,
        userName: currentLiveName,
        semester: currentLiveSemester,
        year: currentLiveYear,
        subjectCount: subjectCount,
        studyHoursStart: _formatTime(studyStart),
        studyHoursEnd: _formatTime(studyEnd),
        blockedSlotsCount: blockedSlotsCount,
        taskReminders: taskReminders,
        slotEndPrompts: slotEndPrompts,
        burnoutWarnings: burnoutWarnings,
        weeklyResetSummary: weeklyResetSummary,
        appVersion: data!.appVersion,
        joinedClassCount: joinedClassCount,
        semesters: data!.semesters,
        avatarUrl: data!.avatarUrl,
      );
    }
    await _storage.write(key: _keyUserName, value: name);
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).update({'name': name});
      }
    } catch (e) {
      debugPrint("Failed to write updated user profile identity fields: $e");
    }
  }

  Future<void> updateAvatar(XFile file) async {
    try {
      final response = await ApiService.uploadImage('/student/settings/avatar', file.path);
      final remoteUrl = response['avatar_url'] as String;
      avatarUrl = remoteUrl;
      data = data?.copyWith(avatarUrl: remoteUrl);
      await _storage.write(key: _keyAvatarUrl, value: remoteUrl);
      notifyListeners();
    } catch (_) {
      setError('Failed to upload avatar');
    }
  }

  void setData(StudentSettingsModel model) {
    data = model;
    studyStart = _parseTimeString(model.studyHoursStart);
    studyEnd = _parseTimeString(model.studyHoursEnd);
    taskReminders = model.taskReminders;
    slotEndPrompts = model.slotEndPrompts;
    burnoutWarnings = model.burnoutWarnings;
    weeklyResetSummary = model.weeklyResetSummary;

    currentLiveName = model.userName;
    currentLiveSemester = model.semester;
    currentLiveYear = model.year;

    subjects = model.subjects.map((s) => {
      'id': s.id.toString(),
      'student_id': s.studentId.toString(),
      'semester_id': s.semesterId.toString(),
      'subject_id': s.subjectId.toString(),
      'name': s.name,
      'code': s.code,
      'color_hex': s.colorHex,
    }).toList();
    blockedSlots = Set.from(model.blockedSlots);
    semesters = model.semesters.map((s) => {
      'name': s.name,
      'isCurrent': s.isCurrent.toString(),
      'subjectCount': s.subjectCount.toString(),
      'studyHoursStart': s.studyHoursStart,
      'studyHoursEnd': s.studyHoursEnd,
    }).toList();
    avatarUrl = model.avatarUrl;
    notifyListeners();
  }

  void clear() {
    data = null;
    studyStart = const TimeOfDay(hour: 8, minute: 0);
    studyEnd = const TimeOfDay(hour: 22, minute: 0);
    blockedSlots = {};
    subjects = [];
    semesters = [];
    joinedClasses = [];
    taskReminders = false;
    slotEndPrompts = false;
    burnoutWarnings = false;
    weeklyResetSummary = false;
    loading = false;
    error = null;
    avatarUrl = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setError(String message) {
    error = message;
    loading = false;
    notifyListeners();
  }

  void _tryApiPatch(Map<String, dynamic> body) async {
    try {
      await ApiService.patch('/student/settings', body);
    } catch (_) {}
  }

  void _tryApiDelete(String path) async {
    try {
      await ApiService.delete(path);
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
    final num = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int hour = num;
    if (isPm && hour != 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: 0);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h $ampm';
  }
}