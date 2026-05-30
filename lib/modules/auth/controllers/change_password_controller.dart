import 'package:bcrypt/bcrypt.dart';

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

  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}