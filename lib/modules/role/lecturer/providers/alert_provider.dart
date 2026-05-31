import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert_model.dart';

class AlertProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String selectedFilter = 'all';
  bool isLoading = false;

  // Live dynamic lists instead of hardcoded mock records
  List<AlertModel> _alerts = [];

  StreamSubscription? _classesSubscription;
  StreamSubscription? _enrollmentsSubscription;

  AlertProvider() {
    initLiveAlertStream();
  }

  /// Establishes reactive real-time database listeners for the lecturer's specific student data
  void initLiveAlertStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    // 1. Fetch class rooms managed exclusively by this lecturer to filter incoming enrollments safely
    _classesSubscription?.cancel();
    _classesSubscription = _db
        .collection('classes')
        .where('lecturerId', isEqualTo: user.uid)
        .snapshots()
        .listen((classesSnapshot) {

      final List<String> managedClassNames = classesSnapshot.docs
          .map((doc) => doc.data()['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      if (managedClassNames.isEmpty) {
        _alerts = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Listen to active student enrollment data matrices inside those specific class streams
      _enrollmentsSubscription?.cancel();
      _enrollmentsSubscription = _db
          .collection('enrollments')
          .where('classId', whereIn: managedClassNames)
          .snapshots()
          .listen((enrollmentSnapshot) {

        if (enrollmentSnapshot.docs.isEmpty) {
          _alerts = [];
          isLoading = false;
          notifyListeners();
          return;
        }

        final List<AlertModel> realTimeAlerts = [];

        for (var doc in enrollmentSnapshot.docs) {
          final data = doc.data();
          final String studentName = data['studentName']?.toString() ?? 'Unknown Student';
          final String className = data['classId']?.toString() ?? 'Class Module';
          final String sId = data['studentId']?.toString() ?? doc.id;

          final double burnout = (data['burnoutIndex'] as num? ?? 0.0).toDouble();
          final int completed = (data['completedTasks'] as num? ?? 0).toInt();
          final int pending = (data['pendingTasks'] as num? ?? 0).toInt();
          final bool isReadStatus = data['alertMarkedRead'] as bool? ?? false;

          // Case A: High Burnout Index (Exhaustion Threshold crossed)
          if (burnout >= 0.70) {
            realTimeAlerts.add(AlertModel(
              id: '${doc.id}_burnout',
              title: 'Burnout Risk — $studentName',
              message: '$studentName is showing severe clinical fatigue patterns at ${(burnout * 100).toStringAsFixed(0)}% strain index.',
              type: 'burnout',
              time: 'Live',
              emoji: '🔥',
              meta: '$className · Burnout Index: ${(burnout * 100).toStringAsFixed(0)}%',
              studentId: sId,
              studentName: studentName,
              className: className,
              burnoutIndex: burnout,
              riskLevel: 'High Risk',
              read: isReadStatus,
              timestamp: DateTime.now(),
            ));
          }

          // Case B: Overdue Workload patterns (Falling Behind Threshold crossed)
          if (pending > 3 || (completed == 0 && pending > 0)) {
            realTimeAlerts.add(AlertModel(
              id: '${doc.id}_behind',
              title: 'Falling Behind — $studentName',
              message: '$studentName has accumulated $pending pending academic tasks.',
              type: 'behind',
              time: 'Live',
              emoji: '⚠️',
              meta: '$className · $pending tasks remaining unchecked',
              studentId: sId,
              studentName: studentName,
              className: className,
              burnoutIndex: burnout,
              riskLevel: 'Moderate Risk',
              read: isReadStatus,
              timestamp: DateTime.now(),
            ));
          }
        }

        _alerts = realTimeAlerts;
        isLoading = false;
        notifyListeners();
      });
    });
  }

  /// Computes filtering array states based on user interaction selections
  List<AlertModel> get filtered {
    if (selectedFilter == 'all') return _alerts.where((a) => !a.read).toList();
    if (selectedFilter == 'read') return _alerts.where((a) => a.read).toList();
    return _alerts.where((a) => a.type == selectedFilter && !a.read).toList();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  /// Persists reading state choices straight back down to the target document reference in Firebase
  void markAsRead(AlertModel alert) async {
    // Strip our custom composite postfix tag to identify the pure parent enrollment Document ID
    final String rawEnrollmentId = alert.id.replaceAll('_burnout', '').replaceAll('_behind', '');

    try {
      await _db.collection('enrollments').doc(rawEnrollmentId).update({
        'alertMarkedRead': true,
      });
    } catch (e) {
      debugPrint("Failed to sync reading status change to Firestore collection: $e");
    }
  }

  @override
  void dispose() {
    _classesSubscription?.cancel();
    _enrollmentsSubscription?.cancel();
    super.dispose();
  }
}