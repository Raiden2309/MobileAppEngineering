import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/providers/classes_provider.dart';

class EditTaskSheet extends StatefulWidget {
  final String classId;
  final Map<String, dynamic> task;

  const EditTaskSheet({
    super.key,
    required this.classId,
    required this.task,
  });

  static void show(BuildContext context, String classId, Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskSheet(classId: classId, task: task),
    );
  }

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task['title']?.toString() ?? '';
    _descController.text = widget.task['description']?.toString() ?? '';

    final String? rawDate = widget.task['dueDate']?.toString() ?? widget.task['due_date']?.toString();
    if (rawDate != null) {
      _selectedDueDate = DateTime.tryParse(rawDate.split('T').first);
    }
    _selectedDueDate ??= DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
        color: Color(0xFF1E2330),
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
                'Edit Class Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Task Title', style: TextStyle(fontSize: 12, color: AppColors.white)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(filled: true, fillColor: AppColors.black, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 12),
          const Text('Task Description', style: TextStyle(fontSize: 12, color: AppColors.white)),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(filled: true, fillColor: AppColors.black, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 12),
          const Text('Due Date Deadline', style: TextStyle(fontSize: 12, color: AppColors.white)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDueDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(10)),
              child: Text(
                DateFormat('yyyy-MM-dd').format(_selectedDueDate!),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                final title = _titleController.text.trim();
                if (title.isEmpty) return;

                final dateString = DateFormat('yyyy-MM-dd').format(_selectedDueDate!);

                await context.read<ClassesProvider>().updateClassTask(
                  classId: widget.classId,
                  taskId: widget.task['id'].toString(),
                  updatedTitle: title,
                  updatedDescription: _descController.text.trim(),
                  updatedDueDate: dateString,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Changes', style: TextStyle(color: AppColors.californiaBlue)),
            ),
          ),
        ],
      ),
    );
  }
}