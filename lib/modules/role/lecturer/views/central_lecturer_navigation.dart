import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/student/bottom_nav.dart';
import '../../../../shared/widgets/student/student_header.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

class CentralLecturerNavigation extends StatefulWidget {
  const CentralLecturerNavigation({super.key});

  @override
  State<CentralLecturerNavigation> createState() =>
      CentralLecturerNavigationState();
}

class CentralLecturerNavigationState extends State<CentralLecturerNavigation> {
  int currentNavIndex = 0;

  final List<Widget> pages = const [
    PlaceholderPage(title: 'Lecturer Dashboard'),
    PlaceholderPage(title: 'My Classes'),
    PlaceholderPage(title: 'Assignments'),
    PlaceholderPage(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.californiaBlue,
      extendBody: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text('Header Placeholder'),
              ),
              Expanded(
                child: ClipRect(child: pages[currentNavIndex]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onTap: (i) => setState(() => currentNavIndex = i),
      ),
    );
  }
}