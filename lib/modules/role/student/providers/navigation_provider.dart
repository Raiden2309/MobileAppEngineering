import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int previousIndex = 0;

  int get previousPage => previousIndex;

  void setCurrentIndex(int index) {
    previousIndex = index;
    notifyListeners();
  }
}