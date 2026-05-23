import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/dashboard/widgets/lecturer_classes_cards.dart';
import 'widgets/lecturer_greeting.dart';
import 'widgets/alert_banner.dart';
import 'widgets/lecturer_stat_grid.dart';

class LecturerDashboard extends StatefulWidget {
  final VoidCallback? onNavigateToClasses;
  const LecturerDashboard({super.key, this.onNavigateToClasses});

  @override
  State<LecturerDashboard> createState() => LecturerDashboardState();
}

class LecturerDashboardState extends State<LecturerDashboard> {
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
          LecturerClassesCards(onSeeAll: widget.onNavigateToClasses),
        ],
      ),
    );
  }
}
