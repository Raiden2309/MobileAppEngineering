import 'package:flutter/material.dart';
import '../models/semester_progress_model.dart';
import '../../../../shared/services/api_service.dart';

class SemesterProvider with ChangeNotifier {
  SemesterProgressModel? data;
  bool loading = false;
  String? error;

  void loadMock() {
    data = SemesterProgressModel.mockData();
    notifyListeners();
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final json = await ApiService.get('/semester_progress');
      data = SemesterProgressModel.fromJson(json);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}