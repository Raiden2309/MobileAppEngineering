import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';

import 'dashboard_provider.dart';
import 'student_settings_provider.dart';

class TasksProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  TasksProvider({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Centralized cache link
  LocalCacheService? _cacheEngine;
  StudentDashboardProvider? _dashboardProvider;

  void updateCacheEngine(LocalCacheService engine) {
    _cacheEngine = engine;
  }

  void updateDashboardProvider(StudentDashboardProvider dash) {
    _dashboardProvider = dash;
  }

  VoidCallback? _subjectsRefreshHook;

  void registerSubjectsRefreshHook(StudentSettingsProvider settings) {
    _subjectsRefreshHook ??= () {
      if (settings.currentSemesterId != null) {
        listenToLiveTasks(semester: settings.currentSemesterId!);
      }
    };
    settings.addSubjectUpdatedListener(_subjectsRefreshHook!);
  }

  List<SubjectGroup> groups = [];
  String activeFilter = 'all';

  int get totalTasksCount =>
      groups.fold(0, (total, g) => total + g.tasks.length);
  int get pendingTasksCount => groups.fold(
    0,
    (total, g) =>
        total + g.tasks.where((t) => t.status != TaskStatus.completed).length,
  );
  bool loading = false;
  bool isOffline = false;
  String? error;
  StreamSubscription? _tasksSubscription;
  String? _subscribedUid;
  String? _currentSemester;
  String? get currentSemester => _currentSemester;

  String _cacheKey(String uid) => 'tasks_cache_$uid';

  Future<bool> _loadFromCache() async {
    final uid = _auth.currentUser?.uid ?? 'offline_student';
    try {
      final decoded = await _cacheEngine?.read(_cacheKey(uid));

      if (decoded is List && decoded.isNotEmpty) {
        groups = decoded.map((g) {
          final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
            g as Map,
          );
          final List<dynamic> rawTasks =
              itemMap['tasks'] ?? itemMap['tasksList'] ?? [];

          return SubjectGroup(
            id: itemMap['id']?.toString() ?? '',
            name:
                itemMap['name'] ??
                itemMap['classId']?.toString() ??
                'Unknown Subject',
            colorKey: itemMap['colorKey']?.toString() ?? 'blue',
            tasks: rawTasks
                .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
                .toList(),
          );
        }).toList();
        return true;
      }

      final settingsSubj = await _cacheEngine?.read('settings_subjects');
      if (settingsSubj is List && settingsSubj.isNotEmpty) {
        groups = settingsSubj.map((s) {
          final sMap = Map<String, dynamic>.from(s as Map);
          final String name =
              sMap['name'] ?? sMap['classId'] ?? 'Unknown Subject';

          final safeClassId = name
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
              .replaceAll(RegExp(r'[\s-]'), '_');
          final targetGroupId = '${uid}_$safeClassId';

          return SubjectGroup(
            id: sMap['id']?.toString() ?? targetGroupId,
            name: name,
            colorKey: sMap['colorKey']?.toString() ?? 'blue',
            tasks: const [],
          );
        }).toList();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Tasks read cache error: $e');
      return false;
    }
  }

  Future<void> _saveToCache() async {
    final uid = _auth.currentUser?.uid ?? 'offline_student';
    try {
      final encoded = groups.map((g) => g.toJson()).toList();
      await _cacheEngine?.write(_cacheKey(uid), encoded);
    } catch (e) {
      debugPrint('Tasks save cache error: $e');
    }
  }

  void listenToLiveTasks({required String semester}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Avoid churning the Firestore subscription when re-invoked with the
    // same user + semester (e.g. proxy-provider updates on dependency
    // changes). The live snapshot already reflects remote changes.
    if (_tasksSubscription != null &&
        _subscribedUid == uid &&
        _currentSemester == semester) {
      return;
    }
    _subscribedUid = uid;
    _currentSemester = semester;

    _cacheEngine?.delete(_cacheKey(uid));

    loading = true;
    notifyListeners();

    _loadFromCache().then((hasCached) {
      if (hasCached) {
        loading = false;
        notifyListeners();
      }
    });

    _tasksSubscription?.cancel();

    // FIXED: Query broadly by studentId to prevent missing field drops, then filter locally
    _tasksSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isEmpty) {
              _loadFromCache().then((hasCached) {
                loading = false;
                isOffline = hasCached;
                notifyListeners();
              });
              return;
            }

            // Filter by semester locally in Dart to avoid strict query drops
            final validDocs = snapshot.docs.where((doc) {
              final data = doc.data();
              final String docSemester =
                  data['semester']?.toString() ??
                  data['semester_id']?.toString() ??
                  '';

              // Fallback: If no semester is attached yet, let it show up to prevent data loss
              if (docSemester.isEmpty) return true;
              return docSemester == semester;
            }).toList();

            groups = validDocs.map((doc) {
              final data = doc.data();
              final List<dynamic> rawTasks = data['tasksList'] ?? [];

              // FIXED: Uniform fallback normalization mapping across lecturer and student layers
              final String resolvedSubjectName =
                  data['classId']?.toString() ??
                  data['name']?.toString() ??
                  data['subjectName']?.toString() ??
                  'Unknown Subject';

              return SubjectGroup(
                id: doc.id,
                name: resolvedSubjectName,
                colorKey: data['colorHex'] ?? data['colorKey'] ?? 'blue',
                tasks: rawTasks.map((t) {
                  final taskMap = Map<String, dynamic>.from(t as Map);

                  final parsedTask = Task.fromJson({
                    'id':
                        taskMap['id']?.toString() ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': taskMap['title'] ?? 'Untitled Assignment',
                    'estimatedHours':
                        double.tryParse(
                          (taskMap['estimatedHours'] ??
                                  taskMap['estimated_hours'] ??
                                  '1.0')
                              .toString(),
                        ) ??
                        1.0,
                    'status': taskMap['status'] ?? 'toDo',
                    'dueDate': taskMap['dueDate'] ?? taskMap['due_date'],
                  });

                  final liveStatus = _getLiveStatus(parsedTask);
                  return liveStatus != parsedTask.status
                      ? parsedTask.copyWith(status: liveStatus)
                      : parsedTask;
                }).toList(),
              );
            }).toList();

            loading = false;
            isOffline = false;
            _saveToCache();
            notifyListeners();
          },
          onError: (e) {
            error = e.toString();
            loading = false;
            _loadFromCache().then((hasCached) {
              isOffline = hasCached;
              notifyListeners();
            });
          },
        );
  }

  // ── RESTORED REQUIREMENT CONTROLLER OPERATIONS METHODS ─────────────────────

  void switchSemester(String semester) {
    listenToLiveTasks(semester: semester);
  }

  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  List<Task> filteredTasks(List<Task> tasks) {
    if (activeFilter == 'all') return tasks;
    return tasks.where((t) {
      final liveStatus = _getLiveStatus(t);

      if (activeFilter == 'completed') {
        return liveStatus == TaskStatus.completed;
      }
      if (activeFilter == 'inProgress') {
        return liveStatus == TaskStatus.inProgress;
      }
      if (activeFilter == 'dueSoon') return liveStatus == TaskStatus.dueSoon;
      if (activeFilter == 'dueToday') return liveStatus == TaskStatus.dueToday;
      if (activeFilter == 'toDo') {
        return liveStatus == TaskStatus.toDo ||
            liveStatus == TaskStatus.upcoming;
      }

      return liveStatus.name == activeFilter;
    }).toList();
  }

  Future<void> fetch() async =>
      listenToLiveTasks(semester: _currentSemester ?? '');

  void load() => listenToLiveTasks(semester: _currentSemester ?? '');

  Future<void> addTask({
    required String groupId,
    required String title,
    required double estimatedHours,
    required TaskStatus status,
    DateTime? dueDate,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      estimatedHours: estimatedHours,
      status: status,
      dueDate: dueDate,
    );

    final gIdx = groups.indexWhere((g) => g.id == groupId);
    if (gIdx == -1) return;

    groups[gIdx].tasks.add(task);
    _saveToCache();
    notifyListeners();

    try {
      final docRef = _db.collection('enrollments').doc(groupId);
      await docRef.update({
        'tasksList': FieldValue.arrayUnion([task.toJson()]),
        'pendingTasks': FieldValue.increment(1),
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updatedTask = task;

    final gIdx = groups.indexWhere(
      (g) => g.tasks.any((t) => t.id == updatedTask.id),
    );
    if (gIdx == -1) return;

    final tIdx = groups[gIdx].tasks.indexWhere((t) => t.id == updatedTask.id);
    groups[gIdx].tasks[tIdx] = updatedTask;

    _saveToCache();
    notifyListeners();

    _dashboardProvider?.listenToLiveDashboardStats();

    try {
      final docRef = _db.collection('enrollments').doc(groups[gIdx].id);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final List<dynamic> raw = List.from(docSnap.data()?['tasksList'] ?? []);
      final idx = raw.indexWhere((t) => t['id'] == updatedTask.id);
      if (idx == -1) return;

      final oldStatus = (raw[idx] as Map)['status']?.toString() ?? '';
      final newStatus = updatedTask.status.name;

      raw[idx] = updatedTask.toJson();

      final Map<String, dynamic> counters = {'tasksList': raw};
      if (oldStatus != 'completed' && newStatus == 'completed') {
        counters['completedTasks'] = FieldValue.increment(1);
        counters['pendingTasks'] = FieldValue.increment(-1);
      } else if (oldStatus == 'completed' && newStatus != 'completed') {
        counters['completedTasks'] = FieldValue.increment(-1);
        counters['pendingTasks'] = FieldValue.increment(1);
      }

      await docRef.update(counters);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    final matchGroup = groups.firstWhere(
      (g) => g.tasks.any((t) => t.id == task.id),
    );
    final docRef = _db.collection('enrollments').doc(matchGroup.id);

    final gIdx = groups.indexOf(matchGroup);
    groups[gIdx].tasks.removeWhere((t) => t.id == task.id);
    _saveToCache();
    notifyListeners();

    _dashboardProvider?.listenToLiveDashboardStats();

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final List<dynamic> currentTasks = List.from(
          snapshot.data()!['tasksList'] ?? [],
        );
        dynamic taskToRemove;
        for (var t in currentTasks) {
          if (t['id'] == task.id) {
            taskToRemove = t;
            break;
          }
        }

        if (taskToRemove != null) {
          final oldStatus = taskToRemove['status'];
          currentTasks.remove(taskToRemove);
          transaction.update(docRef, {
            'tasksList': currentTasks,
            'pendingTasks': FieldValue.increment(
              oldStatus != 'completed' ? -1 : 0,
            ),
            'completedTasks': FieldValue.increment(
              oldStatus == 'completed' ? -1 : 0,
            ),
          });
        }
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveCache() => _saveToCache();

  void reset() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _subscribedUid = null;
    _currentSemester = null;
    groups = [];
    activeFilter = 'all';
    loading = false;
    isOffline = false;
    error = null;
    notifyListeners();
  }

  TaskStatus _getLiveStatus(Task task) {
    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.inProgress) {
      return task.status;
    }
    if (task.dueDate == null) return task.status;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    if (taskDate.isBefore(todayDate)) {
      return TaskStatus.overdue;
    }
    if (taskDate.isAtSameMomentAs(todayDate)) {
      return TaskStatus.dueToday;
    }
    final daysDifference = taskDate.difference(todayDate).inDays;
    if (daysDifference <= 3) {
      return TaskStatus.dueSoon;
    }
    return task.status;
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
