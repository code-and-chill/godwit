import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool appBusy;

  bool get isAppBusy => appBusy;

  set loading(bool value) {
    appBusy = value;
    notifyListeners();
  }

  int _pageIndex = 0;

  int get pageIndex {
    return _pageIndex;
  }

  set setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}
