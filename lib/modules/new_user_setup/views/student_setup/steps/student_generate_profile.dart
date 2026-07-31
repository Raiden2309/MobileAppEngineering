import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/widgets/setup_widgets.dart';

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
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _progress = i / 10;
        _messageIndex = i < _messages.length ? i : _messages.length - 1;
      });
    }

    // --- FIXED: Add a short pause once the progress reaches 100% ---
    // This allows the "Your plan is ready!" message to stay visible
    // and lets the animation complete cleanly before triggering the Firestore upload.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    widget.onDone(); // Safely invoke backend batch save now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/transparent_logo.png',
                width: 72,
                height: 72,
              ),
              const SizedBox(height: 24),
              const StepDots(total: 5, current: 4),
              const SizedBox(height: 20),
              const Text(
                'Building Your Plan…',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 48),

              // Animated message switcher text block
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.black,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),

              // Progress bar track container element
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 400),
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
