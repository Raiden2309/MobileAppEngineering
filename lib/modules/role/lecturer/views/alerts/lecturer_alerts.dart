import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/styles/font_styles.dart';
import '../../controllers/alert_controller.dart';
import '../../models/class_enrollment_model.dart';
import '../../providers/alert_provider.dart';
import '../../models/alert_model.dart';
import '../view_student_profile/view_student_profile.dart';
import 'widgets/alert_filter_chips.dart';
import 'widgets/alert_row.dart';

class LecturerAlertsPage extends StatelessWidget {
  const LecturerAlertsPage({super.key});

  // Mark as read AFTER returning from the profile page instead
  Future<void> _goToProfile(BuildContext context, AlertModel alert) async {
    final student = ClassStudentModel(
      studentId: alert.studentId,
      name: alert.studentName,
      initials: alert.studentName.isNotEmpty
          ? alert.studentName[0].toUpperCase()
          : 'S',
      chipColor: alert.type == 'burnout' ? AppColors.red : AppColors.mikadoYellow,
      joinedAt: DateTime.now(),
      weeklyStudyHours: 0,
      completedTasks: 0,
      pendingTasks: 0,
      burnoutIndex: alert.type == 'burnout' ? 0.85 : 0.5,
      meta: alert.meta,
      chip: alert.type == 'burnout' ? 'At Risk' : 'Falling Behind',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewStudentProfilePage(student: student),
      ),
    );

    if (context.mounted) {
      AlertController.markAsRead(context, alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Student at-risk & burnout notifications',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              const AlertFilterChips(),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              children: provider.filtered.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AlertRow(
                  alert: alert,
                  onTap: () {},
                  onViewProfile: () => _goToProfile(context, alert),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}