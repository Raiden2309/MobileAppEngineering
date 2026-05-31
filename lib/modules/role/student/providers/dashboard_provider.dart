import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/student_subject_model.dart';
import '../models/dashboard_models.dart';

class StudentDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  DashboardModel? data;
  StreamSubscription? _enrollmentSubscription;

  Timer? _scheduleTimer;
  String _activeScheduleTask = "Free Time / Break";
  String get activeScheduleTask => _activeScheduleTask;

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
          semesterId: (mapData['semesterId'] as num? ?? 1).toInt(),
          subjectId: rawHashId,
          name: classIdStr,
          code: mapData['subjectCode']?.toString() ?? classIdStr.toUpperCase().padRight(6, 'X').substring(0, 6),
          colorHex: mapData['colorHex']?.toString() ?? '#60A5FA',
        );
      }).toList();
    });
  }

  void listenToLiveDashboardStats() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    _enrollmentSubscription?.cancel();
    _enrollmentSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {

      int tasksCompleted = 0;
      int tasksTotal = 0;
      int tasksDueSoon = 0;
      int tasksOverdue = 0;

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final docMap = doc.data();
        final List<dynamic> rawTasks = docMap['tasksList'] ?? [];

        tasksTotal += rawTasks.length;

        for (var t in rawTasks) {
          final String statusStr = t['status']?.toString() ?? 'toDo';
          final String? deadlineRaw = t['deadline']?.toString();

          if (statusStr == 'completed' || statusStr == 'done') {
            tasksCompleted++;
          } else if (statusStr == 'overdue') {
            tasksOverdue++;
          } else {
            if (deadlineRaw != null) {
              final deadlineDate = DateTime.tryParse(deadlineRaw);
              if (deadlineDate != null) {
                if (deadlineDate.isBefore(now)) {
                  tasksOverdue++;
                } else if (deadlineDate.difference(now).inDays <= 3) {
                  tasksDueSoon++;
                }
              }
            } else {
              if (statusStr == 'dueSoon' || statusStr == 'due_soon') tasksDueSoon++;
            }
          }
        }
      }

      data = DashboardModel(
        summary: data?.summary ?? DashboardSummary(
          userName: _auth.currentUser?.displayName ?? 'Student',
          taskCountToday: tasksTotal - tasksCompleted - tasksOverdue,
          date: DateTime.now(),
        ),
        stats: DashboardStats(
          tasksDone: tasksCompleted,
          totalTasks: tasksTotal,
          dueSoon: tasksDueSoon,
          dueSoonDays: 3,
          overdue: tasksOverdue,
          currentWeek: data?.stats.currentWeek ?? 8,
          totalWeeks: data?.stats.totalWeeks ?? 14,
        ),
        currentTask: data?.currentTask,
        workloadPlan: data?.workloadPlan ?? const WorkloadPlan(planLabel: 'Study blocks', tasks: []),
        todayTasks: data?.todayTasks ?? [],
      );

      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      isLoading = false;
      notifyListeners();
    });
  }

  void startScheduleAutoTracker(List<dynamic> dailyStudyBlocks) {
    _scheduleTimer?.cancel();
    _evaluateCurrentTimeSlot(dailyStudyBlocks);

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
      notifyListeners();
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

  Stream<List<TaskItem>> get todayTasksStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    final today = DateTime.now();

    return _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final List<TaskItem> result = [];

      for (var doc in snapshot.docs) {
        final mapData = doc.data();
        final String className = mapData['classId']?.toString() ?? '';
        final List<dynamic> rawTasks = mapData['tasksList'] ?? [];

        for (var t in rawTasks) {
          final String status = t['status']?.toString() ?? '';
          if (status == 'completed' || status == 'done') continue;

          final String? dueDateStr = t['due_date'] ?? t['deadline'];
          bool isToday = false;

          if (dueDateStr != null) {
            final due = DateTime.tryParse(dueDateStr);
            if (due != null) {
              isToday = due.day == today.day &&
                  due.month == today.month &&
                  due.year == today.year;
            }
          }

          final bool isInProgress = status == 'inProgress' || status == 'in_progress';
          // Show if due today, in progress, OR just a pending toDo with no date
          final bool isPending = status == 'toDo' && dueDateStr == null;

          if (isToday || isInProgress || isPending) {
            result.add(TaskItem(
              title: t['title']?.toString() ?? 'Task',
              subtitle: '$className · ${t['estimated_hours']}h',
              status: isInProgress ? TaskStatus.inProgress : TaskStatus.dueToday,
              classId: className,
              taskId: t['id']?.toString() ?? '',
            ));
          }
        }
      }

      return result;
    });
  }

  Future<void> toggleTaskCompletion(String classId, String taskId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .where('classId', isEqualTo: classId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final doc = snapshot.docs.first;
    final List<dynamic> tasks = List.from(doc.data()['tasksList'] ?? []);

    final index = tasks.indexWhere((t) => t['id'].toString() == taskId);
    if (index == -1) return;

    final current = tasks[index]['status']?.toString() ?? '';
    tasks[index] = {
      ...tasks[index],
      'status': (current == 'completed' || current == 'done') ? 'toDo' : 'completed',
    };

    await doc.reference.update({'tasksList': tasks});
  }

  @override
  void dispose() {
    _enrollmentSubscription?.cancel();
    _scheduleTimer?.cancel();
    super.dispose();
  }
}