import 'dart:convert';
import 'dart:io';
import 'package:digi_xpense/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

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
  bool isLoading = false;
  final List<String> statusOptionsmyTeam = [
    "In Process",
    "All",
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerCashAdvanceMyteams.clear();
          controller.getProfilePicture();

    });
    _scrollController = ScrollController();

    // Load data
   
    controller.fetchNotifications();
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
                // 🔹 Responsive Header
              if (primaryColor != const Color(0xFF1e4db7) )
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor
                              .withOpacity(0.7), // Lighter primary color
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(6, 40, 6, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                      IconButton(
                    onPressed: _openMenu,
                    icon: Icon(Icons.menu, color: Colors.black, size: 20),
                    // Optional: Add custom background or shape
                    style: IconButton.styleFrom(
                      // backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/XpenseWhite.png',
                            width: isSmallScreen ? 80 : 100,
                            height: isSmallScreen ? 30 : 40,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Actions
                        Row(
                          children: [
                            const LanguageDropdown(),
                            _buildNotificationBadge(),
                            _buildProfileAvatar(),
                          ],
                        ),
                      ],
                    ),
                  ),
             if (primaryColor == const Color(0xFF1e4db7) )
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
                              padding: const EdgeInsets.fromLTRB(6, 40, 6, 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _openMenu,
                                    icon: Icon(
                                      Icons.menu,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    // Optional: Add custom background or shape
                                    style: IconButton.styleFrom(
                                      // backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/XpenseWhite.png',
                                      width: isSmallScreen ? 80 : 100,
                                      height: isSmallScreen ? 30 : 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Actions
                                  Row(
                                    children: [
                                      const LanguageDropdown(),
                                      _buildNotificationBadge(),
                                      _buildProfileAvatar(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0), // Like margin-left
                    child: Text(
                      "My Team Cash Advances",
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
                      return  Center(child: Text(loc.pleaseWait));
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
                            child: _buildCard(card, isSmallScreen),
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
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
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
                    child: Obx(() => DropdownButton<String>(
                          value: controller
                              .selectedStatusDropDownmyteamCashAdvance.value,
                          isExpanded: true,
                          underline: Container(),
                          dropdownColor: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          icon:  Icon(Icons.arrow_drop_down,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary),
                          onChanged: (String? newValue) {
                            if (newValue != null &&
                                newValue !=
                                    controller
                                        .selectedStatusmyteamCashAdvance) {
                              controller.selectedStatusmyteamCashAdvance =
                                  newValue;
                              controller.selectedStatusDropDownmyteamCashAdvance
                                  .value = newValue; // Update reactive value
                              controller
                                  .fetchAllmyTeamsCashAdvanse(); // Refetch data
                            }
                          },
                          items: statusOptionsmyTeam
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              enabled: true,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: controller.selectedStatusDropDownmyteamCashAdvance.value == value
                      ? theme.colorScheme.secondary // ACTIVE DROPDOWN ITEM COLOR
                      : Colors.white, // popup text color
                                ),
                              ),
                            );
                          }).toList(),
                        )),
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
                    final query =
                        controller.searchQuery.value.toLowerCase().trim();
                    final filteredExpenses = query.isEmpty
                        ? expenses
                        : expenses.where((item) {
                            final lowerReqId = item.requisitionId.toLowerCase();
                            final lowerEmployeeName =
                                item.employeeName.toLowerCase();
                            final lowerStatus =
                                item.approvalStatus.toLowerCase();

                            return lowerReqId.contains(query) ||
                                lowerEmployeeName.contains(query) ||
                                lowerStatus.contains(query);
                          }).toList();
                    if (expenses.isEmpty) {
                      return const Center(child: Text("No expenses found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (ctx, idx) {
                        final item = filteredExpenses[idx];

                        return Dismissible(
                          key: ValueKey(item.referenceId),
                          background: _buildSwipeActionLeft(isLoading),
                          secondaryBackground: _buildSwipeActionRight(),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              setState(() => isLoading = true);

                              setState(() => isLoading = false);
                              return false;
                            } else {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete?'),
                                  content:
                                      Text('Delete "${item.referenceId}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                setState(() => isLoading = true);
                                await controller.deleteExpense(item.recId);
                                setState(() => isLoading = false);
                                return true; // This will remove the item from UI
                              }

                              return false;
                            }
                          },
                          child: _buildStyledCard(item, context),
                        );
                      },
                    );
                  }),
                )
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
                    fontWeight: FontWeight.bold),
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
      onTap: () => Navigator.pushNamed(context, AppRoutes.personalInfo),
      child: Obx(() => Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: controller.isImageLoading.value
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : controller.profileImage.value != null
                      ? Image.file(
                          controller.profileImage.value!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          )),
    );
  }

Widget _buildCard(ManageExpensesCard card, bool isSmallScreen) {
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
          _getTitle(card.status),
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
          'Count: ${card.count}',
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

  String _getTitle(String status) {
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
          Text('Delete',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  final controller = Get.put(Controller());

  return GestureDetector(
    onTap: () {
      controller.fetchSpecificCashAdvanceItem(context, item.recId,false);
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
              ],
            ),

            const SizedBox(height: 4),

            // Category
            Text(
              item.expenseCategoryId?.toString() ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // Status and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 110, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.approvalStatus ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  item.totalRequestedAmount?.toString() ?? "",
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

}
