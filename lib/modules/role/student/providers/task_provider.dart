import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';

class TasksProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SubjectGroup> groups = [];
  String activeFilter = 'all';
  bool loading = false;
  String? error;
  StreamSubscription? _tasksSubscription;

  // Real-time Firestore document synchronizer pipeline
  void listenToLiveTasks() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    loading = true;
    notifyListeners();

    _tasksSubscription?.cancel();
    _tasksSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {

      // Fixed: Explicit type casting map sequence to create a clean List<SubjectGroup>
      groups = snapshot.docs.map((doc) {
        final dataMap = doc.data();
        final String subjectNameStr = dataMap['classId']?.toString() ?? 'General';

        final int liveCompleted = (dataMap['completedTasks'] as num? ?? 0).toInt();
        final int livePending = (dataMap['pendingTasks'] as num? ?? 0).toInt();

        // Extract the tasks array map collection hosted inside the enrollment doc
        final List<dynamic> rawTasksList = dataMap['tasksList'] ?? [];
        final parsedTasks = rawTasksList.map((t) => Task.fromJson(Map<String, dynamic>.from(t))).toList();

        // Fixed: Pass named parameter properties into your newly reinstated class fields
        return SubjectGroup(
          id: doc.id,
          name: subjectNameStr, // Feeds to SubjectGroup.name
          colorKey: 'blue',
          totalTasks: liveCompleted + livePending,
          completedTasks: liveCompleted,
          tasks: parsedTasks,
        );
      }).toList();

      loading = false;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  // Fallback signature mapping placeholder methods to fix controller calls
  Future<void> fetch() async {
    listenToLiveTasks();
  }

  void loadMock() {
    groups = SubjectGroup.mockData();
    notifyListeners();
  }

  List<Task> filteredTasks(List<Task> tasks) {
    if (activeFilter == 'all') return tasks;
    return tasks.where((t) => t.status.name == activeFilter).toList();
  }

  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  // Save new task records directly to Firestore array collections
  Future<void> addTask({
    required String groupId,
    required String title,
    required double estimatedHours,
    required TaskStatus status,
  }) async {
    try {
      final docRef = _db.collection('enrollments').doc(groupId);
      final newTaskMap = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'estimated_hours': estimatedHours,
        'status': status.name,
      };

      await docRef.update({
        'tasksList': FieldValue.arrayUnion([newTaskMap]),
        'pendingTasks': FieldValue.increment(status != TaskStatus.completed ? 1 : 0),
        'completedTasks': FieldValue.increment(status == TaskStatus.completed ? 1 : 0),
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing task item and adjust status aggregates dynamically
  Future<void> updateTask(Task task) async {
    final matchGroup = groups.firstWhere((g) => g.tasks.any((t) => t.id == task.id));
    final docRef = _db.collection('enrollments').doc(matchGroup.id);

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final List<dynamic> currentTasks = List.from(data['tasksList'] ?? []);

        int pendingDelta = 0;
        int completedDelta = 0;

        for (var i = 0; i < currentTasks.length; i++) {
          if (currentTasks[i]['id'] == task.id) {
            final oldStatus = currentTasks[i]['status'];

            if (oldStatus == 'completed' && task.status.name != 'completed') {
              completedDelta = -1; pendingDelta = 1;
            } else if (oldStatus != 'completed' && task.status.name == 'completed') {
              completedDelta = 1; pendingDelta = -1;
            }

            // Automatically handle the start clock timestamp rules ---
            String? startedAtStr = currentTasks[i]['started_at'];
            if (task.status.name == 'inProgress' && oldStatus != 'inProgress') {
              // Task just started running right now
              startedAtStr = DateTime.now().toIso8601String();
            } else if (task.status.name != 'inProgress') {
              // Task moved out of in-progress; clear the timer stamp
              startedAtStr = null;
            }

            currentTasks[i]['title'] = task.title;
            currentTasks[i]['estimated_hours'] = task.estimatedHours;
            currentTasks[i]['status'] = task.status.name;
            currentTasks[i]['started_at'] = startedAtStr; // Save back to document map
            break;
          }
        }

        transaction.update(docRef, {
          'tasksList': currentTasks,
          'pendingTasks': FieldValue.increment(pendingDelta),
          'completedTasks': FieldValue.increment(completedDelta),
        });
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Fixed: Added missing deleteTask implementation required by TaskController
  Future<void> deleteTask(Task task) async {
    try {
      final matchGroup = groups.firstWhere((g) => g.tasks.any((t) => t.id == task.id));
      final docRef = _db.collection('enrollments').doc(matchGroup.id);

      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final List<dynamic> currentTasks = List.from(data['tasksList'] ?? []);

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
            'pendingTasks': FieldValue.increment(oldStatus != 'completed' ? -1 : 0),
            'completedTasks': FieldValue.increment(oldStatus == 'completed' ? -1 : 0),
          });
        }
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}