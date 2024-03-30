import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  bool _isDark = false; // true = dark mode, false = light mode [KEEP FALSE BY DEFAULT]

  bool get isDark => _isDark;

  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }
}
