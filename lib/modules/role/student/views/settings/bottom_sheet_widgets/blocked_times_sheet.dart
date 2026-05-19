import 'package:flutter/material.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../controllers/student_settings_controller.dart';

class BlockedTimesSheet extends StatefulWidget {
  final StudentSettingsController controller;
  const BlockedTimesSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, StudentSettingsController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlockedTimesSheet(controller: controller),
    );
  }

  @override
  State<BlockedTimesSheet> createState() => _BlockedTimesSheetState();
}

class _BlockedTimesSheetState extends State<BlockedTimesSheet> {
  late Set<String> _slots;

  final _days  = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
  final _hours = ['8am','9am','10am','11am','12pm','1pm','2pm','3pm','4pm','5pm','6pm','7pm','8pm','9pm'];

  @override
  void initState() {
    super.initState();
    _slots = Set<String>.from(widget.controller.blockedSlots);
  }

  void _toggle(String key) => setState(() {
    _slots.contains(key) ? _slots.remove(key) : _slots.add(key);
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2330),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Blocked Times', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Tap slots you're unavailable — classes, breaks, personal time.",
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              // Day headers
              Row(
                children: [
                  const SizedBox(width: 36),
                  ..._days.map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: const TextStyle(fontSize: 9, color: AppColors.dayLabel, fontWeight: FontWeight.w600)),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 4),
              // Grid — scrollable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: List.generate(_hours.length, (hIdx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(_hours[hIdx], style: const TextStyle(fontSize: 9, color: AppColors.dayLabel), textAlign: TextAlign.right),
                            ),
                            ...List.generate(_days.length, (dIdx) {
                              final key     = '${dIdx}_$hIdx';
                              final blocked = _slots.contains(key);
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _toggle(key),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    height: 26,
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
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Legend
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0x1FF87171), border: Border.all(color: const Color(0x4DF87171)), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Blocked', style: TextStyle(fontSize: 11, color: AppColors.legendText)),
                  const SizedBox(width: 16),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(0xFF1E2330), border: Border.all(color: AppColors.white), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Available', style: TextStyle(fontSize: 11, color: AppColors.legendText)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await widget.controller.saveBlockedSlots(_slots);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}