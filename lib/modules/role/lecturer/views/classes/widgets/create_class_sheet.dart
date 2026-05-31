import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
  String? generatedJoinCode;
  bool isGenerating = false;
  bool isLoading    = false;
  String? _error;

  Color selectedColor = const Color(0xFF4CAF50);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _generateJoinCode() async {
    if (nameController.text.trim().isEmpty) {
      setState(() => _error = 'Enter a subject name first');
      return;
    }
    setState(() { isGenerating = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 900));

    final code = nameController.text
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    setState(() {
      generatedJoinCode = '$code–A1';
      isGenerating = false;
    });
  }

  void _submitData() async {
    if (nameController.text.isEmpty) {
      setState(() => _error = 'Subject name is required');
      return;
    }
    if (generatedJoinCode == null) {
      setState(() => _error = 'Please generate a join code first');
      return;
    }

    setState(() { isLoading = true; _error = null; });

    try {
      final derivedCode = nameController.text
          .trim()
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
          .join();

      final newClassData = ClassModel(
        id: FirebaseFirestore.instance.collection('classes').doc().id,
        lecturerId: FirebaseAuth.instance.currentUser?.uid ?? '',
        name: nameController.text.trim(),
        code: derivedCode,
        semester: '',
        joinCode: generatedJoinCode!,
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
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
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
                    const Text('Create Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Enter your subject name and generate a join code.', style: TextStyle(fontSize: 12, color: Colors.white54)),

                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ],
                const SizedBox(height: 20),

                Text('SUBJECT NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.legendText, letterSpacing: 0.8)),
                const SizedBox(height: 8),
                _buildTextField(controller: nameController, hint: 'e.g. CT124 System Proposal'),
                const SizedBox(height: 16),

                // Generate button or join code reveal
                if (generatedJoinCode == null)
                  GestureDetector(
                    onTap: isGenerating ? null : _generateJoinCode,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isGenerating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                            : const Text('Generate Join Code', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  )
                else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YOUR CLASS JOIN CODE', style: TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(generatedJoinCode!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.black, letterSpacing: 4)),
                        const SizedBox(height: 4),
                        const Text('Valid for the entire semester', style: TextStyle(fontSize: 11, color: AppColors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      'Students open their Unplug app, go to Join Class, and enter this code.',
                      style: TextStyle(fontSize: 12, color: AppColors.black, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: generatedJoinCode!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join code copied!')));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('Copy Join Code', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700, fontSize: 13))),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : GestureDetector(
                    onTap: _submitData,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.californiaBlue.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Create Class', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.white, width: 1.5)),
      ),
    );
  }
}