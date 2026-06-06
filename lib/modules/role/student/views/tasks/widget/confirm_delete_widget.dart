import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';

class ConfirmDeleteWidget extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmDeleteWidget({super.key, required this.onConfirm});


  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConfirmDeleteWidget(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2330),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Delete Task?',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          const Text(
            'Are you sure you want to delete this task? This cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Text('Delete', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}