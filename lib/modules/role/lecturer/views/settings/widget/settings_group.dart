import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: FontStyles.titleTiny,
              fontWeight: FontStyles.weightMedium,
              color: AppColors.legendText,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: AppColors.glassCard(),
          child: Column(
            children: children
                .asMap()
                .entries
                .map(
                  (e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.glassDivider,
                      indent: 52,
                    ),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}