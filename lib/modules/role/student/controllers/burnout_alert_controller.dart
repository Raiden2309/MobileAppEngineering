import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_enums.dart';
import '../models/burnout_alert_model.dart';
import '../providers/burnout_alert_provider.dart';

class BurnoutAlertController extends ChangeNotifier {
  final BuildContext? context;

  BurnoutAlertController([this.context]);

  BurnoutAlertModel? get data => context?.read<BurnoutAlertProvider>().alert;
  bool get loading => context?.read<BurnoutAlertProvider>().loading ?? false;
  String? get error => context?.read<BurnoutAlertProvider>().error;

  void init() {
    context?.read<BurnoutAlertProvider>().listenToLiveBurnoutMetrics();
  }

  static void onPrimaryAction(BuildContext context) {
    final alert = context.read<BurnoutAlertProvider>().alert;
    context.read<BurnoutAlertProvider>().dismiss();
    Navigator.of(context).pop(true);

    if (alert == null) return;
    switch (alert.type) {
      case BurnoutAlertType.overload:
      case BurnoutAlertType.burnout:
      case BurnoutAlertType.warning:
        Navigator.of(context).pushNamed('/schedule');
        break;
      case BurnoutAlertType.allGood:
        Navigator.of(context).pushNamed('/dashboard');
        break;
    }
  }

  static void onDismiss(BuildContext context) {
    context.read<BurnoutAlertProvider>().dismiss();
    Navigator.of(context).pop(false);
  }

  static void evaluateSession(BuildContext context, {required double hoursStudied}) {
    context.read<BurnoutAlertProvider>().evaluateSession(hoursStudied: hoursStudied);
  }

  static void dismiss(BuildContext context) {
    context.read<BurnoutAlertProvider>().dismiss();
  }

  static void clear(BuildContext context) {
    context.read<BurnoutAlertProvider>().clear();
  }
}