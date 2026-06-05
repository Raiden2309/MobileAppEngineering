import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mae_assignment_frontend/shared/services/local_cache_service.dart';
import 'package:mae_assignment_frontend/shared/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'package:mae_assignment_frontend/modules/new_user_setup/provider/student_provider.dart';
import 'shared/widgets/splash_screen.dart';

/// Top-level function to handle incoming background/terminated push notifications.
/// Must be annotated with @pragma('vm:entry-point') so it doesn't get stripped during compilation.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the background messaging handler as early as possible
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const storage = FlutterSecureStorage();

  await storage.write(key: 'auth_token', value: 'test_token_abc123');
  await storage.write(key: 'user_role', value: 'student');
  await storage.write(key: 'is_setup_complete', value: 'true');

  final authProvider = AuthProvider();
  await authProvider.loadFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClassesProvider()),

        // Student
        ChangeNotifierProvider(create: (_) => LocalCacheService()),

        ChangeNotifierProxyProvider<LocalCacheService, StudentSettingsProvider>(
          create: (_) => StudentSettingsProvider(),
          update: (_, cache, settings) => settings!..updateCacheEngine(cache),
        ),

        ChangeNotifierProxyProvider2<
          LocalCacheService,
          StudentSettingsProvider,
          SemesterProvider
        >(
          create: (context) => SemesterProvider(),
          update: (context, cache, settingsProvider, semesterProvider) {
            // 1. Inject the cache engine
            semesterProvider!.updateCacheEngine(cache);

            // 2. Wire up the immediate offline refresh handler
            settingsProvider.onSubjectsUpdated = () {
              semesterProvider.reloadSubjectsFromCache();
            };

            return semesterProvider;
          },
        ),

        ChangeNotifierProxyProvider<
          LocalCacheService,
          StudentDashboardProvider
        >(
          create: (_) => StudentDashboardProvider(),
          update: (_, cache, dash) => dash!..updateCacheEngine(cache),
        ),

        ChangeNotifierProxyProvider3<
          LocalCacheService,
          StudentSettingsProvider,
          StudentDashboardProvider,
          TasksProvider
        >(
          create: (_) => TasksProvider(),
          update: (_, cache, settingsProvider, dashboardProvider, tasksProvider) {
            tasksProvider!.updateCacheEngine(cache);
            tasksProvider.updateDashboardProvider(dashboardProvider);

            final previousCallback = settingsProvider.onSubjectsUpdated;
            settingsProvider.onSubjectsUpdated = () {
              previousCallback?.call();
              if (settingsProvider.currentSemesterId != null) {
                tasksProvider.listenToLiveTasks(
                  semester: settingsProvider.currentSemesterId!,
                );
              }
            };

            return tasksProvider;
          },
        ),

        ChangeNotifierProxyProvider2<
          LocalCacheService,
          TasksProvider,
          BurnoutAlertProvider
        >(
          create: (_) => BurnoutAlertProvider(),
          update: (_, cache, tasks, burnout) {
            burnout!.updateCacheEngine(cache);
            burnout.updateTotalTasks(tasks.totalTasksCount);
            return burnout;
          },
        ),

        ChangeNotifierProxyProvider3<
          LocalCacheService,
          StudentSettingsProvider,
          BurnoutAlertProvider,
          StudyPlanProvider
        >(
          create: (_) => StudyPlanProvider(),
          update: (_, cache, settings, burnout, study) {
            study!.updateCacheEngine(cache);
            study.updateSettingsProvider(settings);
            study.updateBurnoutProvider(burnout);
            if (settings.currentSemesterId != null) {
              study.listenToLiveStudyPlan(
                semester: settings.currentSemesterId!,
              );
            }

            return study;
          },
        ),

        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // Lecturer
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => LecturerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => EngagementProvider()),
        ChangeNotifierProvider(create: (_) => LecturerSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
  await NotificationService().setupNotificationTokenPipeline();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      initialRoute: '/',
    );
  }
}
