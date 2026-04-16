import 'dart:convert';
import 'dart:io';
import 'package:diginexa/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:diginexa/core/comman/widgets/languageDropdown.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/noDataFind.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/models.dart';
import 'package:diginexa/core/constant/Parames/params.dart' show Params;
import 'package:diginexa/data/models.dart'
    show
        ManageExpensesCard,
        GExpense,
        LeaveAnalytics,
        LeaveRequisition,
        LeaveDetailsModel,
        LeaveCancellationModel,
        User,
        Employee,
        LeaveAnalyticsFilter;
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/leaveCalenderView.dart';
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/view_CreateLeave.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class PendingApprovalsLeaveDashboard extends StatefulWidget {
  const PendingApprovalsLeaveDashboard({super.key});

  @override
  State<PendingApprovalsLeaveDashboard> createState() =>
      _PendingApprovalsLeaveDashboardState();
}

class _PendingApprovalsLeaveDashboardState
    extends State<PendingApprovalsLeaveDashboard>
    with TickerProviderStateMixin {
  late final Controller controller;
  // final controller = Get.put(Controller());
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  RxList<LeaveAnalytics> leaveAnalyticsCards = <LeaveAnalytics>[].obs;

  // Tab related variables
  int _selectedTabIndex = 0;
   late final List<String> _tabTitles = [
    AppLocalizations.of(context)!.tableView,
    AppLocalizations.of(context)!.calendarView,
  ];

  // Calendar related variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<LeaveCancellationModel>> _events = {};
  CalendarFormat _viewMode = CalendarFormat.month;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool isLoading = false;
  Rxn<File> profileImage = Rxn<File>();
  bool? showExpense;
  bool? showPerDiem;
  bool? showMileage;
  bool? showCashAdvans;

  Color _colorFromHex(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$cleaned'));
    } catch (e) {
      return Colors.red;
    }
  }

  String formatDateFromMillis(int? millis) {
    if (millis == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(millis,isUtc: true);
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLeaveAnalytics();
      controller.searchQuery.value = '';
      controller.searchControllerApprovalDashBoard.clear();
      controller.selectedLeaveIds.clear();
      controller.fetchUnreadNotifications();
      _loadProfileImage();
      controller.getPersonalDetails(context);
      _initializeCalendarEvents();
      controller.fetchLeaveCodes();
      final range = controller.getMonthRangeEpoch(controller.focusedDay);
      controller.selectedAvailability.value = "All";
      controller.availabilityController.text = "All";
      controller.selectedType.value = "My Leave";
      controller.typeController.text = "My Leave";
      controller.loadCalendarLeaves(
        fromDate: range['from']!,
        toDate: range['to']!,
      );
    });
    _scrollController = ScrollController();

    // Load data
    // controller.loadProfilePictureFromStorage();

    controller.fetchAndCombineData().then((_) {
      if (leaveAnalyticsCards.isNotEmpty && mounted) {
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
      controller.pendingApprovalLeaveRequisitions().then((_) {
        controller.isLoadingLeaves.value = false;
      });
    });
  }

  Future<void> loadLeaveAnalytics() async {
    final result = await controller.fetchLeaveAnalytics(
      Params.employeeId,
      Params.userToken,
    );
    print("resultLeave$result");
    leaveAnalyticsCards.assignAll(result);
  }

  void _initializeCalendarEvents() {
    // Initialize events from controller's leave data
    for (var leave in controller.approvalsfilteredLeaves) {
      if (leave.applicationDate != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(leave.applicationDate,isUtc: true);
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (_events[dateOnly] == null) {
          _events[dateOnly] = [];
        }
        _events[dateOnly]!.add(leave);
      }
    }
  }

  void _loadProfileImage() async {
    controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedMenu', 'Leave Pending Approvals');
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      controller.isImageLoading.value = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        controller.selectedExpenseType = "All Expenses".obs;
        controller.selectedLeaveStatusDropDown = "Un Reported".obs;
        controller.selectedStatus = "Un Reported";
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.selectedLeaveIds.clear();
        });
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
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.pendingApprovals,
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

                // 🔹 Stylish Tabs for Card View and Calendar View
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: List.generate(_tabTitles.length, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == index
                                    ? theme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTabIndex == index
                                    ? [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  _tabTitles[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedTabIndex == index
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Auto-Scrolling Cards (Only show in Card View tab)

                // 🔹 Calendar View Content
                const SizedBox(height: 8),

                // 🔹 Responsive Search Bar (Only show in Card View tab)
                if (_selectedTabIndex == 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller:
                            controller.searchControllerApprovalDashBoard,
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

                  //                 Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Padding(
                  //       padding: const EdgeInsets.only(right: 8.0),
                  //       child: Container(
                  //         width: 200, // 👈 make it small
                  //         height: 50,
                  //         padding: const EdgeInsets.symmetric(horizontal: 12),
                  //         decoration: BoxDecoration(
                  //           color: theme.colorScheme.primary,
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //         child: Obx(
                  //           () => DropdownButton<String>(
                  //             value: controller.selectedLeaveStatusDropDownmyTeam.value,
                  //             isExpanded: true,
                  //             underline: const SizedBox(),
                  //             dropdownColor: theme.colorScheme.primary,
                  //             borderRadius: BorderRadius.circular(8),
                  //             style: TextStyle(
                  //               fontSize: 11,
                  //               color: theme.colorScheme.secondary,
                  //             ),
                  //             icon: Icon(
                  //               Icons.arrow_drop_down,
                  //               color: theme.colorScheme.secondary,
                  //               size: 18,
                  //             ),
                  //             onChanged: (String? newValue) {
                  //               if (newValue != null &&
                  //                   newValue != controller.selectedStatus) {
                  //                 controller.selectedStatus = newValue;
                  //                 controller.selectedLeaveStatusDropDownmyTeam.value = newValue;
                  //                 controller.fetchMyteamsLeaveRequisitions();
                  //               }
                  //             },
                  //             items: statusOptions
                  //                 .map(
                  //                   (value) => DropdownMenuItem<String>(
                  //                     value: value,
                  //                     child: Text(
                  //                       value,
                  //                       overflow: TextOverflow.ellipsis,
                  //                       style: TextStyle(
                  //                         fontSize: 11,
                  //                         color: controller
                  //                                     .selectedLeaveStatusDropDownmyTeam.value ==
                  //                                 value
                  //                             ? theme.colorScheme.secondary
                  //                             : Colors.white,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 )
                  //                 .toList(),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],

                // 🔹 Content based on selected tab
                Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildCardViewContent(context)
                      : _buildCalendarViewContent(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarViewContent(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),

          /// Month Week Day Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFormatButton(
                  AppLocalizations.of(context)!.month,
                  CalendarFormat.month,
                ),
                _buildFormatButton(
                  AppLocalizations.of(context)!.week,
                  CalendarFormat.week,
                ),
                _buildFormatButton(
                  AppLocalizations.of(context)!.day,
                  CalendarFormat.twoWeeks,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Today + Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: _goToToday,
                    child: const Text("Today", style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _openFilterBottomSheet(context),
                    icon: const Icon(Icons.filter_alt_outlined, size: 16),
                    label: const Text("Filter", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// CALENDAR VIEW
          if (_viewMode != CalendarFormat.twoWeeks)
            Container(
              height: 500,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                return Stack(
                  children: [
                    TableCalendar<LeaveDetailsModel>(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2050, 12, 31),
                      focusedDay: controller.focusedDay,
                      calendarFormat: _calendarFormat,

                      eventLoader: (date) {
                        final key = DateTime(date.year, date.month, date.day);
                        return controller.events[key] ?? [];
                      },

                      selectedDayPredicate: (day) {
                        return isSameDay(controller.selectedDay, day);
                      },

                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),

                      calendarStyle: CalendarStyle(
                        markersAlignment: Alignment.bottomCenter,
                        markersMaxCount: 3,

                        todayDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),

                        selectedDecoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                      ),

                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return const SizedBox();

                          final dots = events
                              .take(3)
                              .map((e) => e.leaveColor ?? "#e13333")
                              .toList();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: dots.map((hex) {
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _colorFromHex(hex),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      onDaySelected: (selected, focused) {
                        controller.onDaySelected(selected, focused);
                        setState(() {});

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        });
                      },

                      onPageChanged: (focused) {
                        controller.focusedDay = focused;

                        final range = controller.getMonthRangeEpoch(focused);

                        controller.loadCalendarLeaves(
                          fromDate: range['from']!,
                          toDate: range['to']!,
                        );
                      },
                    ),

                    if (controller.isCalendarLoading.value)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.08),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

          /// DAY VIEW (TODAY CARD)
          if (_viewMode == CalendarFormat.twoWeeks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTodayLeaveCard(),
            ),

          const SizedBox(height: 12),

          /// Bottom Leave List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildBottomList(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _goToToday() {
    final today = DateTime.now();

    controller.focusedDay = today;
    controller.selectedDay = today;

    final range = controller.getMonthRangeEpoch(today);

    controller.loadCalendarLeaves(
      fromDate: range['from']!,
      toDate: range['to']!,
    );

    setState(() {});

    /// Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildTodayLeaveCard() {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);

    final leaves = controller.events[key] ?? [];

    if (leaves.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text("No Leave Today", style: TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    final leave = leaves.first;

    return Card(
      color: Colors.amber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          leave.leaveCode ?? "Leave",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(leave.employeeName ?? ""),
      ),
    );
  }

  void _openFilterBottomSheet(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final controller = Get.find<Controller>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Form(
                      key: controller.filterFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDragHandle(),
                          const SizedBox(height: 16),

                          /// Title
                          Center(
                            child: Text(
                              localizations.filterations,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          _buildDatePickerField(context),
                          // const SizedBox(height: 16),

                          _buildViewTypeDropdown(context, controller),
                          // const SizedBox(height: 16),

                        Obx(
                            () => controller.showEmployeeField.value
                                ? Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      _buildEmployeeMultiSelect(
                                        context,
                                        controller,
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),

                          const SizedBox(height: 16),

                          _buildStatusDropdown(context, controller),

                          const SizedBox(height: 16),

                          _buildLeaveCodeMultiSelect(context, controller),

                          const SizedBox(height: 16),

                          _buildNotifyingUsersMultiSelect(context, controller),

                          const SizedBox(height: 28),

                          _buildActionButtons(context, controller),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    final controller = Get.find<Controller>();

    // ✅ Set default today date if null
    controller.selectedFilterDate.value ??= DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selected Dates *'),
        const SizedBox(height: 6),

        Obx(
          () => TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: controller.selectedFilterDate.value == null
                  ? ''
                  : DateFormat(
                      'dd-MM-yyyy',
                    ).format(controller.selectedFilterDate.value!),
            ),
            decoration: InputDecoration(
              hintText: 'Select date',
              suffixIcon: const Icon(Icons.calendar_today, size: 18),

              // ✅ Border radius 30
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
                initialDate:
                    controller.selectedFilterDate.value ?? DateTime.now(),
              );

              if (date != null) {
                controller.selectedFilterDate.value = date;
              }
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  String _formatDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds,isUtc: true);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildViewTypeDropdown(BuildContext context, Controller controller) {
    final localizations = AppLocalizations.of(context)!;
    final types = [
      "My Leave",
      "My Team Leave",
      "My Branch Leave",
      "My Department Leave",
    ];

    return SearchableMultiColumnDropdownField<String>(
      labelText: localizations.viewType,
      columnHeaders: [localizations.type],
      items: types,
      selectedValue: controller.selectedType.value,
      searchValue: (option) => option,
      displayText: (option) => option,
      onChanged: (option) {
        controller.selectedType.value = option ?? '';
        controller.typeController.text = option ?? '';

        // Update employee field visibility and fetch data
        if (option == "My Branch Leave") {
          controller.showEmployeeField.value = true;
          controller.employeeLabel.value = localizations.branchEmployees;
          controller.scopeFilters = "branch_leaves";
          controller.fetchEmployeesFilter();
        } else if (option == "My Department Leave") {
          controller.showEmployeeField.value = true;
          controller.employeeLabel.value = AppLocalizations.of(
            context,
          )!.departmentEmployees;
          controller.scopeFilters = "department_leaves";
          controller.fetchEmployeesFilter();
        } else if (option == "My Team Leave") {
          controller.showEmployeeField.value = false;
          controller.scopeFilters = "my_team_leaves";
          controller.fetchEmployeesFilter();
        } else {
          controller.showEmployeeField.value = false;
          controller.scopeFilters = "my_leaves";
          controller.fetchEmployeesFilter();
        }
        // Clear previous employee selection when type changes
        controller.selectedEmployeesFilter.clear();
      },
      controller: controller.typeController,
      rowBuilder: (option, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(option),
      ),
    );
  }

  Widget _buildEmployeeMultiSelect(
    BuildContext context,
    Controller controller,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return Obx(() {
      if (controller.isLoadingEmployees.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return MultiSelectMultiColumnDropdownField<LeaveEmployee>(
        labelText: controller.employeeLabel.value,
        columnHeaders: [localizations.employeeId, localizations.employeeName],
        items: controller.employeesFilter,
        selectedValues: controller.selectedEmployeesFilter,
        searchValue: (emp) => "${emp.employeeId} ${emp.employeeName}",
        displayText: (emp) => emp.employeeId,
        controller: controller.employeeController,
        // validator: (values) {
        //   if (controller.selectedEmployeesFilter.isEmpty) {
        //     return  AppLocalizations.of(context)!.empl;
        //   }
        //   return null;
        // },
        onMultiChanged: (items) {
          controller.selectedEmployeesFilter.assignAll(items);
        },
        rowBuilder: (emp, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(emp.employeeId)),
              Expanded(child: Text(emp.employeeName)),
            ],
          ),
        ),
        isMultiSelect: true,
        onChanged: (_) {},
      );
    });
  }

  Widget _buildStatusDropdown(BuildContext context, Controller controller) {
    final localizations = AppLocalizations.of(context)!;
    final statuses = ["All", "Approved", "Pending"];

    return SearchableMultiColumnDropdownField<String>(
      labelText: localizations.status,
      columnHeaders: [localizations.status],
      items: statuses,
      selectedValue: controller.selectedAvailability.value,
      searchValue: (s) => s,
      displayText: (s) => s,
      onChanged: (option) {
        controller.selectedAvailability.value = option ?? '';
        controller.availabilityController.text = option ?? '';
      },
      controller: controller.availabilityController,
      rowBuilder: (option, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(option),
      ),
    );
  }

  Widget _buildLeaveCodeMultiSelect(
    BuildContext context,
    Controller controller,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return MultiSelectMultiColumnDropdownField<LeaveAnalyticsFilter>(
      labelText: '${localizations.leaveCode} *',
      columnHeaders: [localizations.code, localizations.type],
      items: controller.leaveCodesFilter,
      selectedValues: controller.selectedleaveCodesFilter,
      searchValue: (code) => '${code.leaveCode} ${code.leaveType}',
      displayText: (code) => code.leaveCode,
      validator: (values) {
        if (controller.selectedleaveCodesFilter.isEmpty) {
          return '${localizations.leaveCode} ${localizations.fieldRequired}';
        }
        return null;
      },
      onMultiChanged: (items) {
        controller.selectedleaveCodesFilter.assignAll(items);
      },
      controller: controller.leaveCodeController,
      rowBuilder: (code, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(code.leaveCode)),
            Expanded(child: Text(code.leaveType)),
          ],
        ),
      ),
      isMultiSelect: true,
      onChanged: (_) {},
    );
  }

  Widget _buildNotifyingUsersMultiSelect(
    BuildContext context,
    Controller controller,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return MultiSelectMultiColumnDropdownField<LeaveEmployee>(
      labelText: '${localizations.all} ${localizations.employees}',
      items: controller.employeesFilter,
      selectedValues: controller.selectedEmployeesFilter,
      isMultiSelect: true,
      searchValue: (user) => '${user.employeeId} ${user.employeeName}',
      displayText: (user) => user.employeeName,
      validator: (values) {
        if (controller.selectedEmployeesFilter.isEmpty) {
          return '${localizations.notifyingUsers} ${localizations.fieldRequired}';
        }
        return null;
      },
      onMultiChanged: (users) {
        controller.selectedEmployeesFilter.assignAll(users);
      },
      columnHeaders: [localizations.employeeId, localizations.name],
      rowBuilder: (emp, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(emp.employeeId)),
            Expanded(child: Text(emp.employeeName)),
          ],
        ),
      ),
      onChanged: (_) {},
    );
  }

  Widget _buildActionButtons(BuildContext context, Controller controller) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Validate form if needed
              if (controller.filterFormKey.currentState?.validate() ?? true) {
                // Use current month range or selected dates
                final now = DateTime.now();
                final fromDate = DateTime(
                  now.year,
                  now.month,
                  1,
                ).millisecondsSinceEpoch;

                final toDate = DateTime(
                  now.year,
                  now.month + 1,
                  0,
                  23,
                  59,
                  59,
                ).millisecondsSinceEpoch;

                controller.loadCalendarLeaves(
                  fromDate: fromDate,
                  toDate: toDate,
                );
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.filterations),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              controller.resetFilters(); // reset filters
              final now = DateTime.now();
              final fromDate = DateTime(
                now.year,
                now.month,
                1,
              ).millisecondsSinceEpoch;

              final toDate = DateTime(
                now.year,
                now.month + 1,
                0,
                23,
                59,
                59,
              ).millisecondsSinceEpoch;

              controller.loadCalendarLeaves(fromDate: fromDate, toDate: toDate);
              Navigator.pop(context); // close dialog/page
            },
            child: Text(localizations.cancel),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomList() {
    final list = controller.selectedEvents;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '${AppLocalizations.of(context)!.noEventsFor} ${DateFormat('yMMMd').format(controller.selectedDay)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // IMPORTANT
      physics: const NeverScrollableScrollPhysics(), // IMPORTANT
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ev = list[index];

        return GestureDetector(
          onTap: () => _openDetail(ev),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Leave Color Dot
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _colorFromHex(ev.leaveColor ?? '#e13333'),
                    shape: BoxShape.circle,
                  ),
                ),

                /// Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Leave Type
                      Text(
                        ev.leaveCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Employee Name + ID
                      Text(
                        ev.employeeName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "ID: ${ev.employeeId}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Duration Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${ev.duration} day${ev.duration != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Date Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMM d').format(
                        DateTime.fromMillisecondsSinceEpoch(ev.fromDate,isUtc: true),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'to ${DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(ev.toDate,isUtc: true))}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDetail(LeaveDetailsModel ev) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewEditLeavePage(
          leaveRequest: ev,
          isReadOnly: false,
          status: false,
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildFormatButton(String text, CalendarFormat mode) {
    final bool isSelected = _viewMode == mode;

    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _viewMode = mode;

            if (mode == CalendarFormat.month) {
              _calendarFormat = CalendarFormat.month;
            } else if (mode == CalendarFormat.week) {
              _calendarFormat = CalendarFormat.week;
            } else {
              controller.onDaySelected(DateTime.now(), DateTime.now());
            }
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveEventItem(LeaveRequisition leave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _getLeaveColor(leave.leaveCode),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave.leaveCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppLocalizations.of(context)!.duration}: ${leave.duration} ${AppLocalizations.of(context)!.days}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(leave.approvalStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(leave.approvalStatus),
                width: 1,
              ),
            ),
            child: Text(
              leave.approvalStatus,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(leave.approvalStatus),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLeaveColor(String leaveCode) {
    // Map leave codes to colors
    final colorMap = {
      'Annual Leave': Colors.blue,
      'Sick Leave': Colors.green,
      'Maternity Leave': Colors.purple,
      'Paternity Leave': Colors.orange,
      'Study Leave': Colors.teal,
      'Unpaid Leave': Colors.grey,
    };

    return colorMap[leaveCode] ?? Theme.of(context).primaryColor;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = picked;
      });
    }
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Add day headers
    List<String> weekdays = [
      AppLocalizations.of(context)!.mon,
      AppLocalizations.of(context)!.tue,
      AppLocalizations.of(context)!.wed,
      AppLocalizations.of(context)!.thu,
      AppLocalizations.of(context)!.fri,
      AppLocalizations.of(context)!.sat,
      AppLocalizations.of(context)!.sun,
    ];
    for (var day in weekdays) {
      dayWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // Add empty spaces for days before the first day of month
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
      final hasEvents = _events.containsKey(currentDate);
      final isSelected = _selectedDay == currentDate;
      final isToday = currentDate.isAtSameMomentAs(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = currentDate;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue[50]
                  : isToday
                  ? Colors.blue[100]
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.blue[900]
                        : isToday
                        ? Colors.blue[800]
                        : Colors.grey[800],
                  ),
                ),
                if (hasEvents)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: dayWidgets,
    );
  }

  Widget _buildCardViewContent(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      print("isLoadingLeaves => ${controller.isLoadingLeaves.value}");

      if (controller.isLoadingLeaves.value) {
        return const SkeletonLoaderPage();
      }

      if (controller.approvalsfilteredLeaves.isEmpty) {
        return const CommonNoDataWidget();
      }

      return Column(
        children: [
          /// ✅ Bulk Action Dropdown
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
              child: Obx(() {
                final isDisabled = controller.selectedLeaveIds.isEmpty;

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
                      PopupMenuItem(value: "approve", child: Text("Approval")),
                      PopupMenuItem(value: "reject", child: Text("Reject")),
                    ],
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bulk Action",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          /// ✅ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: controller.approvalsfilteredLeaves.length,
              itemBuilder: (ctx, idx) {
                final item = controller.approvalsfilteredLeaves[idx];

                return Dismissible(
                  key: ValueKey(item.leaveCancelId),
                  background: _buildSwipeActionLeft(isLoading),
                  secondaryBackground: _buildSwipeActionRight(),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await controller.fetchSpecificApprovalDetails(
                        context,
                        item.workitemrecid,
                        false,
                        item.leaveCancelId.isEmpty,
                      );
                    }
                    return false;
                  },
                  child: _buildStyledCard(item, context),
                );
              },
            ),
          ),
        ],
      );
    });
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

                            final success = await controller
                                .postApprovalActionLeave(
                                  context,
                                  workitemrecid: controller.selectedLeaveIds,
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
                                AppRoutes.leavePendingApprovals,
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

  Widget _buildStyledCard(LeaveCancellationModel item, BuildContext context) {
    final int id = item.workitemrecid;

    return Obx(() {
      final selectedIds = controller.selectedLeaveIds;
      final bool isSelected = selectedIds.contains(id);
      final bool selectionMode = selectedIds.isNotEmpty;

      return InkWell(
        borderRadius: BorderRadius.circular(12),

        onLongPress: () => controller.toggleLeaveSelection(id),

        onTap: () async {
          if (selectionMode) {
            controller.toggleLeaveSelection(id);
          } else {
            await controller.fetchSpecificApprovalDetails(
              context,
              item.workitemrecid,
              false,
              item.leaveCancelId.isEmpty,
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
                      '${item.leaveCancelId.isEmpty ? item.leaveId : item.leaveCancelId} / ${item.employeeId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.fromDate}: ${_isoDate(item.fromDate)} | ${AppLocalizations.of(context)!.toDate}: ${_isoDate(item.toDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: item.duration != 0.0
                              ? Text(
                                  '${AppLocalizations.of(context)!.noOfDays} ${item.duration}',
                                  style: const TextStyle(fontSize: 12),
                                )
                              : const SizedBox(),
                        ),

                        /// RIGHT STATUS CHIP
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.stepType == 'Review'
                                ? Colors.orange.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.stepType ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: item.stepType == 'Review'
                                  ? Colors.orange
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
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

  String _isoDate(int epoch) {
    return DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(epoch,isUtc: true));
  }
}
