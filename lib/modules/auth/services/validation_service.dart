import 'package:bcrypt/bcrypt.dart';

class ValidationService {
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Please confirm your password.';
    if (password != confirm) return 'Passwords do not match.';
    return null;
  }

  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}