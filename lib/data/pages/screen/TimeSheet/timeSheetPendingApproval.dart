import 'dart:convert';
import 'dart:io';
import 'package:diginexa/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:diginexa/core/comman/widgets/languageDropdown.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/noDataFind.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart' show Params;
import 'package:diginexa/data/models.dart'
    show
        ManageExpensesCard,
        GExpense,
        LeaveAnalytics,
        LeaveRequisition,
        LeaveDetailsModel,
        Employee,
        TimesheetModel;
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/leaveCalenderView.dart';
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/view_CreateLeave.dart';
import 'package:diginexa/data/pages/screen/TimeSheet/createViewTimeSheet.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class TimeSheetPendingDashboard extends StatefulWidget {
  const TimeSheetPendingDashboard({super.key});

  @override
  State<TimeSheetPendingDashboard> createState() =>
      _TimeSheetPendingDashboard();
}

class _TimeSheetPendingDashboard extends State<TimeSheetPendingDashboard>
    with TickerProviderStateMixin {
  // late final Controller controller;
final controller = Get.find<Controller>();
  late final AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  RxList<LeaveAnalytics> leaveAnalyticsCards = <LeaveAnalytics>[].obs;

  // Tab related variables

  bool isLoading = false;
  Rxn<File> profileImage = Rxn<File>();
  bool? showExpense;
  bool? showPerDiem;
  bool? showMileage;
  bool? showCashAdvans;
  final List<String> statusOptions = ["In Process", "All"];

  String formatDateFromMillis(int? millis) {
    if (millis == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.selectedTimesheetIds.clear();
    });

    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
      controller.getPersonalDetails(context);
      controller.fetchPendingApprovalsTimeSHeet().then((_) {
        controller.isLoadingLeaves.value = false;
      });
    });
  }

  void _loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedMenu', 'Pending Approvals Sheet');
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      controller.isImageLoading.value = false;
    }
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        controller.selectedStatus = "Un Reported";
        controller.selectedTimeSheetStatusDropDown.value = "Un Reported";
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        controller.selectedTimesheetIds.clear();
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: const MyDrawer(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final theme = Theme.of(context);
            final primaryColor = theme.primaryColor;
            return Column(
              children: [
                if (primaryColor != const Color(0xFF1e4db7))
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(
                            0.7,
                          ), // Lighter primary color
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _openMenu,
                                icon: Icon(
                                  Icons.menu,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  // backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                ),
                              ),

                              // Logo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/XpenseWhite.png',
                                  width: isSmallScreen ? 60 : 80,
                                  height: isSmallScreen ? 30 : 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        Flexible(
                          flex: 9,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const LanguageDropdown(),

                                IconButton(
                                  icon: const Icon(
                                    Icons.fingerprint,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.punchScreen,
                                    );
                                  },
                                ),

                                _buildNotificationBadge(),
                                _buildProfileAvatar(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (primaryColor == const Color(0xFF1e4db7))
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Vector.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: _openMenu,
                                icon: Icon(
                                  Icons.menu,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  // backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                ),
                              ),

                              // Logo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/XpenseWhite.png',
                                  width: isSmallScreen ? 50 : 70,
                                  height: isSmallScreen ? 30 : 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        Flexible(
                          flex: 9,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const LanguageDropdown(),

                                IconButton(
                                  icon: const Icon(
                                    Icons.fingerprint,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.punchScreen,
                                    );
                                  },
                                ),

                                _buildNotificationBadge(),
                                _buildProfileAvatar(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.timeSheetPendingApprovals,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: controller.searchControllerApprovalDashBoard,
                      onChanged: (value) {
                        controller.searchQuery.value = value.toLowerCase();
                        print(controller.searchController.text);
                      },
                      decoration: InputDecoration(
                        hintText: loc.search,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Align(
  alignment: Alignment.centerLeft,
  child: Padding(
    padding: const EdgeInsets.only(right: 16, left: 16),
    child: Obx(() {
      final isDisabled = controller.selectedTimesheetIds.isEmpty;

      return Container(
        height: 47,
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: PopupMenuButton<String>(
          enabled: !isDisabled, // ✅ disables tap
          onSelected: (value) {
            if (value == "approve") {
              showActionPopup(context, "Approve");
            } else if (value == "reject") {
              showActionPopup(context, "Reject");
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "approve",
              child: Text("Approval"),
            ),
            PopupMenuItem(
              value: "reject",
              child: Text("Reject"),
            ),
          ],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bulk Action",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }),
  ),
),
                // 🔹 Content based on selected tab
                Expanded(child: _buildCardViewContent(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                     '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : '' }',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.teal,
                            width: 2,
                          ),
                        ),
                        errorText: isCommentError
                            ? 'Comment is required.'
                            : null,
                      ),
                      onChanged: (value) {
                        if (isCommentError && value.trim().isNotEmpty) {
                          setState(() => isCommentError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.closeField();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();
                            if (status != "Approve" && comment.isEmpty) {
                              setState(() => isCommentError = true);
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) =>
                                  const Center(child: SkeletonLoaderPage()),
                            );
                            print(
                              "Sending IDs: ${controller.selectedExpenseIds}",
                            );

                            final success = await controller
                                .postApprovalActionLeavelSheet(
                                  context,
                                  workitemrecid:
                                      controller.selectedTimesheetIds.value,
                                  decision: status,
                                  comment: commentController.text,
                                );

                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.timeSheetPendingDashboard,
                              );
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit action'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardViewContent(BuildContext context) {
    return Obx(() {
      print("isLoadingLeaves => ${controller.isLoadingLeaves.value}");

      if (controller.isLoadingLeaves.value) {
        return const SkeletonLoaderPage();
      }

      if (controller.filteredMyteamSheetPendingApprovals.isEmpty) {
        return const CommonNoDataWidget();
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: controller.filteredMyteamSheetPendingApprovals.length,
        itemBuilder: (ctx, idx) {
          final item = controller.filteredMyteamSheetPendingApprovals[idx];

          return Dismissible(
            key: ValueKey(item.timesheetId),
            background: _buildSwipeActionLeft(isLoading),
            secondaryBackground: _buildSwipeActionRight(),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                setState(() => isLoading = true);
                await controller.fetchSpecificTimesheetApprvalDetails(
                  recId: item.workItemRecId,
                  lockId: item.workItemRecId,
                  context: context,
                  page: "Approvals",
                );

                setState(() => isLoading = false);
                return false;
              }

              if (direction == DismissDirection.endToStart &&
                  item.approvalStatus == "Created") {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.delete),
                    content: Text(
                      '${AppLocalizations.of(context)!.delete} "${item.timesheetId}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  setState(() => isLoading = true);
                  await controller.deleteLeave(item.recId);
                  setState(() => isLoading = false);
                  return true;
                }
              }

              return false;
            },
            child: _buildStyledCard(item, context),
          );
        },
      );
    });
  }

  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.notification),
        ),
        Obx(() {
          final count = controller.unreadNotifications.length;
          if (count == 0) return const SizedBox();
          return Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.personalInfo);
      },
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: controller.isImageLoading.value ? 1.0 : 1.05,
            child: ClipOval(
              child: SizedBox(
                width: 30,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// Avatar / Placeholder
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                      ),
                      child: profileImage.value != null
                          ? Image.file(
                              profileImage.value!,
                              key: ValueKey(profileImage.value!.path),
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white70,
                            ),
                    ),

                    /// Loader Overlay
                    // if (controller.isImageLoading.value)
                    //   Container(
                    //     width: 30,
                    //     height: 30,
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Colors.black.withOpacity(0.35),
                    //     ),
                    //     child: const Center(
                    //       child: SizedBox(
                    //         width: 14,
                    //         height: 14,
                    //         child: CircularProgressIndicator(
                    //           strokeWidth: 2,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeActionLeft(bool isLoading) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.blue.shade100,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          else
            const Icon(Icons.remove_red_eye, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            isLoading ? loc.loading : loc.view,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      alignment: Alignment.centerRight,
      color: const Color.fromARGB(255, 115, 142, 229),
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.delete,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStyledCard(TimesheetModel item, BuildContext context) {
    final controller = Get.put(Controller());
    final int id = item.workItemRecId;

    return Obx(() {
      final selectedIds = controller.selectedTimesheetIds;
      final bool isSelected = selectedIds.contains(id);
      final bool selectionMode = selectedIds.isNotEmpty;

      return InkWell(
        borderRadius: BorderRadius.circular(12),

        onLongPress: () => controller.toggleTimesheetSelection(id),

        onTap: () async {
          if (controller.selectedTimesheetIds.isNotEmpty) {
            controller.toggleTimesheetSelection(id);
          } else {
            await controller.fetchSpecificTimesheetApprvalDetails(
              recId: item.workItemRecId,
              lockId: item.workItemRecId,
              context: context,
              page: "Approvals",
            );
          }
        },

        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: isSelected ? Colors.blue.shade50 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                /// Date top-right
                Positioned(
                  right: 0,
                  top: 0,
                  child: Text(
                    formatDateFromMillis(item.applicationDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                /// Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.timesheetId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${AppLocalizations.of(context)!.employeeId} ${item.employeeId} | '
                      '${AppLocalizations.of(context)!.employeeName}: ${item.employeeName}',
                      style: const TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.approvalStatus,
                        style: TextStyle(
                          color:
                              (item.approvalStatus == 'Cancelled' ||
                                  item.approvalStatus == 'Rejected')
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                
              ],
            ),
          ),
        ),
      );
    });
  }
}
