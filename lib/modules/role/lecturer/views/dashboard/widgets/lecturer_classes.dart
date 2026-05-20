import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class LecturerClasses extends StatelessWidget {
  const LecturerClasses({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'See all',
              style: TextStyle(
                fontSize: FontStyles.titleSmall,
                fontWeight: FontStyles.weightMedium,
                color: AppColors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _ClassRow(
          emoji: '🖥️',
          name: 'CT124 System Proposal',
          meta: '28 students · 62% avg completion',
          accentColor: AppColors.californiaBlue,
        ),
        const SizedBox(height: 8),
        const _ClassRow(
          emoji: '🔬',
          name: 'Research Methods',
          meta: '24 students · 54% avg completion',
          accentColor: AppColors.mikadoYellow,
        ),
        const SizedBox(height: 8),
        const _ClassRow(
          emoji: '📱',
          name: 'Mobile Development',
          meta: '20 students · 59% avg completion',
          accentColor: AppColors.softPurple,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ClassRow extends StatelessWidget {
  final String emoji;
  final String name;
  final String meta;
  final Color accentColor;

  const _ClassRow({
    required this.emoji,
    required this.name,
    required this.meta,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppColors.glassTile(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightMedium,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
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