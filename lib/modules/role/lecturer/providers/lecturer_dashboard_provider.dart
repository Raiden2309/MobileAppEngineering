import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stat_card_model.dart';
import '../models/alert_model.dart';
import '../models/class_model.dart';

class LecturerDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  bool isLoading = false;
  String lecturerName = 'Lecturer';

  String _greeting = 'Good Morning';
  String get greeting => _greeting;

  String _subtitleText = 'Here is your overview for today';
  String get subtitleText => _subtitleText;

  String _dateLabel = '';
  String get dateLabel => _dateLabel;

  int _atRiskCount = 0;
  int get atRiskCount => _atRiskCount;

  List<StatCardModel> _stats = [];
  List<StatCardModel> get stats => _stats;

  List<ClassModel> classes = [];
  List<AlertModel> alerts = [];

  StreamSubscription? _classesSubscription;
  StreamSubscription? _enrollmentsSubscription;

  LecturerDashboardProvider({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _updateTimeBasedGreeting();
    initLiveDashboard();
  }
  void _updateTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    _dateLabel = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void initLiveDashboard() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    lecturerName = user.displayName ?? 'Lecturer';
    notifyListeners();

    _classesSubscription?.cancel();
    _classesSubscription = _db
        .collection('classes')
        .where('lecturerId', isEqualTo: user.uid)
        .snapshots()
        .listen((classesSnapshot) {

      final List<String> managedClassNames = [];
      final List<ClassModel> mappedClasses = [];

      for (var doc in classesSnapshot.docs) {
        final d = doc.data();
        final name = d['name']?.toString() ?? 'Unknown Class';
        managedClassNames.add(name);

        mappedClasses.add(ClassModel(
          id: doc.id,
          name: name,
          code: d['subjectCode']?.toString() ?? d['classCode']?.toString() ?? 'COMP000',
          subjectCode: d['subjectCode']?.toString() ?? '',
          classCode: d['classCode']?.toString() ?? '',
          semester: d['semester']?.toString() ?? 'Semester 1',
          lecturerId: user.uid,
          accentColor: const Color(0xff4F86C6),
          studentCount: 0,
        ));
      }
      classes = mappedClasses;

      if (managedClassNames.isEmpty) {
        _rebuildEmptyDashboard();
        return;
      }

      _enrollmentsSubscription?.cancel();
      _enrollmentsSubscription = _db
          .collection('enrollments')
          .where('classId', whereIn: managedClassNames)
          .snapshots()
          .listen((enrollmentSnapshot) {

        int totalStudents = enrollmentSnapshot.docs.length;
        int highlyBurnedOutCount = 0;
        double combinedProgress = 0.0;
        int progressCount = 0;

        alerts.clear();

        for (var classItem in classes) {
          final classDocs = enrollmentSnapshot.docs.where((doc) =>
          doc.data()['classId']?.toString() == classItem.name
          );
          classItem.studentCount = classDocs.length;

          int classAtRisk = 0;
          double classProgressSum = 0.0;
          int classProgressCount = 0;

          for (var cDoc in classDocs) {
            final cData = cDoc.data();
            final double bo = (cData['burnoutIndex'] as num? ?? 0.0).toDouble();
            if (bo >= 0.70) classAtRisk++;

            final double comp = (cData['completedTasks'] as num? ?? 0).toDouble();
            final double pend = (cData['pendingTasks'] as num? ?? 0).toDouble();
            if ((comp + pend) > 0) {
              classProgressSum += (comp / (comp + pend));
              classProgressCount++;
            }
          }
          classItem.atRiskCount = classAtRisk;
          classItem.avgCompletion = classProgressCount > 0 ? (classProgressSum / classProgressCount) * 100 : 0.0;
        }

        for (var doc in enrollmentSnapshot.docs) {
          final studentData = doc.data();
          final double burnout = (studentData['burnoutIndex'] as num? ?? 0.0).toDouble();
          final double completed = (studentData['completedTasks'] as num? ?? 0).toDouble();
          final double pending = (studentData['pendingTasks'] as num? ?? 0).toDouble();

          final double totalTasks = completed + pending;
          if (totalTasks > 0) {
            combinedProgress += (completed / totalTasks);
            progressCount++;
          }

          if (burnout >= 0.70) {
            highlyBurnedOutCount++;
            alerts.add(AlertModel(
              id: doc.id,
              title: 'High Burnout Alert',
              message: '${studentData['studentName'] ?? 'A student'} is exhibiting high exhaustion metrics.',
              type: 'burnout',
              time: 'Just now',
              emoji: '🔥',
              meta: studentData['classId']?.toString() ?? 'Class Route',
              studentId: studentData['studentId']?.toString() ?? doc.id,
              studentName: studentData['studentName']?.toString() ?? 'Student',
              className: studentData['classId']?.toString() ?? 'Class',
              burnoutIndex: burnout,
              riskLevel: 'High Risk',
              timestamp: DateTime.now(),
            ));
          }
        }

        _atRiskCount = highlyBurnedOutCount;
        double averageCompletion = progressCount > 0 ? (combinedProgress / progressCount) * 100 : 0.0;
        _subtitleText = highlyBurnedOutCount > 0
            ? 'You have $highlyBurnedOutCount students at risk'
            : 'All student parameters look balanced today';

        _stats = [
          StatCardModel(
            label: 'Active Classes',
            value: classes.length.toString(),
            sub: 'Classes managed',
            icon: Icons.class_rounded,
            accent: Colors.blue,
          ),
          StatCardModel(
            label: 'Total Students',
            value: totalStudents.toString(),
            sub: 'Students enrolled',
            icon: Icons.people_alt_rounded,
            accent: Colors.green,
          ),
          StatCardModel(
            label: 'Avg Progress',
            value: '${averageCompletion.toStringAsFixed(0)}%',
            sub: 'Task completion',
            icon: Icons.trending_up_rounded,
            accent: Colors.purple,
          ),
          StatCardModel(
            label: 'At Risk Students',
            value: highlyBurnedOutCount.toString(),
            sub: highlyBurnedOutCount > 0 ? 'Requires attention' : 'All clear',
            icon: Icons.warning_amber_rounded,
            accent: highlyBurnedOutCount > 0 ? Colors.red : Colors.grey,
          ),
        ];

        isLoading = false;
        notifyListeners();
      });

    }, onError: (e) {
      isLoading = false;
      notifyListeners();
    });
  }

  void _rebuildEmptyDashboard() {
    _atRiskCount = 0;
    _subtitleText = 'Create a class to begin tracking metrics';
    _stats = [
      StatCardModel(label: 'Active Classes', value: '0', sub: 'No classes found', icon: Icons.class_rounded, accent: Colors.grey),
      StatCardModel(label: 'Total Students', value: '0', sub: 'No data', icon: Icons.people_alt_rounded, accent: Colors.grey),
      StatCardModel(label: 'Avg Progress', value: '0%', sub: 'No data', icon: Icons.trending_up_rounded, accent: Colors.grey),
      StatCardModel(label: 'At Risk Students', value: '0', sub: 'No data', icon: Icons.warning_amber_rounded, accent: Colors.grey),
    ];
    alerts.clear();
    isLoading = false;
    notifyListeners();
  }

  // Legacy layout synchronization hooks
  void updateLecturerName(String name) {}
  void updateGreeting(String greeting) {}
  void updateDateLabel(String label) {}
  void updateAtRiskCount(int count) {}

  @override
  void dispose() {
    _classesSubscription?.cancel();
    _enrollmentsSubscription?.cancel();
    super.dispose();
  }
}