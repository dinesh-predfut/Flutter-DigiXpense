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

class MyTeamExpenseDashboard extends StatefulWidget {
  const MyTeamExpenseDashboard({super.key});

  @override
  State<MyTeamExpenseDashboard> createState() => _MyTeamExpenseDashboardState();
}

class _MyTeamExpenseDashboardState extends State<MyTeamExpenseDashboard>
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

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    controller.selectedStatusmyteam = "In Process";
    _scrollController = ScrollController();

    // Load data
    controller.loadProfilePictureFromStorage();
    controller.fetchNotifications();
    controller.getPersonalDetails(context);
    // controller.fetchMileageRates();
    controller.fetchManageExpensesCards().then((_) {
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

    controller.fetchAllmyTeamsExpens().then((_) {
      controller.isLoadingGE1.value = false;
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return Column(
              children: [
                // 🔹 Responsive Header
                Container(
                  width: double.infinity,
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
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0), // Like margin-left
                    child: Text(
                      "My Team Expense Dashboard",
                      style: TextStyle(
                        color: AppColors.gradientEnd, // Text color
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
                      controller: controller.searchController,
                      onChanged: (value) {
                        controller.searchQuery.value = value.toLowerCase();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
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
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() => DropdownButton<String>(
                          value: controller.selectedStatusDropDownmyteam
                              .value, // ← Make sure it's .value for RxString
                          isExpanded: true,
                          underline: Container(), // Removes default underline
                          borderRadius: BorderRadius.circular(10),
                          style: const TextStyle(color: Colors.deepPurple),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.deepPurple),
                          onChanged: (String? newValue) {
                            if (newValue != null &&
                                newValue != controller.selectedStatusmyteam) {
                              controller.selectedStatusmyteam = newValue;
                              controller.selectedStatusDropDownmyteam.value =
                                  newValue; // Update reactive value
                              controller
                                  .fetchAllmyTeamsExpens(); // Refetch data
                            }
                          },
                          items: statusOptionsmyTeam
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              enabled: true,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.black),
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

                    final expenses = controller.getAllListGExpense;
                    final filteredExpenses = expenses.where((item) {
                      final query = controller.searchQuery.value;
                      if (query.isEmpty) return true;
                      return item.expenseType.toLowerCase().contains(query) ||
                          item.expenseType.toLowerCase().contains(query) ||
                          item.expenseId.toLowerCase().contains(query);
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
                          key: ValueKey(item.expenseId),
                          background: _buildSwipeActionLeft(isLoading),
                          secondaryBackground: _buildSwipeActionRight(),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              setState(() => isLoading = true);

                              if (item.expenseType == "PerDiem") {
                                await controller.fetchSecificPerDiemItem(
                                    context, item.recId, true);
                              } else if (item.expenseType ==
                                  "General Expenses") {
                                await controller.fetchSecificExpenseItem(
                                    context, item.recId);
                                controller.fetchExpenseHistory(item.recId);
                              } else if (item.expenseType == "Mileage") {
                                print("Its Call");
                                Navigator.pushNamed(
                                    context, AppRoutes.mileageDetailsPage);
                              }

                              setState(() => isLoading = false);
                              return false;
                            } else {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete?'),
                                  content: Text('Delete "${item.expenseId}"?'),
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
    return Container(
      width: isSmallScreen ? 150 : 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.4),
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
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '₹${card.amount.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'AmountSettled':
        return Icons.check_circle;
      case 'Inprogress':
        return Icons.sync;
      case 'Pending':
        return Icons.hourglass_bottom;
      case 'TotalAmountReporting':
        return Icons.bar_chart;
      default:
        return Icons.category;
    }
  }

  String _getTitle(String key) {
    return {
          'AmountSettled': 'Total Amount Settled',
          'Inprogress': 'Total Advance In Progress',
          'Pending': 'Total Amount Pending',
          'TotalAmountReporting': 'Total Expenses',
        }[key] ??
        key;
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

  Widget _buildStyledCard(GExpense item, BuildContext context) {
    print("itemxxx ${item.expenseType}");
    final controller = Get.put(Controller());
    return GestureDetector(
      onTap: () {
        if (item.expenseType == "PerDiem") {
          controller.fetchSecificPerDiemItem(context, item.recId,true);
          controller.isEditModePerdiem = false;
        } else if (item.expenseType == "General Expenses") {
          print("Expenses${item.recId}");
          controller.fetchSecificExpenseItem(context, item.recId, false);
          controller.fetchExpenseHistory(item.recId);
        } else if (item.expenseType == "Mileage") {
          controller.fetchMileageDetails(context, item.recId);
        } else if (item.expenseType == "CashAdvanceReturn") {
        controller.fetchSecificCashAdvanceReturn(context, item.recId, false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Unknown expense type: ${item.expenseType}")),
          );
        }
      },
      child: Card(
        color: const Color.fromARGB(218, 245, 244, 244),
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
