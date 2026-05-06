import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';
import '../../../controllers/student_setup_controller.dart';


class StudentSemester extends StatefulWidget {
  final SetupController controller;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StudentSemester({super.key, required this.controller, required this.onNext, required this.onBack});

  @override
  State<StudentSemester> createState() => StudentSemesterState();

}

class StudentSemesterState extends State<StudentSemester> {
  void handleNext(BuildContext context) {
    if (widget.controller.validate(widget.controller.programmeController.text, 'programme',
      emptyMessage: 'Please enter your programme',
    )) {
      widget.onNext();
    }
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          widget.controller.semStart = picked;
        } else {
          widget.controller.semEnd = picked;
        }
      });
    }
  }

  String formatDate(DateTime? d) => d == null ? 'Pick date' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return SetupScaffold(
      step: 2,
      title: 'Your Semester',
      subtitle: 'Add your current semester details so we can track your progress correctly.',
      onNext: () => handleNext(context),
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SetupLabel('Programme / Course'),
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) => SetupInput(
              controller: c.programmeController,
              placeholder: 'e.g. Diploma in Computer Science',
              errorText: c.getError('programme'),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SetupLabel('Semester'),
                    const SizedBox(height: 6),
                    SetupDropdown<int>(
                      value: c.semester,
                      items: List.generate(6, (i) => i + 1),
                      label: (v) => 'Semester $v',
                      onChanged: (v) => setState(() => c.semester = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SetupLabel('Year'),
                    const SizedBox(height: 6),
                    SetupDropdown<int>(
                      value: c.year,
                      items: List.generate(4, (i) => i + 1),
                      label: (v) => 'Year $v',
                      onChanged: (v) => setState(() => c.year = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SetupLabel('Start Date'),
                    const SizedBox(height: 6),
                    DateTile(label: formatDate(c.semStart), onTap: () => pickDate(context, true)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SetupLabel('End Date'),
                    const SizedBox(height: 6),
                    DateTile(label: formatDate(c.semEnd), onTap: () => pickDate(context, false)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DateTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const DateTile({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.black),
        ),
      ),
    );
  }
}