// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeNotifier with ChangeNotifier {
//   ThemeData _themeData;
//   String? _themeColorKey;

//   ThemeNotifier(this._themeData);

//   ThemeData getTheme() => _themeData;
//   String? getThemeColorKey() => _themeColorKey;

//   // 🔹 Map light ↔ dark theme keys
//   static final Map<String, String> themeKeyToggleMap = {
//     'RED_THEME': 'DARK_RED_THEME',
//     'GREEN_THEME': 'DARK_GREEN_THEME',
//     'BLUE_THEME': 'DARK_BLUE_THEME',
//     'ORANGE_THEME': 'DARK_ORANGE_THEME',
//     'PURPLE_THEME': 'DARK_PURPLE_THEME',
//     'INDIGO_THEME': 'DARK_INDIGO_THEME',
//     'DARK_RED_THEME': 'RED_THEME',
//     'DARK_GREEN_THEME': 'GREEN_THEME',
//     'DARK_BLUE_THEME': 'BLUE_THEME',
//     'DARK_ORANGE_THEME': 'ORANGE_THEME',
//     'DARK_PURPLE_THEME': 'PURPLE_THEME',
//     'DARK_INDIGO_THEME': 'INDIGO_THEME',
//   };

//   // 🔹 Color map
//   static final Map<String, Color> themeColorMap = {
//     'RED_THEME': Colors.pinkAccent,
//     'GREEN_THEME': Colors.green,
//     'BLUE_THEME': Colors.blue,
//     'ORANGE_THEME': Colors.orange,
//     'PURPLE_THEME': Colors.purple,
//     'INDIGO_THEME': Colors.indigo,
//     'DARK_RED_THEME':  const Color.fromARGB(255, 250, 60, 155),
//     'DARK_GREEN_THEME': Color(0xFF1B5E20),
//     'DARK_BLUE_THEME': Color(0xFF0D47A1),
//     'DARK_ORANGE_THEME': Color(0xFFE65100),
//     'DARK_PURPLE_THEME': Color(0xFF6A1B9A),
//     'DARK_INDIGO_THEME': Color(0xFF1A237E),
//   };

//   /// ✅ Clear saved theme on logout
//   Future<void> clearTheme() async {
//     _themeColorKey = '';
//     final prefs = await SharedPreferences.getInstance();
//     final String themeKey = prefs.getString("ThemeColor") ?? "BLUE_THEME";

//     // Get color from saved themeKey
//     final Color themeColor = themeColorMap[themeKey] ?? Colors.blue;
//     final bool isDark = themeKey.toUpperCase().startsWith('DARK_');

//     // Apply the theme from local storage
//     _themeColorKey = themeKey;
//     _themeData =
//         _buildTheme(themeColor, isDark ? Brightness.dark : Brightness.light);
//     notifyListeners();

//     print("🔄 Theme reapplied from local storage: $themeKey");
//   }

//   /// ✅ Build theme dynamically
//   ThemeData _buildTheme(Color color, Brightness brightness) {
//     final bool isDark = brightness == Brightness.dark;
//     final Color textColor = isDark ? Colors.white : Colors.black87;

//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: color,
//         brightness: brightness,
//       ),
//       appBarTheme: AppBarTheme(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         elevation: 4,
//         centerTitle: true,
//         titleTextStyle: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//       primaryColor: color,
//       scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: textColor),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: color, width: 2),
//         ),
//         labelStyle: TextStyle(color: textColor),
//         floatingLabelStyle: TextStyle(color: color),
//       ),
//       textTheme: ThemeData.light().textTheme.apply(
//             bodyColor: textColor,
//             displayColor: textColor,
//           ),
//     );
//   }

//   /// ✅ Set theme and save
//   void setColor(Color color, {required String themeKey}) async {
//     final bool isDark = themeKey.toUpperCase().startsWith('DARK_');
//     _themeData =
//         _buildTheme(color, isDark ? Brightness.dark : Brightness.light);

//     _themeColorKey = themeKey;
//     notifyListeners();

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("ThemeColor", themeKey);

//     print("✅ Theme set: $themeKey | Mode: ${isDark ? 'Dark' : 'Light'}");
//   }

//   /// ✅ Toggle Dark/Light Mode
//   void toggleDarkMode() async {
//     if (_themeColorKey == null) return;

//     final String? toggledKey = themeKeyToggleMap[_themeColorKey];
//     if (toggledKey == null) return;

//     final Color newColor = themeColorMap[toggledKey] ?? Colors.indigo;
//     final bool isDark = toggledKey.toUpperCase().startsWith('DARK_');

//     _themeData =
//         _buildTheme(newColor, isDark ? Brightness.dark : Brightness.light);

//     _themeColorKey = toggledKey;
//     notifyListeners();

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("ThemeColor", toggledKey);

//     print("🌓 Toggled to: $toggledKey | Mode: ${isDark ? 'Dark' : 'Light'}");
//   }

//   static Future<ThemeNotifier> loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String themeKey = prefs.getString("ThemeColor") ?? "BLUE_THEME";

//     final Color themeColor = themeColorMap[themeKey] ?? Colors.blue;
//     final bool isDark = themeKey.toUpperCase().startsWith('DARK_');

//     final themeData = ThemeNotifier._buildStaticTheme(
//         themeColor, isDark ? Brightness.dark : Brightness.light);

//     final notifier = ThemeNotifier(themeData);
//     notifier._themeColorKey = themeKey;
//     return notifier;
//   }

//   static ThemeData _buildStaticTheme(Color color, Brightness brightness) {
//     final bool isDark = brightness == Brightness.dark;
//     final Color textColor = isDark ? Colors.white : Colors.black87;

//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: color,
//         brightness: brightness,
//       ),
//       primaryColor: color,
//       scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 💡 Theme model equivalent to your JS ThemeType
class AppTheme {
  final String name;
  final bool dark;
  final Map<String, Color> colors;

  AppTheme({required this.name, required this.dark, required this.colors});
}

/// 🔹 Define all your light themes
final AppTheme blueTheme = AppTheme(
  name: 'BLUE_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFF1e4db7),
    'secondary': const Color(0xFF1a97f5),
    'background': const Color(0xFFF6F6F6),
    'textPrimary': const Color(0xFF2A3547),
    'textSecondary': const Color(0xFF2A3547),
    'containerBg': Colors.white,
  },
);

final AppTheme redTheme = AppTheme(
  name: 'RED_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFF5e244d),
    'secondary': const Color(0xFFFF5C8E),
    'background': const Color(0xFFF6F6F6),
    'textPrimary': const Color(0xFF2A3547),
    'textSecondary': const Color(0xFF2A3547),
    'containerBg': Colors.white,
  },
);

final AppTheme greenTheme = AppTheme(
  name: 'GREEN_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFF066a73),
    'secondary': const Color(0xFF00cec3),
    'background': const Color(0xFFF6F6F6),
    'textPrimary': const Color(0xFF2A3547),
    'textSecondary': const Color(0xFF2A3547),
    'containerBg': Colors.white,
  },
);

final AppTheme orangeTheme = AppTheme(
  name: 'ORANGE_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFFfb9678),
    'secondary': const Color(0xFF03c9d7),
    'background': const Color(0xFFF6F6F6),
    'textPrimary': const Color(0xFF2A3547),
    'textSecondary': const Color(0xFF2A3547),
    'containerBg': Colors.white,
  },
);

final AppTheme purpleTheme = AppTheme(
  name: 'PURPLE_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFF402e8d),
    'secondary': const Color(0xFF7352ff),
    'background': const Color(0xFFF6F6F6),
    'textPrimary': const Color(0xFF2A3547),
    'textSecondary': const Color(0xFF2A3547),
    'containerBg': Colors.white,
  },
);

final AppTheme indigoTheme = AppTheme(
  name: 'INDIGO_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFF11397b),
    'secondary': const Color(0xFF1e4db7),
    'background': const Color(0xFFF6F6F6),
    'textPrimary': const Color(0xFF2A3547),
    'textSecondary': const Color(0xFF2A3547),
    'containerBg': Colors.white,
  },
);

final AppTheme darkBlueTheme = AppTheme(
  name: 'DARK_BLUE_THEME',
  dark: false,
  colors: {
    'primary': const Color(0xFF1e4db7),
    'secondary': const Color(0xFF1a97f5),
    'background': const Color(0xFF2a3447),
    'textPrimary': const Color(0xFFEAEFF4),
    'textSecondary': const Color(0xFF7C8FAC),
    'containerBg': const Color(0xFF171c23),
  },
);

final AppTheme darkRedTheme = AppTheme(
  name: 'DARK_RED_THEME',
  dark: true,
  colors: {
    'primary': const Color(0xFF5e244d),
    'secondary': const Color(0xFFFF5C8E),
    'background': const Color(0xFF171c23),
    'textPrimary': const Color(0xFFEAEFF4),
    'textSecondary': const Color(0xFF7C8FAC),
    'containerBg': const Color(0xFF171c23),
  },
);

final AppTheme darkGreenTheme = AppTheme(
  name: 'DARK_GREEN_THEME',
  dark: true,
  colors: {
    'primary': const Color(0xFF066a73),
    'secondary': const Color(0xFF00cec3),
    'background': const Color(0xFF171c23),
    'textPrimary': const Color(0xFFEAEFF4),
    'textSecondary': const Color(0xFF7C8FAC),
    'containerBg': const Color(0xFF171c23),
  },
);

final AppTheme darkOrangeTheme = AppTheme(
  name: 'DARK_ORANGE_THEME',
  dark: true,
  colors: {
    'primary': const Color(0xFFfb9678),
    'secondary': const Color(0xFF03c9d7),
    'background': const Color(0xFF171c23),
    'textPrimary': const Color(0xFFEAEFF4),
    'textSecondary': const Color(0xFF7C8FAC),
    'containerBg': const Color(0xFF171c23),
  },
);

final AppTheme darkPurpleTheme = AppTheme(
  name: 'DARK_PURPLE_THEME',
  dark: true,
  colors: {
    'primary': const Color(0xFF402e8d),
    'secondary': const Color(0xFF7352ff),
    'background': const Color(0xFF171c23),
    'textPrimary': const Color(0xFFEAEFF4),
    'textSecondary': const Color(0xFF7C8FAC),
    'containerBg': const Color(0xFF171c23),
  },
);

final AppTheme darkIndigoTheme = AppTheme(
  name: 'DARK_INDIGO_THEME',
  dark: true,
  colors: {
    'primary': const Color(0xFF11397b),
    'secondary': const Color(0xFF1e4db7),
    'background': const Color(0xFF171c23),
    'textPrimary': const Color(0xFFEAEFF4),
    'textSecondary': const Color(0xFF7C8FAC),
    'containerBg': const Color(0xFF171c23),
  },
);

final Map<String, AppTheme> themeMap = {
  'BLUE_THEME': blueTheme,
  'RED_THEME': redTheme,
  'GREEN_THEME': greenTheme,
  'ORANGE_THEME': orangeTheme,
  'PURPLE_THEME': purpleTheme,
  'INDIGO_THEME': indigoTheme,
  'DARK_BLUE_THEME': darkBlueTheme,
  'DARK_RED_THEME': darkRedTheme,
  'DARK_GREEN_THEME': darkGreenTheme,
  'DARK_ORANGE_THEME': darkOrangeTheme,
  'DARK_PURPLE_THEME': darkPurpleTheme,
  'DARK_INDIGO_THEME': darkIndigoTheme,
};

final Map<String, String> themeToggleMap = {
  'BLUE_THEME': 'DARK_BLUE_THEME',
  'RED_THEME': 'DARK_RED_THEME',
  'GREEN_THEME': 'DARK_GREEN_THEME',
  'ORANGE_THEME': 'DARK_ORANGE_THEME',
  'PURPLE_THEME': 'DARK_PURPLE_THEME',
  'INDIGO_THEME': 'DARK_INDIGO_THEME',
  'DARK_BLUE_THEME': 'BLUE_THEME',
  'DARK_RED_THEME': 'RED_THEME',
  'DARK_GREEN_THEME': 'GREEN_THEME',
  'DARK_ORANGE_THEME': 'ORANGE_THEME',
  'DARK_PURPLE_THEME': 'PURPLE_THEME',
  'DARK_INDIGO_THEME': 'INDIGO_THEME',
};

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  String? _themeKey;

  ThemeNotifier(this._themeData, [this._themeKey]);

  ThemeData get theme => _themeData;
  String? get themeKey => _themeKey;

  static Map<String, Color> get themeColorMap => Map.fromEntries(
    themeMap.entries.map((e) => MapEntry(e.key, e.value.colors['primary']!)),
  );

  static Future<ThemeNotifier> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = prefs.getString('ThemeColor') ?? 'BLUE_THEME';
    final AppTheme appTheme = themeMap[key] ?? blueTheme;
    return ThemeNotifier(_buildTheme(appTheme), appTheme.name);
  }

  Future<void> setTheme(String key) async {
    final AppTheme appTheme = themeMap[key] ?? blueTheme;
    _themeData = _buildTheme(appTheme);
    _themeKey = appTheme.name;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ThemeColor', _themeKey!);
  }

  Future<void> setColor(Color color, {required String themeKey}) async {
    await setTheme(themeKey);
  }

  Future<void> toggleDarkMode() async {
    if (_themeKey == null) return;
    final toggledKey = themeToggleMap[_themeKey];
    if (toggledKey == null) return;
    await setTheme(toggledKey);
  }

  Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ThemeColor');
    await setTheme('BLUE_THEME');
  }

  static ThemeData _buildTheme(AppTheme theme) {
    final primary = theme.colors['primary']!;
    final secondary = theme.colors['secondary']!;
    final background = theme.colors['background']!;
    final textPrimary = theme.colors['textPrimary']!;
    final textSecondary = theme.colors['textSecondary']!;
    final containerBg = theme.colors['containerBg']!;

    final isDark = theme.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        // brightness: isDark ? Brightness.dark : Brightness.light,
        brightness: Brightness.light,

        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        background: background,
        onBackground: textPrimary,
        surface: containerBg,
        onSurface: textSecondary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        floatingLabelStyle: TextStyle(color: primary),
      ),
      
      // textTheme: TextTheme(
      //   bodyLarge: TextStyle(color: isDark ? Colors.white : Colors.black),
      //   bodyMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
      //   bodySmall: TextStyle(color: isDark ? Colors.white : Colors.black),
      //   titleMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
      //   titleSmall: TextStyle(color: isDark ? Colors.white : Colors.black),
      // ),
    );
  }
}
