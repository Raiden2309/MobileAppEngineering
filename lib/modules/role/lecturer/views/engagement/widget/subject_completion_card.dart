import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../engagement.dart';
import 'completion_bar.dart';

class SubjectCompletionCard extends StatelessWidget {
  const SubjectCompletionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Subject Completion'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average completion rate of tasks students have tagged under each of your subjects.',
                style: TextStyle(
                  fontSize: FontStyles.titleTiny,
                  color: AppColors.black.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              CompletionBar(label: 'CT124', value: 0.62, color: AppColors.californiaBlue),
              const SizedBox(height: 10),
              CompletionBar(label: 'RM302', value: 0.54, color: AppColors.mikadoYellow),
              const SizedBox(height: 10),
              CompletionBar(label: 'MOB401', value: 0.59, color: AppColors.softPurple),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}