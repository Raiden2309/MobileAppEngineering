import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../controllers/change_password_controller.dart';
import '../models/change_password_request.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final ChangePasswordController _controller = ChangePasswordController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  String? validateEmail(String email) => _controller.validateEmail(email);
  String? validatePassword(String password) => _controller.validatePassword(password);
  String? validateConfirmPassword(String password, String confirm) =>
      _controller.validateConfirmPassword(password, confirm);

  Future<String?> sendOtp(String email) async {
    final error = _controller.validateEmail(email);
    if (error != null) return error;

    _setLoading(true);
    try {
      await ApiService.post('/auth/forgot-password', {'email': email});
      _setError(null);
      return null;
    } catch (e) {
      _setError('Failed to send code. Please try again.');
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    if (otp.length < 6) return 'Enter all 6 digits.';

    _setLoading(true);
    try {
      await ApiService.post('/auth/verify-otp', {'email': email, 'otp': otp});
      _setError(null);
      return null;
    } catch (e) {
      _setError('Incorrect or expired code.');
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> updatePassword({
    required String password,
    required String confirm,
    required Object request,
  }) async {
    final passError = _controller.validatePassword(password);
    if (passError != null) return passError;

    final confirmError = _controller.validateConfirmPassword(password, confirm);
    if (confirmError != null) return confirmError;

    _setLoading(true);
    try {
      final hashed = _controller.hashPassword(password);

      if (request is ChangePasswordRequest) {
        final payload = request.copyWith(hashedNewPassword: hashed);
        await ApiService.post('/auth/change-password', payload.toJson());
      } else if (request is ForgotPasswordRequest) {
        final payload = request.copyWith(hashedNewPassword: hashed);
        await ApiService.post('/auth/reset-password', payload.toJson());
      }

      _setError(null);
      return null;
    } catch (e) {
      _setError('Failed to update password. Please try again.');
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }
}