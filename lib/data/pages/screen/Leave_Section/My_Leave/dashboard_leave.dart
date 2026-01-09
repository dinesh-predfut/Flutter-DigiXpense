import 'dart:convert';
import 'dart:io';
import 'package:digi_xpense/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart' show Params;
import 'package:digi_xpense/data/models.dart'
    show
        ManageExpensesCard,
        GExpense,
        LeaveAnalytics,
        LeaveRequisition,
        LeaveDetailsModel,
        Employee;
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/leaveCalenderView.dart';
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/view_CreateLeave.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveDashboard extends StatefulWidget {
  const LeaveDashboard({super.key});

  @override
  State<LeaveDashboard> createState() => _LeaveDashboardState();
}

class _LeaveDashboardState extends State<LeaveDashboard>
    with TickerProviderStateMixin {
  late final Controller controller;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  RxList<LeaveAnalytics> leaveAnalyticsCards = <LeaveAnalytics>[].obs;
  bool isLoading = true;
  // Tab related variables
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['Card View', 'Calendar View'];

  // Calendar related variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<LeaveRequisition>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
  Color _colorFromHex(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('0xFF' + cleaned));
    } catch (e) {
      return Colors.red;
    }
  }

  String formatDateFromMillis(int? millis) {
    if (millis == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    _loadProfileImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerApprovalDashBoard.clear();
      loadLeaveAnalytics();
      _initializeCalendarEvents();
    });
    _scrollController = ScrollController();

    loadEmployee();

    // Load data
    // controller.loadProfilePictureFromStorage();
    controller.loadCalendarLeaves();
    controller.fetchNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPersonalDetails(context);

      controller.fetchLeaveRequisitions().then((_) {
        controller.isLoadingLeaves.value = false;
      });
    });
  }

  Future<void> loadEmployee() async {
    final result = await controller.fetchEmployees();
    print("resultEmployee$result");
    controller.employees.assignAll(result);
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
    for (var leave in controller.filteredLeaves) {
      if (leave.applicationDate != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          leave.applicationDate!,
        );
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (_events[dateOnly] == null) {
          _events[dateOnly] = [];
        }
        _events[dateOnly]!.add(leave);
      }
    }
  }

  void _loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedMenu', 'My Leave');
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
    if ( controller.isLoadingLeaves.value) {
      return const Scaffold(body: Center(child: SkeletonLoaderPage()));
    }
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        controller.selectedExpenseType = "All Expenses".obs;
        controller.selectedLeaveStatusDropDown = "Un Reported".obs;
        controller.selectedStatus = "Un Reported";
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
                if (primaryColor != const Color(0xFF1e4db7))
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, primaryColor.withOpacity(0.7)],
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _openMenu,
                          icon: Icon(Icons.menu, color: Colors.black, size: 20),
                          style: IconButton.styleFrom(
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
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "${AppLocalizations.of(context)!.myLeave} ${AppLocalizations.of(context)!.dashboard}",
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
                if (_selectedTabIndex == 0) ...[
                  SizedBox(
                    height: 100,
                    child: Obx(() {
                      if (controller.isLoadingLeave.value) {
                        return Center(child: Text(loc.pleaseWait));
                      }

                      return NotificationListener<UserScrollNotification>(
                        onNotification: (notification) {
                          if (notification.direction == ScrollDirection.idle) {
                            _onUserScroll();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: leaveAnalyticsCards.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final card = leaveAnalyticsCards[index];
                            return GestureDetector(
                              onTap: _onUserScroll,
                              child: _buildCard(card),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],

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

                  Row(
                    children: [
                      // Status Dropdown
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
                                value: controller
                                    .selectedLeaveStatusDropDown
                                    .value,
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.secondary,
                                ),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: theme.colorScheme.primary,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != controller.selectedStatus) {
                                    controller.selectedStatus = newValue;
                                    controller
                                            .selectedLeaveStatusDropDown
                                            .value =
                                        newValue;
                                    controller.fetchLeaveRequisitions();
                                  }
                                },
                                items: statusOptions.map<DropdownMenuItem<String>>((
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
                                                    .selectedLeaveStatusDropDown
                                                    .value ==
                                                value
                                            ? theme.colorScheme.secondary
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: Text(
                              AppLocalizations.of(context)!.addLeaveRequest,
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.viewLeave,
                                arguments: {
                                  'item': null,
                                  'readOnly': false,
                                  'status': false,
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Calendar Navigation Header
          const SizedBox(height: 12),

          // Calendar Format Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFormatButton('Month', CalendarFormat.month),
                _buildFormatButton('Week', CalendarFormat.week),
                _buildFormatButton('Day', CalendarFormat.twoWeeks),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _openFilterBottomSheet(context),
                    icon: const Icon(Icons.filter_alt_outlined, size: 16),
                    label: const Text('Filter', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Table Calendar Container with Fixed Height
          Container(
            height: 500, // Fixed height for calendar
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Calendar - Takes most of the space
                Expanded(
                  child: TableCalendar<LeaveDetailsModel>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2050, 12, 31),
                    focusedDay: controller.focusedDay,
                    calendarFormat: _calendarFormat,

                    eventLoader: (date) {
                      final key = DateTime(date.year, date.month, date.day);
                      return controller.events[key] ?? [];
                    },
                    selectedDayPredicate: (d) =>
                        isSameDay(d, controller.selectedDay),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    calendarStyle: CalendarStyle(
                      markerDecoration: BoxDecoration(),
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 3,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox.shrink();

                        final dots = events
                            .take(3)
                            .map((e) => (e).leaveColor ?? '#e13333')
                            .toList();

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dots.map((hex) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
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
                    },
                    onPageChanged: (focused) {
                      controller.focusedDay = focused;
                    },
                  ),
                ),

                // Selected Day Events - Only shows when there are events
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildBottomList(),
          ),

          // Add some bottom padding for better scrolling
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.7,
          maxChildSize: 1.0, // 🔥 IMPORTANT
          expand: true,
          builder: (_, scrollController) {
            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Center(
                          child: Text(
                            'Filter Calendar View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const SizedBox(height: 24),

                        _buildDatePickerField(context),
                        const SizedBox(height: 16),
                        SearchableMultiColumnDropdownField<String>(
                          labelText: 'View Type',
                          columnHeaders: [AppLocalizations.of(context)!.type],
                          items: [
                            AppLocalizations.of(context)!.myLeave,
                            AppLocalizations.of(context)!.myTeamLeave,
                            "My Branch Leave ",
                            "My Deportment Leave",
                          ],
                          selectedValue: controller.selectedAvailability.value,
                          searchValue: (option) => option,
                          displayText: (option) => option,
                          validator: (value) {
                            if (value == null ||
                                controller
                                    .availabilityController
                                    .text
                                    .isEmpty) {
                              return '${AppLocalizations.of(context)!.availabilityDuringLeave} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          onChanged: (option) {
                            controller.selectedAvailability.value =
                                option ?? '';
                            controller.availabilityController.text =
                                option ?? '';
                          },
                          controller: controller.availabilityController,
                          rowBuilder: (option, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [Expanded(child: Text(option))],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SearchableMultiColumnDropdownField<String>(
                          labelText:
                              '${AppLocalizations.of(context)!.availabilityDuringLeave}}',
                          columnHeaders: [
                            AppLocalizations.of(context)!.availability,
                          ],
                          items: [
                            AppLocalizations.of(context)!.all,
                            AppLocalizations.of(context)!.approve,
                            "Pending",
                          ],
                          selectedValue: controller.selectedAvailability.value,
                          searchValue: (option) => option,
                          displayText: (option) => option,
                          validator: (value) {
                            if (value == null ||
                                controller
                                    .availabilityController
                                    .text
                                    .isEmpty) {
                              return '${AppLocalizations.of(context)!.availabilityDuringLeave} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          onChanged: (option) {
                            controller.selectedAvailability.value =
                                option ?? '';
                            controller.availabilityController.text =
                                option ?? '';
                          },
                          controller: controller.availabilityController,
                          rowBuilder: (option, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [Expanded(child: Text(option))],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SearchableMultiColumnDropdownField<LeaveAnalytics>(
                          labelText:
                              '${AppLocalizations.of(context)!.leaveCode}*',
                          columnHeaders: [
                            AppLocalizations.of(context)!.code,

                            AppLocalizations.of(context)!.type,
                          ],
                          items: controller.leaveCodes,
                          selectedValue: controller.selectedLeaveCode.value,
                          searchValue: (code) =>
                              '${code.leaveCode} ${code.leaveType}',
                          displayText: (code) => code.leaveCode,
                          validator: (value) {
                            if (controller.leaveCodeController.text.isEmpty) {
                              return '${AppLocalizations.of(context)!.leaveCode} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },

                          onChanged: (code) {
                            controller.selectedLeaveCode.value = code;
                            controller.leaveCodeController.text =
                                code?.leaveCode ?? '';
                          },
                          controller: controller.leaveCodeController,
                          rowBuilder: (code, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(code.leaveCode)),

                                  Expanded(child: Text(code.leaveType)),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        MultiSelectMultiColumnDropdownField<Employee>(
                          labelText:
                              '${AppLocalizations.of(context)!.notifyingUsers}',
                          items: controller.employees,
                          selectedValues: controller.selectedNotifyingUsers,
                          isMultiSelect: true,
                          searchValue: (user) => '${user.id} ${user.firstName}',
                          displayText: (user) => user.firstName,
                          validator: (value) {
                            if (controller.selectedNotifyingUsers.isEmpty) {
                              return '${AppLocalizations.of(context)!.notifyingUsers} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          onMultiChanged: (users) {
                            controller.selectedNotifyingUsers.assignAll(users);
                          },
                          columnHeaders: [
                            AppLocalizations.of(context)!.employeeId,
                            AppLocalizations.of(context)!.name,
                          ],
                          rowBuilder: (emp, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(emp.id)),
                                  Expanded(
                                    child: Text(
                                      '${emp.firstName}${emp.middleName}${emp.firstName}',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onChanged: (Employee? p1) {},
                        ),

                        const SizedBox(height: 24),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // controller.applyCalendarFilters();
                                },
                                child: const Text('Filter'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
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

  Widget _buildDatePickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selected Dates *'),
        const SizedBox(height: 6),

        Obx(
          () => TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: controller.selectedFilterDate.value == null
                  ? 'Select date'
                  : DateFormat(
                      'dd/MM/yyyy',
                    ).format(controller.selectedFilterDate.value!),
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              border: const OutlineInputBorder(),
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
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _colorFromHex(ev.leaveColor ?? '#e13333'),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ev.leaveCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ev.employeeName, // Show employee name instead
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ev.duration} day${ev.duration != 1 ? 's' : ''}', // Show duration
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMM d').format(
                        DateTime.fromMillisecondsSinceEpoch(ev.fromDate),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'to ${DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(ev.toDate))}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18),
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
          isReadOnly: true,
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

  Widget _buildFormatButton(String text, CalendarFormat format) {
    final isSelected = _calendarFormat == format;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _calendarFormat = format;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
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
    return Obx(() {
      print("isLoadingLeaves => ${controller.isLoadingLeaves.value}");

      if (controller.isLoadingLeaves.value) {
        return const SkeletonLoaderPage();
      }

      if (controller.filteredLeaves.isEmpty) {
        return Center(child: Text(AppLocalizations.of(context)!.noLeaveData));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: controller.filteredLeaves.length,
        itemBuilder: (ctx, idx) {
          final item = controller.filteredLeaves[idx];

          return Dismissible(
            key: ValueKey(item.leaveId),
            background: _buildSwipeActionLeft(isLoading),
            secondaryBackground: _buildSwipeActionRight(),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                setState(() => isLoading = true);
                await controller.fetchSpecificLeaveDetails(
                  context,
                  item.recId,
                  true,
                );
                setState(() => isLoading = false);
                return false;
              }

              if (direction == DismissDirection.endToStart &&
                  item.approvalStatus == "Created") {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.delete),
                    content: Text(
                      '${AppLocalizations.of(context)!.delete} "${item.leaveId}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  setState(() => isLoading = true);
                  await controller.deleteLeave(item.recId);
                  setState(() => isLoading = false);
                  return true;
                }
              }

              return false;
            },
            child: _buildStyledCard(item, context),
          );
        },
      );
    });
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

  Widget _buildCard(LeaveAnalytics data) {
    final percent = data.totalLeaves == 0
        ? 0.0
        : (data.leaveBalance / data.totalLeaves).clamp(0.0, 1.0);

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.remaining,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  data.leaveCode,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    hexToColor(data.leaveCodeColor),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.leaveBalance.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.outOf} ${data.totalLeaves}',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
        ],
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

  Widget _buildStyledCard(LeaveRequisition item, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        // 👉 Handle click here
        // Example: Navigate to details page
        await controller.fetchSpecificLeaveDetails(context, item.recId, true);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.leaveId,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No of Days: ${item.duration} | Balance: ${item.leaveBalance}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.approvalStatus,
                      style: TextStyle(
                        color:
                            (item.approvalStatus == 'Cancelled' ||
                                item.approvalStatus == 'Rejected')
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
