import 'dart:io';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/pages/screen/widget/router/router.dart';
import '../../../data/service.dart';
import '../../../l10n/app_localizations.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(Controller());

  String selectedMenu = '';
  Rxn<File> profileImage = Rxn<File>();

  bool isProfileLoaded = false;

  // Auto-open ExpansionTile
  bool isExpenseExpanded = false;
  bool isCashExpanded = false;
  bool isReportsExpanded = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    _loadUserData();
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');

    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
    }
  }

  /// Load username + saved active menu
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    controller.userName.value = prefs.getString('userName') ?? '';

    selectedMenu = prefs.getString('selectedMenu') ?? '';

    // Auto-expand ExpansionTiles
    isExpenseExpanded = [
      'My Expenses',
      'My Team Expenses',
      'Pending Approvals',
      'UnProcessed',
    ].contains(selectedMenu);

    isCashExpanded = [
      'My Cash Advances',
      'My Team Cash Advances',
      'Pending Approvals',
    ].contains(selectedMenu);

    isReportsExpanded = ['Reports', 'Expenses Reports'].contains(selectedMenu);

    setState(() => isProfileLoaded = true);
  }

  // ========================= Drawer Item ========================= //

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required String menuKey,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final bool isActive = selectedMenu == menuKey;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutBack,
            ),
          ),

      /// ⭐ Wrap with Container to control full-width background
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.secondary.withOpacity(0.2)
              : Colors.transparent, // Default background
          borderRadius: BorderRadius.circular(10),
        ),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(
            icon,
            color: isActive ? theme.colorScheme.secondary : null,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? theme.colorScheme.secondary : null,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () async {
            setState(() => selectedMenu = menuKey);

            final prefs = await SharedPreferences.getInstance();
            prefs.setString('selectedMenu', menuKey);

            onTap?.call();
          },
        ),
      ),
    );
  }

  // ========================= Drawer Header ========================= //

  Widget _buildDrawerHeader() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
        ),
      ),
      child: Row(
        children: [
          Obx(
            () => CircleAvatar(
              radius: 30,
              backgroundImage: controller.isImageLoading.value
                  ? null
                  : profileImage.value != null
                  ? FileImage(profileImage.value!)
                  : null,
              child: controller.isImageLoading.value
                  ? const CircularProgressIndicator()
                  : profileImage.value == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText("${loc.hello}, 👋"),
                      TyperAnimatedText("${loc.hiThere}, "),
                      TyperAnimatedText("${loc.welcomeBack}, "),
                    ],
                    repeatForever: true,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          controller.userName.value.trim(),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================= Logout Dialog ========================= //

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    VoidCallback onLogout,
  ) async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // ========================= Build Drawer ========================= //

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (!isProfileLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Drawer(
      width: 260,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),

          // -------------------- MENU TITLE -------------------- //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              loc.all,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),

          // -------------------- Dashboard -------------------- //
          _buildDrawerItem(
            title: loc.dashboard,
            icon: Icons.home_outlined,
            menuKey: "Dashboard",
            onTap: () => Navigator.pushNamed(context, AppRoutes.dashboard_Main),
          ),

          // -------------------- EXPENSE -------------------- //
          ExpansionTile(
            initiallyExpanded: isExpenseExpanded,
            leading: Icon(Icons.person_outline),
            title: Text(loc.expense),
            children: [
              _buildDrawerItem(
                title: loc.myExpenses,
                icon: Icons.arrow_right,
                menuKey: loc.myExpenses,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.generalExpense),
              ),
              _buildDrawerItem(
                title: loc.myTeamExpenses,
                icon: Icons.arrow_right,
                menuKey: loc.myTeamExpenses,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.myTeamExpenseDashboard,
                ),
              ),
              _buildDrawerItem(
                title: loc.pendingApprovals,
                icon: Icons.arrow_right,
                menuKey: loc.pendingApprovals,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.approvalDashboard),
              ),
              _buildDrawerItem(
                title: loc.unProcessed,
                icon: Icons.arrow_right,
                menuKey: loc.unProcessed,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.unProcessed),
              ),
            ],
          ),

          // -------------------- CASH ADVANCE -------------------- //
          ExpansionTile(
            initiallyExpanded: isCashExpanded,
            leading: Icon(Icons.money_outlined),
            title: Text(loc.cashAdvance),
            children: [
              _buildDrawerItem(
                title: loc.myCashAdvances,
                icon: Icons.arrow_right,
                menuKey: loc.myCashAdvances,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cashAdvanceRequestDashboard,
                ),
              ),
              _buildDrawerItem(
                title: loc.myTeamCashAdvances,
                icon: Icons.arrow_right,
                menuKey: loc.myTeamCashAdvances,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.myTeamcashAdvanceDashboard,
                ),
              ),
              _buildDrawerItem(
                title: loc.pendingApprovals,
                icon: Icons.arrow_right,
                menuKey: "Cash Advance Pending Approval",
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.approvalDashboardForDashboard,
                ),
              ),
            ],
          ),

          // -------------------- EMAIL HUB -------------------- //
          _buildDrawerItem(
            title: loc.emailHub,
            icon: Icons.mail_outline,
            menuKey: loc.emailHub,
            onTap: () => Navigator.pushNamed(context, AppRoutes.emailHubScreen),
          ),

          // -------------------- APPROVAL HUB -------------------- //
          _buildDrawerItem(
            title: loc.approvalHub,
            icon: Icons.calendar_today,
            menuKey: loc.approvalHub,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.approvalHubMain),
          ),

          // -------------------- REPORTS -------------------- //
          ExpansionTile(
            initiallyExpanded: isReportsExpanded,
            leading: Icon(Icons.person_outline),
            title: Text(loc.reports),
            children: [
              _buildDrawerItem(
                title: loc.reports,
                icon: Icons.arrow_right,
                menuKey: loc.reports,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.reportsDashboard),
              ),
              _buildDrawerItem(
                title: loc.expensesReports,
                icon: Icons.arrow_right,
                menuKey: loc.expensesReports,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.reportWizardParent),
              ),
            ],
          ),

          const Divider(),

          // -------------------- SETTINGS -------------------- //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              loc.settings,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),

          _buildDrawerItem(
            title: loc.settings,
            icon: Icons.settings_outlined,
            menuKey: loc.settings,
            onTap: () => Navigator.pushNamed(context, AppRoutes.personalInfo),
          ),

          _buildDrawerItem(
            title: loc.help,
            icon: Icons.help_outline,
            menuKey: loc.help,
          ),

          // -------------------- LOGOUT -------------------- //
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(loc.logout, style: const TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutConfirmation(context, () async {
                await controller.logout();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                await prefs.remove('employeeId');
                await prefs.remove('userId');
                await prefs.remove('refresh_token');
                await prefs.remove('userName');
                prefs.setString('refresh_token', 'Login');

               
                final themeNotifier = Provider.of<ThemeNotifier>(
                  context,
                  listen: false,
                );
                await themeNotifier.clearTheme();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.signin,
                  (route) => false,
                );
              });
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
