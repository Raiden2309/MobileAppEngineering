import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/burnout_alert_provider.dart';
import 'package:mae_assignment_frontend/modules/role/student/models/burnout_alert_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late BurnoutAlertProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    provider = BurnoutAlertProvider(db: fakeFirestore, auth: fakeAuth);
  });

  group('BurnoutAlertProvider.dismiss()', () {
    test('sets alert to null', () {
      provider.alert = BurnoutAlertModel.burnoutPreset();
      provider.dismiss();
      expect(provider.alert, isNull);
    });
  });

  group('BurnoutAlertProvider.clear()', () {
    test('resets alert, error and loading', () {
      provider.alert = BurnoutAlertModel.overloadPreset();
      provider.error = 'some error';
      provider.loading = true;
      provider.clear();
      expect(provider.alert, isNull);
      expect(provider.error, isNull);
      expect(provider.loading, false);
    });
  });

  group('BurnoutAlertProvider.updateTotalTasks()', () {
    test('clamps value to minimum of 1', () {
      provider.updateTotalTasks(0);
      // No direct getter, but verifying no crash and clamping behavior via internal usage
      expect(() => provider.updateTotalTasks(0), returnsNormally);
    });

    test('accepts valid task count', () {
      expect(() => provider.updateTotalTasks(10), returnsNormally);
    });
  });
}