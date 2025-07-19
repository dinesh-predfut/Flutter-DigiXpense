import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
// import 'package:digi_xpense/generated/app_en.arb';
// Locale notifier to switch language
class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                ThemeNotifier(ThemeData(primarySwatch: Colors.blue))),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      title: 'My Flutter App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.entryScreen,
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
