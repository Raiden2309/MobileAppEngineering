import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mae_assignment/shared/styles/app_colors.dart';

import '../../styles/font_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static Widget item(IconData icon, String label, bool isActive) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          if (!isActive) ...[
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontSize: FontStyles.titleTiny,
                fontWeight: FontStyles.weightMedium,
              ),
            ),
          ],
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      onTap: onTap,
      height: 65,
      color: AppColors.summerCampBlue,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: AppColors.summerCampBlueLight,
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeInOut,
      items: [
        item(Icons.grid_view_rounded,  'Dashboard', currentIndex == 0),
        item(Icons.check_rounded,      'My Tasks',  currentIndex == 1),
        item(Icons.menu_book_outlined, 'Study Plan',currentIndex == 2),
        item(Icons.bar_chart_rounded,  'Progress',  currentIndex == 3),
      ],
    );
  }
}