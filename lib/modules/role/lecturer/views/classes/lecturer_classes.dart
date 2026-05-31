import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../controllers/classes_controller.dart';
import '../../providers/classes_provider.dart';
import 'widgets/class_card.dart';
import 'widgets/create_class_sheet.dart';


class LecturerClassesSection extends StatefulWidget {
  const LecturerClassesSection({super.key});

  @override
  State<LecturerClassesSection> createState() => _LecturerClassesSectionState();
}

class _LecturerClassesSectionState extends State<LecturerClassesSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<ClassesProvider>().fetchAllClasses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassesProvider>();
    final classes = provider.classes;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  GestureDetector(
                    onTap: () => CreateClassSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: AppColors.white),
                          SizedBox(width: 4),
                          Text(
                            'Add Class',
                            style: TextStyle(
                              fontSize: FontStyles.titleSmall,
                              fontWeight: FontStyles.weightMedium,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          child: classes.isEmpty
              ? const Center(child: Text('No classes yet. Tap Add Class to create one.'))
              : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              children: [
                ...classes.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClassCard(
                    classModel: c,
                    onTap: () => ClassesController.openClass(context, c),
                    onDelete: () => context.read<ClassesProvider>().deleteClass(c),
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