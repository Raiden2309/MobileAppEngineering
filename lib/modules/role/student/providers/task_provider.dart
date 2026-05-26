import 'package:flutter/material.dart';
import '../models/app_enums.dart';
import '../models/tasks_model.dart';
import '../../../../shared/services/api_service.dart';

class TasksProvider with ChangeNotifier {
  List<SubjectGroup> groups = [];
  String activeFilter = 'all';
  bool loading = false;
  String? error;

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

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await ApiService.get('/tasks');
      groups = (json['subject_groups'] as List<dynamic>)
          .map((g) => SubjectGroup.fromJson(g))
          .toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String groupId,
    required String title,
    required double estimatedHours,
    required TaskStatus status,
  }) async {
    try {
      final json = await ApiService.post('/tasks', {
        'group_id':        groupId,
        'title':           title,
        'estimated_hours': estimatedHours,
        'status':          status.name,
      });
      final newTask = Task.fromJson(json);
      groups = groups.map((g) {
        if (g.id != groupId) return g;
        return g.copyWith(tasks: [...g.tasks, newTask]);
      }).toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await ApiService.patch('/tasks/${task.id}', {
        'title':           task.title,
        'estimated_hours': task.estimatedHours,
        'status':          task.status.name,
      });
      groups = groups.map((g) {
        final match = g.tasks.any((t) => t.id == task.id);
        if (!match) return g;
        return g.copyWith(
          tasks: g.tasks.map((t) => t.id == task.id ? task : t).toList(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await ApiService.delete('/tasks/${task.id}');
      groups = groups.map((g) {
        final match = g.tasks.any((t) => t.id == task.id);
        if (!match) return g;
        return g.copyWith(
          tasks: g.tasks.where((t) => t.id != task.id).toList(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}