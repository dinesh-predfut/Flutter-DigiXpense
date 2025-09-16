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
  late AnimationController _animationController;
  bool isProfileLoaded = false; // ✅ New state to wait until user data is ready

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _loadUserData();
  }

  /// Fetch username & profile image, then show drawer content
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    controller.userName.value = prefs.getString('userName') ?? '';
print("controller.profileImage.value${controller.profileImage.value}");
    if (controller.profileImage.value == null) {
      await controller.getProfilePicture();
      controller.callProfile = true;
    }

    setState(() {
      isProfileLoaded = true;
    });
  }

  /// Drawer Menu Item Widget
  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required String menuKey,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final bool isActive = selectedMenu == menuKey;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: const Color.fromARGB(36, 153, 153, 152),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: () {
          setState(() => selectedMenu = menuKey);
          onTap?.call();
        },
      ),
    );
  }

  /// Drawer Header Widget
  Widget _buildDrawerHeader() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Obx(() => CircleAvatar(
                radius: 30,
                backgroundImage: controller.isImageLoading.value
                    ? null
                    : controller.profileImage.value != null
                        ? FileImage(controller.profileImage.value!)
                        : null,
                child: controller.isImageLoading.value
                    ? const CircularProgressIndicator()
                    : controller.profileImage.value == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
              )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText("${loc.hello}, 👋"),
                      TyperAnimatedText("${loc.hiThere}, "),
                      TyperAnimatedText("${loc.welcomeBack}, "),
                    ],
                    repeatForever: true,
                    pause: const Duration(milliseconds: 800),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  return DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          controller.userName.value.isNotEmpty
                              ? controller.userName.value.trim()
                              : "",
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
      BuildContext context, VoidCallback onLogout) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color.fromARGB(221, 53, 50, 50),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onLogout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (!isProfileLoaded) {
      /// ✅ Full-screen loader until profile + name loaded
      return const Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: CircularProgressIndicator(strokeWidth: 5),
        ),
      );
    }

    return Drawer(
      width: 280,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("MAIN",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ),
          _buildDrawerItem(
            title: loc.dashboard,
            icon: Icons.home_outlined,
            menuKey: "Dashboard",
            onTap: () => Navigator.pushNamed(context, AppRoutes.dashboard_Main),
          ),
          ExpansionTile(
            leading: Icon(Icons.person_outline,
                color: Theme.of(context).colorScheme.primary),
            title: Text(loc.expense,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            childrenPadding: const EdgeInsets.only(left: 16),
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
                    context, AppRoutes.myTeamExpenseDashboard),
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
          ExpansionTile(
            leading: Icon(Icons.money_outlined,
                color: Theme.of(context).colorScheme.primary),
            title: Text(loc.cashAdvance,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            childrenPadding: const EdgeInsets.only(left: 16),
            children: [
              _buildDrawerItem(
                title: loc.myCashAdvances,
                icon: Icons.arrow_right,
                menuKey: loc.myCashAdvances,
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.cashAdvanceRequestDashboard),
              ),
              _buildDrawerItem(
                title: loc.myTeamCashAdvances,
                icon: Icons.arrow_right,
                menuKey: loc.myTeamCashAdvances,
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.myTeamcashAdvanceDashboard),
              ),
              _buildDrawerItem(
                title: loc.pendingApprovals,
                icon: Icons.arrow_right,
                menuKey: loc.pendingApprovals,
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.approvalDashboardForDashboard),
              ),
            ],
          ),
          _buildDrawerItem(
            title: loc.emailHub,
            icon: Icons.mail_outline,
            menuKey: loc.emailHub,
            onTap: () => Navigator.pushNamed(context, AppRoutes.emailHubScreen),
          ),
          _buildDrawerItem(
            title: loc.approvalHub,
            icon: Icons.calendar_today,
            menuKey: loc.approvalHub,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.approvalHubMain),
          ),
          ExpansionTile(
            leading: Icon(Icons.person_outline,
                color: Theme.of(context).colorScheme.primary),
            title: Text(loc.reports,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            childrenPadding: const EdgeInsets.only(left: 16),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(loc.settings,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ),
          _buildDrawerItem(
            title: loc.settings,
            icon: Icons.settings_outlined,
            menuKey: loc.settings,
          ),
          _buildDrawerItem(
            title: loc.help,
            icon: Icons.help_outline,
            menuKey: loc.help,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(loc.logout, style: const TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutConfirmation(context, () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                final themeNotifier =
                    Provider.of<ThemeNotifier>(context, listen: false);
                await themeNotifier.clearTheme();

                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.signin,
                  (route) => false,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
