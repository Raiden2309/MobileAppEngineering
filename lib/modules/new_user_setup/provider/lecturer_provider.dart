import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';
import '../models/lecturer_model.dart';

class LecturerProvider extends ChangeNotifier {
  LecturerModel? lecturer;
  bool loading = false;
  String? error;

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await ApiService.get('/lecturer/profile');
      lecturer = LecturerModel.fromJson(data);
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save(LecturerModel model) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await ApiService.post('/lecturer/profile', model.toJson());
      lecturer = model;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<String> generateJoinCode(String subjectName) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('/lecturer/generate-code', {'subjectName': subjectName});
      loading = false;
      notifyListeners();
      return data['joinCode'];
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return '';
    }
  }

  void setLecturer(LecturerModel model) {
    lecturer = model;
    notifyListeners();
  }

  void clear() {
    lecturer = null;
    error = null;
    notifyListeners();
  }
}