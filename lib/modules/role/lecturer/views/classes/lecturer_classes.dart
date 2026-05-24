import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../controllers/classes_controller.dart';
import '../../providers/classes_provider.dart';
import 'widgets/class_card.dart';

class LecturerClassesSection extends StatelessWidget {
  const LecturerClassesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassesProvider>().classes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Classes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Semester 4 · ${classes.length} active classes',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              children: [
                ...classes.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClassCard(
                    classModel: c,
                    onTap: () => ClassesController.openClass(context, c),
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}