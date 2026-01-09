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
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

class GeneralExpenseDashboard extends StatefulWidget {
  const GeneralExpenseDashboard({super.key});

  @override
  State<GeneralExpenseDashboard> createState() =>
      _GeneralExpenseDashboardState();
}

class _GeneralExpenseDashboardState extends State<GeneralExpenseDashboard>
    with TickerProviderStateMixin {
  late final Controller controller;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool isLoading = false;
  Rxn<File> profileImage = Rxn<File>();
  bool? showExpense;
  bool? showPerDiem;
  bool? showMileage;
  bool? showCashAdvans;
  final List<String> statusOptions = [
    "Un Reported",
    "Approved",
    "Cancelled",
    "Rejected",
    "In Process",
    "All",
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    loadFuture();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      controller.searchQuery.value = '';
      controller.searchControllerApprovalDashBoard.clear();
      _loadProfileImage();
    });
    _scrollController = ScrollController();

    // Load data
    // controller.loadProfilePictureFromStorage();
    controller.fetchNotifications();
    controller.getPersonalDetails(context);
    controller.fetchMileageRates();
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
      controller.fetchGetallGExpense().then((_) {
        controller.isLoadingGE1.value = false;
      });
    });
  }

  void _loadProfileImage() async {
    //  WidgetsBinding.instance.addPostFrameCallback((_) {
    //    controller.selectedExpenseType = "All Expenses".obs;
    //     controller.selectedStatusDropDown = "Un Reported".obs;
    //     controller.selectedStatus = "Un Reported";});
   
    final prefs = await SharedPreferences.getInstance();
    //  final prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    prefs.setString('selectedMenu', AppLocalizations.of(context)!.myExpenses);
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

  void loadFuture() async {

    showExpense = await controller.isFeatureEnabled('EnableExpense');
    showPerDiem = await controller.isFeatureEnabled('EnablePerdiem');
    print("EnableExpense$showExpense");
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> allButtons = [
      {
        'label': loc.addExpense,
        'icon': Icons.receipt,
        'route': AppRoutes.expenseForm,
        'featureId': 'EnableGeneralExpense', // ← matches API response
      },
      {
        'label': loc.addPerDiem,
        'icon': Icons.food_bank,
        'route': AppRoutes.perDiem,
        'featureId': 'EnablePerdiem',
      },
      {
        'label': loc.addCashAdvanceReturn,
        'icon': Icons.attach_money,
        'route': AppRoutes.cashAdvanceReturnForms,
        'featureId': 'EnableCashAdvanceRequisition',
      },
      {
        'label': loc.addMileage,
        'icon': Icons.directions_car,
        'route': AppRoutes.mileageExpensefirst,
        'featureId': 'EnableMileage',
      },
    ];
    return WillPopScope(
      onWillPop: () async {
        controller.selectedExpenseType = "All Expenses".obs;
        controller.selectedStatusDropDown = "Un Reported".obs;
        controller.selectedStatus = "Un Reported";
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: const MyDrawer(),
        body: 
        LayoutBuilder(
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
                    padding: const EdgeInsets.fromLTRB(6, 40, 6, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _openMenu,
                          icon: Icon(Icons.menu, color: Colors.black, size: 20),
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Like margin-left
                    child: Text(
                      loc.expenseDashboard,
                      style: const TextStyle(
                        // color: AppColors.gradientEnd, // Text color
                        fontSize: 16, // font-size
                        fontWeight: FontWeight.bold, // font-weight: bold
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        // height: 1.2,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 12),

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
                            child: _buildCard(card, isSmallScreen),
                          );
                        },
                      ),
                    );
                  }),
                ),

                // const SizedBox(height: 8),

                // 🔹 Responsive Search Bar
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
                        hintText: loc.searchExpenses,
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

                // 🔹 Add Buttons (Scrollable)
                FutureBuilder<Map<String, bool>>(
                  future: controller.getAllFeatureStates(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 56); // or show loading
                    }

                    final featureStates = snapshot.data!;

                    // Filter buttons: only keep those where feature is enabled
                    final visibleButtons = allButtons.where((btn) {
                      final featureId = btn['featureId'] as String;
                      return featureStates[featureId] == true;
                    }).toList();

                    if (visibleButtons.isEmpty) {
                      return const SizedBox(
                        height: 56,
                      ); // or show "No actions available"
                    }

                    return SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: visibleButtons.length,
                        itemBuilder: (context, index) {
                          final btn = visibleButtons[index];
                          return ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              btn['route'].toString(),
                            ),
                            icon: Icon(
                              btn['icon'] as IconData,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              btn['label'].toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    // ------------------ Status Dropdown ------------------

                    // ------------------ Expense Type Dropdown ------------------
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedExpenseType.value,
                              isExpanded: true,
                              underline: SizedBox(),
                              dropdownColor:
                                  theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              style: TextStyle(
            fontSize: 12,
            // color: theme.colorScheme.secondary, // ACTIVE VALUE COLOR
          ),
                             icon: Icon(
                                Icons.arrow_drop_down,
                                color: theme.colorScheme.primary,
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
                                          color: controller.selectedExpenseType.value == value
                      ? Theme.of(
                                context,
                              ).colorScheme.secondary // ACTIVE DROPDOWN ITEM COLOR
                      : Colors.white, // popup text color
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedStatusDropDown.value,
                              isExpanded: true,
underline: const SizedBox(),
                              dropdownColor: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme
                                    .colorScheme
                                    .secondary, // ACTIVE VALUE COLOR
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: theme.colorScheme.primary,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null &&
                                    newValue != controller.selectedStatus) {
                                  controller.selectedStatus = newValue;
                                  controller.selectedStatusDropDown.value =
                                      newValue;
                                  controller.fetchGetallGExpense();
                                }
                              },
                              items: statusOptions
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
                                          
                                          color: controller.selectedStatusDropDown.value == value
                      ? theme.colorScheme.secondary // ACTIVE DROPDOWN ITEM COLOR
                      : Colors.white, // popup text color
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    print("isLoadingGE1 => ${controller.isLoadingGE1.value}");
                    return controller.isLoadingGE1.value
                        ? const SkeletonLoaderPage()
                        : controller.filteredExpenses.isEmpty
                        ? Center(child: Text(loc.noExpensesFound))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: controller.filteredExpenses.length,
                            itemBuilder: (ctx, idx) {
                              final item = controller.filteredExpenses[idx];

                              return Dismissible(
                                key: ValueKey(item.expenseId),
                                background: _buildSwipeActionLeft(isLoading),
                                secondaryBackground: _buildSwipeActionRight(),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    setState(() => isLoading = true);

                                    if (item.expenseType == "PerDiem") {
                                      await controller.fetchSecificPerDiemItem(
                                        context,
                                        item.recId,
                                        false,
                                      );
                                    } else if (item.expenseType ==
                                        "General Expenses") {
                                      await controller.fetchSecificExpenseItem(
                                        context,
                                        item.recId,
                                        true,
                                      );
                                      controller.fetchExpenseHistory(
                                        item.recId,
                                      );
                                    } else if (item.expenseType == "Mileage") {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.mileageExpense,
                                      );
                                    }

                                    setState(() => isLoading = false);
                                    return false;
                                  } else if (item.approvalStatus == "Created") {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(loc.delete),
                                        content: Text(
                                          '${loc.delete} "${item.expenseId}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: Text(loc.cancel),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Text(loc.delete),
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
                                      return true; // remove item from UI
                                    }

                                    return false;
                                  }
                                  return false;
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
                    if (controller.isImageLoading.value)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.35),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCard(ManageExpensesCard card, bool isSmallScreen) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return Container(
      width: 220,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
      padding: const EdgeInsets.all(10),
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
          Icon(_getIconForStatus(card.status), size: 18, color: Colors.white),
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
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (item.expenseType == "PerDiem") {
          controller.fetchSecificPerDiemItem(context, item.recId, false);
        } else if (item.expenseType == "General Expenses") {
          print("Expenses${item.recId}");
          controller.fetchSecificExpenseItem(context, item.recId, true);
          controller.fetchExpenseHistory(item.recId);
        } else if (item.expenseType == "Mileage") {
          controller.fetchMileageDetails(context, item.recId, true);
        } else if (item.expenseType == "CashAdvanceReturn") {
          controller.fetchSecificCashAdvanceReturn(context, item.recId, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${loc.unknownExpenseType} ${item.expenseType}"),
            ),
          );
        }
      },
      child: Card(
        // color: const Color.fromARGB(218, 245, 244, 244),
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
                    item.expenseId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.receiptDate != null
                        ? DateFormat('dd-MM-yyyy').format(item.receiptDate!)
                        : 'No date',
                    style: const TextStyle(
                      fontSize: 12,
                      // color: Color.fromARGB(255, 41, 41, 41),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Category
              Text(
                item.expenseCategoryId,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
