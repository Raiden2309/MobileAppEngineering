abstract class PasswordRequest {
  const PasswordRequest();
}

class ChangePasswordRequest extends PasswordRequest {
  final int userId;
  final String hashedNewPassword;

  const ChangePasswordRequest({
    required this.userId,
    this.hashedNewPassword = '',
  });

  ChangePasswordRequest copyWith({String? hashedNewPassword}) {
    return ChangePasswordRequest(
      userId: userId,
      hashedNewPassword: hashedNewPassword ?? this.hashedNewPassword,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'new_password': hashedNewPassword,
  };
}

class ForgotPasswordRequest extends PasswordRequest {
  final String email;
  final String hashedNewPassword;

  const ForgotPasswordRequest({
    required this.email,
    this.hashedNewPassword = '',
  });

  ForgotPasswordRequest copyWith({String? hashedNewPassword}) {
    return ForgotPasswordRequest(
      email: email,
      hashedNewPassword: hashedNewPassword ?? this.hashedNewPassword,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'new_password': hashedNewPassword,
  };
}