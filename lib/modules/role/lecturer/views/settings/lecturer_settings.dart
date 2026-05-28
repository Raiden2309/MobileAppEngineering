import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/settings/widget/lecturer_profile_header.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';

import '../../../student/views/settings/student_settings.dart';
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

// ── Custom Settings Group Container ──
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({required this.title, required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

// ── Custom Settings Action/Value Row ──
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String? value;
  final Color? labelColor;
  final VoidCallback onTap;

  const SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.value,
    this.labelColor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: labelColor ?? Colors.white, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(color: labelColor ?? Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: value != null
          ? Text(value!, style: const TextStyle(color: Colors.white54, fontSize: 14))
          : const Icon(Icons.chevron_right_rounded, color: Colors.white30),
    );
  }
}

// ── Custom Settings Interactive Toggle Row ──
class ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: (_) => onToggle(),
        activeColor: AppColors.californiaBlue,
      ),
    );
  }
}