import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class AlertProvider extends ChangeNotifier {
  String selectedFilter = 'all';

  final List<AlertModel> _alerts = [
    AlertModel(
      type: 'burnout',
      emoji: '🔥',
      title: 'Burnout Risk — Amirul Haikal',
      meta: 'CT124 System Proposal · Studied 6+ hrs/day for 4 days, task completion dropped to 30%',
    ),
    AlertModel(
      type: 'burnout',
      emoji: '🔥',
      title: 'Burnout Risk — Nurul Farhana',
      meta: 'RM302 Research Methods · High workload pattern detected, 2 tasks overdue',
    ),
    AlertModel(
      type: 'behind',
      emoji: '⚠️',
      title: 'Falling Behind — Haziq Zulkifli',
      meta: 'CT124 System Proposal · 4 tasks overdue, no activity in 3 days',
    ),
    AlertModel(
      type: 'behind',
      emoji: '⚠️',
      title: 'Falling Behind — Izzati Roslan',
      meta: 'MOB401 Mobile Development · Completion rate dropped from 70% to 35% this week',
    ),
    AlertModel(
      type: 'behind',
      emoji: '📋',
      title: 'Low Engagement — Farid Iskandar',
      meta: 'RM302 Research Methods · Only 2 of 5 tasks started this semester',
    ),
    AlertModel(
      type: 'read',
      emoji: '🔥',
      title: 'Burnout Risk — Siti Hajar · Resolved',
      meta: 'CT124 · Marked as reviewed 2 days ago',
      read: true,
    ),
  ];

  List<AlertModel> get filtered {
    if (selectedFilter == 'all') return _alerts;
    if (selectedFilter == 'read') return _alerts.where((a) => a.read).toList();
    return _alerts.where((a) => a.type == selectedFilter && !a.read).toList();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void markAsRead(AlertModel alert) {
    final index = _alerts.indexOf(alert);
    if (index == -1) return;
    _alerts[index] = _alerts[index].copyWith(read: true);
    notifyListeners();
  }
}