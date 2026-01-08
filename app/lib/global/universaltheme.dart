import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  double _fontsize = 12.0;

  double get fontSize => _fontsize;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontsize = prefs.getDouble('fontSize') ?? 12.0;
    notifyListeners();
  }
  
  Future<void> updateFontSize(double newSize) async {
    _fontsize = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', newSize);
    notifyListeners();
  }

  // We can use them for font and some of them be usable for icon sizing.
  ThemeData get themeData => ThemeData(
    textTheme: GoogleFonts.latoTextTheme(
      TextTheme(
        headlineLarge: TextStyle(fontSize: _fontsize * 2.67, fontWeight: FontWeight.w600), // 32
        headlineMedium: TextStyle(fontSize: _fontsize * 2.33, fontWeight: FontWeight.w600), // 28
        headlineSmall: TextStyle(fontSize: _fontsize * 1.67, fontWeight: FontWeight.w600), // 20
        displayLarge: TextStyle(fontSize: _fontsize * 1.33, fontWeight: FontWeight.w600), // 16
        displayMedium: TextStyle(fontSize: _fontsize * 1.167, fontWeight: FontWeight.w600), // 14
        displaySmall: TextStyle(fontSize: _fontsize * 1.0, fontWeight: FontWeight.w600), // 12
      )
    ),
  );

}