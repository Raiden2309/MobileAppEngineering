import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_dashboard_provider.dart';
import 'widgets/lecturer_greeting.dart';
import 'widgets/lecturer_stat_grid.dart';
import 'widgets/alert_banner.dart';
import 'widgets/lecturer_classes_cards.dart';

class LecturerDashboard extends StatelessWidget {
  const LecturerDashboard({super.key}); // KEPT: Original signature untouched

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerDashboardProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LecturerGreeting(), // Restored original signatures
          const SizedBox(height: 16),
          const LecturerStatGrid(),
          const SizedBox(height: 16),
          if (provider.alerts.isNotEmpty) ...[
            const AlertBanner(),
            const SizedBox(height: 16),
          ],
          const Text(
            'Your Active Classes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const LecturerClassesCards(),
        ],
      ),
    );
  }
}