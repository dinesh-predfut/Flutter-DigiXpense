import 'dart:convert';
import 'dart:io';

import 'package:diginexa/core/comman/Side_Bar/side_bar.dart';
import 'package:diginexa/core/comman/widgets/languageDropdown.dart';
import 'package:diginexa/core/comman/widgets/noDataFind.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models.dart';

class PendingApprovalDashboard extends StatefulWidget {
  const PendingApprovalDashboard({super.key});

  @override
  State<PendingApprovalDashboard> createState() =>
      _PendingApprovalDashboardState();
}

class _PendingApprovalDashboardState extends State<PendingApprovalDashboard>
    with TickerProviderStateMixin {
  // final controllers = Get.put(Controller());
  bool isLoading = false;
   final controller = Get.find<Controller>();

  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Rxn<File> profileImage = Rxn<File>();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchController.clear();
      controller.selectedExpenseIds.clear();
      controller.selectedExpenseType.value = "All Expenses";
    });
    controller.fetchUnreadNotifications();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataOnce();
      setState(() {
        _dragOffset = MediaQuery.of(context).size.height * 0.3;
      });
    });
    loadProfileImage();
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      // controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
      // controller.isImageLoading.value = false;
    }
  }
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

    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        // controller.selectedExpenseIds.clear();
        return true; // allow back navigation
      },
      child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
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
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    40,
                                    0,
                                    16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                              ),
                                            ),

                                            // Logo
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    40,
                                    0,
                                    16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 4,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                              ),
                                            ),

                                            // Logo
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                              ), // Like margin-left
                              child: Text(
                                loc.pendingApprovals,
                                style: const TextStyle(
                                  // color: AppColors.gradientEnd, // Text color
                                  fontSize: 20, // font-size
                                  fontWeight:
                                      FontWeight.bold, // font-weight: bold
                                  fontFamily: 'Roboto',
                                  letterSpacing: 0.5,
                                  // height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                            child:  _buildStyledCard(card)
                          );
                        },
                      ),
                    );
                  }),
                ),
                          const SizedBox(height: 15),
                          Center(
                            child: SizedBox(
                              width: 300,
                              height: 48,
                              child: TextField(
                                controller: controller.searchController,
                                onChanged: (value) {
                                  controller.searchQuery.value = value
                                      .toLowerCase();
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.searchExpenses,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // ------------------ Status Dropdown ------------------
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16,
                                    left: 16,
                                  ),
                                  child: Obx(() {
                                    final isDisabled =
                                        controller.selectedExpenseIds.isEmpty;

                                    return Container(
                                      height: 47,
                                      width: 140,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDisabled
                                            ? Colors.grey
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primary,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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

                              // ------------------ Expense Type Dropdown ------------------
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16,
                                    left: 16,
                                  ),
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
                                            .selectedExpenseType
                                            .value,
                                        isExpanded: true,
                                        underline: Container(),
                                        dropdownColor:
                                            theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                        style: const TextStyle(fontSize: 12),
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            controller
                                                    .selectedExpenseType
                                                    .value =
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
                                                              .secondary // ACTIVE DROPDOWN ITEM COLOR
                                                        : Colors
                                                              .white, // popup text color
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.47,
                  child: Obx(() {
                    return controller.isLoadingGE1.value
                        ? const SkeletonLoaderPage()
                        : controller.filteredpendingApprovals.isEmpty
                        ? const CommonNoDataWidget()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount:
                                controller.filteredpendingApprovals.length,
                            itemBuilder: (ctx, idx) {
                              final item =
                                  controller.filteredpendingApprovals[idx];

                              return Dismissible(
                                key: ValueKey(item.expenseId),
                                background: _buildSwipeActionLeft(isLoading),
                                secondaryBackground: _buildSwipeActionRight(),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // setState(() => isLoading = true);

                                    if (item.expenseType == "PerDiem") {
                                      controller
                                          .fetchSecificPerDiemItemApproval(
                                            context,
                                            item.workitemrecid,
                                          );
                                    } else if (item.expenseType ==
                                        "General Expenses") {
                                      controller
                                          .fetchSecificApprovalExpenseItem(
                                            context,
                                            item.workitemrecid,
                                          );
                                      controller.fetchExpenseHistory(
                                        item.recId,
                                      );
                                    } else if (item.expenseType == "Mileage") {
                                      // print("Expenses${item.recId}");
                                      controller.fetchMileageDetailsApproval(
                                        context,
                                        item.workitemrecid,
                                        true,
                                      );
                                      // controller.fetchSecificApprovalExpenseItem(context, item.workitemrecid);
                                      // controller.fetchExpenseHistory(item.recId);
                                    }

                                    setState(() => isLoading = false);
                                    return false;
                                  }
                                },
                                child: _buildCard(item, context),
                              );
                            },
                          );
                  }),
                ),
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
                    if (status == "Escalate") ...[
                      Text(
                        '${AppLocalizations.of(context)!.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${AppLocalizations.of(context)!.user} *',
                          columnHeaders: [
                            AppLocalizations.of(context)!.userName,
                            AppLocalizations.of(context)!.userId,
                          ],
                          items: controller.userList,
                          selectedValue: controller.selectedUser.value,
                          searchValue: (user) =>
                              '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(user.userName)),
                                  Expanded(child: Text(user.userId)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ''}',
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

                            final success = await controller.postApprovalAction(
                              context,
                              workitemrecid:
                                  controller.selectedExpenseIds.value,
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
                                AppRoutes.approvalDashboard,
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

  Widget circula() {
    return const Center(child: CircularProgressIndicator());
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
            Color.fromRGBO(41, 41, 102, 0.493),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wallet, color: Colors.white, weight: 70),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
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

void _openExpenseDetails(
  ExpenseModel item,
  BuildContext context,
  Controller controller,
) {
  if (item.expenseType == "PerDiem") {
    controller.fetchSecificPerDiemItemApproval(context, item.workitemrecid);
  } else if (item.expenseType == "General Expenses") {
    controller.fetchSecificApprovalExpenseItem(context, item.workitemrecid);
    controller.fetchExpenseHistory(item.recId);
  } else if (item.expenseType == "Mileage") {
    controller.fetchMileageDetailsApproval(context, item.workitemrecid, true);
  } else if (item.expenseType == "CashAdvanceReturn") {
    controller.fetchSecificCashAdvanceReturnApproval(
      context,
      item.workitemrecid,
      true,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unknown expense type: ${item.expenseType}")),
    );
  }
}

Widget _swipeBg(IconData icon, Alignment align) {
  return Container(
    alignment: align,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: Colors.blue.shade50,
    child: Icon(icon, color: Colors.blue),
  );
}

Widget _buildCard(ExpenseModel item, BuildContext context) {
  final controller = Get.find<Controller>();
  final id = item.workitemrecid;

  return Obx(() {
    final isSelected = controller.selectedExpenseIds.contains(id);

    return Dismissible(
      key: ValueKey('expense_$id'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        _openExpenseDetails(item, context, controller);
        return false; // prevent dismiss
      },
      background: _swipeBg(Icons.arrow_forward, Alignment.centerLeft),
      secondaryBackground: _swipeBg(Icons.arrow_back, Alignment.centerRight),

      child: GestureDetector(
        onLongPress: () => controller.toggleSelectionExpense(id),

        onTap: () {
          if (controller.selectedExpenseIds.isNotEmpty) {
            controller.toggleSelectionExpense(id);
          } else {
            _openExpenseDetails(item, context, controller);
          }
        },

        child: Card(
          color: isSelected ? Colors.blue.shade50 : null,
          shadowColor: const Color.fromARGB(255, 82, 78, 78),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),

          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.expenseId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              item.receiptDate,isUtc: true
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// Category
                    Text(
                      item.expenseCategoryId?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    /// Status + Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.stepType,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 1, 90, 4),
                              fontSize: 12,
                            ),
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

              // /// ✅ Checkbox overlay when selecting
              // if (controller.selectedExpenseIds.isNotEmpty)
              //   Positioned(
              //     top: 8,
              //     right: 8,
              //     child: Checkbox(
              //       value: isSelected,
              //       onChanged: (_) =>
              //           controller.toggleSelectionExpense(id),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  });
}
