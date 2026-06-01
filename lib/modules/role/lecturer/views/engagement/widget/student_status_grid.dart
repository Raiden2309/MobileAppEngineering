import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/engagement_provider.dart'; // FIXED: Pointing correctly to your provider file
import 'engagement_status_card.dart'; // Imports StatusCard cleanly

class StudentStatusGrid extends StatelessWidget {
  const StudentStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngagementProvider>();
    final counts = provider.workloadCounts;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: StatusCard(
              label: 'At Risk',
              count: (counts['High'] ?? 0).toString(),
              sub: 'High workload level detected',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatusCard(
              label: 'Needs Review',
              count: (counts['Medium'] ?? 0).toString(),
              sub: 'Moderate levels tracked',
              icon: Icons.assignment_late_rounded,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatusCard(
              label: 'Stable Status',
              count: (counts['Low'] ?? 0).toString(),
              sub: 'Healthy progression profile',
              icon: Icons.check_circle_outline_rounded,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}