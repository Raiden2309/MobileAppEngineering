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
  final TextEditingController _codeController = TextEditingController();

  bool _isSearching = false;
  bool _isJoining   = false;

  Map<String, dynamic>? _foundClass;
  bool _searched = false;
  bool _notFound = false;

  static const List<Color> _palette = [
    Color(0xFF4F86C6), Color(0xFF6C63FF), Color(0xFF2ECC71),
    Color(0xFFE67E22), Color(0xFFE74C3C), Color(0xFF1ABC9C),
    Color(0xFF9B59B6), Color(0xFFF39C12),
  ];

  Color _colorForIndex(int i) => _palette[i % _palette.length];

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _searchClass() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isSearching = true;
      _foundClass  = null;
      _searched    = false;
      _notFound    = false;
    });

    final provider = context.read<StudentSettingsProvider>();
    try {
      final snap = await provider.lookupClassByCode(code);
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searched    = true;
        if (snap != null) {
          _foundClass = snap;
          _notFound   = false;
        } else {
          _notFound = true;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _isSearching = false; _notFound = true; _searched = true; });
    }
  }

  Future<void> _confirmJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);
    final success = await context.read<StudentSettingsProvider>().joinClass(code);
    if (!mounted) return;
    setState(() => _isJoining = false);

    if (success) {
      _codeController.clear();
      setState(() { _foundClass = null; _searched = false; _notFound = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the class!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not join. You may already be enrolled.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // KEY FIX: Stream from Firestore enrollments (lecturer-created classes)
    // instead of reading from StudentSettingsProvider's local joinedClasses list.
    final provider = context.read<StudentSettingsProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: provider.streamJoinedClasses(),
      builder: (context, snapshot) {
        final classes = snapshot.data ?? [];

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * (classes.isEmpty ? 0.55 : 0.75),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),

                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Classes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 2),
                          Text('Enter your lecturer\'s class code to join.', style: TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                    if (classes.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.californiaBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.californiaBlue.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${classes.length} enrolled',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.californiaBlue),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Code input + search
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
                          controller: _codeController,
                          style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1.5),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (_) => _searchClass(),
                          onChanged: (_) {
                            if (_searched) setState(() { _foundClass = null; _searched = false; _notFound = false; });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter class code (e.g. 012345)',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isSearching ? null : _searchClass,
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.californiaBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _isSearching
                            ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),

                // Search result preview
                if (_searched) ...[
                  const SizedBox(height: 14),
                  if (_notFound)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 10),
                          Text('No class found with that code.', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ],
                      ),
                    )
                  else if (_foundClass != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.californiaBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.californiaBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.californiaBlue.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.californiaBlue.withOpacity(0.4)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(_foundClass!['name'] ?? '?'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.californiaBlue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _foundClass!['name'] ?? 'Unknown Class',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _foundClass!['subjectCode'] ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _isJoining ? null : _confirmJoin,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.californiaBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isJoining
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Join', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                // Enrolled list — now sourced from Firestore enrollments
                if (classes.isEmpty) ...[
                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined, color: Colors.white24, size: 40),
                        const SizedBox(height: 10),
                        const Text('No classes joined yet.', style: TextStyle(color: Colors.white38, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Spacer(),
                ] else ...[
                  const SizedBox(height: 20),
                  const Text('ENROLLED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: classes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        // Each item is a Map<String, dynamic> from Firestore
                        final cls = classes[index];
                        final String className = cls['name'] ?? 'Unknown Class';
                        final String subjectCode = cls['subjectCode'] ?? '';
                        final color = _colorForIndex(index);

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.07)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: color.withOpacity(0.4)),
                                ),
                                alignment: Alignment.center,
                                child: Text(_initials(className), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      className,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (subjectCode.isNotEmpty)
                                      Text(
                                        subjectCode,
                                        style: const TextStyle(fontSize: 11, color: Colors.white38),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                child: Text('Enrolled', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                const Center(child: Text('Ask your lecturer for the class code.', style: TextStyle(color: Colors.white24, fontSize: 12))),
              ],
            ),
          ),
        );
      },
    );
  }
}