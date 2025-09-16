import 'dart:async';
import 'dart:io';
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 100; // Initial height of the draggable panel
  final double _minDragExtent = 100; // Minimum height
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

    // Kick off init flow
    _initializeAsync();
  }

  void _initializeAsync() async {
    controller.getPersonalDetails(context);

  
      controller.digiSessionId = const Uuid().v4();
      Timer(const Duration(seconds: 4), () {
        controller.getCashAdvanceAPI();
        controller.getExpenseList();
        controller.fetchExpensesByCategory();
        controller.fetchManageExpensesSummary();
        controller.fetchExpensesByStatus();
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
        controller.fetchChartData();
        controller.fetchExpensesByProjects();
        controller.fetchAndReplaceValue();
        controller.currencyDropDown();
        controller.fetchNotifications();
        controller.getPersonalDetails(context);
        controller.configuration();
        controller.getUserPref();
        if (controller.profileImage.value == null) {
          controller.getProfilePicture();
        }
        controller.isInitialized.value = true;
      });
    }
  

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    print("unreadCount${controller.unreadCount.value}");
    final theme = Theme.of(context);

    ;
    return WillPopScope(onWillPop: () async {
      // For Android
      if (Platform.isAndroid) {
        SystemNavigator.pop(); // closes the app
      } else if (Platform.isIOS) {
        exit(0); // iOS will kill the app (not recommended in App Store)
      }
      return false; // prevent normal back navigation
    }, child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
        body: Obx(() {
      return controller.isUploadingCards.value
          ? const SkeletonLoaderPage()
          : LayoutBuilder(builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              final primaryColor = theme.primaryColor;
              //  Color primaryColors = theme.shade500;
              print("primaryColor.value${primaryColor.value}");
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    primaryColor.withOpacity(
                                        0.7), // Lighter primary color
                                  ],
                                ),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 40, 16, 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      // _buildProfileAvatar(),
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
                              padding:
                                  const EdgeInsets.fromLTRB(10, 40, 20, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                color: Colors.white),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  AppRoutes.notification);
                                            },
                                          ),
                                          Obx(() {
                                            final unreadCount = controller
                                                .unreadNotifications.length;
                                            if (unreadCount == 0) {
                                              return const SizedBox.shrink();
                                            }
                                            return Positioned(
                                              right: 6,
                                              top: 6,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
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
                          // Your existing header and content widgets...
                          // Stack(
                          //   children: [
                          //     Container(
                          //       width: double.infinity,
                          //       height: 130,
                          //       decoration: const BoxDecoration(
                          //         image: DecorationImage(
                          //           image: AssetImage('assets/Vector.png'),
                          //           fit: BoxFit.cover,
                          //         ),
                          //         borderRadius: BorderRadius.only(
                          //           bottomLeft: Radius.circular(10),
                          //           bottomRight: Radius.circular(10),
                          //         ),
                          //       ),
                          //       padding: const EdgeInsets.fromLTRB(
                          //           10, 40, 20, 20),
                          //       child: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           Flexible(
                          //             child: Column(
                          //               children: [
                          //                 const Text(
                          //                   'Welcome to',
                          //                   style: TextStyle(
                          //                       color: Colors.white,
                          //                       fontSize: 8),
                          //                 ),
                          //                 ClipRRect(
                          //                   borderRadius:
                          //                       BorderRadius.circular(20),
                          //                   child: Image.asset(
                          //                     'assets/XpenseWhite.png',
                          //                     width: 100,
                          //                     height: 40,
                          //                     fit: BoxFit.cover,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //           const SizedBox(height: 20),
                          //           Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               const LanguageDropdown(),
                          //               Stack(
                          //                 children: [
                          //                   IconButton(
                          //                     icon: const Icon(
                          //                         Icons.notifications,
                          //                         color: Colors.white),
                          //                     onPressed: () {
                          //                       Navigator.pushNamed(context,
                          //                           AppRoutes.notification);
                          //                     },
                          //                   ),
                          //                   Obx(() {
                          //                     final unreadCount = controller
                          //                         .unreadNotifications
                          //                         .length;
                          //                     if (unreadCount == 0) {
                          //                       return const SizedBox
                          //                           .shrink();
                          //                     }
                          //                     return Positioned(
                          //                       right: 6,
                          //                       top: 6,
                          //                       child: Container(
                          //                         padding:
                          //                             const EdgeInsets.all(
                          //                                 4),
                          //                         decoration:
                          //                             const BoxDecoration(
                          //                           color: Colors.red,
                          //                           shape: BoxShape.circle,
                          //                         ),
                          //                         constraints:
                          //                             const BoxConstraints(
                          //                           minWidth: 18,
                          //                           minHeight: 18,
                          //                         ),
                          //                         child: Text(
                          //                           '$unreadCount',
                          //                           style: const TextStyle(
                          //                             color: Colors.white,
                          //                             fontSize: 10,
                          //                             fontWeight:
                          //                                 FontWeight.bold,
                          //                           ),
                          //                           textAlign:
                          //                               TextAlign.center,
                          //                         ),
                          //                       ),
                          //                     );
                          //                   }),
                          //                 ],
                          //               ),
                          //               const SizedBox(width: 10),
                          //               GestureDetector(
                          //                 onTap: () {
                          //                   Navigator.pushNamed(context,
                          //                       AppRoutes.personalInfo);
                          //                 },
                          //                 child: Obx(() => Container(
                          //                       padding:
                          //                           const EdgeInsets.all(2),
                          //                       decoration: BoxDecoration(
                          //                         shape: BoxShape.circle,
                          //                         border: Border.all(
                          //                             color: Colors.white,
                          //                             width: 2),
                          //                       ),
                          //                       child: ClipRRect(
                          //                         borderRadius:
                          //                             BorderRadius.circular(
                          //                                 20),
                          //                         child: controller
                          //                                 .isImageLoading
                          //                                 .value
                          //                             ? const SizedBox(
                          //                                 width: 40,
                          //                                 height: 40,
                          //                                 child:
                          //                                     CircularProgressIndicator(
                          //                                   color: Colors
                          //                                       .white,
                          //                                   strokeWidth: 2,
                          //                                 ),
                          //                               )
                          //                             : controller.profileImage
                          //                                         .value !=
                          //                                     null
                          //                                 ? Image.file(
                          //                                     controller
                          //                                         .profileImage
                          //                                         .value!,
                          //                                     width: 40,
                          //                                     height: 40,
                          //                                     fit: BoxFit
                          //                                         .cover,
                          //                                   )
                          //                                 : const Icon(
                          //                                     Icons.person,
                          //                                     size: 40,
                          //                                     color: Colors
                          //                                         .white,
                          //                                   ),
                          //                       ),
                          //                     )),
                          //               ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Obx(() {
                            return NotificationListener<UserScrollNotification>(
                              onNotification: (notification) {
                                // Stop auto-scroll when user starts interacting
                                if (_animationController.isAnimating) {
                                  _animationController.stop();
                                  print(
                                      "Auto-scroll stopped because user started scrolling");
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
                                  itemCount:
                                      controller.manageExpensesCards.length,
                                  itemBuilder: (context, index) {
                                    final card =
                                        controller.manageExpensesCards[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // Stop animation on card tap
                                        if (_animationController.isAnimating) {
                                          _animationController.stop();
                                          print(
                                              "Auto-scroll stopped because user tapped a card");
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _mostUsedButton(Icons.money, loc.expense, () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.generalExpense);
                                  }),
                                  const SizedBox(width: 20),
                                  _mostUsedButton(Icons.verified, loc.approvals,
                                      () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.approvalHubMain);
                                  }),
                                  const SizedBox(width: 20),
                                  _mostUsedButton(Icons.mail, loc.mail, () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.emailHubScreen);
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 290,
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              // padding: const EdgeInsets.all(7),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        loc.myDashboard,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          // 🔹 Expense Trends
                                          Obx(() {
                                            if (controller.isLoading.value) {
                                              return _loaderBox();
                                            }
                                            return _expenseTrendChart(context);
                                          }),

                                          // 🔹 Expense by Approval Status
                                          Obx(() {
                                            if (controller.isLoading.value) {
                                              return _loaderBox();
                                            } else if (controller
                                                .manageExpensesSummary
                                                .isEmpty) {
                                              return _emptyBox();
                                            }
                                            return _approvalStatusChart(
                                                context);
                                          }),

                                          // 🔹 Settlement Status
                                          Obx(() {
                                            if (controller.isLoading.value) {
                                              return _loaderBox();
                                            } else if (controller
                                                .expensesByStatus.isEmpty) {
                                              return _emptyBox();
                                            }
                                            return _settlementStatusChart(
                                                context);
                                          }),

                                          // 🔹 Expenses by Project
                                          Obx(() {
                                            if (controller.isLoading.value) {
                                              return _loaderBox();
                                            } else if (controller
                                                .projectExpenses.isEmpty) {
                                              return _emptyBox();
                                            }
                                            return _expensesByProjectChart(
                                                context);
                                          }),

                                          // 🔹 Expenses by Category
                                          Obx(() {
                                            if (controller.isLoading.value) {
                                              return _loaderBox();
                                            } else if (controller
                                                .projectExpensesbyCategory
                                                .isEmpty) {
                                              return _emptyBox();
                                            }
                                            return _expensesByCategoryChart(
                                                context);
                                          }),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          // / Space before the draggable panel
                        ],
                      ),
                    ),
                  ),

                  // Draggable panel at the bottom
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _dragOffset = (_dragOffset - details.delta.dy)
                            .clamp(_minDragExtent, _maxDragExtent);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _dragOffset,
                      decoration: BoxDecoration(
                        // 👇 Gradient glass effect
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40)),
                        child: Column(
                          children: [
                            // 🔥 Custom drag handle
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 12),
                                width: 60,
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.purpleAccent
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // 🌊 Wavy top curve (Optional for unique feel)
                            // CustomPaint(
                            //   size: Size(double.infinity, 30),
                            //   painter: _TopCurvePainter(),
                            // ),

                            // 🌟 Transaction list content
                            Expanded(
                              child: _transactionList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            });
    })));
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
        width: 120,
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 1, 20, 43), Color(0xFF60A5FA)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
              loc.cashAdvance, controller.cashAdvanceList.length, () {
            setState(() {
              controller.showAllCashAdvance = !controller.showAllCashAdvance;
            });
          }),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (count > 5)
            GestureDetector(
              onTap: onSeeMore,
              child: Text(
                _getSeeMoreText(title),
                style: const TextStyle(
                    color: Color.fromARGB(255, 88, 61, 184),
                    fontWeight: FontWeight.w800),
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
            Icon(Icons.account_balance_wallet_outlined,
                color: Colors.orange, size: 50),
            SizedBox(height: 10),
            Text(
              "No Cash Advance Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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
            title: Text('Requisition: ${tx.requisitionId}'),
            subtitle: Text('Status: ${tx.approvalStatus}'),
            trailing: Text('₹${tx.totalRequestedAmountInReporting}'),
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
                  color: Colors.grey,
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
        title: Text('Expense Id: ${tx.expenseId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${tx.expenseCategoryId}'),
            Text(
              'Status: ${tx.approvalStatus}', // 👈 added ApprovalStatus
            ),
          ],
        ),
        trailing: Text('₹${tx.totalAmountTrans.toStringAsFixed(2)}'),
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
          width: 64, // total container size (including border)
          height: 64,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32), // match container shape
            child: controller.isImageLoading.value
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : controller.profileImage.value != null
                    ? Image.file(
                        controller.profileImage.value!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        )),
  );
}


  Widget _loaderBox() {
    return const SizedBox(
      width: 250,
      height: 220,
      child: Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }

  /// 🔹 Reusable empty state box
  Widget _emptyBox() {
    return const SizedBox(
      width: 250,
      height: 220,
      child: Center(
        child: Text("No data available",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
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
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
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
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        primaryXAxis: const CategoryAxis(
          labelStyle: TextStyle(fontSize: 8),
        ),
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
              fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
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
