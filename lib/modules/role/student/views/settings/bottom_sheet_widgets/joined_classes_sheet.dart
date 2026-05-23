import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../controllers/student_settings_controller.dart';

class JoinedClassesSheet extends StatefulWidget {
  final StudentSettingsController controller;
  const JoinedClassesSheet({super.key, required this.controller});

  static Future<void> show(
      BuildContext context,
      StudentSettingsController controller,
      ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JoinedClassesSheet(controller: controller),
    );
  }

  @override
  State<JoinedClassesSheet> createState() => _JoinedClassesSheetState();
}

class _JoinedClassesSheetState extends State<JoinedClassesSheet> {
  final _codeController = TextEditingController();
  bool _joining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinClass() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _joining = true);
    await widget.controller.joinClass(code);
    _codeController.clear();
    setState(() => _joining = false);
  }

  Future<void> _leaveClass(String classId) async {
    await widget.controller.leaveClass(classId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final classes = widget.controller.joinedClasses;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2330),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
                    'Joined Classes',
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
                'Enter a class code to join, or manage your existing classes.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 16),

              // Join input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      style: const TextStyle(color: AppColors.white, fontSize: 14),
                      cursorColor: AppColors.white,
                      decoration: InputDecoration(
                        hintText: 'Enter class code',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _joining ? null : _joinClass,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.californiaBlue.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _joining
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                            : const Text(
                          'Join',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section label
              Text(
                'MY CLASSES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.legendText,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              // Class list
              Expanded(
                child: classes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 40,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No classes joined yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  controller: scrollController,
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.07),
                  ),
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.californiaBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppColors.glassIconBorderRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.class_rounded,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                      title: Text(
                        cls.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () => _confirmLeave(context, cls.id, cls.name),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            size: 14,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLeave(BuildContext context, String classId, String className) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Leave Class?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to leave "$className"?',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _leaveClass(classId);
            },
            child: Text(
              'Leave',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}