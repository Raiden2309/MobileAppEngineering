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

    // If we have a cached state already, keep using it instantly instead of dropping into a loading loop
    if (data == null) {
      loading = true;
      // Pre-seed a clean structural backup layout to avoid blocking the viewport render grid lines
      data = const SemesterProgressModel(
        semesterName: 'Degree Level 1',
        dateRange: 'March – July 2026',
        overallProgress: 0.0,
        completedTasks: 0,
        totalTasks: 0,
        currentWeek: 8,
        totalWeeks: 14,
        timelineProgress: 0.57,
        weeksRemaining: 6,
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
        final String subjectCodeStr = doc.id.split('_').last.toUpperCase();

        final int subjectCompleted = (dataMap['completedTasks'] as num? ?? 0).toInt();
        final int subjectPending = (dataMap['pendingTasks'] as num? ?? 0).toInt();
        final int subjectTotal = subjectCompleted + subjectPending;

        final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];
        final int subjectDueSoon = rawTasks.where((t) => t['status'] == 'dueSoon').length;

        overallTotalTasks += subjectTotal;
        overallCompletedTasks += subjectCompleted;

        double subjectProgressRatio = subjectTotal > 0 ? (subjectCompleted / subjectTotal) : 0.0;

        liveSubjectsList.add(SubjectProgress(
          name: subjectNameStr,
          code: subjectCodeStr,
          progress: subjectProgressRatio,
          completed: subjectCompleted,
          remaining: subjectPending,
          dueSoon: subjectDueSoon,
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
        currentWeek: 8,
        totalWeeks: 14,
        timelineProgress: 0.57,
        weeksRemaining: 6,
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