import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/semester_progress_provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/semester_progress_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late SemesterProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    provider = SemesterProvider(db: fakeFirestore, auth: fakeAuth);
  });

  group('SemesterProvider.semesterLabel', () {
    test('returns empty string when no semester is set', () {
      expect(provider.semesterLabel, '');
    });
  });

  group('SemesterProvider.updateSubjectsAuthoritativeList()', () {
    test('creates new subjects when data is null', () {
      provider.updateSubjectsAuthoritativeList([
        {'name': 'Mobile Dev', 'code': 'MOB401'},
        {'name': 'Research Methods', 'code': 'RM302'},
      ]);

      expect(provider.data, isNotNull);
      expect(provider.data!.subjects.length, 2);
      expect(provider.data!.subjects[0].name, 'Mobile Dev');
      expect(provider.data!.subjects[1].name, 'Research Methods');
    });

    test('preserves existing subject progress when name matches', () {
      provider.data = const SemesterProgressModel(
        semesterName: 'Sem 1',
        dateRange: '',
        overallProgress: 0.5,
        completedTasks: 5,
        totalTasks: 10,
        currentWeek: 4,
        totalWeeks: 14,
        timelineProgress: 0.3,
        weeksRemaining: 10,
        finalExamDate: 'Not Set',
        subjects: [
          SubjectProgress(
            name: 'Mobile Dev',
            code: 'MOB401',
            progress: 0.8,
            completed: 4,
            remaining: 1,
            dueSoon: 0,
          ),
        ],
      );

      provider.updateSubjectsAuthoritativeList([
        {'name': 'Mobile Dev', 'code': 'MOB401'},
      ]);

      expect(provider.data!.subjects[0].progress, 0.8);
      expect(provider.data!.subjects[0].completed, 4);
    });

    test('adds new subject with zero progress when not in existing data', () {
      provider.data = const SemesterProgressModel(
        semesterName: 'Sem 1',
        dateRange: '',
        overallProgress: 0.0,
        completedTasks: 0,
        totalTasks: 0,
        currentWeek: 1,
        totalWeeks: 14,
        timelineProgress: 0.0,
        weeksRemaining: 13,
        finalExamDate: 'Not Set',
        subjects: [],
      );

      provider.updateSubjectsAuthoritativeList([
        {'name': 'New Subject', 'code': 'NS101'},
      ]);

      expect(provider.data!.subjects.length, 1);
      expect(provider.data!.subjects[0].progress, 0.0);
      expect(provider.data!.subjects[0].completed, 0);
    });

    test('removes subjects not in the updated list', () {
      provider.data = const SemesterProgressModel(
        semesterName: 'Sem 1',
        dateRange: '',
        overallProgress: 0.0,
        completedTasks: 0,
        totalTasks: 0,
        currentWeek: 1,
        totalWeeks: 14,
        timelineProgress: 0.0,
        weeksRemaining: 13,
        finalExamDate: 'Not Set',
        subjects: [
          SubjectProgress(name: 'Old Subject', code: 'OS001', progress: 0.5, completed: 2, remaining: 2, dueSoon: 0),
          SubjectProgress(name: 'Keep Subject', code: 'KS001', progress: 0.2, completed: 1, remaining: 4, dueSoon: 0),
        ],
      );

      provider.updateSubjectsAuthoritativeList([
        {'name': 'Keep Subject', 'code': 'KS001'},
      ]);

      expect(provider.data!.subjects.length, 1);
      expect(provider.data!.subjects[0].name, 'Keep Subject');
    });
  });
}