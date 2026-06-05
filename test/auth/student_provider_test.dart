import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/models/student_model.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/provider/student_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StudentProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    provider = StudentProvider(db: fakeFirestore);
  });

  group('StudentProvider.fetch()', () {
    test('sets student when document exists', () async {
      await fakeFirestore.collection('users').doc('uid1').set({
        'id': 'uid1',
        'name': 'Jake',
        'email': 'jake@test.com',
        'programme': 'SE',
        'dayStart': {'hour': 8, 'minute': 0},
        'dayEnd': {'hour': 22, 'minute': 0},
        'blockedSlots': [],
        'currentSemesterId': null,
      });

      await provider.fetch('uid1');

      expect(provider.student, isNotNull);
      expect(provider.student!.name, 'Jake');
      expect(provider.loading, false);
      expect(provider.error, isNull);
    });

    test('student remains null when document does not exist', () async {
      await provider.fetch('nonexistent_uid');

      expect(provider.student, isNull);
      expect(provider.loading, false);
    });

    test('also fetches currentSemester when currentSemesterId is set', () async {
      await fakeFirestore.collection('users').doc('uid1').set({
        'id': 'uid1',
        'name': 'Jake',
        'email': 'jake@test.com',
        'programme': 'SE',
        'dayStart': {'hour': 8, 'minute': 0},
        'dayEnd': {'hour': 22, 'minute': 0},
        'blockedSlots': [],
        'currentSemesterId': 'sem_1_yr2024',
      });

      await fakeFirestore
          .collection('users')
          .doc('uid1')
          .collection('semesters')
          .doc('sem_1_yr2024')
          .set({
        'id': 'sem_1_yr2024',
        'semester': 1,
        'year': 2024,
        'semStart': '2024-01-01T00:00:00.000',
        'semEnd': '2024-06-30T00:00:00.000',
        'examDates': [],
        'subjects': [],
      });

      await provider.fetch('uid1');

      expect(provider.currentSemester, isNotNull);
      expect(provider.currentSemester!.id, 'sem_1_yr2024');
    });
  });

  group('StudentProvider.save()', () {
    test('saves student and semester, updates local state', () async {
      final student = StudentModel(
        id: 'uid1',
        name: 'Jake',
        email: 'jake@test.com',
        programme: 'SE',
        dayStart: const TimeOfDay(hour: 8, minute: 0),
        dayEnd: const TimeOfDay(hour: 22, minute: 0),
        blockedSlots: [],
        currentSemesterId: null,
      );

      final semester = SemesterModel(
        id: '',
        semester: 1,
        year: 2024,
        semStart: DateTime(2024, 1, 1),
        semEnd: DateTime(2024, 6, 30),
        examDates: [],
        subjects: [],
      );

      await provider.save(student, semester);

      expect(provider.student, isNotNull);
      expect(provider.student!.currentSemesterId, 'sem_1_yr2024');
      expect(provider.currentSemester, isNotNull);
      expect(provider.currentSemester!.semester, 1);
      expect(provider.currentSemester!.year, 2024);
      expect(provider.loading, false);
      expect(provider.error, isNull);
    });
  });

  group('StudentProvider.clear()', () {
    test('resets all state to null', () async {
      final student = StudentModel(
        id: 'uid1',
        name: 'Jake',
        email: 'jake@test.com',
        programme: 'SE',
        dayStart: const TimeOfDay(hour: 8, minute: 0),
        dayEnd: const TimeOfDay(hour: 22, minute: 0),
        blockedSlots: [],
        currentSemesterId: null,
      );

      final semester = SemesterModel(
        id: 'sem_1_yr2024',
        semester: 1,
        year: 2024,
        examDates: [],
        subjects: [],
      );

      await provider.save(student, semester);
      provider.clear();

      expect(provider.student, isNull);
      expect(provider.currentSemester, isNull);
      expect(provider.error, isNull);
    });
  });
}