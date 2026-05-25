import 'package:flutter/material.dart';
import '../../../../shared/services/api_service.dart';
import '../models/burnout_alert_model.dart';

class BurnoutAlertProvider extends ChangeNotifier {
  BurnoutAlertModel? currentAlert;
  bool isDismissed = false;
  bool loading = false;
  String? error;

  bool get hasAlert => currentAlert != null && !isDismissed;

  void loadMock() {
    setAlert(BurnoutAlertModel.overloadPreset(hoursStudied: 7.0));
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await ApiService.get('/burnout_alert/getBurnoutData');
      setAlert(BurnoutAlertModel.fromJson(json));
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }

  void setAlert(BurnoutAlertModel alert) {
    currentAlert = alert;
    isDismissed = false;
    loading = false;
    error = null;
    notifyListeners();
  }

  void evaluateSession({required double hoursStudied}) {
    if (hoursStudied >= 6.0) {
      currentAlert = BurnoutAlertModel.overloadPreset(hoursStudied: hoursStudied);
    } else if (hoursStudied >= 5.0) {
      currentAlert = BurnoutAlertModel.burnoutPreset(hoursStudied: hoursStudied);
    } else if (hoursStudied >= 3.0) {
      currentAlert = BurnoutAlertModel.warningPreset(hoursStudied: hoursStudied);
    } else {
      currentAlert = BurnoutAlertModel.allGoodPreset(hoursStudied: hoursStudied);
    }
    isDismissed = false;
    loading = false;
    notifyListeners();
  }

  void dismiss() {
    isDismissed = true;
    notifyListeners();
  }

  void clear() {
    currentAlert = null;
    isDismissed = false;
    loading = false;
    error = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setError(String message) {
    error = message;
    loading = false;
    notifyListeners();
  }
}