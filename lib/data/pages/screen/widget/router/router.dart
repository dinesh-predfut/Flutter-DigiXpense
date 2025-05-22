// lib/presentation/routes/app_routes.dart
import 'package:digi_xpense/data/pages/screen/Profile/personalDetail.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/core/comman/navigationBar.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/forgetPassword.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/login.dart';
import 'package:digi_xpense/data/pages/screen/Dashboard_Screen/dashboard_Main.dart';
import 'package:digi_xpense/data/pages/screen/Profile/changeLanguage.dart';
import '../../Profile/profile.dart';
import '../../landingLogo/widget.dart';

class AppRoutes {
  static const String signin = '/home';
  static const String login = '/login';
  static const String forgetPasswordurl = '/forgetPassword';
  static const String dashboard_Main = '/dashboard_Main';
  static const String changesLanguage = '/profile/changesLanguage';
  static const String profile = '/profile/profileinfo';
  static const String personalInfo='/profile/profileDetailsPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgetPasswordurl:
        return MaterialPageRoute(builder: (_) => const ForgetPassword());
      case changesLanguage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case personalInfo:
        return MaterialPageRoute(builder: (_) =>  PersonalDetailsPage());
      case profile:
        return MaterialPageRoute(
          builder: (_) =>  ScaffoldWithNav(
            pages: [
              const DashboardPage(),
              const ForgetPassword(),
              const LoginScreen(),
               PersonalDetailsPage(),
            ],
            initialIndex: 3, // index of ProfilePage
          ),
        );
      case dashboard_Main:
        return MaterialPageRoute(
          builder: (_) =>  ScaffoldWithNav(
            pages: [
              const DashboardPage(),
              const ForgetPassword(),
              const LoginScreen(),
              PersonalDetailsPage(),
            ],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
