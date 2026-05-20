import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class StatusCard extends StatelessWidget {
  final String label;
  final String count;
  final String sub;
  final Color? color;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.sub,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: AppColors.glassCard(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: FontStyles.titleGreeting,
                      fontWeight: FontStyles.titleWeight,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: FontStyles.titleSmall,
                      color: AppColors.legendText,
                    ),
                  ),
                ],
              ),
              Icon(icon, color: c, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
