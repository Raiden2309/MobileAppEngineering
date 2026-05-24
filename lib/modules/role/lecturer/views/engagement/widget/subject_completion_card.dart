import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'completion_bar.dart';
import 'engagement_section_header.dart';

class SubjectCompletionCard extends StatelessWidget {
  const SubjectCompletionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EngagementSectionHeader(title: 'Subject Completion'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average completion rate of tasks students have tagged under each of your subjects.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const CompletionBar(label: 'CT124', value: 0.62, color: AppColors.californiaBlue),
              const SizedBox(height: 10),
              const CompletionBar(label: 'RM302', value: 0.54, color: AppColors.mikadoYellow),
              const SizedBox(height: 10),
              const CompletionBar(label: 'MOB401', value: 0.59, color: AppColors.softPurple),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}