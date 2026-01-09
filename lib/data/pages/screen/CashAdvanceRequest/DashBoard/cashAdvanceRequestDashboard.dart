import 'dart:convert';
import 'dart:io';
import 'package:digi_xpense/core/comman/Side_Bar/side_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

class CashAdvanceRequestDashboard extends StatefulWidget {
  const CashAdvanceRequestDashboard({super.key});

  @override
  State<CashAdvanceRequestDashboard> createState() =>
      _CashAdvanceRequestDashboardState();
}

class _CashAdvanceRequestDashboardState
    extends State<CashAdvanceRequestDashboard>
    with TickerProviderStateMixin {
  final controllers = Get.put(Controller());
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Rxn<File> profileImage = Rxn<File>();
  double _dragOffset = 0;
  final double _maxDragExtent = 600;
  final Controller controller = Controller();
  List<GExpense> _items = [];
  bool _item1Expanded = true;
  bool _item2Expanded = false;
  bool _showHistory = false;
  // final Controller controller = Controller();
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final List<String> statusOptions = [
    "Un Reported",
    "Approved",
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
                            controller.fetchCashAdvanceRequisitions();
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

  void _loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
   
    prefs.setString('selectedMenu', AppLocalizations.of(context)!.myCashAdvances);
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      // controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _loadDataOnce() async {
    await controller.fetchCashAdvanceRequisitions();
    controller.isEnable.value = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerCashAdvance.clear();
    });
    // controller.loadProfilePictureFromStorage();
    controller.fetchNotifications();
    controller.getPersonalDetails(context);

    controller.fetchAndCombineData().then((_) {
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
    // controller.fetchMileageRates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _dragOffset = MediaQuery.of(context).size.height * 0.3;
      });
    });
    _loadProfileImage();
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
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
        // backgroundColor: const Color(0xFFF7F7F7),
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: const MyDrawer(),
        body: Obx(() {
          return controller.isLoadingGE1.value
              ? const SkeletonLoaderPage()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 600;
                    final theme = Theme.of(context);
                    final primaryColor = theme.primaryColor;
                    return Column(
                      children: [
                        // Top Content in scroll view
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                     if (primaryColor != const Color(0xFF1e4db7) )
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                          padding: const EdgeInsets.fromLTRB(
                                            6,
                                            40,
                                            6,
                                            16,
                                          ),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                ),
                                              ),

                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.asset(
                                                  'assets/XpenseWhite.png',
                                                  width: isSmallScreen
                                                      ? 80
                                                      : 100,
                                                  height: isSmallScreen
                                                      ? 30
                                                      : 40,
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                      ), // Like margin-left
                                      child: Text(
                                        '${loc.myCashAdvances} ${loc.dashboard}',
                                        style: const TextStyle(
                                          // color: AppColors.gradientEnd, // Text color
                                          fontSize: 16, // font-size
                                          fontWeight: FontWeight
                                              .bold, // font-weight: bold
                                          fontFamily: 'Roboto',
                                          letterSpacing: 0.5,
                                          // height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return NotificationListener<
                                      UserScrollNotification
                                    >(
                                      onNotification: (notification) {
                                        // Stop auto-scroll when user starts interacting
                                        if (_animationController.isAnimating) {
                                          _animationController.stop();
                                          print(
                                            "Auto-scroll stopped because user started scrolling",
                                          );
                                        }
                                        _restartAnimationAfterDelay(); // ✅ Restart after delay
                                        return false; // allow the scroll event to continue
                                      },
                                      child: SizedBox(
                                        height: 140,
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(), // ✅ Manual scroll enabled
                                          itemCount: controller
                                              .manageExpensesCards
                                              .length,
                                          itemBuilder: (context, index) {
                                            final card = controller
                                                .manageExpensesCards[index];
                                            return GestureDetector(
                                              onTap: () {
                                                // Stop animation on card tap
                                                if (_animationController
                                                    .isAnimating) {
                                                  _animationController.stop();
                                                  print(
                                                    "Auto-scroll stopped because user tapped a card",
                                                  );
                                                }
                                                _restartAnimationAfterDelay(); // ✅ Restart after delay
                                              },
                                              child: _buildStyledCard(card),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: SizedBox(
                                      width: 300,
                                      height: 48,
                                      child: TextField(
                                        controller: controller
                                            .searchControllerCashAdvance,
                                        onChanged: (value) {
                                          controller.searchQuery.value = value
                                              .toLowerCase();
                                        },
                                        decoration: InputDecoration(
                                          hintText: AppLocalizations.of(
                                            context,
                                          )!.search,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: Colors.grey,
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

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 🔹 Responsive Dropdown Filter
                              Expanded(
                                flex: 3, // Takes 3 parts of available space
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
                                          .selectedStatusDropDown
                                          .value,
                                      isExpanded: true,
                                      underline: Container(),
                                      dropdownColor:
                                          theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                      style: const TextStyle(fontSize: 12),
                                      icon:  Icon(
                                        Icons.arrow_drop_down,
                                        color: Theme.of(
                                context,
                              ).colorScheme.secondary,
                                      ),

                                      onChanged: (String? newValue) {
                                        if (newValue != null &&
                                            newValue !=
                                                controller.selectedStatus) {
                                          // Update both legacy and reactive values for backward compatibility
                                          controller.selectedStatus = newValue;
                                          controller
                                                  .selectedStatusDropDown
                                                  .value =
                                              newValue;
                                          controller
                                              .fetchCashAdvanceRequisitions(); // Refetch with new filter
                                        }
                                      },
                                      items: statusOptions
                                          .map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                 color: controller.selectedStatusDropDown.value == value
                      ? theme.colorScheme.secondary // ACTIVE DROPDOWN ITEM COLOR
                      :Colors.white,  // popup text color
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      hint: const Text(
                                        "Select Status",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ), // Spacing between dropdown and button
                              // 🔹 Add Request Button
                              Expanded(
                                flex:
                                    4, // Takes 2 parts of space (smaller than dropdown)
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.formCashAdvanceRequest,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add_circle,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "${AppLocalizations.of(context)?.cashAdvanceRequest}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue.shade800,
                                    elevation: 4,
                                    shadowColor: Colors.blue.shade900
                                        .withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.50,
                          child: Obx(() {
                            if (controller.isLoadingCA.value) {
                              return const SkeletonLoaderPage();
                            }

                            // Get the full list from controller
                            final List<CashAdvanceRequisition> expenses =
                                controller.cashAdvanceListDashboard;
                            print(
                              "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@111111222r",
                            );

                            // Apply search filter
                            final query = controller.searchQuery.value
                                .toLowerCase()
                                .trim();
                            final filteredExpenses = query.isEmpty
                                ? expenses
                                : expenses.where((item) {
                                    final lowerReqId = item.requisitionId
                                        .toLowerCase();
                                    final lowerEmployeeName = item.employeeName
                                        .toLowerCase();
                                    final lowerStatus = item.approvalStatus
                                        .toLowerCase();

                                    return lowerReqId.contains(query) ||
                                        lowerEmployeeName.contains(query) ||
                                        lowerStatus.contains(query);
                                  }).toList();

                            if (filteredExpenses.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Lottie.asset(
                                    //   'assets/animations/no_data.json', // Place under /assets/animations/
                                    //   width: 200,
                                    //   height: 200,
                                    //   fit: BoxFit.cover,
                                    // ),
                                    const Text(
                                      "No Cash Advances Found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.searchQuery.value.isNotEmpty
                                          ? 'Try a different search'
                                          : 'You have no requests yet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        controller
                                            .fetchCashAdvanceRequisitions();
                                      },
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text("Refresh"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (ctx, idx) {
                                final item = filteredExpenses[idx];

                                return Dismissible(
                                  key: ValueKey(
                                    item.requisitionId,
                                  ), // Unique key per item
                                  background: _buildSwipeActionLeft(
                                    isLoading,
                                  ), // View action (e.g., eye icon)
                                  secondaryBackground:
                                      _buildSwipeActionRight(), // Delete action

                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      // Swipe right → View Details
                                      await _handleViewAction(
                                        controller,
                                        item,
                                        ctx,
                                      );
                                      return false; // Don't remove
                                    } else {
                                      // Swipe left → Delete
                                      return await _showDeleteConfirmation(
                                        ctx,
                                        item,
                                        controller,
                                      );
                                    }
                                  },
                                  child: _buildCard(item, ctx),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    );
                  },
                );
        }),
      ),
    );
  }

  Future<void> _handleViewAction(
    Controller controller,
    CashAdvanceRequisition item,
    BuildContext context,
  ) async {
    // Example navigation based on type (if needed later)
    // For now, just navigate to details page
    // await controller.fetchSpecificCashAdvance(item.recId); // Optional: fetch fresh data

    Navigator.pushNamed(context, AppRoutes.dashboard_Main, arguments: item);
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    CashAdvanceRequisition item,
    Controller controller,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request?'),
        content: Text(
          'Are you sure you want to delete "${item.requisitionId}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isDeleting.value
                  ? null
                  : () async {
                      await controller.deleteCashAdvance(item.recId);
                      Navigator.pop(ctx, true); // Confirm dismissal
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: controller.isDeleting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  Widget circula() {
    return const Center(child: CircularProgressIndicator());
  }

  void _restartAnimationAfterDelay() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!_animationController.isAnimating && mounted) {
        _animationController.repeat(reverse: false);
      }
    });
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

  Widget _buildStyledCard(ManageExpensesCard card) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    return Container(
      width: 200,
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
          Icon(_getIconForStatus(card.status), size: 30, color: Colors.white),
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

Widget _buildCard(CashAdvanceRequisition item, BuildContext context) {
  // print("itemxxx ${item.expenseType}");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${item}");

  final controller = Get.put(Controller());
  return GestureDetector(
    onTap: () {
      controller.fetchSpecificCashAdvanceItem(context, item.recId,true);
      // controller.
      // if (item.expenseType == "PerDiem") {
      //   controller.fetchSecificPerDiemItem(context, item.recId);
      // } else if (item.expenseType == "General Expenses") {
      //   print("Expenses${item.recId}");
      //   controller.fetchSecificExpenseItem(context, item.recId);
      //   controller.fetchExpenseHistory(item.recId);
      // } else if (item.expenseType == "Mileage") {
      //   controller.fetchMileageDetails(context, item.recId);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Unknown expense type: ${item.expenseType}")),
      //   );
      // }
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
                  item.requisitionId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  item.requestDate != null
                      ? DateFormat('dd-MM-yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(item.requestDate),
                        )
                      : 'No date',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 4),

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
                  NumberFormat(
                    '#,##,###',
                  ).format(item.totalRequestedAmountInReporting),
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
