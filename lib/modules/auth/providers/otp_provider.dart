import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

class OtpProvider extends ChangeNotifier {
  String? hashedOtp;
  DateTime? expiresAt;

  bool get isValid => hashedOtp != null &&
      expiresAt != null &&
      DateTime.now().isBefore(expiresAt!);

  void store(String plainOtp) {
    hashedOtp = BCrypt.hashpw(plainOtp, BCrypt.gensalt());
    expiresAt = DateTime.now().add(const Duration(minutes: 3));
    notifyListeners();
  }

  bool verify(String plainOtp) {
    if (!isValid) return false;
    return BCrypt.checkpw(plainOtp, hashedOtp!);
  }

  void clear() {
    hashedOtp = null;
    expiresAt = null;
    notifyListeners();
  }
}