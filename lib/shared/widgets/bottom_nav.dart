import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.californiaBlue,
        border: Border(top: BorderSide(color: AppColors.white, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: NavItem(index: 0, currentIndex: currentIndex, icon: Icons.grid_view_rounded, label: 'Dashboard', onTap: onTap)),
              Expanded(child: NavItem(index: 1, currentIndex: currentIndex, icon: Icons.check,              label: 'My Tasks',  onTap: onTap)),
              Expanded(child: NavItem(index: 2, currentIndex: currentIndex, icon: Icons.menu_book_outlined, label: 'Study Plan', onTap: onTap)),
              Expanded(child: NavItem(index: 3, currentIndex: currentIndex, icon: Icons.bar_chart_rounded,  label: 'Progress',  onTap: onTap)),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.black : AppColors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.black : AppColors.white,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.black : AppColors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}