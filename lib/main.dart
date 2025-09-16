import 'dart:convert';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constant/Parames/params.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale;
  Locale get locale => _locale;

  // Default constructor (lazy-loads)
  LocaleNotifier() : _locale = const Locale('en') {
    _loadLocale();
  }

  // <-- Named constructor you tried to call
  LocaleNotifier.initial(this._locale);

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langId = prefs.getString('LanguageID') ?? 'LUG-01';
    final code = getLocaleCodeFromId(langId);
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('LanguageID', getIdFromLocale(locale));
  }

  String getIdFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'LUG-02';
      case 'zh':
        return 'LUG-03';
      case 'fr':
        return 'LUG-04';
      case 'en':
      default:
        return 'LUG-01';
    }
  }
}

// top-level helper used above
String getLocaleCodeFromId(String id) {
  switch (id) {
    case 'LUG-02':
      return 'ar';
    case 'LUG-03':
      return 'zh';
    case 'LUG-04':
      return 'fr';
    case 'LUG-01':
    default:
      return 'en';
  }
}


final Map<String, Color> themeColorMap = {
  "RED_THEME": Colors.red,
  "GREEN_THEME": Colors.green,
  "BLUE_THEME": Colors.blue,
  "ORANGE_THEME": Colors.orange,
  "PURPLE_THEME": Colors.purple,
  "INDIGO_THEME": Colors.indigo,
  "DARK_RED_THEME": const Color(0xFFB71C1C),
  "DARK_GREEN_THEME": const Color(0xFF1B5E20),
  "DARK_BLUE_THEME": const Color(0xFF0D47A1),
  "DARK_INDIGO_THEME": const Color(0xFF1A237E),
  "DARK_PURPLE_THEME": const Color(0xFF6A1B9A),
  "DARK_ORANGE_THEME": const Color(0xFFE65100),
};

/// ✅ Token check & decide initial route
Future<String> getInitialRoute(String? refreshToken) async {
  print("refreshToken: $refreshToken");

  if (refreshToken == null || refreshToken.isEmpty || refreshToken == "null") {
    print("❌ No refresh token, go to login");
    return AppRoutes.entryScreen; // Login/entry page
  }

  try {
    final response = await http.post(
      Uri.parse("https://api.digixpense.com/api/v1/tenant/auth/refresh_token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer ${refreshToken ?? ''}'
      },
      // body: jsonEncode({"refresh_token": refreshToken}),
    );

    print("Response code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("@data$data");
      if (data["access_token"] != null) {
        // ✅ Token valid → Save it & go to Dashboard
        Params.userToken = data["access_token"];
        print("✅ Token refreshed successfully");
        return AppRoutes.dashboard_Main;
      }
    }

    // ❌ Token invalid
    return AppRoutes.signin;
  } catch (e) {
    print("Error refreshing token: $e");
    return AppRoutes.signin;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final themeKey = prefs.getString("ThemeColor");

  final langId = prefs.getString("LanguageID") ?? "LUG-01";
  final code = getLocaleCodeFromId(langId);

  // create notifier with initial locale
  final localeNotifier = LocaleNotifier.initial(Locale(code));
  // Load refreshToken
  await SetSharedPref().getData();

  if (Params.refreshtoken != null && Params.refreshtoken != "null") {
    print("✅ Retrieved refreshToken: ${Params.refreshtoken}");
  } else {
    print("❌ No refreshToken found");
  }

  // 🔹 Define theme color map
  final Map<String, Color> themeColorMap = {
    'RED_THEME': Colors.red,
    'BLUE_THEME': Colors.blue,
    'GREEN_THEME': Colors.green,
    'ORANGE_THEME': Colors.orange,
    'PURPLE_THEME': Colors.purple,
    'INDIGO_THEME': Colors.indigo,
    'DARK_RED_THEME': const Color(0xFFB71C1C),
    'DARK_BLUE_THEME': const Color(0xFF0D47A1),
    'DARK_GREEN_THEME': const Color(0xFF1B5E20),
    'DARK_PURPLE_THEME': const Color(0xFF6A1B9A),
    'DARK_ORANGE_THEME': const Color(0xFFE65100),
    'DARK_INDIGO_THEME': const Color(0xFF1A237E),
  };

  // 🔹 Determine initial color
  final Color initialColor =
      themeKey != null && themeColorMap.containsKey(themeKey)
          ? themeColorMap[themeKey]!
          : const Color(0xFF1A237E);

  // 🔹 Create ThemeNotifier with correct theme
  final themeNotifier = ThemeNotifier(
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: initialColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue, // Will be updated in setColor
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      scaffoldBackgroundColor: Colors.grey[50]!,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: initialColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: initialColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: initialColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: initialColor, width: 2),
        ),
        labelStyle: TextStyle(color: initialColor),
        floatingLabelStyle: TextStyle(color: initialColor),
      ),
    ),
  );

  // 🔹 Apply theme (this updates _themeColorKey and calls notifyListeners)
  if (themeKey != null) {
    themeNotifier.setColor(initialColor, themeKey: themeKey);
    print("✅ Applied saved theme: $themeKey");
  }

  // 🔹 Get initial route
  final String initialRoute = await getInitialRoute(Params.refreshtoken);
  print("➡️ initialRoute: $initialRoute");

  // 🔹 Run App with pre-loaded providers
  runApp(
    MultiProvider(
      providers: [
        // ✅ Use .value() to pass pre-initialized ThemeNotifier
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),

        // ✅ Locale Notifier
        ChangeNotifierProvider<LocaleNotifier>(
          create: (_) => LocaleNotifier(),
        ),

        // ✅ Report Model
        ChangeNotifierProvider<ReportModel>(
          create: (_) => ReportModel(),
        ),

        // ✅ Add other providers as needed
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      title: 'My Flutter App',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: themeNotifier.getTheme(),
      locale: localeNotifier.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
        Locale('zh'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
