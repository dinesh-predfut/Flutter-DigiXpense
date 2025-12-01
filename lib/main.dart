import 'dart:convert';
import 'package:digi_xpense/data/pages/screen/screenLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// Local imports
import 'firebase_options.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';

/// Locale Notifier
class LocaleNotifier extends ChangeNotifier {
  Locale _locale;
  Locale get locale => _locale;

  LocaleNotifier() : _locale = const Locale('en') {
    _loadLocale();
  }

  LocaleNotifier.initial(this._locale);

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langId = prefs.getString('LanguageID') ?? 'LUG-01';
    _locale = Locale(getLocaleCodeFromId(langId));
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

/// Theme Colors Map
final Map<String, Color> themeColorMap = {
  "RED_THEME": Colors.pinkAccent,
  "GREEN_THEME": Colors.green,
  "BLUE_THEME": Colors.blue,
  "ORANGE_THEME": Colors.orange,
  "PURPLE_THEME": Colors.purple,
  "INDIGO_THEME": Colors.indigo,
  "DARK_RED_THEME": const Color.fromARGB(255, 250, 60, 155),
  "DARK_GREEN_THEME": const Color(0xFF1B5E20),
  "DARK_BLUE_THEME": const Color(0xFF0D47A1),
  "DARK_INDIGO_THEME": const Color(0xFF1A237E),
  "DARK_PURPLE_THEME": const Color(0xFF6A1B9A),
  "DARK_ORANGE_THEME": const Color(0xFFE65100),
};

class AppInitializer {
  static Future<AppInitData> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase (non-blocking)
    final firebaseFuture = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Load SharedPreferences and other data in parallel
    final prefs = await SharedPreferences.getInstance();
    final themeKey = prefs.getString("ThemeColor");
    final langId = prefs.getString("LanguageID") ?? "LUG-01";
    final refreshToken = prefs.getString('refresh_token');
     final initialRoute = await _getInitialRoute(refreshToken);
    // Wait for Firebase initialization to complete
    await firebaseFuture;
    await SetSharedPref().getData();

    // Initialize theme
    final Color initialColor = themeColorMap[themeKey] ?? const Color(0xFF1A237E);
    final themeNotifier = ThemeNotifier(
      ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: initialColor),
        scaffoldBackgroundColor: Colors.grey[50]!,
      ),
      null,
    );
    if (themeKey != null) {
      themeNotifier.setColor(initialColor, themeKey: themeKey);
    }

    // Initialize locale
    final localeNotifier = LocaleNotifier.initial(
      Locale(getLocaleCodeFromId(langId)),
    );

    // Determine initial route
   

    return AppInitData(
      themeNotifier: themeNotifier,
      localeNotifier: localeNotifier,
      initialRoute: initialRoute,
    );
  }

  static Future<String> _getInitialRoute(String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRoute = prefs.getString('refresh_token');
    
    if (lastRoute == "Login") {
      return AppRoutes.signin;
    } else if (refreshToken == null || refreshToken.isEmpty || refreshToken == "null") {
      return AppRoutes.entryScreen;
    } else {
      return AppRoutes.dashboard_Main;
    }
  }
}

class AppInitData {
  final ThemeNotifier themeNotifier;
  final LocaleNotifier localeNotifier;
  final String initialRoute;

  AppInitData({
    required this.themeNotifier,
    required this.localeNotifier,
    required this.initialRoute,
  });
}

void main() {
  runApp(
    FutureBuilder<AppInitData>(
      future: AppInitializer.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final initData = snapshot.data!;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeNotifier>.value(value: initData.themeNotifier),
                ChangeNotifierProvider<LocaleNotifier>.value(value: initData.localeNotifier),
                ChangeNotifierProvider<ReportModel>(create: (_) => ReportModel()),
              ],
              child: MyApp(initialRoute: initData.initialRoute),
            );
          } else {
            // Fallback if initialization fails
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png', // Update with your logo path
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text('Initialization failed'),
                    ],
                  ),
                ),
              ),
            );
          }
        } else {
          // Show loading screen while initializing
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            home: Logo_ScreenLanding(),
          );
        }
      },
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
      title: 'Digi Xpense',
      debugShowCheckedModeBanner: false,
      
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: themeNotifier.theme,
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