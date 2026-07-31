import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert_model.dart';

class AlertProvider extends ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String selectedFilter = 'all';
  bool isLoading = false;

  List<AlertModel> _alerts = [];

  StreamSubscription? _classesSubscription;
  StreamSubscription? _enrollmentsSubscription;

  AlertProvider({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    initLiveAlertStream();
  }

  void initLiveAlertStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    _classesSubscription?.cancel();
    _classesSubscription = _db.collection('classes').where('lecturerId', isEqualTo: user.uid).snapshots().listen((
      classesSnapshot,
    ) {
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

      _enrollmentsSubscription?.cancel();
      _enrollmentsSubscription = _db
          .collection('enrollments')
          .where('classId', whereIn: managedClassNames)
          .snapshots()
          .listen((enrollmentSnapshot) async {
            // FIXED: Swapped listener closure context map to async to allow lookups

            if (enrollmentSnapshot.docs.isEmpty) {
              _alerts = [];
              isLoading = false;
              notifyListeners();
              return;
            }

            final List<AlertModel> realTimeAlerts = [];

            for (var doc in enrollmentSnapshot.docs) {
              final data = doc.data();
              final String className =
                  data['classId']?.toString() ?? 'Class Module';
              final String sId = data['studentId']?.toString() ?? '';

              // FIXED: Resolves real user names by reading from the users collection instead of a static placeholder
              String resolvedStudentName = 'Unknown Student';
              if (sId.isNotEmpty) {
                try {
                  final userDoc = await _db.collection('users').doc(sId).get();
                  if (userDoc.exists) {
                    resolvedStudentName =
                        (userDoc.data()?['name'] ?? 'Unknown Student')
                            .toString();
                  }
                } catch (e) {
                  debugPrint(
                    "Failed to resolve user metadata profile join parameters: $e",
                  );
                }
              }

              final double burnout = (data['burnoutIndex'] as num? ?? 0.0)
                  .toDouble();
              final int completed = (data['completedTasks'] as num? ?? 0)
                  .toInt();
              final int pending = (data['pendingTasks'] as num? ?? 0).toInt();
              final bool isReadStatus =
                  data['alertMarkedRead'] as bool? ?? false;

              // Case A: High Burnout Index
              if (burnout >= 0.70) {
                realTimeAlerts.add(
                  AlertModel(
                    id: '${doc.id}_burnout',
                    title:
                        'Burnout Risk — $resolvedStudentName', // FIXED: Bound resolved profile name parameter
                    message:
                        '$resolvedStudentName is showing severe clinical fatigue patterns at ${(burnout * 100).toStringAsFixed(0)}% strain index.',
                    type: 'burnout',
                    time: 'Live',
                    emoji: '🔥',
                    meta:
                        '$className · Burnout Index: ${(burnout * 100).toStringAsFixed(0)}%',
                    studentId: sId,
                    studentName:
                        resolvedStudentName, // FIXED: Passes genuine name payload string securely
                    className: className,
                    burnoutIndex: burnout,
                    riskLevel: 'High Risk',
                    read: isReadStatus,
                    timestamp: DateTime.now(),
                  ),
                );
              }

              // Case B: Overdue Workload patterns
              if (pending > 3 || (completed == 0 && pending > 0)) {
                realTimeAlerts.add(
                  AlertModel(
                    id: '${doc.id}_behind',
                    title:
                        'Falling Behind — $resolvedStudentName', // FIXED: Bound resolved profile name parameter
                    message:
                        '$resolvedStudentName has accumulated $pending pending academic tasks.',
                    type: 'behind',
                    time: 'Live',
                    emoji: '⚠️',
                    meta: '$className · $pending tasks remaining unchecked',
                    studentId: sId,
                    studentName:
                        resolvedStudentName, // FIXED: Passes genuine name payload string securely
                    className: className,
                    burnoutIndex: burnout,
                    riskLevel: 'Moderate Risk',
                    read: isReadStatus,
                    timestamp: DateTime.now(),
                  ),
                );
              }
            }

            _alerts = realTimeAlerts;
            isLoading = false;
            notifyListeners();
          });
    });
  }

  /// Computes filtering array states based on user interaction selections
  /// Computes filtering array states based on user interaction selections
  List<AlertModel> get filtered {
    // 1. "All" tab shows absolutely everything (both read and unread alerts combined)
    if (selectedFilter == 'all') {
      return _alerts;
    }

    // 2. "Read" tab shows only notifications marked read
    if (selectedFilter == 'read') {
      return _alerts.where((a) => a.read).toList();
    }

    // 3. "Falling Behind" tab shows behind notifications (both read and unread)
    if (selectedFilter == 'behind' || selectedFilter == 'falling_behind') {
      return _alerts.where((a) => a.type == 'behind').toList();
    }

    // 4. "Burnout" tab shows burnout notifications (both read and unread)
    if (selectedFilter == 'burnout') {
      return _alerts.where((a) => a.type == 'burnout').toList();
    }

    // Fallback default match rule (retains items regardless of read state status)
    return _alerts.where((a) => a.type == selectedFilter).toList();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void markAsRead(AlertModel alert) async {
    final String rawEnrollmentId = alert.id
        .replaceAll('_burnout', '')
        .replaceAll('_behind', '');

    try {
      await _db.collection('enrollments').doc(rawEnrollmentId).update({
        'alertMarkedRead': true,
      });
    } catch (e) {
      debugPrint(
        "Failed to sync reading status change to Firestore collection: $e",
      );
    }
  }

  void reset() {
    _classesSubscription?.cancel();
    _classesSubscription = null;
    _enrollmentsSubscription?.cancel();
    _enrollmentsSubscription = null;
    _alerts = [];
    selectedFilter = 'all';
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _classesSubscription?.cancel();
    _enrollmentsSubscription?.cancel();
    super.dispose();
  }
}
