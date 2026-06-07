import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/class_model.dart';
import '../models/class_student_model.dart';

class ClassesProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  bool isLoading = false;
  String? error;

  StreamSubscription? _classesSubscription;

  ClassesProvider({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _auth.authStateChanges().listen((user) {
      if (user != null) startLiveClassesListener();
    });
  }

  void startLiveClassesListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    _classesSubscription?.cancel();

    _classesSubscription = _db
        .collection('classes')
        .where('lecturerId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {

      _classes = snapshot.docs.map((doc) {
        return ClassModel.fromFirestore(doc);
      }).toList();

      isLoading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    });
  }

  /// STREAM: Fetches all enrollment records for a subject and dynamically joins user data to retrieve actual student names
  Stream<List<ClassStudentModel>> getStudents(String classCode) {
    return _db
        .collection('enrollments')
        .where('subjectCode', isEqualTo: classCode)
        .snapshots()
        .asyncMap((enrollmentSnapshot) async {

      final List<ClassStudentModel> populatedStudentsList = [];

      for (var doc in enrollmentSnapshot.docs) {
        final enrollmentData = doc.data();
        final String studentUid = enrollmentData['studentId']?.toString() ?? '';

        String actualStudentName = 'Enrolled Student';

        if (studentUid.isNotEmpty) {
          try {
            // LOOKUP: Query the master user profile document matching this ID
            final DocumentSnapshot userProfileSnapshot =
            await _db.collection('users').doc(studentUid).get();

            if (userProfileSnapshot.exists) {
              final userData = userProfileSnapshot.data() as Map<String, dynamic>? ?? {};
              // Target the exact "name" field visible in your Firestore console image
              actualStudentName = userData['name']?.toString() ?? 'Enrolled Student';
            }
          } catch (e) {
            debugPrint("Failed to load real-time student profile name payload: $e");
          }
        }

        populatedStudentsList.add(
          ClassStudentModel(
            studentId: studentUid,
            name: actualStudentName,
            weeklyStudyHours: (enrollmentData['weeklyStudyHours'] as num? ?? 0.0).toDouble(),
            burnoutIndex: (enrollmentData['burnoutIndex'] as num? ?? 0.0).toDouble(),
          ),
        );
      }

      return populatedStudentsList;
    });
  }

  /// NEW REAL-TIME STREAM: Listens to updates for a specific class document
  Stream<ClassModel> streamClassDetails(String classId) {
    return _db
        .collection('classes')
        .doc(classId)
        .snapshots()
        .map((snapshot) => ClassModel.fromFirestore(snapshot));
  }

  /// METHOD: Distributes a task blueprint to a class and pushes it to all enrolled students
  Future<void> assignTaskToClass({
    required String classId,
    required String subjectCode,
    required String semester,
    required String taskTitle,
    required String description,
    required DateTime dueDate,
  }) async {
    try {
      final String generatedTaskId = _db.collection('classes').doc().id;

      final Map<String, dynamic> taskMap = {
        'id': generatedTaskId,
        'title': taskTitle,
        'description': description,
        'estimated_hours': 1.0,
        'status': 'toDo',
        'due_date': dueDate.toIso8601String(),
      };

      // 1. Add task directly into the core class curriculum matrix template
      await _db.collection('classes').doc(classId).update({
        'initialTasks': FieldValue.arrayUnion([taskMap]),
      });

      // 2. Query all student records tracking this specific course subject code
      final QuerySnapshot targetEnrollments = await _db
          .collection('enrollments')
          .where('subjectCode', isEqualTo: subjectCode.toUpperCase())
          .where('semester', isEqualTo: semester)
          .get();

      if (targetEnrollments.docs.isEmpty) return;

      final WriteBatch taskWriteBatch = _db.batch();

      // 3. Append task to each matching enrollment doc (TasksProvider reads tasksList from here)
      for (var doc in targetEnrollments.docs) {
        final DocumentReference enrollmentDocRef = _db.collection('enrollments').doc(doc.id);
        final existingData = doc.data() as Map<String, dynamic>;

        taskWriteBatch.update(enrollmentDocRef, {
          'tasksList':    FieldValue.arrayUnion([taskMap]),
          'pendingTasks': FieldValue.increment(1),
          // Stamp display fields if missing so TasksProvider can render the subject group
          if (!existingData.containsKey('name') || existingData['name'] == null)
            'name':     subjectCode,
          if (!existingData.containsKey('classId') || existingData['classId'] == null)
            'classId':  subjectCode,
          if (!existingData.containsKey('colorKey') || existingData['colorKey'] == null)
            'colorKey': 'blue',
          if (!existingData.containsKey('semester') || existingData['semester'] == null)
            'semester': semester,
        });
      }

      await taskWriteBatch.commit();

      notifyListeners();
    } catch (e) {
      debugPrint("Failed to distribute assigned tasks across enrollments collection: $e");
      rethrow;
    }
  }

  Future<void> addClass(ClassModel newClass) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _db.collection('classes').doc(newClass.id).set({
        'name': newClass.name,
        'subjectCode': newClass.subjectCode.toUpperCase(),
        'classCode': newClass.classCode,
        'semester': newClass.semester,
        'lecturerId': user.uid,
        'studentCount': 0,
        'avgCompletion': 0.0,
        'atRiskCount': 0,
        'initialTasks': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to execute class creation transaction pipeline: $e");
      rethrow;
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await _db.collection('classes').doc(classId).delete();
    } catch (e) {
      debugPrint("Aborted class structural destruction mapping sequence: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _classesSubscription?.cancel();
    super.dispose();
  }
}