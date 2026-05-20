import 'package:flutter/cupertino.dart';

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const StatBox({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: FontStyles.titleMedium,
              fontWeight: FontStyles.weightHeavy,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: FontStyles.titleTiny,
              color: AppColors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
