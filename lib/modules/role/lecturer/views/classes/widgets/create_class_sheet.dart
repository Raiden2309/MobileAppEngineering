import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../role/lecturer/models/class_model.dart';
import '../../../../../role/lecturer/providers/classes_provider.dart';

class CreateClassSheet extends StatefulWidget {
  const CreateClassSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateClassSheet(),
    );
  }

  @override
  State<CreateClassSheet> createState() => _CreateClassSheetState();
}

class _CreateClassSheetState extends State<CreateClassSheet> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final semesterController = TextEditingController();
  Color selectedColor = const Color(0xFF4CAF50);
  bool isLoading = false;
  String? _error;

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    semesterController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (nameController.text.isEmpty || codeController.text.isEmpty) {
      setState(() => _error = "Name and Code are required");
      return;
    }

    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      final newClassData = ClassModel(
        id: FirebaseFirestore.instance.collection('classes').doc().id,
        lecturerId: FirebaseAuth.instance.currentUser?.uid ?? '',
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        semester: semesterController.text.trim(),
        accentColor: selectedColor,
      );

      await context.read<ClassesProvider>().addClass(newClassData);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Fallback hex color if AppColors is missing
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Create Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Class Name', labelStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.black),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: codeController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Class Code', labelStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.black),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: semesterController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Semester', labelStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.black),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Create Class'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}