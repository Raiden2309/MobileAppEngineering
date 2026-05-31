import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class SubjectsSheet extends StatefulWidget {
  const SubjectsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubjectsSheet(),
    );
  }

  @override
  State<SubjectsSheet> createState() => _SubjectsSheetState();
}

class _SubjectsSheetState extends State<SubjectsSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isSaving = false;

  Future<void> _handleSaveSubject() async {
    final String subjectName = _nameController.text.trim();
    final String subjectCode = _codeController.text.trim().toUpperCase();
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (subjectName.isEmpty || subjectCode.isEmpty || uid.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Create clean document tracking hash strings matching layout serialization engines
      final String safeDocId = '${uid}_${subjectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').replaceAll(RegExp(r'[\s-]'), '_')}';

      await FirebaseFirestore.instance.collection('enrollments').doc(safeDocId).set({
        'studentId': uid,
        'classId': subjectName,
        'subjectCode': subjectCode,
        'colorHex': '#3DA5D9', // Assign a standard default template styling color
        'completedTasks': 0,
        'pendingTasks': 0,
        'burnoutIndex': 0.0,
        'tasksList': [], // Seed with an empty array ready to accept new task records
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Failed to save subject collection row entry: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B), // Premium dark theme matching modal assets
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Subject Track',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Subject Name (e.g. Mathematics)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.25),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _codeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Course Code (e.g. AMOD102)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.25),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _handleSaveSubject,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Subject', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}