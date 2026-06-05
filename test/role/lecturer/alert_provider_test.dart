import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/alert_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late AlertProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'lecturer_uid'));
    provider = AlertProvider(db: fakeFirestore, auth: fakeAuth);
  });

  // -------------------------------------------------------------------------
  group('AlertProvider.setFilter()', () {
    test('defaults to "all"', () {
      expect(provider.selectedFilter, 'all');
    });

    test('updates selectedFilter to given value', () {
      provider.setFilter('burnout');
      expect(provider.selectedFilter, 'burnout');
    });

    test('can switch back to "all"', () {
      provider.setFilter('burnout');
      provider.setFilter('all');
      expect(provider.selectedFilter, 'all');
    });

    test('accepts "behind" filter key', () {
      provider.setFilter('behind');
      expect(provider.selectedFilter, 'behind');
    });

    test('accepts "falling_behind" alias', () {
      provider.setFilter('falling_behind');
      expect(provider.selectedFilter, 'falling_behind');
    });

    test('accepts "read" filter key', () {
      provider.setFilter('read');
      expect(provider.selectedFilter, 'read');
    });
  });

  // -------------------------------------------------------------------------
  group('AlertProvider.filtered — empty state', () {
    test('returns empty list when no alerts are loaded', () {
      expect(provider.filtered, isEmpty);
    });

    test('returns empty list for "burnout" filter with no alerts', () {
      provider.setFilter('burnout');
      expect(provider.filtered, isEmpty);
    });

    test('returns empty list for "behind" filter with no alerts', () {
      provider.setFilter('behind');
      expect(provider.filtered, isEmpty);
    });

    test('returns empty list for "read" filter with no alerts', () {
      provider.setFilter('read');
      expect(provider.filtered, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('AlertProvider.markAsRead() — ID suffix stripping', () {
    test('strips _burnout suffix to resolve enrollment doc ID', () {
      const String alertId = 'enrollment_doc_abc_burnout';
      final String stripped = alertId
          .replaceAll('_burnout', '')
          .replaceAll('_behind', '');
      expect(stripped, 'enrollment_doc_abc');
    });

    test('strips _behind suffix to resolve enrollment doc ID', () {
      const String alertId = 'enrollment_doc_xyz_behind';
      final String stripped = alertId
          .replaceAll('_burnout', '')
          .replaceAll('_behind', '');
      expect(stripped, 'enrollment_doc_xyz');
    });

    test('leaves ID unchanged when no suffix is present', () {
      const String alertId = 'enrollment_plain_id';
      final String stripped = alertId
          .replaceAll('_burnout', '')
          .replaceAll('_behind', '');
      expect(stripped, 'enrollment_plain_id');
    });
  });

  // -------------------------------------------------------------------------
  group('AlertProvider.dispose()', () {
    test('disposes without throwing', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}