import 'dart:convert';
import 'dart:io';
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
  bool isLoading = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerApprovalDashBoard.clear();
     if (controller.profileImage.value == null) {
        controller.getProfilePicture();
      }
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        controller.selectedExpenseType = "All Expenses".obs;
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final theme = Theme.of(context);
            final primaryColor = theme.primaryColor;
            return Column(
              children: [
                if (primaryColor != const Color(0xff1a237e) &&
                    primaryColor.value != 4282339765)
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
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                if (primaryColor == const Color(0xff1a237e) ||
                    primaryColor.value == 4282339765)
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
                    padding: const EdgeInsets.fromLTRB(10, 40, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            children: [
                              // const Text(
                              //   'Welcome to',
                              //   style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 8),
                              // ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/XpenseWhite.png',
                                  width: 100,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const LanguageDropdown(),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.notification);
                                  },
                                ),
                                Obx(() {
                                  final unreadCount =
                                      controller.unreadNotifications.length;
                                  if (unreadCount == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 15,
                                        minHeight: 15,
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, AppRoutes.personalInfo);
  },
  child: Obx(() => AnimatedContainer(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Placeholder or Image
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                  child: controller.isImageLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : controller.profileImage.value != null
                          ? Image.file(
                              controller.profileImage.value!,
                              fit: BoxFit.cover,
                              width: 30,
                              height: 30,
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.white70,
                              ),
                            ),
                ),
                // Overlay shimmer when loading
                if (controller.isImageLoading.value)
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.white10],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                // Edit icon overlay on tap-ready state
               
              ],
            ),
          ),
        ),
      )),
),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0), // Like margin-left
                    child: Text(
                      loc.expenseDashboard,
                      style: const TextStyle(
                        // color: AppColors.gradientEnd, // Text color
                        fontSize: 20, // font-size
                        fontWeight: FontWeight.bold, // font-weight: bold
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        // height: 1.2,
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
                      return const Center(child: Text("No data"));
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
                      controller: controller.searchControllerApprovalDashBoard,
                      onChanged: (value) {
                        controller.searchQuery.value = value.toLowerCase();
                        print(controller.searchController.text);
                      },
                      decoration: InputDecoration(
                        hintText: loc.searchExpenses,
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

                // 🔹 Add Buttons (Scrollable)
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final buttons = [
                        {
                          'label': loc.addExpense,
                          'icon': Icons.receipt,
                          'route': AppRoutes.expenseForm
                        },
                        {
                          'label': loc.addPerDiem,
                          'icon': Icons.food_bank,
                          'route': AppRoutes.perDiem
                        },
                        {
                          'label': loc.addCashAdvanceReturn,
                          'icon': Icons.attach_money,
                          'route': AppRoutes.cashAdvanceReturnForms
                        },
                        {
                          'label': loc.addMileage,
                          'icon': Icons.directions_car,
                          'route': AppRoutes.mileageExpensefirst
                        },
                      ];
                      final btn = buttons[index];
                      return ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, btn['route'].toString()),
                        icon: Icon(btn['icon'] as IconData?,
                            size: 18, color: Colors.white),
                        label: Text(
                          btn['label'].toString(),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E4C92),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // ------------------ Status Dropdown ------------------

                    // ------------------ Expense Type Dropdown ------------------
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Obx(() => DropdownButton<String>(
                                value: controller.selectedExpenseType.value,
                                isExpanded: true,
                                underline: Container(),
                                dropdownColor:
                                    theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                                style: const TextStyle(fontSize: 12),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: theme.colorScheme.primary),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedExpenseType.value =
                                        newValue;
                                  }
                                },
                                items: [
                                  "All Expenses",
                                  "General Expenses",
                                  "PerDiem",
                                  "CashAdvanceReturn",
                                  "Mileage"
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme
                                            .onBackground, // popup text color
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )),
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
                          child: Obx(() => DropdownButton<String>(
                                value: controller.selectedStatusDropDown.value,
                                isExpanded: true,
                                dropdownColor:
                                    theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                                style: const TextStyle(fontSize: 12),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: theme.colorScheme.primary),
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
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    enabled: true,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme
                                            .onBackground, // popup text color
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    print("isLoadingGE1 => ${controller.isLoadingGE1.value}");
                    return controller.isLoadingGE1.value
                        ? const SkeletonLoaderPage()
                        : controller.filteredExpenses.isEmpty
                            ? Center(child: Text(loc.noExpensesFound))
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: controller.filteredExpenses.length,
                                itemBuilder: (ctx, idx) {
                                  final item = controller.filteredExpenses[idx];

                                  return Dismissible(
                                    key: ValueKey(item.expenseId),
                                    background:
                                        _buildSwipeActionLeft(isLoading),
                                    secondaryBackground:
                                        _buildSwipeActionRight(),
                                    confirmDismiss: (direction) async {
                                      if (direction ==
                                          DismissDirection.startToEnd) {
                                        setState(() => isLoading = true);

                                        if (item.expenseType == "PerDiem") {
                                          await controller
                                              .fetchSecificPerDiemItem(
                                                  context, item.recId, false);
                                        } else if (item.expenseType ==
                                            "General Expenses") {
                                          await controller
                                              .fetchSecificExpenseItem(
                                                  context, item.recId, true);
                                          controller
                                              .fetchExpenseHistory(item.recId);
                                        } else if (item.expenseType ==
                                            "Mileage") {
                                          Navigator.pushNamed(context,
                                              AppRoutes.mileageExpense);
                                        }

                                        setState(() => isLoading = false);
                                        return false;
                                      } else if (item.approvalStatus ==
                                          "Created") {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(loc.delete),
                                            content: Text(
                                                '${loc.delete} "${item.expenseId}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(false),
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
                                          await controller
                                              .deleteExpense(item.recId);
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
          Text('Delete',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                content: Text("${loc.unknownExpenseType} ${item.expenseType}")),
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
                  Text(item.expenseId,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    item.receiptDate != null
                        ? DateFormat('dd-MM-yyyy').format(item.receiptDate!)
                        : 'No date',
                    style: const TextStyle(
                        fontSize: 12, color: Color.fromARGB(255, 41, 41, 41)),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Category
              Text(item.expenseCategoryId,
                  style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 6),

              // Status and Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
