import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/student/controllers/burnout_alert_controller.dart';
import 'package:mae_assignment_frontend/modules/role/student/controllers/student_settings_controller.dart';
import '../../styles/app_colors.dart';
import '../../styles/font_styles.dart';
import '../../../modules/role/student/views/burnout_alert/burnout_alert_bottom_sheet.dart';

class StudentHeader extends StatelessWidget {
  final VoidCallback onProfileTapped;

  const StudentHeader({
    super.key,
    required this.onProfileTapped, required BurnoutAlertController burnoutAlertController, required StudentSettingsController settingsController,
  });

  void showBurnoutAlert(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const BurnoutAlertBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onTap: () => showBurnoutAlert(context),
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Image.asset('assets/images/burnout_fire.png', width: 24),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onProfileTapped,
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Image.asset('assets/images/person.png', width: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}