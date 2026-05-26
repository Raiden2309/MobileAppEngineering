import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/role/lecturer/providers/alert_provider.dart';
import 'modules/role/lecturer/providers/classes_provider.dart';
import 'modules/role/lecturer/providers/engagement_provider.dart';
import 'modules/role/lecturer/providers/lecturer_dashboard_provider.dart';
import 'modules/role/lecturer/providers/lecturer_settings_provider.dart';
import 'modules/role/student/providers/burnout_alert_provider.dart';
import 'modules/role/student/providers/dashboard_provider.dart';
import 'modules/role/student/providers/navigation_provider.dart';
import 'modules/role/student/providers/semester_progress_provider.dart';
import 'modules/role/student/providers/student_settings_provider.dart';
import 'modules/role/student/providers/study_plan_provider.dart';
import 'modules/role/student/providers/task_provider.dart';
import 'shared/widgets/splash_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding =
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const storage = FlutterSecureStorage();

  await storage.write(key: 'auth_token',       value: 'test_token_abc123');
  await storage.write(key: 'user_role',         value: 'student');
  await storage.write(key: 'is_setup_complete', value: 'true');

  final authProvider = AuthProvider();
  await authProvider.loadFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClassesProvider()),

        // Student
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => SemesterProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => BurnoutAlertProvider()),
        ChangeNotifierProvider(create: (_) => StudentSettingsProvider()),

        // Lecturer
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => ClassesProvider()),
        ChangeNotifierProvider(create: (_) => LecturerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => EngagementProvider()),
        ChangeNotifierProvider(create: (_) => LecturerSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
