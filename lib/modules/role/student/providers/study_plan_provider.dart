import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/app_enums.dart';
import '../models/study_plan_model.dart';
import '../../../../shared/services/ai_service.dart';

class StudyPlanProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WeekPlan? plan;
  bool loading = false;
  String? error;
  StreamSubscription? _enrollmentSubscription;

  List<Map<String, dynamic>> _latestFirestoreTasks = [];

  /// Instantly sets up a real-time stream that uses fast local distribution rules on load.
  void listenToLiveStudyPlan() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Only show loading spinner on initial boot if no plan has been built locally yet
    if (plan == null) {
      loading = true;
      notifyListeners();
    }

    _enrollmentSubscription?.cancel();
    _enrollmentSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {

      _latestFirestoreTasks.clear();
      for (var doc in snapshot.docs) {
        final dataMap = doc.data();
        final String className = dataMap['classId']?.toString() ?? 'General';
        final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];

        for (var t in rawTasks) {
          if (t['status'] != 'completed') {
            _latestFirestoreTasks.add({
              'title': t['title'] ?? 'Assignment Task',
              'subject': className,
              'hours': (t['estimated_hours'] as num? ?? 1.5).toDouble(),
              'status': t['status'] == 'inProgress' ? BlockStatus.inProgress : BlockStatus.toDo,
              'dueDate': t['due_date'] != null ? DateTime.parse(t['due_date'] as String) : null,
            });
          }
        }
      }

      // FIXED: Generate using local fast rules instantly instead of blocking the app with an API call
      _generateLocalFastPlan();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  /// FAST LOCAL ALGORITHM: Arranges tasks instantly into the calendar without hitting the internet
  void _generateLocalFastPlan() {
    final List<DayPlan> generatedDays = [];
    final now = DateTime.now();

    final int currentDayOfWeek = now.weekday;
    final DateTime mondayOfThisWeek = now.subtract(Duration(days: currentDayOfWeek - 1));

    int unDatedTaskDistributionIndex = 0;

    for (int i = 0; i < 7; i++) {
      final targetDate = mondayOfThisWeek.add(Duration(days: i));
      final List<StudyBlock> dailyBlocks = [];

      final DateTime todayMidnight = DateTime(now.year, now.month, now.day);
      final DateTime targetMidnight = DateTime(targetDate.year, targetDate.month, targetDate.day);

      final matchDayTasks = _latestFirestoreTasks.where((t) {
        final DateTime? taskDue = t['dueDate'];

        if (taskDue == null) {
          if (!targetMidnight.isBefore(todayMidnight)) {
            final int dayOffset = targetMidnight.difference(todayMidnight).inDays;
            final int assignedDaySlot = unDatedTaskDistributionIndex % 3;
            if (dayOffset == assignedDaySlot) return true;
          }
          return false;
        }

        return taskDue.day == targetDate.day &&
            taskDue.month == targetDate.month &&
            taskDue.year == targetDate.year;
      }).toList();

      if (matchDayTasks.isNotEmpty) {
        unDatedTaskDistributionIndex++;
      }

      String activeTimelineTrackerString = "10:00";
      for (var targetTask in matchDayTasks) {
        final double taskHours = targetTask['hours'];
        final int executionMinutes = (taskHours * 60).round();

        dailyBlocks.add(StudyBlock(
          startTime: activeTimelineTrackerString,
          title: targetTask['title'],
          subject: targetTask['subject'],
          durationMinutes: executionMinutes,
          type: BlockType.study,
          status: targetTask['status'],
        ));

        activeTimelineTrackerString = taskHours == 1.5 ? "11:30" : "12:00";

        dailyBlocks.add(StudyBlock(
          startTime: activeTimelineTrackerString,
          title: "Post-Study Recharge Break",
          durationMinutes: 30,
          type: BlockType.breakSlot,
          status: BlockStatus.toDo,
        ));

        activeTimelineTrackerString = taskHours == 1.5 ? "12:00" : "12:30";
      }

      generatedDays.add(DayPlan(date: targetDate, blocks: dailyBlocks));
    }

    plan = WeekPlan(days: generatedDays, lastUpdated: DateTime.now());
    loading = false;
    notifyListeners();
  }

  /// AI ENGINE MODE: Only called when explicitly hitting the "Regenerate" action button
  Future<void> generateAiWeeklyPlan() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final int currentDayOfWeek = now.weekday;
      final DateTime mondayOfThisWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
      final String mondayIsoStr = DateFormat('yyyy-MM-dd').format(mondayOfThisWeek);

      final List<Map<String, dynamic>> structuredSubjectsInput = _latestFirestoreTasks.map((t) {
        String priority = 'medium';
        if (t['status'] == BlockStatus.inProgress) {
          priority = 'high';
        } else if (t['dueDate'] != null) {
          final int daysRemaining = (t['dueDate'] as DateTime).difference(now).inDays;
          if (daysRemaining <= 2) priority = 'high';
          if (daysRemaining > 5) priority = 'low';
        }

        return {
          'name': t['subject'],
          'task_title': t['title'],
          'estimated_hours': t['hours'],
          'priority': priority,
        };
      }).toList();

      if (structuredSubjectsInput.isEmpty) {
        structuredSubjectsInput.add({
          'name': 'General Study',
          'task_title': 'Review Semester Materials',
          'estimated_hours': 2.0,
          'priority': 'medium'
        });
      }

      final Map<String, dynamic> aiResponseJson = await AiService.generateStudyPlan(
        subjects: structuredSubjectsInput,
        availableHoursPerDay: 6,
        startDateIso: mondayIsoStr,
      );

      final List<dynamic> daysArray = aiResponseJson['days'] ?? [];
      final List<DayPlan> parsedDaysList = [];

      for (var dayMap in daysArray) {
        final DateTime parsedDate = DateTime.parse(dayMap['date'] ?? mondayIsoStr);
        final List<dynamic> blocksArray = dayMap['blocks'] ?? [];
        final List<StudyBlock> blocksList = [];

        for (var blockMap in blocksArray) {
          final String rawType = blockMap['type'] ?? 'study';
          final String rawStatus = blockMap['status'] ?? 'toDo';

          BlockType bType = BlockType.study;
          if (rawType == 'breakSlot') bType = BlockType.breakSlot;
          if (rawType == 'blocked') bType = BlockType.blocked;

          BlockStatus bStatus = BlockStatus.toDo;
          if (rawStatus == 'inProgress') bStatus = BlockStatus.inProgress;
          if (rawStatus == 'completed') bStatus = BlockStatus.completed;
          if (rawStatus == 'dueSoon') bStatus = BlockStatus.dueSoon;

          blocksList.add(StudyBlock(
            startTime: blockMap['start_time'] ?? '09:00',
            title: blockMap['title'] ?? 'Study Session',
            subject: blockMap['subject'],
            durationMinutes: (blockMap['duration_minutes'] as num? ?? 60).toInt(),
            type: bType,
            status: bStatus,
          ));
        }

        parsedDaysList.add(DayPlan(date: parsedDate, blocks: blocksList));
      }

      if (parsedDaysList.isNotEmpty) {
        plan = WeekPlan(days: parsedDaysList, lastUpdated: DateTime.now());
      } else {
        throw Exception("AI structured data returned empty.");
      }

    } catch (e) {
      error = "AI Generation Failed: ${e.toString()}";
      // Fallback instantly to local structure so the user's screen never breaks
      _generateLocalFastPlan();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetch() async {
    listenToLiveStudyPlan();
  }

  void loadMock() {
    listenToLiveStudyPlan();
  }

  void setPlan(WeekPlan newPlan) {
    plan = newPlan;
    notifyListeners();
  }

  void updateBlock(int dayIndex, int blockIndex, StudyBlock updated) {
    if (plan == null) return;
    final days = List<DayPlan>.from(plan!.days);
    final blocks = List<StudyBlock>.from(days[dayIndex].blocks);
    blocks[blockIndex] = updated;
    days[dayIndex] = DayPlan(date: days[dayIndex].date, blocks: blocks);
    plan = WeekPlan(days: days, lastUpdated: DateTime.now());
    notifyListeners();
  }

  @override
  void dispose() {
    _enrollmentSubscription?.cancel();
    super.dispose();
  }
}