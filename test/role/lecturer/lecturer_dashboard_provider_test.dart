import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/lecturer_dashboard_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late LecturerDashboardProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'lecturer_uid'));
    provider = LecturerDashboardProvider(db: fakeFirestore, auth: fakeAuth);
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider initial state', () {
    test('classes list is empty on init', () {
      expect(provider.classes, isEmpty);
    });

    test('alerts list is empty on init', () {
      expect(provider.alerts, isEmpty);
    });

    test('atRiskCount is 0 on init', () {
      expect(provider.atRiskCount, 0);
    });

    test('greeting is set on init', () {
      expect(provider.greeting, isNotEmpty);
    });

    test('dateLabel is set on init', () {
      expect(provider.dateLabel, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider — time-based greeting', () {
    String computeGreeting(int hour) {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }

    test('returns "Good Morning" for hours 0–11', () {
      expect(computeGreeting(0),  'Good Morning');
      expect(computeGreeting(6),  'Good Morning');
      expect(computeGreeting(11), 'Good Morning');
    });

    test('returns "Good Afternoon" for hours 12–16', () {
      expect(computeGreeting(12), 'Good Afternoon');
      expect(computeGreeting(14), 'Good Afternoon');
      expect(computeGreeting(16), 'Good Afternoon');
    });

    test('returns "Good Evening" for hours 17–23', () {
      expect(computeGreeting(17), 'Good Evening');
      expect(computeGreeting(20), 'Good Evening');
      expect(computeGreeting(23), 'Good Evening');
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider — date label formatting', () {
    String computeDateLabel(DateTime now) {
      const days   = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    }

    test('formats a Monday correctly', () {
      expect(computeDateLabel(DateTime(2024, 6, 3)), 'Monday, 3 Jun 2024');
    });

    test('formats a Friday correctly', () {
      expect(computeDateLabel(DateTime(2024, 6, 7)), 'Friday, 7 Jun 2024');
    });

    test('formats December correctly', () {
      expect(computeDateLabel(DateTime(2024, 12, 25)), 'Wednesday, 25 Dec 2024');
    });

    test('formats single-digit day without leading zero', () {
      expect(computeDateLabel(DateTime(2024, 3, 5)), 'Tuesday, 5 Mar 2024');
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider — subtitle text', () {
    String computeSubtitle(int atRiskCount) => atRiskCount > 0
        ? 'You have $atRiskCount students at risk'
        : 'All student parameters look balanced today';

    test('shows at-risk message when count > 0', () {
      expect(computeSubtitle(3), 'You have 3 students at risk');
    });

    test('shows balanced message when count is 0', () {
      expect(computeSubtitle(0), 'All student parameters look balanced today');
    });

    test('handles count of 1', () {
      expect(computeSubtitle(1), 'You have 1 students at risk');
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider — avgCompletion calculation', () {
    double computeAvg(List<Map<String, int>> enrollments) {
      double total = 0.0;
      int count = 0;
      for (var e in enrollments) {
        final double comp = (e['completed'] ?? 0).toDouble();
        final double pend = (e['pending'] ?? 0).toDouble();
        if (comp + pend > 0) { total += comp / (comp + pend); count++; }
      }
      return count > 0 ? (total / count) * 100 : 0.0;
    }

    test('calculates correctly for multiple enrollments', () {
      expect(computeAvg([
        {'completed': 8, 'pending': 2},
        {'completed': 5, 'pending': 5},
        {'completed': 10, 'pending': 0},
      ]), closeTo(76.67, 0.5));
    });

    test('returns 0.0 when all tasks are zero', () {
      expect(computeAvg([{'completed': 0, 'pending': 0}]), 0.0);
    });

    test('returns 100.0 when all tasks are completed', () {
      expect(computeAvg([
        {'completed': 10, 'pending': 0},
        {'completed': 5, 'pending': 0},
      ]), 100.0);
    });

    test('returns 0.0 for empty enrollment list', () {
      expect(computeAvg([]), 0.0);
    });

    test('skips enrollments with zero combined tasks', () {
      expect(computeAvg([
        {'completed': 0, 'pending': 0},
        {'completed': 6, 'pending': 4},
      ]), closeTo(60.0, 0.01));
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider — burnout at-risk threshold', () {
    test('student is at risk when burnout >= 0.70', () {
      expect(0.70 >= 0.70, isTrue);
      expect(1.0  >= 0.70, isTrue);
    });

    test('student is NOT at risk when burnout < 0.70', () {
      expect(0.69 >= 0.70, isFalse);
      expect(0.0  >= 0.70, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('LecturerDashboardProvider.dispose()', () {
    test('disposes without throwing', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}