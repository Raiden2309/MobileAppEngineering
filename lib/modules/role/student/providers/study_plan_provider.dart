import 'package:flutter/material.dart';
import '../models/study_plan_model.dart';
import '../../../../shared/services/api_service.dart';

class StudyPlanProvider with ChangeNotifier {
  WeekPlan? plan;
  bool loading = false;
  String? error;

  void loadMock() {
    plan = WeekPlan.mockData();
    notifyListeners();
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await ApiService.get('/study-plan');
      plan = WeekPlan.fromJson(json);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setPlan(WeekPlan newPlan) {
    plan = newPlan;
    notifyListeners();
  }

  void updateBlock(int dayIndex, int blockIndex, StudyBlock updated) {
    if (plan == null) return;
    final days = List<DayPlan>.from(plan!.days);
    final blocks = List<StudyBlock>.from(days[dayIndex].blocks);
    blocks[blockIndex] = updated;
    days[dayIndex] = DayPlan(date: days[dayIndex].date, blocks: blocks);
    plan = WeekPlan(days: days, lastUpdated: DateTime.now());
    notifyListeners();
  }
}