import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../providers/classes_provider.dart';

class CreateClassSheet extends StatefulWidget {
  const CreateClassSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ClassesProvider>(),
        child: const CreateClassSheet(),
      ),
    );
  }

  @override
  State<CreateClassSheet> createState() => _CreateClassSheetState();
}

class _CreateClassSheetState extends State<CreateClassSheet> {
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  String? _generatedCode;
  bool _generating = false;
  String? _error;

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    final name = _subjectNameController.text.trim();
    final code = _subjectCodeController.text.trim();
    if (name.isEmpty || code.isEmpty) {
      setState(() => _error = 'Please fill in subject name and code first');
      return;
    }
    setState(() {
      _generating = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    final prefix = code.toUpperCase().replaceAll(' ', '');
    setState(() {
      _generatedCode = '$prefix–A1';
      _generating = false;
    });
  }

  Future<void> _save() async {
    if (_generatedCode == null) {
      setState(() => _error = 'Please generate a join code first');
      return;
    }
    await context.read<ClassesProvider>().addClass(
      name: _subjectNameController.text.trim(),
      code: _subjectCodeController.text.trim(),
      joinCode: _generatedCode!,
    );
    if (context.mounted) Navigator.pop(context);
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
                  'New Class',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
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
              'Fill in the details and generate a join code for your students.',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 20),
            _Label('Subject Name'),
            const SizedBox(height: 6),
            _InputField(
              controller: _subjectNameController,
              hint: 'e.g. CT124 System Proposal',
              onChanged: (_) => setState(() => _generatedCode = null),
            ),
            const SizedBox(height: 12),
            _Label('Subject Code'),
            const SizedBox(height: 6),
            _InputField(
              controller: _subjectCodeController,
              hint: 'e.g. CT124',
              onChanged: (_) => setState(() => _generatedCode = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            if (_generatedCode == null)
              _GenerateButton(generating: _generating, onTap: _generateCode)
            else
              _JoinCodeReveal(joinCode: _generatedCode!),
            const SizedBox(height: 20),
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
                child: const Text('Create Class', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _InputField({required this.controller, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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

class _GenerateButton extends StatelessWidget {
  final bool generating;
  final VoidCallback onTap;

  const _GenerateButton({required this.generating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: generating ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: generating
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
          )
              : const Text(
            'Generate Join Code',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _JoinCodeReveal extends StatelessWidget {
  final String joinCode;
  const _JoinCodeReveal({required this.joinCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JOIN CODE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white54, letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  joinCode,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.white, letterSpacing: 4),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Valid for the entire semester',
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: joinCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Join code copied!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.californiaBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📋 Copy',
                style: TextStyle(fontSize: 12, color: AppColors.californiaBlue, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}