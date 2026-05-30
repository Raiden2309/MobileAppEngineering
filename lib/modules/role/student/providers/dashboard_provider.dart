import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_subject_model.dart';
import '../models/dashboard_models.dart';

class StudentDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  DashboardModel? data;

  // Real-time schedule checking fields
  Timer? _scheduleTimer;
  String _activeScheduleTask = "Free Time / Break";
  String get activeScheduleTask => _activeScheduleTask;

  // Clean data stream returning structured student subjects from enrollments collection
  Stream<List<StudentSubjectModel>> get myEnrolledClassesStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final mapData = doc.data();
        final String classIdStr = mapData['classId']?.toString() ?? 'UNKNOWN';
        final int rawHashId = classIdStr.hashCode.abs();

        return StudentSubjectModel(
          id: rawHashId,
          studentId: rawHashId,
          semesterId: 1, // Fallback placeholder index integer values
          subjectId: rawHashId,
          name: classIdStr,
          code: classIdStr.toUpperCase().padRight(6, 'X').substring(0, 6),
          colorHex: '#60A5FA',
        );
      }).toList();
    });
  }

  // --- COMPUTE REAL-TIME TIMETABLE TASK STATUS UPDATER ---
  void startScheduleAutoTracker(List<dynamic> dailyStudyBlocks) {
    _scheduleTimer?.cancel();
    _evaluateCurrentTimeSlot(dailyStudyBlocks);

    // Re-verify the schedule slot matches the clock time every 60 seconds
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _evaluateCurrentTimeSlot(dailyStudyBlocks);
    });
  }

  void _evaluateCurrentTimeSlot(List<dynamic> blocks) {
    final now = DateTime.now();
    final currentMinutes = (now.hour * 60) + now.minute;
    String detectedTask = "Free Time / Break";

    for (var block in blocks) {
      final start = _parseTimeToMinutes(block.startTime);
      final end = _parseTimeToMinutes(block.endTime);

      if (currentMinutes >= start && currentMinutes < end) {
        detectedTask = block.title;
        break;
      }
    }

    if (_activeScheduleTask != detectedTask) {
      _activeScheduleTask = detectedTask;
      notifyListeners(); // Seamlessly update UI views on structural match adjustments
    }
  }

  int _parseTimeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return (int.parse(parts[0].trim()) * 60) + int.parse(parts[1].trim());
    } catch (_) {
      return 0;
    }
  }

  void loadMock() {
    data = DashboardModel.mockData();
    notifyListeners();
  }

  void toggleTask(int index) {
    if (data == null) return;

    final updatedTasks = List<TaskItem>.from(data!.todayTasks);
    updatedTasks[index] = updatedTasks[index].copyWith(
      checked: !updatedTasks[index].checked,
    );

    data = DashboardModel(
      summary: data!.summary,
      stats: data!.stats,
      currentTask: data!.currentTask,
      workloadPlan: data!.workloadPlan,
      todayTasks: updatedTasks,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }
}