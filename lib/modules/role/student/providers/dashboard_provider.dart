import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/student_subject_model.dart';
import '../models/dashboard_models.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';

class StudentDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  StudentDashboardProvider({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  LocalCacheService? _cacheEngine;

  void updateCacheEngine(LocalCacheService engine) {
    _cacheEngine = engine;
  }

  bool isLoading = false;
  bool isOffline = false;
  DashboardModel? data;
  StreamSubscription? _enrollmentSubscription;

  Timer? _scheduleTimer;
  String _activeScheduleTask = "Free Time / Break";

  String get activeScheduleTask => _activeScheduleTask;

  String? _currentSemesterId;

  String? get currentSemesterId => _currentSemesterId;

  String _cacheKey(String uid) => 'dashboard_cache_$uid';

  Future<void> _saveToCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || data == null) return;
    try {
      final payload = {
        'tasksDone': data!.stats.tasksDone,
        'totalTasks': data!.stats.totalTasks,
        'dueSoon': data!.stats.dueSoon,
        'overdue': data!.stats.overdue,
        'currentWeek': data!.stats.currentWeek,
        'totalWeeks': data!.stats.totalWeeks,
        'userName': data!.summary.userName,
        'taskCountToday': data!.summary.taskCountToday,
      };
      await _cacheEngine?.write(_cacheKey(uid), payload);
    } catch (e) {
      debugPrint('dashboard cache write error: $e');
    }
  }

  Future<bool> _loadFromCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final decoded = await _cacheEngine?.read(_cacheKey(uid));
      if (decoded == null) return false;
      final Map<String, dynamic> map = decoded is String
          ? jsonDecode(decoded)
          : Map<String, dynamic>.from(decoded);
      data = DashboardModel(
        summary: DashboardSummary(
          userName: map['userName'] ?? 'Student',
          taskCountToday: map['taskCountToday'] ?? 0,
          date: DateTime.now(),
        ),
        stats: DashboardStats(
          tasksDone: map['tasksDone'] ?? 0,
          totalTasks: map['totalTasks'] ?? 0,
          dueSoon: map['dueSoon'] ?? 0,
          dueSoonDays: 3,
          overdue: map['overdue'] ?? 0,
          currentWeek: map['currentWeek'] ?? 8,
          totalWeeks: map['totalWeeks'] ?? 14,
        ),
        currentTask: null,
        workloadPlan: const WorkloadPlan(planLabel: 'Study blocks', tasks: []),
        todayTasks: [],
      );
      return true;
    } catch (e) {
      debugPrint('dashboard cache read error: $e');
      return false;
    }
  }

  void updateActiveSemester(String? semesterId) {
    if (_currentSemesterId != semesterId) {
      _currentSemesterId = semesterId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        listenToLiveDashboardStats();
      });
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
          final docs = snapshot.docs.where((doc) {
            final sem =
                doc.data()['semester']?.toString() ??
                doc.data()['semester_id']?.toString();
            if (_currentSemesterId != null && _currentSemesterId!.isNotEmpty) {
              return sem == _currentSemesterId;
            }
            return true;
          });

          return docs.map((doc) {
            final mapData = doc.data();

            final int id = mapData['id'] is int
                ? mapData['id'] as int
                : int.tryParse(mapData['id']?.toString() ?? '') ??
                      doc.id.hashCode.abs();

            final int studentId = mapData['student_id'] is int
                ? mapData['student_id'] as int
                : int.tryParse(mapData['studentId']?.toString() ?? '') ?? 0;

            final int semesterId = mapData['semester_id'] is int
                ? mapData['semester_id'] as int
                : int.tryParse(
                        mapData['semester']?.toString() ??
                            mapData['semesterId']?.toString() ??
                            '',
                      ) ??
                      0;

            final int subjectId = mapData['subject_id'] is int
                ? mapData['subject_id'] as int
                : int.tryParse(
                        mapData['subjectId']?.toString() ??
                            mapData['classId']?.toString() ??
                            '',
                      ) ??
                      0;

            final String name =
                mapData['name']?.toString() ??
                mapData['subjectName']?.toString() ??
                mapData['className']?.toString() ??
                'Unknown Subject';

            final String code =
                mapData['code']?.toString() ??
                mapData['subjectCode']?.toString() ??
                'N/A';

            final String colorHex =
                mapData['color_hex']?.toString() ??
                mapData['colorHex']?.toString() ??
                '#FFFFFF';

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

    _loadFromCache().then((hasCached) {
      if (hasCached) {
        isLoading = false;
        notifyListeners();
      } else if (!isLoading) {
        isLoading = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      }
    });

    _enrollmentSubscription?.cancel();
    _enrollmentSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            int tasksCompleted = 0;
            int tasksTotal = 0;
            int tasksDueSoon = 0;
            int tasksOverdue = 0;

            final now = DateTime.now();

            final validDocs = snapshot.docs.where((doc) {
              final sem =
                  doc.data()['semester']?.toString() ??
                  doc.data()['semester_id']?.toString();
              if (_currentSemesterId != null &&
                  _currentSemesterId!.isNotEmpty) {
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

                if (statusStr == 'completed' || statusStr == 'done') {
                  tasksCompleted++;
                } else if (statusStr == 'overdue') {
                  tasksOverdue++;
                } else {
                  final String? dueDateRaw =
                      t['dueDate']?.toString() ?? t['due_date']?.toString();
                  if (dueDateRaw != null) {
                    final dueDate = DateTime.tryParse(dueDateRaw);
                    if (dueDate != null) {
                      final taskDay = DateTime(
                        dueDate.year,
                        dueDate.month,
                        dueDate.day,
                      );
                      final today = DateTime(now.year, now.month, now.day);
                      if (taskDay.isBefore(today)) {
                        tasksOverdue++;
                      } else if (taskDay.difference(today).inDays <= 3) {
                        tasksDueSoon++;
                      }
                    }
                  } else {
                    if (statusStr == 'dueSoon' || statusStr == 'due_soon')
                      tasksDueSoon++;
                    if (statusStr == 'overdue') tasksOverdue++;
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
              workloadPlan:
                  data?.workloadPlan ??
                  const WorkloadPlan(planLabel: 'Study blocks', tasks: []),
              todayTasks: data?.todayTasks ?? [],
            );

            isLoading = false;
            isOffline = false;
            _saveToCache();
            notifyListeners();
          },
          onError: (e) {
            isLoading = false;
            _loadFromCache().then((hasCached) {
              isOffline = hasCached;
              notifyListeners();
            });
          },
        );
  }

  void startScheduleAutoTracker(List<dynamic> dailyStudyBlocks) {
    _scheduleTimer?.cancel();
    _evaluateCurrentTimeSlot(dailyStudyBlocks);
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
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

  void load() {
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
          final todayDate = DateTime(now.year, now.month, now.day);
          final todayStr =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          for (var doc in snapshot.docs) {
            final d = doc.data();
            final String? docSemester =
                d['semester']?.toString() ?? d['semester_id']?.toString();
            if (_currentSemesterId != null &&
                _currentSemesterId!.isNotEmpty &&
                docSemester != _currentSemesterId) {
              continue;
            }

            final String className =
                d['name']?.toString() ??
                d['subjectName']?.toString() ??
                d['classId']?.toString() ??
                'General';
            final List<dynamic> tasks = d['tasksList'] as List? ?? [];

            for (var t in tasks) {
              final String statusStr = t['status']?.toString() ?? 'toDo';

              // 1. Completely skip items marked completed or done
              if (statusStr == 'completed' || statusStr == 'done') continue;

              final String? dueDateStr =
                  t['dueDate']?.toString() ?? t['due_date']?.toString();
              final String? estHours =
                  (t['estimated_hours'] ?? t['estimatedHours'] ?? '0')
                      .toString();

              final bool isTodayString =
                  dueDateStr != null && dueDateStr.startsWith(todayStr);
              final bool isInProgress =
                  statusStr == 'inProgress' || statusStr == 'in_progress';

              bool isToday = isTodayString;
              bool isOverdue = false;
              bool isCalendarDueSoon = false;

              if (dueDateStr != null) {
                final parsedDate = DateTime.tryParse(dueDateStr);
                if (parsedDate != null) {
                  final taskDate = DateTime(
                    parsedDate.year,
                    parsedDate.month,
                    parsedDate.day,
                  );

                  isToday = taskDate.isAtSameMomentAs(todayDate);
                  isOverdue = taskDate.isBefore(todayDate);

                  final daysDifference = taskDate.difference(todayDate).inDays;
                  if (daysDifference > 0 && daysDifference <= 3) {
                    isCalendarDueSoon = true;
                  }
                }
              }

              if (isToday ||
                  isOverdue ||
                  isCalendarDueSoon ||
                  isInProgress ||
                  statusStr == 'toDo' ||
                  statusStr == 'todo' ||
                  statusStr == 'pending' ||
                  statusStr == 'dueSoon' ||
                  statusStr == 'due_soon') {
                TaskStatus assignedStatus;

                if (isInProgress) {
                  assignedStatus = TaskStatus.inProgress;
                } else if (isOverdue) {
                  assignedStatus = TaskStatus.overdue;
                } else if (isToday) {
                  assignedStatus = TaskStatus.dueToday;
                } else if (isCalendarDueSoon ||
                    statusStr == 'dueSoon' ||
                    statusStr == 'due_soon') {
                  assignedStatus = TaskStatus.dueSoon;
                } else {
                  assignedStatus = TaskStatus.toDo;
                }

                result.add(
                  TaskItem(
                    title: t['title']?.toString() ?? 'Task',
                    subtitle: '$className · ${estHours}h',
                    status: assignedStatus,
                    classId: doc.id,
                    taskId: t['id']?.toString() ?? '',
                  ),
                );
              }
            }
          }
          return result;
        });
  }

  final Set<String> _completingTasks = {};

  Set<String> get completingTasks => _completingTasks;

  Future<void> toggleTaskCompletion(String classId, String taskId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _completingTasks.add(taskId);
    notifyListeners();

    try {
      final docRef = _db.collection('enrollments').doc(classId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        _completingTasks.remove(taskId);
        notifyListeners();
        return;
      }

      final List<dynamic> tasks = List.from(docSnap.data()?['tasksList'] ?? []);
      final index = tasks.indexWhere((t) => t['id'].toString() == taskId);
      if (index == -1) {
        _completingTasks.remove(taskId);
        notifyListeners();
        return;
      }

      final currentStatus = tasks[index]['status']?.toString() ?? '';
      final isCompleting =
          currentStatus != 'completed' && currentStatus != 'done';
      final String newStatus = isCompleting ? 'completed' : 'toDo';
      final int delta = isCompleting ? 1 : -1;

      tasks[index] = {...tasks[index], 'status': newStatus};

      await docRef.update({
        'tasksList': tasks,
        'completedTasks': FieldValue.increment(delta),
        'pendingTasks': FieldValue.increment(-delta),
      });
    } catch (e) {
      debugPrint('toggleTaskCompletion error: $e');
    } finally {
      _completingTasks.remove(taskId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _enrollmentSubscription?.cancel();
    _scheduleTimer?.cancel();
    super.dispose();
  }
}
