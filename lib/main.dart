import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// Local imports
import 'firebase_options.dart'; // ✅ Make sure this file exists in lib/
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'core/constant/Parames/params.dart';

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

/// Determine initial route based on token
Future<String> getInitialRoute(String? refreshToken) async {
  if (refreshToken == null || refreshToken.isEmpty || refreshToken == "null") {
    return AppRoutes.entryScreen;
  }

  try {
    final response = await http.post(
      Uri.parse("https://api.digixpense.com/api/v1/tenant/auth/refresh_token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $refreshToken',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data["access_token"] != null) {
        Params.userToken = data["access_token"];
        return AppRoutes.dashboard_Main;
      }
    }

    return AppRoutes.signin;
  } catch (_) {
    return AppRoutes.signin;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔹 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Use the generated file
  );

  /// 🔹 SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final themeKey = prefs.getString("ThemeColor");
  final langId = prefs.getString("LanguageID") ?? "LUG-01";

  /// 🔹 LocaleNotifier
  final localeNotifier = LocaleNotifier.initial(Locale(getLocaleCodeFromId(langId)));

  /// 🔹 ThemeNotifier
  final Color initialColor =
      themeColorMap[themeKey] ?? const Color(0xFF1A237E);

  final themeNotifier = ThemeNotifier(
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: initialColor),
      scaffoldBackgroundColor: Colors.grey[50]!,
    ),
  );
  if (themeKey != null) {
    themeNotifier.setColor(initialColor, themeKey: themeKey);
  }

  /// 🔹 Load refresh token
  await SetSharedPref().getData();

  /// 🔹 Initial route
  final initialRoute = await getInitialRoute(Params.refreshtoken);

  /// 🔹 Run App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
        ChangeNotifierProvider<LocaleNotifier>.value(value: localeNotifier),
        ChangeNotifierProvider<ReportModel>(create: (_) => ReportModel()),
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
      title: 'Digi Xpense',
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
