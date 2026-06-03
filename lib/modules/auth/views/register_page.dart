import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool showPassword        = true;
  bool showConfirmPassword = true;

  final RegisterController controller = RegisterController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.black,
              onPrimary: AppColors.white,
            ),
            checkboxTheme: const CheckboxThemeData(
              side: BorderSide(color: AppColors.black),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.black),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.black),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: AppColors.black),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 2),
              ),
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset('assets/images/transparent_logo.png'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Register',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create your account',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      TextField(
                        controller: controller.emailController,
                        cursorColor: AppColors.black,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: controller.emailError,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: controller.passwordController,
                        cursorColor: AppColors.black,
                        obscureText: showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: controller.passwordError,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            hoverColor: AppColors.transparent,
                            splashColor: AppColors.transparent,
                            highlightColor: AppColors.transparent,
                            icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => showPassword = !showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm password
                      TextField(
                        controller: controller.confirmPasswordController,
                        cursorColor: AppColors.black,
                        obscureText: showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          errorText: controller.confirmPasswordError,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            hoverColor: AppColors.transparent,
                            splashColor: AppColors.transparent,
                            highlightColor: AppColors.transparent,
                            icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
                          onPressed: () => controller.register(
                            context,
                            selectedRole: 0,
                            onError: () => setState(() {}),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => controller.registerWithGoogle(
                            context,
                            onError: () {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Google registration failed. Please try again.')),
                              );
                            },
                          ),
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Sign up with Google'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.black,
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(color: AppColors.darkIndigoBlue, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}