import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/alert_controller.dart';
import '../../../models/alert_model.dart';

class AlertRow extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final VoidCallback? onViewProfile;

  const AlertRow({
    super.key,
    required this.alert,
    this.onTap,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead   = alert.read;
    final bool isUnread = AlertController.isUnread(alert);
    final Color dotColor = AlertController.colorFor(alert);

    return Opacity(
      opacity: isRead ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white.withValues(alpha: 0.3)
                          : dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${alert.emoji} ${alert.title}',
                      style: TextStyle(
                        fontSize: FontStyles.titleSmall,
                        fontWeight: FontStyles.weightHeavy,
                        color: isRead
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                alert.meta,
                style: const TextStyle(
                  fontSize: FontStyles.titleTiny,
                  color: AppColors.legendText,
                  height: 1.4,
                ),
              ),
              if (!isRead) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onViewProfile,
                  child: Text(
                    'View student profile ›',
                    style: TextStyle(
                      fontSize: FontStyles.titleTiny,
                      fontWeight: FontStyles.weightHeavy,
                      color: dotColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}