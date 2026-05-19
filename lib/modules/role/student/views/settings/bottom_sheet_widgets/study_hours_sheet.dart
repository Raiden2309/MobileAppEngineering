import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../controllers/student_settings_controller.dart';

/// Bottom sheet for editing study hours (start + end time).
/// Opens only when tapped — disposed immediately on close.
class StudyHoursSheet extends StatefulWidget {
  final StudentSettingsController controller;
  const StudyHoursSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, StudentSettingsController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudyHoursSheet(controller: controller),
    );
  }

  @override
  State<StudyHoursSheet> createState() => _StudyHoursSheetState();
}

class _StudyHoursSheetState extends State<StudyHoursSheet> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    _start = widget.controller.studyStart;
    _end   = widget.controller.studyEnd;
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Study Hours',
      onSave: () async {
        await widget.controller.saveStudyHours(_start, _end);
        if (context.mounted) Navigator.pop(context);
      },
      child: Row(
        children: [
          Expanded(child: _TimeBlock(label: 'Day Starts', time: _start, onTap: () => _pickTime(true))),
          const SizedBox(width: 12),
          Expanded(child: _TimeBlock(label: 'Day Ends',   time: _end,   onTap: () => _pickTime(false))),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeBlock({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(time.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black)),
          ],
        ),
      ),
    );
  }
}

// ── Shared sheet scaffold (used by all 4 sheets) ─────────────────────────────
class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;

  const _SheetScaffold({required this.title, required this.child, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2330),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white)),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
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
              onPressed: onSave,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}