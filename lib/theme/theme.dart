import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  ThemeData getTheme() => _themeData;

  void setColor(Color color) {
    _themeData = ThemeData(
      primaryColor: color,
      appBarTheme: AppBarTheme(backgroundColor: color),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: color),
    );
    notifyListeners();
  }
}
