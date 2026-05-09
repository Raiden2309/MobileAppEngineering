import 'package:flutter/material.dart';

class LecturerSetupController extends ChangeNotifier {
  final nameController = TextEditingController();
  final subjectNameController = TextEditingController();

  String? generatedJoinCode;
  bool generating = false;

  final Map<String, String?> errors = {};
  String? getError(String key) => errors[key];

  bool validate(String value, String errorKey, {
    int minLength = 2,
    String? emptyMessage,
    String? shortMessage,
  }) {
    if (value.trim().isEmpty) {
      errors[errorKey] = emptyMessage ?? 'This field is required';
      notifyListeners();
      return false;
    }
    if (value.trim().length < minLength) {
      errors[errorKey] = shortMessage ?? 'Must be at least $minLength characters';
      notifyListeners();
      return false;
    }
    errors[errorKey] = null;
    notifyListeners();
    return true;
  }

  bool validateAll() {
    final nameValid = validate(nameController.text, 'name', emptyMessage: 'Please enter your name');
    final subjectValid = validate(subjectNameController.text, 'subjectName', emptyMessage: 'Please enter a subject name');
    return nameValid && subjectValid;
  }

  void setGenerating(bool value) {
    generating = value;
    notifyListeners();
  }

  void setJoinCode(String code) {
    generatedJoinCode = code;
    generating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    subjectNameController.dispose();
    super.dispose();
  }
}