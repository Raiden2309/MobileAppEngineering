import 'package:flutter/material.dart';
import '../../../../../../../shared/styles/app_colors.dart';
import '../../../../../../../shared/styles/font_styles.dart';

class StudentSectionLabel extends StatelessWidget {
  final String text;

  const StudentSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: FontStyles.titleTiny,
        fontWeight: FontStyles.weightMedium,
        color: AppColors.legendText,
        letterSpacing: 0.8,
      ),
    );
  }
}