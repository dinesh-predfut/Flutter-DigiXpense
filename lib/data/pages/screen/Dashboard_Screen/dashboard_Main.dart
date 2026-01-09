import 'dart:async';
import 'dart:io';
import 'package:digi_xpense/core/comman/widgets/chatCard.dart';
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/constant/url.dart' show Urls;
import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constant/Parames/colors.dart';
import '../../../../core/constant/Parames/params.dart';
import '../../../service.dart';
import '../widget/router/router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 100; // Initial height of the draggable panel
  final double _minDragExtent = 100; // Minimum height
  RxBool isImageLoading = false.obs;
  Rxn<File> profileImage = Rxn<File>();
  List<Dashboard> dashboards = [];
  bool loadingDashboards = false;
  Dashboard? selectedDashboard;
  final double _maxDragExtent =
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.height *
      0.7; // Maximum height
  final Controller controller = Controller();
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  // final loc = AppLocalizations.of(context)!;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getDeviceDetails(context);
    controller.fetchAndStoreFeatures(Params.userToken);

    controller.updateFeatureVisibility();
    //  controller.loadDashboards();
    _loadDashboards();
    // controller.initializeWizardConfigs(); // Initialize wizard configs
    _initializeAsync();
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

  Future<void> _initializeAsync() async {
    print("Initialization failed111: ${controller.isDataLoaded.value}");
    if (controller.isDataLoaded.value) return;

    controller.digiSessionId = const Uuid().v4();

    try {
      /// 1️⃣ FIRST: fetch reference / user token (blocking)
      await controller.getPersonalDetails(context); // if this gives token
      await controller.getUserPref(context);
      await controller.fetchAndCombineData().then((_) {
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

      /// 2️⃣ SECOND: parallel API calls (FAST)
      await Future.wait(
        [
              controller.getCashAdvanceAPI(),
              controller.getExpenseList(),
              controller.fetchExpensesByCategory(),
              controller.fetchManageExpensesSummary(),
              controller.fetchExpensesByStatus(),
              controller.fetchExpensesByProjects(),
              controller.fetchAndReplaceValue(),
              controller.fetchNotifications(),
              controller.currencyDropDown(),
              controller.configuration(),
              controller.getAllFeatureStates(),
              registerDevice(),
              _loadProfileImage(),
            ]
            as Iterable<Future>,
      );

      controller.isDataLoaded.value = true;
    } catch (e) {
      debugPrint("Initialization failed: $e");
      controller.isInitialized.value = true;
    }
  }

  void _loadProfileImage() async {
    controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      await controller.getProfilePicture();
      final path = prefs.getString('profileImagePath');

      profileImage.value = File(path!);
      controller.isImageLoading.value = false;
    }
  }
  // void _initializeAsync() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? userToken;

  //   // userToken = prefs.getString('refresh_token');
  //   // if (userToken == null) {
  //   //   await Future.delayed(const Duration(seconds: 2));
  //   // }

  //   // now you are sure userToken is not null

  //   controller.digiSessionId = const Uuid().v4();

  //   // Functions executed without loader

  //   controller.configuration();

  //   registerDevice();
  //   controller.currencyDropDown();

  //   // Show common loader for these API calls
  //   // controller.isUploadingCardsUpdate.value =
  //   //     true; // custom loader function or state, e.g., setState(() => loading = true);
  //   await Future.wait([
  //     controller.getProfilePicture(),
  //     controller.getUserPref(context),
  //     controller.getCashAdvanceAPI(),
  //     controller.getExpenseList(),
  //     controller.fetchExpensesByCategory(),
  //     controller.fetchManageExpensesSummary(),
  //     controller.fetchExpensesByStatus(),
  //     controller.fetchChartData(),
  //     controller.fetchExpensesByProjects(),
  //     controller.fetchAndReplaceValue(),
  //     controller.getPersonalDetails(context),
  //     controller.fetchManageExpensesCards(),

  //     controller.fetchNotifications(),
  //   ]);
  //   // controller.isUploadingCardsUpdate.value = false;

  //   // Animation setup after cards load
  //   if (controller.manageExpensesCards.isNotEmpty) {
  //     _animationController = AnimationController(
  //       vsync: this,
  //       duration: const Duration(seconds: 10),
  //     )..repeat(reverse: false);

  //     _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
  //       ..addListener(() {
  //         if (_scrollController.hasClients) {
  //           final maxScroll = _scrollController.position.maxScrollExtent;
  //           _scrollController.jumpTo(_animation.value * maxScroll);
  //         }
  //       });
  //   }

  //   controller.isInitialized.value = true;
  // }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    const duration = Duration(milliseconds: 100);

    Future.doWhile(() async {
      if (!_scrollController.hasClients) return true;

      final maxScroll = _scrollController.position.maxScrollExtent;

      if (_scrollController.offset >= maxScroll) {
        // 👉 Jump back to the start instantly when at end
        _scrollController.jumpTo(0);
      }

      await _scrollController.animateTo(
        _scrollController.offset + 10, // move 10px forward
        duration: duration,
        curve: Curves.linear,
      );

      return true; // keep looping
    });
  }

  Future<void> registerDevice() async {
    try {
      // Step 1: Get device details
      final details = await getDeviceDetails(context);

      print("📱 Registering device with details: $details");

      // Step 2: Make POST API call
      final response = await http.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/common/pushnotifications/registerdevice',
        ),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        },
        body: jsonEncode(details),
      );

      // Step 3: Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Device registered successfully: $data");
      } else {
        print("❌ Failed to register device. Status: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("🚨 Error registering device: $e");
    }
  }

  Future<void> _loadDashboards() async {
    setState(() => loadingDashboards = true);
    try {
      dashboards = await controller.fetchDashboardWidgets();
      print("ErrorErrordashboards: $dashboards");

      if (dashboards.isNotEmpty) {
        // Find the dashboard where IsDefault == true
        final defaultDash = dashboards.firstWhere(
          (d) => d.isDefault == true,
          orElse: () => dashboards.first, // fallback if none marked default
        );

        controller.selectedDashboard.value = defaultDash;

        await controller.onDashboardChanged(defaultDash);
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load dashboards: $e')));
    } finally {
      setState(() => loadingDashboards = false);
    }
  }

  Future<Map<String, dynamic>> getDeviceDetails(BuildContext context) async {
    print("Fetching device details...");
    final token = await controller.getDeviceToken();
    final platform = controller.getPlatform();
    final deviceId = await controller.getDeviceId();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedMenu', AppLocalizations.of(context)!.dashboard);
    prefs.remove('last_route');
    final details = {
      "DeviceToken": token ?? "N/A",
      "Platform": platform,
      "DeviceId": deviceId ?? "N/A",
      "ProjectId": "test-4aca4",
      "AppIdentifier": "1:681028483669:android:28c51bfa3610b72fee32dc",
    };

    return details;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final List<RoleItem> roles = [
      RoleItem(
        title: "Spenders",
        imagePath: "assets/image 2050.png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Spender"},
          ),
        },
      ),
      RoleItem(
        title: "Line Managers",
        imagePath: "assets/image 2051.png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Line Manager"},
          ),
        },
      ),
      RoleItem(
        title: "Finance Manager",
        imagePath: "assets/image 2050 (1).png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Finance Manager"},
          ),
        },
      ),
      RoleItem(
        title: "Project Manager",
        imagePath: "assets/image 2054.png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Project Manager"},
          ),
        },
      ),
      RoleItem(
        title: "Department Admin",
        imagePath: "assets/image 2054.png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Department Admin"},
          ),
        },
      ),
      RoleItem(
        title: "Branch Admin",
        imagePath: "assets/image 2050.png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Branch Admin"},
          ),
        },
      ),
      RoleItem(
        title: "Admin",
        imagePath: "assets/image 2050.png",
        onTap: () => {
          Navigator.pushNamed(
            context,
            AppRoutes.spanders,
            arguments: {'id': "Admin"},
          ),
        },
      ),
    ];
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
        return false;
      },
      child: Scaffold(
        body: Obx(() {
          return controller.isUploadingCardsUpdate.value
              ? const SkeletonLoaderPage()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 600;
                    final primaryColor = theme.primaryColor;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
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
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                40,
                                16,
                                16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/XpenseWhite.png',
                                      width: isSmallScreen ? 80 : 100,
                                      height: isSmallScreen ? 30 : 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
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
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                40,
                                20,
                                20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const LanguageDropdown(),
                                      Stack(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.notifications,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.notification,
                                              );
                                            },
                                          ),
                                          Obx(() {
                                            final unreadCount = controller
                                                .unreadNotifications
                                                .length;
                                            if (unreadCount == 0) {
                                              return const SizedBox.shrink();
                                            }
                                            return Positioned(
                                              right: 6,
                                              top: 6,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                constraints:
                                                    const BoxConstraints(
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
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.personalInfo,
                                          );
                                        },
                                        child: Obx(
                                          () => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: AnimatedScale(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              scale: controller.isImageLoading.value
                                                  ? 1.0
                                                  : 1.05,
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
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .grey[800],
                                                            ),
                                                        child:
                                                            profileImage
                                                                    .value !=
                                                                null
                                                            ? Image.file(
                                                                profileImage
                                                                    .value!,
                                                                key: ValueKey(
                                                                  profileImage
                                                                      .value!
                                                                      .path,
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : const Icon(
                                                                Icons.person,
                                                                size: 18,
                                                                color: Colors
                                                                    .white70,
                                                              ),
                                                      ),

                                                      /// Loader Overlay
                                                      if (controller.isImageLoading.value)
                                                        Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.35,
                                                                    ),
                                                              ),
                                                          child: const Center(
                                                            child: SizedBox(
                                                              width: 14,
                                                              height: 14,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      Colors
                                                                          .white,
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
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Auto-scrolling Cards Section
                          SizedBox(
                            height: 140,
                            child: Obx(() {
                              if (controller.manageExpensesCards.isEmpty) {
                                return Center(child: Text(loc.pleaseWait));
                              }
                              return NotificationListener<
                                UserScrollNotification
                              >(
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
                                  itemCount:
                                      controller.manageExpensesCards.length,
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
                          const SizedBox(height: 10),

                          // Quick Actions Section
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _mostUsedButton(Icons.money, loc.expense, () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.generalExpense,
                                    );
                                  }),
                                  const SizedBox(width: 20),
                                  _mostUsedButton(
                                    Icons.verified,
                                    loc.approvals,
                                    () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.approvalHubMain,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  _mostUsedButton(Icons.mail, loc.mail, () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.emailHubScreen,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Dashboard Selection and Role Selector
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          loc.myDashboard,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),

                                        // Dashboard Dropdown
                                      ],
                                    ),
                                  ),

                                  // Role Selector
                                  // Role Selector + Dashboard dropdown (inside a Widget with access to controller)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Current Dashboard:',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Obx(() {
                                            final selected = controller
                                                .selectedDashboard
                                                .value;
                                            return DropdownButtonHideUnderline(
                                              child: DropdownButton<Dashboard>(
                                                value: selected,
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                ),
                                                dropdownColor: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                                onChanged: (Dashboard? newDash) {
                                                  if (newDash != null) {
                                                    controller
                                                            .selectedDashboard
                                                            .value =
                                                        newDash;
                                                    controller
                                                        .onDashboardChanged(
                                                          newDash,
                                                        );
                                                  }
                                                },
                                                items: dashboards
                                                    .map(
                                                      (dashboard) =>
                                                          DropdownMenuItem<
                                                            Dashboard
                                                          >(
                                                            value: dashboard,
                                                            child: Text(
                                                              dashboard
                                                                  .dashBoardTitle,
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Widgets Display
                                  Obx(() {
                                    if (controller.isLoadingWidgets.value) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }

                                    final wizards = controller
                                        .getWizardsForCurrentRole();
                                    if (wizards.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Center(
                                          child: Text(
                                            'No widgets available for this role',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      height: 280,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: wizards.map((wizardItem) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              child: _buildDynamicWidget(
                                                wizardItem,
                                                context,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // My Roles Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white, // White background
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.08,
                                    ), // Subtle shadow
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dashboards",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      int columnCount = 2;

                                      if (constraints.maxWidth > 1200) {
                                        columnCount = 4;
                                      } else if (constraints.maxWidth > 800) {
                                        columnCount = 3;
                                      } else if (constraints.maxWidth > 500) {
                                        columnCount = 2;
                                      }

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: roles.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: columnCount,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: 0.82,
                                            ),
                                        itemBuilder: (context, index) {
                                          return RoleCard(item: roles[index]);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        }),
      ),
    );
  }

  Widget _buildDynamicWidget(DashboardDataItem item, BuildContext context) {
    return Container(
      width: 240,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.filterProps?.widgetLabel ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () async {
                    await controller.fetchWidgetDataFromEndpoint(item);
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildWidgetContent(item, context)),
        ],
      ),
    );
  }

  // Build Widget Content
  Widget _buildWidgetContent(DashboardDataItem item, BuildContext context) {
    final data = controller.getWidgetData(item.filterProps?.widgetName ?? "");

    if (data == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await controller.fetchWidgetDataFromEndpoint(item);
          },
          child: const Text('Load Data'),
        ),
      );
    }
    switch (controller.getWidgetType(item.filterProps?.widgetName ?? '')) {
      case 'LineChart':
        return _buildLineChartWidget(item, data);

      case 'BarChart':
        return _buildBarChartWidget(item, data);

      case 'PieChart':
        return _buildPieChartWidget(item, data);

      case 'DonutChart':
        return _buildDonutChartWidget(item, data);

      case 'SummaryBox':
        return _buildSummaryBoxWidget(item, data);

      case 'Table':
        return _buildTable();
      case 'MultiBarChart':
        return _buildMultiBarChart(item, data);
      default:
        return _buildGenericWidgetContent(item, data);
    }
  }

  Widget _buildMultiBarChart(DashboardDataItem item, WidgetDataResponse data) {
    final multiSeries = controller.convertMultiSeriesChart(data!.raw);
    if (multiSeries.isEmpty) {
      return const Center(child: Text("No chart data"));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        legend: Legend(isVisible: true),
        // tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          labelRotation: 25,
          labelStyle: const TextStyle(fontSize: 8),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 9),
        ),
        series: multiSeries,
      ),
    );
  }

  // Line Chart Widget
  Widget _buildLineChartWidget(
    DashboardDataItem item,
    WidgetDataResponse data,
  ) {
    final chartData = _convertToChartDataPoints(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
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

        series: <LineSeries<ChartDataPoint, String>>[
          LineSeries<ChartDataPoint, String>(
            dataSource: chartData,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  // Bar Chart Widget
  Widget _buildBarChartWidget(DashboardDataItem item, WidgetDataResponse data) {
    final chartData = _convertToChartDataPoints(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
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
        series: <ColumnSeries<ChartDataPoint, String>>[
          ColumnSeries<ChartDataPoint, String>(
            dataSource: chartData,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  // Pie Chart Widget
  Widget _buildPieChartWidget(DashboardDataItem item, WidgetDataResponse data) {
    final chartData = _convertToChartDataPoints(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCircularChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          textStyle: const TextStyle(fontSize: 9),
        ),

        series: <PieSeries<ChartDataPoint, String>>[
          PieSeries<ChartDataPoint, String>(
            dataSource: chartData,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,

            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 8), // Reduced label font
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartWidget(
    DashboardDataItem item,
    WidgetDataResponse data,
  ) {
    final chartData = _convertToChartDataPoints(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCircularChart(
        legend: Legend(isVisible: true),
        series: <DoughnutSeries<ChartDataPoint, String>>[
          DoughnutSeries<ChartDataPoint, String>(
            dataSource: chartData,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            explode: true,
            explodeOffset: '10%',
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final headers = [
      "ExpenseId",
      "EmployeeName",
      "ExpenseStatus",
      "ApprovalStatus",
      "TotalAmountTrans",
      "Currency",
      "MerchantName",
      "ExpenseCategoryId",
      "PaymentMethod",
      "ReceiptDate",
      "CreatedDatetime",
    ];

    return Obx(() {
      final list = controller.getAllListGExpense;

      if (list.isEmpty) {
        return const Center(child: Text("No draft expenses found"));
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade300),
            columns: headers
                .map(
                  (h) => DataColumn(
                    label: Text(
                      h,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            rows: list.map<DataRow>((row) {
              final mapRow = row.toMap(); // Convert object to Map

              return DataRow(
                cells: headers.map((h) {
                  var value = mapRow[h];

                  // Format timestamps
                  if ((h == "ReceiptDate" || h == "CreatedDatetime") &&
                      value != null &&
                      value is int) {
                    value = controller.formattedDate(value);
                  }

                  return DataCell(Text(value?.toString() ?? ""));
                }).toList(),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildTableGridWidget(
    DashboardDataItem item,
    WidgetDataResponse data,
  ) {
    // Safely get list of rows
    final list = data.getSeries();

    if (list.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    // Extract headers from first row
    final firstRow = list.first;
    if (firstRow is! Map<String, dynamic>) {
      return const Center(child: Text("Invalid table format"));
    }

    final headers = firstRow.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
            columns: [
              for (final header in headers)
                DataColumn(
                  label: Text(
                    header.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
            rows: list.map<DataRow>((row) {
              if (row is! Map<String, dynamic>) return const DataRow(cells: []);
              return DataRow(
                cells: [
                  for (final h in headers)
                    DataCell(Text(row[h]?.toString() ?? '')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Summary Box Widget
  Widget _buildSummaryBoxWidget(
    DashboardDataItem item,
    WidgetDataResponse data,
  ) {
    final value = data.getSingleValue();
    final formattedValue = NumberFormat.currency(
      symbol: "₹",
      decimalDigits: 0,
    ).format(value);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 38, color: Colors.blue),
          const SizedBox(height: 8),

          Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            item.filterProps?.widgetName ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Generic Widget Content
  Widget _buildGenericWidgetContent(
    DashboardDataItem item,
    WidgetDataResponse data,
  ) {
    final chartData = _convertToChartDataPoints(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Data Points: ${chartData.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (chartData.isNotEmpty)
            Text(
              "Latest: ${chartData.last.y}",
              style: const TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Helper method to convert API response to chart data points
  List<ChartDataPoint> _convertToChartDataPoints(WidgetDataResponse data) {
    final List<ChartDataPoint> points = [];
    final raw = data.raw;

    List<dynamic>? list;

    // CASE 1: raw itself is a List of {x,y}
    if (raw is List) {
      list = raw;
    }
    // CASE 2: raw is a Map
    else if (raw is Map<String, dynamic>) {
      // CASE 2a: XAxis + YAxis format
      if (raw['XAxis'] is List && raw['YAxis'] is List) {
        final xAxis = List<String>.from(raw['XAxis']);
        final yAxisRaw = raw['YAxis'] as List;

        for (int i = 0; i < xAxis.length; i++) {
          if (i < yAxisRaw.length) {
            final yValue = yAxisRaw[i];
            double y = 0.0;
            if (yValue is num) {
              y = yValue.toDouble();
            } else if (yValue is String) {
              y = double.tryParse(yValue) ?? 0.0;
            } else if (yValue is Map && yValue.containsKey('y')) {
              final val = yValue['y'];
              y = (val is num)
                  ? val.toDouble()
                  : double.tryParse(val.toString()) ?? 0.0;
            }
            points.add(ChartDataPoint(x: xAxis[i], y: y));
          }
        }
        return points;
      }

      // CASE 2b: raw['data'] is a List
      if (raw['data'] is List)
        list = raw['data'];
      // CASE 2c: raw['value'] is a List
      else if (raw['value'] is List)
        list = raw['value'];
      // CASE 2d: raw['value']['data'] is a List
      else if (raw['value'] is Map && raw['value']['data'] is List) {
        list = raw['value']['data'];
      }
    }

    // If we have a list, parse it
    if (list != null) {
      for (var item in list) {
        if (item is Map) {
          final xValue = item['x'] ?? item['label'] ?? item['category'] ?? '';
          final yRaw = item['y'] ?? item['value'] ?? item['amount'] ?? 0;
          double yValue = 0.0;

          if (yRaw is num)
            yValue = yRaw.toDouble();
          else if (yRaw is String)
            yValue = double.tryParse(yRaw) ?? 0.0;

          if (xValue != '') {
            points.add(ChartDataPoint(x: xValue.toString(), y: yValue));
          }
        }
      }
    }

    return points;
  }

  // Widget _buildDashboardSection(BuildContext context, AppLocalizations loc) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Container(
  //       height: 320,
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).colorScheme.secondary,
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(12.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   loc.myDashboard,
  //                   style: const TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 // Current role indicator
  //                 Obx(() {
  //                   return Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     child: Text(
  //                       controller.currentRole.value,
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   );
  //                 }),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: Obx(() {
  //               if (controller.isLoadingWidgets.value) {
  //                 return const Center(
  //                   child: CircularProgressIndicator(color: Colors.white),
  //                 );
  //               }

  //               // final wizards = controller.getWizardsForCurrentRole();
  //               // if (wizards.isEmpty) {
  //               //   return Center(
  //               //     child: Text(
  //               //       'No widgets available for ${controller.currentRole.value}',
  //               //       style: const TextStyle(color: Colors.white70),
  //               //     ),
  //               //   );
  //               // }

  //               return SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: Row(
  //                   children: wizards.map((wizard) {
  //                     return _renderDynamicWidget(wizard, context);
  //                   }).toList(),
  //                 ),
  //               );
  //             }),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // // Dynamic widget renderer
  // Widget _renderDynamicWidget(WizardConfig wizard, BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Container(
  //       width: 260,
  //       height: 240,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           // Widget header
  //           Padding(
  //             padding: const EdgeInsets.all(12.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     wizard.displayName,
  //                     style: const TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.refresh, size: 18),
  //                   onPressed: () async {
  //                     await controller.fetchWidgetData(wizard);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           // Widget content
  //           Expanded(
  //             child: _buildWidgetContent(wizard, context),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // // Build widget content based on type
  // Widget _buildWidgetContent(WizardConfig wizard, BuildContext context) {
  //   final data = controller.getWidgetData(wizard.widgetName);

  //   if (data == null) {
  //     return Center(
  //       child: ElevatedButton(
  //         onPressed: () async {
  //           await controller.fetchWidgetData(wizard);
  //         },
  //         child: const Text('Load Data'),
  //       ),
  //     );
  //   }

  //   switch (wizard.wizardType) {
  //     case 'Line Chart Wizard':
  //       return _buildLineChart(wizard, data);
  //     case 'Bar Chart Wizard':
  //       return _buildBarChart(wizard, data);
  //     case 'Pie Chart Wizard':
  //       return _buildPieChart(wizard, data);
  //     case 'Summary Box Wizard':
  //       return _buildSummaryBox(wizard, data);
  //     default:
  //       return _buildGenericChart(wizard, data);
  //   }
  // }

  // // Line Chart Widget
  // Widget _buildLineChart(WizardConfig wizard, WidgetDataResponse data) {
  //   final chartData = data.toChartDataPoints();

  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: SfCartesianChart(
  //       primaryXAxis: CategoryAxis(
  //         labelRotation: 45,
  //         labelStyle: const TextStyle(fontSize: 9),
  //       ),
  //       primaryYAxis: NumericAxis(
  //         numberFormat: NumberFormat.compact(),
  //         labelStyle: const TextStyle(fontSize: 9),
  //       ),
  //       series: <LineSeries<ChartDataPoint, String>>[
  //         LineSeries<ChartDataPoint, String>(
  //           dataSource: chartData,
  //           xValueMapper: (ChartDataPoint point, _) => point.x,
  //           yValueMapper: (ChartDataPoint point, _) => point.y,
  //           markerSettings: const MarkerSettings(isVisible: true),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // Bar Chart Widget
  // Widget _buildBarChart(WizardConfig wizard, WidgetDataResponse data) {
  //   final chartData = data.toChartDataPoints();

  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: SfCartesianChart(
  //       primaryXAxis: CategoryAxis(
  //         labelRotation: 45,
  //         labelStyle: const TextStyle(fontSize: 9),
  //       ),
  //       primaryYAxis: NumericAxis(
  //         numberFormat: NumberFormat.compact(),
  //         labelStyle: const TextStyle(fontSize: 9),
  //       ),
  //       series: <ColumnSeries<ChartDataPoint, String>>[
  //         ColumnSeries<ChartDataPoint, String>(
  //           dataSource: chartData,
  //           xValueMapper: (ChartDataPoint point, _) => point.x,
  //           yValueMapper: (ChartDataPoint point, _) => point.y,
  //           dataLabelSettings: const DataLabelSettings(isVisible: true),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // Pie Chart Widget
  // Widget _buildPieChart(WizardConfig wizard, WidgetDataResponse data) {
  //   final chartData = data.toChartDataPoints();

  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: SfCircularChart(
  //       series: <PieSeries<ChartDataPoint, String>>[
  //         PieSeries<ChartDataPoint, String>(
  //           dataSource: chartData,
  //           xValueMapper: (ChartDataPoint point, _) => point.x,
  //           yValueMapper: (ChartDataPoint point, _) => point.y,
  //           dataLabelSettings: const DataLabelSettings(isVisible: true),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Summary Box Widget
  Widget _buildSummaryBox(WizardConfig wizard, WidgetDataResponse data) {
    final value = data.getSingleValue();
    final formattedValue = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForWidget(wizard.widgetName),
            size: 40,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wizard.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // // Generic Chart Widget
  // Widget _buildGenericChart(WizardConfig wizard, WidgetDataResponse data) {
  //   final chartData = data.toChartDataPoints();

  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           'Data Points: ${chartData.length}',
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         if (chartData.isNotEmpty)
  //           Text(
  //             'Latest: ${chartData.last.y}',
  //             style: const TextStyle(fontSize: 12, color: Colors.grey),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Helper function to get icon for widget
  IconData _getIconForWidget(String widgetName) {
    if (widgetName.toLowerCase().contains('expense')) {
      return Icons.currency_rupee;
    } else if (widgetName.toLowerCase().contains('cash')) {
      return Icons.account_balance_wallet;
    } else if (widgetName.toLowerCase().contains('leave')) {
      return Icons.calendar_today;
    } else if (widgetName.toLowerCase().contains('approval')) {
      return Icons.check_circle;
    }
    return Icons.assessment;
  }

  // Auto-scrolling cards section
  Widget _buildAutoScrollCards(AppLocalizations loc) {
    return SizedBox(
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
                child: _buildCard(card, false),
              );
            },
          ),
        );
      }),
    );
  }

  // Quick actions section
  Widget _buildQuickActions(AppLocalizations loc) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _mostUsedButton(
              Icons.money,
              loc.expense,
              () => Navigator.pushNamed(context, AppRoutes.generalExpense),
            ),
            const SizedBox(width: 20),
            _mostUsedButton(
              Icons.verified,
              loc.approvals,
              () => Navigator.pushNamed(context, AppRoutes.approvalHubMain),
            ),
            const SizedBox(width: 20),
            _mostUsedButton(
              Icons.mail,
              loc.mail,
              () => Navigator.pushNamed(context, AppRoutes.emailHubScreen),
            ),
          ],
        ),
      ),
    );
  }

  // My Roles section
  // Widget _buildRolesSection() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "My Roles",
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w700,
  //             color: Theme.of(context).primaryColorDark,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         LayoutBuilder(
  //           builder: (context, constraints) {
  //             int columnCount = 2;
  //             if (constraints.maxWidth > 1200)
  //               columnCount = 4;
  //             else if (constraints.maxWidth > 800)
  //               columnCount = 3;
  //             else if (constraints.maxWidth > 500)
  //               columnCount = 2;

  //             return GridView.builder(
  //               shrinkWrap: true,
  //               physics: const NeverScrollableScrollPhysics(),
  //               itemCount: roles.length,
  //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                 crossAxisCount: columnCount,
  //                 crossAxisSpacing: 16,
  //                 mainAxisSpacing: 16,
  //                 childAspectRatio: 0.82,
  //               ),
  //               itemBuilder: (context, index) => RoleCard(item: roles[index]),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  void _restartAnimationAfterDelay() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!_animationController.isAnimating && mounted) {
        _animationController.repeat(reverse: false);
      }
    });
  }

  // Rest of your helper methods (_balanceCard, _mostUsedButton, _transactionList) remain the same...

  Widget _mostUsedButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min, // ✅ makes width auto
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionList() {
    final loc = AppLocalizations.of(context)!;
    return Obx(() {
      return ListView(
        children: [
          // 🔹 Section 1: Cash Advance

          // 🔹 Section 2: Expense
          _buildSectionHeader(loc.expense, controller.expenseList.length, () {
            setState(() {
              controller.showAllExpense = !controller.showAllExpense;
            });
          }),
          ..._buildExpenseList(),
          _buildSectionHeader(
            loc.cashAdvance,
            controller.cashAdvanceList.length,
            () {
              setState(() {
                controller.showAllCashAdvance = !controller.showAllCashAdvance;
              });
            },
          ),
          _buildCashAdvanceSection(),
        ],
      );
    });
  }

  Widget _buildSectionHeader(String title, int count, VoidCallback onSeeMore) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (count > 5)
            GestureDetector(
              onTap: onSeeMore,
              child: Text(
                _getSeeMoreText(title),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSeeMoreText(String type) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case "Cash Advance":
        return controller.showAllCashAdvance ? loc.seeLess : loc.seeMore;
      case "Expense":
        return controller.showAllExpense ? loc.seeLess : loc.seeMore;
      default:
        return loc.seeMore;
    }
  }

  Widget _buildCashAdvanceSection() {
    if (controller.cashAdvanceList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.orange,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              "No Cash Advance Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final items = controller.showAllCashAdvance
        ? controller.cashAdvanceList
        : controller.cashAdvanceList.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List of cash advances
        ...items.map((tx) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.account_balance_wallet, color: Colors.white),
            ),
            title: Text(
              'Requisition: ${tx.requisitionId}',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Status: ${tx.approvalStatus}',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              '₹${tx.totalRequestedAmountInReporting}',
              style: TextStyle(color: Colors.white),
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildExpenseList() {
    if (controller.expenseList.isEmpty) {
      return [
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text(
                "No Expenses Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final items = controller.showAllExpense
        ? controller.expenseList
        : controller.expenseList.take(5).toList();

    return items.map((tx) {
      return ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.currency_rupee, color: Colors.white),
        ),
        title: Text(
          'Expense Id: ${tx.expenseId}',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${tx.expenseCategoryId}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Status: ${tx.approvalStatus}',
              style: TextStyle(color: Colors.white), // 👈 added ApprovalStatus
            ),
          ],
        ),
        trailing: Text(
          '₹${tx.totalAmountTrans.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.white),
        ),
      );
    }).toList();
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
      decoration: _boxDecoration(Colors.green.shade50),
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
      decoration: _boxDecoration(Colors.amber.shade50),
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

  Widget _settlementStatusChart(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _boxDecoration(Colors.white),
      child: SfCartesianChart(
        title: ChartTitle(
          text: loc.mySettlementStatus,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        primaryXAxis: const CategoryAxis(
          labelRotation: 35,
          labelStyle: TextStyle(fontSize: 8),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 8),
        ),
        series: <ColumnSeries>[
          ColumnSeries<ExpenseAmountByStatus, String>(
            dataSource: controller.expensesByStatus,
            xValueMapper: (ExpenseAmountByStatus data, _) => data.status,
            yValueMapper: (ExpenseAmountByStatus data, _) => data.amount,
            pointColorMapper: (_, __) =>
                Colors.primaries[__ % Colors.primaries.length].shade300,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expensesByProjectChart(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _boxDecoration(Colors.blue.shade50),
      child: SfCartesianChart(
        title: ChartTitle(
          text: loc.myExpensesByProject,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 8)),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 8),
        ),
        series: <CartesianSeries>[
          ColumnSeries<ProjectExpense, String>(
            dataSource: controller.projectExpenses,
            xValueMapper: (ProjectExpense project, _) => project.x,
            yValueMapper: (ProjectExpense project, _) => project.y,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 8),
            ),
            color: Colors.blue,
          ),
        ],
      ),
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

  Widget _expensesByCategoryChart(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _boxDecoration(Colors.blue.shade50),
      child: SfCartesianChart(
        title: ChartTitle(
          text: loc.totalExpensesByCategory,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        primaryXAxis: const CategoryAxis(
          labelRotation: 45,
          labelStyle: TextStyle(fontSize: 5, fontWeight: FontWeight.w500),
          labelAlignment: LabelAlignment.start,
          maximumLabels: 10,
          isVisible: true,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<ProjectExpensebycategory, String>(
            dataSource: controller.projectExpensesbyCategory,
            xValueMapper: (ProjectExpensebycategory project, _) => project.x,
            yValueMapper: (ProjectExpensebycategory project, _) => project.y,
            pointColorMapper: (ProjectExpensebycategory project, _) =>
                project.color,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  /// 🔹 Common box decoration
  BoxDecoration _boxDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
      color: color,
    );
  }
}
