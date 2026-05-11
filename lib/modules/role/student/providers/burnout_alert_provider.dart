import '../../../../shared/services/api_service.dart';
import '../controllers/burnout_alert_controller.dart';
import '../models/burnout_alert_model.dart';

class BurnoutAlertProvider {
  final BurnoutAlertController controller;

  BurnoutAlertProvider(this.controller);

  void loadMock() {
    // controller.setAlert(BurnoutAlertModel.warningPreset(hoursStudied: 3.5));
    // controller.setAlert(BurnoutAlertModel.burnoutPreset(hoursStudied: 5.5));
    controller.setAlert(BurnoutAlertModel.overloadPreset(hoursStudied: 7.0));
    // controller.setAlert(BurnoutAlertModel.allGoodPreset(hoursStudied: 1.5));
  }

  Future<void> fetch() async {
    controller.setLoading(true);

    try {
      final json = await ApiService.get('/burnout_alert/getBurnoutData');
      final model = BurnoutAlertModel.fromJson(json);
      controller.setAlert(model);
    } catch (e) {
      controller.setError(e.toString());
    }
  }
}