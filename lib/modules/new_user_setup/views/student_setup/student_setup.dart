import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/controllers/student_setup_controller.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_generate_profile.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_profile.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_schedule.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_semester.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_subjects.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/central_student_navigation.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/dashboard/student_dashboard.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../auth/services/auth_service.dart';

class StudentSetupPage extends StatefulWidget {
  const StudentSetupPage({super.key});

  @override
  State<StudentSetupPage> createState() => StudentSetupPageState();
}

class StudentSetupPageState extends State<StudentSetupPage> {
  int currentStep = 0;
  final SetupController controller = SetupController();

  void nextStep() => setState(() => currentStep++);
  void prevStep() => setState(() => currentStep--);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildStep() {
    switch (currentStep) {
      case 0: return StudentProfile(controller: controller, onNext: nextStep);
      case 1: return StudentSchedule(controller: controller, onNext: nextStep, onBack: prevStep);
      case 2: return StudentSemester(controller: controller, onNext: nextStep, onBack: prevStep);
      case 3: return StudentSubjects(controller: controller, onNext: nextStep, onBack: prevStep);
      case 4: return StudentGenerateProfile(
        onDone: () async {
          await AuthService.completeSetup();
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CentralStudentNavigation()),
          );
        },
      );
      default: return const SizedBox();
    }
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
        child: SafeArea(
          child: buildStep(),
        ),
      ),
    );
  }
}