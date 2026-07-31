import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../lecturer/views/settings/widget/settings_group.dart';
import '../../../lecturer/views/settings/widget/settings_row.dart';
import '../../../lecturer/views/settings/widget/toggle_row.dart';
import '../../controllers/lecturer_settings_controller.dart';
import '../../providers/lecturer_settings_provider.dart';

class LecturerSettingsPage extends StatelessWidget {
  const LecturerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.californiaBlue, AppColors.greenSheen],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
                    // Dynamic Profile Layout with matched back navigation structure
                    const DeployedLecturerProfileHeader(),
                    const SizedBox(height: 24),

                    SettingsGroup(
                      title: 'Account',
                      children: [
                        SettingsRow(
                          icon: Icons.lock_rounded,
                          iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                          label: 'Change Password',
                          onTap: () =>
                              LecturerSettingsController.openChangePassword(
                                context,
                              ),
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
                          onToggle: () =>
                              LecturerSettingsController.toggleBurnoutAlerts(
                                context,
                              ),
                        ),
                        ToggleRow(
                          icon: Icons.warning_amber_rounded,
                          iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                          label: 'Falling Behind Alerts',
                          value: data.fallingBehindAlerts,
                          onToggle: () =>
                              LecturerSettingsController.toggleFallingBehindAlerts(
                                context,
                              ),
                        ),
                        ToggleRow(
                          icon: Icons.bar_chart_rounded,
                          iconBg: AppColors.softPurple.withValues(alpha: 0.2),
                          label: 'Weekly Engagement Report',
                          value: data.weeklyEngagementReport,
                          onToggle: () =>
                              LecturerSettingsController.toggleWeeklyEngagementReport(
                                context,
                              ),
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
                          onTap: () =>
                              LecturerSettingsController.signOut(context),
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

class DeployedLecturerProfileHeader extends StatefulWidget {
  const DeployedLecturerProfileHeader({super.key});

  @override
  State<DeployedLecturerProfileHeader> createState() =>
      _DeployedLecturerProfileHeaderState();
}

class _DeployedLecturerProfileHeaderState
    extends State<DeployedLecturerProfileHeader> {
  bool _editingModeActive = false;
  late final TextEditingController _nameEditingFieldController;
  final ImagePicker _avatarImagePickerEngine = ImagePicker();

  @override
  void initState() {
    super.initState();
    final String initialProfileNameStringValue =
        context.read<LecturerSettingsProvider>().data?.userName ?? '';
    _nameEditingFieldController = TextEditingController(
      text: initialProfileNameStringValue,
    );
  }

  @override
  void dispose() {
    _nameEditingFieldController.dispose();
    super.dispose();
  }

  Future<void> _triggerAvatarImageSelectionPipeline() async {
    final XFile? selectedImageFileReference = await _avatarImagePickerEngine
        .pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );
    if (selectedImageFileReference == null) return;
    if (!mounted) return;
    await LecturerSettingsController.updateAvatar(
      context,
      selectedImageFileReference,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProviderInstanceRef = context
        .watch<LecturerSettingsProvider>();
    final settingsModelPayloadData = currentProviderInstanceRef.data!;

    // FIXED: Wrapped with an absolute left alignment stack matching student formatting constraints
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
              GestureDetector(
                onTap: _triggerAvatarImageSelectionPipeline,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: currentProviderInstanceRef.avatarUrl != null
                          ? Image.network(
                              currentProviderInstanceRef.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
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
              _editingModeActive
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 36,
                          child: TextField(
                            controller: _nameEditingFieldController,
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
                            LecturerSettingsController.updateUserName(
                              context,
                              _nameEditingFieldController.text.trim(),
                            );
                            setState(() => _editingModeActive = false);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            _nameEditingFieldController.text =
                                settingsModelPayloadData.userName;
                            setState(() => _editingModeActive = false);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          settingsModelPayloadData.userName,
                          style: const TextStyle(
                            fontSize: FontStyles.titleLarge,
                            fontWeight: FontStyles.titleWeight,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _editingModeActive = true),
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
                '${settingsModelPayloadData.department} · Faculty Portal',
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
