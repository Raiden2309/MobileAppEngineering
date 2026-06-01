import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import '../../../controllers/classes_controller.dart';
import '../../../controllers/lecture_dashboard_controller.dart';
import '../../../models/class_model.dart';
import '../../../providers/lecturer_dashboard_provider.dart';
import '../../classes/class_detail_page.dart'; // REQUIRED IMPORT

class LecturerClassesCards extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const LecturerClassesCards({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<LecturerDashboardProvider>().classes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Classes',
              style: TextStyle(
                fontSize: FontStyles.titleMedium,
                fontWeight: FontStyles.weightHeavy,
                color: AppColors.black,
              ),
            ),
            GestureDetector(
              onTap: () => LecturerDashboardController.onSeeAllClasses(context, onSeeAll),
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  color: AppColors.black.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...classes.map(
              (c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            // FIXED: Wrapped row mapping layer into an active local structural routing context bridge
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailPage(classModel: c),
                  ),
                );
              },
              child: _ClassRow(model: c),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ClassRow extends StatelessWidget {
  final ClassModel model;

  const _ClassRow({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: model.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightMedium,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ClassesController.studentsMeta(model),
                  style: TextStyle(
                    fontSize: FontStyles.titleTiny,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '›',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}