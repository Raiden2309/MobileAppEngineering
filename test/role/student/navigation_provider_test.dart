import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/role/student/providers/navigation_provider.dart';

void main() {
  late NavigationProvider provider;

  setUp(() {
    provider = NavigationProvider();
  });

  group('NavigationProvider.setCurrentIndex()', () {
    test('updates previousIndex', () {
      provider.setCurrentIndex(2);
      expect(provider.previousIndex, 2);
    });

    test('previousPage returns previousIndex', () {
      provider.setCurrentIndex(3);
      expect(provider.previousPage, 3);
    });

    test('updates correctly across multiple calls', () {
      provider.setCurrentIndex(1);
      provider.setCurrentIndex(4);
      expect(provider.previousIndex, 4);
    });
  });
}