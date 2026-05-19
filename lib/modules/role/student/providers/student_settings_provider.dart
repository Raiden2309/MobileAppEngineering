import '../controllers/student_settings_controller.dart';
import '../models/student_settings_models.dart';

class StudentSettingsProvider {
  final StudentSettingsController controller;

  StudentSettingsProvider(this.controller);

  void loadMock() {
    controller.setData(StudentSettingsModel.mockData());
  }

  Future<void> fetch() async {
    await controller.load();
  }
}