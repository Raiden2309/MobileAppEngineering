import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/role/lecturer/views/classes/widgets/class_card.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../../../../shared/styles/font_styles.dart';

class LecturerClassesSection extends StatelessWidget {
  const LecturerClassesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Classes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontStyles.weightHeavy,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 4),
              Text(
                'Semester 4 · 3 active classes',
                style: TextStyle(
                  fontSize: FontStyles.titleSmall,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              children: const [
                ClassCard(
                  name: 'CT124 System Proposal',
                  code: 'CT124 · Diploma in Computer Science',
                  students: '28',
                  avgDone: '62%',
                  atRisk: '1',
                  atRiskColor: AppColors.red,
                  accentColor: AppColors.californiaBlue,
                  semester: 'Sem 4 · Mar – Jul 2026',
                ),
                SizedBox(height: 12),
                ClassCard(
                  name: 'Research Methods',
                  code: 'RM302 · Diploma in Computer Science',
                  students: '24',
                  avgDone: '54%',
                  atRisk: '1',
                  atRiskColor: AppColors.red,
                  accentColor: AppColors.mikadoYellow,
                  semester: 'Sem 4 · Mar – Jul 2026',
                ),
                SizedBox(height: 12),
                ClassCard(
                  name: 'Mobile Development',
                  code: 'MOB401 · Diploma in Computer Science',
                  students: '20',
                  avgDone: '59%',
                  atRisk: '0',
                  atRiskColor: AppColors.greenSheen,
                  accentColor: AppColors.softPurple,
                  semester: 'Sem 4 · Mar – Jul 2026',
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
