import 'dart:math';
import '../../../../shared/services/api_service.dart';

class OtpEmailService {
  static String generateOtp() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  static Future<void> sendOtp({
    required String toEmail,
    required String otp,
  }) async {
    await ApiService.post('/auth/send-otp', {
      'email': toEmail,
      'otp': otp,
    });
  }
}