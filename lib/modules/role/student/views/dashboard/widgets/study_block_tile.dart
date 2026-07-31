import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../models/app_enums.dart';
import '../../../models/study_plan_model.dart';

class StudyBlockTile extends StatelessWidget {
  final StudyBlock block;

  const StudyBlockTile({super.key, required this.block});

  static const List<Color> _subjectAccentColors = [
    AppColors.californiaBlue,
    AppColors.greenSheen,
    AppColors.softPurple,
    AppColors.skyCyan,
    AppColors.nectarine,
    AppColors.pink,
    AppColors.lime,
    AppColors.mikadoYellow,
  ];

  Color get _accentColor {
    if (block.type == BlockType.blocked) return AppColors.red;
    if (block.type == BlockType.breakSlot) return AppColors.black;
    final key = block.subject ?? block.title;
    return _subjectAccentColors[key.hashCode.abs() %
        _subjectAccentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppColors.glassTile().copyWith(
        border: Border.all(color: AppColors.black),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.titleWeight,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (block.subject != null && block.subject!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    block.subject!,
                    style: const TextStyle(
                      color: AppColors.legendText,
                      fontSize: FontStyles.titleTiny,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${block.startTime} – ${block.endTime}',
            style: const TextStyle(
              color: AppColors.legendText,
              fontSize: FontStyles.titleSmall,
              fontWeight: FontStyles.weightMedium,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
