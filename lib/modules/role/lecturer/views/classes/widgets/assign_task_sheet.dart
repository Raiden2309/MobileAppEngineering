import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/shared/styles/font_styles.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/classes_provider.dart';

class AssignTaskSheet extends StatefulWidget {
  final String classId;
  final String subjectCode;
  final String semester;

  const AssignTaskSheet({
    super.key,
    required this.classId,
    required this.subjectCode,
    required this.semester,
  });

  static void show(BuildContext context, String classId, String subjectCode, String semester) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignTaskSheet(classId: classId, subjectCode: subjectCode, semester: semester),
    );
  }

  @override
  State<AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends State<AssignTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Default deadline to exactly 1 week out matching baseline tracking standards
    _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// INLINE DATE PICKER: Renders student-side dark thematic design picker interface
  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.californiaBlue,
              onPrimary: AppColors.black,
              surface: Color(0xFF1E2330),
              onSurface: AppColors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E2330),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2330), // Match student dark container theme blueprint verbatim
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assign Class Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'This task will be distributed instantly to all students enrolled in ${widget.subjectCode.toUpperCase()}.',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 20),

          _Label('Task Title'),
          const SizedBox(height: 6),
          _Field(controller: _titleController, hint: 'e.g. Complete Lab Worksheet 4'),
          const SizedBox(height: 12),

          _Label('Task Description / Instructions'),
          const SizedBox(height: 6),
          _Field(controller: _descController, hint: 'Add description lines...', maxLines: 3),
          const SizedBox(height: 12),

          _Label('Due Date Deadline'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDueDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDueDate == null
                        ? 'Select deadline date...'
                        : DateFormat('yyyy-MM-dd (EEEE)').format(_selectedDueDate!),
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedDueDate == null ? Colors.white38 : AppColors.white,
                    ),
                  ),
                  const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Colors.white12, width: 1),
              ),
              // FIXED: Added async modifier to the button closure signature
              onPressed: () async {
                final title = _titleController.text.trim();
                if (title.isEmpty) return;

                final String targetDateString = _selectedDueDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
                    : DateTime.now().toIso8601String().split('T').first;

                // while the async write transactions process efficiently in the background
                await context.read<ClassesProvider>().assignTaskToClass(
                  classId: widget.classId,
                  subjectCode: widget.subjectCode,
                  semester: widget.semester,
                  taskTitle: title,
                  description: _descController.text.trim(),
                  dueDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
                );

                if (context.mounted) {
                  Navigator.pop(context); // CLOSES INSTANTLY
                }
              },
              child: const Text(
                'Publish Task to Students',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.californiaBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.white, fontSize: 13),
      cursorColor: AppColors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: AppColors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      ),
    );
  }
}