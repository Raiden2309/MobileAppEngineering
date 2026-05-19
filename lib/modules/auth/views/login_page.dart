import 'package:flutter/material.dart';
import 'package:mae_assignment/modules/auth/views/register_page.dart';


import '../../../shared/styles/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool showPassword = true;
  bool rememberMe = false;

  // Instantiate the controller
  final LoginController controller = LoginController();

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
                        'Login',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Good to see you again',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => setState(() => rememberMe = !rememberMe),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    mouseCursor: SystemMouseCursors.click,
                                    overlayColor: WidgetStateProperty.all(AppColors.transparent),
                                    onChanged: (val) => setState(() => rememberMe = val!),
                                  ),
                                  const Text('Remember me', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Login button — calls controller
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
                          onPressed: () => controller.login(
                            context,
                            onError: () => setState(() {}),
                          ),
                          child: const Text('Login'),
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
                          style: OutlinedButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click),
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Sign in with Google'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                                transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.black,
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Register',
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