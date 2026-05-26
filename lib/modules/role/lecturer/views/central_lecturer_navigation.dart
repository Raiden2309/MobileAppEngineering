import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/alerts/lecturer_alerts.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/lecturer/lecturer_header.dart';
import '../providers/lecturer_settings_provider.dart';
import 'classes/lecturer_classes.dart';
import 'dashboard/lecturer_dashboard.dart';
import 'engagement/engagement.dart';

class CentralLecturerNavigation extends StatefulWidget {
  const CentralLecturerNavigation({super.key});

  @override
  State<CentralLecturerNavigation> createState() =>
      CentralLecturerNavigationState();
}

class CentralLecturerNavigationState
    extends State<CentralLecturerNavigation> {
  int currentNavIndex = 0;
  bool hasUnreadAlerts = true;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      LecturerDashboard(onNavigateToClasses: () => goToTab(1)),
      const LecturerClassesSection(),
      const LecturerEngagementPage(),
      const LecturerAlertsPage(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LecturerSettingsProvider>().loadMock();
    });
  }

  void goToTab(int index) {
    if (index == currentNavIndex) return;
    setState(() {
      currentNavIndex = index;
      if (index == 3) hasUnreadAlerts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: LecturerHeader(
                  hasUnreadAlerts: hasUnreadAlerts,
                  onAlertsTapped: () => goToTab(3),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 68),
                  child: IndexedStack(
                    index: currentNavIndex,
                    children: pages,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onTap: goToTab,
        role: 2,
      ),
    );
  }
}