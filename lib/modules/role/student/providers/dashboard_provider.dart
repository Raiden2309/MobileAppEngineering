import 'package:flutter/material.dart';
import '../../../../shared/services/api_service.dart';
import '../models/dashboard_models.dart';

class DashboardProvider with ChangeNotifier {
  DashboardModel? data;
  bool loading = false;
  String? error;

  // remember to remove mock data
  void loadMock() {
    data = DashboardModel.mockData();
    notifyListeners();
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await ApiService.get('/dashboard_student');
      data = DashboardModel.fromJson(json);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void toggleTask(int index) {
    if (data == null) return;
    final updated = List<TaskItem>.from(data!.todayTasks);
    updated[index] = updated[index].copyWith(checked: !updated[index].checked);
    data = DashboardModel(
      summary:      data!.summary,
      stats:        data!.stats,
      currentTask:  data!.currentTask,
      workloadPlan: data!.workloadPlan,
      todayTasks:   updated,
    );
    notifyListeners();
  }
}