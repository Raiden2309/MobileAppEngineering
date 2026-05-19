import 'package:flutter/material.dart';
import 'package:mae_assignment/modules/new_user_setup/controllers/lecturer_setup_controller.dart';
import 'package:mae_assignment/modules/new_user_setup/views/lecturer_setup/steps/lecturer_profile.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../auth/services/auth_service.dart';
import '../../../role/lecturer/views/central_lecturer_navigation.dart';
import '../../models/lecturer_model.dart';
import '../../provider/lecturer_provider.dart';

class LecturerSetupPage extends StatefulWidget {
  const LecturerSetupPage({super.key});

  @override
  State<LecturerSetupPage> createState() => LecturerSetupPageState();
}

class LecturerSetupPageState extends State<LecturerSetupPage> {
  late final LecturerSetupController controller = LecturerSetupController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onSetupDone(BuildContext context) async {
    final lecturerModel = LecturerModel(
      id: '',
      name: controller.nameController.text,
      email: '',
      programme: '',
      classes: [
        LecturerClass(
          name: controller.subjectNameController.text,
          code: controller.subjectNameController.text.trim().split(' ').first.toUpperCase(),
          joinCode: controller.generatedJoinCode ?? '',
        ),
      ],
    );

    if (!context.mounted) return;
    await context.read<LecturerProvider>().save(lecturerModel);

    await AuthService.completeSetup();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CentralLecturerNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LecturerProvider(),
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
            child: LecturerProfile(
              controller: controller,
              onNext: () => onSetupDone(context),
            ),
          ),
        ),
      ),
    );
  }
}