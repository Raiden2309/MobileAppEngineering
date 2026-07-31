import 'package:cloud_firestore/cloud_firestore.dart';
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
    final isRoleSelected = selectedIndex != null;

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
                                  color: AppColors.black.withValues(alpha: 0.1),
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
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
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
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
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
                              // Standard Material behavior: turns gray when disabled
                              disabledBackgroundColor: Colors.grey.shade400,
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Strictly passing null explicitly disables input and visual ripples
                            onPressed: !isRoleSelected
                                ? null
                                : () async {
                                    if (selectedIndex == 0) {
                                      await AuthService.saveRole(1);
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(AuthService.getCurrentUserId())
                                          .update({'role': 1});
                                      if (!context.mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const StudentSetupPage(),
                                        ),
                                      );
                                    } else if (selectedIndex == 1) {
                                      await AuthService.saveRole(2);
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(AuthService.getCurrentUserId())
                                          .update({'role': 2});
                                      if (!context.mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LecturerSetupPage(),
                                        ),
                                      );
                                    }
                                  },
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: FontStyles.titleMedium,
                                fontWeight: FontWeight.bold,
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
