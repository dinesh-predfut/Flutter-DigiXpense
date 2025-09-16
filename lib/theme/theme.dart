import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  String? _themeColorKey;

  ThemeNotifier(this._themeData);

  ThemeData getTheme() => _themeData;
  String? getThemeColorKey() => _themeColorKey;

  // 🔹 Map light ↔ dark theme keys
  static final Map<String, String> themeKeyToggleMap = {
    'RED_THEME': 'DARK_RED_THEME',
    'GREEN_THEME': 'DARK_GREEN_THEME',
    'BLUE_THEME': 'DARK_BLUE_THEME',
    'ORANGE_THEME': 'DARK_ORANGE_THEME',
    'PURPLE_THEME': 'DARK_PURPLE_THEME',
    'INDIGO_THEME': 'DARK_INDIGO_THEME',
    'DARK_RED_THEME': 'RED_THEME',
    'DARK_GREEN_THEME': 'GREEN_THEME',
    'DARK_BLUE_THEME': 'BLUE_THEME',
    'DARK_ORANGE_THEME': 'ORANGE_THEME',
    'DARK_PURPLE_THEME': 'PURPLE_THEME',
    'DARK_INDIGO_THEME': 'INDIGO_THEME',
  };

  // 🔹 Color map
  static final Map<String, Color> themeColorMap = {
    'RED_THEME': Colors.red,
    'GREEN_THEME': Colors.green,
    'BLUE_THEME': Colors.blue,
    'ORANGE_THEME': Colors.orange,
    'PURPLE_THEME': Colors.purple,
    'INDIGO_THEME': Colors.indigo,
    'DARK_RED_THEME': Color(0xFFB71C1C),
    'DARK_GREEN_THEME': Color(0xFF1B5E20),
    'DARK_BLUE_THEME': Color(0xFF0D47A1),
    'DARK_ORANGE_THEME': Color(0xFFE65100),
    'DARK_PURPLE_THEME': Color(0xFF6A1B9A),
    'DARK_INDIGO_THEME': Color(0xFF1A237E),
  };

  /// ✅ Clear saved theme on logout
  Future<void> clearTheme() async {
    _themeColorKey = '';
    final prefs = await SharedPreferences.getInstance();
    final String themeKey = prefs.getString("ThemeColor") ?? "BLUE_THEME";

    // Get color from saved themeKey
    final Color themeColor = themeColorMap[themeKey] ?? Colors.blue;
    final bool isDark = themeKey.toUpperCase().startsWith('DARK_');

    // Apply the theme from local storage
    _themeColorKey = themeKey;
    _themeData =
        _buildTheme(themeColor, isDark ? Brightness.dark : Brightness.light);
    notifyListeners();

    print("🔄 Theme reapplied from local storage: $themeKey");
  }

  /// ✅ Build theme dynamically
  ThemeData _buildTheme(Color color, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: color, 
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      primaryColor: color,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        labelStyle: TextStyle(color: textColor),
        floatingLabelStyle: TextStyle(color: color),
      ),
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: textColor,
            displayColor: textColor,
          ),
    );
  }

  /// ✅ Set theme and save
  void setColor(Color color, {required String themeKey}) async {
    final bool isDark = themeKey.toUpperCase().startsWith('DARK_');
    _themeData =
        _buildTheme(color, isDark ? Brightness.dark : Brightness.light);

    _themeColorKey = themeKey;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("ThemeColor", themeKey);

    print("✅ Theme set: $themeKey | Mode: ${isDark ? 'Dark' : 'Light'}");
  }

  /// ✅ Toggle Dark/Light Mode
  void toggleDarkMode() async {
    if (_themeColorKey == null) return;

    final String? toggledKey = themeKeyToggleMap[_themeColorKey];
    if (toggledKey == null) return;

    final Color newColor = themeColorMap[toggledKey] ?? Colors.indigo;
    final bool isDark = toggledKey.toUpperCase().startsWith('DARK_');

    _themeData =
        _buildTheme(newColor, isDark ? Brightness.dark : Brightness.light);

    _themeColorKey = toggledKey;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("ThemeColor", toggledKey);

    print("🌓 Toggled to: $toggledKey | Mode: ${isDark ? 'Dark' : 'Light'}");
  }

  static Future<ThemeNotifier> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String themeKey = prefs.getString("ThemeColor") ?? "BLUE_THEME";

    final Color themeColor = themeColorMap[themeKey] ?? Colors.blue;
    final bool isDark = themeKey.toUpperCase().startsWith('DARK_');

    final themeData = ThemeNotifier._buildStaticTheme(
        themeColor, isDark ? Brightness.dark : Brightness.light);

    final notifier = ThemeNotifier(themeData);
    notifier._themeColorKey = themeKey;
    return notifier;
  }

  static ThemeData _buildStaticTheme(Color color, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: brightness,
      ),
      primaryColor: color,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
    );
  }
}
