// lib/presentation/routes/app_routes.dart
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/GeneralExpense/createForm.dart';
import 'package:digi_xpense/data/pages/screen/Profile/personalDetail.dart';
import 'package:digi_xpense/data/pages/screen/landingLogo/entryLogoScree.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/core/comman/navigationBar.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/forgetPassword.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/login.dart';
import 'package:digi_xpense/data/pages/screen/Dashboard_Screen/dashboard_Main.dart';
import 'package:digi_xpense/data/pages/screen/Profile/changeLanguage.dart';
import '../../ALl_Expense_Screens/GeneralExpense/dashboard.dart';
import '../../Profile/profile.dart';
import '../../landingLogo/widget.dart';

class AppRoutes {
  static const String signin = '/home';
  static const String login = '/login';
  static const String forgetPasswordurl = '/forgetPassword';
  static const String dashboard_Main = '/dashboard_Main';
  static const String changesLanguage = '/profile/changesLanguage';
  static const String profile = '/profile/profileinfo';
  static const String personalInfo = '/profile/profileDetailsPage';
  static const String entryScreen = '/profile/entryLogoScreen';
  static const String generalExpense = '/expense/generalExpense';
  static const String expenseForm = '/expense/generalExpense/fom';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case entryScreen:
        return MaterialPageRoute(builder: (_) => const Logo_Screen());
      case login:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgetPasswordurl:
        return MaterialPageRoute(builder: (_) => const ForgetPassword());
      case changesLanguage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalDetailsPage());
      case generalExpense:
        return MaterialPageRoute(
            builder: (_) => const GeneralExpenseDashboard());
      case expenseForm:
        return MaterialPageRoute(
            builder: (_) => const ExpenseCreationForm());
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ScaffoldWithNav(
            pages: [
              DashboardPage(),
              GeneralExpenseDashboard(),
              LoginScreen(),
              // PersonalDetailsPage(),
            ],
            initialIndex: 0, // index of ProfilePage
          ),
        );
      case dashboard_Main:
        return MaterialPageRoute(
          builder: (_) => const ScaffoldWithNav(
            pages: [
              DashboardPage(),
              GeneralExpenseDashboard(),
              // LoginScreen(),
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
