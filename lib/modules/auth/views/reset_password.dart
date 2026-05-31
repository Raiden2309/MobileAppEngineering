import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';
import '../controllers/change_password_controller.dart';
import '../models/change_password_request.dart';
import '../providers/reset_password_provider.dart';
import 'change_password.dart';

class ResetPasswordPage extends StatefulWidget {
  final ChangePasswordController controller;
  final PasswordRequest request;
  final ChangePasswordProvider   provider;

  const ResetPasswordPage({
    super.key,
    required this.controller,
    required this.request,
    required this.provider,
  });

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final passController    = TextEditingController();
  final confirmController = TextEditingController();
  bool    obscurePass    = true;
  bool    obscureConfirm = true;
  bool    loading        = false;
  String? passError;
  String? confirmError;

  Future<void> submit() async {
    setState(() {
      passError    = null;
      confirmError = null;
      loading      = true;
    });

    final error = await widget.provider.updatePassword( // fixed
      password: passController.text,
      confirm:  confirmController.text,
      request:  widget.request,
    );

    setState(() => loading = false);

    if (error != null) {
      final isConfirmError = error.contains('match') || error.contains('confirm');
      setState(() {
        if (isConfirmError) {
          confirmError = error;
        } else {
          passError = error;
        }
      });
      return;
    }

    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title:    'New Password',
      subtitle: 'Choose a strong password for your account.',
      children: [
        GlassField(
          label:      'New Password',
          hint:       '••••••••',
          controller: passController,
          obscure:    obscurePass,
          errorText:  passError,
          suffix: IconButton(
            icon: Icon(
              obscurePass
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.white.withValues(alpha: 0.5),
              size: 18,
            ),
            onPressed: () => setState(() => obscurePass = !obscurePass),
          ),
        ),
        const SizedBox(height: 16),
        GlassField(
          label:      'Confirm Password',
          hint:       '••••••••',
          controller: confirmController,
          obscure:    obscureConfirm,
          errorText:  confirmError,
          suffix: IconButton(
            icon: Icon(
              obscureConfirm
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.white.withValues(alpha: 0.5),
              size: 18,
            ),
            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label:   'Update Password',
          loading: loading,
          onTap:   submit,
        ),
      ],
    );
  }
}