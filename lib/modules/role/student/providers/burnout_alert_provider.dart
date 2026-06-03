import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/burnout_alert_model.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';

class BurnoutAlertProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Centralized cache link
  LocalCacheService? _cacheEngine;

  void updateCacheEngine(LocalCacheService engine) {
    _cacheEngine = engine;
  }

  BurnoutAlertModel? alert;
  bool loading = false;
  bool isOffline = false;
  String? error;
  StreamSubscription? _burnoutSubscription;

  String _cacheKey(String uid) => 'burnout_alert_cache_$uid';

  Future<void> _saveToCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || alert == null) return;
    try {
      final encoded = jsonEncode({
        'type':               alert!.type.name,
        'title':              alert!.title,
        'description':        alert!.description,
        'hoursStudied':       alert!.hoursStudied,
        'workloadProgress':   alert!.workloadProgress,
        'workloadLevel':      alert!.workloadLevel.name,
        'primaryActionLabel': alert!.primaryActionLabel,
        'dismissLabel':       alert!.dismissLabel,
      });
      await _cacheEngine?.write(_cacheKey(uid), encoded);
    } catch (e) {
      debugPrint('Burnout write cache error: $e');
    }
  }

  Future<bool> _loadFromCache() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final decoded = await _cacheEngine?.read(_cacheKey(uid));
      if (decoded == null) return false;

      final Map<String, dynamic> map = decoded is String ? jsonDecode(decoded) : Map<String, dynamic>.from(decoded);
      alert = BurnoutAlertModel(
        type:               BurnoutAlertType.values.firstWhere((e) => e.name == map['type'], orElse: () => BurnoutAlertType.allGood),
        title:              map['title'] ?? '',
        description:        map['description'] ?? '',
        hoursStudied:       (map['hoursStudied'] as num? ?? 0.0).toDouble(),
        workloadProgress:   (map['workloadProgress'] as num? ?? 0.0).toDouble(),
        workloadLevel:      WorkloadLevel.values.firstWhere((e) => e.name == map['workloadLevel'], orElse: () => WorkloadLevel.low),
        primaryActionLabel: map['primaryActionLabel'] ?? '',
        dismissLabel:       map['dismissLabel'] ?? '',
      );
      return true;
    } catch (e) {
      debugPrint('Burnout read cache error: $e');
      return false;
    }
  }

  int _totalTasksCount = 10;

  void updateTotalTasks(int total) {
    _totalTasksCount = total.clamp(1, 999);
  }

  void listenToLiveBurnoutMetrics() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    _loadFromCache().then((hasCached) {
      if (hasCached) {
        loading = false;
        notifyListeners();
      }
    });

    _burnoutSubscription?.cancel();
    _burnoutSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      double accumulatedStudyHours    = 0.0;
      int totalPendingTasksCount      = 0;
      double extremeBurnoutPeakIndex  = 0.0;

      for (var doc in snapshot.docs) {
        final payload = doc.data();
        accumulatedStudyHours   += (payload['weeklyStudyHours'] as num? ?? 0.0).toDouble();
        totalPendingTasksCount  += (payload['pendingTasks']     as num? ?? 0).toInt();

        final double specificIndex = (payload['burnoutIndex'] as num? ?? 0.0).toDouble();
        if (specificIndex > extremeBurnoutPeakIndex) {
          extremeBurnoutPeakIndex = specificIndex;
        }
      }

      BurnoutAlertType calculatedType;
      WorkloadLevel calculatedLevel;
      String titleText;
      String primaryBtnLabel;
      String staticAdviceMessage;

      final double pendingTasksRatio = (totalPendingTasksCount / _totalTasksCount.toDouble()).clamp(0.0, 1.0);
      final double compositeScore = (extremeBurnoutPeakIndex * 0.55) +
          (pendingTasksRatio * 0.25) +
          ((accumulatedStudyHours / 40).clamp(0.0, 1.0) * 0.20);

      if (compositeScore > 0.75 || extremeBurnoutPeakIndex > 0.75) {
        calculatedType = BurnoutAlertType.overload;
        calculatedLevel = WorkloadLevel.critical;
        titleText = "Critical Burnout Risk!";
        primaryBtnLabel = "Reschedule Workload";
        staticAdviceMessage = "Your concurrent workload across enrolled tracks has crossed into the red zone. We strongly advise pausing secondary targets, spacing pending micro-tasks, and prioritizing sleep tonight.";
      } else if (compositeScore > 0.5 || extremeBurnoutPeakIndex > 0.45 || accumulatedStudyHours > 35) {
        calculatedType = BurnoutAlertType.burnout;
        calculatedLevel = WorkloadLevel.high;
        titleText = "Burnout Alert";
        primaryBtnLabel = "Take a Break";
        staticAdviceMessage = "You have a heavy number of pending tasks building up. Consider breaking them into smaller sessions and clearing your backlog gradually to avoid hitting a wall.";
      } else if (compositeScore > 0.25 || totalPendingTasksCount > 3) {
        calculatedType = BurnoutAlertType.warning;
        calculatedLevel = WorkloadLevel.moderate;
        titleText = "Approaching Burnout";
        primaryBtnLabel = "Review Study Blocks";
        staticAdviceMessage = "Pacing indicators suggest elevated study strain on your tracking boards. Pacing your study sessions out evenly this week will keep you comfortable and on track.";
      } else {
        calculatedType = BurnoutAlertType.allGood;
        calculatedLevel = WorkloadLevel.low;
        titleText = "Looking Great!";
        primaryBtnLabel = "View Dashboard";
        staticAdviceMessage = "Your assignment pipeline is completely balanced and clear. You are maintaining an excellent healthy workflow—keep up this incredible momentum!";
      }

      alert = BurnoutAlertModel(
        type: calculatedType,
        title: titleText,
        description: staticAdviceMessage,
        hoursStudied: accumulatedStudyHours,
        workloadProgress: compositeScore.clamp(0.0, 1.0),
        workloadLevel: calculatedLevel,
        primaryActionLabel: primaryBtnLabel,
        dismissLabel: 'Dismiss warning',
      );

      loading = false;
      isOffline = false;
      _saveToCache();
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

  void evaluateSession({required double hoursStudied}) {}

  void dismiss() {
    alert = null;
    notifyListeners();
  }

  void clear() {
    alert = null;
    error = null;
    loading = false;
    notifyListeners();
  }

  Future<void> fetch() async {
    listenToLiveBurnoutMetrics();
  }

  void loadMock() => listenToLiveBurnoutMetrics();

  @override
  void dispose() {
    _burnoutSubscription?.cancel();
    super.dispose();
  }
}