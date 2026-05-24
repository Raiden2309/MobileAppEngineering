import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../modules/role/lecturer/providers/lecturer_settings_provider.dart';
import '../../../modules/role/lecturer/views/settings/lecturer_settings.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/font_styles.dart';

class LecturerHeader extends StatelessWidget {
  final bool hasUnreadAlerts;
  final VoidCallback onAlertsTapped;

  const LecturerHeader({
    super.key,
    required this.hasUnreadAlerts,
    required this.onAlertsTapped,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<LecturerSettingsProvider>();
    final avatarUrl = settingsProvider.avatarUrl;

    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/transparent_logo.png', width: 32),
              const SizedBox(width: 8),
              const Text(
                'Unplug',
                style: TextStyle(
                  fontSize: FontStyles.titleLarge,
                  fontWeight: FontStyles.titleWeight,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onAlertsTapped,
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.black,
                        size: 22,
                      ),
                    ),
                    if (hasUnreadAlerts)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LecturerSettingsPage(),
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Image.asset('assets/images/person.png', width: 24)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}