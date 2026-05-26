import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/tasks_controller.dart';
import '../../../models/app_enums.dart';
import '../../../models/tasks_model.dart';

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
  bool _saving = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _hoursController = TextEditingController(
      text: widget.existing != null ? widget.existing!.estimatedHours.toString() : '',
    );
    _status = widget.existing?.status ?? TaskStatus.toDo;
    _selectedGroup = widget.groups.firstWhere(
          (g) => g.id == (widget.group?.id ?? widget.groups.first.id),
      orElse: () => widget.groups.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final hours = double.tryParse(_hoursController.text.trim()) ?? 0;
    if (title.isEmpty || _selectedGroup == null) return;
    setState(() => _saving = true);
    if (isEditing) {
      await widget.controller.updateTask(
        widget.existing!.copyWith(title: title, estimatedHours: hours, status: _status),
      );
    } else {
      await widget.controller.addTask(
        groupId: _selectedGroup!.id,
        title: title,
        estimatedHours: hours,
        status: _status,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    await widget.controller.deleteTask(widget.existing!);
    if (mounted) Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete Task?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this task? This cannot be undone.',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete();
            },
            child: Text('Delete', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
              Text(
                isEditing ? 'Edit Task' : 'Add Task',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
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
                          color: AppColors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.red),
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
            isEditing ? 'Update the details below.' : 'Fill in the details to add a new task.',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 20),
          _Label('Subject'),
          const SizedBox(height: 6),
          _Dropdown<SubjectGroup>(
            value: _selectedGroup,
            items: widget.groups,
            labelOf: (g) => g.name,
            onChanged: isEditing ? null : (g) => setState(() => _selectedGroup = g),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
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
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?>? onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
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
          dropdownColor: const Color(0xFF1E2330),
          iconEnabledColor: Colors.white54,
          iconDisabledColor: Colors.white24,
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              labelOf(item),
              style: const TextStyle(fontSize: 13, color: AppColors.white),
            ),
          )).toList(),
        ),
      ),
    );
  }
}