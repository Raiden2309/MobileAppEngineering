import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/burnout_alert_controller.dart';
import '../../providers/burnout_alert_provider.dart';
import '../../../../../../shared/styles/app_colors.dart'; // Correct relative alignment level
import 'widgets/alert_empty.dart';
import 'widgets/alert_sheet_content.dart';

class BurnoutAlertBottomSheet extends StatefulWidget {
  const BurnoutAlertBottomSheet({super.key});

  @override
  State<BurnoutAlertBottomSheet> createState() => _BurnoutAlertBottomSheetState();
}

class _BurnoutAlertBottomSheetState extends State<BurnoutAlertBottomSheet> {
  late final BurnoutAlertController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BurnoutAlertController(context);
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BurnoutAlertProvider>();
    final alert = provider.alert;

    if (provider.loading && alert == null) {
      return const SizedBox(
        height: 350,
        child: Center(
          // FIXED: Removed invalid const wrapper to prevent compiler exceptions
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.californiaBlue),
          ),
        ),
      );
    }

    if (alert == null) {
      return const AlertEmptyState();
    }

    return AlertSheetContent(alert: alert);
  }
}