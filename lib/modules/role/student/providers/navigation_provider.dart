import 'package:flutter/material.dart';
import '../models/semester_details_model.dart';

class NavigationProvider extends ChangeNotifier {
  int previousIndex = 0;

  int get previousPage => previousIndex;

  void setCurrentIndex(int index) {
    previousIndex = index;
    notifyListeners();
  }

  void selectSemester(BuildContext context, SemesterModel semester) {
    // Navigator.push(context, ...)
  }

  void navigateToAddNewSemester(BuildContext context) {
    // Navigator.push(context, ...)
  }
}