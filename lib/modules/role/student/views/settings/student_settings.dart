import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../../../auth/views/change_password.dart';
import '../../controllers/student_settings_controller.dart';
import '../../models/student_settings_models.dart';
import '../../providers/student_settings_provider.dart';
import 'bottom_sheet_widgets/blocked_times_sheet.dart';
import 'bottom_sheet_widgets/joined_classes_sheet.dart';
import 'bottom_sheet_widgets/semester_sheet.dart';
import 'bottom_sheet_widgets/study_hours_sheet.dart';
import 'bottom_sheet_widgets/subjects_sheet.dart';

class StudentSettingsPage extends StatelessWidget {
  const StudentSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentSettingsProvider>();

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
              if (provider.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.data == null) {
                return const Center(child: Text('No settings found'));
              }
              return const SettingsBody();
            },
          ),
        ),
      ),
    );
  }
}

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentSettingsProvider>();
    final data = provider.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        children: [
          ProfileHeader(data: data),
          const SizedBox(height: 24),
          SettingsGroup(
            title: 'Account',
            children: [
              SettingsRow(
                icon: Icons.lock_rounded,
                iconBg: AppColors.californiaBlue.withValues(alpha: 0.2),
                label: 'Change Password',
                onTap: () => ChangePassword.startChangePassword(
                  context,
                  userId: data.userId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Classes',
            children: [
              SettingsRow(
                icon: Icons.lock_rounded,
                iconBg: AppColors.californiaBlue.withValues(alpha: 0.2),
                label: 'Join Class',
                value: '${data.joinedClassCount} classes',
                onTap: () => JoinedClassesSheet.show(context),
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
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const StudyHoursSheet(),
                ),
              ),
              SettingsRow(
                icon: Icons.block_rounded,
                iconBg: AppColors.red.withValues(alpha: 0.2),
                label: 'Blocked Times',
                value: '${data.blockedSlotsCount} slots',
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const BlockedTimesSheet(),
                ),
              ),
              SettingsRow(
                icon: Icons.menu_book_rounded,
                iconBg: AppColors.softPurple.withValues(alpha: 0.2),
                label: 'Subjects',
                value: '${data.subjectCount} subjects',
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const SubjectsSheet(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const NewSemesterCard(),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Notifications',
            children: [
              ToggleRow(
                icon: Icons.notifications_rounded,
                iconBg: AppColors.greenSheenDark.withValues(alpha: 0.9),
                label: 'Task Reminders',
                value: data.taskReminders,
                onToggle: provider.toggleTaskReminders,
              ),
              ToggleRow(
                icon: Icons.alarm_rounded,
                iconBg: AppColors.mikadoYellow.withValues(alpha: 0.2),
                label: 'Slot End Prompts',
                value: data.slotEndPrompts,
                onToggle: provider.toggleSlotEndPrompts,
              ),
              ToggleRow(
                icon: Icons.local_fire_department_rounded,
                iconBg: AppColors.red.withValues(alpha: 0.2),
                label: 'Burnout Warnings',
                value: data.burnoutWarnings,
                onToggle: provider.toggleBurnoutWarnings,
              ),
              ToggleRow(
                icon: Icons.calendar_today_rounded,
                iconBg: AppColors.greenSheenDark.withValues(alpha: 0.9),
                label: 'Weekly Reset Summary',
                value: data.weeklyResetSummary,
                onToggle: provider.toggleWeeklyResetSummary,
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
                onTap: () => StudentSettingsController.signOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  final StudentSettingsModel data;

  const ProfileHeader({super.key, required this.data});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
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
    if (!mounted) return;
    await context.read<StudentSettingsProvider>().updateAvatar(image);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentSettingsProvider>();

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
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: AppColors.glassCard(borderRadius: 36),
                      clipBehavior: Clip.antiAlias,
                      child: provider.avatarUrl != null
                          ? Image.network(
                        provider.avatarUrl!,
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
                      context.read<StudentSettingsProvider>().updateUserName(
                        _nameController.text.trim(),
                      );
                      setState(() => _editingName = false);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.2),
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
                'Semester ${widget.data.semester} · Year ${widget.data.year} · ${widget.data.subjectCount} subjects',
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

  const SettingsGroup({super.key, required this.title, required this.children});

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
    super.key,
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
    super.key,
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

class NewSemesterCard extends StatelessWidget {
  const NewSemesterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentSettingsProvider>();
    final semesters = provider.data?.semesters ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'SEMESTER',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...semesters.map(
                    (semester) => Column(
                  children: [
                    GestureDetector(
                      onTap: () => StudentSettingsController.selectSemester(context, semester.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: AppColors.glassTile(),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: semester.isCurrent
                                    ? AppColors.greenSheenDark.withValues(alpha: 0.9)
                                    : AppColors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppColors.glassIconBorderRadius,
                                ),
                              ),
                              child: Icon(
                                semester.isCurrent
                                    ? Icons.check_circle_rounded
                                    : Icons.calendar_month_rounded,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    semester.name,
                                    style: const TextStyle(
                                      fontSize: FontStyles.titleSmall,
                                      fontWeight: FontStyles.weightMedium,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Text(
                                    '${semester.subjectCount} subjects · ${semester.studyHoursStart} – ${semester.studyHoursEnd}',
                                    style: TextStyle(
                                      fontSize: FontStyles.titleTiny,
                                      color: AppColors.legendText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (semester.isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lime.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: FontStyles.titleTiny,
                                    color: AppColors.greenSheenDark.withValues(alpha: 0.9),
                                    fontWeight: FontStyles.weightMedium,
                                  ),
                                ),
                              ),
                            // ── Edit button ──
                            GestureDetector(
                              onTap: () => SemesterSheet.show(
                                context,
                                existing: {
                                  'name':  semester.name,
                                  'start': semester.start,
                                  'end':   semester.end,
                                },
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppColors.black.withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white.withValues(
                                    alpha: semester.isCurrent ? 0.6 : 0.35,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: semester.isCurrent
                                  ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => SemesterSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: AppColors.glassTile(),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.californiaBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppColors.glassIconBorderRadius),
                        ),
                        child: const Icon(Icons.add_rounded, size: 16, color: AppColors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add New Semester',
                          style: TextStyle(
                            fontSize: FontStyles.titleSmall,
                            fontWeight: FontStyles.weightMedium,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
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