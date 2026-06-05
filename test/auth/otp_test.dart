import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment_frontend/modules/auth/providers/otp_provider.dart';

void main() {
  group('OtpProvider - OTP Validation', () {
    test('isValid returns false when no OTP has been stored', () {
      final provider = OtpProvider();
      expect(provider.isValid, false);
    });

    test('isValid returns true after storing a valid OTP', () {
      final provider = OtpProvider();
      provider.store('123456');
      expect(provider.isValid, true);
    });

    test('verify returns true for correct OTP', () {
      final provider = OtpProvider();
      provider.store('123456');
      expect(provider.verify('123456'), true);
    });

    test('verify returns false for incorrect OTP', () {
      final provider = OtpProvider();
      provider.store('123456');
      expect(provider.verify('999999'), false);
    });

    test('verify returns false after clear is called', () {
      final provider = OtpProvider();
      provider.store('123456');
      provider.clear();
      expect(provider.verify('123456'), false);
    });

    test('isValid returns false after clear is called', () {
      final provider = OtpProvider();
      provider.store('123456');
      provider.clear();
      expect(provider.isValid, false);
    });

    test('isValid returns false when OTP is expired', () {
      final provider = OtpProvider();
      provider.store('123456');
      // Manually force expiry
      provider.expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      expect(provider.isValid, false);
    });

    test('verify returns false when OTP is expired', () {
      final provider = OtpProvider();
      provider.store('123456');
      // Manually force expiry
      provider.expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      expect(provider.verify('123456'), false);
    });
  });
}