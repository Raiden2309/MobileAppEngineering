import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // REQUIRED for real-time StreamSubscription tracking
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

  static const _keyBlockedSlotsCount = 'settings_blocked_slots_count';
  static const _keyAppVersion = 'settings_app_version';
  static const _keyAvatarUrl = 'settings_avatar_url';
  static const _keyJoinedClasses = 'settings_joined_classes';

  StudentSettingsModel? data;
  bool loading = false;
  String? error;

  TimeOfDay studyStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay studyEnd = const TimeOfDay(hour: 22, minute: 0);
  Set<String> blockedSlots = {};
  List<Map<String, String>> subjects = [];
  List<Map<String, String>> semesters = [];
  List<JoinedClassModel> joinedClasses = [];

  bool taskReminders = true;
  bool slotEndPrompts = true;
  bool burnoutWarnings = true;
  bool weeklyResetSummary = false;

  String currentLiveName = '';
  String currentLiveSemester = '1';
  int currentLiveYear = 1;
  String? avatarUrl;

  // Real-time listener pipelines to ensure seamless cross-view synchronizations
  StreamSubscription? _userSubscription;
  StreamSubscription? _enrollmentSubscription;

  StudentSettingsProvider() {
    initLiveListeners();
  }

  /// INITIALIZES REAL-TIME PIPELINES: Listens to live database changes automatically
  void initLiveListeners() async {
    final user = _auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    // Load foundational local layout preferences from secure cache storage row indexes
    await _loadFromCache();

    // Pipeline 1: Listen to user meta-profile metrics dynamically
    _userSubscription?.cancel();
    _userSubscription = _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((userSnapshot) {

      if (userSnapshot.exists && userSnapshot.data() != null) {
        final userData = userSnapshot.data()!;
        currentLiveName = userData['name']?.toString() ?? user.displayName ?? 'Student';
        currentLiveSemester = userData['semester']?.toString() ?? currentLiveSemester;
        currentLiveYear = int.tryParse(userData['year']?.toString() ?? '') ?? currentLiveYear;

        if (userData['semesterHistory'] != null) {
          final List<dynamic> historyRaw = userData['semesterHistory'];
          semesters = historyRaw.map((e) => Map<String, String>.from(e as Map)).toList();
        }
        _rebuildSettingsModel(user.uid);
      }
    });

    // Pipeline 2: Listen directly to the enrollments collection for instant subject card updates
    _enrollmentSubscription?.cancel();
    _enrollmentSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: user.uid)
        .snapshots()
        .listen((enrollmentSnapshot) {

      joinedClasses = enrollmentSnapshot.docs.map((doc) {
        final docMap = doc.data();
        return JoinedClassModel(
          id: doc.id,
          name: docMap['classId']?.toString() ?? 'Unknown Class',
        );
      }).toList();

      _rebuildSettingsModel(user.uid);
    });
  }

  /// Rebuilds the operational configuration tracking model with true reactive parameters
  void _rebuildSettingsModel(String uid) {
    data = StudentSettingsModel(
      userId: uid.hashCode.abs(),
      userName: currentLiveName,
      semester: currentLiveSemester,
      year: currentLiveYear,
      subjectCount: joinedClasses.length, // Synchronized in real time
      studyHoursStart: _formatTime(studyStart),
      studyHoursEnd: _formatTime(studyEnd),
      blockedSlotsCount: blockedSlots.length,
      taskReminders: taskReminders,
      slotEndPrompts: slotEndPrompts,
      burnoutWarnings: burnoutWarnings,
      weeklyResetSummary: weeklyResetSummary,
      appVersion: 'v1.0',
      joinedClassCount: joinedClasses.length, // Synchronized in real time
      joinedClasses: joinedClasses,
      semesters: semesters.map((s) => SemesterModel(
        name: s['name'] ?? 'Semester 1',
        isCurrent: s['isCurrent'] == 'true',
        subjectCount: int.tryParse(s['subjectCount'] ?? '0') ?? 0,
        studyHoursStart: s['studyHoursStart'] ?? '8 AM',
        studyHoursEnd: s['studyHoursEnd'] ?? '10 PM',
      )).toList(),
      subjects: const [],
    );

    loading = false;
    notifyListeners(); // Forces UI view state matrices to instantly re-render
  }

  /// Fallback compatibility legacy bridge layer
  Future<void> load() async {
    initLiveListeners();
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
    final avatarRaw = await _storage.read(key: _keyAvatarUrl);

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

    if (trRaw != null) taskReminders = trRaw == 'true';
    if (sepRaw != null) slotEndPrompts = sepRaw == 'true';
    if (bwRaw != null) burnoutWarnings = bwRaw == 'true';
    if (wrsRaw != null) weeklyResetSummary = wrsRaw == 'true';
  }

  void loadMock() {
    initLiveListeners();
  }

  Future<void> toggleTaskReminders() async {
    taskReminders = !taskReminders;
    await _storage.write(key: _keyTaskReminders, value: taskReminders.toString());
    _tryApiPatch({'taskReminders': taskReminders});
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> toggleSlotEndPrompts() async {
    slotEndPrompts = !slotEndPrompts;
    await _storage.write(key: _keySlotEndPrompts, value: slotEndPrompts.toString());
    _tryApiPatch({'slotEndPrompts': slotEndPrompts});
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> toggleBurnoutWarnings() async {
    burnoutWarnings = !burnoutWarnings;
    await _storage.write(key: _keyBurnoutWarnings, value: burnoutWarnings.toString());
    _tryApiPatch({'burnoutWarnings': burnoutWarnings});
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> toggleWeeklyResetSummary() async {
    weeklyResetSummary = !weeklyResetSummary;
    await _storage.write(key: _keyWeeklyReset, value: weeklyResetSummary.toString());
    _tryApiPatch({'weeklyResetSummary': weeklyResetSummary});
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> saveStudyHours(TimeOfDay start, TimeOfDay end) async {
    studyStart = start;
    studyEnd = end;
    await _storage.write(key: _keyStudyStart, value: '${start.hour}:${start.minute}');
    await _storage.write(key: _keyStudyEnd, value: '${end.hour}:${end.minute}');
    _tryApiPatch({
      'studyHoursStart': _formatTime(start),
      'studyHoursEnd': _formatTime(end),
    });
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> saveBlockedSlots(Set<String> slots) async {
    blockedSlots = slots;
    await _storage.write(key: _keyBlockedSlots, value: jsonEncode(slots.toList()));
    await _storage.write(key: _keyBlockedSlotsCount, value: slots.length.toString());
    _tryApiPatch({'blockedSlotsCount': slots.length});
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> saveSubjects(List<Map<String, String>> updated) async {
    subjects = updated;
    await _storage.write(key: _keySubjects, value: jsonEncode(updated));
    await _storage.write(key: _keySubjectCount, value: updated.length.toString());
    _tryApiPatch({'subjectCount': updated.length});
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  Future<void> saveSemesters(List<Map<String, String>> updated) async {
    semesters = updated;
    await _storage.write(key: _keySemesters, value: jsonEncode(updated));

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _db.collection('users').doc(user.uid).update({
          'semesterHistory': updated,
        });
      } catch (e) {
        debugPrint("Failed to sync semester list: $e");
      }
    }
  }

  void selectSemester(String name) async {
    for (var s in semesters) {
      s['isCurrent'] = (s['name'] == name).toString();
    }
    await _storage.write(key: _keySemesters, value: jsonEncode(semesters));

    final matching = semesters.firstWhere((s) => s['name'] == name, orElse: () => {});
    if (matching.isNotEmpty) {
      currentLiveSemester = matching['semesterNum'] ?? '1';
      currentLiveYear = int.tryParse(matching['yearNum'] ?? '1') ?? 1;

      await _storage.write(key: _keySemester, value: currentLiveSemester);
      await _storage.write(key: _keyYear, value: currentLiveYear.toString());

      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _db.collection('users').doc(user.uid).update({
            'semester': currentLiveSemester,
            'year': currentLiveYear,
            'semesterHistory': semesters,
          });
        } catch (e) {
          debugPrint("Failed to sync selected semester switch inside Firestore: $e");
        }
      }

      _tryApiPatch({
        'semester': currentLiveSemester,
        'year': currentLiveYear,
      });
    }
  }

  Future<void> updateUserName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({'name': name});
    }
  }

  Future<void> updateAvatar(XFile file) async {
    avatarUrl = file.path;
    await _storage.write(key: _keyAvatarUrl, value: file.path);
    final uid = _auth.currentUser?.uid;
    if (uid != null) _rebuildSettingsModel(uid);
  }

  /// FIXED: Validates a class code against the database and creates a real-time student enrollment block
  Future<bool> joinClass(String code) async {
    final user = _auth.currentUser;
    if (user == null || code.trim().isEmpty) return false;

    try {
      // Search across the database to find the master class tracking record matching the entry code
      final classQuery = await _db
          .collection('classes')
          .where('classCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (classQuery.docs.isEmpty) {
        debugPrint("Validation broken: No master class records discovered matching code: $code");
        return false;
      }

      final classDoc = classQuery.docs.first;
      final classData = classDoc.data();
      final String className = classData['name']?.toString() ?? 'Unknown Class';
      final String subjectCode = classData['subjectCode']?.toString() ?? classDoc.id.toUpperCase();

      // Prevent duplicate enrollments by checking if the user is already joined
      final safeDocId = '${user.uid}_${className.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').replaceAll(RegExp(r'[\s-]'), '_')}';
      final duplicateCheck = await _db.collection('enrollments').doc(safeDocId).get();

      if (duplicateCheck.exists) {
        debugPrint("Enrollment aborted: Student is already registered inside this class path container.");
        return true;
      }

      // Generate a new real-time tracking document inside the enrollments collection
      await _db.collection('enrollments').doc(safeDocId).set({
        'studentId': user.uid,
        'classId': className,
        'subjectCode': subjectCode,
        'colorHex': '#60A5FA',
        'completedTasks': 0,
        'pendingTasks': 0,
        'burnoutIndex': 0.0,
        'tasksList': classData['initialTasks'] ?? [], // Inherits master template tasks from lecturer
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Forward event records to backend API compatibility layer if necessary
      try {
        await ApiService.post('/student/class/join', {'code': code.trim().toUpperCase()});
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint("Failed to process live enrollment mapping transaction: $e");
      return false;
    }
  }

  Future<void> leaveClass(String classId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Find and remove enrollment mapping securely from Firestore
      await _db.collection('enrollments').doc(classId).delete();
      _tryApiDelete('/student/class/leave/$classId');
    } catch (e) {
      debugPrint("Failed to delete enrollment item from remote cluster: $e");
    }
  }

  void clearCache() async {
    await _storage.deleteAll();
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
    final val = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
    if (isPm && val < 12) return TimeOfDay(hour: val + 12, minute: 0);
    if (isAm && val == 12) return const TimeOfDay(hour: 0, minute: 0);
    return TimeOfDay(hour: val, minute: 0);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
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