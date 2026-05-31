import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/change_password_controller.dart';
import 'otp_provider.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final ChangePasswordController _controller = ChangePasswordController();
  final FirebaseAuth             _auth        = FirebaseAuth.instance;
  final OtpProvider              _otpProvider = OtpProvider();

  // ── EmailJS credentials ──
  static const _serviceId  = 'service_50epfyk';
  static const _templateId = 'template_havuzqk';
  static const _publicKey  = 'xfa3Hu7FTxgXDjoy7';
  static const _privateKey = 'mEY96UCMdyUyABePWYJw0';


  bool    _isLoading    = false;
  String? _errorMessage;

  bool    get isLoading     => _isLoading;
  String? get errorMessage  => _errorMessage;

  void _setLoading(bool value) { _isLoading = value; notifyListeners(); }
  void _setError(String? msg)  { _errorMessage = msg; notifyListeners(); }

  String? validateEmail(String email)                              => _controller.validateEmail(email);
  String? validatePassword(String password)                        => _controller.validatePassword(password);
  String? validateConfirmPassword(String password, String confirm) => _controller.validateConfirmPassword(password, confirm);

  Future<String?> sendOtp(String email) async {
    final error = _controller.validateEmail(email);
    if (error != null) return error;

    _setLoading(true);
    try {
      final otp = _generateOtp();
      _otpProvider.store(otp);

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id':  _serviceId,
          'template_id': _templateId,
          'user_id':     _publicKey,
          'accessToken': _privateKey,
          'template_params': {
            'to_email': email.trim(),
            'otp':      otp,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('EmailJS error: ${response.body}');
      }

      _setError(null);
      return null;
    } catch (e) {
      print('EmailJS error: $e'); // add this
      _setError(e.toString());
      _setError('Failed to send code. Please try again.');
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    if (otp.length < 6) return 'Enter all 6 digits.';
    if (!_otpProvider.verify(otp)) return 'Incorrect or expired code.';
    _otpProvider.clear();
    return null;
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
      await _auth.currentUser?.updatePassword(password);
      _setError(null);
      return null;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Failed to update password.');
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  String _generateOtp() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }
}