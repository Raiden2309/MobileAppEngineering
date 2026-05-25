import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/burnout_alert_provider.dart';
import 'widgets/alert_empty.dart';
import 'widgets/alert_sheet_content.dart';

class BurnoutAlertBottomSheet extends StatelessWidget {
  const BurnoutAlertBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BurnoutAlertProvider>();
    final alert = provider.currentAlert;

    if (alert == null) return const AlertEmptyState();

    return AlertSheetContent(alert: alert);
  }
}