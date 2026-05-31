import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/study_plan_provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/task_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/student_settings_models.dart';
import '../models/semester_details_model.dart';

class StudentSettingsProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  final FirebaseFirestore _db        = FirebaseFirestore.instance;
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseStorage   _fbStorage = FirebaseStorage.instance;

  // ── Cache keys ──────────────────────────────────────────────────────────────
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
  static const _keyAvatarUrl       = 'settings_avatar_url';
  static const _keyJoinedClasses   = 'settings_joined_classes';
  static const _keyCurrentSemId    = 'settings_current_sem_id';

  // ── State ────────────────────────────────────────────────────────────────────
  StudentSettingsModel? data;

  String currentLiveName     = '';
  String currentLiveSemester = '1';
  int    currentLiveYear     = 1;
  String? avatarUrl;

  TimeOfDay studyStart = const TimeOfDay(hour: 8,  minute: 0);
  TimeOfDay studyEnd   = const TimeOfDay(hour: 22, minute: 0);

  Set<String>               blockedSlots  = {};
  List<Map<String, String>> subjects      = [];
  List<Map<String, String>> semesters     = [];
  List<JoinedClassModel>    joinedClasses = [];

  String? currentSemesterId;

  bool taskReminders      = false;
  bool slotEndPrompts     = false;
  bool burnoutWarnings    = false;
  bool weeklyResetSummary = false;

  bool    loading = false;
  String? error;

  // Real-time listener subscriptions
  StreamSubscription? _userSubscription;
  StreamSubscription? _enrollmentSubscription;

  // ── Computed ────────────────────────────────────────────────────────────────
  String get studyHoursDisplay  => '${_formatTime(studyStart)} – ${_formatTime(studyEnd)}';
  int    get blockedSlotsCount  => blockedSlots.length;
  int    get subjectCount       => subjects.length;
  int    get joinedClassCount   => joinedClasses.length;
  String? get _uid              => _auth.currentUser?.uid;

  String get activeSemesterName {
    final current = semesters.firstWhere(
          (s) => s['isCurrent'] == 'true',
      orElse: () => semesters.isNotEmpty ? semesters.first : {},
    );
    return current['id'] ?? current['semesterKey'] ?? current['name'] ?? '';
  }

  // ── Constructor ──────────────────────────────────────────────────────────────
  StudentSettingsProvider() {
    initLiveListeners();
  }

  // ── Real-time listeners ──────────────────────────────────────────────────────
  void initLiveListeners() async {
    final user = _auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    await _loadFromCache();

    // Pipeline 1: Listen to user document changes
    _userSubscription?.cancel();
    _userSubscription = _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;

      final d = snapshot.data()!;
      currentLiveName     = d['name']?.toString()     ?? currentLiveName;
      currentLiveSemester = d['semester']?.toString() ?? currentLiveSemester;
      currentLiveYear     = (d['year'] as num?)?.toInt() ?? currentLiveYear;
      currentSemesterId   = d['currentSemesterId']?.toString() ?? currentSemesterId;

      if (d['study_hours_start'] != null) studyStart   = _parseTimeString(d['study_hours_start'].toString());
      if (d['study_hours_end']   != null) studyEnd     = _parseTimeString(d['study_hours_end'].toString());
      if (d['blocked_slots']     != null) blockedSlots = Set<String>.from(d['blocked_slots'] as List);
      if (d['joined_classes']    != null) {
        joinedClasses = (d['joined_classes'] as List)
            .map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      taskReminders      = d['task_reminders']       as bool? ?? taskReminders;
      slotEndPrompts     = d['slot_end_prompts']     as bool? ?? slotEndPrompts;
      burnoutWarnings    = d['burnout_warnings']     as bool? ?? burnoutWarnings;
      weeklyResetSummary = d['weekly_reset_summary'] as bool? ?? weeklyResetSummary;
      avatarUrl          = d['avatar_url']?.toString() ?? avatarUrl;

      if (d['semesterHistory'] != null) {
        final List<dynamic> historyRaw = d['semesterHistory'];
        semesters = historyRaw.map((e) => Map<String, String>.from(e as Map)).toList();
      }

      _rebuildDataModel();
    });

    // Pipeline 2: Listen to enrollments collection
    _enrollmentSubscription?.cancel();
    _enrollmentSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      joinedClasses = snapshot.docs.map((doc) {
        final d = doc.data();
        return JoinedClassModel(
          id:   doc.id,
          name: d['classId']?.toString() ?? 'Unknown Class',
        );
      }).toList();
      _rebuildDataModel();
    });
  }

  /// Fallback / compatibility alias
  Future<void> load() async => initLiveListeners();
  void loadMock()           => initLiveListeners();

  // ── Load subjects for a specific semester ─────────────────────────────────────
  Future<void> _loadSubjectsForSemester(String semId) async {
    if (_uid == null) return;
    try {
      final semDoc = await _db
          .collection('users')
          .doc(_uid)
          .collection('semesters')
          .doc(semId)
          .get();
      if (semDoc.exists) {
        subjects = (semDoc.data()?['subjects'] as List? ?? [])
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
        _rebuildDataModel();
        await _saveToCache();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('_loadSubjectsForSemester error: $e');
    }
  }

  // ── Save subjects ─────────────────────────────────────────────────────────────
  Future<void> saveSubjects(List<Map<String, String>> updated) async {
    subjects = updated;
    _rebuildDataModel();
    await _saveToCache();

    if (_uid != null && currentSemesterId != null) {
      try {
        await _db
            .collection('users')
            .doc(_uid)
            .collection('semesters')
            .doc(currentSemesterId)
            .update({'subjects': updated});

        for (final subject in updated) {
          final subjectName = subject['name'] ?? '';
          if (subjectName.isEmpty) continue;
          final safeClassId = subjectName
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
              .replaceAll(RegExp(r'[\s-]'), '_');
          final enrollmentId = '${_uid}_$safeClassId';

          await _db.collection('enrollments').doc(enrollmentId).set({
            'studentId':        _uid,
            'classId':          safeClassId,
            'semester':         currentSemesterId,
            'weeklyStudyHours': 0.0,
            'completedTasks':   0,
            'pendingTasks':     0,
            'burnoutIndex':     0.0,
            'tasksList':        [],
          }, SetOptions(merge: true));
        }

        semesters = semesters.map((s) {
          if (s['id'] == currentSemesterId) {
            return {...s, 'subjectCount': updated.length.toString()};
          }
          return s;
        }).toList();
      } catch (e) {
        debugPrint('saveSubjects error: $e');
      }
    }
    notifyListeners();
  }

  // ── Semesters CRUD ────────────────────────────────────────────────────────────
  Future<void> saveSemesters(List<Map<String, String>> updated) async {
    final newEntry = updated.last;
    final nameParts = (newEntry['name'] ?? '').split(' ');
    final semNum  = int.tryParse(nameParts.length > 1 ? nameParts[1] : '1') ?? 1;
    final semYear = int.tryParse(nameParts.length > 3 ? nameParts[3] : '1') ?? 1;
    final semId   = 'sem_${semNum}_yr$semYear';

    if (_uid != null) {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('semesters')
          .doc(semId)
          .set({
        'id':       semId,
        'semester': semNum,
        'year':     semYear,
        'semStart': newEntry['start'] ?? '',
        'semEnd':   newEntry['end']   ?? '',
        'examDates': [],
        'subjects':  [],
      });
    }

    semesters = [
      ...semesters,
      {
        'id':           semId,
        'name':         newEntry['name'] ?? 'Semester $semNum Year $semYear',
        'semesterKey':  semId,
        'start':        newEntry['start'] ?? '',
        'end':          newEntry['end']   ?? '',
        'isCurrent':    'false',
        'subjectCount': '0',
      },
    ];

    _rebuildDataModel();
    await _saveToCache();
    notifyListeners();
  }

  Future<void> editSemester(String oldName, Map<String, String> updated) async {
    final existing = semesters.firstWhere(
          (s) => s['name'] == oldName,
      orElse: () => {},
    );
    final semId = existing['id'] ?? existing['semesterKey'];

    semesters = semesters.map((s) {
      if (s['name'] == oldName) return {...s, ...updated};
      return s;
    }).toList();

    _rebuildDataModel();
    await _saveToCache();

    if (_uid != null && semId != null) {
      try {
        await _db
            .collection('users')
            .doc(_uid)
            .collection('semesters')
            .doc(semId)
            .update({
          'semStart': updated['start'] ?? '',
          'semEnd':   updated['end']   ?? '',
        });
      } catch (e) {
        debugPrint('editSemester error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> deleteSemester(String name) async {
    final existing = semesters.firstWhere(
          (s) => s['name'] == name,
      orElse: () => {},
    );
    final semId = existing['id'] ?? existing['semesterKey'];

    semesters = semesters.where((s) => s['name'] != name).toList();
    _rebuildDataModel();
    await _saveToCache();

    if (_uid != null && semId != null) {
      try {
        await _db
            .collection('users')
            .doc(_uid)
            .collection('semesters')
            .doc(semId)
            .delete();
      } catch (e) {
        debugPrint('deleteSemester error: $e');
      }
    }
    notifyListeners();
  }

  void selectSemester(String name, {TasksProvider? tasks, StudyPlanProvider? studyPlan}) {
    semesters = semesters.map((s) {
      return {...s, 'isCurrent': (s['name'] == name).toString()};
    }).toList();

    final selected = semesters.firstWhere(
          (s) => s['name'] == name,
      orElse: () => {},
    );
    final newSemId = selected['id'] ?? selected['semesterKey'];

    if (newSemId != null && newSemId != currentSemesterId) {
      currentSemesterId = newSemId;
      subjects = [];
      _tryFirestorePatch({'currentSemesterId': newSemId});
      _loadSubjectsForSemester(newSemId);
    }

    // Sync semester number/year fields
    currentLiveSemester = selected['semesterNum'] ?? currentLiveSemester;
    currentLiveYear     = int.tryParse(selected['yearNum'] ?? '') ?? currentLiveYear;

    tasks?.switchSemester(newSemId ?? name);
    studyPlan?.switchSemester(newSemId ?? name);

    _rebuildDataModel();
    _saveToCache();
    notifyListeners();
  }

  // ── Study hours & blocked slots ───────────────────────────────────────────────
  Future<void> saveStudyHours(TimeOfDay start, TimeOfDay end) async {
    studyStart = start;
    studyEnd   = end;
    _rebuildDataModel();
    await _saveToCache();
    _tryFirestorePatch({
      'study_hours_start': _formatTime(start),
      'study_hours_end':   _formatTime(end),
    });
    notifyListeners();
  }

  Future<void> saveBlockedSlots(Set<String> slots) async {
    blockedSlots = slots;
    _rebuildDataModel();
    await _saveToCache();
    _tryFirestorePatch({'blocked_slots': slots.toList()});
    notifyListeners();
  }

  // ── Notification toggles ──────────────────────────────────────────────────────
  Future<void> toggleTaskReminders() async {
    taskReminders = !taskReminders;
    _rebuildDataModel();
    await _persistToggle({'task_reminders': taskReminders});
  }

  Future<void> toggleSlotEndPrompts() async {
    slotEndPrompts = !slotEndPrompts;
    _rebuildDataModel();
    await _persistToggle({'slot_end_prompts': slotEndPrompts});
  }

  Future<void> toggleBurnoutWarnings() async {
    burnoutWarnings = !burnoutWarnings;
    _rebuildDataModel();
    await _persistToggle({'burnout_warnings': burnoutWarnings});
  }

  Future<void> toggleWeeklyResetSummary() async {
    weeklyResetSummary = !weeklyResetSummary;
    _rebuildDataModel();
    await _persistToggle({'weekly_reset_summary': weeklyResetSummary});
  }

  Future<void> _persistToggle(Map<String, dynamic> fields) async {
    await _saveToCache();
    _tryFirestorePatch(fields);
    notifyListeners();
  }

  // ── Join / leave class ────────────────────────────────────────────────────────
  Future<bool> joinClass(String code) async {
    if (_uid == null || code.trim().isEmpty) return false;
    try {
      final classQuery = await _db
          .collection('classes')
          .where('classCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (classQuery.docs.isEmpty) return false;

      final classDoc   = classQuery.docs.first;
      final classData  = classDoc.data();
      final className  = classData['name']?.toString()        ?? 'Unknown Class';
      final subjectCode = classData['subjectCode']?.toString() ?? classDoc.id.toUpperCase();

      final safeDocId = '${_uid}_${className.toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'[\s-]'), '_')}';

      final duplicate = await _db.collection('enrollments').doc(safeDocId).get();
      if (duplicate.exists) return true;

      await _db.collection('enrollments').doc(safeDocId).set({
        'studentId':      _uid,
        'classId':        className,
        'subjectCode':    subjectCode,
        'colorHex':       '#60A5FA',
        'completedTasks': 0,
        'pendingTasks':   0,
        'burnoutIndex':   0.0,
        'tasksList':      classData['initialTasks'] ?? [],
        'joinedAt':       FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('joinClass error: $e');
      return false;
    }
  }

  Future<void> leaveClass(String classId) async {
    if (_uid == null) return;
    try {
      await _db.collection('enrollments').doc(classId).delete();
    } catch (e) {
      debugPrint('leaveClass error: $e');
    }
    // The enrollment listener will automatically update joinedClasses
  }

  // ── User name & avatar ────────────────────────────────────────────────────────
  Future<void> updateUserName(String name) async {
    currentLiveName = name;
    _rebuildDataModel();
    await _storage.write(key: _keyUserName, value: name);
    if (_uid != null) {
      try {
        await _db.collection('users').doc(_uid).update({'name': name});
      } catch (e) {
        debugPrint('updateUserName error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> updateAvatar(XFile file) async {
    if (_uid == null) return;
    try {
      final ref = _fbStorage.ref().child('avatars/students/$_uid.jpg');
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      avatarUrl = url;
      _rebuildDataModel();
      await _storage.write(key: _keyAvatarUrl, value: url);
      _tryFirestorePatch({'avatar_url': url});
      notifyListeners();
    } catch (e) {
      setError('Failed to upload avatar');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _rebuildDataModel() {
    data = StudentSettingsModel(
      userId:             data?.userId ?? _uid?.hashCode.abs() ?? 0,
      userName:           currentLiveName,
      semester:           currentLiveSemester,
      year:               currentLiveYear,
      subjectCount:       subjects.length,
      studyHoursStart:    _formatTime(studyStart),
      studyHoursEnd:      _formatTime(studyEnd),
      blockedSlotsCount:  blockedSlots.length,
      taskReminders:      taskReminders,
      slotEndPrompts:     slotEndPrompts,
      burnoutWarnings:    burnoutWarnings,
      weeklyResetSummary: weeklyResetSummary,
      appVersion:         data?.appVersion ?? 'v1.0',
      joinedClassCount:   joinedClasses.length,
      joinedClasses:      joinedClasses,
      semesters: semesters.map((s) {
        final isCurrent = s['isCurrent'] == 'true';
        final count = isCurrent
            ? subjects.length
            : int.tryParse(s['subjectCount'] ?? '0') ?? 0;
        return SemesterModel(
          name:            s['name']  ?? '',
          start:           s['start'] ?? '',
          end:             s['end']   ?? '',
          isCurrent:       isCurrent,
          subjectCount:    count,
          studyHoursStart: _formatTime(studyStart),
          studyHoursEnd:   _formatTime(studyEnd),
        );
      }).toList(),
      avatarUrl: avatarUrl,
    );

    loading = false;
    notifyListeners();
  }

  void _tryFirestorePatch(Map<String, dynamic> fields) async {
    if (_uid == null) return;
    try {
      await _db.collection('users').doc(_uid).set(fields, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore patch failed: $e');
    }
  }

  Future<void> _loadFromCache() async {
    final start        = await _storage.read(key: _keyStudyStart);
    final end          = await _storage.read(key: _keyStudyEnd);
    final slots        = await _storage.read(key: _keyBlockedSlots);
    final subjRaw      = await _storage.read(key: _keySubjects);
    final semRaw       = await _storage.read(key: _keySemesters);
    final trRaw        = await _storage.read(key: _keyTaskReminders);
    final sepRaw       = await _storage.read(key: _keySlotEndPrompts);
    final bwRaw        = await _storage.read(key: _keyBurnoutWarnings);
    final wrsRaw       = await _storage.read(key: _keyWeeklyReset);
    final userIdRaw    = await _storage.read(key: _keyUserId);
    final userNameRaw  = await _storage.read(key: _keyUserName);
    final semesterRaw  = await _storage.read(key: _keySemester);
    final yearRaw      = await _storage.read(key: _keyYear);
    final subjCountRaw = await _storage.read(key: _keySubjectCount);
    final blockedCntRaw= await _storage.read(key: _keyBlockedCount);
    final appVersionRaw= await _storage.read(key: _keyAppVersion);
    final avatarRaw    = await _storage.read(key: _keyAvatarUrl);
    final classesRaw   = await _storage.read(key: _keyJoinedClasses);
    final currentSemRaw= await _storage.read(key: _keyCurrentSemId);

    if (avatarRaw    != null) avatarUrl          = avatarRaw;
    if (start        != null) studyStart         = _parseTimeString(start);
    if (end          != null) studyEnd           = _parseTimeString(end);
    if (slots        != null) blockedSlots       = Set<String>.from(jsonDecode(slots) as List);
    if (trRaw        != null) taskReminders      = trRaw  == 'true';
    if (sepRaw       != null) slotEndPrompts     = sepRaw == 'true';
    if (bwRaw        != null) burnoutWarnings    = bwRaw  == 'true';
    if (wrsRaw       != null) weeklyResetSummary = wrsRaw == 'true';
    if (currentSemRaw!= null) currentSemesterId  = currentSemRaw;

    currentLiveName     = userNameRaw ?? currentLiveName;
    currentLiveSemester = semesterRaw ?? currentLiveSemester;
    currentLiveYear     = int.tryParse(yearRaw ?? '') ?? currentLiveYear;

    if (subjRaw    != null) subjects      = (jsonDecode(subjRaw)    as List).map((e) => Map<String, String>.from(e as Map)).toList();
    if (semRaw     != null) semesters     = (jsonDecode(semRaw)     as List).map((e) => Map<String, String>.from(e as Map)).toList();
    if (classesRaw != null) joinedClasses = (jsonDecode(classesRaw) as List).map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>)).toList();

    if (userIdRaw != null || semesters.isNotEmpty) {
      data = StudentSettingsModel(
        userId:             int.tryParse(userIdRaw ?? '0') ?? 0,
        userName:           currentLiveName,
        semester:           currentLiveSemester,
        year:               currentLiveYear,
        subjectCount:       int.tryParse(subjCountRaw   ?? '0') ?? 0,
        studyHoursStart:    _formatTime(studyStart),
        studyHoursEnd:      _formatTime(studyEnd),
        blockedSlotsCount:  int.tryParse(blockedCntRaw  ?? '0') ?? 0,
        taskReminders:      taskReminders,
        slotEndPrompts:     slotEndPrompts,
        burnoutWarnings:    burnoutWarnings,
        weeklyResetSummary: weeklyResetSummary,
        appVersion:         appVersionRaw ?? 'v1.0',
        joinedClassCount:   joinedClasses.length,
        joinedClasses:      joinedClasses,
        semesters: semesters.map((s) => SemesterModel(
          name:            s['name']  ?? '',
          start:           s['start'] ?? '',
          end:             s['end']   ?? '',
          isCurrent:       s['isCurrent'] == 'true',
          subjectCount:    int.tryParse(s['subjectCount'] ?? '0') ?? 0,
          studyHoursStart: _formatTime(studyStart),
          studyHoursEnd:   _formatTime(studyEnd),
        )).toList(),
      );
    }
  }

  Future<void> _saveToCache() async {
    await _storage.write(key: _keyStudyStart,     value: _formatTime(studyStart));
    await _storage.write(key: _keyStudyEnd,       value: _formatTime(studyEnd));
    await _storage.write(key: _keyBlockedSlots,   value: jsonEncode(blockedSlots.toList()));
    await _storage.write(key: _keySubjects,       value: jsonEncode(subjects));
    await _storage.write(key: _keySemesters,      value: jsonEncode(semesters));
    await _storage.write(key: _keyTaskReminders,  value: taskReminders.toString());
    await _storage.write(key: _keySlotEndPrompts, value: slotEndPrompts.toString());
    await _storage.write(key: _keyBurnoutWarnings,value: burnoutWarnings.toString());
    await _storage.write(key: _keyWeeklyReset,    value: weeklyResetSummary.toString());
    await _storage.write(key: _keyJoinedClasses,  value: jsonEncode(
      joinedClasses.map((c) => {'id': c.id, 'name': c.name}).toList(),
    ));
    if (currentSemesterId != null) {
      await _storage.write(key: _keyCurrentSemId, value: currentSemesterId!);
    }
    if (data != null) {
      await _storage.write(key: _keyUserId,       value: data!.userId.toString());
      await _storage.write(key: _keyUserName,     value: currentLiveName);
      await _storage.write(key: _keySemester,     value: currentLiveSemester);
      await _storage.write(key: _keyYear,         value: currentLiveYear.toString());
      await _storage.write(key: _keySubjectCount, value: subjectCount.toString());
      await _storage.write(key: _keyBlockedCount, value: blockedSlotsCount.toString());
      await _storage.write(key: _keyAppVersion,   value: data!.appVersion);
      if (avatarUrl != null) await _storage.write(key: _keyAvatarUrl, value: avatarUrl!);
    }
  }

  // ── Misc public methods ───────────────────────────────────────────────────────
  void setData(StudentSettingsModel model) {
    data               = model;
    studyStart         = _parseTimeString(model.studyHoursStart);
    studyEnd           = _parseTimeString(model.studyHoursEnd);
    taskReminders      = model.taskReminders;
    slotEndPrompts     = model.slotEndPrompts;
    burnoutWarnings    = model.burnoutWarnings;
    weeklyResetSummary = model.weeklyResetSummary;
    currentLiveName    = model.userName;
    currentLiveSemester= model.semester;
    currentLiveYear    = model.year;
    blockedSlots       = Set.from(model.blockedSlots);
    semesters = model.semesters.map((s) => {
      'name':         s.name,
      'isCurrent':    s.isCurrent.toString(),
      'subjectCount': s.subjectCount.toString(),
    }).toList();
    avatarUrl = model.avatarUrl;
    notifyListeners();
  }

  void clearCache() async {
    await _storage.deleteAll();
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

  void clear() {
    data               = null;
    currentSemesterId  = null;
    clearCache();
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

  // ── Time helpers ──────────────────────────────────────────────────────────────
  TimeOfDay _parseTimeString(String s) {
    s = s.trim();
    if (s.contains(':')) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final isPm = s.toUpperCase().contains('PM');
    final isAm = s.toUpperCase().contains('AM');
    final val  = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
    if (isPm && val < 12) return TimeOfDay(hour: val + 12, minute: 0);
    if (isAm && val == 12) return const TimeOfDay(hour: 0, minute: 0);
    return TimeOfDay(hour: val, minute: 0);
  }

  String _formatTime(TimeOfDay t) {
    final hour   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = t.minute == 0 ? '' : ':${t.minute.toString().padLeft(2, '0')}';
    return '$hour$minute $period';
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _enrollmentSubscription?.cancel();
    super.dispose();
  }
}