import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // --- Static Interfaces Mapping to Widgets Callbacks ---
  static void onPrimaryAction(BuildContext context) {
    context.read<BurnoutAlertProvider>().dismiss();
    Navigator.of(context).pop(true);
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