import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/controllers/lecturer_setup_controller.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/lecturer_setup/steps/lecturer_profile.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/lecturer_setup/steps/lecturer_generate_profile.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../provider/lecturer_provider.dart';

// Wrap the real page in a provider shell so the context inside
// LecturerSetupPage is always a descendant of LecturerProvider.
class LecturerSetupPage extends StatelessWidget {
  const LecturerSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LecturerProvider(),
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

  // FIXED: Delegate database creation and navigation parameters safely directly to the controller
  Future<void> _onGenerateDone() async {
    if (!mounted) return;

    // This method automatically handles saving to Firestore, updating native storage flags,
    // and pushing to CentralLecturerNavigation safely.
    await controller.completeSetup(context);
  }

  @override
  Widget build(BuildContext context) {
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