import 'package:flutter/material.dart';
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
}