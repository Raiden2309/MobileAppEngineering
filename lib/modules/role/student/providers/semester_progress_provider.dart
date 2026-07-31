import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/semester_progress_model.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';
import 'student_settings_provider.dart';

class SemesterProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  SemesterProvider({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Centralized cache link
  LocalCacheService? _cacheEngine;

  void updateCacheEngine(LocalCacheService engine) {
    _cacheEngine = engine;
  }

  VoidCallback? _subjectsRefreshHook;

  void registerSubjectsRefreshHook(StudentSettingsProvider settings) {
    _subjectsRefreshHook ??= reloadSubjectsFromCache;
    settings.addSubjectUpdatedListener(_subjectsRefreshHook!);
  }

  SemesterProgressModel? data;
  bool loading = false;
  bool isOffline = false;
  String? error;
  StreamSubscription? _progressSubscription;

  String? _currentSemesterId;
  String _semesterName = '';
  String _dateRange = '';
  DateTime? _semStart;
  DateTime? _semEnd;
  String? get currentSemesterId => _currentSemesterId;
  DateTime? get semStart => _semStart;
  DateTime? get semEnd => _semEnd;

  String get semesterLabel {
    final parts = <String>[];
    if (_semesterName.isNotEmpty) parts.add(_semesterName);
    if (_dateRange.isNotEmpty) parts.add(_dateRange);
    return parts.join(' · ');
  }

  String _cacheKey(String uid) => 'semester_progress_cache_$uid';

  Future<void> _saveToCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || data == null) return;
    try {
      final payload = {
        'semesterName': data!.semesterName,
        'dateRange': data!.dateRange,
        'overallProgress': data!.overallProgress,
        'completedTasks': data!.completedTasks,
        'totalTasks': data!.totalTasks,
        'currentWeek': data!.currentWeek,
        'totalWeeks': data!.totalWeeks,
        'timelineProgress': data!.timelineProgress,
        'weeksRemaining': data!.weeksRemaining,
        'finalExamDate': data!.finalExamDate,
        'subjects': data!.subjects
            .map(
              (s) => {
                'name': s.name,
                'code': s.code,
                'progress': s.progress,
                'completed': s.completed,
                'remaining': s.remaining,
                'dueSoon': s.dueSoon,
              },
            )
            .toList(),
      };
      await _cacheEngine?.write(_cacheKey(uid), payload);
    } catch (e) {
      debugPrint('Semester write cache error: $e');
    }
  }

  Future<bool> _loadFromCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final decoded = await _cacheEngine?.read(_cacheKey(uid));

      if (decoded != null) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
        final List<dynamic> subsRaw = map['subjects'] ?? [];

        data = SemesterProgressModel(
          semesterName: map['semesterName'] ?? '',
          dateRange: map['dateRange'] ?? '',
          overallProgress: (map['overallProgress'] as num? ?? 0.0).toDouble(),
          completedTasks: (map['completedTasks'] as num? ?? 0).toInt(),
          totalTasks: (map['totalTasks'] as num? ?? 0).toInt(),
          currentWeek: (map['currentWeek'] as num? ?? 1).toInt(),
          totalWeeks: (map['totalWeeks'] as num? ?? 14).toInt(),
          timelineProgress: (map['timelineProgress'] as num? ?? 0.0).toDouble(),
          weeksRemaining: (map['weeksRemaining'] as num? ?? 0).toInt(),
          finalExamDate: map['finalExamDate'] ?? 'Not Set',
          subjects: subsRaw
              .map(
                (s) => SubjectProgress(
                  name: s['name'] ?? '',
                  code: s['code'] ?? '',
                  progress: (s['progress'] as num? ?? 0.0).toDouble(),
                  completed: (s['completed'] as num? ?? 0).toInt(),
                  remaining: (s['remaining'] as num? ?? 0).toInt(),
                  dueSoon: (s['dueSoon'] as num? ?? 0).toInt(),
                ),
              )
              .toList(),
        );
        return true;
      }

      // No semester cache — fall back to subjects from settings cache
      final subjRaw = await _cacheEngine?.read('settings_subjects');
      if (subjRaw is List && subjRaw.isNotEmpty) {
        data = SemesterProgressModel(
          semesterName: _semesterName,
          dateRange: _dateRange,
          overallProgress: 0.0,
          completedTasks: 0,
          totalTasks: 0,
          currentWeek: _currentWeek(),
          totalWeeks: _totalWeeks(),
          timelineProgress: _timelineProgress(),
          weeksRemaining: _weeksRemaining(),
          finalExamDate: 'Not Set',
          subjects: subjRaw
              .map(
                (s) => SubjectProgress(
                  name: s['name'] ?? '',
                  code: s['code'] ?? '',
                  progress: 0.0,
                  completed: 0,
                  remaining: 0,
                  dueSoon: 0,
                ),
              )
              .toList(),
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Semester read cache error: $e');
      return false;
    }
  }

  void listenToLiveProgress() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentSemesterId == null) return;

    loading = true;
    notifyListeners();

    _loadFromCache().then((hasCached) {
      if (hasCached) {
        loading = false;
        notifyListeners();
      }
    });

    _progressSubscription?.cancel();
    _progressSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .where('semester', isEqualTo: _currentSemesterId)
        .snapshots()
        .listen(
          (snapshot) {
            int aggregatedCompleted = 0;
            int aggregatedTotal = 0;

            final List<SubjectProgress> calculatedSubjects = snapshot.docs.map((
              doc,
            ) {
              final item = doc.data();
              final int comp = (item['completedTasks'] as num? ?? 0).toInt();
              final int pend = (item['pendingTasks'] as num? ?? 0).toInt();
              final int tot = comp + pend;

              aggregatedCompleted += comp;
              aggregatedTotal += tot;

              final List<dynamic> tasksList = item['tasksList'] ?? [];
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              int dueSoon = 0;
              for (final t in tasksList) {
                final status = t['status']?.toString() ?? '';
                if (status == 'completed') continue;
                final dueDateRaw = t['due_date']?.toString() ?? '';
                if (dueDateRaw.isEmpty) continue;
                final dueDate = DateTime.tryParse(dueDateRaw);
                if (dueDate == null) continue;
                final taskDay = DateTime(
                  dueDate.year,
                  dueDate.month,
                  dueDate.day,
                );
                final diff = taskDay.difference(today).inDays;
                if (diff < 0) dueSoon++;
              }

              return SubjectProgress(
                name: item['classId'] ?? item['name'] ?? 'Unknown Subject',
                code: item['subjectCode'] ?? '',
                progress: tot > 0 ? (comp / tot) : 0.0,
                completed: comp,
                remaining: pend,
                dueSoon: dueSoon,
              );
            }).toList();

            data = SemesterProgressModel(
              semesterName: _semesterName,
              dateRange: _dateRange,
              overallProgress: aggregatedTotal > 0
                  ? (aggregatedCompleted / aggregatedTotal)
                  : 0.0,
              completedTasks: aggregatedCompleted,
              totalTasks: aggregatedTotal,
              currentWeek: _currentWeek(),
              totalWeeks: _totalWeeks(),
              timelineProgress: _timelineProgress(),
              weeksRemaining: _weeksRemaining(),
              finalExamDate: _finalExamDate(),
              subjects: calculatedSubjects,
            );

            loading = false;
            isOffline = false;
            _saveToCache();
            notifyListeners();
          },
          onError: (e) {
            error = e.toString();
            loading = false;
            _loadFromCache().then((hasCached) {
              isOffline = hasCached;
              notifyListeners();
            });
          },
        );
  }

  void switchSemester({
    required String semesterId,
    required String semesterName,
    required String start,
    required String end,
  }) {
    _currentSemesterId = semesterId;
    _semesterName = semesterName;

    _semStart = DateTime.tryParse(start);
    _semEnd = DateTime.tryParse(end);

    // Format the clean date string natively
    if (_semStart != null && _semEnd != null) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      String startStr =
          "${_semStart!.day} ${months[_semStart!.month - 1]} ${_semStart!.year}";
      String endStr =
          "${_semEnd!.day} ${months[_semEnd!.month - 1]} ${_semEnd!.year}";

      _dateRange = '$startStr – $endStr';
    } else {
      _dateRange = '';
    }

    listenToLiveProgress();
  }

  Future<void> reloadSubjectsFromCache() async {
    final subjRaw = await _cacheEngine?.read('settings_subjects');
    if (subjRaw is List && subjRaw.isNotEmpty) {
      final List<Map<String, String>> updatedList =
          List<Map<String, String>>.from(
            subjRaw.map(
              (s) => {
                'name': (s['name'] ?? '').toString(),
                'code': (s['code'] ?? '').toString(),
              },
            ),
          );
      // Use your existing merger logic to force an instant state rebuild offline
      updateSubjectsAuthoritativeList(updatedList);
    }
  }

  void updateSubjectsAuthoritativeList(
    List<Map<String, String>> updatedSubjects,
  ) {
    final existing = data?.subjects ?? [];
    final existingByName = {for (final s in existing) s.name: s};

    final merged = updatedSubjects.map((s) {
      final name = s['name'] ?? 'Unknown';
      return existingByName[name] ??
          SubjectProgress(
            name: name,
            code: s['code'] ?? '',
            progress: 0.0,
            completed: 0,
            remaining: 0,
            dueSoon: 0,
          );
    }).toList();

    data = SemesterProgressModel(
      semesterName: data?.semesterName ?? _semesterName,
      dateRange: data?.dateRange ?? _dateRange,
      overallProgress: data?.overallProgress ?? 0.0,
      completedTasks: data?.completedTasks ?? 0,
      totalTasks: data?.totalTasks ?? 0,
      currentWeek: data?.currentWeek ?? _currentWeek(),
      totalWeeks: data?.totalWeeks ?? _totalWeeks(),
      timelineProgress: data?.timelineProgress ?? _timelineProgress(),
      weeksRemaining: data?.weeksRemaining ?? _weeksRemaining(),
      finalExamDate: data?.finalExamDate ?? _finalExamDate(),
      subjects: merged,
    );

    _saveToCache();
    notifyListeners();
  }

  int _currentWeek() {
    if (_semStart == null) return 1;
    final diff = DateTime.now().difference(_semStart!).inDays;
    if (diff < 0) return 1;
    final wk = (diff / 7).boldCast() + 1;
    return wk > _totalWeeks() ? _totalWeeks() : wk;
  }

  int _totalWeeks() {
    if (_semStart == null || _semEnd == null) return 14;
    final diff = _semEnd!.difference(_semStart!).inDays;
    return (diff / 7).ceil().clamp(1, 24);
  }

  double _timelineProgress() {
    if (_semStart == null || _semEnd == null) return 0.0;
    final total = _semEnd!.difference(_semStart!).inSeconds;
    final current = DateTime.now().difference(_semStart!).inSeconds;
    if (total <= 0) return 0.0;
    return (current / total).clamp(0.0, 1.0);
  }

  int _weeksRemaining() {
    final rem = _totalWeeks() - _currentWeek();
    return rem < 0 ? 0 : rem;
  }

  String _finalExamDate() => 'Not Set';

  void reset() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
    data = null;
    loading = false;
    isOffline = false;
    error = null;
    _currentSemesterId = null;
    _semesterName = '';
    _dateRange = '';
    _semStart = null;
    _semEnd = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}

extension on double {
  int boldCast() => floor();
}
