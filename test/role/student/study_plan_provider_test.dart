import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/study_plan_provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/study_plan_model.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/app_enums.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late StudyPlanProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    provider = StudyPlanProvider(db: fakeFirestore, auth: fakeAuth);
  });


  final mockPlan = WeekPlan(
    lastUpdated: DateTime(2024, 1, 1),
    days: [
      DayPlan(
        date: DateTime(2024, 1, 1),
        blocks: [
          const StudyBlock(
            title: 'Study Session',
            startTime: '09:00',
            durationMinutes: 60,
            type: BlockType.study,
            status: BlockStatus.toDo,
          ),
          const StudyBlock(
            title: 'Short Break',
            startTime: '10:00',
            durationMinutes: 15,
            type: BlockType.breakSlot,
          ),
        ],
      ),
    ],
  );

  group('StudyPlanProvider.setPlan()', () {
    test('sets the plan', () {
      provider.setPlan(mockPlan);
      expect(provider.plan, isNotNull);
      expect(provider.plan!.days.length, 1);
    });
  });

  group('StudyPlanProvider.updateBlock()', () {
    test('replaces block at given day and block index', () {
      provider.setPlan(mockPlan);

      const updated = StudyBlock(
        title: 'Updated Block',
        startTime: '09:00',
        durationMinutes: 90,
        type: BlockType.study,
        status: BlockStatus.inProgress,
      );

      provider.updateBlock(0, 0, updated);

      expect(provider.plan!.days[0].blocks[0].title, 'Updated Block');
      expect(provider.plan!.days[0].blocks[0].durationMinutes, 90);
      expect(provider.plan!.days[0].blocks[0].status, BlockStatus.inProgress);
    });

    test('does nothing when plan is null', () {
      expect(() => provider.updateBlock(0, 0, const StudyBlock(
        title: 'X',
        startTime: '09:00',
        durationMinutes: 30,
        type: BlockType.study,
      )), returnsNormally);
    });
  });
}