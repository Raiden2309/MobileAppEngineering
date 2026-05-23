import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mae_assignment_frontend/modules/auth/views/reset_password.dart';
import 'package:mae_assignment_frontend/modules/auth/views/widget/otp_box.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/font_styles.dart';
import '../controllers/change_password_controller.dart';
import '../models/change_password_request.dart';

class ChangePassword {
  static void startForgotPassword(BuildContext context) {
    final controller = ChangePasswordController();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailPage(controller: controller),
      ),
    );
  }

  static void startChangePassword(BuildContext context, {required int userId}) {
    final controller = ChangePasswordController();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(
          controller: controller,
          request: ChangePasswordRequest(userId: userId),
        ),
      ),
    );
  }
}

class FlowScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const FlowScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: FontStyles.titleLarge,
                        fontWeight: FontStyles.titleWeight,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: FontStyles.titleSmall,
                        color: AppColors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffix;
  final String? errorText;

  const GlassField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: FontStyles.titleTiny,
            fontWeight: FontStyles.weightMedium,
            color: AppColors.legendText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: FontStyles.titleSmall,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.white.withValues(alpha: 0.35),
                fontSize: FontStyles.titleSmall,
              ),
              suffixIcon: suffix,
              border: InputBorder.none,
              enabledBorder: hasError
                  ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
                borderSide: const BorderSide(color: AppColors.red),
              )
                  : InputBorder.none,
              focusedBorder: hasError
                  ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
                borderSide: const BorderSide(color: AppColors.red, width: 1.5),
              )
                  : InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: FontStyles.titleTiny,
              color: AppColors.red,
              fontWeight: FontStyles.weightMedium,
            ),
          ),
        ],
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
              : Text(
            label,
            style: const TextStyle(
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.titleWeight,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class EmailPage extends StatefulWidget {
  final ChangePasswordController controller;
  const EmailPage({super.key, required this.controller});

  @override
  State<EmailPage> createState() => EmailPageState();
}

class EmailPageState extends State<EmailPage> {
  final emailController = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> submit() async {
    setState(() {
      error = null;
      loading = true;
    });

    final result = await widget.controller.sendOtp(emailController.text.trim());

    setState(() {
      loading = false;
      error = result;
    });

    if (result != null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpPage(
          email: emailController.text.trim(),
          controller: widget.controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: 'Reset Password',
      subtitle: 'Enter your account email and we\'ll send you a one-time code.',
      children: [
        GlassField(
          label: 'Email Address',
          hint: 'you@example.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: error,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send Code',
          loading: loading,
          onTap: submit,
        ),
      ],
    );
  }
}

class OtpPage extends StatefulWidget {
  final String email;
  final ChangePasswordController controller;
  const OtpPage({super.key, required this.email, required this.controller});

  @override
  State<OtpPage> createState() => OtpPageState();
}

class OtpPageState extends State<OtpPage> {
  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  bool loading = false;
  String? error;

  String get otp => controllers.map((c) => c.text).join();

  Future<void> submit() async {
    setState(() {
      error = null;
      loading = true;
    });

    final result = await widget.controller.verifyOtp(widget.email, otp);

    setState(() {
      loading = false;
      error = result;
    });

    if (result != null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(
          controller: widget.controller,
          request: ForgotPasswordRequest(email: widget.email),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: 'Enter Code',
      subtitle: 'We sent a 6-digit code to ${widget.email}',
      children: [
        Text(
          'ONE-TIME CODE',
          style: TextStyle(
            fontSize: FontStyles.titleTiny,
            fontWeight: FontStyles.weightMedium,
            color: AppColors.legendText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
                (i) => OtpBox(
              hasError: error != null,
              controller: controllers[i],
              focusNode: focusNodes[i],
              onChanged: (val) {
                if (val.isNotEmpty && i < 5) focusNodes[i + 1].requestFocus();
                if (val.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
                setState(() {});
              },
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: const TextStyle(
              fontSize: FontStyles.titleTiny,
              color: AppColors.red,
              fontWeight: FontStyles.weightMedium,
            ),
          ),
        ],
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Verify Code',
          loading: loading,
          onTap: submit,
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () async {
              setState(() => error = null);
              await widget.controller.sendOtp(widget.email);
            },
            child: Text(
              'Resend code',
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                color: AppColors.white.withValues(alpha: 0.6),
                decoration: TextDecoration.underline,
                decorationColor: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



