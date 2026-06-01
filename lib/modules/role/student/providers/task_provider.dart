import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';

class TasksProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Centralized cache link
  LocalCacheService? _cacheEngine;

  void updateCacheEngine(LocalCacheService engine) {
    _cacheEngine = engine;
  }

  List<SubjectGroup> groups = [];
  String activeFilter = 'all';
  bool loading = false;
  bool isOffline = false;
  String? error;
  StreamSubscription? _tasksSubscription;
  String? _currentSemester;
  String? get currentSemester => _currentSemester;

  // FIXED: Consistent uniform key mapping matching your dynamic controller targets
  String _cacheKey(String uid) => 'tasks_cache_$uid';

  Future<bool> _loadFromCache() async {
    final uid = _auth.currentUser?.uid ?? 'offline_student';
    try {
      final decoded = await _cacheEngine?.read(_cacheKey(uid));

      // 1. First scenario: Explicit local tasks list found in device memory
      if (decoded is List && decoded.isNotEmpty) {
        groups = decoded.map((g) {
          final Map<String, dynamic> itemMap = Map<String, dynamic>.from(g as Map);

          // FIXED: Safeguard parsing to evaluate both local 'tasks' export key and server 'tasksList' key
          final List<dynamic> rawTasks = itemMap['tasks'] ?? itemMap['tasksList'] ?? [];

          return SubjectGroup(
            id: itemMap['id']?.toString() ?? '',
            name: itemMap['name'] ?? itemMap['classId']?.toString() ?? 'Unknown Subject',
            colorKey: itemMap['colorKey']?.toString() ?? 'blue',
            tasks: rawTasks.map((t) => Task.fromJson(Map<String, dynamic>.from(t))).toList(),
          );
        }).toList();
        return true;
      }

      // 2. Offline Fallback scenario: If user tasks are totally un-cached,
      // dynamically pull from your active local user cache key signature
      final settingsSubj = await _cacheEngine?.read('settings_subjects');
      if (settingsSubj is List && settingsSubj.isNotEmpty) {
        groups = settingsSubj.map((s) {
          final sMap = Map<String, dynamic>.from(s as Map);
          final String name = sMap['name'] ?? sMap['classId'] ?? 'Unknown Subject';

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
    _currentSemester = semester;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

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
    _tasksSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .where('semester', isEqualTo: semester)
        .snapshots()
        .listen((snapshot) {

      // If network yields nothing or is offline, do NOT clear out the dropdown/view lists!
      if (snapshot.docs.isEmpty) {
        _loadFromCache().then((hasCached) {
          loading = false;
          isOffline = hasCached;
          notifyListeners();
        });
        return;
      }

      groups = snapshot.docs.map((doc) {
        final data = doc.data();
        final List<dynamic> rawTasks = data['tasksList'] ?? [];
        return SubjectGroup(
          id: doc.id,
          name: data['name']?.toString() ??
              data['subjectName']?.toString() ??
              data['classId']?.toString() ??
              'Unknown Subject',
          colorKey: data['colorKey'] ?? 'blue',
          tasks: rawTasks.map((t) => Task.fromJson(Map<String, dynamic>.from(t))).toList(),
        );
      }).toList();

      loading = false;
      isOffline = false;
      _saveToCache(); // Keeps local storage fresh
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      _loadFromCache().then((hasCached) {
        isOffline = hasCached;
        notifyListeners();
      });
    });
  }

  void switchSemester(String semester) {
    listenToLiveTasks(semester: semester);
  }

  Future<void> deleteTask(Task task) async {
    final matchGroup = groups.firstWhere((g) => g.tasks.any((t) => t.id == task.id));
    final docRef = _db.collection('enrollments').doc(matchGroup.id);

    final gIdx = groups.indexOf(matchGroup);
    groups[gIdx].tasks.removeWhere((t) => t.id == task.id);
    _saveToCache();
    notifyListeners();

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final List<dynamic> currentTasks = List.from(snapshot.data()!['tasksList'] ?? []);
        dynamic taskToRemove;
        for (var t in currentTasks) {
          if (t['id'] == task.id) { taskToRemove = t; break; }
        }

        if (taskToRemove != null) {
          final oldStatus = taskToRemove['status'];
          currentTasks.remove(taskToRemove);
          transaction.update(docRef, {
            'tasksList':      currentTasks,
            'pendingTasks':   FieldValue.increment(oldStatus != 'completed' ? -1 : 0),
            'completedTasks': FieldValue.increment(oldStatus == 'completed' ? -1 : 0),
          });
        }
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  List<Task> filteredTasks(List<Task> tasks) {
    if (activeFilter == 'all') return tasks;
    return tasks.where((t) => t.status.name == activeFilter).toList();
  }

  Future<void> fetch() async => listenToLiveTasks(semester: _currentSemester ?? '');

  void loadMock() => listenToLiveTasks(semester: _currentSemester ?? '');

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
      id:             DateTime.now().millisecondsSinceEpoch.toString(),
      title:          title,
      estimatedHours: estimatedHours,
      status:         status,
      dueDate:        dueDate,
    );

    final gIdx = groups.indexWhere((g) => g.id == groupId);
    if (gIdx == -1) return;

    groups[gIdx].tasks.add(task);
    _saveToCache();
    notifyListeners();

    try {
      final docRef = _db.collection('enrollments').doc(groupId);
      await docRef.update({
        'tasksList':    FieldValue.arrayUnion([task.toJson()]),
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

    final gIdx = groups.indexWhere((g) => g.tasks.any((t) => t.id == task.id));
    if (gIdx == -1) return;

    final tIdx = groups[gIdx].tasks.indexWhere((t) => t.id == task.id);
    groups[gIdx].tasks[tIdx] = task;
    _saveToCache();
    notifyListeners();

    try {
      final docRef  = _db.collection('enrollments').doc(groups[gIdx].id);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final List<dynamic> raw = List.from(docSnap.data()?['tasksList'] ?? []);
      final idx = raw.indexWhere((t) => t['id'] == task.id);
      if (idx == -1) return;

      raw[idx] = task.toJson();
      await docRef.update({'tasksList': raw});
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveCache() => _saveToCache();

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}