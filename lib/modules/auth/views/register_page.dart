import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool showPassword = true;
  bool showConfirmPassword = true;

  // Instantiate the controller
  final RegisterController controller = RegisterController();

  @override
  void dispose() {
    controller.dispose(); // clean up
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/transparent_logo.png',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Join us today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email field — wired up
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

                      // Password field — wired up
                      TextField(
                        controller: controller.passwordController,
                        cursorColor: AppColors.black,
                        obscureText: showPassword,
                        decoration: InputDecoration(
                          errorText: controller.passwordError,
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            hoverColor: AppColors.transparent,
                            splashColor: AppColors.transparent,
                            highlightColor: AppColors.transparent,
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => showPassword = !showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm password field — wired up
                      TextField(
                        controller: controller.confirmPasswordController,
                        cursorColor: AppColors.black,
                        obscureText: showConfirmPassword,
                        decoration: InputDecoration(
                          errorText: controller.confirmPasswordError,
                          labelText: 'Confirm pass',
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            hoverColor: AppColors.transparent,
                            splashColor: AppColors.transparent,
                            highlightColor: AppColors.transparent,
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => showConfirmPassword = !showConfirmPassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register button — calls controller
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          onPressed: () => controller.register(
                            context,
                            onError: () => setState(() {}),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.black)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.black)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Sign in with Google'),
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
                              text: "Already have an account? ",
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: Color(0xFF111184),
                                    fontWeight: FontWeight.bold,
                                  ),
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
