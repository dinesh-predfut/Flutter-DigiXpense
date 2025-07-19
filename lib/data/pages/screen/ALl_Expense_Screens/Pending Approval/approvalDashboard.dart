import 'dart:convert';

import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../../models.dart';

class PendingApprovalDashboard extends StatefulWidget {
  const PendingApprovalDashboard({super.key});

  @override
  State<PendingApprovalDashboard> createState() =>
      _PendingApprovalDashboardState();
}

class _PendingApprovalDashboardState extends State<PendingApprovalDashboard>
    with TickerProviderStateMixin {
  final controllers = Get.put(Controller());
  bool isLoading = false;
  final Controller controller = Controller();
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  double _dragOffset = 0;
  final double _maxDragExtent = 600;
  // final Controller controller = Controller();
  List<GExpense> _items = [];
  bool _item1Expanded = true;
  bool _item2Expanded = false;
  bool _showHistory = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final List<String> statusOptions = [
    "Un Reported",
    "Approval",
    "Cancelled",
    "Rejected",
    "In Process",
    "All",
  ];

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _toggleOverlay(); // dismiss when tapping outside
        },
        child: Stack(
          children: [
            Positioned(
              left: offset.dx + 16,
              top: offset.dy + 280, // adjust as needed
              width: 120,
              height: 300,
              child: GestureDetector(
                // Prevent tap propagation inside the popup
                onTap: () {},
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: statusOptions.length,
                      itemBuilder: (_, index) {
                        final option = statusOptions[index];
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          onTap: () {
                            setState(() {
                              controller.selectedStatus = option;
                              controller.isLoadingGE1.value = false;
                            });
                            controller.fetchPendingApprovals();
                            _toggleOverlay(); // close overlay
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _loadDataOnce() async {
    await controller.fetchPendingApprovals();
    controller.isEnable.value = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
     _scrollController = ScrollController();
    controller.fetchManageExpensesCards().then((_) {
      if (controller.manageExpensesCards.isNotEmpty) {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 10),
        )..repeat(reverse: false);

        _animation =
            Tween<double>(begin: 0, end: 1).animate(_animationController)
              ..addListener(() {
                if (_scrollController.hasClients) {
                  final maxScroll = _scrollController.position.maxScrollExtent;
                  _scrollController.jumpTo(_animation.value * maxScroll);
                }
              });
      }
    });
    setState(() {
      controller.isEnable.value = false;
    });
    print("${controller.isEnable.value}isEnable");
    _loadDataOnce();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _dragOffset = MediaQuery.of(context).size.height * 0.3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return
        // ignore: deprecated_member_use
        WillPopScope(
            onWillPop: () async {
              Navigator.pushNamed(context, AppRoutes.dashboard_Main);
              return true; // allow back navigation
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F7),
              body: Column(
                children: [
                  // Top Content in scroll view
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 130,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 40, 20, 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left side (Welcome text + logo)
                                      Flexible(
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Welcome to',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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

                                      // Right side (Language Dropdown + Bell + Profile)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const LanguageDropdown(),

                                          // ✅ Notification Bell with Badge
                                          Stack(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.notifications,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.notification);
                                                },
                                              ),
                                              // Badge
                                              Obx(() {
                                                final unreadCount = controller
                                                    .unreadNotifications.length;
                                                if (unreadCount == 0)
                                                  return const SizedBox
                                                      .shrink();
                                                return Positioned(
                                                  right: 6,
                                                  top: 6,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 18,
                                                      minHeight: 18,
                                                    ),
                                                    child: Text(
                                                      '$unreadCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),

                                          const SizedBox(width: 10),

                                          // ✅ Profile Picture (Reactive)
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  AppRoutes.personalInfo);
                                            },
                                            child: Obx(() => Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 2),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: controller
                                                            .isImageLoading
                                                            .value
                                                        ? const SizedBox(
                                                            width: 40,
                                                            height: 40,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2,
                                                            ),
                                                          )
                                                        : controller.profileImage
                                                                    .value !=
                                                                null
                                                            ? Image.file(
                                                                controller
                                                                    .profileImage
                                                                    .value!,
                                                                width: 40,
                                                                height: 40,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : const Icon(
                                                                Icons.person,
                                                                size: 40,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Obx(() {
                              return SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // 👈 Disable manual swipe
                                  itemCount:
                                      controller.manageExpensesCards.length,
                                  itemBuilder: (context, index) {
                                    final card =
                                        controller.manageExpensesCards[index];
                                    return _buildStyledCard(card);
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 15),
                            Center(
                              child: SizedBox(
                                width: 300,
                                height: 48,
                                child: TextField(
                                  controller: controller.searchController,
                                  onChanged: (value) {
                                    controller.searchQuery.value =
                                        value.toLowerCase();
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    prefixIcon: const Icon(Icons.search,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: Obx(() {
                      if (controller.isLoadingGE1.value) {
                        return const SkeletonLoaderPage();
                      }

                      final expenses = controller.pendingApprovals;
                      print("expenses$expenses");
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
                                  controller.fetchSecificPerDiemItemApproval(
                                      context, item.workitemrecid);
                                } else if (item.expenseType ==
                                    "General Expenses") {
                                  print("Expenses${item.recId}");
                                  controller.fetchSecificApprovalExpenseItem(
                                      context, item.workitemrecid);
                                  controller.fetchExpenseHistory(item.recId);
                                } else if (item.expenseType == "Mileage") {
                                  print("Expenses${item.recId}");
                                  controller.fetchMileageDetailsApproval(
                                      context, item.workitemrecid);
                                  // controller.fetchSecificApprovalExpenseItem(context, item.workitemrecid);
                                  // controller.fetchExpenseHistory(item.recId);
                                }

                                setState(() => isLoading = false);
                                return false;
                              } else {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete?'),
                                    content:
                                        Text('Delete "${item.expenseId}"?'),
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
                            child: _buildCard(item, context),
                          );
                        },
                      );
                    }),
                  )
                ],
              ),
            ));

  }
 Widget _buildStyledCard(ManageExpensesCard card) {
    return Container(
      width: 180,
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
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForStatus(card.status),
            size: 30,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            _getTitle(card.status),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${card.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
 String _getTitle(String key) {
    switch (key) {
      case 'AmountSettled':
        return ' Total Amount Settled';
      case 'Inprogress':
        return 'Total Advance In Progress';
      case 'Pending':
        return 'Total Amount Pending';
      case 'TotalAmountReporting':
        return 'Total Expenses';
      default:
        return key;
    }
  }
  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'AmountSettled':
        return Icons.check_circle; // ✅
      case 'Inprogress':
        return Icons.sync; // 🔄
      case 'Pending':
        return Icons.hourglass_bottom; // ⏳
      case 'TotalAmountReporting':
        return Icons.bar_chart; // 📊
      default:
        return Icons.category; // fallback
    }
  }
  Widget circula() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // General TextField-like display

  // Example itemized detail block

  Widget _balanceCard(String title, String amount) {
    return Container(
      width: 230,
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(86, 86, 121, 1),
            Color.fromRGBO(41, 41, 102, 1.0),
            Color.fromRGBO(41, 41, 102, 0.493)
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wallet, color: Colors.white, weight: 70),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 5),
          Text(amount,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Icon(Icons.delete, color: Colors.white),
      ],
    ),
  );
}

Widget _buildCard(ExpenseModel item, BuildContext context) {
  print("itemxxx ${item.expenseType}");
  final controller = Get.put(Controller());
  return GestureDetector(
    onTap: () {
      if (item.expenseType == "PerDiem") {
        controller.fetchSecificPerDiemItemApproval(context, item.workitemrecid);
      } else if (item.expenseType == "General Expenses") {
        print("Expenses${item.recId}");
        controller.fetchSecificApprovalExpenseItem(context, item.workitemrecid);
        controller.fetchExpenseHistory(item.recId);
      } else if (item.expenseType == "Mileage") {
        print("Expenses${item.recId}");
        controller.fetchMileageDetailsApproval(context, item.workitemrecid);
        // controller.fetchSecificApprovalExpenseItem(context, item.workitemrecid);
        // controller.fetchExpenseHistory(item.recId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown expense type: ${item.expenseType}")),
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
                  DateFormat('dd-MM-yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(item.receiptDate),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 41, 41, 41),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Category
            Text(
              (item.expenseCategoryId == null)
                  ? ''
                  : item.expenseCategoryId.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // Status and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.stepType,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 1, 90, 4), fontSize: 12),
                  ),
                ),
                Text(
                  '${item.totalAmountReporting}',
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
