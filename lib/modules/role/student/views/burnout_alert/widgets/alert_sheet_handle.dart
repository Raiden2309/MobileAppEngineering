import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';

class AlertSheetHandle extends StatelessWidget {
  final double bottomMargin;

  const AlertSheetHandle({super.key, this.bottomMargin = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}