import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';

class CurrentTaskPopup extends StatelessWidget {
  const CurrentTaskPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Task Reminder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('No tasks yet.', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}