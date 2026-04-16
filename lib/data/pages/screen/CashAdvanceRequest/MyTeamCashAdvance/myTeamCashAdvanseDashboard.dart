import 'dart:convert';
import 'dart:io';
import 'package:diginexa/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:diginexa/core/comman/widgets/languageDropdown.dart';
import 'package:diginexa/core/comman/widgets/noDataFind.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models.dart';
import 'package:diginexa/l10n/app_localizations.dart';

class MyTeamCashAdvanceDashboard extends StatefulWidget {
  const MyTeamCashAdvanceDashboard({super.key});

  @override
  State<MyTeamCashAdvanceDashboard> createState() =>
      _MyTeamCashAdvanceDashboardState();
}

class _MyTeamCashAdvanceDashboardState extends State<MyTeamCashAdvanceDashboard>
    with TickerProviderStateMixin {
  late final Controller controller;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  Rxn<File> profileImage = Rxn<File>();
  bool isLoading = false;
  final List<String> statusOptionsmyTeam = ["In Process", "All"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerCashAdvanceMyteams.clear();
      controller.selectedStatusDropDownmyteamCashAdvance.value = "In Process";
      loadProfileImage();
    });
    _scrollController = ScrollController();

    // Load data

    controller.fetchUnreadNotifications();
    controller.getPersonalDetails(context);
    // controller.fetchMileageRates();
    controller.fetchAndCombineData().then((_) {
      if (controller.manageExpensesCards.isNotEmpty && mounted) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 10),
        );
        _animation =
            Tween<double>(begin: 0, end: 1).animate(_animationController)
              ..addListener(() {
                if (_scrollController.hasClients &&
                    _animationController.isAnimating) {
                  final max = _scrollController.position.maxScrollExtent;
                  _scrollController.jumpTo(_animation.value * max);
                }
              });
        _animationController.repeat();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllmyTeamsCashAdvanse().then((_) {
        controller.isLoadingGE1.value = false;
      });
    });
  }

  void loadProfileImage() async {
    controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
      controller.isImageLoading.value = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Restart animation after user scrolls
  void _onUserScroll() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    });
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: const MyDrawer(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
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
                    padding: EdgeInsets.only(left: 16.0), // Like margin-left
                    child: Text(
                      AppLocalizations.of(context)!.myTeamCashAdvances,
                      style: TextStyle(
                        // color: AppColors.gradientEnd, // Text color
                        fontSize: 20, // font-size
                        fontWeight: FontWeight.bold, // font-weight: bold
                        fontFamily: 'Roboto', // font-family (if used)
                        letterSpacing: 0.5, // letter-spacing
                        // height: 1.2,                          // line-height
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Auto-Scrolling Cards
                SizedBox(
                  height: 140,
                  child: Obx(() {
                    if (controller.manageExpensesCards.isEmpty) {
                      return Center(child: Text(loc.pleaseWait));
                    }
                    return NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (notification.direction == ScrollDirection.idle) {
                          _onUserScroll();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.manageExpensesCards.length,
                        itemBuilder: (context, index) {
                          final card = controller.manageExpensesCards[index];
                          return GestureDetector(
                            onTap: _onUserScroll,
                            child: _buildCard(card, isSmallScreen, context),
                          );
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // 🔹 Responsive Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: controller.searchControllerCashAdvanceMyteams,
                      onChanged: (value) {
                        controller.searchQuery.value = value.toLowerCase();
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Filter Dropdown (Replaces Overlay)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      () => DropdownButton<String>(
                        value: controller
                            .selectedStatusDropDownmyteamCashAdvance
                            .value,
                        isExpanded: true,
                        underline: Container(),
                        dropdownColor: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              newValue !=
                                  controller.selectedStatusmyteamCashAdvance) {
                            controller.selectedStatusmyteamCashAdvance =
                                newValue;
                            controller
                                    .selectedStatusDropDownmyteamCashAdvance
                                    .value =
                                newValue; // Update reactive value
                            controller
                                .fetchAllmyTeamsCashAdvanse(); // Refetch data
                          }
                        },
                        items: statusOptionsmyTeam.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            enabled: true,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    controller
                                            .selectedStatusDropDownmyteamCashAdvance
                                            .value ==
                                        value
                                    ? theme
                                          .colorScheme
                                          .secondary // ACTIVE DROPDOWN ITEM COLOR
                                    : Colors.white, // popup text color
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Expanded(
                  // height: MediaQuery.of(context).size.height * 0.45,
                  child: Obx(() {
                    if (controller.isLoadingGE1.value) {
                      return const SkeletonLoaderPage();
                    }
                    final List<CashAdvanceRequestHeader> expenses =
                        controller.getAllListCashAdvanseMyteams;
                    final query = controller.searchQuery.value
                        .toLowerCase()
                        .trim();
                    final filteredExpenses = query.isEmpty
                        ? expenses
                        : expenses.where((item) {
                            final lowerReqId = item.requisitionId.toLowerCase();
                            final lowerEmployeeName = item.employeeName
                                .toLowerCase();
                            final lowerStatus = item.approvalStatus
                                .toLowerCase();

                            return lowerReqId.contains(query) ||
                                lowerEmployeeName.contains(query) ||
                                lowerStatus.contains(query);
                          }).toList();
                    if (expenses.isEmpty) {
                      return const CommonNoDataWidget();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (ctx, idx) {
                        final item = filteredExpenses[idx];

                        return Dismissible(
                          key: ValueKey(item.referenceId),
                          background: _buildSwipeActionLeft(isLoading),
                          secondaryBackground: _buildSwipeActionLeft(isLoading),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              setState(() => isLoading = true);
                              controller.fetchSpecificCashAdvanceItem(
                                context,
                                item.recId,
                                false,
                              );

                              setState(() => isLoading = false);
                              return false;
                            } else {
                              setState(() => isLoading = true);
                              controller.fetchSpecificCashAdvanceItem(
                                context,
                                item.recId,
                                false,
                              );

                              setState(() => isLoading = false);
                              return false;
                            }
                          },
                          child: _buildStyledCard(item, context),
                        );
                      },
                    );
                  }),
                ),
                // 🔹 Expense List (Flexible height)
              ],
            );
          },
        ),
      ),
    );
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
}

Widget _buildCard(
  ManageExpensesCard card,
  bool isSmallScreen,
  BuildContext context,
) {
  final theme = Theme.of(context);
  final primaryColor = theme.primaryColor;
  final onPrimaryColor = theme.colorScheme.onPrimary;

  return Container(
    width: 220,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          primaryColor.withOpacity(0.8), // Lighter primary color
          primaryColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.topRight,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_getIconForStatus(card.status), size: 28, color: Colors.white),
        const SizedBox(height: 6),
        Text(
          _getTitle(card.status, context),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // ✅ Show count
        Text(
          '${AppLocalizations.of(context)!.count}: ${card.count}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70, // lighter than amount
          ),
        ),

        const SizedBox(height: 4),

        // ✅ Show amount
        Text(
          '₹ ${card.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

IconData _getIconForStatus(String status) {
  switch (status) {
    case 'Approved Expenses (Total)':
      return Icons.check_circle; // ✅
    case 'Expenses In Progress (Total)':
      return Icons.sync; // 🔄
    case 'Approved Advances (Total)':
      return Icons.hourglass_bottom; // ⏳
    case ' Advances In Progress (Total)':
      return Icons.bar_chart; // 📊
    default:
      return Icons.category; // fallback
  }
}

String _getTitle(String status, context) {
  switch (status) {
    case 'Approved Expenses (Total)':
      return AppLocalizations.of(context)!.approvedExpensesTotal;
    case 'Expenses In Progress (Total)':
      return AppLocalizations.of(context)!.expensesInProgressTotal;
    case 'Approved Advances (Total)':
      return AppLocalizations.of(context)!.approvedAdvancesTotal;
    case 'Advances In Progress (Total)':
      return AppLocalizations.of(context)!.advancesInProgressTotal;
    default:
      return status;
  }
}

Widget _buildSwipeActionLeft(bool isLoading) {
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
          isLoading ? 'Loading...' : 'View',
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
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Delete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Icon(Icons.delete, color: Colors.white),
      ],
    ),
  );
}

Widget _buildStyledCard(CashAdvanceRequestHeader item, BuildContext context) {
  final theme = Theme.of(context);
  final primaryColor = theme.primaryColor;
  final onPrimaryColor = theme.colorScheme.onPrimary;
  final controller = Get.find<Controller>();

  return GestureDetector(
    onTap: () {
      controller.fetchSpecificCashAdvanceItem(context, item.recId, false);
    },
    child: Card(
      shadowColor: const Color.fromARGB(255, 82, 78, 78),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.requisitionId ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  item.requestDate != null
                      ? DateFormat('dd-MM-yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(item.requestDate,isUtc: true),
                        )
                      : 'No date',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              '${AppLocalizations.of(context)!.employeeId}: ${item.employeeId} | ${AppLocalizations.of(context)!.employeeName}: ${item.employeeName}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),

            // Status and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 110, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.approvalStatus ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Text(
                  item.totalEstimatedAmountInReporting.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
