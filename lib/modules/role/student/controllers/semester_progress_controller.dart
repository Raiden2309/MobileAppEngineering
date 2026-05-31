import 'package:flutter/material.dart';
import '../models/semester_progress_model.dart';
import '../providers/semester_progress_provider.dart';

class SemesterProgressController extends ChangeNotifier {
  final SemesterProvider provider;

  SemesterProgressController(this.provider) {
    provider.addListener(onProviderUpdate);
  }

  SemesterProgressModel? get data => provider.data;
  bool get loading => provider.loading;
  String? get error => provider.error;

  bool get hasData => data != null;

  // Derived getters

  double get overallProgress => data?.overallProgress ?? 0.0;
  int get completedTasks => data?.completedTasks ?? 0;
  int get totalTasks => data?.totalTasks ?? 0;
  int get currentWeek => data?.currentWeek ?? 0;
  int get totalWeeks => data?.totalWeeks ?? 0;
  int get weeksRemaining => data?.weeksRemaining ?? 0;
  double get timelineProgress => data?.timelineProgress ?? 0.0;
  String get finalExamDate => data?.finalExamDate ?? '';

  // FIXED: Return clean placeholder formatting until live stream documents emit values
  String get semesterLabel => data != null
      ? '${data!.semesterName} · ${data!.dateRange}'
      : 'Loading Semester...';

  List<SubjectProgress> get subjects => data?.subjects ?? [];

  /// Returns subjects sorted by progress ascending (most at-risk first).
  List<SubjectProgress> get subjectsByRisk =>
      [...subjects]..sort((a, b) => a.progress.compareTo(b.progress));

  /// Returns subjects that have at least one task due soon.
  List<SubjectProgress> get subjectsDueSoon =>
      subjects.where((s) => s.dueSoon > 0).toList();

  // Data loading

  // FIXED: Initialize live listeners immediately on attach to stream documents without async locks
  Future<void> init() async {
    provider.listenToLiveProgress();
  }

  Future<void> fetch() async {
    provider.listenToLiveProgress();
  }

  void loadMock() {
    provider.listenToLiveProgress();
  }

  Future<void> refresh() async {
    provider.listenToLiveProgress();
  }

  // Provider sync

  void onProviderUpdate() {
    notifyListeners();
  }

  // Helpers

  /// Returns a human-readable progress summary string.
  String get progressSummary =>
      '$completedTasks of $totalTasks tasks completed';

  /// Returns a human-readable timeline summary string.
  String get timelineSummary =>
      'Week $currentWeek of $totalWeeks · $weeksRemaining weeks remaining';

  // Cleanup

  @override
  void dispose() {
    provider.removeListener(onProviderUpdate);
    super.dispose();
  }
}