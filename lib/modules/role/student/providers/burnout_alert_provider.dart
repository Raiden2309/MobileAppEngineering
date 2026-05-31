import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/app_enums.dart';
import '../models/burnout_alert_model.dart';

class BurnoutAlertProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BurnoutAlertModel? alert;
  bool loading = false;
  String? error;
  StreamSubscription? _burnoutSubscription;

  // Actual Google AI Studio key
  static const String _apiKey = 'AIzaSyDde40Mgc-MTNBp1OwIXY0EhcTxLLLgk1Q';

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
        .listen((snapshot) async {

      int totalPendingTasksCount = 0;
      double accumulatedStudyHours = 0.0;
      final List<String> trackingSubjectsList = [];

      for (var doc in snapshot.docs) {
        final dataMap = doc.data();
        final String subjectName = dataMap['classId']?.toString() ?? 'General';
        final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];

        final pendingTasks = rawTasks.where((t) => t['status'] != 'completed').toList();

        if (pendingTasks.isNotEmpty) {
          totalPendingTasksCount += pendingTasks.length;
          trackingSubjectsList.add(subjectName);
          for (var task in pendingTasks) {
            accumulatedStudyHours += (task['estimated_hours'] as num? ?? 1.5).toDouble();
          }
        }
      }

      BurnoutAlertType calculatedType = BurnoutAlertType.allGood;
      WorkloadLevel calculatedLevel = WorkloadLevel.low;
      String titleText = "You're on Fire!";
      String primaryBtnLabel = "Keep going";

      if (totalPendingTasksCount > 7 || accumulatedStudyHours > 20) {
        calculatedType = BurnoutAlertType.burnout;
        calculatedLevel = WorkloadLevel.critical;
        titleText = "Burnout Alert";
        primaryBtnLabel = "Take a break";
      } else if (totalPendingTasksCount > 4 || accumulatedStudyHours > 10) {
        calculatedType = BurnoutAlertType.overload;
        calculatedLevel = WorkloadLevel.high;
        titleText = "Overload Detected";
        primaryBtnLabel = "Stop for today";
      } else if (totalPendingTasksCount > 2) {
        calculatedType = BurnoutAlertType.warning;
        calculatedLevel = WorkloadLevel.moderate;
        titleText = "Heads Up";
        primaryBtnLabel = "Take a short break";
      }

      final String currentTextDescription = alert?.description ??
          "Analyzing your semester workload logs to generate personal mental health insights...";

      alert = BurnoutAlertModel(
        type: calculatedType,
        title: titleText,
        description: currentTextDescription,
        hoursStudied: accumulatedStudyHours,
        workloadProgress: (totalPendingTasksCount / 10).clamp(0.0, 1.0),
        workloadLevel: calculatedLevel,
        primaryActionLabel: primaryBtnLabel,
        dismissLabel: 'Dismiss warning',
      );

      loading = false;
      notifyListeners();

      _fetchAiPersonalizedMessage(
        riskLevel: calculatedLevel.name,
        pendingCount: totalPendingTasksCount,
        totalHours: accumulatedStudyHours,
        subjects: trackingSubjectsList,
      );

    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchAiPersonalizedMessage({
    required String riskLevel,
    required int pendingCount,
    required double totalHours,
    required List<String> subjects,
  }) async {
    try {
      // FIXED: Use 'gemini-1.5-flash' directly without the 'models/' prefix string mapping block
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 120,
        ),
      );

      final String prompt = '''
You are an empathetic, encouraging student mental health counselor and academic advisor.
Your job is to read a student's live workload data and provide a concise, warm, 2-sentence piece of personalized advice.
Address them directly with supportive peer-like tone. Avoid robotic phrasing, corporate buzzwords, and dry lists.

Current Student Data Context:
- Academic Burnout Risk Rating: $riskLevel
- Active Pending Backlog Count: $pendingCount tasks left
- Accumulated Study Hours Required: $totalHours hours
- Targeted Subject Tracks: ${subjects.join(', ')}

Provide exactly 2 sentences of meaningful, customized guidance based on this information.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final String? responseText = response.text?.trim();

      if (responseText != null && responseText.isNotEmpty && alert != null) {
        alert = BurnoutAlertModel(
          type: alert!.type,
          title: alert!.title,
          description: responseText,
          hoursStudied: alert!.hoursStudied,
          workloadProgress: alert!.workloadProgress,
          workloadLevel: alert!.workloadLevel,
          primaryActionLabel: alert!.primaryActionLabel,
          dismissLabel: alert!.dismissLabel,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gemini evaluation error: $e");
    }
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