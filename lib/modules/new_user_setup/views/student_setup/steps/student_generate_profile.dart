import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';

class StudentGenerateProfile extends StatefulWidget {
  final VoidCallback onDone;
  const StudentGenerateProfile({super.key, required this.onDone});

  @override
  State<StudentGenerateProfile> createState() => StudentGenerateProfileState();
}

class StudentGenerateProfileState extends State<StudentGenerateProfile> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    runProgress();
  }

  void runProgress() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => progress = i / 10);
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.californiaBlue, AppColors.greenSheen],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/transparent_logo.png', width: 72, height: 72),
              const SizedBox(height: 24),
              const StepDots(total: 5, current: 4),
              const SizedBox(height: 20),
              const Text(
                'Building Your Plan…',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Our AI is analysing your schedule, deadlines, and workload to create a personalised weekly study plan.',
                style: TextStyle(fontSize: 13, color: AppColors.black, height: 1.65),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                width: 200, height: 4,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.mikadoYellow, AppColors.nectarine]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}