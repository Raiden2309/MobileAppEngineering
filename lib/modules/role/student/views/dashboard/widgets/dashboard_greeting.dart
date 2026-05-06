import 'package:flutter/material.dart';
import '../../../controllers/dashboard/student_dashboard_controller.dart';

class DashboardGreeting extends StatelessWidget {
  final StudentDashboardController controller;
  const DashboardGreeting({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Text(
            'Good Morning, ${controller.userName}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5, height: 1.5),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            'You have ${controller.amountOfTasks} tasks scheduled for today',
            style: const TextStyle(fontSize: 15, color: Colors.black, letterSpacing: 0.5, height: 1.5),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(32)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(controller.getFormattedDate(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}