import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../providers/engagement_provider.dart';
import 'completion_bar.dart';

class SubjectCompletionCard extends StatelessWidget {
  const SubjectCompletionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngagementProvider>();
    final completions = provider.subjectCompletions;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Completion Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (completions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'No subject metrics calculated yet.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            )
          else
            ...completions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CompletionBar(
                  label: entry.key.toUpperCase(), // Maps to constructor parameter label
                  value: entry.value,             // FIXED: Maps to constructor parameter value
                  color: AppColors.californiaBlue, // FIXED: Maps to constructor parameter color
                ),
              );
            }),
        ],
      ),
    );
  }
}