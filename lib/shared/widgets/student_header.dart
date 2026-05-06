import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset('assets/images/transparent_logo.png', width: 32),
            const SizedBox(width: 8),
            const Text(
              'Unplug',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.black),
            ),
          ],
        ),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.white,
              child: Image.asset('assets/images/burnout_fire.png', width: 24),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.white,
              child: Image.asset('assets/images/person.png', width: 24),
            ),
          ],
        ),
      ],
    );
  }
}