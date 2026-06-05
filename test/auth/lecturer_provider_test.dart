import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/models/lecturer_model.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/provider/lecturer_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late LecturerProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'lec1'));
    provider = LecturerProvider(db: fakeFirestore, auth: fakeAuth);
  });

  group('LecturerProvider.fetch()', () {
    test('sets lecturer when document exists', () async {
      await fakeFirestore.collection('lecturers').doc('lec1').set({
        'id': 'lec1',
        'name': 'Dr. Smith',
        'email': 'smith@uni.edu',
        'programme': 'Computing',
        'classes': [],
      });

      await provider.fetch();

      expect(provider.lecturer, isNotNull);
      expect(provider.lecturer!.name, 'Dr. Smith');
      expect(provider.loading, false);
      expect(provider.error, isNull);
    });

    test('lecturer remains null when document does not exist', () async {
      await provider.fetch();

      expect(provider.lecturer, isNull);
      expect(provider.loading, false);
    });
  });

  group('LecturerProvider.save()', () {
    test('saves lecturer and updates local state', () async {
      final model = LecturerModel(
        id: 'lec1',
        name: 'Dr. Smith',
        email: 'smith@uni.edu',
        programme: 'Computing',
        classes: [],
      );

      await provider.save(model);

      expect(provider.lecturer, isNotNull);
      expect(provider.lecturer!.name, 'Dr. Smith');
      expect(provider.lecturer!.programme, 'Computing');
      expect(provider.loading, false);
      expect(provider.error, isNull);
    });
  });

  group('LecturerProvider.clear()', () {
    test('resets lecturer and error to null', () async {
      final model = LecturerModel(
        id: 'lec1',
        name: 'Dr. Smith',
        email: 'smith@uni.edu',
        programme: 'Computing',
        classes: [],
      );

      await provider.save(model);
      provider.clear();

      expect(provider.lecturer, isNull);
      expect(provider.error, isNull);
    });
  });
}