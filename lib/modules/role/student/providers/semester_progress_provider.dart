import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/semester_progress_model.dart';

class SemesterProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SemesterProgressModel? data;
  bool loading = false;
  String? error;
  StreamSubscription? _progressSubscription;

  void listenToLiveProgress() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Academic Term Configuration
    final DateTime termStartDate = DateTime(2026, 3, 2); // Term started first week of March
    final DateTime termEndDate = DateTime(2026, 7, 10);  // Term ends second week of July
    final DateTime now = DateTime.now();

    // Calculate Semester Week Metrics Dynamically
    final int totalDaysInTerm = termEndDate.difference(termStartDate).inDays;
    final int totalWeeksInTerm = (totalDaysInTerm / 7).ceil();

    int currentWeekCalculated = ((now.difference(termStartDate).inDays) / 7).ceil();
    currentWeekCalculated = currentWeekCalculated.clamp(1, totalWeeksInTerm);

    int weeksRemainingCalculated = totalWeeksInTerm - currentWeekCalculated;
    weeksRemainingCalculated = weeksRemainingCalculated.clamp(0, totalWeeksInTerm);

    double liveTimelineProgress = now.difference(termStartDate).inDays / totalDaysInTerm;
    liveTimelineProgress = liveTimelineProgress.clamp(0.0, 1.0);

    if (data == null) {
      loading = true;
      data = SemesterProgressModel(
        semesterName: 'Degree Level 1',
        dateRange: 'March – July 2026',
        overallProgress: 0.0,
        completedTasks: 0,
        totalTasks: 0,
        currentWeek: currentWeekCalculated,
        totalWeeks: totalWeeksInTerm,
        timelineProgress: liveTimelineProgress,
        weeksRemaining: weeksRemainingCalculated,
        finalExamDate: '14 July',
        subjects: [],
      );
      notifyListeners();
    }

    _progressSubscription?.cancel();
    _progressSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {

      int overallTotalTasks = 0;
      int overallCompletedTasks = 0;
      final List<SubjectProgress> liveSubjectsList = [];

      for (var doc in snapshot.docs) {
        final dataMap = doc.data();
        final String subjectNameStr = dataMap['classId']?.toString() ?? 'General';

        // Grab code safely from fields or break down your string patterns
        final String subjectCodeStr = dataMap['subjectCode']?.toString() ??
            (doc.id.contains('_') ? doc.id.split('_').last.toUpperCase() : 'COMP000');

        final List<dynamic> rawTasks = dataMap["tasksList"] ?? [];
        final int subjectCompleted = rawTasks.where((t) => t["status"] == "completed" || t["status"] == "done").length;
        final int subjectDueSoon   = rawTasks.where((t) => t["status"] == "dueSoon" || t["status"] == "due_soon").length;
        final int subjectTotal     = rawTasks.length;
        final int subjectRemaining = subjectTotal - subjectCompleted;

        overallTotalTasks     += subjectTotal;
        overallCompletedTasks += subjectCompleted;

        final double subjectProgressRatio = subjectTotal > 0 ? (subjectCompleted / subjectTotal) : 0.0;

        liveSubjectsList.add(SubjectProgress(
          name:      subjectNameStr,
          code:      subjectCodeStr,
          progress:  subjectProgressRatio,
          completed: subjectCompleted,
          remaining: subjectRemaining,
          dueSoon:   subjectDueSoon,
        ));
      }

      double liveOverallProgressRatio = overallTotalTasks > 0
          ? (overallCompletedTasks / overallTotalTasks)
          : 0.0;

      data = SemesterProgressModel(
        semesterName: 'Degree Level 1',
        dateRange: 'March – July 2026',
        overallProgress: liveOverallProgressRatio,
        completedTasks: overallCompletedTasks,
        totalTasks: overallTotalTasks,
        currentWeek: currentWeekCalculated,
        totalWeeks: totalWeeksInTerm,
        timelineProgress: liveTimelineProgress,
        weeksRemaining: weeksRemainingCalculated,
        finalExamDate: '14 July',
        subjects: liveSubjectsList,
      );

      loading = false;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> fetch() async {
    listenToLiveProgress();
  }

  void loadMock() {
    listenToLiveProgress();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}