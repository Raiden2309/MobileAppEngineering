import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../modules/auth/services/auth_service.dart';
import '../../modules/auth/views/login_page.dart';
import '../../modules/new_user_setup/views/role_setup.dart';
import '../../modules/role/student/views/central_student_navigation.dart';
import '../styles/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo reveal (clip from bottom to top)
  late AnimationController revealController;
  late Animation<double> revealAnimation;

  // Logo fade
  late AnimationController logoFadeController;
  late Animation<double> logoFadeAnimation;

  // Logo slide left
  late AnimationController logoSlideController;
  late Animation<Offset> logoSlideAnimation;

  // Text fade + slide in from right
  late AnimationController textController;
  late Animation<double> textFadeAnimation;
  late Animation<Offset> textSlideAnimation;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    revealAnimation = CurvedAnimation(
      parent: revealController,
      curve: Curves.easeInOut,
    );

    logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    logoFadeAnimation = CurvedAnimation(
      parent: logoFadeController,
      curve: Curves.easeIn,
    );

    logoSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    textFadeAnimation = CurvedAnimation(
      parent: textController,
      curve: Curves.easeIn,
    );

    // Placeholder values — overwritten in didChangeDependencies before use
    logoSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(logoSlideController);

    textSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(textController);
  }

  bool sequenceStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sequenceStarted) return;
    sequenceStarted = true;

    textSlideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: textController, curve: Curves.easeOut));

    logoSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.5, 0)).animate(
          CurvedAnimation(parent: logoSlideController, curve: Curves.easeInOut),
        );

    startSequence();
  }

  Future<void> startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));

    revealController.forward();
    logoFadeController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    logoSlideController.forward();
    textController.forward();

    await Future.delayed(const Duration(milliseconds: 800));

    final bool loggedIn = await AuthService.isLoggedIn();
    final bool setupDone = await AuthService.isSetupComplete();

    if (mounted) {
      Widget destination;
      if (loggedIn) {
        // has JWT token → skip everything
        destination = const CentralStudentNavigation();
      } else if (setupDone) {
        // no token but setup done → go to login
        destination = const LoginPage();
      } else {
        // no token, no setup → must setup first
        destination = const RoleSetupPage();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    revealController.dispose();
    logoFadeController.dispose();
    logoSlideController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 280,
            height: 130,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 75,
                  child: SlideTransition(
                    position: logoSlideAnimation,
                    child: FadeTransition(
                      opacity: logoFadeAnimation,
                      child: AnimatedBuilder(
                        animation: revealAnimation,
                        builder: (context, child) => ClipRect(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            heightFactor: revealAnimation.value,
                            child: child,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/transparent_logo.png',
                          width: 130,
                          height: 130,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 150,
                  top: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SlideTransition(
                        position: textSlideAnimation,
                        child: FadeTransition(
                          opacity: textFadeAnimation,
                          child: const Text(
                            'Unplug',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
