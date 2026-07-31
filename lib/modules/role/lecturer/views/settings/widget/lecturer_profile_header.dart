import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../controllers/lecturer_settings_controller.dart';
import '../../../providers/lecturer_settings_provider.dart';

class LecturerProfileHeader extends StatefulWidget {
  const LecturerProfileHeader({super.key});

  @override
  State<LecturerProfileHeader> createState() => _LecturerProfileHeaderState();
}

class _LecturerProfileHeaderState extends State<LecturerProfileHeader> {
  bool _editingName = false;
  late final TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final name = context.read<LecturerSettingsProvider>().data?.userName ?? '';
    _nameController = TextEditingController(text: name);
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
    if (image == null || !mounted) return;
    await LecturerSettingsController.updateAvatar(context, image);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerSettingsProvider>();
    final data = provider.data!;

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
                            LecturerSettingsController.updateUserName(
                              context,
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
                            _nameController.text = data.userName;
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
                          data.userName,
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
                'Lecturer · ${data.department} · ${data.activeClassesCount} active classes',
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
