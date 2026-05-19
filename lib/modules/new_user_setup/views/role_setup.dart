import 'package:flutter/material.dart';
import 'package:mae_assignment/modules/new_user_setup/views/student_setup/student_setup.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Image — left side
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
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.white24,
                                        child: const Icon(Icons.person, size: 48, color: Colors.black26),
                                      ),
                                    ),
                                  ),
                                ),

                                // Text — right side
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          roles[index]['label']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.black : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          roles[index]['description']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
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

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black26,
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
                            await AuthService.saveRole('student'); // save role
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentSetupPage()),
                            );
                          } else if (selectedIndex == 1) {
                            await AuthService.saveRole('lecturer');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentSetupPage()),
                            );
                          }
                        },
                        child: const Text('Continue', style: TextStyle(fontSize: 16)),
                      ),
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