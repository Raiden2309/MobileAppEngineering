import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../providers/burnout_alert_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/semester_progress_provider.dart';
import '../../../providers/student_settings_provider.dart';
import '../../../providers/study_plan_provider.dart';
import '../../../providers/task_provider.dart';

class SubjectsSheet extends StatefulWidget {
  const SubjectsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubjectsSheet(),
    );
  }

  @override
  State<SubjectsSheet> createState() => _SubjectsSheetState();
}

class _SubjectsSheetState extends State<SubjectsSheet> {
  late List<Map<String, String>> _subjects;
  final _newSubjectController = TextEditingController();
  String? _error;

  final _colors = [
    '4F86C6',
    'F87171',
    '34D399',
    'FBBF24',
    'A78BFA',
    'F472B6',
    '60A5FA',
    'FB923C',
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _subjects = List<Map<String, String>>.from(
      context.read<StudentSettingsProvider>().subjects.map(
        (e) => Map<String, String>.from(e),
      ),
    );
  }

  @override
  void dispose() {
    _newSubjectController.dispose();
    super.dispose();
  }

  void _add() {
    final name = _newSubjectController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a subject name');
      return;
    }
    setState(() {
      _subjects.add({
        'name': name,
        'color_hex': _colors[_colorIndex % _colors.length],
      });
      _colorIndex++;
      _newSubjectController.clear();
      _error = null;
    });
  }

  void _remove(int i) => setState(() => _subjects.removeAt(i));

  Color _parseColor(String hex) => Color(int.parse('FF$hex', radix: 16));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                  'Subjects',
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
            const SizedBox(height: 16),
            if (_subjects.isNotEmpty) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subjects.length,
                  itemBuilder: (context, i) {
                    final s = _subjects[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.07),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _parseColor(s['color_hex'] ?? '4F86C6'),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _remove(i),
                            child: const Text(
                              '✕',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSubjectController,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                    cursorColor: AppColors.white,
                    decoration: InputDecoration(
                      hintText: 'Subject name…',
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                      errorText: _error,
                      errorStyle: const TextStyle(
                        color: AppColors.red,
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: AppColors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _add,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.07),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
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
                onPressed: () async {
                  final settings = context.read<StudentSettingsProvider>();
                  final tasks = context.read<TasksProvider>();
                  final studyPlan = context.read<StudyPlanProvider>();
                  final semester = context.read<SemesterProvider>();
                  final dashboard = context.read<StudentDashboardProvider>();
                  final burnout = context.read<BurnoutAlertProvider>();

                  await settings.saveSubjects(
                    _subjects,
                    tasks: tasks,
                    studyPlan: studyPlan,
                    semesterProgress: semester,
                    dashboard: dashboard,
                    burnout: burnout,
                  );

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
