import 'dart:convert';
import 'dart:io';
import 'package:digi_xpense/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart' show Params;
import 'package:digi_xpense/data/models.dart'
    show ManageExpensesCard, GExpense, LeaveAnalytics, LeaveRequisition, LeaveTransaction;
import 'package:digi_xpense/data/pages/screen/Leave_Section/leaveCalenderView.dart';
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
  
  // Tab related variables
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['Card View', 'Calendar View'];
  
  // Calendar related variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<LeaveRequisition>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLeaveAnalytics();
      controller.searchQuery.value = '';
      controller.searchControllerApprovalDashBoard.clear();
      _loadProfileImage();
      _initializeCalendarEvents();
    });
    _scrollController = ScrollController();

    // Load data
    // controller.loadProfilePictureFromStorage();
    controller.loadCalendarLeaves();
    controller.fetchNotifications();
    controller.getPersonalDetails(context);
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
      controller.fetchLeaveRequisitions().then((_) {
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
    for (var leave in controller.filteredLeaves) {
      if (leave.applicationDate != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(leave.applicationDate!);
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
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.7),
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
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ),
                    child: Text(
                      "Leave Dashboard",
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
                                          color: theme.primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
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
                      if (leaveAnalyticsCards.isEmpty) {
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
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                                value: controller.selectedLeaveStatusDropDown.value,
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
                                    controller.selectedLeaveStatusDropDown.value =
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
                            label: const Text(
                              'Add Leave Request',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.viewLeave);
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
        Container(
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
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left navigation button
              _buildNavButton(
                icon: Icons.chevron_left,
                onTap: () {
                  setState(() {
                    if (_calendarFormat == CalendarFormat.month) {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    } else if (_calendarFormat == CalendarFormat.week) {
                      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                    } else {
                      _focusedDay = _focusedDay.subtract(const Duration(days: 1));
                    }
                  });
                },
              ),
              
              // Month/Year display
              GestureDetector(
                onTap: () {
                  // Optional: Show date picker for navigation
                  _showDatePicker(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedDay),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              
              // Right navigation button
              _buildNavButton(
                icon: Icons.chevron_right,
                onTap: () {
                  setState(() {
                    if (_calendarFormat == CalendarFormat.month) {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    } else if (_calendarFormat == CalendarFormat.week) {
                      _focusedDay = _focusedDay.add(const Duration(days: 7));
                    } else {
                      _focusedDay = _focusedDay.add(const Duration(days: 1));
                    }
                  });
                },
              ),
            ],
          ),
        ),
        
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
                child: TableCalendar<LeaveTransaction>(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: controller.focusedDay,
                 calendarFormat: _calendarFormat ,
                
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
                        .map(
                          (e) =>
                              (e).leaveColor ?? '#e13333',
                        )
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
  
 Widget _buildBottomList() {
  final list = controller.selectedEvents;

  if (list.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No events for ${DateFormat('yMMMd').format(controller.selectedDay)}',
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
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
              ),
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
                      DateFormat('EEE, MMM d, y')
                          .format(ev.transDate as DateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    },
  );
}

   void _openDetail(LeaveTransaction ev) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeaveDetailPage(transaction: ev)),
    );
  }
  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
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
                  'Duration: ${leave.duration} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
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
        return Center(child: Text("No Leave Data"));
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
                // await controller.fetchSpecificLeaveItem(
                //   context,
                //   item.recId,
                // );
                setState(() => isLoading = false);
                return false;
              }

              if (direction == DismissDirection.endToStart &&
                  item.approvalStatus == "Created") {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.delete),
                    content: Text('${AppLocalizations.of(context)!.delete} "${item.leaveId}"?'),
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
                  // await controller.deleteLeave(item.recId);
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
                : profileImage.value != null
                ? Image.file(
                    profileImage.value!,
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
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
                  'Remaining',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
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
                    'Out of ${data.totalLeaves}',
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

  Widget _buildStyledCard(LeaveRequisition item, BuildContext context) {
    return Card(
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
                  item.leaveCode,
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
                      color: (item.approvalStatus == 'Cancelled' ||
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
    );
  }
}