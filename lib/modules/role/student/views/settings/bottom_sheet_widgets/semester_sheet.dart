import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';
import '../../../controllers/student_settings_controller.dart';

class SemesterSheet extends StatefulWidget {
  final StudentSettingsController controller;
  const SemesterSheet({super.key, required this.controller});

  static Future<void> show(
      BuildContext context, StudentSettingsController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => SemesterSheet(controller: controller),
    );
  }

  @override
  State<SemesterSheet> createState() => _SemesterSheetState();
}

class _SemesterSheetState extends State<SemesterSheet> {
  late List<Map<String, dynamic>> _semesters;

  final _programmeController = TextEditingController();
  String? _programmeError;
  int _semester = 1;
  int _year = 1;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<DateTime?> _examDates = [null];

  @override
  void initState() {
    super.initState();
    _semesters = List<Map<String, dynamic>>.from(
      widget.controller.semesters.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  @override
  void dispose() {
    _programmeController.dispose();
    super.dispose();
  }

  String _fmt(DateTime? d) =>
      d == null ? 'Pick date' : '${d.day}/${d.month}/${d.year}';

  bool _validateForm() {
    if (_programmeController.text.trim().isEmpty) {
      setState(() => _programmeError = 'Please enter your programme');
      return false;
    }
    setState(() => _programmeError = null);
    return true;
  }

  Future<void> _pickDate(void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.californiaBlue,
            surface: Color(0xFF1A2540),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141927),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Semester',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _GlassLabel('Programme / Course'),
              const SizedBox(height: 6),
              _GlassInput(
                controller: _programmeController,
                placeholder: 'e.g. Diploma in Computer Science',
                errorText: _programmeError,
                onChanged: (_) {
                  if (_programmeError != null) {
                    setState(() => _programmeError = null);
                  }
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _GlassDropdown<int>(
                      label: 'Semester',
                      value: _semester,
                      items: List.generate(6, (i) => i + 1),
                      labelFn: (v) => 'Semester $v',
                      onChanged: (v) => setState(() => _semester = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassDropdown<int>(
                      label: 'Year',
                      value: _year,
                      items: List.generate(4, (i) => i + 1),
                      labelFn: (v) => 'Year $v',
                      onChanged: (v) => setState(() => _year = v!),
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
                        _GlassLabel('Start Date'),
                        const SizedBox(height: 6),
                        _GlassDateTile(
                          label: _fmt(_startDate),
                          hint: 'Start',
                          onTap: () => _pickDate((d) => _startDate = d),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GlassLabel('End Date'),
                        const SizedBox(height: 6),
                        _GlassDateTile(
                          label: _fmt(_endDate),
                          hint: 'End',
                          onTap: () => _pickDate((d) => _endDate = d),
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
                  _GlassLabel('Final Exam Dates (Optional)'),
                  GestureDetector(
                    onTap: () => setState(() => _examDates.add(null)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.californiaBlue,
                            AppColors.greenSheen
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: FontStyles.titleTiny,
                              color: Colors.white,
                              fontWeight: FontStyles.weightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          onTap: () =>
                              setState(() => _examDates.removeAt(i)),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.25)),
                            ),
                            child: const Icon(Icons.remove,
                                color: Colors.redAccent, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: _GlassDateTile(
                          label: _fmt(_examDates[i]),
                          hint: 'Exam ${i + 1}',
                          onTap: () => _pickDate((d) => _examDates[i] = d),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.californiaBlue, AppColors.greenSheen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (!_validateForm()) return;
                      final programme = _programmeController.text.trim();
                      for (final s in _semesters) {
                        s['isCurrent'] = false;
                      }
                      _semesters.add({
                        'name':
                        '$programme · Semester $_semester · Year $_year',
                        'programme': programme,
                        'semester': _semester,
                        'year': _year,
                        'isCurrent': true,
                        'startDate':
                        _startDate != null ? _fmt(_startDate) : '',
                        'endDate': _endDate != null ? _fmt(_endDate) : '',
                        'examDates': _examDates
                            .where((d) => d != null)
                            .map(_fmt)
                            .toList(),
                      });
                      final serialised = _semesters
                          .map((s) => s.map(
                            (k, v) => MapEntry(
                            k,
                            v is List
                                ? (v as List).join(',')
                                : v.toString()),
                      ))
                          .toList()
                          .cast<Map<String, String>>();
                      await widget.controller.saveSemesters(serialised);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontStyles.titleWeight,
                        fontSize: FontStyles.titleMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassLabel extends StatelessWidget {
  final String text;
  const _GlassLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontStyles.titleSmall,
        fontWeight: FontStyles.weightMedium,
        color: Colors.white60,
      ),
    );
  }
}

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _GlassInput({
    required this.controller,
    required this.placeholder,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(AppColors.glassOpacity),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent
                  : Colors.white.withOpacity(AppColors.glassBorderOpacity),
            ),
            borderRadius:
            BorderRadius.circular(AppColors.glassTileBorderRadius),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              hintText: placeholder,
              hintStyle:
              const TextStyle(color: Colors.white38, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 11, color: Colors.redAccent),
          ),
        ],
      ],
    );
  }
}

class _GlassDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelFn;
  final ValueChanged<T?> onChanged;

  const _GlassDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelFn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GlassLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(AppColors.glassOpacity),
            border: Border.all(
              color: Colors.white.withOpacity(AppColors.glassBorderOpacity),
            ),
            borderRadius:
            BorderRadius.circular(AppColors.glassTileBorderRadius),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1A2540),
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white54),
            items: items
                .map((v) =>
                DropdownMenuItem(value: v, child: Text(labelFn(v))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _GlassDateTile extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _GlassDateTile({
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPicked = label != 'Pick date';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(AppColors.glassOpacity),
          border: Border.all(
            color: isPicked
                ? AppColors.californiaBlue.withOpacity(0.4)
                : Colors.white.withOpacity(AppColors.glassBorderOpacity),
          ),
          borderRadius:
          BorderRadius.circular(AppColors.glassTileBorderRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: FontStyles.titleTiny,
                      color: Colors.white54,
                      fontWeight: FontStyles.weightMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPicked ? AppColors.white : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isPicked ? AppColors.californiaBlue : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}