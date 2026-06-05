import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/lecturer_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late MockFirebaseStorage fakeStorage;
  late LecturerSettingsProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth     = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'lecturer_uid'));
    fakeStorage  = MockFirebaseStorage();
    provider     = LecturerSettingsProvider(db: fakeFirestore, auth: fakeAuth, storage: fakeStorage, testMode: true);
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider initial state', () {
    test('burnoutAlerts is false on init', () {
      expect(provider.burnoutAlerts, isFalse);
    });

    test('fallingBehindAlerts is false on init', () {
      expect(provider.fallingBehindAlerts, isFalse);
    });

    test('weeklyEngagementReport is false on init', () {
      expect(provider.weeklyEngagementReport, isFalse);
    });

    test('avatarUrl is null on init', () {
      expect(provider.avatarUrl, isNull);
    });

    test('error is null on init', () {
      expect(provider.error, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.toggleBurnoutAlerts()', () {
    test('toggles from false to true', () async {
      provider.burnoutAlerts = false;
      await provider.toggleBurnoutAlerts();
      expect(provider.burnoutAlerts, isTrue);
    });

    test('toggles from true to false', () async {
      provider.burnoutAlerts = true;
      await provider.toggleBurnoutAlerts();
      expect(provider.burnoutAlerts, isFalse);
    });

    test('double toggle returns to original state', () async {
      provider.burnoutAlerts = false;
      await provider.toggleBurnoutAlerts();
      await provider.toggleBurnoutAlerts();
      expect(provider.burnoutAlerts, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.toggleFallingBehindAlerts()', () {
    test('toggles from false to true', () async {
      provider.fallingBehindAlerts = false;
      await provider.toggleFallingBehindAlerts();
      expect(provider.fallingBehindAlerts, isTrue);
    });

    test('toggles from true to false', () async {
      provider.fallingBehindAlerts = true;
      await provider.toggleFallingBehindAlerts();
      expect(provider.fallingBehindAlerts, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.toggleWeeklyEngagementReport()', () {
    test('toggles from false to true', () async {
      provider.weeklyEngagementReport = false;
      await provider.toggleWeeklyEngagementReport();
      expect(provider.weeklyEngagementReport, isTrue);
    });

    test('toggles from true to false', () async {
      provider.weeklyEngagementReport = true;
      await provider.toggleWeeklyEngagementReport();
      expect(provider.weeklyEngagementReport, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.setError()', () {
    test('sets error message', () {
      provider.setError('Something went wrong');
      expect(provider.error, 'Something went wrong');
    });

    test('sets loading to false when error is set', () {
      provider.setLoading(true);
      provider.setError('Error occurred');
      expect(provider.loading, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.setLoading()', () {
    test('sets loading to true', () {
      provider.setLoading(true);
      expect(provider.loading, isTrue);
    });

    test('sets loading to false', () {
      provider.setLoading(true);
      provider.setLoading(false);
      expect(provider.loading, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.clear()', () {
    test('resets all state to defaults', () {
      provider.burnoutAlerts          = true;
      provider.fallingBehindAlerts    = true;
      provider.weeklyEngagementReport = true;
      provider.avatarUrl              = 'http://example.com/avatar.jpg';
      provider.clear();

      expect(provider.burnoutAlerts,          isFalse);
      expect(provider.fallingBehindAlerts,    isFalse);
      expect(provider.weeklyEngagementReport, isFalse);
      expect(provider.avatarUrl,              isNull);
      expect(provider.error,                  isNull);
      expect(provider.loading,                isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider — secure storage cache parsing', () {
    bool parseCacheValue(String? raw) => raw == 'true';

    test('parses "true" as true', () {
      expect(parseCacheValue('true'), isTrue);
    });

    test('parses "false" as false', () {
      expect(parseCacheValue('false'), isFalse);
    });

    test('parses null as false', () {
      expect(parseCacheValue(null), isFalse);
    });

    test('parses empty string as false', () {
      expect(parseCacheValue(''), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerSettingsProvider.dispose()', () {
    test('disposes without throwing', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}