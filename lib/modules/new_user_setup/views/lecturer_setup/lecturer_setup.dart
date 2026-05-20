import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/controllers/lecturer_setup_controller.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/lecturer_setup/steps/lecturer_profile.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/lecturer_setup/steps/lecturer_generate_profile.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../auth/services/auth_service.dart';
import '../../../role/lecturer/views/central_lecturer_navigation.dart';
import '../../models/lecturer_model.dart';
import '../../provider/lecturer_provider.dart';

// Wrap the real page in a provider shell so the context inside
// LecturerSetupPage is always a descendant of LecturerProvider.
class LecturerSetupPage extends StatelessWidget {
  const LecturerSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LecturerProvider(),
      // Use builder so the child's context is below the provider.
      builder: (context, _) => const _LecturerSetupPageInner(),
    );
  }
}

class _LecturerSetupPageInner extends StatefulWidget {
  const _LecturerSetupPageInner();

  @override
  State<_LecturerSetupPageInner> createState() =>
      _LecturerSetupPageInnerState();
}

class _LecturerSetupPageInnerState extends State<_LecturerSetupPageInner> {
  late final LecturerSetupController controller = LecturerSetupController();
  bool _generating = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onFormDone() {
    setState(() => _generating = true);
  }

  Future<void> _onGenerateDone() async {
    final lecturerModel = LecturerModel(
      id: '',
      name: controller.nameController.text,
      email: '',
      programme: '',
      classes: [
        LecturerClass(
          name: controller.subjectNameController.text,
          code: controller.subjectNameController.text
              .trim()
              .split(' ')
              .first
              .toUpperCase(),
          joinCode: controller.generatedJoinCode ?? '',
        ),
      ],
    );

    if (!mounted) return;
    // context here is safely below the ChangeNotifierProvider
    await context.read<LecturerProvider>().save(lecturerModel);

    await AuthService.completeSetup();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CentralLecturerNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LecturerGenerateProfile draws its own full-screen gradient,
    // so only apply the outer gradient for the profile form step.
    if (_generating) {
      return Scaffold(body: LecturerGenerateProfile(onDone: _onGenerateDone));
    }

    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.californiaBlue, AppColors.greenSheen],
            ),
          ),
          child: SafeArea(
            child: LecturerProfile(controller: controller, onNext: _onFormDone),
          ),
        ),
      ),
    );
  }
}
