import '../controllers/lecturer_settings_controller.dart';
import '../models/lecturer_settings_model.dart';

class LecturerSettingsProvider {
  final LecturerSettingsController controller;

  LecturerSettingsProvider(this.controller);

  void loadMock() {
    controller.setData(LecturerSettingsModel.mockData());
  }

  Future<void> fetch() async {
    await controller.load();
  }
}