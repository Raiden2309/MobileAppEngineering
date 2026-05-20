import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/lecturer_setup/lecturer_setup.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/student_setup.dart';
import 'package:mae_assignment_frontend/modules/auth/views/login_page.dart';

import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/font_styles.dart';
import '../../auth/services/auth_service.dart';

class RoleSetupPage extends StatefulWidget {
  const RoleSetupPage({super.key});

  @override
  State<RoleSetupPage> createState() => RoleSetupPageState();
}

PageRouteBuilder slideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      final fade = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class RoleSetupPageState extends State<RoleSetupPage> {
  int? selectedIndex;

  final List<Map<String, String>> roles = [
    {
      'image': 'assets/images/student.png',
      'label': 'Student',
      'description': 'Track your progress, tasks and assignments.',
    },
    {
      'image': 'assets/images/lecturer.png',
      'label': 'Lecturer',
      'description': 'Manage your classes and students performance.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3DA5D9), Color(0xFF73BFB8)],
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
                    const Text(
                      "What's your role?",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    ...List.generate(roles.length, (index) {
                      final isSelected = selectedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 130,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.black
                                    : AppColors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  child: SizedBox(
                                    width: 120,
                                    height: 130,
                                    child: Image.asset(
                                      roles[index]['image']!,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: AppColors.white,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 48,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          roles[index]['label']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppColors.black
                                                : AppColors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          roles[index]['description']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.black,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return ScaleTransition(
                                      scale:
                                          Tween<double>(
                                            begin: 0.92,
                                            end: 1.0,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.black,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor: AppColors.black,
                              enabledMouseCursor: SystemMouseCursors.click,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: selectedIndex == null
                                ? null
                                : () async {
                                    if (selectedIndex == 0) {
                                      await AuthService.saveRole(1);
                                      Navigator.pushReplacement(
                                        context,
                                        slideRoute(const StudentSetupPage()),
                                      );
                                    } else if (selectedIndex == 1) {
                                      await AuthService.saveRole(2);
                                      Navigator.pushReplacement(
                                        context,
                                        slideRoute(const LecturerSetupPage()),
                                      );
                                    }
                                  },
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: FontStyles.titleMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
