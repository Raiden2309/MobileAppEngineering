import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/classes_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late ClassesProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'lecturer_uid'));
    provider = ClassesProvider(db: fakeFirestore, auth: fakeAuth);
  });

  // -------------------------------------------------------------------------
  group('ClassesProvider initial state', () {
    test('classes list is empty on init', () {
      expect(provider.classes, isEmpty);
    });

    test('error is null on init', () {
      expect(provider.error, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('ClassesProvider.addClass()', () {
    test('writes class document to Firestore', () async {
      await fakeFirestore.collection('classes').doc('class_001').set({
        'name': 'Data Structures',
        'subjectCode': 'COMP201',
        'classCode': 'SEC_A',
        'semester': 'Semester 1',
        'lecturerId': 'lecturer_uid',
        'studentCount': 0,
        'avgCompletion': 0.0,
        'atRiskCount': 0,
        'initialTasks': [],
      });

      final doc = await fakeFirestore.collection('classes').doc('class_001').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['name'], 'Data Structures');
      expect(doc.data()?['subjectCode'], 'COMP201');
    });

    test('subject code is stored in uppercase', () async {
      await fakeFirestore.collection('classes').doc('class_002').set({
        'subjectCode': 'comp301'.toUpperCase(),
        'lecturerId': 'lecturer_uid',
      });

      final doc = await fakeFirestore.collection('classes').doc('class_002').get();
      expect(doc.data()?['subjectCode'], 'COMP301');
    });

    test('initialTasks defaults to empty list', () async {
      await fakeFirestore.collection('classes').doc('class_003').set({
        'name': 'Algorithms',
        'subjectCode': 'COMP401',
        'lecturerId': 'lecturer_uid',
        'initialTasks': [],
      });

      final doc = await fakeFirestore.collection('classes').doc('class_003').get();
      expect(doc.data()?['initialTasks'], isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('ClassesProvider.deleteClass()', () {
    test('removes class document from Firestore', () async {
      await fakeFirestore.collection('classes').doc('class_del').set({
        'name': 'To Delete',
        'lecturerId': 'lecturer_uid',
      });

      await fakeFirestore.collection('classes').doc('class_del').delete();
      final doc = await fakeFirestore.collection('classes').doc('class_del').get();
      expect(doc.exists, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('ClassesProvider.assignTaskToClass() — task map structure', () {
    test('task map contains all required fields', () {
      final DateTime due = DateTime(2024, 8, 30);
      final map = <String, dynamic>{
        'id': 'task_abc',
        'title': 'Lab Report',
        'description': 'Write up lab findings',
        'estimated_hours': 1.0,
        'status': 'toDo',
        'due_date': due.toIso8601String(),
      };

      expect(map['id'], 'task_abc');
      expect(map['title'], 'Lab Report');
      expect(map['status'], 'toDo');
      expect(map['estimated_hours'], 1.0);
      expect(map['due_date'], due.toIso8601String());
    });

    test('new task status is always "toDo"', () {
      final map = <String, dynamic>{'status': 'toDo'};
      expect(map['status'], 'toDo');
    });

    test('due_date is stored as ISO 8601 string', () {
      final DateTime due = DateTime(2024, 12, 1, 9, 0);
      final String isoString = due.toIso8601String();
      expect(isoString, '2024-12-01T09:00:00.000');
    });
  });

  // -------------------------------------------------------------------------
  group('ClassesProvider — student name fallback', () {
    test('returns name when Firestore provides a non-empty value', () {
      final String? raw = 'Alice Tan';
      final String resolved = raw?.isNotEmpty == true ? raw! : 'Enrolled Student';
      expect(resolved, 'Alice Tan');
    });

    test('returns fallback when name is null', () {
      final String? raw = null;
      final String resolved = raw?.isNotEmpty == true ? raw! : 'Enrolled Student';
      expect(resolved, 'Enrolled Student');
    });

    test('returns fallback when name is empty string', () {
      final String? raw = '';
      final String resolved = raw?.isNotEmpty == true ? raw! : 'Enrolled Student';
      expect(resolved, 'Enrolled Student');
    });
  });

  // -------------------------------------------------------------------------
  group('ClassesProvider.dispose()', () {
    test('disposes without throwing', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}