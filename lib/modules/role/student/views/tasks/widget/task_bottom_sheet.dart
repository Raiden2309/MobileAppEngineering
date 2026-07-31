import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../controllers/tasks_controller.dart';
import '../../../models/app_enums.dart';
import '../../../models/tasks_model.dart';
import 'confirm_delete_widget.dart';

class TaskBottomSheet extends StatefulWidget {
  final TaskController controller;
  final List<SubjectGroup> groups;
  final SubjectGroup? group;
  final Task? existing;

  const TaskBottomSheet({
    super.key,
    required this.controller,
    required this.groups,
    this.group,
    this.existing,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskController controller,
    required List<SubjectGroup> groups,
    SubjectGroup? group,
    Task? existing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskBottomSheet(
        controller: controller,
        groups: groups,
        group: group,
        existing: existing,
      ),
    );
  }

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _hoursController;

  late TaskStatus _status;
  late SubjectGroup? _selectedGroup;
  DateTime? _selectedDueDate;
  bool _saving = false;
  String? _hoursError;

  bool get isEditing => widget.existing != null;

  TaskStatus _computeLiveStatus(Task task) {
    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.inProgress) {
      return task.status;
    }
    if (task.dueDate == null) return task.status;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
    if (taskDate.isBefore(todayDate)) return TaskStatus.overdue;
    if (taskDate.isAtSameMomentAs(todayDate)) return TaskStatus.dueToday;
    final diff = taskDate.difference(todayDate).inDays;
    if (diff <= 3) return TaskStatus.dueSoon;
    return task.status;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _hoursController = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.estimatedHours.toString()
          : '',
    );
    _status = widget.existing != null
        ? _computeLiveStatus(widget.existing!)
        : TaskStatus.toDo;
    _selectedGroup = widget.groups.isEmpty
        ? null
        : widget.groups.firstWhere(
            (g) => g.id == (widget.group?.id ?? widget.groups.first.id),
            orElse: () => widget.groups.first,
          );
    _selectedDueDate = widget.existing?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.californiaBlue,
              onPrimary: AppColors.black,
              surface: Color(0xFF1E2330),
              onSurface: AppColors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E2330),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        if (_status != TaskStatus.completed &&
            _status != TaskStatus.inProgress) {
          final now = DateTime.now();
          final todayDate = DateTime(now.year, now.month, now.day);
          final taskDate = DateTime(picked.year, picked.month, picked.day);
          if (taskDate.isBefore(todayDate)) {
            _status = TaskStatus.overdue;
          } else if (taskDate.isAtSameMomentAs(todayDate)) {
            _status = TaskStatus.dueToday;
          } else if (taskDate.difference(todayDate).inDays <= 3) {
            _status = TaskStatus.dueSoon;
          } else {
            _status = TaskStatus.upcoming;
          }
        }
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final hoursText = _hoursController.text.trim();
    final hours = double.tryParse(hoursText);
    if (title.isEmpty || _selectedGroup == null) return;
    if (hours == null || hours <= 0) {
      setState(() => _hoursError = 'Hours must be greater than 0 (e.g. 1.5)');
      return;
    }
    if (hours > 24) {
      setState(() => _hoursError = 'Hours cannot exceed 24 in a single day');
      return;
    }
    setState(() => _hoursError = null);

    if (mounted) Navigator.pop(context); // ← MOVED HERE

    if (isEditing) {
      await widget.controller.updateTask(
        widget.existing!.copyWith(
          title: title,
          estimatedHours: hours,
          status: _status,
          dueDate: _selectedDueDate,
        ),
      );
    } else {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('enrollments')
            .doc(_selectedGroup!.id);
        final newTaskMap = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': title,
          'estimated_hours': hours,
          'status': _status.name,
          'due_date': _selectedDueDate?.toIso8601String(),
        };

        await docRef.update({
          'tasksList': FieldValue.arrayUnion([newTaskMap]),
          'pendingTasks': FieldValue.increment(
            _status != TaskStatus.completed ? 1 : 0,
          ),
          'completedTasks': FieldValue.increment(
            _status == TaskStatus.completed ? 1 : 0,
          ),
        });
        widget.controller.refreshCache();
      } catch (e) {
        debugPrint('Failed to save task: $e');
      }
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    await widget.controller.deleteTask(widget.existing!);
    if (mounted) Navigator.pop(context);
  }

  void _confirmDelete() =>
      ConfirmDeleteWidget.show(context, onConfirm: _delete);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    if (_selectedGroup != null && widget.groups.isNotEmpty) {
      final matches = widget.groups.any((g) => g.id == _selectedGroup!.id);
      if (!matches) {
        _selectedGroup = widget.groups.first;
      } else {
        _selectedGroup = widget.groups.firstWhere(
          (g) => g.id == _selectedGroup!.id,
        );
      }
    }

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
              Text(
                isEditing ? 'Edit Task' : 'Add Task',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Row(
                children: [
                  if (isEditing)
                    GestureDetector(
                      onTap: _saving ? null : _confirmDelete,
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppColors.red,
                        ),
                      ),
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
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isEditing
                ? 'Update the details below.'
                : 'Fill in the details to add a new task.',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 20),
          _Label('Subject'),
          const SizedBox(height: 6),

          // Streamlined clean dropdown block with no custom creation button
          Row(
            children: [
              Expanded(
                child: _Dropdown<SubjectGroup>(
                  value: _selectedGroup,
                  items: widget.groups,
                  labelOf: (g) => g.name,
                  onChanged: isEditing
                      ? null
                      : (g) => setState(() => _selectedGroup = g),
                  hintText: 'No subjects loaded',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _Label('Task Title'),
          const SizedBox(height: 6),
          _Field(controller: _titleController, hint: 'e.g. Write introduction'),

          const SizedBox(height: 12),
          _Label('Estimated Hours'),
          const SizedBox(height: 6),
          _Field(
            controller: _hoursController,
            hint: 'e.g. 1.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text;
                if (text == '0' || text == '00') return oldValue;
                return newValue;
              }),
            ],
            errorText: _hoursError,
            onChanged: (_) {
              if (_hoursError != null) setState(() => _hoursError = null);
            },
          ),

          const SizedBox(height: 12),
          _Label('Due Date deadline'),
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
                        : DateFormat(
                            'yyyy-MM-dd (EEEE)',
                          ).format(_selectedDueDate!),
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedDueDate == null
                          ? Colors.white38
                          : AppColors.white,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          _Label('Status'),
          const SizedBox(height: 6),
          _Dropdown<TaskStatus>(
            value: _status,
            items: TaskStatus.values,
            labelOf: (s) => s.label,
            onChanged: (s) => setState(() => _status = s!),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'Save Changes' : 'Add Task',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?>? onChanged;
  final String hintText;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.hintText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hintText.isNotEmpty
              ? Text(
                  hintText,
                  style: const TextStyle(fontSize: 13, color: Colors.white38),
                )
              : null,
          dropdownColor: const Color(0xFF1E2330),
          iconEnabledColor: Colors.white54,
          iconDisabledColor: Colors.white24,
          onChanged: onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    labelOf(item),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
