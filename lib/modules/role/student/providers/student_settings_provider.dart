import '../../../../shared/services/api_service.dart';
import '../controllers/student_settings_controller.dart';
import '../models/student_settings_models.dart';

class StudentSettingsProvider {
  final StudentSettingsController controller;

  StudentSettingsProvider(this.controller);

  // remember to remove mock data
  void loadMock() {
    controller.setData(StudentSettingsModel.mockData());
  }

  Future<void> fetch() async {
    controller.setLoading(true);

    try {
      final json = await ApiService.get('/student/settings');
      final model = StudentSettingsModel.fromJson(json);
      controller.setData(model);
    } catch (e) {
      controller.setError(e.toString());
    }
  }
}