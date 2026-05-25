import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/burnout_alert_provider.dart';

class BurnoutAlertController {
  static void evaluateSession(BuildContext context, {required double hoursStudied}) {
    context.read<BurnoutAlertProvider>().evaluateSession(hoursStudied: hoursStudied);
  }

  static void dismiss(BuildContext context) {
    context.read<BurnoutAlertProvider>().dismiss();
  }

  static void onPrimaryAction(BuildContext context) {
    context.read<BurnoutAlertProvider>().dismiss();
    Navigator.of(context).pop(true);
  }

  static void onDismiss(BuildContext context) {
    context.read<BurnoutAlertProvider>().dismiss();
    Navigator.of(context).pop(false);
  }

  static void clear(BuildContext context) {
    context.read<BurnoutAlertProvider>().clear();
  }
}