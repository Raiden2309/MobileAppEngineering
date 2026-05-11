import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../controllers/student_settings_controller.dart';
import '../../models/student_settings_models.dart';
import '../../providers/navigation_provider.dart';

class StudentSettingsPage extends StatelessWidget {
  final StudentSettingsController controller;
  final NavigationProvider navigationProvider;

  const StudentSettingsPage({
    super.key,
    required this.controller,
    required this.navigationProvider,
  });

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
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.data == null) {
                return const Center(child: Text('No settings found'));
              }
              return SettingsBody(
                controller: controller,
                data: controller.data!,
                navigationProvider: navigationProvider,
              );
            },
          ),
        ),
      ),
    );
  }
}

class SettingsBody extends StatelessWidget {
  final StudentSettingsController controller;
  final StudentSettingsModel data;
  final NavigationProvider navigationProvider;

  const SettingsBody({
    super.key,
    required this.controller,
    required this.data,
    required this.navigationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        children: [
          ProfileHeader(data: data, navigationProvider: navigationProvider),
          const SizedBox(height: 24),
          SettingsGroup(
            title: 'Account',
            children: [
              SettingsRow(
                icon: Icons.edit_rounded,
                iconBg: AppColors.greenSheen.withValues(alpha: 0.2),
                label: 'Edit Profile',
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.lock_rounded,
                iconBg: AppColors.californiaBlue.withValues(alpha: 0.2),
                label: 'Change Password',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Study Schedule',
            children: [
              SettingsRow(
                icon: Icons.schedule_rounded,
                iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                label: 'Study Hours',
                value: '${data.studyHoursStart} – ${data.studyHoursEnd}',
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.block_rounded,
                iconBg: AppColors.red.withValues(alpha: 0.2),
                label: 'Blocked Times',
                value: '${data.blockedSlotsCount} slots',
                onTap: () {},
              ),
              SettingsRow(
                icon: Icons.menu_book_rounded,
                iconBg: AppColors.softPurple.withValues(alpha: 0.2),
                label: 'Subjects & Semester',
                value: '${data.subjectCount} subjects',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          NewSemesterCard(controller: controller),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Notifications',
            children: [
              ToggleRow(
                icon: Icons.notifications_rounded,
                iconBg: AppColors.greenSheen.withValues(alpha: 0.2),
                label: 'Task Reminders',
                value: data.taskReminders,
                onToggle: controller.toggleTaskReminders,
              ),
              ToggleRow(
                icon: Icons.alarm_rounded,
                iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                label: 'Slot End Prompts',
                value: data.slotEndPrompts,
                onToggle: controller.toggleSlotEndPrompts,
              ),
              ToggleRow(
                icon: Icons.local_fire_department_rounded,
                iconBg: AppColors.red.withValues(alpha: 0.2),
                label: 'Burnout Warnings',
                value: data.burnoutWarnings,
                onToggle: controller.toggleBurnoutWarnings,
              ),
              ToggleRow(
                icon: Icons.calendar_today_rounded,
                iconBg: AppColors.greenSheen.withValues(alpha: 0.2),
                label: 'Weekly Reset Summary',
                value: data.weeklyResetSummary,
                onToggle: controller.toggleWeeklyResetSummary,
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
                onTap: () => controller.signOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final StudentSettingsModel data;
  final NavigationProvider navigationProvider;

  const ProfileHeader({
    super.key,
    required this.data,
    required this.navigationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: AppColors.glassCard(borderRadius: 36),
                child: const Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.userName,
                style: const TextStyle(
                  fontSize: FontStyles.titleLarge,
                  fontWeight: FontStyles.titleWeight,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Semester ${data.semester} · Year ${data.year} · ${data.subjectCount} subjects',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: FontStyles.titleTiny,
              fontWeight: FontStyles.weightMedium,
              color: AppColors.white.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: AppColors.glassCard(),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
              children: [
                e.value,
                if (e.key < children.length - 1)
                  Divider(
                    height: 1,
                    color: AppColors.glassDivider,
                    indent: 52,
                  ),
              ],
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final Color? labelColor;
  final String? value;
  final VoidCallback onTap;

  const SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppColors.glassIconBorderRadius),
              ),
              child: Icon(icon, size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: labelColor ?? AppColors.white,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.white.withValues(alpha: 0.5),
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

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
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppColors.glassIconBorderRadius),
              ),
              child: Icon(icon, size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.white,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.greenSheen,
              activeTrackColor: AppColors.greenSheen.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.white.withValues(alpha: 0.4),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}

class NewSemesterCard extends StatelessWidget {
  final StudentSettingsController controller;

  const NewSemesterCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'NEW SEMESTER',
            style: TextStyle(
              fontSize: FontStyles.titleTiny,
              fontWeight: FontStyles.weightMedium,
              color: AppColors.white.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: AppColors.glassCard(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starting a new semester? Set up your programme, blocked times, and subjects, then let the AI generate a fresh schedule from scratch.',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.white.withValues(alpha: 0.6),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: AppColors.glassTile(),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.greenSheen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppColors.glassIconBorderRadius),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Set Up New Semester',
                          style: TextStyle(
                            fontSize: FontStyles.titleSmall,
                            fontWeight: FontStyles.weightMedium,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.white.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.greenSheen, AppColors.californiaBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.black),
                            SizedBox(width: 8),
                            Text(
                              'Generate New Schedule',
                              style: TextStyle(
                                fontSize: FontStyles.titleSmall,
                                fontWeight: FontStyles.titleWeight,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}