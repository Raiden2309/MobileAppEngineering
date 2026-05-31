import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';
import '../../../controllers/student_setup_controller.dart';

class StudentProfile extends StatelessWidget {
  final SetupController controller;
  final VoidCallback onNext;

  const StudentProfile({super.key, required this.controller, required this.onNext});

  void handleNext(BuildContext context) {
    if (controller.validate(controller.nameController.text, 'name',
      emptyMessage: 'Please enter your name',
    )) {
      onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 0,
      title: 'Welcome to Unplug',
      subtitle: "Your AI-powered study planner. Let's set up your profile so we can build a plan that works for you.",
      onNext: () => handleNext(context),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SetupLabel('Your Name'),
            SetupInput(
              controller: controller.nameController,
              placeholder: 'e.g. Alex',
              errorText: controller.getError('name'),
            ),
            const SizedBox(height: 16),
            const SetupLabel('Study Hours'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TimeBlock(
                    label: 'Day Starts',
                    time: controller.dayStart,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: controller.dayStart,
                        builder: (context, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(primary: AppColors.black),
                          ),
                          child: child!,
                        ),
                      );
                      if (t != null) controller.setDayStart(t);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TimeBlock(
                    label: 'Day Ends',
                    time: controller.dayEnd,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: controller.dayEnd,
                        builder: (context, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(primary: AppColors.black),
                          ),
                          child: child!,
                        ),
                      );
                      if (t != null) controller.setDayEnd(t);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimeBlock extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const TimeBlock({super.key, required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}