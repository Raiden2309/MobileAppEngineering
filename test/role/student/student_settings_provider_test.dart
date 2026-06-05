import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/student_settings_models.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/student_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FlutterSecureStorage.setMockInitialValues({});

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late MockFirebaseStorage fakeStorage;
  late StudentSettingsProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth      = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    fakeStorage   = MockFirebaseStorage();
    provider      = StudentSettingsProvider(
      db:        fakeFirestore,
      auth:      fakeAuth,
      fbStorage: fakeStorage,
      testMode:  true,
    );
  });

  group('StudentSettingsProvider.setData()', () {
    test('correctly applies all fields from model', () {
      final model = StudentSettingsModel(
        userId: 1,
        userName: 'Jake',
        semester: '1',
        year: 2,
        subjectCount: 3,
        studyHoursStart: '8:00',
        studyHoursEnd: '22:00',
        blockedSlotsCount: 2,
        taskReminders: true,
        slotEndPrompts: false,
        burnoutWarnings: true,
        weeklyResetSummary: false,
        blockedSlots: {'MON-08:00', 'TUE-10:00'},
        semesters: [],
      );

      provider.setData(model);

      expect(provider.currentLiveName, 'Jake');
      expect(provider.taskReminders, true);
      expect(provider.burnoutWarnings, true);
      expect(provider.slotEndPrompts, false);
      expect(provider.weeklyResetSummary, false);
      expect(provider.blockedSlots.length, 2);
    });
  });

  group('StudentSettingsProvider toggle methods', () {
    test('toggleTaskReminders flips state', () async {
      final initial = provider.taskReminders;
      await provider.toggleTaskReminders();
      expect(provider.taskReminders, !initial);
    });

    test('toggleSlotEndPrompts flips state', () async {
      final initial = provider.slotEndPrompts;
      await provider.toggleSlotEndPrompts();
      expect(provider.slotEndPrompts, !initial);
    });

    test('toggleBurnoutWarnings flips state', () async {
      final initial = provider.burnoutWarnings;
      await provider.toggleBurnoutWarnings();
      expect(provider.burnoutWarnings, !initial);
    });

    test('toggleWeeklyResetSummary flips state', () async {
      final initial = provider.weeklyResetSummary;
      await provider.toggleWeeklyResetSummary();
      expect(provider.weeklyResetSummary, !initial);
    });
  });

  group('StudentSettingsProvider.setError()', () {
    test('sets error message and loading to false', () {
      provider.setLoading(true);
      provider.setError('Something went wrong');
      expect(provider.error, 'Something went wrong');
      expect(provider.loading, false);
    });
  });

  group('StudentSettingsProvider.updateAvatar()', () {
    test('does not throw when fbStorage is injected', () async {
      expect(() async => provider.updateAvatar(XFile('fake/path/avatar.jpg')), returnsNormally);
    });
  });

  group('StudentSettingsProvider computed properties', () {
    test('studyHoursDisplay formats correctly', () {
      provider.studyStart = const TimeOfDay(hour: 8, minute: 0);
      provider.studyEnd   = const TimeOfDay(hour: 22, minute: 0);
      expect(provider.studyHoursDisplay, contains('AM'));
      expect(provider.studyHoursDisplay, contains('PM'));
    });

    test('blockedSlotsCount matches blockedSlots length', () {
      provider.blockedSlots = {'MON-08:00', 'WED-14:00'};
      expect(provider.blockedSlotsCount, 2);
    });

    test('subjectCount matches subjects length', () {
      provider.subjects = [
        {'name': 'CT124', 'code': 'CT124'},
        {'name': 'RM302', 'code': 'RM302'},
      ];
      expect(provider.subjectCount, 2);
    });
  });
}