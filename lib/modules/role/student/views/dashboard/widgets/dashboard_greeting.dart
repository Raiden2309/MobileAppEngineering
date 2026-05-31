import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/student_settings_provider.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key});

  /// Dynamically computes the appropriate greeting based on the current hour of the day
  String _getGreetingSnippet() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<StudentDashboardProvider>().data?.summary;
    final taskCount = summary?.taskCountToday ?? 0;

    final settingsProvider = context.watch<StudentSettingsProvider>();
    final String userName = settingsProvider.data?.userName ?? 'Student';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Text(
            '${_getGreetingSnippet()}, $userName', // FIXED: Reflects real-time hour state values natively
            style: const TextStyle(
              fontSize: FontStyles.titleGreeting,
              fontWeight: FontStyles.titleWeight,
              color: AppColors.black,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            'You have $taskCount tasks scheduled for today',
            style: const TextStyle(
              fontSize: FontStyles.titleMedium,
              color: AppColors.black,
              letterSpacing: 0.5,
              height: 2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, color: AppColors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                _formattedDate(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: FontStyles.titleMedium,
                  fontWeight: FontStyles.weightMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}