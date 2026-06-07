import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_colors.dart';
import '../../../../../shared/widgets/setup_widgets.dart';
import '../../../controllers/student_setup_controller.dart';


class StudentSchedule extends StatefulWidget {
  final SetupController controller;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StudentSchedule({super.key, required this.controller, required this.onNext, required this.onBack});

  @override
  State<StudentSchedule> createState() => StudentScheduleState();
}

class StudentScheduleState extends State<StudentSchedule> {
  final days = ['MON', 'TUE', 'WED', 'THU', 'FRI'];

  List<String> _buildHours() {
    final start = widget.controller.dayStart.hour;
    final end = widget.controller.dayEnd.hour;
    final List<String> result = [];
    for (int h = start; h < end; h++) {
      if (h == 0) result.add('12am');
      else if (h < 12) result.add('${h}am');
      else if (h == 12) result.add('12pm');
      else result.add('${h - 12}pm');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final hours = _buildHours();
    final startHour = widget.controller.dayStart.hour;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final hours = _buildHours();

        return SetupScaffold(
          step: 1,
          title: 'Block Off Your Time',
          subtitle: "Tap the slots you're unavailable — classes, commitments, or personal time.",
          onNext: widget.onNext,
          onBack: widget.onBack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupLabel('Mon – Fri · Tap to block'),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 36),
                  ...days.map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: const TextStyle(fontSize: 9, color: AppColors.dayLabel, fontWeight: FontWeight.w600)),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 4),
              ...List.generate(hours.length, (hIdx) {
                final actualHour = startHour + hIdx; // absolute hour for key
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(hours[hIdx], style: const TextStyle(fontSize: 9, color: AppColors.dayLabel), textAlign: TextAlign.right),
                      ),
                      ...List.generate(days.length, (dIdx) {
                        final key = '${dIdx}_$actualHour';
                        final blocked = widget.controller.blockedSlots.contains(key);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => widget.controller.toggleSlot(key),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 24,
                              decoration: BoxDecoration(
                                color: blocked ? AppColors.blockedBg : AppColors.availableBg,
                                border: Border.all(
                                  color: blocked ? AppColors.blockedBorder : AppColors.white.withOpacity(0.07),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: blocked ? const Center(child: Text('🔒', style: TextStyle(fontSize: 8))) : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0x1FF87171), border: Border.all(color: const Color(0x4DF87171)), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Blocked', style: TextStyle(fontSize: 11, color: AppColors.legendText)),
                  const SizedBox(width: 16),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF1E2330), border: Border.all(color: AppColors.white), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Available', style: TextStyle(fontSize: 11, color: AppColors.legendText)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}