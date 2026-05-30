import 'package:flutter/material.dart';
import '../models/app_enums.dart';
import '../models/study_plan_model.dart';
import '../providers/study_plan_provider.dart';

class StudyPlanController extends ChangeNotifier {
  final StudyPlanProvider provider;

  int selectedDay = 0;

  StudyPlanController(this.provider) {
    provider.addListener(onProviderUpdate);
  }

  // Provider passthrough

  WeekPlan? get plan => provider.plan;
  bool get loading => provider.loading;
  String? get error => provider.error;
  bool get hasData => plan != null;

  // Day selection

  int get selectedDayIndex => selectedDay;

  DayPlan? get selectedDayPlan =>
      hasData ? plan!.days[selectedDayIndex] : null;

  void selectDay(int index) {
    if (!hasData) return;
    assert(index >= 0 && index < plan!.days.length);
    selectedDay = index;
    notifyListeners();
  }

  /// Selects today's day automatically. Falls back to index 0 if not found.
  void selectToday() {
    if (!hasData) return;
    final now = DateTime.now();
    final index = plan!.days.indexWhere(
          (d) =>
      d.date.day == now.day &&
          d.date.month == now.month &&
          d.date.year == now.year,
    );
    selectedDay = index < 0 ? 0 : index;
    notifyListeners();
  }

  // Derived getters

  List<DayPlan> get days => plan?.days ?? [];

  String get lastUpdatedLabel {
    if (plan == null) return '';
    final now = DateTime.now();
    final diff = now.difference(plan!.lastUpdated);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inHours < 1) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Updated today';
    return 'Updated ${diff.inDays}d ago';
  }

  /// Returns the number of study blocks (non-blocked, non-break) for the selected day.
  int get selectedDayStudyBlockCount =>
      selectedDayPlan?.blocks
          .where((b) => b.type == BlockType.study)
          .length ??
          0;

  /// Returns total study minutes for the selected day.
  int get selectedDayTotalMinutes =>
      selectedDayPlan?.blocks
          .where((b) => b.type == BlockType.study)
          .fold(0, (sum, b) => sum! + b.durationMinutes) ??
          0;

  // Data loading

  Future<void> init() async {
    // Starts the real-time background enrollment task array mapping listener
    provider.listenToLiveStudyPlan();
    selectToday();
  }

  Future<void> fetch() async {
    await provider.fetch();
    selectToday();
  }

  void loadMock() {
    provider.loadMock();
    selectToday();
  }

  /// Regenerates the week plan with fresh mock data (mirrors the view's onTap logic).
  void regenerate() {
    provider.generateAiWeeklyPlan();
    selectToday();
  }

  Future<void> refresh() async {
    await provider.fetch();
    selectToday();
  }

  // Block updates

  void updateBlock(int dayIndex, int blockIndex, StudyBlock updated) {
    provider.updateBlock(dayIndex, blockIndex, updated);
  }

  void updateSelectedDayBlock(int blockIndex, StudyBlock updated) {
    provider.updateBlock(selectedDayIndex, blockIndex, updated);
  }

  // Provider sync

  void onProviderUpdate() {
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    provider.removeListener(onProviderUpdate);
    super.dispose();
  }
}