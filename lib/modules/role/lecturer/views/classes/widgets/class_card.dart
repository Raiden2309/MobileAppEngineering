import 'package:flutter/cupertino.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/classes/widgets/stat_box_classes.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/classes/class_detail_page.dart'; // ADD

import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class ClassCard extends StatelessWidget {
  final String name;
  final String code;
  final String students;
  final String avgDone;
  final String atRisk;
  final Color atRiskColor;
  final Color accentColor;
  final String semester;

  const ClassCard({
    required this.name,
    required this.code,
    required this.students,
    required this.avgDone,
    required this.atRisk,
    required this.atRiskColor,
    required this.accentColor,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(                          // ADD
      onTap: () => Navigator.push(                  // ADD
        context,                                    // ADD
        CupertinoPageRoute(                         // ADD — slides in from right like the prototype
          builder: (_) => ClassDetailPage(         // ADD
            name: name,                             // ADD
            code: code,                             // ADD
            students: students,                     // ADD
            avgDone: avgDone,                       // ADD
            atRisk: atRisk,                         // ADD
            atRiskColor: atRiskColor,               // ADD
            accentColor: accentColor,               // ADD
            semester: semester,                     // ADD
          ),                                        // ADD
        ),                                          // ADD
      ),                                            // ADD
      child: Container(                             // was the root widget, now child
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: FontStyles.titleMedium,
                          fontWeight: FontStyles.weightHeavy,
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: FontStyles.titleTiny,
                          color: AppColors.black.withValues(alpha: 0.55),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: StatBox(
                      value: students,
                      label: 'Students',
                      valueColor: AppColors.californiaBlue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: StatBox(
                      value: avgDone,
                      label: 'Avg Done',
                      valueColor: AppColors.mikadoYellow,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: StatBox(
                      value: atRisk,
                      label: 'At Risk',
                      valueColor: atRiskColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '📅 $semester',
                    style: TextStyle(
                      fontSize: FontStyles.titleTiny,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'View class ›',
                  style: TextStyle(
                    fontSize: FontStyles.titleSmall,
                    fontWeight: FontStyles.weightMedium,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}