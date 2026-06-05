import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/student_settings_provider.dart';
import '../models/app_enums.dart';
import '../models/study_plan_model.dart';
import '../../../../shared/services/ai_service.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';

import 'burnout_alert_provider.dart';

class StudyPlanProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  StudyPlanProvider({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  StudentSettingsProvider? _settingsProvider;
  BurnoutAlertProvider? _burnoutProvider;

  void updateSettingsProvider(StudentSettingsProvider p) => _settingsProvider = p;
  void updateBurnoutProvider(BurnoutAlertProvider p)    => _burnoutProvider  = p;

  LocalCacheService? _cacheEngine;

  void _generateLocalFastPlan() {
    final now = DateTime.now();
    final DateTime todayMidnight = DateTime(now.year, now.month, now.day);
    final DateTime mondayOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    // ── 1. Read real settings instead of hardcoded values ──────────
    final settings = _settingsProvider;
    final burnout  = _burnoutProvider;

    final int studyStartMins = settings != null
        ? settings.studyStart.hour * 60 + settings.studyStart.minute
        : 9 * 60; // fallback 09:00

    final int studyEndMins = settings != null
        ? settings.studyEnd.hour * 60 + settings.studyEnd.minute
        : 22 * 60; // fallback 22:00

    final int availableWindowMins = (studyEndMins - studyStartMins).clamp(0, 14 * 60);

    final String burnoutLevel = burnout?.alert?.workloadLevel.name ?? 'low';

    // Burnout-aware daily cap (never exceeds available window)
    final int burnoutCapMinutes = switch (burnoutLevel) {
      'critical' => 120,
      'high'     => 180,
      'moderate' => 240,
      _          => 360, // low
    };

    final int dailyCapMinutes = burnoutCapMinutes.clamp(0, availableWindowMins);

    final Map<int, int> dayBudgetMinutes = {
      for (int i = 0; i < 7; i++) i: dailyCapMinutes,
    };

    final Map<int, int> dayUsedMinutes  = {for (int i = 0; i < 7; i++) i: 0};
    final Map<int, int> dayNextStart    = {for (int i = 0; i < 7; i++) i: studyStartMins};
    final Map<int, List<StudyBlock>> dayBlocks = {for (int i = 0; i < 7; i++) i: []};

    // ── Helper ──────────────────────────────────────────────────────
    String minsToTime(int totalMins) {
      final h = totalMins ~/ 60;
      final m = totalMins % 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }

    // ── 2. Pre-fill blocked slots ───────────────────────────────────
    // Expected format from settings: "Monday 09:00-11:00"
    final List<String> blockedSlots = settings?.blockedSlots.toList() ?? [];
    const List<String> _dayNames = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    ];

    for (final slot in blockedSlots) {
      final parts = slot.trim().split(' ');
      if (parts.length < 2) continue;
      final int dayIdx = _dayNames.indexOf(parts[0].toLowerCase());
      if (dayIdx == -1) continue;

      final times = parts[1].split('-');
      if (times.length < 2) continue;

      final startParts = times[0].split(':');
      final endParts   = times[1].split(':');
      if (startParts.length < 2 || endParts.length < 2) continue;

      final int slotStart = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final int slotEnd   = int.parse(endParts[0])   * 60 + int.parse(endParts[1]);
      final int slotMins  = slotEnd - slotStart;
      if (slotMins <= 0) continue;

      dayBlocks[dayIdx]!.add(StudyBlock(
        startTime:       minsToTime(slotStart),
        title:           'Blocked',
        durationMinutes: slotMins,
        type:            BlockType.blocked,
        status:          BlockStatus.none,
      ));

      // Push the day's next-start pointer past this slot if needed
      if (dayNextStart[dayIdx]! < slotEnd) {
        dayNextStart[dayIdx] = slotEnd;
      }
    }

    // ── 3. Sort and schedule tasks ──────────────────────────────────
    final sortedTasks = List<Map<String, dynamic>>.from(_latestFirestoreTasks)
      ..sort((a, b) {
        if (a['status'] == BlockStatus.inProgress && b['status'] != BlockStatus.inProgress) return -1;
        if (b['status'] == BlockStatus.inProgress && a['status'] != BlockStatus.inProgress) return 1;
        final DateTime? aDue = a['dueDate'];
        final DateTime? bDue = b['dueDate'];
        if (aDue != null && bDue != null) return aDue.compareTo(bDue);
        if (aDue != null) return -1;
        if (bDue != null) return 1;
        return (b['hours'] as double).compareTo(a['hours'] as double);
      });

    const int maxSessionMinutes = 90;
    const int minSessionMinutes = 30;
    const int breakMinutes      = 15;

    for (final task in sortedTasks) {
      final double totalHours = task['hours'] as double;
      int remainingMinutes = (totalHours * 60).round();
      final DateTime? dueDate = task['dueDate'];

      final List<int> eligibleDayIndexes = [];
      for (int i = 0; i < 7; i++) {
        final dayDate     = mondayOfThisWeek.add(Duration(days: i));
        final dayMidnight = DateTime(dayDate.year, dayDate.month, dayDate.day);
        if (dayMidnight.isBefore(todayMidnight)) continue;
        if (dueDate != null) {
          final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
          if (dayMidnight.isAfter(dueMidnight)) continue;
        }
        eligibleDayIndexes.add(i);
      }

      if (eligibleDayIndexes.isEmpty) continue;

      int dayCursor = 0;
      while (remainingMinutes >= minSessionMinutes && dayCursor < eligibleDayIndexes.length) {
        final int dayIdx    = eligibleDayIndexes[dayCursor];
        final int budgetLeft = dayBudgetMinutes[dayIdx]! - dayUsedMinutes[dayIdx]!;

        if (budgetLeft >= minSessionMinutes) {
          final int sessionMins =
          [remainingMinutes, maxSessionMinutes, budgetLeft].reduce((a, b) => a < b ? a : b);

          final int startMin = dayNextStart[dayIdx]!;
          dayBlocks[dayIdx]!.add(StudyBlock(
            startTime:       minsToTime(startMin),
            title:           task['title'],
            subject:         task['subject'],
            durationMinutes: sessionMins,
            type:            BlockType.study,
            status:          task['status'],
          ));

          dayUsedMinutes[dayIdx] = dayUsedMinutes[dayIdx]! + sessionMins;
          dayNextStart[dayIdx]   = startMin + sessionMins;
          remainingMinutes      -= sessionMins;

          final int budgetAfter = dayBudgetMinutes[dayIdx]! - dayUsedMinutes[dayIdx]!;
          if (budgetAfter >= breakMinutes && remainingMinutes > 0) {
            final int breakStart = dayNextStart[dayIdx]!;
            dayBlocks[dayIdx]!.add(StudyBlock(
              startTime:       minsToTime(breakStart),
              title:           'Short Break',
              durationMinutes: breakMinutes,
              type:            BlockType.breakSlot,
              status:          BlockStatus.none,
            ));
            dayUsedMinutes[dayIdx] = dayUsedMinutes[dayIdx]! + breakMinutes;
            dayNextStart[dayIdx]   = breakStart + breakMinutes;
          }
        }

        dayCursor++;
        if (dayCursor >= eligibleDayIndexes.length && remainingMinutes >= minSessionMinutes) {
          dayCursor = 0;
          final anyBudget = eligibleDayIndexes.any(
                (idx) => (dayBudgetMinutes[idx]! - dayUsedMinutes[idx]!) >= minSessionMinutes,
          );
          if (!anyBudget) break;
        }
      }
    }

    // ── 4. Fill remaining slots with subject revision ───────────────
    final List<String> subjects = [
      ...?settings?.joinedClasses.map((c) => c.name),
      ...?settings?.subjects.map((s) => s['name'] ?? '').where((n) => n.isNotEmpty),
    ].toSet().toList();

    if (subjects.isNotEmpty) {
      int subjectCursor = 0;

      for (int i = 0; i < 7; i++) {
        final dayDate     = mondayOfThisWeek.add(Duration(days: i));
        final dayMidnight = DateTime(dayDate.year, dayDate.month, dayDate.day);
        if (dayMidnight.isBefore(todayMidnight)) continue;

        // Track subjects already scheduled today to avoid repeats
        final usedSubjects = dayBlocks[i]!
            .where((b) => b.type == BlockType.study)
            .map((b) => b.subject)
            .toSet();

        while (true) {
          final int budgetLeft = dayBudgetMinutes[i]! - dayUsedMinutes[i]!;
          if (budgetLeft < minSessionMinutes) break;

          // Pick next subject not already used today
          String? subject;
          for (int s = 0; s < subjects.length; s++) {
            final candidate = subjects[(subjectCursor + s) % subjects.length];
            if (!usedSubjects.contains(candidate)) {
              subject       = candidate;
              subjectCursor = (subjectCursor + s + 1) % subjects.length;
              break;
            }
          }
          if (subject == null) break; // all subjects used today

          final int sessionMins = budgetLeft.clamp(minSessionMinutes, maxSessionMinutes);
          final int startMin    = dayNextStart[i]!;

          dayBlocks[i]!.add(StudyBlock(
            startTime:       minsToTime(startMin),
            title:           'Revise $subject',
            subject:         subject,
            durationMinutes: sessionMins,
            type:            BlockType.study,
            status:          BlockStatus.toDo,
          ));
          usedSubjects.add(subject);
          dayUsedMinutes[i] = dayUsedMinutes[i]! + sessionMins;
          dayNextStart[i]   = startMin + sessionMins;

          // Add break if room
          final int budgetAfterRevision = dayBudgetMinutes[i]! - dayUsedMinutes[i]!;
          if (budgetAfterRevision >= breakMinutes) {
            dayBlocks[i]!.add(StudyBlock(
              startTime:       minsToTime(dayNextStart[i]!),
              title:           'Short Break',
              durationMinutes: breakMinutes,
              type:            BlockType.breakSlot,
              status:          BlockStatus.none,
            ));
            dayUsedMinutes[i] = dayUsedMinutes[i]! + breakMinutes;
            dayNextStart[i]   = dayNextStart[i]! + breakMinutes;
          }
        }
      }
    }

    // ── 5. Build final sorted day plans ────────────────────────────
    final List<DayPlan> generatedDays = List.generate(7, (i) {
      final targetDate = mondayOfThisWeek.add(Duration(days: i));
      final blocks = dayBlocks[i]!
        ..sort((a, b) {
          final aMins = int.parse(a.startTime.split(':')[0]) * 60 +
              int.parse(a.startTime.split(':')[1]);
          final bMins = int.parse(b.startTime.split(':')[0]) * 60 +
              int.parse(b.startTime.split(':')[1]);
          return aMins.compareTo(bMins);
        });
      return DayPlan(date: targetDate, blocks: blocks);
    });

    plan    = WeekPlan(days: generatedDays, lastUpdated: DateTime.now());
    loading = false;
    notifyListeners();
  }

  void updateCacheEngine(LocalCacheService engine) {
    _cacheEngine = engine;
  }

  WeekPlan? plan;
  bool loading = false;
  bool isOffline = false;
  String? error;
  StreamSubscription? _enrollmentSubscription;

  String? _currentSemester;
  List<Map<String, dynamic>> _latestFirestoreTasks = [];

  String _tasksCacheKey(String uid) => 'study_plan_tasks_$uid';
  String _planCacheKey(String uid)  => 'study_plan_week_$uid';

  Future<void> _saveTasksToCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final serializable = _latestFirestoreTasks.map((t) => {
        'title':   t['title'],
        'subject': t['subject'],
        'hours':   t['hours'],
        'status':  (t['status'] as BlockStatus).name,
        'dueDate': (t['dueDate'] as DateTime?)?.toIso8601String(),
      }).toList();
      await _cacheEngine?.write(_tasksCacheKey(uid), serializable);
    } catch (e) {
      debugPrint('study plan tasks cache write error: $e');
    }
  }

  Future<bool> _loadTasksFromCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final decoded = await _cacheEngine?.read(_tasksCacheKey(uid));
      if (decoded == null) return false;

      final List<dynamic> list =
      decoded is String ? jsonDecode(decoded) : List.from(decoded);
      _latestFirestoreTasks = list.map((t) {
        BlockStatus status = BlockStatus.toDo;
        if (t['status'] == 'inProgress') status = BlockStatus.inProgress;
        if (t['status'] == 'completed')  status = BlockStatus.completed;
        if (t['status'] == 'dueSoon')    status = BlockStatus.dueSoon;

        return {
          'title':   t['title'],
          'subject': t['subject'],
          'hours':   (t['hours'] as num).toDouble(),
          'status':  status,
          'dueDate': t['dueDate'] != null ? DateTime.parse(t['dueDate']) : null,
        };
      }).toList();

      return _latestFirestoreTasks.isNotEmpty;
    } catch (e) {
      debugPrint('study plan tasks cache read error: $e');
      return false;
    }
  }

  void listenToLiveStudyPlan({String? semester}) {
    _currentSemester = semester;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _loadTasksFromCache().then((hasCached) {
      if (hasCached) {
        _generateLocalFastPlan();
      } else {
        loading = true;
        notifyListeners();
      }
    });

    _enrollmentSubscription?.cancel();

    _enrollmentSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      _latestFirestoreTasks.clear();

      for (var doc in snapshot.docs) {
        final dataMap = doc.data() as Map<String, dynamic>;
        final sem = dataMap['semester'] as String?;
        if (sem != null && semester != null && semester.isNotEmpty && sem != semester) continue;

        final String className       = dataMap['classId']?.toString() ?? 'General';
        final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];

        for (var t in rawTasks) {
          if (t['status'] != 'completed') {
            _latestFirestoreTasks.add({
              'title':   t['title'] ?? 'Assignment Task',
              'subject': className,
              'hours':   (t['estimatedHours'] as num?
                  ?? t['estimated_hours'] as num?
                  ?? 1.5).toDouble(),
              'status':  t['status'] == 'inProgress'
                  ? BlockStatus.inProgress
                  : BlockStatus.toDo,
              'dueDate': () {
                final raw = t['dueDate'] ?? t['due_date'];
                if (raw == null) return null;
                return raw is String ? DateTime.tryParse(raw) : null;
              }(),
            });
          }
        }
      }

      _saveTasksToCache();
      isOffline = false;
      _generateLocalFastPlan();
    }, onError: (e) {
      error   = e.toString();
      loading = false;
      _loadTasksFromCache().then((hasCached) {
        isOffline = hasCached;
        if (hasCached) _generateLocalFastPlan();
        notifyListeners();
      });
    });
  }

  void switchSemester(String semester) => listenToLiveStudyPlan(semester: semester);
  Future<void> fetch({String? semester}) async => listenToLiveStudyPlan(semester: semester);
  void loadMock() => listenToLiveStudyPlan();

  Future<void> generateAiWeeklyPlan() async {
    loading = true;
    error   = null;
    notifyListeners();

    try {
      final now             = DateTime.now();
      final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
      final String mondayIsoStr = DateFormat('yyyy-MM-dd').format(monday);

      // ── Build task list with priority ──────────────────────────────
      final List<Map<String, dynamic>> taskInput = _latestFirestoreTasks.map((t) {
        String priority = 'medium';
        if (t['status'] == BlockStatus.inProgress) {
          priority = 'high';
        } else if (t['dueDate'] != null) {
          final int days = (t['dueDate'] as DateTime).difference(now).inDays;
          if (days <= 2) priority = 'high';
          if (days > 5)  priority = 'low';
        }
        return {
          'subject':         t['subject'],
          'task_title':      t['title'],
          'estimated_hours': t['hours'],
          'priority':        priority,
          'status':          (t['status'] as BlockStatus).name,
          'due_date':        t['dueDate'] != null
              ? DateFormat('yyyy-MM-dd').format(t['dueDate'] as DateTime)
              : null,
        };
      }).toList();

      final settings = _settingsProvider;
      final burnout  = _burnoutProvider;

      String toHHMM(TimeOfDay t) =>
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

      final String studyStart = settings != null ? toHHMM(settings.studyStart) : '08:00';
      final String studyEnd   = settings != null ? toHHMM(settings.studyEnd)   : '22:00';


      final List<String> blockedSlots      = settings?.blockedSlots.toList() ?? [];
      final List<String> enrolledSubjects = [
        ...?settings?.joinedClasses.map((c) => c.name),
        ...?settings?.subjects.map((s) => s['name'] ?? '').where((n) => n.isNotEmpty),
      ].toSet().toList();
      final String burnoutLevel = burnout?.alert?.workloadLevel.name ?? 'low';

      final Map<String, dynamic> aiResponse = await AiService.generateStudyPlan(
        tasks:            taskInput,
        enrolledSubjects: enrolledSubjects,
        studyStart:       studyStart,
        studyEnd:         studyEnd,
        blockedSlots:     blockedSlots,
        burnoutLevel:     burnoutLevel,
        startDateIso:     mondayIsoStr,
      );

      final List<DayPlan> parsedDays = [];
      for (var dayMap in (aiResponse['days'] ?? [])) {
        final DateTime date           = DateTime.parse(dayMap['date'] ?? mondayIsoStr);
        final List<StudyBlock> blocks = [];

        for (var blockMap in (dayMap['blocks'] ?? [])) {
          BlockType   bType   = BlockType.study;
          BlockStatus bStatus = BlockStatus.toDo;

          if (blockMap['type']   == 'breakSlot') bType   = BlockType.breakSlot;
          if (blockMap['type']   == 'blocked')   bType   = BlockType.blocked;
          if (blockMap['status'] == 'inProgress') bStatus = BlockStatus.inProgress;
          if (blockMap['status'] == 'completed')  bStatus = BlockStatus.completed;
          if (blockMap['status'] == 'dueSoon')    bStatus = BlockStatus.dueSoon;

          blocks.add(StudyBlock(
            startTime:       blockMap['start_time'] ?? '09:00',
            title:           blockMap['title'] ?? 'Study Session',
            subject:         blockMap['subject'],
            durationMinutes: (blockMap['duration_minutes'] as num? ?? 60).toInt(),
            type:            bType,
            status:          bStatus,
          ));
        }
        parsedDays.add(DayPlan(date: date, blocks: blocks));
      }

      if (parsedDays.isNotEmpty) {
        plan = WeekPlan(days: parsedDays, lastUpdated: DateTime.now());
      } else {
        throw Exception('AI returned empty plan.');
      }
    } catch (e) {
      error = 'AI Generation Failed: ${e.toString()}';
      _generateLocalFastPlan();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setPlan(WeekPlan newPlan) {
    plan = newPlan;
    notifyListeners();
  }

  void updateBlock(int dayIndex, int blockIndex, StudyBlock updated) {
    if (plan == null) return;
    final days   = List<DayPlan>.from(plan!.days);
    final blocks = List<StudyBlock>.from(days[dayIndex].blocks);
    blocks[blockIndex] = updated;
    days[dayIndex]     = DayPlan(date: days[dayIndex].date, blocks: blocks);
    plan               = WeekPlan(days: days, lastUpdated: DateTime.now());
    notifyListeners();
  }

  @override
  void dispose() {
    _enrollmentSubscription?.cancel();
    super.dispose();
  }
}