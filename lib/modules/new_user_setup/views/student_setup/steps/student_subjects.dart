import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';
import '../../../controllers/student_setup_controller.dart';


class StudentSubjects extends StatefulWidget {
  final SetupController controller;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StudentSubjects({super.key, required this.controller, required this.onNext, required this.onBack});

  @override
  State<StudentSubjects> createState() => StudentSubjectsState();
}

class StudentSubjectsState extends State<StudentSubjects> {
  void handleNext(BuildContext context) {
    if (widget.controller.validateSubjects()) {
      widget.onNext();
    }
  }

  Color parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return SetupScaffold(
      step: 3,
      title: 'Add Your Subjects',
      subtitle: "Add the subjects you're taking this semester. You can always edit these later.",
      onNext: () => handleNext(context),
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SetupLabel('Subjects'),
          const SizedBox(height: 8),
          ...List.generate(c.subjects.length, (i) {
            final subj = c.subjects[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: AppColors.white.withOpacity(0.07)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: parseColor(subj['color']!), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(subj['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFE5E7EB)))),
                  GestureDetector(
                    onTap: () => setState(() => c.removeSubject(i)),
                    child: const Text('✕', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SetupInput(
                  controller: c.newSubjectController,
                  placeholder: 'Subject name…',
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => c.addSubject()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    border: Border.all(color: AppColors.white.withOpacity(0.07)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('+ Add', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final error = widget.controller.getError('subjects');
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(error, style: const TextStyle(color: AppColors.red, fontSize: 12)),
              );
            },
          ),
        ],
      ),
    );
  }
}