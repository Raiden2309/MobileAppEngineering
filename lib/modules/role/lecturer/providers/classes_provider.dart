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
        .where('subjectCode', isEqualTo: classCode.trim())
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

  /// FIXED METHOD: Distributes tasks smoothly to both Class structures and active Enrolled profiles
  Future<void> assignTaskToClass(String classId, [Map<String, dynamic>? taskData]) async {
    try {
      final todayString = DateTime.now().toIso8601String().split('T').first;
      final resolvedData = taskData ?? {};

      // Build a comprehensive, safe map containing properties required by both My Tasks and Today's Tasks
      final taskMap = {
        'id': resolvedData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': resolvedData['title'] ?? 'New Class Assignment',
        'description': resolvedData['description'] ?? 'Please complete this assignment task.',
        'subjectCode': resolvedData['subjectCode'] ?? '',
        'dueDate': resolvedData['dueDate'] ?? todayString,
        'scheduledDate': resolvedData['scheduledDate'] ?? todayString,

        // CRITICAL DATA MATCHING FLAGS FOR THE STUDENT FILTERS:
        'status': 'pending',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 1. Add task to master class template
      await _db.collection('classes').doc(classId).update({
        'initialTasks': FieldValue.arrayUnion([taskMap])
      });

      // 2. Query all active student enrollments for this class
      final classSnap = await _db.collection('classes').doc(classId).get();
      final String subjectCode = (classSnap.data() as Map<String, dynamic>)['subjectCode'] ?? '';

      final enrollmentsSnap = await _db
          .collection('enrollments')
          .where('subjectCode', isEqualTo: subjectCode.trim())
          .where('source', isEqualTo: 'class')
          .get();

      final WriteBatch taskWriteBatch = _db.batch();

      for (var doc in enrollmentsSnap.docs) {
        final DocumentReference enrollmentDocRef = _db.collection('enrollments').doc(doc.id);

        taskWriteBatch.update(enrollmentDocRef, {
          'tasksList': FieldValue.arrayUnion([taskMap]),
          'pendingTasks': FieldValue.increment(1),
        });
      }

      await taskWriteBatch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to distribute assigned tasks: $e");
      rethrow;
    }
  }

  /// NEW METHOD: Modifies an existing task's description and due date, then atomatically forces changes to all enrolled students
  Future<void> updateClassTask({
    required String classId,
    required String taskId,
    required String updatedTitle,
    required String updatedDescription,
    required String updatedDueDate,
  }) async {
    try {
      // 1. Fetch and modify master class task array template
      final classDocRef = _db.collection('classes').doc(classId);
      final classSnap = await classDocRef.get();
      if (!classSnap.exists) throw Exception('Class template not found');

      final classData = classSnap.data() as Map<String, dynamic>;
      final String subjectCode = classData['subjectCode'] ?? '';
      final List<dynamic> masterTasks = List.from(classData['initialTasks'] ?? []);

      final masterIdx = masterTasks.indexWhere((t) => t['id']?.toString() == taskId);
      if (masterIdx != -1) {
        masterTasks[masterIdx]['title'] = updatedTitle;
        masterTasks[masterIdx]['description'] = updatedDescription;
        masterTasks[masterIdx]['dueDate'] = updatedDueDate;
        masterTasks[masterIdx]['scheduledDate'] = updatedDueDate; // Keep dashboard feed tracking aligned

        await classDocRef.update({'initialTasks': masterTasks});
      }

      // 2. Query all student enrollments under this subject to update their lists via batch write
      final enrollmentsSnap = await _db
          .collection('enrollments')
          .where('subjectCode', isEqualTo: subjectCode.trim())
          .where('source', isEqualTo: 'class')
          .get();

      final WriteBatch updateBatch = _db.batch();

      for (var doc in enrollmentsSnap.docs) {
        final List<dynamic> studentTasks = List.from(doc.data()['tasksList'] ?? []);
        final studentTaskIdx = studentTasks.indexWhere((t) => t['id']?.toString() == taskId);

        if (studentTaskIdx != -1) {
          studentTasks[studentTaskIdx]['title'] = updatedTitle;
          studentTasks[studentTaskIdx]['description'] = updatedDescription;
          studentTasks[studentTaskIdx]['dueDate'] = updatedDueDate;
          studentTasks[studentTaskIdx]['scheduledDate'] = updatedDueDate;

          updateBatch.update(_db.collection('enrollments').doc(doc.id), {
            'tasksList': studentTasks,
          });
        }
      }

      await updateBatch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to update class task: $e");
      rethrow;
    }
  }

  Future<void> addClass(ClassModel newClass) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _db.collection('classes').doc(newClass.id).set({
        'name': newClass.name,
        'subjectCode': newClass.subjectCode.toUpperCase().trim(),
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

  /// METHOD: Manually enrolls a targeted student by creating an authoritative document inside the enrollments collection
  Future<bool> manuallyEnrollStudent({
    required String studentUid,
    required String className,
    required String subjectCode,
  }) async {
    if (studentUid.isEmpty || className.isEmpty) return false;

    try {
      final safeClassId = className
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'[\s-]'), '_');
      final enrollmentId = '${studentUid}_$safeClassId';

      final DocumentSnapshot duplicateCheck =
      await _db.collection('enrollments').doc(enrollmentId).get();

      if (duplicateCheck.exists) return false;

      // CRITICAL FIX: Fetch the student's actual active academic semester ID (e.g. sem_1_yr1)
      final studentUserDoc = await _db.collection('users').doc(studentUid).get();
      final String actualStudentSemester = studentUserDoc.data()?['currentSemesterId']?.toString() ?? 'sem_1_yr1';

      List initialTasks = [];
      final QuerySnapshot classSnap = await _db
          .collection('classes')
          .where('subjectCode', isEqualTo: subjectCode.trim())
          .limit(1)
          .get();

      if (classSnap.docs.isNotEmpty) {
        final rawTasks = (classSnap.docs.first.data() as Map<String, dynamic>)['initialTasks'] as List? ?? [];
        final String todayString = DateTime.now().toIso8601String().split('T').first;

        initialTasks = rawTasks.map((task) {
          final taskMap = Map<String, dynamic>.from(task as Map);
          taskMap['dueDate'] = taskMap['dueDate'] ?? todayString;
          taskMap['scheduledDate'] = taskMap['scheduledDate'] ?? todayString;

          // ENSURE PARSING FLAGS ARE PRESENT:
          taskMap['status'] = 'pending';
          taskMap['isCompleted'] = false;
          taskMap['createdAt'] = taskMap['createdAt'] ?? DateTime.now().toIso8601String();
          return taskMap;
        }).toList();
      }

      await _db.collection('enrollments').doc(enrollmentId).set({
        'studentId': studentUid,
        'classId': className,
        'subjectCode': subjectCode.trim(),
        'source': 'class',
        'colorHex': '#60A5FA',
        'completedTasks': 0,
        'pendingTasks': initialTasks.length,
        'burnoutIndex': 0.0,
        'tasksList': initialTasks,
        'joinedAt': FieldValue.serverTimestamp(),
        'semester': actualStudentSemester, // Passes structural requirement validation check
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('manuallyEnrollStudent error: $e');
      return false;
    }
  }

  /// NEW METHOD: Completely terminates a student enrollment record and updates registration counters
  Future<bool> removeStudentFromClass({
    required String studentUid,
    required String className,
  }) async {
    if (studentUid.isEmpty || className.isEmpty) return false;

    try {
      final safeClassId = className
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'[\s-]'), '_');
      final enrollmentId = '${studentUid}_$safeClassId';

      final docRef = _db.collection('enrollments').doc(enrollmentId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) return false;

      final enrollmentData = docSnap.data() as Map<String, dynamic>;
      final String subjectCode = enrollmentData['subjectCode'] ?? '';

      // 1. Clear out the target enrollment entry completely
      await docRef.delete();

      // 2. Decrement student counter inside parent class schema reference template
      final classQuery = await _db
          .collection('classes')
          .where('subjectCode', isEqualTo: subjectCode.trim())
          .limit(1)
          .get();

      if (classQuery.docs.isNotEmpty) {
        await classQuery.docs.first.reference.update({
          'studentCount': FieldValue.increment(-1),
        });
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('removeStudentFromClass error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _classesSubscription?.cancel();
    super.dispose();
  }
}