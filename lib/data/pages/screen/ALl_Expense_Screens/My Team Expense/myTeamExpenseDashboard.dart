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
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syncfusion_flutter_charts/charts.dart'
    show
        SfCircularChart,
        ChartTitle,
        Legend,
        CategoryAxis,
        CartesianSeries,
        MarkerSettings,
        DoughnutSeries,
        DataLabelSettings,
        EdgeLabelPlacement,
        AxisLabelIntersectAction,
        NumericAxis,
        TooltipBehavior,
        LineSeries,
        SfCartesianChart,
        LegendItemOverflowMode,
        LegendPosition;
import '../../../../models.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

class MyTeamExpenseDashboard extends StatefulWidget {
  const MyTeamExpenseDashboard({super.key});

  @override
  State<MyTeamExpenseDashboard> createState() => _MyTeamExpenseDashboardState();
}

class _MyTeamExpenseDashboardState extends State<MyTeamExpenseDashboard>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late final Controller controller;
  late final ScrollController _scrollController;
  late AnimationController? _animationController;
  late Animation<double>? _animation;
  Rxn<File> profileImage = Rxn<File>();
  RxBool isImageLoading = false.obs;

  bool isLoading = false;
  final List<String> statusOptionsmyTeam = ["In Process", "All"];

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerMyteamsExpense.clear();
      controller.fetchNotifications();
      controller.getPersonalDetails(context);
      _loadProfileImage();
    });
    controller.selectedStatusmyteam = "In Process";
    _scrollController = ScrollController();

    // Initialize animation controllers as nullable first
    _animationController = null;
    _animation = null;

    // Load data
    controller.fetchAndCombineData().then((_) {
      if (controller.manageExpensesCards.isNotEmpty && mounted) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 10),
        );
        _animation =
            Tween<double>(begin: 0, end: 1).animate(_animationController!)
              ..addListener(() {
                if (_scrollController.hasClients &&
                    _animationController!.isAnimating) {
                  final max = _scrollController.position.maxScrollExtent;
                  _scrollController.jumpTo(_animation!.value * max);
                }
              });
        _animationController!.repeat();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllmyTeamsExpens().then((_) {
        controller.isLoadingGE1.value = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Restart animation after user scrolls
  void _onUserScroll() {
    if (_animationController?.isAnimating ?? false) {
      _animationController!.stop();
    }
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (!(_animationController?.isAnimating ?? false)) {
        _animationController?.repeat();
      }
    });
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _loadProfileImage() async {
    // isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      // isImageLoading.value = false;
    } else {
      await controller.getProfilePicture();
      final path = prefs.getString('profileImagePath');

      profileImage.value = File(path!);
      // isImageLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        controller.selectedExpenseType = "All Expenses".obs;
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
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

                                  // Logo
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
                             
                        ],
                      ),
                      // Your existing header and content widgets...
                      // Stack(
                      //   children: [
                      //     Container(
                      //       width: double.infinity,
                      //       height: 130,
                      //       decoration: const BoxDecoration(
                      //         image: DecorationImage(
                      //           image: AssetImage('assets/Vector.png'),
                      //           fit: BoxFit.cover,
                      //         ),
                      //         borderRadius: BorderRadius.only(
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10),
                      //         ),
                      //       ),
                      //       padding: const EdgeInsets.fromLTRB(
                      //           10, 40, 20, 20),
                      //       child: Row(
                      //         mainAxisAlignment:
                      //             MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Flexible(
                      //             child: Column(
                      //               children: [
                      //                 const Text(
                      //                   'Welcome to',
                      //                   style: TextStyle(
                      //                       color: Colors.white,
                      //                       fontSize: 8),
                      //                 ),
                      //                 ClipRRect(
                      //                   borderRadius:
                      //                       BorderRadius.circular(20),
                      //                   child: Image.asset(
                      //                     'assets/XpenseWhite.png',
                      //                     width: 100,
                      //                     height: 40,
                      //                     fit: BoxFit.cover,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           const SizedBox(height: 20),
                      //           Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               const LanguageDropdown(),
                      //               Stack(
                      //                 children: [
                      //                   IconButton(
                      //                     icon: const Icon(
                      //                         Icons.notifications,
                      //                         color: Colors.white),
                      //                     onPressed: () {
                      //                       Navigator.pushNamed(context,
                      //                           AppRoutes.notification);
                      //                     },
                      //                   ),
                      //                   Obx(() {
                      //                     final unreadCount = controller
                      //                         .unreadNotifications
                      //                         .length;
                      //                     if (unreadCount == 0) {
                      //                       return const SizedBox
                      //                           .shrink();
                      //                     }
                      //                     return Positioned(
                      //                       right: 6,
                      //                       top: 6,
                      //                       child: Container(
                      //                         padding:
                      //                             const EdgeInsets.all(
                      //                                 4),
                      //                         decoration:
                      //                             const BoxDecoration(
                      //                           color: Colors.red,
                      //                           shape: BoxShape.circle,
                      //                         ),
                      //                         constraints:
                      //                             const BoxConstraints(
                      //                           minWidth: 18,
                      //                           minHeight: 18,
                      //                         ),
                      //                         child: Text(
                      //                           '$unreadCount',
                      //                           style: const TextStyle(
                      //                             color: Colors.white,
                      //                             fontSize: 10,
                      //                             fontWeight:
                      //                                 FontWeight.bold,
                      //                           ),
                      //                           textAlign:
                      //                               TextAlign.center,
                      //                         ),
                      //                       ),
                      //                     );
                      //                   }),
                      //                 ],
                      //               ),
                      //               const SizedBox(width: 10),
                      //               GestureDetector(
                      //                 onTap: () {
                      //                   Navigator.pushNamed(context,
                      //                       AppRoutes.personalInfo);
                      //                 },
                      //                 child: Obx(() => Container(
                      //                       padding:
                      //                           const EdgeInsets.all(2),
                      //                       decoration: BoxDecoration(
                      //                         shape: BoxShape.circle,
                      //                         border: Border.all(
                      //                             color: Colors.white,
                      //                             width: 2),
                      //                       ),
                      //                       child: ClipRRect(
                      //                         borderRadius:
                      //                             BorderRadius.circular(
                      //                                 20),
                      //                         child: controller
                      //                                 .isImageLoading
                      //                                 .value
                      //                             ? const SizedBox(
                      //                                 width: 40,
                      //                                 height: 40,
                      //                                 child:
                      //                                     CircularProgressIndicator(
                      //                                   color: Colors
                      //                                       .white,
                      //                                   strokeWidth: 2,
                      //                                 ),
                      //                               )
                      //                             : controller.profileImage
                      //                                         .value !=
                      //                                     null
                      //                                 ? Image.file(
                      //                                     controller
                      //                                         .profileImage
                      //                                         .value!,
                      //                                     width: 40,
                      //                                     height: 40,
                      //                                     fit: BoxFit
                      //                                         .cover,
                      //                                   )
                      //                                 : const Icon(
                      //                                     Icons.person,
                      //                                     size: 40,
                      //                                     color: Colors
                      //                                         .white,
                      //                                   ),
                      //                       ),
                      //                     )),
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 140,
                        child: Obx(() {
                          if (controller.manageExpensesCards.isEmpty) {
                            return Center(child: Text(loc.pleaseWait));
                          }
                          return NotificationListener<UserScrollNotification>(
                            onNotification: (notification) {
                              if (notification.direction ==
                                  ScrollDirection.idle) {
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
                                final card =
                                    controller.manageExpensesCards[index];
                                return GestureDetector(
                                  onTap: _onUserScroll,
                                  child: _buildCard(card, isSmallScreen),
                                );
                              },
                            ),
                          );
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "My Team Expense Dashboard",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Auto-Scrolling Cards

                      // 🔹 Responsive Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller:
                                controller.searchControllerMyteamsExpense,
                            onChanged: (value) {
                              controller.searchQuery.value = value
                                  .toLowerCase();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search expenses...',
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

                      // 🔹 Dropdown Row - FIXED: Proper use of Expanded
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            // Expense Type Dropdown
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Obx(
                                  () => DropdownButton<String>(
                                    value: controller.selectedExpenseType.value,
                                    isExpanded: true,
                                    underline: Container(),
                                    dropdownColor: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        controller.selectedExpenseType.value =
                                            newValue;
                                      }
                                    },
                                    items:
                                        [
                                          "All Expenses",
                                          "General Expenses",
                                          "PerDiem",
                                          "CashAdvanceReturn",
                                          "Mileage",
                                        ].map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    controller
                                                            .selectedExpenseType
                                                            .value ==
                                                        value
                                                    ? theme
                                                          .colorScheme
                                                          .secondary
                                                    : Colors.white,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Status Dropdown
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Obx(
                                  () => DropdownButton<String>(
                                    value: controller
                                        .selectedStatusDropDownmyteam
                                        .value,
                                    isExpanded: true,
                                    dropdownColor: theme.colorScheme.primary,
                                    underline: Container(),
                                    borderRadius: BorderRadius.circular(10),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    onChanged: (String? newValue) {
                                      if (newValue != null &&
                                          newValue !=
                                              controller.selectedStatusmyteam) {
                                        controller.selectedStatusmyteam =
                                            newValue;
                                        controller
                                                .selectedStatusDropDownmyteam
                                                .value =
                                            newValue;
                                        controller.fetchAllmyTeamsExpens();
                                      }
                                    },
                                    items: statusOptionsmyTeam
                                        .map<DropdownMenuItem<String>>((
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
                                                            .selectedStatusDropDownmyteam
                                                            .value ==
                                                        value
                                                    ? theme
                                                          .colorScheme
                                                          .secondary
                                                    : Colors.white,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Expense List (Flexible height)
                      Expanded(
                        child: Obx(() {
                          return controller.isLoadingGE1.value
                              ? const SkeletonLoaderPage()
                              : controller.filteredExpenses.isEmpty
                              ? const Center(child: Text("No expenses found"))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount: controller.filteredExpenses.length,
                                  itemBuilder: (ctx, idx) {
                                    final item =
                                        controller.filteredExpenses[idx];
                                    return Dismissible(
                                      key: ValueKey(item.expenseId),
                                      background: _buildSwipeActionLeft(
                                        isLoading,
                                      ),
                                      secondaryBackground:
                                          _buildSwipeActionRight(),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          setState(() => isLoading = true);
                                          if (item.expenseType == "PerDiem") {
                                            await controller
                                                .fetchSecificPerDiemItem(
                                                  context,
                                                  item.recId,
                                                  true,
                                                );
                                          } else if (item.expenseType ==
                                              "General Expenses") {
                                            await controller
                                                .fetchSecificExpenseItem(
                                                  context,
                                                  item.recId,
                                                );
                                            controller.fetchExpenseHistory(
                                              item.recId,
                                            );
                                          } else if (item.expenseType ==
                                              "Mileage") {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.mileageDetailsPage,
                                            );
                                          }
                                          setState(() => isLoading = false);
                                          return false;
                                        } else {
                                          final shouldDelete =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Delete?'),
                                                  content: Text(
                                                    'Delete "${item.expenseId}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            ctx,
                                                          ).pop(false),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            ctx,
                                                          ).pop(true),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          if (shouldDelete == true) {
                                            setState(() => isLoading = true);
                                            await controller.deleteExpense(
                                              item.recId,
                                            );
                                            setState(() => isLoading = false);
                                            return true;
                                          }
                                          return false;
                                        }
                                      },
                                      child: _buildStyledCard(item, context),
                                    );
                                  },
                                );
                        }),
                      ),

                      // / Space before the draggable panel
                    ],
                  ),
                ),

                // Title
              ],
            );
          },
        ),
      ),
    );
  }

  // Rest of your helper methods remain the same...
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
      onTap: () => Navigator.pushNamed(context, AppRoutes.personalInfo),
      child: Obx(
        () => Container(
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
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
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
        ),
      ),
    );
  }

  Widget _buildCard(ManageExpensesCard card, bool isSmallScreen) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.8), primaryColor],
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
          Text(
            'Count: ${card.count}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
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
        return Icons.check_circle;
      case 'Expenses In Progress (Total)':
        return Icons.sync;
      case 'Approved Advances (Total)':
        return Icons.hourglass_bottom;
      case 'Advances In Progress (Total)':
        return Icons.bar_chart;
      default:
        return Icons.category;
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

  Widget _loaderBox() {
    return const SizedBox(
      width: 250,
      height: 220,
      child: Center(child: CircularProgressIndicator(color: Colors.green)),
    );
  }

  /// 🔹 Reusable empty state box
  Widget _emptyBox() {
    return const SizedBox(
      width: 250,
      height: 220,
      child: Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  /// 🔹 Chart Widgets (split into methods for clarity)
  Widget _expenseTrendChart(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      // decoration: _boxDecoration(Colors.green.shade50),
      child: SfCartesianChart(
        title: ChartTitle(
          text: loc.myExpenseTrends,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        primaryXAxis: const CategoryAxis(
          labelRotation: 25,
          labelStyle: TextStyle(fontSize: 5),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelIntersectAction: AxisLabelIntersectAction.hide,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 8),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          LineSeries<ProjectData, String>(
            dataSource: controller.chartData,
            xValueMapper: (ProjectData project, _) => project.x,
            yValueMapper: (ProjectData project, _) => project.y,
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _approvalStatusChart(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      // decoration: _boxDecoration(Colors.amber.shade50),
      child: SfCircularChart(
        title: ChartTitle(
          text: loc.myExpenseAmountByApprovalStatus,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        legend: const Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
          textStyle: TextStyle(fontSize: 9),
        ),
        series: <DoughnutSeries<ManageExpensesSummary, String>>[
          DoughnutSeries<ManageExpensesSummary, String>(
            dataSource: controller.manageExpensesSummary,
            xValueMapper: (ManageExpensesSummary data, _) => data.status,
            yValueMapper: (ManageExpensesSummary data, _) => data.amount,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildStyledCard(GExpense item, BuildContext context) {
    final controller = Get.put(Controller());
    return GestureDetector(
      onTap: () {
        if (item.expenseType == "PerDiem") {
          controller.fetchSecificPerDiemItem(context, item.recId, true);
          controller.isEditModePerdiem = false;
        } else if (item.expenseType == "General Expenses") {
          controller.fetchSecificExpenseItem(context, item.recId, false);
          controller.fetchExpenseHistory(item.recId);
        } else if (item.expenseType == "Mileage") {
          controller.fetchMileageDetails(context, item.recId, false);
        } else if (item.expenseType == "CashAdvanceReturn") {
          controller.fetchSecificCashAdvanceReturn(context, item.recId, false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unknown expense type: ${item.expenseType}"),
            ),
          );
        }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.expenseId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.receiptDate != null
                        ? DateFormat('dd-MM-yyyy').format(item.receiptDate!)
                        : 'No date',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 41, 41, 41),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.expenseCategoryId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
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
                      item.approvalStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Text(
                    item.totalAmountReporting.toStringAsFixed(2),
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
