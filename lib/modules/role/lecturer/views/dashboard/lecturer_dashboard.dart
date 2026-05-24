import 'package:flutter/material.dart';
import 'widgets/lecturer_greeting.dart';
import 'widgets/alert_banner.dart';
import 'widgets/lecturer_stat_grid.dart';
import 'widgets/lecturer_classes_cards.dart';

class LecturerDashboard extends StatelessWidget {
  final VoidCallback? onNavigateToClasses;
  const LecturerDashboard({super.key, this.onNavigateToClasses});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LecturerGreeting(),
          const SizedBox(height: 16),
          const AlertBanner(),
          const SizedBox(height: 16),
          const LecturerStatGrid(),
          const SizedBox(height: 16),
          LecturerClassesCards(onSeeAll: onNavigateToClasses),
        ],
      ),
    );
  }
}