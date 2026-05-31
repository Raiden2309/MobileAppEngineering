import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/student_settings_models.dart';
import '../models/semester_details_model.dart';

class StudentSettingsProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;
  final FirebaseStorage   _fbStorage = FirebaseStorage.instance;

  static const _keyStudyStart       = 'settings_study_start';
  static const _keyStudyEnd         = 'settings_study_end';
  static const _keyBlockedSlots     = 'settings_blocked_slots';
  static const _keySubjects         = 'settings_subjects';
  static const _keySemesters        = 'settings_semesters';
  static const _keyTaskReminders    = 'settings_task_reminders';
  static const _keySlotEndPrompts   = 'settings_slot_end_prompts';
  static const _keyBurnoutWarnings  = 'settings_burnout_warnings';
  static const _keyWeeklyReset      = 'settings_weekly_reset_summary';
  static const _keyUserId           = 'settings_user_id';
  static const _keyUserName         = 'settings_user_name';
  static const _keySemester         = 'settings_semester';
  static const _keyYear             = 'settings_year';
  static const _keySubjectCount     = 'settings_subject_count';
  static const _keyBlockedCount     = 'settings_blocked_slots_count';
  static const _keyAppVersion       = 'settings_app_version';
  static const _keyAvatarUrl        = 'settings_avatar_url';
  static const _keyJoinedClasses    = 'settings_joined_classes';

  StudentSettingsModel? data;

  String currentLiveName     = 'Edwin Chin Chun Wui';
  String currentLiveSemester = '1';
  int    currentLiveYear     = 1;

  TimeOfDay studyStart = const TimeOfDay(hour: 8,  minute: 0);
  TimeOfDay studyEnd   = const TimeOfDay(hour: 22, minute: 0);

  Set<String>               blockedSlots  = {};
  List<Map<String, String>> subjects      = [];
  List<Map<String, String>> semesters     = [];
  List<JoinedClassModel>    joinedClasses = [];

  bool taskReminders     = false;
  bool slotEndPrompts    = false;
  bool burnoutWarnings   = false;
  bool weeklyResetSummary = false;

  String? avatarUrl;
  bool    loading = false;
  String? error;

  String get studyHoursDisplay => '${_formatTime(studyStart)} – ${_formatTime(studyEnd)}';
  int get blockedSlotsCount  => blockedSlots.length;
  int get subjectCount       => subjects.length;
  int get joinedClassCount   => joinedClasses.length;

  String? get currentSemesterName => semesters.firstWhere(
        (s) => s['isCurrent'] == 'true',
    orElse: () => {},
  )['name'];

  String? get _uid => _auth.currentUser?.uid;

  void loadMock() => setData(StudentSettingsModel.mockData());

  Future<void> load() async {
    loading = true;
    error   = null;
    notifyListeners();

    await _loadFromCache();

    try {
      if (_uid != null) {
        final userDoc = await _db.collection('users').doc(_uid).get();
        if (userDoc.exists) {
          final docMap = userDoc.data();

          currentLiveName     = docMap?['name']?.toString()            ?? currentLiveName;
          currentLiveSemester = docMap?['semester']?.toString()        ?? currentLiveSemester;
          currentLiveYear     = (docMap?['year'] as num? ?? currentLiveYear).toInt();

          // Load settings sub-fields if stored in Firestore
          if (docMap?['blocked_slots'] != null) {
            blockedSlots = Set<String>.from(docMap!['blocked_slots'] as List);
          }
          if (docMap?['subjects'] != null) {
            subjects = (docMap!['subjects'] as List)
                .map((e) => Map<String, String>.from(e as Map))
                .toList();
          }
          if (docMap?['joined_classes'] != null) {
            joinedClasses = (docMap!['joined_classes'] as List)
                .map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          taskReminders      = docMap?['task_reminders']      as bool? ?? taskReminders;
          slotEndPrompts     = docMap?['slot_end_prompts']     as bool? ?? slotEndPrompts;
          burnoutWarnings    = docMap?['burnout_warnings']     as bool? ?? burnoutWarnings;
          weeklyResetSummary = docMap?['weekly_reset_summary'] as bool? ?? weeklyResetSummary;
          avatarUrl          = docMap?['avatar_url']?.toString() ?? avatarUrl;

          data = StudentSettingsModel(
            userId:            data?.userId ?? 1,
            userName:          currentLiveName,
            semester:          currentLiveSemester,
            year:              currentLiveYear,
            subjectCount:      subjectCount,
            studyHoursStart:   _formatTime(studyStart),
            studyHoursEnd:     _formatTime(studyEnd),
            blockedSlotsCount: blockedSlotsCount,
            taskReminders:     taskReminders,
            slotEndPrompts:    slotEndPrompts,
            burnoutWarnings:   burnoutWarnings,
            weeklyResetSummary: weeklyResetSummary,
            appVersion:        data?.appVersion ?? 'v1.0',
            joinedClassCount:  joinedClassCount,
            semesters:         data?.semesters ?? [],
            avatarUrl:         avatarUrl,
          );

          await _saveToCache();
        }
      }
    } catch (e) {
      debugPrint('Firebase Profile Fetch Failed: $e');
    }

    loading = false;
    notifyListeners();
  }

  // ── Join class via Firestore join_codes collection ──
  Future<bool> joinClass(String code) async {
    if (_uid == null) return false;
    try {
      final codeDoc = await _db.collection('join_codes').doc(code).get();
      if (!codeDoc.exists) {
        debugPrint('joinClass: code not found');
        return false;
      }

      final classData = codeDoc.data()!;
      final joined = JoinedClassModel(
        id:   code,
        name: classData['subjectName']?.toString() ?? code,
      );

      if (!joinedClasses.any((c) => c.id == joined.id)) {
        joinedClasses = [...joinedClasses, joined];
        data = data?.copyWith(joinedClassCount: joinedClasses.length);

        // Write joined class back to user's Firestore doc
        await _db.collection('users').doc(_uid).update({
          'joined_classes': joinedClasses
              .map((c) => {'id': c.id, 'name': c.name})
              .toList(),
        });

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
    _tryFirestorePatch({
      'joined_classes': joinedClasses
          .map((c) => {'id': c.id, 'name': c.name})
          .toList(),
    });
    notifyListeners();
  }

  Future<void> toggleTaskReminders() async {
    taskReminders = !taskReminders;
    data = data?.copyWith(taskReminders: taskReminders);
    await _persistToggle({'task_reminders': taskReminders});
  }

  Future<void> toggleSlotEndPrompts() async {
    slotEndPrompts = !slotEndPrompts;
    data = data?.copyWith(slotEndPrompts: slotEndPrompts);
    await _persistToggle({'slot_end_prompts': slotEndPrompts});
  }

  Future<void> toggleBurnoutWarnings() async {
    burnoutWarnings = !burnoutWarnings;
    data = data?.copyWith(burnoutWarnings: burnoutWarnings);
    await _persistToggle({'burnout_warnings': burnoutWarnings});
  }

  Future<void> toggleWeeklyResetSummary() async {
    weeklyResetSummary = !weeklyResetSummary;
    data = data?.copyWith(weeklyResetSummary: weeklyResetSummary);
    await _persistToggle({'weekly_reset_summary': weeklyResetSummary});
  }

  Future<void> _persistToggle(Map<String, dynamic> fields) async {
    await _saveToCache();
    _tryFirestorePatch(fields);
    notifyListeners();
  }

  Future<void> saveStudyHours(TimeOfDay start, TimeOfDay end) async {
    studyStart = start;
    studyEnd   = end;
    await _saveToCache();
    _tryFirestorePatch({
      'study_hours_start': _formatTime(start),
      'study_hours_end':   _formatTime(end),
    });
    notifyListeners();
  }

  Future<void> saveBlockedSlots(Set<String> slots) async {
    blockedSlots = slots;
    await _saveToCache();
    _tryFirestorePatch({'blocked_slots': slots.toList()});
    notifyListeners();
  }

  Future<void> saveSubjects(List<Map<String, String>> updated) async {
    subjects = updated;
    await _saveToCache();
    _tryFirestorePatch({'subjects': updated});
    notifyListeners();
  }

  Future<void> saveSemesters(List<Map<String, String>> updated) async {
    semesters = updated;
    data = data?.copyWith(
      semesters: updated.map((s) => SemesterModel(
        name:            s['name']            ?? '',
        isCurrent:       s['isCurrent']       == 'true',
        subjectCount:    int.tryParse(s['subjectCount']    ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '',
        studyHoursEnd:   s['studyHoursEnd']   ?? '',
      )).toList(),
    );
    await _saveToCache();
    _tryFirestorePatch({'semesters': updated});
    notifyListeners();
  }

  void selectSemester(String name) {
    semesters = semesters.map((s) {
      return {...s, 'isCurrent': (s['name'] == name).toString()};
    }).toList();
    data = data?.copyWith(
      semesters: semesters.map((s) => SemesterModel(
        name:            s['name']            ?? '',
        isCurrent:       s['isCurrent']       == 'true',
        subjectCount:    int.tryParse(s['subjectCount']    ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '',
        studyHoursEnd:   s['studyHoursEnd']   ?? '',
      )).toList(),
    );
    _saveToCache();
    _tryFirestorePatch({'semesters': semesters});
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    currentLiveName = name;
    if (data != null) {
      data = StudentSettingsModel(
        userId:            data!.userId,
        userName:          currentLiveName,
        semester:          currentLiveSemester,
        year:              currentLiveYear,
        subjectCount:      subjectCount,
        studyHoursStart:   _formatTime(studyStart),
        studyHoursEnd:     _formatTime(studyEnd),
        blockedSlotsCount: blockedSlotsCount,
        taskReminders:     taskReminders,
        slotEndPrompts:    slotEndPrompts,
        burnoutWarnings:   burnoutWarnings,
        weeklyResetSummary: weeklyResetSummary,
        appVersion:        data!.appVersion,
        joinedClassCount:  joinedClassCount,
        semesters:         data!.semesters,
        avatarUrl:         data!.avatarUrl,
      );
    }
    await _storage.write(key: _keyUserName, value: name);
    notifyListeners();

    try {
      if (_uid != null) {
        await _db.collection('users').doc(_uid).update({'name': name});
      }
    } catch (e) {
      debugPrint('Failed to update user name in Firestore: $e');
    }
  }

  // ── Upload avatar to Firebase Storage ──
  Future<void> updateAvatar(XFile file) async {
    if (_uid == null) return;
    try {
      final ref = _fbStorage.ref().child('avatars/students/$_uid.jpg');
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();

      avatarUrl = url;
      data = data?.copyWith(avatarUrl: url);
      await _storage.write(key: _keyAvatarUrl, value: url);
      _tryFirestorePatch({'avatar_url': url});
      notifyListeners();
    } catch (_) {
      setError('Failed to upload avatar');
    }
  }

  void setData(StudentSettingsModel model) {
    data               = model;
    studyStart         = _parseTimeString(model.studyHoursStart);
    studyEnd           = _parseTimeString(model.studyHoursEnd);
    taskReminders      = model.taskReminders;
    slotEndPrompts     = model.slotEndPrompts;
    burnoutWarnings    = model.burnoutWarnings;
    weeklyResetSummary = model.weeklyResetSummary;
    currentLiveName     = model.userName;
    currentLiveSemester = model.semester;
    currentLiveYear     = model.year;
    subjects = model.subjects.map((s) => {
      'id':           s.id.toString(),
      'student_id':   s.studentId.toString(),
      'semester_id':  s.semesterId.toString(),
      'subject_id':   s.subjectId.toString(),
      'name':         s.name,
      'code':         s.code,
      'color_hex':    s.colorHex,
    }).toList();
    blockedSlots = Set.from(model.blockedSlots);
    semesters = model.semesters.map((s) => {
      'name':            s.name,
      'isCurrent':       s.isCurrent.toString(),
      'subjectCount':    s.subjectCount.toString(),
      'studyHoursStart': s.studyHoursStart,
      'studyHoursEnd':   s.studyHoursEnd,
    }).toList();
    avatarUrl = model.avatarUrl;
    notifyListeners();
  }

  void clear() {
    data               = null;
    studyStart         = const TimeOfDay(hour: 8,  minute: 0);
    studyEnd           = const TimeOfDay(hour: 22, minute: 0);
    blockedSlots       = {};
    subjects           = [];
    semesters          = [];
    joinedClasses      = [];
    taskReminders      = false;
    slotEndPrompts     = false;
    burnoutWarnings    = false;
    weeklyResetSummary = false;
    loading            = false;
    error              = null;
    avatarUrl          = null;
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

  void _tryFirestorePatch(Map<String, dynamic> fields) async {
    if (_uid == null) return;
    try {
      await _db.collection('users').doc(_uid).update(fields);
    } catch (e) {
      debugPrint('Firestore patch failed: $e');
    }
  }

  Future<void> _loadFromCache() async {
    final start           = await _storage.read(key: _keyStudyStart);
    final end             = await _storage.read(key: _keyStudyEnd);
    final slots           = await _storage.read(key: _keyBlockedSlots);
    final subjRaw         = await _storage.read(key: _keySubjects);
    final semRaw          = await _storage.read(key: _keySemesters);
    final trRaw           = await _storage.read(key: _keyTaskReminders);
    final sepRaw          = await _storage.read(key: _keySlotEndPrompts);
    final bwRaw           = await _storage.read(key: _keyBurnoutWarnings);
    final wrsRaw          = await _storage.read(key: _keyWeeklyReset);
    final userIdRaw       = await _storage.read(key: _keyUserId);
    final userNameRaw     = await _storage.read(key: _keyUserName);
    final semesterRaw     = await _storage.read(key: _keySemester);
    final yearRaw         = await _storage.read(key: _keyYear);
    final subjCountRaw    = await _storage.read(key: _keySubjectCount);
    final blockedCountRaw = await _storage.read(key: _keyBlockedCount);
    final appVersionRaw   = await _storage.read(key: _keyAppVersion);
    final avatarRaw       = await _storage.read(key: _keyAvatarUrl);
    final classesRaw      = await _storage.read(key: _keyJoinedClasses);

    if (avatarRaw != null) avatarUrl              = avatarRaw;
    if (start     != null) studyStart             = _parseTimeString(start);
    if (end       != null) studyEnd               = _parseTimeString(end);
    if (slots     != null) blockedSlots           = Set<String>.from(jsonDecode(slots) as List);
    if (trRaw     != null) taskReminders          = trRaw  == 'true';
    if (sepRaw    != null) slotEndPrompts         = sepRaw == 'true';
    if (bwRaw     != null) burnoutWarnings        = bwRaw  == 'true';
    if (wrsRaw    != null) weeklyResetSummary     = wrsRaw == 'true';

    currentLiveName     = userNameRaw ?? currentLiveName;
    currentLiveSemester = semesterRaw ?? currentLiveSemester;
    currentLiveYear     = int.tryParse(yearRaw ?? '') ?? currentLiveYear;

    if (subjRaw   != null) subjects      = (jsonDecode(subjRaw)   as List).map((e) => Map<String, String>.from(e as Map)).toList();
    if (semRaw    != null) semesters     = (jsonDecode(semRaw)    as List).map((e) => Map<String, String>.from(e as Map)).toList();
    if (classesRaw != null) joinedClasses = (jsonDecode(classesRaw) as List).map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>)).toList();

    if (userIdRaw != null || semesters.isNotEmpty) {
      data = StudentSettingsModel(
        userId:            int.tryParse(userIdRaw ?? '0') ?? 0,
        userName:          currentLiveName,
        semester:          currentLiveSemester,
        year:              currentLiveYear,
        subjectCount:      int.tryParse(subjCountRaw    ?? '0') ?? 0,
        studyHoursStart:   _formatTime(studyStart),
        studyHoursEnd:     _formatTime(studyEnd),
        blockedSlotsCount: int.tryParse(blockedCountRaw ?? '0') ?? 0,
        taskReminders:     taskReminders,
        slotEndPrompts:    slotEndPrompts,
        burnoutWarnings:   burnoutWarnings,
        weeklyResetSummary: weeklyResetSummary,
        appVersion:        appVersionRaw ?? 'v1.0',
        joinedClassCount:  joinedClasses.length,
        semesters:         semesters.map((s) => SemesterModel(
          name:            s['name']            ?? '',
          isCurrent:       s['isCurrent']       == 'true',
          subjectCount:    int.tryParse(s['subjectCount']    ?? '0') ?? 0,
          studyHoursStart: s['studyHoursStart'] ?? '',
          studyHoursEnd:   s['studyHoursEnd']   ?? '',
        )).toList(),
      );
    }
  }

  Future<void> _saveToCache() async {
    await _storage.write(key: _keyStudyStart,    value: _formatTime(studyStart));
    await _storage.write(key: _keyStudyEnd,      value: _formatTime(studyEnd));
    await _storage.write(key: _keyBlockedSlots,  value: jsonEncode(blockedSlots.toList()));
    await _storage.write(key: _keySubjects,      value: jsonEncode(subjects));
    await _storage.write(key: _keySemesters,     value: jsonEncode(semesters));
    await _storage.write(key: _keyTaskReminders, value: taskReminders.toString());
    await _storage.write(key: _keySlotEndPrompts,value: slotEndPrompts.toString());
    await _storage.write(key: _keyBurnoutWarnings,value: burnoutWarnings.toString());
    await _storage.write(key: _keyWeeklyReset,   value: weeklyResetSummary.toString());
    await _storage.write(key: _keyJoinedClasses, value: jsonEncode(
      joinedClasses.map((c) => {'id': c.id, 'name': c.name}).toList(),
    ));
    if (data != null) {
      await _storage.write(key: _keyUserId,      value: data!.userId.toString());
      await _storage.write(key: _keyUserName,    value: currentLiveName);
      await _storage.write(key: _keySemester,    value: currentLiveSemester);
      await _storage.write(key: _keyYear,        value: currentLiveYear.toString());
      await _storage.write(key: _keySubjectCount,value: subjectCount.toString());
      await _storage.write(key: _keyBlockedCount,value: blockedSlotsCount.toString());
      await _storage.write(key: _keyAppVersion,  value: data!.appVersion);
      if (avatarUrl != null) await _storage.write(key: _keyAvatarUrl, value: avatarUrl!);
    }
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
    if (isAm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: 0);
  }

  String _formatTime(TimeOfDay t) {
    final h    = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h $ampm';
  }
}