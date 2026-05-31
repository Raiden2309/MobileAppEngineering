import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../student/providers/student_settings_provider.dart';

class JoinedClassesSheet extends StatefulWidget {
  const JoinedClassesSheet({super.key});

  static void show(BuildContext context) {
    final provider = context.read<StudentSettingsProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const JoinedClassesSheet(),
      ),
    );
  }

  @override
  State<JoinedClassesSheet> createState() => _JoinedClassesSheetState();
}

class _JoinedClassesSheetState extends State<JoinedClassesSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _joinClass() async {
    final code = _searchController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    final provider = context.read<StudentSettingsProvider>();
    final success = await provider.joinClass(code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the class!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No class found with that code. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Join a Class',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter the class code provided by your lecturer.',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // Search row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _joinClass(),
                      decoration: const InputDecoration(
                        hintText: 'Enter class code…',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _joinClass,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.californiaBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isLoading
                        ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Bottom hint
            const Center(
              child: Text(
                'Ask your lecturer for the class code.',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}