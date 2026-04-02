import 'dart:io';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
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
  final controller = Get.find<Controller>();

  String selectedMenu = '';
  Rxn<File> profileImage = Rxn<File>();
  bool? showExpense;
  bool? showCashAdvance;
  bool? showBoard;
  bool? showCashAdvans;
  bool? showTimesheet;
  bool? punchInOut;
  bool? showLeaveMenu;
  bool? showEmail;
  bool? enablePayRoll;
  bool isFeatureLoading = true;

  bool isProfileLoaded = false;
  bool isPayRoles = false;
  // Auto-open ExpansionTile
  bool isExpenseExpanded = false;
  bool isSheet = false;
  bool isCashExpanded = false;
  bool isReportsExpanded = false;
  bool isLeave = false;
  bool isPunchInOut = false;
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
    showTimesheet = await controller.isFeatureEnabled("EnableTimesheet");
    punchInOut = await controller.isFeatureEnabled(
      "EnableAttendanceRequisition",
    );
    final hasAttendanceRead = PermissionHelper.canRead("Attendance Management");
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
    final loc = AppLocalizations.of(context)!;

    isExpenseExpanded = [
     loc.myExpenses,
      loc.myTeamExpenses,
      loc.pendingApprovals,
      loc.unProcessed,
      'Expense Reports',
      "MIS Reports",
    ].contains(selectedMenu);
    isSheet = [
      'My TimeSheets',
      'My Team TimeSheets',
      'Pending Approvals Sheet',
      'TimeSheet Reports',
    ].contains(selectedMenu);
    isCashExpanded = [
      loc.myCashAdvances,
      loc.myTeamCashAdvances,
      'Cash Advance Pending Approval',
      'CashAdvance Reports',
      'CashAdvance MIS Reports',
    ].contains(selectedMenu);
    isLeave = [
       loc.myLeave,
      loc.myTeamLeave,
      'Leave Pending Approvals',
      'Leave Cancellation',
      'Leave Reports',
      'Leave MIS Reports',
    ].contains(selectedMenu);
    isPunchInOut = [
      loc.punchInOut,
      loc.punchInOutList,
      loc.myTeamAttendance,
    ].contains(selectedMenu);
    isPayRoles = [loc.myPayslips, loc.allPayslips].contains(selectedMenu);
    isReportsExpanded = ['Reports', 'Expenses Reports'].contains(selectedMenu);

    setState(() => isProfileLoaded = true);
  }

  // ========================= Drawer Item ========================= //
  Widget _buildBoldDrawerItem({
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
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
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
              fontWeight: FontWeight.bold,
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.secondary.withOpacity(0.2)
              : Colors.transparent, // Default background
          borderRadius: BorderRadius.circular(10),
        ),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(
            null,
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
                // if (controller.isImageLoading.value)
                //   Container(
                //     width: 60,
                //     height: 60,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.black.withOpacity(0.4),
                //     ),
                //     child: const Center(
                //       child: SizedBox(
                //         width: 22,
                //         height: 22,
                //         child: CircularProgressIndicator(
                //           strokeWidth: 2.5,
                //           valueColor: AlwaysStoppedAnimation<Color>(
                //             Colors.white,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
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
        title: Text(
          AppLocalizations.of(context)!.confirmLogout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.logoutConfirmationMessage,
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: Text(AppLocalizations.of(context)!.logout),
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
    final reportModel = Provider.of<ReportModel>(context, listen: false);
    if (!isProfileLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Drawer(
      width: 260,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),

          // -------------------- Dashboard -------------------- //
          _buildBoldDrawerItem(
            title: loc.dashboard,
            icon: Icons.home_outlined,
            menuKey: "Dashboard",
            onTap: () => Navigator.pushNamed(context, AppRoutes.dashboard_Main),
          ),

          // -------------------- EXPENSE -------------------- //
          if (showExpense == true &&
                  PermissionHelper.canRead("Expense Reports") ||
              PermissionHelper.canRead("Expense Registration"))
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // ✅ removes line
              ),
              child: ExpansionTile(
                initiallyExpanded: isExpenseExpanded,
                leading: Icon(Icons.person_outline),
                title: Text(
                  loc.expense,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  if (PermissionHelper.canRead("Expense Registration"))
                    _buildDrawerItem(
                      title: loc.myExpenses,
                      icon: Icons.arrow_right,
                      menuKey: loc.myExpenses,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.generalExpense,
                      ),
                    ),
                  if (PermissionHelper.canRead("Expense Registration"))
                    _buildDrawerItem(
                      title: loc.myTeamExpenses,
                      icon: Icons.arrow_right,
                      menuKey: loc.myTeamExpenses,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.myTeamExpenseDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Expense Registration"))
                    _buildDrawerItem(
                      title: loc.pendingApprovals,
                      icon: Icons.arrow_right,
                      menuKey: loc.pendingApprovals,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.approvalDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Expense Registration"))
                    _buildDrawerItem(
                      title: loc.unProcessed,
                      icon: Icons.arrow_right,
                      menuKey: loc.unProcessed,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.unProcessed),
                    ),
                  if (PermissionHelper.canRead("Expense Reports"))
                    _buildDrawerItem(
                      title: loc.reports,
                      icon: Icons.arrow_right,
                      menuKey: "Expense Reports",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.expensereportsDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Expense Reports"))
                    _buildDrawerItem(
                      title: loc.misReports,
                      icon: Icons.arrow_right,
                      menuKey: "Expense MIS Reports",
                      onTap: () => {
                        reportModel.clearMISFields(),
                        Navigator.pushNamed(context, AppRoutes.expenseMIS),
                      },
                    ),
                ],
              ),
            ),

          // -------------------- CASH ADVANCE -------------------- //
          if (showCashAdvance == true &&
                  PermissionHelper.canRead("Cash Advance Reports") ||
              PermissionHelper.canRead("Cash Advance Requisition"))
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // ✅ removes line
              ),
              child: ExpansionTile(
                initiallyExpanded: isCashExpanded,
                leading: Icon(Icons.money_outlined),
                title: Text(
                  loc.cashAdvance,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  if (PermissionHelper.canRead("Cash Advance Requisition"))
                    _buildDrawerItem(
                      title: loc.myCashAdvances,
                      icon: Icons.arrow_right,
                      menuKey: loc.myCashAdvances,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.cashAdvanceRequestDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Cash Advance Requisition"))
                    _buildDrawerItem(
                      title: loc.myTeamCashAdvances,
                      icon: Icons.arrow_right,
                      menuKey: loc.myTeamCashAdvances,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.myTeamcashAdvanceDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Cash Advance Requisition"))
                    _buildDrawerItem(
                      title: loc.pendingApprovals,
                      icon: Icons.arrow_right,
                      menuKey: "Cash Advance Pending Approval",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.approvalDashboardForDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Cash Advance Reports"))
                    _buildDrawerItem(
                      title: loc.reports,
                      icon: Icons.arrow_right,
                      menuKey: "CashAdvance Reports",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.cashAdvanceMyReportsDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Cash Advance Reports"))
                    _buildDrawerItem(
                      title: loc.misReports,
                      icon: Icons.arrow_right,
                      menuKey: "CashAdvance MIS Reports",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.cashAdvanceMISReports,
                      ),
                    ),
                ],
              ),
            ),

          // -------------------- EMAIL HUB -------------------- //
          if (showLeaveMenu == true &&
                  PermissionHelper.canRead("Leave Requisition") ||
              PermissionHelper.canRead("Leave Reports"))
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // ✅ removes line
              ),
              child: ExpansionTile(
                initiallyExpanded: isLeave,
                leading: Icon(Icons.work_off),
                title: Text(
                  loc.leaveRequisition,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                children: [
                  if (PermissionHelper.canRead("Leave Requisition"))
                    _buildDrawerItem(
                      title: loc.myLeave,
                      icon: Icons.arrow_right,
                      menuKey: loc.myLeave,
                      onTap: () => {
                        Navigator.pushNamed(context, AppRoutes.leaveDashboard),
                      },
                    ),
                  if (PermissionHelper.canRead("Leave Requisition"))
                    _buildDrawerItem(
                      title: loc.myTeamLeave,
                      icon: Icons.arrow_right,
                      menuKey: loc.myTeamLeave,
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.myTeamsDashboard,
                        ),
                      },
                      // Navigator.pushNamed(context, AppRoutes.reportsDashboard),
                    ),
                  if (PermissionHelper.canRead("Leave Requisition"))
                    _buildDrawerItem(
                      title: loc.pendingApprovals,
                      icon: Icons.arrow_right,
                      menuKey: "Leave Pending Approvals",
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.leavePendingApprovals,
                        ),
                      },
                    ),
                  if (PermissionHelper.canRead("Leave Requisition"))
                    _buildDrawerItem(
                      title: loc.leaveCancellation,
                      icon: Icons.arrow_right,
                      menuKey: 'Leave Cancellation',
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.leaveCancellation,
                        ),
                      },
                    ),

                  if (PermissionHelper.canRead("Leave Reports"))
                    _buildDrawerItem(
                      title: loc.reports,
                      icon: Icons.arrow_right,
                      menuKey: "Leave Reports",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.leaveMyReportsDashboard,
                      ),
                    ),
                  if (PermissionHelper.canRead("Leave Reports"))
                    _buildDrawerItem(
                      title: loc.misReports,
                      icon: Icons.arrow_right,
                      menuKey: "Leave MIS Reports",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.leaveMISReports,
                      ),
                    ),
                ],
              ),
            ),
          if (showTimesheet == true &&
                  PermissionHelper.canRead("Timesheet Reports") ||
              PermissionHelper.canRead("Timesheet Requisition"))
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isSheet,
                leading: Icon(Icons.calendar_month),
                title: Text(
                  loc.timesheets,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  if (PermissionHelper.canRead("Timesheet Requisition"))
                    _buildDrawerItem(
                      title: loc.myTimesheets,
                      icon: Icons.arrow_right,
                      menuKey: 'My TimeSheets',
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.timeSheetDashboard,
                        ),
                      },
                    ),
                  if (PermissionHelper.canRead("Timesheet Requisition"))
                    _buildDrawerItem(
                      title: loc.myTeamTimesheets,
                      icon: Icons.arrow_right,
                      menuKey: 'My Team TimeSheets',
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.myTeamimeSheetRequestPage,
                        ),
                      },
                      // Navigator.pushNamed(context, AppRoutes.reportsDashboard),
                    ),
                  if (PermissionHelper.canRead("Timesheet Requisition"))
                    _buildDrawerItem(
                      title: loc.pendingApprovals,
                      icon: Icons.arrow_right,
                      menuKey: 'Pending Approvals Sheet',
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.timeSheetPendingDashboard,
                        ),
                      },
                    ),
                  if (PermissionHelper.canRead("Timesheet Reports"))
                    _buildDrawerItem(
                      title: loc.reports,
                      icon: Icons.arrow_right,
                      menuKey: "TimeSheet Reports",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.timeSheetDashboardReports,
                      ),
                    ),
                  //  _buildDrawerItem(
                  //   title: "MIS Reports",
                  //   icon: Icons.arrow_right,
                  //   menuKey: "TimeSheet MIS Reports",
                  //   onTap: () =>
                  //       Navigator.pushNamed(context, AppRoutes.leaveMISReports),
                  // ),
                ],
              ),
            ),

          if (enablePayRoll == true &&
              PermissionHelper.canRead("Payroll Requisition"))
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // ✅ removes line
              ),
              child: ExpansionTile(
                initiallyExpanded: isPayRoles,
                leading: Icon(Icons.note),
                title: Text(
                  loc.payroll,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  _buildDrawerItem(
                    title: loc.myPayslips,
                    icon: Icons.arrow_right,
                    menuKey: loc.myPayslips,
                    onTap: () => {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.mypaySlipDashboard,
                      ),
                    },
                  ),
                  _buildDrawerItem(
                    title: loc.allPayslips,
                    icon: Icons.arrow_right,
                    menuKey: loc.allPayslips,
                    onTap: () => {
                      Navigator.pushNamed(context, AppRoutes.paySlipDashboard),
                      // Navigator.pushNamed(context, AppRoutes.myTeamsDashboard),
                    },
                  ),
                ],
              ),
            ),
          if (showBoard == true &&
              PermissionHelper.canRead("Board Requisition"))
            _buildBoldDrawerItem(
              title: loc.board,
              icon: Icons.dashboard,
              menuKey: loc.board,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.boardDashboard),
            ),
          if (showEmail == true)
            if (PermissionHelper.canRead("Expense Registration"))
              _buildBoldDrawerItem(
                title: loc.emailHub,
                icon: Icons.mail_outline,
                menuKey: loc.emailHub,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.emailHubScreen),
              ),

          // -------------------- APPROVAL HUB -------------------- //
          _buildBoldDrawerItem(
            title: loc.approvalHub,
            icon: Icons.calendar_today,
            menuKey: loc.approvalHub,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.approvalHubMain),
          ),

          // -------------------- REPORTS -------------------- //
          // Theme(
          //   data: Theme.of(context).copyWith(
          //     dividerColor: Colors.transparent, // ✅ removes line
          //   ),
          //   child: ExpansionTile(
          //     initiallyExpanded: isReportsExpanded,
          //     leading: Icon(Icons.person_outline),
          //     title: Text(
          //       loc.reports,
          //       style: TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //     children: [
          //       _buildDrawerItem(
          //         title: loc.reports,
          //         icon: Icons.arrow_right,
          //         menuKey: loc.reports,
          //         onTap: () =>
          //             Navigator.pushNamed(context, AppRoutes.reportsDashboard),
          //       ),
          //       _buildDrawerItem(
          //         title: loc.expensesReports,
          //         icon: Icons.arrow_right,
          //         menuKey: loc.expensesReports,
          //         onTap: () => Navigator.pushNamed(
          //           context,
          //           AppRoutes.reportWizardParent,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          if (punchInOut == true &&
              PermissionHelper.canRead("Attendance Requisition") == true)
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // ✅ removes line
              ),
              child: ExpansionTile(
                initiallyExpanded: isPunchInOut,
                leading: Icon(Icons.fingerprint),
                title: Text(
                  loc.punchInOut,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  _buildDrawerItem(
                    title: loc.punchInOut,
                    icon: Icons.arrow_right,
                    menuKey: loc.punchInOut,
                    onTap: () => {
                      Navigator.pushNamed(context, AppRoutes.punchScreen),
                    },
                  ),
                  _buildDrawerItem(
                    title: loc.punchInOutList,
                    icon: Icons.arrow_right,
                    menuKey: loc.punchInOutList,
                    onTap: () => {
                      Navigator.pushNamed(context, AppRoutes.myAttendanceList),
                    },
                    // Navigator.pushNamed(context, AppRoutes.reportsDashboard),
                  ),
                  _buildDrawerItem(
                    title: loc.myTeamAttendance,
                    icon: Icons.arrow_right,
                    menuKey: loc.myTeamAttendance,
                    onTap: () => {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.myTeamPunchInOutList,
                      ),
                    },
                  ),
                ],
              ),
            ),

          // -------------------- SETTINGS -------------------- //
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     loc.settings,
          //     style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          //   ),
          // ),

          _buildBoldDrawerItem(
            title: loc.settings,
            icon: Icons.settings_outlined,
            menuKey: loc.settings,
            onTap: () => Navigator.pushNamed(context, AppRoutes.personalInfo),
          ),

          _buildBoldDrawerItem(
            title: loc.help,
            icon: Icons.help_outline,
            menuKey: loc.help,
            onTap: () => {},
          ),

          // -------------------- LOGOUT -------------------- //
          Obx(
            () => ListTile(
              leading: controller.isLogoutLoading.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout, color: Colors.red),

              title: Text(
                controller.isLogoutLoading.value
                    ? "Logging out..."
                    : loc.logout,
                style: const TextStyle(color: Colors.red),
              ),

              // ✅ Disable second click
              onTap: controller.isLogoutLoading.value
                  ? null
                  : () {
                      _showLogoutConfirmation(context, () async {
                        controller.isLogoutLoading.value = true;

                        try {
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
                        } finally {
                          controller.isLogoutLoading.value = false;
                        }
                      });
                    },
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
