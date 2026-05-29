import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../../../role/lecturer/models/class_model.dart';
import '../../../../../role/lecturer/providers/classes_provider.dart';
import '../../../../../../shared/styles/app_colors.dart';

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
      setState(() => _error = 'Name and Code are required');
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
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2330),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Class',
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
              const SizedBox(height: 4),
              const Text(
                'Fill in the details below to create a new class.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),

              // Fields label
              Text(
                'CLASS DETAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.legendText,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              // Class Name
              _buildTextField(
                controller: nameController,
                hint: 'Class Name',
              ),
              const SizedBox(height: 10),

              // Class Code
              _buildTextField(
                controller: codeController,
                hint: 'Class Code',
              ),
              const SizedBox(height: 10),

              // Semester
              _buildTextField(
                controller: semesterController,
                hint: 'Semester (e.g. Semester 2)',
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
                    : GestureDetector(
                  onTap: _submitData,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.californiaBlue.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Create Class',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.white, fontSize: 14),
      cursorColor: AppColors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.white, width: 1.5),
        ),
      ),
    );
  }
}