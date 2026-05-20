import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';
import '../../../controllers/lecturer_setup_controller.dart';

class LecturerProfile extends StatelessWidget {
  final LecturerSetupController controller;
  final VoidCallback onNext;

  const LecturerProfile(
      {super.key, required this.controller, required this.onNext});

  void handleNext(BuildContext context) {
    if (!controller.validateAll()) return;
    if (controller.generatedJoinCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate a join code first')),
      );
      return;
    }
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Unplug',
            style: TextStyle(fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.black),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set up your profile and create your first class to get started.',
            style: TextStyle(fontSize: 13, color: AppColors.black, height: 1.6),
          ),
          const SizedBox(height: 32),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SetupLabel('Your Name'),
                    SetupInput(
                      controller: controller.nameController,
                      placeholder: 'e.g. Dr. Lim Mei Yee',
                      errorText: controller.getError('name'),
                    ),
                    const SizedBox(height: 16),
                    const SetupLabel('Subject Name'),
                    SetupInput(
                      controller: controller.subjectNameController,
                      placeholder: 'e.g. CT124 System Proposal',
                      errorText: controller.getError('subjectName'),
                    ),
                    const SizedBox(height: 16),
                    if (controller.generatedJoinCode == null)
                      GenerateButton(controller: controller)
                    else
                      JoinCodeReveal(joinCode: controller.generatedJoinCode!),
                  ],
                ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => handleNext(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Go to Dashboard →',
                  style: TextStyle(color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GenerateButton extends StatelessWidget {
  final LecturerSetupController controller;

  const GenerateButton({super.key, required this.controller});

  Future<void> handleGenerate() async {
    if (controller.subjectNameController.text
        .trim()
        .isEmpty) return;
    controller.setGenerating(true);
    await Future.delayed(const Duration(milliseconds: 900));
    final code = controller.subjectNameController.text
        .trim()
        .split(' ')
        .first
        .toUpperCase();
    controller.setJoinCode('$code–A1');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.generating ? null : handleGenerate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: controller.generating
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.black),
          )
              : const Text(
            'Generate Join Code',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class JoinCodeReveal extends StatelessWidget {
  final String joinCode;

  const JoinCodeReveal({super.key, required this.joinCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Class Join Code',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                joinCode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Valid for the entire semester',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Students open their Unplug app, go to Join Class, and enter this code.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.black,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: joinCode));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Join code copied!')),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Copy Join Code',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}