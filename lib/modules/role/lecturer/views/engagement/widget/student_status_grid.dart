import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/shared/styles/app_colors.dart';
import 'engagement_status_card.dart';

class StudentStatusGrid extends StatelessWidget {
  const StudentStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                child: StatusCard(
                  label: 'On Track',
                  count: '54',
                  sub: 'students',
                  icon: Icons.check_circle_outline,
                  color: AppColors.greenSheenDark,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatusCard(
                  label: 'Falling Behind',
                  count: '16',
                  sub: 'students',
                  icon: Icons.trending_down_rounded,
                  color: AppColors.mikadoYellow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                child: StatusCard(
                  label: 'Burnout Risk',
                  count: '2',
                  sub: 'students',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatusCard(
                  label: 'Inactive',
                  count: '4',
                  sub: 'no activity 3+ days',
                  icon: Icons.hourglass_empty_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}