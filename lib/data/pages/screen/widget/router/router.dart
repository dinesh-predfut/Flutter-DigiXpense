// lib/presentation/routes/app_routes.dart
import 'dart:io';

import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/GeneralExpense/createForm.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/GeneralExpense/viewGeneralExpense.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Mileage/mileageExpenseForm.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Mileage/mileageExpenseFormstart.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/PerDiem/perDiemCreateform.dart';
import 'package:digi_xpense/data/pages/screen/Profile/personalDetail.dart';
import 'package:digi_xpense/data/pages/screen/landingLogo/entryLogoScree.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/core/comman/navigationBar.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/forgetPassword.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/login.dart';
import 'package:digi_xpense/data/pages/screen/Dashboard_Screen/dashboard_Main.dart';
import 'package:digi_xpense/data/pages/screen/Profile/changeLanguage.dart';
import '../../ALl_Expense_Screens/AutoScan/autoScan.dart';
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
  static const String expenseForm = '/expense/generalExpense/from';
  static const String getSpecificExpense = '/expense/getSpecificExpense/view';
  static const String autoScan = '/expense/outScan/view';
  static const String perDiem = '/expense/PerDiem/create';
  static const String mileageExpense = '/expense/mileageExpense/create';
  static const String mileageExpensefirst =
      '/expense/mileageExpense/mileageExpensefirst';
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
      case perDiem:
        final args = settings.arguments;
        if (args != null &&
            args is Map<String, dynamic> &&
            args.containsKey('item')) {
          final PerdiemResponseModel item = args['item'];
          return MaterialPageRoute(
            builder: (_) => CreatePerDiemPage(item: item),
          );
        } else {
          // fallback: navigate to CreatePerDiemPage without item or show error
          return MaterialPageRoute(
            builder: (_) => const CreatePerDiemPage(),
          );
        }

      case mileageExpense:
        return MaterialPageRoute(
            builder: (_) => const MileageRegistrationPage());
      case mileageExpensefirst:
        return MaterialPageRoute(builder: (_) => const MileageFirstFrom());

      case autoScan:
        final args = settings.arguments as Map<String, dynamic>;
        final File imageFile = args['imageFile'];
        final Map<String, dynamic> apiResponse = args['apiResponse'];

        return MaterialPageRoute(
          builder: (_) => AutoScanExpensePage(
            imageFile: imageFile,
            apiResponse: apiResponse,
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ScaffoldWithNav(
            pages: [
              DashboardPage(),
              GeneralExpenseDashboard(),
              LoginScreen(),
            ],
            initialIndex: 0,
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
      case expenseForm:
        return MaterialPageRoute(builder: (_) => const ExpenseCreationForm());
      case AppRoutes.getSpecificExpense:
        final args = settings.arguments as Map<String, dynamic>?;
        print("args$args");
        return MaterialPageRoute(
          builder: (_) => ViewEditExpensePage(
            items: args?['item'],
            isReadOnly: true,
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
