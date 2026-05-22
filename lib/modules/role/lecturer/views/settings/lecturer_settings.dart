import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../../../auth/views/change_password.dart';
import '../../controllers/lecturer_settings_controller.dart';
import '../../models/lecturer_settings_model.dart';
import '../../providers/lecturer_settings_provider.dart';

class LecturerSettingsPage extends StatelessWidget {
  final LecturerSettingsController controller;
  final LecturerSettingsProvider navigationProvider;

  const LecturerSettingsPage({
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
              return _LecturerSettingsBody(
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

class _LecturerSettingsBody extends StatelessWidget {
  final LecturerSettingsController controller;
  final LecturerSettingsModel data;
  final LecturerSettingsProvider navigationProvider;

  const _LecturerSettingsBody({
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
          _LecturerProfileHeader(
            data: data,
            navigationProvider: navigationProvider,
            controller: controller,
          ),
          const SizedBox(height: 24),

          // ── ACCOUNT ──────────────────────────────────────────────
          SettingsGroup(
            title: 'Account',
            children: [
              SettingsRow(
                icon: Icons.lock_rounded,
                iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                label: 'Change Password',
                onTap: () => ChangePassword.startChangePassword(
                  context,
                  userId: data.userId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── NOTIFICATIONS ─────────────────────────────────────────
          SettingsGroup(
            title: 'Notifications',
            children: [
              ToggleRow(
                icon: Icons.local_fire_department_rounded,
                iconBg: AppColors.red.withValues(alpha: 0.2),
                label: 'Burnout Alerts',
                value: data.burnoutAlerts,
                onToggle: controller.toggleBurnoutAlerts,
              ),
              ToggleRow(
                icon: Icons.warning_amber_rounded,
                iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                label: 'Falling Behind Alerts',
                value: data.fallingBehindAlerts,
                onToggle: controller.toggleFallingBehindAlerts,
              ),
              ToggleRow(
                icon: Icons.bar_chart_rounded,
                iconBg: AppColors.softPurple.withValues(alpha: 0.2),
                label: 'Weekly Engagement Report',
                value: data.weeklyEngagementReport,
                onToggle: controller.toggleWeeklyEngagementReport,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── ABOUT ─────────────────────────────────────────────────
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

// ── PROFILE HEADER ────────────────────────────────────────────────────────────

class _LecturerProfileHeader extends StatefulWidget {
  final LecturerSettingsModel data;
  final LecturerSettingsProvider navigationProvider;
  final LecturerSettingsController controller;

  const _LecturerProfileHeader({
    required this.data,
    required this.navigationProvider,
    required this.controller,
  });

  @override
  State<_LecturerProfileHeader> createState() => _LecturerProfileHeaderState();
}

class _LecturerProfileHeaderState extends State<_LecturerProfileHeader> {
  bool _editingName = false;
  late final TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null) return;
    await widget.controller.updateAvatar(image);
  }

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
              // Avatar with pencil overlay
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    ListenableBuilder(
                      listenable: widget.controller,
                      builder: (context, _) {
                        final url = widget.controller.avatarUrl;
                        return Container(
                          width: 72,
                          height: 72,
                          decoration: AppColors.glassCard(borderRadius: 36),
                          clipBehavior: Clip.antiAlias,
                          child: url != null
                              ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              size: 36,
                              color: AppColors.white,
                            ),
                          )
                              : const Icon(
                            Icons.person_rounded,
                            size: 36,
                            color: AppColors.white,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.californiaBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Inline name edit
              _editingName
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 160,
                    height: 36,
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      cursorColor: AppColors.white,
                      cursorHeight: 20,
                      style: const TextStyle(
                        fontSize: FontStyles.titleLarge,
                        fontWeight: FontStyles.titleWeight,
                        color: AppColors.white,
                        height: 1.0,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      widget.controller
                          .updateUserName(_nameController.text.trim());
                      setState(() => _editingName = false);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 16, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      _nameController.text = widget.data.userName;
                      setState(() => _editingName = false);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.white),
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.data.userName,
                    style: const TextStyle(
                      fontSize: FontStyles.titleLarge,
                      fontWeight: FontStyles.titleWeight,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _editingName = true),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Lecturer · ${widget.data.department} · ${widget.data.activeClassesCount} active classes',
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

// ── REUSED WIDGETS (unchanged) ────────────────────────────────────────────────

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
              color: AppColors.legendText,
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
                .map(
                  (e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.glassDivider,
                      indent: 52,
                    ),
                ],
              ),
            )
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
                borderRadius: BorderRadius.circular(
                  AppColors.glassIconBorderRadius,
                ),
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
                  color: AppColors.legendText,
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
                borderRadius: BorderRadius.circular(
                  AppColors.glassIconBorderRadius,
                ),
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
              activeThumbColor: AppColors.lime,
              activeTrackColor: AppColors.lime.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.white.withValues(alpha: 0.4),
              inactiveTrackColor: AppColors.white.withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}