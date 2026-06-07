import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../providers/student_settings_provider.dart';

class SemesterSheet extends StatefulWidget {
  final Map<String, String>? existing;

  const SemesterSheet({super.key, this.existing});

  static Future<void> show(BuildContext context, {Map<String, String>? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SemesterSheet(existing: existing),
    );
  }

  @override
  State<SemesterSheet> createState() => _SemesterSheetState();
}

class _SemesterSheetState extends State<SemesterSheet> {
  late final TextEditingController _semNumController;
  late final TextEditingController _yearNumController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    debugPrint('SemesterSheet existing: ${widget.existing}');
    final existingSem = widget.existing?['semesterNum']?.trim() ?? '';
    final existingYear = widget.existing?['yearNum']?.trim() ?? '';

    String resolvedSem = existingSem;
    String resolvedYear = existingYear;
    if ((resolvedSem.isEmpty || resolvedYear.isEmpty) && widget.existing?['name'] != null) {
      final name = widget.existing!['name']!;
      final semMatch = RegExp(r'Semester\s+(\d+)').firstMatch(name);
      final yearMatch = RegExp(r'Year\s+(\d+)', caseSensitive: false).firstMatch(name);
      if (resolvedSem.isEmpty && semMatch != null) resolvedSem = semMatch.group(1)!;
      if (resolvedYear.isEmpty && yearMatch != null) resolvedYear = yearMatch.group(1)!;
    }

    _semNumController = TextEditingController(text: resolvedSem);
    _yearNumController = TextEditingController(text: resolvedYear);

    // Parse existing dates if editing
    if (widget.existing?['start'] != null) {
      _startDate = _tryParseDate(widget.existing!['start']!);
    }
    if (widget.existing?['end'] != null) {
      _endDate = _tryParseDate(widget.existing!['end']!);
    }
  }

  DateTime? _tryParseDate(String s) {
    try {
      // Handle both 'dd MMM yyyy' and ISO formats
      final parts = s.split(' ');
      if (parts.length == 3) {
        const months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
          'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
          'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
        };
        return DateTime(
          int.parse(parts[2]),
          months[parts[1]] ?? 1,
          int.parse(parts[0]),
        );
      }
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 120)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.californiaBlue,
            onPrimary: Colors.white,
            surface: Color(0xFF1E2330),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF1E2330),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Clear end date if it's before new start
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final semNum  = _semNumController.text.trim();
    final yearNum = _yearNumController.text.trim();

    if (semNum.isEmpty || yearNum.isEmpty || _startDate == null || _endDate == null) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      setState(() => _error = 'End date must be after start date');
      return;
    }

    final provider = context.read<StudentSettingsProvider>();
    final auto = 'Semester $semNum · Year $yearNum';
    final updated = {
      'name':            auto,
      'semesterNum':     semNum,
      'yearNum':         yearNum,
      'start':           _formatDate(_startDate!),
      'end':             _formatDate(_endDate!),
      'studyHoursStart': '',
      'studyHoursEnd':   '',
      'subjectCount':    '0',
      'isCurrent':       'false',
    };

    if (_isEditing) {
      await provider.editSemester(widget.existing!['name']!, updated);
    } else {
      await provider.saveSemesters([...provider.semesters, updated]);
    }

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        title: const Text('Delete Semester', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${widget.existing!['name']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<StudentSettingsProvider>().deleteSemester(widget.existing!['name']!);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _semNumController.dispose();
    _yearNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E2330),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Semester' : 'New Semester',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
                Row(
                  children: [
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: _delete,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    label: 'Semester',
                    value: List.generate(6, (i) => '${i + 1}').contains(_semNumController.text)
                        ? _semNumController.text
                        : null,
                    items: List.generate(6, (i) => '${i + 1}'),
                    displayLabel: (v) => 'Semester $v',
                    onChanged: (v) => setState(() => _semNumController.text = v ?? ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField(
                    label: 'Year',
                    value: List.generate(4, (i) => '${i + 1}').contains(_yearNumController.text)
                        ? _yearNumController.text
                        : null,
                    items: List.generate(4, (i) => '${i + 1}'),
                    displayLabel: (v) => 'Year $v',
                    onChanged: (v) => setState(() => _yearNumController.text = v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Start Date picker
            _DatePickerField(
              label: 'Start Date',
              value: _startDate != null ? _formatDate(_startDate!) : null,
              hint: 'Select start date',
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(height: 12),

            // End Date picker
            _DatePickerField(
              label: 'End Date',
              value: _endDate != null ? _formatDate(_endDate!) : null,
              hint: 'Select end date',
              onTap: () => _pickDate(isStart: false),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
            ],
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
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Save Changes' : 'Add Semester',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? displayLabel;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text('Select', style: TextStyle(color: Colors.white38, fontSize: 13)),
              isExpanded: true,
              dropdownColor: const Color(0xFF1E2330),
              iconEnabledColor: Colors.white38,
              style: const TextStyle(color: AppColors.white, fontSize: 13),
              items: items.map((v) => DropdownMenuItem(value: v, child: Text(displayLabel != null ? displayLabel!(v) : v))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value != null ? AppColors.white : Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white38),
              ],
            ),
          ),
        ),
      ],
    );
  }
}