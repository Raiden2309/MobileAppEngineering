import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/semester_progress_model.dart';

class OverallProgressCard extends StatelessWidget {
  final SemesterProgressModel model;

  const OverallProgressCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCard(),
      child: Row(
        children: [
          RingProgress(progress: model.overallProgress),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OVERALL PROGRESS',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: FontStyles.titleSmall,
                  fontWeight: FontStyles.weightMedium,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(model.overallProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.lime,
                  fontSize: FontStyles.titleGreeting,
                  fontWeight: FontStyles.weightHeavy,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${model.completedTasks} of ${model.totalTasks} tasks completed',
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: FontStyles.titleSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── RingProgress ──────────────────────────────────────────

class RingProgress extends StatelessWidget {
  final double progress;

  const RingProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: RingPainter(progress: progress),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: AppColors.lime,
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.weightHeavy,
            ),
          ),
        ),
      ),
    );
  }
}

// ── RingPainter ───────────────────────────────────────────

class RingPainter extends CustomPainter {
  final double progress;

  const RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 5;
    const strokeWidth = 5.0;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: AppColors.glassTileOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(RingPainter old) => old.progress != progress;
}