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
  bool? showExpense;
  bool? showCashAdvance;
  bool? showBoard;
  bool? showCashAdvans;
  bool? showTimesheet;
  bool? showLeaveMenu;
  bool? showEmail;
  bool? enablePayRoll;
  bool isFeatureLoading = true;

  bool isProfileLoaded = false;

  // Auto-open ExpansionTile
  bool isExpenseExpanded = false;
  bool isCashExpanded = false;
  bool isReportsExpanded = false;
  bool isLeave = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _initializeDrawer();
  }

  Future<void> _initializeDrawer() async {
    await loadFuture(); // wait for feature flags
    await _loadUserData(); // wait for user data
    await _loadProfileImage(); // image can load independently

    setState(() {
      isFeatureLoading = false;
      isProfileLoaded = true;
    });
  }

  Future<void> loadFuture() async {
    showExpense = await controller.isFeatureEnabled('EnableExpense');
    showCashAdvance = await controller.isFeatureEnabled(
      'EnableCashAdvanceRequisition',
    );
    showBoard = await controller.isFeatureEnabled("EnableKanbanBoard");
    showTimesheet = await controller.isFeatureEnabled("EnableTimesheet");
    enablePayRoll = await controller.isFeatureEnabled("EnablePayRoll");
    showEmail = await controller.isFeatureEnabled("EnableEmailForwording");
    showLeaveMenu = await controller.isFeatureEnabled("EnableLeaveRequisition");
    print("EnableExpenseMenu$showExpense");
    print("EnableshowCashAdvance$showCashAdvance");
    print("EnableshowBoard$showBoard");
    print("EnableshowTimesheet$showTimesheet");
  }

  Future<void> _loadProfileImage() async {
    //  WidgetsBinding.instance.addPostFrameCallback((_) {
    //    controller.selectedExpenseType = "All Expenses".obs;
    //     controller.selectedStatusDropDown = "Un Reported".obs;
    //     controller.selectedStatus = "Un Reported";});
    controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    //  final prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    // prefs.setString('selectedMenu', AppLocalizations.of(context)!.myExpenses);
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
      controller.isImageLoading.value = false;
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
    isLeave = [
      'My Leave',
      'My Team Leave',
      'Pending Approvals',
      'Cancellation Leave',
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
            () => Stack(
              alignment: Alignment.center,
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: profileImage.value != null
                      ? FileImage(profileImage.value!)
                      : null,
                  child: profileImage.value == null
                      ? const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white70,
                        )
                      : null,
                ),

                /// Loader Overlay
                if (controller.isImageLoading.value)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
          if (showExpense == true)
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
          if (showCashAdvance == true)
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
          if (showEmail == true)
            _buildDrawerItem(
              title: loc.emailHub,
              icon: Icons.mail_outline,
              menuKey: loc.emailHub,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.emailHubScreen),
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
          if (showLeaveMenu == true)
            ExpansionTile(
              initiallyExpanded: isLeave,
              leading: Icon(Icons.work_off),
              title: Text(loc.leaveRequisition),
              children: [
                _buildDrawerItem(
                  title: loc.myLeave,
                  icon: Icons.arrow_right,
                  menuKey: loc.myLeave,
                  onTap: () => {
                    Navigator.pushNamed(context, AppRoutes.leaveDashboard),
                  },
                ),
                _buildDrawerItem(
                  title: loc.myTeamLeave,
                  icon: Icons.arrow_right,
                  menuKey: loc.myTeamLeave,
                  onTap: () => {
                    Navigator.pushNamed(context, AppRoutes.myTeamsDashboard),
                  },
                  // Navigator.pushNamed(context, AppRoutes.reportsDashboard),
                ),
                _buildDrawerItem(
                  title: loc.pendingApprovals,
                  icon: Icons.arrow_right,
                  menuKey: loc.pendingApprovals,
                  onTap: () => {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.leavePendingApprovals,
                    ),
                  },
                ),
                _buildDrawerItem(
                  title: "Cancellation Leave",
                  icon: Icons.arrow_right,
                  menuKey: "Cancellation Leave",
                  onTap: () => {
                    Navigator.pushNamed(context, AppRoutes.leaveCancellation),
                  },
                ),
              ],
            ),
             if (showTimesheet == true)
            ExpansionTile(
              initiallyExpanded: isLeave,
              leading: Icon(Icons.calendar_month),
              title: Text("Times Sheets"),
              children: [
                _buildDrawerItem(
                  title: "My TimeSheets",
                  icon: Icons.arrow_right,
                  menuKey: "My TimeSheets",
                  onTap: () => {
                    Navigator.pushNamed(context, AppRoutes.timeSheetDashboard),
                  },
                ),
                _buildDrawerItem(
                  title: "My Team TimeSheets",
                  icon: Icons.arrow_right,
                  menuKey: "My Team TimeSheets",
                  onTap: () => {
                    // Navigator.pushNamed(context, AppRoutes.myTeamsDashboard),
                  },
                  // Navigator.pushNamed(context, AppRoutes.reportsDashboard),
                ),
                _buildDrawerItem(
                  title: loc.pendingApprovals,
                  icon: Icons.arrow_right,
                  menuKey: loc.pendingApprovals,
                  onTap: () => {
                    // Navigator.pushNamed(
                    //   context,
                    //   AppRoutes.leavePendingApprovals,
                    // ),
                  },
                ),
               
              ],
            ),
          if (enablePayRoll == true)
            ExpansionTile(
              initiallyExpanded: isLeave,
              leading: Icon(Icons.note),
              title: Text("Payroll"),
              children: [
                _buildDrawerItem(
                  title: "My Payslips",
                  icon: Icons.arrow_right,
                  menuKey: "My Payslips",
                  onTap: () => {
                    Navigator.pushNamed(context, AppRoutes.paySlipDashboard),
                  },
                ),
                _buildDrawerItem(
                  title: "All Payslips",
                  icon: Icons.arrow_right,
                  menuKey: "All Payslips",
                  onTap: () => {
                    // Navigator.pushNamed(context, AppRoutes.myTeamsDashboard),
                  },
                ),
              ],
            ),
          if (showBoard == true)
            _buildDrawerItem(
              title: "Board",
              icon: Icons.dashboard,
              menuKey: "Board",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.boardDashboard),
            ),

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
            onTap: () => {},
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
                await prefs.remove('profileImagePath');
                prefs.setString('last_route', 'Login');

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
