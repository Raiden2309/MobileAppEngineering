import 'package:flutter/material.dart';
import 'package:mae_assignment/modules/new_user_setup/controllers/student_setup_controller.dart';
import 'package:mae_assignment/modules/new_user_setup/views/student_setup/steps/student_generate_profile.dart';
import 'package:mae_assignment/modules/new_user_setup/views/student_setup/steps/student_profile.dart';
import 'package:mae_assignment/modules/new_user_setup/views/student_setup/steps/student_schedule.dart';
import 'package:mae_assignment/modules/new_user_setup/views/student_setup/steps/student_semester.dart';
import 'package:mae_assignment/modules/new_user_setup/views/student_setup/steps/student_subjects.dart';
import 'package:mae_assignment/modules/role/student/views/central_student_navigation.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../auth/services/auth_service.dart';
import '../../models/student_model.dart';
import '../../provider/student_provider.dart';

class StudentSetupPage extends StatefulWidget {
  const StudentSetupPage({super.key});

  @override
  State<StudentSetupPage> createState() => StudentSetupPageState();
}

class StudentSetupPageState extends State<StudentSetupPage> {
  int currentStep = 0;
  late final SetupController controller = SetupController();

  void nextStep() => setState(() => currentStep++);
  void prevStep() => setState(() => currentStep--);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onSetupDone(BuildContext context) async {
    final studentModel = StudentModel(
      id: '',
      name: controller.nameController.text,
      email: '',
      programme: controller.programmeController.text,
      semester: controller.semester,
      year: controller.year,
      semStart: controller.semStart,
      semEnd: controller.semEnd,
      dayStart: controller.dayStart,
      dayEnd: controller.dayEnd,
      blockedSlots: controller.blockedSlots.toList(),
      subjects: List<Map<String, String>>.from(controller.subjects),
    );

    if (!context.mounted) return;
    await context.read<StudentProvider>().save(studentModel);

    await AuthService.completeSetup();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CentralStudentNavigation()),
    );
  }

  Widget buildStep(BuildContext context) {
    switch (currentStep) {
      case 0: return StudentProfile(controller: controller, onNext: nextStep);
      case 1: return StudentSchedule(controller: controller, onNext: nextStep, onBack: prevStep);
      case 2: return StudentSemester(controller: controller, onNext: nextStep, onBack: prevStep);
      case 3: return StudentSubjects(controller: controller, onNext: nextStep, onBack: prevStep);
      case 4: return StudentGenerateProfile(onDone: () => onSetupDone(context));
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentProvider(),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.californiaBlue, AppColors.greenSheen],
            ),
          ),
          child: SafeArea(
            child: Builder(
              builder: buildStep,
            ),
          ),
        ),
      ),
    );
  }
}