import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_enums.dart';
import '../models/burnout_alert_model.dart';

class BurnoutAlertProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BurnoutAlertModel? alert;
  bool loading = false;
  String? error;
  StreamSubscription? _burnoutSubscription;

  /// Listens to live task metrics to determine real-time student workload standing
  void listenToLiveBurnoutMetrics() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (alert == null) {
      loading = true;
      notifyListeners();
    }

    _burnoutSubscription?.cancel();
    _burnoutSubscription = _db
        .collection('enrollments')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {

      int totalPendingTasksCount = 0;
      double accumulatedStudyHours = 0.0;

      for (var doc in snapshot.docs) {
        final dataMap = doc.data();
        final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];
        final pendingTasks = rawTasks.where((t) => t['status'] != 'completed').toList();

        if (pendingTasks.isNotEmpty) {
          totalPendingTasksCount += pendingTasks.length;
          for (var task in pendingTasks) {
            accumulatedStudyHours += (task['estimated_hours'] as num? ?? 1.5).toDouble();
          }
        }
      }

      // --- DETERMINISTIC WORKLOAD THRESHOLD SETTING MATRIX ---
      BurnoutAlertType calculatedType = BurnoutAlertType.allGood;
      WorkloadLevel calculatedLevel = WorkloadLevel.low;
      String titleText = "You're on Fire!";
      String primaryBtnLabel = "Keep going";
      String staticAdviceMessage = "";

      if (totalPendingTasksCount > 7 || accumulatedStudyHours > 20) {
        calculatedType = BurnoutAlertType.burnout;
        calculatedLevel = WorkloadLevel.critical;
        titleText = "Burnout Alert";
        primaryBtnLabel = "Take a break";
        staticAdviceMessage = "Your active task backlog is critically high right now. Please step away from your study space, prioritize sleep tonight, and discuss task extensions with your course lecturer tomorrow.";
      } else if (totalPendingTasksCount > 4 || accumulatedStudyHours > 10) {
        calculatedType = BurnoutAlertType.overload;
        calculatedLevel = WorkloadLevel.high;
        titleText = "Overload Detected";
        primaryBtnLabel = "Stop for today";
        staticAdviceMessage = "Your required study volume is climbing up rapidly. Consider wrapping up your current assignment slot and scheduling structured relaxation blocks to keep your fatigue levels managed.";
      } else if (totalPendingTasksCount > 2) {
        calculatedType = BurnoutAlertType.warning;
        calculatedLevel = WorkloadLevel.moderate;
        titleText = "Heads Up";
        primaryBtnLabel = "Take a short break";
        staticAdviceMessage = "You have a few upcoming deliverables accumulating on your tracking boards. Pacing your study sessions out evenly this week will keep you comfortable and on track.";
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
        workloadProgress: (totalPendingTasksCount / 10).clamp(0.0, 1.0),
        workloadLevel: calculatedLevel,
        primaryActionLabel: primaryBtnLabel,
        dismissLabel: 'Dismiss warning',
      );

      loading = false;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  void evaluateSession({required double hoursStudied}) {}
  void dismiss() {}
  void clear() {}

  Future<void> fetch() async {
    listenToLiveBurnoutMetrics();
  }

  void loadMock() {
    listenToLiveBurnoutMetrics();
  }

  @override
  void dispose() {
    _burnoutSubscription?.cancel();
    super.dispose();
  }
}