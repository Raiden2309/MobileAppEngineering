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

  String? _currentSemesterId;
  String? get currentSemesterId => _currentSemesterId;

  void updateActiveSemester(String? semesterId) {
    if (_currentSemesterId != semesterId) {
      _currentSemesterId = semesterId;
      notifyListeners();
      // Re-trigger live stats to instantly switch context to the newly selected semester
      listenToLiveDashboardStats();
    }
  }

  Stream<List<StudentSubjectModel>> get myEnrolledClassesStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      // Filter out enrollments that don't match the active semester
      final docs = snapshot.docs.where((doc) {
        final sem = doc.data()['semester']?.toString() ?? doc.data()['semester_id']?.toString();
        if (_currentSemesterId != null && _currentSemesterId!.isNotEmpty) {
          return sem == _currentSemesterId;
        }
        return true;
      });

      return docs.map((doc) {
        final mapData = doc.data();

        // Defensive parsing to safely enforce the integer and string types required by your model
        final int id = mapData['id'] is int
            ? mapData['id'] as int
            : int.tryParse(mapData['id']?.toString() ?? '') ?? doc.id.hashCode.abs();

        final int studentId = mapData['student_id'] is int
            ? mapData['student_id'] as int
            : int.tryParse(mapData['studentId']?.toString() ?? '') ?? 0;

        final int semesterId = mapData['semester_id'] is int
            ? mapData['semester_id'] as int
            : int.tryParse(mapData['semester']?.toString() ?? mapData['semesterId']?.toString() ?? '') ?? 0;

        final int subjectId = mapData['subject_id'] is int
            ? mapData['subject_id'] as int
            : int.tryParse(mapData['subjectId']?.toString() ?? mapData['classId']?.toString() ?? '') ?? 0;

        final String name = mapData['name']?.toString() ??
            mapData['subjectName']?.toString() ??
            mapData['className']?.toString() ?? 'Unknown Subject';

        final String code = mapData['code']?.toString() ??
            mapData['subjectCode']?.toString() ?? 'N/A';

        final String colorHex = mapData['color_hex']?.toString() ??
            mapData['colorHex']?.toString() ?? '#FFFFFF';

        return StudentSubjectModel(
          id: id,
          studentId: studentId,
          semesterId: semesterId,
          subjectId: subjectId,
          name: name,
          code: code,
          colorHex: colorHex,
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

      // Filter enrollment data matching our active semester id
      final validDocs = snapshot.docs.where((doc) {
        final sem = doc.data()['semester']?.toString() ?? doc.data()['semester_id']?.toString();
        if (_currentSemesterId != null && _currentSemesterId!.isNotEmpty) {
          return sem == _currentSemesterId;
        }
        return true;
      }).toList();

      for (var doc in validDocs) {
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
        summary: DashboardSummary(
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

    return _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final List<TaskItem> result = [];
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      for (var doc in snapshot.docs) {
        final d = doc.data();

        // Exclude tasks belonging to other semesters
        final String? docSemester = d['semester']?.toString() ?? d['semester_id']?.toString();
        if (_currentSemesterId != null && _currentSemesterId!.isNotEmpty && docSemester != _currentSemesterId) {
          continue;
        }

        final String className = d['name']?.toString() ?? d['subjectName']?.toString() ?? d['classId']?.toString() ?? 'General';
        final List<dynamic> tasks = d['tasksList'] as List? ?? [];

        for (var t in tasks) {
          final String? statusStr = t['status']?.toString();
          if (statusStr == 'completed' || statusStr == 'done') continue;

          final String? dueDateStr = t['dueDate']?.toString() ?? t['due_date']?.toString();
          final String? estHours = (t['estimated_hours'] ?? t['estimatedHours'] ?? '0').toString();

          final bool isToday = dueDateStr != null && dueDateStr.startsWith(todayStr);
          final bool isInProgress = statusStr == 'inProgress' || statusStr == 'in_progress';
          final bool isPending = statusStr == 'toDo' || statusStr == 'todo' || statusStr == 'pending';

          if (isToday || isInProgress || isPending) {
            result.add(TaskItem(
              title: t['title']?.toString() ?? 'Task',
              subtitle: '$className · ${estHours}h',
              status: isInProgress ? TaskStatus.inProgress : TaskStatus.dueToday,
              classId: doc.id,
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

    try {
      final docRef = _db.collection('enrollments').doc(classId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final List<dynamic> tasks = List.from(docSnap.data()?['tasksList'] ?? []);

      final index = tasks.indexWhere((t) => t['id'].toString() == taskId);
      if (index == -1) return;

      final currentStatus = tasks[index]['status']?.toString() ?? '';
      final isCompleting = currentStatus != 'completed' && currentStatus != 'done';

      final String newStatus = isCompleting ? 'completed' : 'toDo';
      final int delta = isCompleting ? 1 : -1;

      tasks[index] = {
        ...tasks[index],
        'status': newStatus,
      };

      await docRef.update({
        'tasksList': tasks,
        'completedTasks': FieldValue.increment(delta),
        'pendingTasks': FieldValue.increment(-delta),
      });
    } catch (e) {
      debugPrint('toggleTaskCompletion error: $e');
    }
  }

  @override
  void dispose() {
    _enrollmentSubscription?.cancel();
    _scheduleTimer?.cancel();
    super.dispose();
  }
}