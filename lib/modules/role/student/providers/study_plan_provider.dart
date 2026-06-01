import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/app_enums.dart';
import '../models/study_plan_model.dart';
import '../../../../shared/services/ai_service.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';

class StudyPlanProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LocalCacheService? _cacheEngine;

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

      final List<dynamic> list = decoded is String ? jsonDecode(decoded) : List.from(decoded);
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

        final String className    = dataMap['classId']?.toString() ?? 'General';
        final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];

        for (var t in rawTasks) {
          if (t['status'] != 'completed') {
            _latestFirestoreTasks.add({
              'title':   t['title'] ?? 'Assignment Task',
              'subject': className,
              'hours':   (t['estimated_hours'] as num? ?? 1.5).toDouble(),
              'status':  t['status'] == 'inProgress' ? BlockStatus.inProgress : BlockStatus.toDo,
              'dueDate': t['due_date'] != null ? DateTime.parse(t['due_date'] as String) : null,
            });
          }
        }
      }

      _saveTasksToCache();
      isOffline = false;
      _generateLocalFastPlan();
    }, onError: (e) {
      error = e.toString();
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

  void _generateLocalFastPlan() {
    final List<DayPlan> generatedDays = [];
    final now = DateTime.now();
    final DateTime mondayOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    int unDatedTaskDistributionIndex = 0;

    for (int i = 0; i < 7; i++) {
      final targetDate = mondayOfThisWeek.add(Duration(days: i));
      final List<StudyBlock> dailyBlocks = [];
      final DateTime todayMidnight  = DateTime(now.year, now.month, now.day);
      final DateTime targetMidnight = DateTime(targetDate.year, targetDate.month, targetDate.day);

      final matchDayTasks = _latestFirestoreTasks.where((t) {
        final DateTime? taskDue = t['dueDate'];
        if (taskDue == null) {
          if (!targetMidnight.isBefore(todayMidnight)) {
            final int dayOffset    = targetMidnight.difference(todayMidnight).inDays;
            final int assignedSlot = unDatedTaskDistributionIndex % 3;
            if (dayOffset == assignedSlot) return true;
          }
          return false;
        }
        return taskDue.day   == targetDate.day &&
            taskDue.month == targetDate.month &&
            taskDue.year  == targetDate.year;
      }).toList();

      if (matchDayTasks.isNotEmpty) unDatedTaskDistributionIndex++;

      String timeTracker = "10:00";
      for (var targetTask in matchDayTasks) {
        final double taskHours     = targetTask['hours'];
        final int executionMinutes = (taskHours * 60).round();

        dailyBlocks.add(StudyBlock(
          startTime:       timeTracker,
          title:           targetTask['title'],
          subject:         targetTask['subject'],
          durationMinutes: executionMinutes,
          type:            BlockType.study,
          status:          targetTask['status'],
        ));

        timeTracker = taskHours == 1.5 ? "11:30" : "12:00";

        dailyBlocks.add(StudyBlock(
          startTime:       timeTracker,
          title:           "Post-Study Recharge Break",
          durationMinutes: 30,
          type:            BlockType.breakSlot,
          status:          BlockStatus.toDo,
        ));

        timeTracker = taskHours == 1.5 ? "12:00" : "12:30";
      }

      generatedDays.add(DayPlan(date: targetDate, blocks: dailyBlocks));
    }

    plan    = WeekPlan(days: generatedDays, lastUpdated: DateTime.now());
    loading = false;
    notifyListeners();
  }

  Future<void> generateAiWeeklyPlan() async {
    loading = true;
    error   = null;
    notifyListeners();

    try {
      final now             = DateTime.now();
      final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
      final String mondayIsoStr = DateFormat('yyyy-MM-dd').format(monday);

      final List<Map<String, dynamic>> input = _latestFirestoreTasks.map((t) {
        String priority = 'medium';
        if (t['status'] == BlockStatus.inProgress) {
          priority = 'high';
        } else if (t['dueDate'] != null) {
          final int days = (t['dueDate'] as DateTime).difference(now).inDays;
          if (days <= 2) priority = 'high';
          if (days > 5)  priority = 'low';
        }
        return {
          'name':            t['subject'],
          'task_title':      t['title'],
          'estimated_hours': t['hours'],
          'priority':        priority,
        };
      }).toList();

      if (input.isEmpty) {
        input.add({'name': 'General Study', 'task_title': 'Review Semester Materials', 'estimated_hours': 2.0, 'priority': 'medium'});
      }

      final Map<String, dynamic> aiResponse = await AiService.generateStudyPlan(
        subjects:             input,
        availableHoursPerDay: 6,
        startDateIso:         mondayIsoStr,
      );

      final List<DayPlan> parsedDays = [];
      for (var dayMap in (aiResponse['days'] ?? [])) {
        final DateTime date           = DateTime.parse(dayMap['date'] ?? mondayIsoStr);
        final List<StudyBlock> blocks = [];

        for (var blockMap in (dayMap['blocks'] ?? [])) {
          BlockType   bType   = BlockType.study;
          BlockStatus bStatus = BlockStatus.toDo;

          if (blockMap['type']   == 'breakSlot')  bType   = BlockType.breakSlot;
          if (blockMap['type']   == 'blocked')     bType   = BlockType.blocked;
          if (blockMap['status'] == 'inProgress')  bStatus = BlockStatus.inProgress;
          if (blockMap['status'] == 'completed')   bStatus = BlockStatus.completed;
          if (blockMap['status'] == 'dueSoon')     bStatus = BlockStatus.dueSoon;

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
        throw Exception("AI returned empty plan.");
      }
    } catch (e) {
      error = "AI Generation Failed: ${e.toString()}";
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