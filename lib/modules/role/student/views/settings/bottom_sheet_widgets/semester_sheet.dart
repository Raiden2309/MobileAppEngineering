import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../controllers/student_settings_controller.dart';

/// Bottom sheet for managing semesters — select current, add new.
class SemesterSheet extends StatefulWidget {
  final StudentSettingsController controller;
  const SemesterSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, StudentSettingsController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SemesterSheet(controller: controller),
    );
  }

  @override
  State<SemesterSheet> createState() => _SemesterSheetState();
}

class _SemesterSheetState extends State<SemesterSheet> {
  late List<Map<String, String>> _semesters;
  bool _showAddForm = false;

  // Add form state
  int _semester = 1;
  int _year     = 1;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _semesters = List<Map<String, String>>.from(
      widget.controller.semesters.map((e) => Map<String, String>.from(e)),
    );
  }

  void _selectCurrent(int index) {
    setState(() {
      for (int i = 0; i < _semesters.length; i++) {
        _semesters[i] = Map<String, String>.from(_semesters[i])
          ..['isCurrent'] = (i == index).toString();
      }
    });
  }

  void _addSemester() {
    final name = 'Semester $_semester · Year $_year';
    setState(() {
      // Mark all existing as not current
      _semesters = _semesters.map((s) {
        return Map<String, String>.from(s)..['isCurrent'] = 'false';
      }).toList();
      _semesters.add({
        'name':      name,
        'isCurrent': 'true',
        'startDate': _startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : '',
        'endDate':   _endDate   != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'   : '',
      });
      _showAddForm = false;
    });
  }

  Future<void> _pickDate(bool isStart) async {
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
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  String _formatDate(DateTime? d) => d == null ? 'Pick date' : '${d.day}/${d.month}/${d.year}';

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
                const Text('Semester', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white)),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Semester list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _semesters.length,
                itemBuilder: (context, i) {
                  final s         = _semesters[i];
                  final isCurrent = s['isCurrent'] == 'true';
                  return GestureDetector(
                    onTap: () => _selectCurrent(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.black.withOpacity(0.6) : AppColors.black.withOpacity(0.3),
                        border: Border.all(color: isCurrent ? AppColors.white.withOpacity(0.2) : AppColors.white.withOpacity(0.07)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCurrent ? Icons.check_circle : Icons.calendar_month,
                            size: 20,
                            color: isCurrent ? AppColors.white : Colors.white38,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s['name'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                color: isCurrent ? AppColors.white : Colors.white60,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Current', style: TextStyle(fontSize: 11, color: AppColors.white)),
                            ),
                          const SizedBox(width: 8),
                          Radio<int>(
                            value: i,
                            groupValue: _semesters.indexWhere((s) => s['isCurrent'] == 'true'),
                            onChanged: (_) => _selectCurrent(i),
                            fillColor: WidgetStateProperty.all(AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add new semester
            if (!_showAddForm)
              GestureDetector(
                onTap: () => setState(() => _showAddForm = true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.3),
                    border: Border.all(color: AppColors.white.withOpacity(0.07)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white54, size: 20),
                      SizedBox(width: 12),
                      Text('Add New Semester', style: TextStyle(fontSize: 14, color: Colors.white54)),
                    ],
                  ),
                ),
              )
            else ...[
              // Inline add form
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _DropdownTile<int>(
                    label: 'Semester',
                    value: _semester,
                    items: List.generate(6, (i) => i + 1),
                    labelFn: (v) => 'Semester $v',
                    onChanged: (v) => setState(() => _semester = v!),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _DropdownTile<int>(
                    label: 'Year',
                    value: _year,
                    items: List.generate(4, (i) => i + 1),
                    labelFn: (v) => 'Year $v',
                    onChanged: (v) => setState(() => _year = v!),
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _DateTile(label: _formatDate(_startDate), hint: 'Start', onTap: () => _pickDate(true))),
                  const SizedBox(width: 10),
                  Expanded(child: _DateTile(label: _formatDate(_endDate),   hint: 'End',   onTap: () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => setState(() => _showAddForm = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _addSemester,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
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
                onPressed: () async {
                  await widget.controller.saveSemesters(_semesters);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelFn;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({required this.label, required this.value, required this.items, required this.labelFn, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.black,
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1E2330),
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            items: items.map((v) => DropdownMenuItem(value: v, child: Text(labelFn(v)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hint, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}