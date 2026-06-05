import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/task_provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/tasks_model.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/app_enums.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late TasksProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid1'),
    );
    provider = TasksProvider(db: fakeFirestore, auth: fakeAuth);
  });

  group('TasksProvider.setFilter()', () {
    test('updates activeFilter', () {
      provider.setFilter('completed');
      expect(provider.activeFilter, 'completed');
    });

    test('defaults to all', () {
      expect(provider.activeFilter, 'all');
    });
  });

  group('TasksProvider.filteredTasks()', () {
    final tasks = [
      Task(
        id: '1',
        title: 'Task A',
        estimatedHours: 2,
        status: TaskStatus.completed,
      ),
      Task(
        id: '2',
        title: 'Task B',
        estimatedHours: 1,
        status: TaskStatus.inProgress,
      ),
      Task(
        id: '3',
        title: 'Task C',
        estimatedHours: 3,
        status: TaskStatus.toDo,
      ),
      Task(
        id: '4',
        title: 'Task D',
        estimatedHours: 1,
        status: TaskStatus.toDo,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ];

    test('returns all tasks when filter is all', () {
      provider.setFilter('all');
      expect(provider.filteredTasks(tasks).length, 4);
    });

    test('returns only completed tasks', () {
      provider.setFilter('completed');
      final result = provider.filteredTasks(tasks);
      expect(result.length, 1);
      expect(result.first.status, TaskStatus.completed);
    });

    test('returns only inProgress tasks', () {
      provider.setFilter('inProgress');
      final result = provider.filteredTasks(tasks);
      expect(result.length, 1);
      expect(result.first.status, TaskStatus.inProgress);
    });

    test('returns only dueSoon tasks', () {
      provider.setFilter('dueSoon');
      final result = provider.filteredTasks(tasks);
      expect(result.length, 1);
      expect(result.first.id, '4');
    });

    test('returns toDo tasks when filter is toDo', () {
      provider.setFilter('toDo');
      final result = provider.filteredTasks(tasks);
      expect(
        result.every(
          (t) => t.status == TaskStatus.toDo || t.status == TaskStatus.upcoming,
        ),
        true,
      );
    });
  });

  group('TasksProvider computed properties', () {
    test('totalTasksCount sums all tasks across groups', () {
      provider.groups = [
        SubjectGroup(
          id: '1',
          name: 'Sub A',
          tasks: [
            Task(
              id: '1',
              title: 'T1',
              estimatedHours: 1,
              status: TaskStatus.toDo,
            ),
            Task(
              id: '2',
              title: 'T2',
              estimatedHours: 1,
              status: TaskStatus.completed,
            ),
          ],
        ),
        SubjectGroup(
          id: '2',
          name: 'Sub B',
          tasks: [
            Task(
              id: '3',
              title: 'T3',
              estimatedHours: 1,
              status: TaskStatus.toDo,
            ),
          ],
        ),
      ];
      expect(provider.totalTasksCount, 3);
    });

    test('pendingTasksCount excludes completed tasks', () {
      provider.groups = [
        SubjectGroup(
          id: '1',
          name: 'Sub A',
          tasks: [
            Task(
              id: '1',
              title: 'T1',
              estimatedHours: 1,
              status: TaskStatus.toDo,
            ),
            Task(
              id: '2',
              title: 'T2',
              estimatedHours: 1,
              status: TaskStatus.completed,
            ),
            Task(
              id: '3',
              title: 'T3',
              estimatedHours: 1,
              status: TaskStatus.inProgress,
            ),
          ],
        ),
      ];
      expect(provider.pendingTasksCount, 2);
    });
  });
}
