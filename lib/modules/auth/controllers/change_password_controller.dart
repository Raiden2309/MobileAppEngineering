import 'package:bcrypt/bcrypt.dart';
import '../../../shared/services/api_service.dart';
import '../models/change_password_request.dart';

class ChangePasswordController {
  String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required.';
    if (!email.contains('@')) return 'Enter a valid email address.';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Please confirm your password.';
    if (password != confirm) return 'Passwords do not match.';
    return null;
  }

  Future<String?> sendOtp(String email) async {
    final error = validateEmail(email);
    if (error != null) return error;

    try {
      await ApiService.post('/auth/forgot-password', {'email': email});
      return null;
    } catch (e) {
      return 'Failed to send code. Please try again.';
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    if (otp.length < 6) return 'Enter all 6 digits.';

    try {
      await ApiService.post('/auth/verify-otp', {'email': email, 'otp': otp});
      return null;
    } catch (e) {
      return 'Incorrect or expired code.';
    }
  }

  Future<String?> updatePassword({
    required String password,
    required String confirm,
    required Object request,
  }) async {
    final passError = validatePassword(password);
    if (passError != null) return passError;

    final confirmError = validateConfirmPassword(password, confirm);
    if (confirmError != null) return confirmError;

    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());

    try {
      if (request is ChangePasswordRequest) {
        final payload = request.copyWith(hashedNewPassword: hashed);
        await ApiService.post('/auth/change-password', payload.toJson());
      } else if (request is ForgotPasswordRequest) {
        final payload = request.copyWith(hashedNewPassword: hashed);
        await ApiService.post('/auth/reset-password', payload.toJson());
      }
      return null;
    } catch (e) {
      return 'Failed to update password. Please try again.';
    }
  }
}