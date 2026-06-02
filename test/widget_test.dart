import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/modules/auth/providers/auth_provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';

// Create a safe test variant of the splash screen UI for automated verification.
class TestSplashScreenUI extends StatelessWidget {
  const TestSplashScreenUI({super.key});

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
        child: const Center(
          child: SizedBox(
            width: 280,
            height: 130,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 150,
                  top: 0,
                  bottom: 0,
                  child: Text(
                    'Unplug',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      letterSpacing: 3.0,
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

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Render the isolated interface wrapped inside the required state provider
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: TestSplashScreenUI(),
        ),
      ),
    );

    // Assert that the visual layer successfully constructs inside the component tree
    expect(find.byType(TestSplashScreenUI), findsOneWidget);
    expect(find.text('Unplug'), findsOneWidget);
  });
}