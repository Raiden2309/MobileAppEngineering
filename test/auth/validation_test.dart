import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/auth/services/validation_service.dart';

void main() {
  group('ValidationService - Email Validation', () {
    test('Empty email returns required error', () {
      final result = ValidationService.validateEmail('');
      expect(result, 'Email is required.');
    });

    test('Invalid email format returns format error', () {
      final result = ValidationService.validateEmail('notanemail');
      expect(result, 'Enter a valid email address.');
    });

    test('Invalid email missing domain returns format error', () {
      final result = ValidationService.validateEmail('user@');
      expect(result, 'Enter a valid email address.');
    });

    test('Valid email returns null', () {
      final result = ValidationService.validateEmail('user@example.com');
      expect(result, null);
    });
  });

  group('ValidationService - Password Validation', () {
    test('Empty password returns required error', () {
      final result = ValidationService.validatePassword('');
      expect(result, 'Password is required.');
    });

    test('Password under 6 characters returns length error', () {
      final result = ValidationService.validatePassword('123');
      expect(result, 'Password must be at least 6 characters.');
    });

    test('Password with exactly 6 characters returns null', () {
      final result = ValidationService.validatePassword('abc123');
      expect(result, null);
    });

    test('Valid password returns null', () {
      final result = ValidationService.validatePassword('securePassword123');
      expect(result, null);
    });
  });

  group('ValidationService - Confirm Password Validation', () {
    test('Empty confirm password returns required error', () {
      final result = ValidationService.validateConfirmPassword('password123', '');
      expect(result, 'Please confirm your password.');
    });

    test('Non-matching passwords returns mismatch error', () {
      final result = ValidationService.validateConfirmPassword('password123', 'different123');
      expect(result, 'Passwords do not match.');
    });

    test('Matching passwords returns null', () {
      final result = ValidationService.validateConfirmPassword('password123', 'password123');
      expect(result, null);
    });
  });
}