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
  double _progress = 0;
  int _messageIndex = 0;

  static const _messages = [
    'Reviewing your programme details…',
    'Analysing your semester timeline…',
    'Mapping out your weekly schedule…',
    'Identifying your peak study hours…',
    'Calculating your workload balance…',
    'Prioritising your upcoming deadlines…',
    'Structuring your revision blocks…',
    'Fine-tuning your study sessions…',
    'Adding the finishing touches…',
    'Your plan is ready!',
  ];

  @override
  void initState() {
    super.initState();
    _runProgress();
  }

  void _runProgress() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _progress = i / 10;
        _messageIndex = i - 1;
      });
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
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

              // Animated changing message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: const TextStyle(fontSize: 13, color: AppColors.black, height: 1.65),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),

              // Smooth animated progress bar
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.mikadoYellow, AppColors.nectarine],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
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