import 'package:flutter/material.dart';
import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';
import '../../../controllers/student_setup_controller.dart';

class StudentSemester extends StatefulWidget {
  final SetupController controller;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StudentSemester({
    super.key,
    required this.controller,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StudentSemester> createState() => StudentSemesterState();
}

class StudentSemesterState extends State<StudentSemester> {
  final List<DateTime?> _examDates = [null];
  String? _semStartError;
  String? _semEndError;

  void handleNext(BuildContext context) {
    final programmeValid = widget.controller.validate(
      widget.controller.programmeController.text,
      'programme',
      emptyMessage: 'Please enter your programme',
    );

    setState(() {
      _semStartError = widget.controller.semStart == null
          ? 'Please pick a start date'
          : null;

      if (widget.controller.semEnd == null) {
        _semEndError = 'Please pick an end date';
      } else if (widget.controller.semStart != null &&
          !widget.controller.semEnd!.isAfter(widget.controller.semStart!)) {
        _semEndError = 'End date must be after start date';
      } else {
        _semEndError = null;
      }
    });

    if (!programmeValid || _semStartError != null || _semEndError != null) return;

    widget.controller.examDates = _examDates.whereType<DateTime>().toList();
    widget.onNext();
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
          _semStartError = null;
        } else {
          widget.controller.semEnd = picked;
          _semEndError = null;
        }
      });
    }
  }

  Future<void> _pickExamDate(int index) async {
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
    if (picked != null) setState(() => _examDates[index] = picked);
  }

  String formatDate(DateTime? d) =>
      d == null ? 'Pick date' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return SetupScaffold(
      step: 2,
      title: 'Your Semester',
      subtitle:
      'Add your current semester details so we can track your progress correctly.',
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
                    DateTile(
                      label: formatDate(c.semStart),
                      onTap: () => pickDate(context, true),
                      errorText: _semStartError,
                    ),
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
                    DateTile(
                      label: formatDate(c.semEnd),
                      onTap: () => pickDate(context, false),
                      errorText: _semEndError,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SetupLabel('Final Exam Dates (Optional)'),
              GestureDetector(
                onTap: () => setState(() => _examDates.add(null)),
                child: const Icon(Icons.add_circle_outline, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...List.generate(_examDates.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (_examDates.length > 1) ...[
                    GestureDetector(
                      onTap: () => setState(() => _examDates.removeAt(i)),
                      child: const Icon(Icons.remove_circle_outline,
                          size: 20, color: Colors.redAccent),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: DateTile(
                      label: formatDate(_examDates[i]),
                      onTap: () => _pickExamDate(i),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DateTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? errorText;

  const DateTile({
    super.key,
    required this.label,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: hasError ? AppColors.red : AppColors.black,
                width: hasError ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: label == 'Pick date' ? Colors.grey : AppColors.black,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}