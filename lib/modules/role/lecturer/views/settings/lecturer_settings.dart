import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/settings/widget/lecturer_profile_header.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import '../../../lecturer/views/settings/widget/settings_group.dart';
import '../../../lecturer/views/settings/widget/settings_row.dart';
import '../../../lecturer/views/settings/widget/toggle_row.dart';
import '../../controllers/lecturer_settings_controller.dart';
import '../../providers/lecturer_settings_provider.dart';


class LecturerSettingsPage extends StatelessWidget {
  const LecturerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: SafeArea(
          child: Builder(
            builder: (context) {
              final provider = context.watch<LecturerSettingsProvider>();

              if (provider.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.data == null) {
                return const Center(child: Text('No settings found'));
              }

              final data = provider.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  children: [
                    const LecturerProfileHeader(),
                    const SizedBox(height: 24),

                    SettingsGroup(
                      title: 'Account',
                      children: [
                        SettingsRow(
                          icon: Icons.lock_rounded,
                          iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                          label: 'Change Password',
                          onTap: () => LecturerSettingsController.openChangePassword(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SettingsGroup(
                      title: 'Notifications',
                      children: [
                        ToggleRow(
                          icon: Icons.local_fire_department_rounded,
                          iconBg: AppColors.red.withValues(alpha: 0.2),
                          label: 'Burnout Alerts',
                          value: data.burnoutAlerts,
                          onToggle: () => LecturerSettingsController.toggleBurnoutAlerts(context),
                        ),
                        ToggleRow(
                          icon: Icons.warning_amber_rounded,
                          iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                          label: 'Falling Behind Alerts',
                          value: data.fallingBehindAlerts,
                          onToggle: () => LecturerSettingsController.toggleFallingBehindAlerts(context),
                        ),
                        ToggleRow(
                          icon: Icons.bar_chart_rounded,
                          iconBg: AppColors.softPurple.withValues(alpha: 0.2),
                          label: 'Weekly Engagement Report',
                          value: data.weeklyEngagementReport,
                          onToggle: () => LecturerSettingsController.toggleWeeklyEngagementReport(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SettingsGroup(
                      title: 'About',
                      children: [
                        SettingsRow(
                          icon: Icons.info_outline_rounded,
                          iconBg: Colors.white.withValues(alpha: 0.1),
                          label: 'App Version',
                          value: data.appVersion,
                          showArrow: false,
                          onTap: () {},
                        ),
                        SettingsRow(
                          icon: Icons.logout_rounded,
                          iconBg: AppColors.red.withValues(alpha: 0.2),
                          label: 'Sign Out',
                          labelColor: AppColors.red,
                          onTap: () => LecturerSettingsController.signOut(context),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
