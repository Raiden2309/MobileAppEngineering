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

  String? _currentSemesterId;
  String _semesterName = '';
  String _dateRange    = '';
  DateTime? _semStart;
  DateTime? _semEnd;
  String? get currentSemesterId => _currentSemesterId;

  void switchSemester({
    required String semesterId,
    required String semesterName,
    required String start,
    required String end,
  }) {
    _currentSemesterId = semesterId;
    _semesterName      = semesterName;
    _dateRange         = '$start – $end';
    _semStart          = _tryParse(start);
    _semEnd            = _tryParse(end);
    listenToLiveProgress();
  }

  DateTime? _tryParse(String s) {
    try {
      final parts = s.split(' ');
      if (parts.length == 3) {
        const m = {'Jan':1,'Feb':2,'Mar':3,'Apr':4,'May':5,'Jun':6,
          'Jul':7,'Aug':8,'Sep':9,'Oct':10,'Nov':11,'Dec':12};
        return DateTime(int.parse(parts[2]), m[parts[1]] ?? 1, int.parse(parts[0]));
      }
      return DateTime.tryParse(s);
    } catch (_) { return null; }
  }

  int _currentWeek() {
    if (_semStart == null) return 1;
    final weeks = DateTime.now().difference(_semStart!).inDays ~/ 7 + 1;
    return weeks.clamp(1, _totalWeeks());
  }

  int _totalWeeks() {
    if (_semStart == null || _semEnd == null) return 14;
    return ((_semEnd!.difference(_semStart!).inDays) / 7).round().clamp(1, 52);
  }

  double _timelineProgress() {
    if (_semStart == null || _semEnd == null) return 0.0;
    final total   = _semEnd!.difference(_semStart!).inDays;
    final elapsed = DateTime.now().difference(_semStart!).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  int _weeksRemaining() => (_totalWeeks() - _currentWeek()).clamp(0, 52);

  String _finalExamDate() {
    if (_semEnd == null) return '–';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${_semEnd!.day} ${months[_semEnd!.month - 1]}';
  }

  void listenToLiveProgress() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (data == null) {
      loading = true;
      notifyListeners();
    }

    _progressSubscription?.cancel();

    Query query = _db.collection('enrollments').where('studentId', isEqualTo: uid);
    if (_currentSemesterId != null && _currentSemesterId!.isNotEmpty) {
      query = query.where('semester', isEqualTo: _currentSemesterId);
    }

    _progressSubscription = query.snapshots().listen((snapshot) {
      int totalTasks     = 0;
      int completedTasks = 0;
      final List<SubjectProgress> subjects = [];

      for (var doc in snapshot.docs) {
        final d = doc.data() as Map<String, dynamic>;

        final String name = d['classId']?.toString() ?? 'General';
        final String code = d['subjectCode']?.toString() ??
            (doc.id.contains('_') ? doc.id.split('_').last.toUpperCase() : 'COMP000');

        final List<dynamic> raw = d['tasksList'] as List? ?? [];
        final int completed  = raw.where((t) => t['status'] == 'completed' || t['status'] == 'done').length;
        final int dueSoon    = raw.where((t) => t['status'] == 'dueSoon'   || t['status'] == 'due_soon').length;
        final int total      = raw.length;

        totalTasks     += total;
        completedTasks += completed;

        subjects.add(SubjectProgress(
          name:      name,
          code:      code,
          progress:  total > 0 ? completed / total : 0.0,
          completed: completed,
          remaining: total - completed,
          dueSoon:   dueSoon,
        ));
      }

      data = SemesterProgressModel(
        semesterName:     _semesterName.isNotEmpty ? _semesterName : 'Current Semester',
        dateRange:        _dateRange,
        overallProgress:  totalTasks > 0 ? completedTasks / totalTasks : 0.0,
        completedTasks:   completedTasks,
        totalTasks:       totalTasks,
        currentWeek:      _currentWeek(),
        totalWeeks:       _totalWeeks(),
        timelineProgress: _timelineProgress(),
        weeksRemaining:   _weeksRemaining(),
        finalExamDate:    _finalExamDate(),
        subjects:         subjects,
      );

      loading = false;
      notifyListeners();
    }, onError: (e) {
      error   = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> fetch() async => listenToLiveProgress();
  void loadMock() => listenToLiveProgress();

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}