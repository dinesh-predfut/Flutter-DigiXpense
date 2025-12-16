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

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print("Firebase initialization error (continuing anyway): $e");
    }

    // Load SharedPreferences and other data
    final prefs = await SharedPreferences.getInstance();
    final themeKey = prefs.getString("ThemeColor");
    final langId = prefs.getString("LanguageID") ?? "LUG-01";
    final refreshToken = prefs.getString('refresh_token');
    final initialRoute = await _getInitialRoute(refreshToken);
print("initialRoute$initialRoute");
    // Initialize SetSharedPref
    try {
      await SetSharedPref().getData();
    } catch (e) {
      print("SetSharedPref.getData error: $e");
    }

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

    return AppInitData(
      themeNotifier: themeNotifier,
      localeNotifier: localeNotifier,
      initialRoute: initialRoute,
    );
  }

  static Future<String> _getInitialRoute(String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRoute = prefs.getString('last_route'); // Changed from refresh_token
    print("lastRoute$lastRoute");
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
  WidgetsFlutterBinding.ensureInitialized();
  
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
                      FlutterLogo(size: 100),
                      const SizedBox(height: 20),
                      const Text('Digi Xpense', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text('Initialization failed, please restart'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          runApp(
                            MaterialApp(
                              debugShowCheckedModeBanner: false,
                              home: Scaffold(
                                body: Center(child: Text('Retry failed')),
                              ),
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
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

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget _homeScreen;
  
  @override
  void initState() {
    super.initState();
    
    // Create a temporary home screen that will navigate to the initial route
    _homeScreen = _buildTempHomeScreen();
    
    // Delay navigation to ensure MaterialApp is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToInitialRoute();
    });
  }
  
  Widget _buildTempHomeScreen() {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Loading Digi Xpense...'),
              const SizedBox(height: 10),
              Text('Route: ${widget.initialRoute}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToInitialRoute() {
    if (mounted) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, widget.initialRoute);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      title: 'Digi Xpense',
      debugShowCheckedModeBanner: false,
      
      // Provide a home to prevent white screen
      home: _homeScreen,
      
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) {
        print("Navigating to: ${settings.name}");
        try {
          return AppRoutes.generateRoute(settings);
        } catch (e) {
          print("Route generation error: $e");
          // Fallback route
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text('Navigation Error'),
                    const SizedBox(height: 10),
                    Text('Route: ${settings.name}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.entryScreen);
                      },
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
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
      
      // Add a builder to catch errors
      builder: (context, child) {
        return child ?? Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 64, color: Colors.orange),
                const SizedBox(height: 20),
                const Text('App Error'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    runApp(MyApp(initialRoute: AppRoutes.entryScreen));
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Add this fallback widget
class SimpleLoadingScreen extends StatelessWidget {
  const SimpleLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Digi Xpense',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Loading your financial experience...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}