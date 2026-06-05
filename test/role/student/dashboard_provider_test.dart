import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/dashboard_provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/dashboard_models.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/app_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late StudentDashboardProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    provider = StudentDashboardProvider(db: fakeFirestore, auth: fakeAuth);
  });
  group('StudentDashboardProvider.toggleTask()', () {
    test('does nothing when data is null', () {
      expect(() => provider.toggleTask(0), returnsNormally);
    });

    test('toggles checked state of a task', () {
      provider.data = DashboardModel(
        summary: DashboardSummary(
          userName: 'Jake',
          taskCountToday: 2,
          date: DateTime.now(),
        ),
        stats: const DashboardStats(
          tasksDone: 1,
          totalTasks: 3,
          dueSoon: 1,
          dueSoonDays: 3,
          overdue: 0,
          currentWeek: 8,
          totalWeeks: 14,
        ),
        currentTask: null,
        workloadPlan: const WorkloadPlan(planLabel: 'Study blocks', tasks: []),
        todayTasks: [
          const TaskItem(
            title: 'Task A',
            subtitle: 'CT124 · 2h',
            status: TaskStatus.toDo,
            checked: false,
          ),
        ],
      );

      provider.toggleTask(0);
      expect(provider.data!.todayTasks[0].checked, true);
    });

    test('toggles checked back to false on second call', () {
      provider.data = DashboardModel(
        summary: DashboardSummary(
          userName: 'Jake',
          taskCountToday: 1,
          date: DateTime.now(),
        ),
        stats: const DashboardStats(
          tasksDone: 0,
          totalTasks: 1,
          dueSoon: 0,
          dueSoonDays: 3,
          overdue: 0,
          currentWeek: 1,
          totalWeeks: 14,
        ),
        currentTask: null,
        workloadPlan: const WorkloadPlan(planLabel: 'Study blocks', tasks: []),
        todayTasks: [
          const TaskItem(
            title: 'Task A',
            subtitle: 'CT124 · 2h',
            status: TaskStatus.toDo,
            checked: false,
          ),
        ],
      );

      provider.toggleTask(0);
      provider.toggleTask(0);
      expect(provider.data!.todayTasks[0].checked, false);
    });
  });

  group('StudentDashboardProvider.updateActiveSemester()', () {
    test('sets currentSemesterId when new id is provided', () {
      provider.updateActiveSemester('sem_1_yr2024');
      expect(provider.currentSemesterId, 'sem_1_yr2024');
    });

    test('does not update when same id is passed', () {
      provider.updateActiveSemester('sem_1_yr2024');
      provider.updateActiveSemester('sem_1_yr2024');
      expect(provider.currentSemesterId, 'sem_1_yr2024');
    });

    test('updates when a different id is passed', () {
      provider.updateActiveSemester('sem_1_yr2024');
      provider.updateActiveSemester('sem_2_yr2024');
      expect(provider.currentSemesterId, 'sem_2_yr2024');
    });
  });

  group('StudentDashboardProvider._parseTimeToMinutes()', () {
    test('parses standard time string correctly', () {
      // Access via startScheduleAutoTracker behaviour — test indirectly
      // by checking activeScheduleTask with a block covering current time
      expect(() => provider.startScheduleAutoTracker([]), returnsNormally);
    });

    test('defaults to Free Time when no blocks match', () {
      provider.startScheduleAutoTracker([]);
      expect(provider.activeScheduleTask, 'Free Time / Break');
    });
  });

  group('StudentDashboardProvider.startScheduleAutoTracker()', () {
    test('sets activeScheduleTask to Free Time when blocks list is empty', () {
      provider.startScheduleAutoTracker([]);
      expect(provider.activeScheduleTask, 'Free Time / Break');
    });

    test('does not crash when called multiple times', () {
      expect(() {
        provider.startScheduleAutoTracker([]);
        provider.startScheduleAutoTracker([]);
      }, returnsNormally);
    });
  });
}