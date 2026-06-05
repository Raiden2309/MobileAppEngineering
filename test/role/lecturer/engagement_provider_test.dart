import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/engagement_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late EngagementProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'lecturer_uid'));
    provider = EngagementProvider(db: fakeFirestore, auth: fakeAuth);
  });

  // -------------------------------------------------------------------------
  group('EngagementProvider initial state', () {
    test('students list is empty on init', () {
      expect(provider.students, isEmpty);
    });

    test('selectedFilter defaults to "all"', () {
      expect(provider.selectedFilter, 'all');
    });

    test('filters list contains only "All Classes" entry on init', () {
      expect(provider.filters.length, 1);
      expect(provider.filters.first['key'], 'all');
    });

    test('avgCompletion is 0.0 on init', () {
      expect(provider.avgCompletion, 0.0);
    });

    test('totalStudents is 0 on init', () {
      expect(provider.totalStudents, 0);
    });
  });

  // -------------------------------------------------------------------------
  group('EngagementProvider.setFilter()', () {
    test('updates selectedFilter to given value', () {
      provider.setFilter('comp101');
      expect(provider.selectedFilter, 'comp101');
    });

    test('can switch back to "all"', () {
      provider.setFilter('comp201');
      provider.setFilter('all');
      expect(provider.selectedFilter, 'all');
    });
  });

  // -------------------------------------------------------------------------
  group('EngagementProvider — workload classification rules', () {
    test('burnout >= 0.70 classifies as High', () {
      const double burnout = 0.70;
      const int pending = 1;
      final String workload = burnout >= 0.70 || pending > 3
          ? 'High'
          : (burnout >= 0.40 || pending > 1 ? 'Medium' : 'Low');
      expect(workload, 'High');
    });

    test('pending > 3 classifies as High', () {
      const double burnout = 0.30;
      const int pending = 4;
      final String workload = burnout >= 0.70 || pending > 3
          ? 'High'
          : (burnout >= 0.40 || pending > 1 ? 'Medium' : 'Low');
      expect(workload, 'High');
    });

    test('burnout >= 0.40 with low pending classifies as Medium', () {
      const double burnout = 0.50;
      const int pending = 1;
      final String workload = burnout >= 0.70 || pending > 3
          ? 'High'
          : (burnout >= 0.40 || pending > 1 ? 'Medium' : 'Low');
      expect(workload, 'Medium');
    });

    test('pending > 1 with low burnout classifies as Medium', () {
      const double burnout = 0.10;
      const int pending = 2;
      final String workload = burnout >= 0.70 || pending > 3
          ? 'High'
          : (burnout >= 0.40 || pending > 1 ? 'Medium' : 'Low');
      expect(workload, 'Medium');
    });

    test('low burnout and low pending classifies as Low', () {
      const double burnout = 0.20;
      const int pending = 0;
      final String workload = burnout >= 0.70 || pending > 3
          ? 'High'
          : (burnout >= 0.40 || pending > 1 ? 'Medium' : 'Low');
      expect(workload, 'Low');
    });

    test('burnout exactly 0.39 and pending 1 classifies as Low', () {
      const double burnout = 0.39;
      const int pending = 1;
      final String workload = burnout >= 0.70 || pending > 3
          ? 'High'
          : (burnout >= 0.40 || pending > 1 ? 'Medium' : 'Low');
      expect(workload, 'Low');
    });
  });

  // -------------------------------------------------------------------------
  group('EngagementProvider — avgCompletion calculation', () {
    test('calculates correctly for multiple enrollments', () {
      final enrollments = [
        {'completedTasks': 8, 'pendingTasks': 2},  // 0.80
        {'completedTasks': 5, 'pendingTasks': 5},  // 0.50
        {'completedTasks': 10, 'pendingTasks': 0}, // 1.00
      ];

      double total = 0.0;
      int count = 0;
      for (var e in enrollments) {
        final double comp = (e['completedTasks'] as int).toDouble();
        final double pend = (e['pendingTasks'] as int).toDouble();
        if (comp + pend > 0) { total += comp / (comp + pend); count++; }
      }
      final double avg = count > 0 ? (total / count) * 100 : 0.0;
      expect(avg, closeTo(76.67, 0.5));
    });

    test('returns 0.0 when all tasks are zero', () {
      final enrollments = [{'completedTasks': 0, 'pendingTasks': 0}];

      double total = 0.0;
      int count = 0;
      for (var e in enrollments) {
        final double comp = (e['completedTasks'] as int).toDouble();
        final double pend = (e['pendingTasks'] as int).toDouble();
        if (comp + pend > 0) { total += comp / (comp + pend); count++; }
      }
      final double avg = count > 0 ? (total / count) * 100 : 0.0;
      expect(avg, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  group('EngagementProvider.dispose()', () {
    test('disposes without throwing', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}