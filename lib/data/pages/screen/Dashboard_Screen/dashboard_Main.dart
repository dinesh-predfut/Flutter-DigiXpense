import 'dart:async';
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constant/Parames/colors.dart';
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
  double _dragOffset = 200; // Initial height of the draggable panel
  final double _minDragExtent = 100; // Minimum height
  final double _maxDragExtent =
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.height *
          0.7; // Maximum height
  final Controller controller = Controller();
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // Delay heavy calls only on first load
    if (!controller.isInitialized.value) {
      controller.digiSessionId = const Uuid().v4();
      Timer(const Duration(seconds: 2), () {
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

            _animation = Tween<double>(begin: 0, end: 1)
                .animate(_animationController)
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

    return WillPopScope(
        onWillPop: () async {
          // controller.isEnable.value = false;
          // controller.isLoadingGE1.value = false;
          Navigator.pushNamed(context, AppRoutes.signin);
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: Obx(() {
            return controller.isUploadingCards.value
                ? const SkeletonLoaderPage()
                : Column(
                    children: [
                      // Main content that will scroll
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Your existing header and content widgets...
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
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 40, 20, 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                                      .unreadNotifications
                                                      .length;
                                                  if (unreadCount == 0) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Positioned(
                                                    right: 6,
                                                    top: 6,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
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
                                                                color: Colors
                                                                    .white,
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
                              Obx(() {
                                return NotificationListener<
                                    UserScrollNotification>(
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
                                        final card = controller
                                            .manageExpensesCards[index];
                                        return GestureDetector(
                                          onTap: () {
                                            // Stop animation on card tap
                                            if (_animationController
                                                .isAnimating) {
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
                              const SizedBox(height: 30),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _mostUsedButton(Icons.money, 'Expense',
                                          () {
                                        print('Button Pressed');
                                      }),
                                      const SizedBox(width: 20),
                                      _mostUsedButton(
                                          Icons.verified, 'Approvals', () {
                                        print('Button Pressed');
                                      }),
                                      const SizedBox(width: 20),
                                      _mostUsedButton(Icons.mail, 'Mail', () {
                                        print('Button Pressed');
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  height: 290,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'My Dashboard',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
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
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height:
                                                    220, // 👈 Reduced height
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      spreadRadius: 2,
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                  color: Colors.green.shade50,
                                                ),
                                                child: SfCartesianChart(
                                                  title: const ChartTitle(
                                                    text: "My Expense Trends",
                                                    textStyle: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  primaryXAxis:
                                                      const CategoryAxis(
                                                    labelRotation: 25,
                                                    labelStyle:
                                                        TextStyle(fontSize: 5),
                                                    edgeLabelPlacement:
                                                        EdgeLabelPlacement
                                                            .shift, // 👈 shift labels to avoid cutoff
                                                    labelIntersectAction:
                                                        AxisLabelIntersectAction
                                                            .hide, // 👈 hide overlapping labels
                                                  ),
                                                  primaryYAxis: NumericAxis(
                                                    numberFormat:
                                                        NumberFormat.compact(),
                                                    labelStyle: const TextStyle(
                                                        fontSize: 8),
                                                  ),
                                                  tooltipBehavior:
                                                      TooltipBehavior(
                                                          enable: true),
                                                  series: <CartesianSeries>[
                                                    LineSeries<ProjectData,
                                                        String>(
                                                      dataSource:
                                                          controller.chartData,
                                                      xValueMapper:
                                                          (ProjectData project,
                                                                  _) =>
                                                              project.x,
                                                      yValueMapper:
                                                          (ProjectData project,
                                                                  _) =>
                                                              project.y,
                                                      markerSettings:
                                                          const MarkerSettings(
                                                              isVisible: true),
                                                      color: Colors.green,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height:
                                                    220, // 🔥 Increased height to avoid overflow
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.amber.shade50,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      spreadRadius: 2,
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: SfCircularChart(
                                                  title: const ChartTitle(
                                                    text:
                                                        "My Expense Amount by Approval Status",
                                                    textStyle: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  legend: const Legend(
                                                    isVisible: true,
                                                    overflowMode:
                                                        LegendItemOverflowMode
                                                            .wrap, // ✅ Wrap long legends
                                                    position:
                                                        LegendPosition.bottom,
                                                    textStyle:
                                                        TextStyle(fontSize: 9),
                                                  ),
                                                  series: <DoughnutSeries<
                                                      ManageExpensesSummary,
                                                      String>>[
                                                    DoughnutSeries<
                                                        ManageExpensesSummary,
                                                        String>(
                                                      dataSource: controller
                                                          .manageExpensesSummary,
                                                      xValueMapper:
                                                          (ManageExpensesSummary
                                                                      data,
                                                                  _) =>
                                                              data.status,
                                                      yValueMapper:
                                                          (ManageExpensesSummary
                                                                      data,
                                                                  _) =>
                                                              data.amount,
                                                      dataLabelSettings:
                                                          const DataLabelSettings(
                                                        isVisible: true,
                                                        textStyle: TextStyle(
                                                            fontSize: 8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.85,
                                                height: 220,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: SfCartesianChart(
                                                  title: const ChartTitle(
                                                    text:
                                                        "My Settlement Status",
                                                    textStyle: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  primaryXAxis:
                                                      const CategoryAxis(
                                                    labelRotation:
                                                        35, // rotate for better readability
                                                    labelStyle:
                                                        TextStyle(fontSize: 8),
                                                  ),
                                                  primaryYAxis: NumericAxis(
                                                    numberFormat:
                                                        NumberFormat.compact(),
                                                    labelStyle: const TextStyle(
                                                        fontSize: 8),
                                                  ),
                                                  series: <ColumnSeries>[
                                                    ColumnSeries<
                                                        ExpenseAmountByStatus,
                                                        String>(
                                                      dataSource: controller
                                                          .expensesByStatus,
                                                      xValueMapper:
                                                          (ExpenseAmountByStatus
                                                                      data,
                                                                  _) =>
                                                              data.status,
                                                      yValueMapper:
                                                          (ExpenseAmountByStatus
                                                                      data,
                                                                  _) =>
                                                              data.amount,
                                                      pointColorMapper:
                                                          (_, __) => Colors
                                                              .primaries[__ %
                                                                  Colors
                                                                      .primaries
                                                                      .length]
                                                              .shade300,
                                                      dataLabelSettings:
                                                          const DataLabelSettings(
                                                        isVisible: true,
                                                        textStyle: TextStyle(
                                                            fontSize: 8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height: 220,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      spreadRadius: 2,
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                  color: Colors.blue.shade50,
                                                ),
                                                child: SfCartesianChart(
                                                  title: const ChartTitle(
                                                    text:
                                                        "My Expenses by Project ",
                                                    textStyle: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  primaryXAxis:
                                                      const CategoryAxis(
                                                    labelStyle:
                                                        TextStyle(fontSize: 8),
                                                  ),
                                                  primaryYAxis: NumericAxis(
                                                    numberFormat:
                                                        NumberFormat.compact(),
                                                    labelStyle: const TextStyle(
                                                        fontSize: 8),
                                                  ),
                                                  series: <CartesianSeries>[
                                                    ColumnSeries<ProjectExpense,
                                                        String>(
                                                      dataSource: controller
                                                          .projectExpenses,
                                                      xValueMapper:
                                                          (ProjectExpense
                                                                      project,
                                                                  _) =>
                                                              project.x,
                                                      yValueMapper:
                                                          (ProjectExpense
                                                                      project,
                                                                  _) =>
                                                              project.y,
                                                      dataLabelSettings:
                                                          const DataLabelSettings(
                                                        isVisible: true,
                                                        textStyle: TextStyle(
                                                            fontSize:
                                                                8), // 👈 Smaller data labels
                                                      ),
                                                      color: Colors.blue,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height:
                                                    220, // Slightly taller for better spacing
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.blue.shade50,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      spreadRadius: 2,
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: SfCartesianChart(
                                                  title: const ChartTitle(
                                                    text:
                                                        "Total Expenses by Category",
                                                    textStyle: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  primaryXAxis:
                                                      const CategoryAxis(
                                                    labelRotation: 45,
                                                    labelStyle: TextStyle(
                                                      fontSize: 5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    labelAlignment:
                                                        LabelAlignment.start,
                                                    maximumLabels: 10,
                                                    isVisible: true,
                                                  ),
                                                  primaryYAxis: NumericAxis(
                                                    numberFormat:
                                                        NumberFormat.compact(),
                                                    labelStyle: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  tooltipBehavior:
                                                      TooltipBehavior(
                                                          enable: true),
                                                  series: <CartesianSeries>[
                                                    ColumnSeries<
                                                        ProjectExpensebycategory,
                                                        String>(
                                                      dataSource: controller
                                                          .projectExpensesbyCategory,
                                                      xValueMapper:
                                                          (ProjectExpensebycategory
                                                                      project,
                                                                  _) =>
                                                              project.x,
                                                      yValueMapper:
                                                          (ProjectExpensebycategory
                                                                      project,
                                                                  _) =>
                                                              project.y,
                                                      pointColorMapper:
                                                          (ProjectExpensebycategory
                                                                      project,
                                                                  _) =>
                                                              project
                                                                  .color, // 👈 Dynamic colors
                                                      dataLabelSettings:
                                                          const DataLabelSettings(
                                                        isVisible: true,
                                                        textStyle: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .black, // Label color
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5), // Rounded bar edges
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Obx(() {
                                              //   if (controller.isUploading.value) {
                                              //     return Container(
                                              //       width: MediaQuery.of(context)
                                              //               .size
                                              //               .width *
                                              //           0.7, // 👈 Reduced width
                                              //       height: 220, // 👈 Reduced height
                                              //       margin: const EdgeInsets.symmetric(
                                              //           horizontal: 8),
                                              //       decoration: BoxDecoration(
                                              //         borderRadius:
                                              //             BorderRadius.circular(10),
                                              //         boxShadow: [
                                              //           BoxShadow(
                                              //             color: Colors.grey
                                              //                 .withOpacity(0.4),
                                              //             spreadRadius: 2,
                                              //             blurRadius: 10,
                                              //             offset: const Offset(0, 3),
                                              //           ),
                                              //         ],
                                              //         color:
                                              //             Colors.black.withOpacity(0.2),
                                              //       ),
                                              //       child: const Center(
                                              //         child: CircularProgressIndicator(
                                              //             color: Colors.green),
                                              //       ),
                                              //     );
                                              //   }
                                              //   return Container(
                                              //     width: MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         0.7,
                                              //     height: 220,
                                              //     margin: const EdgeInsets.symmetric(
                                              //         horizontal: 8),
                                              //     decoration: BoxDecoration(
                                              //       borderRadius:
                                              //           BorderRadius.circular(10),
                                              //       color: Colors.red.shade50,
                                              //     ),
                                              //     child: SfRadialGauge(
                                              //       title: const GaugeTitle(
                                              //         text: "Total Expense",
                                              //         textStyle: TextStyle(
                                              //           fontSize: 14,
                                              //           fontWeight: FontWeight.bold,
                                              //         ),
                                              //       ),
                                              //       axes: <RadialAxis>[
                                              //         RadialAxis(
                                              //           minimum: 0,
                                              //           maximum: controller
                                              //                   .expenseChartvalue *
                                              //               2,
                                              //           axisLabelStyle:
                                              //               const GaugeTextStyle(
                                              //             fontSize:
                                              //                 8, // 👈 Smaller gauge labels
                                              //             fontWeight: FontWeight.w600,
                                              //           ),
                                              //           pointers: <GaugePointer>[
                                              //             NeedlePointer(
                                              //               value: controller
                                              //                   .expenseChartvalue,
                                              //               enableAnimation: true,
                                              //               needleLength: 0.5,
                                              //               needleStartWidth: 0.5,
                                              //               needleEndWidth: 1.5,
                                              //               knobStyle: const KnobStyle(
                                              //                 knobRadius: 0.05,
                                              //               ),
                                              //             ),
                                              //           ],
                                              //           ranges: <GaugeRange>[
                                              //             GaugeRange(
                                              //               startValue: 0,
                                              //               endValue: controller
                                              //                       .expenseChartvalue *
                                              //                   0.4,
                                              //               color: Colors.green,
                                              //             ),
                                              //             GaugeRange(
                                              //               startValue: controller
                                              //                       .expenseChartvalue *
                                              //                   0.4,
                                              //               endValue: controller
                                              //                       .expenseChartvalue *
                                              //                   0.8,
                                              //               color: Colors.orange,
                                              //             ),
                                              //             GaugeRange(
                                              //               startValue: controller
                                              //                       .expenseChartvalue *
                                              //                   0.8,
                                              //               endValue: controller
                                              //                   .expenseChartvalue,
                                              //               color: Colors.red,
                                              //             ),
                                              //           ],
                                              //           annotations: <GaugeAnnotation>[
                                              //             GaugeAnnotation(
                                              //               widget: Text(
                                              //                 '₹${controller.expenseChartvalue.toStringAsFixed(0)}',
                                              //                 style: const TextStyle(
                                              //                   fontSize:
                                              //                       14, // 👈 Smaller annotation text
                                              //                   fontWeight:
                                              //                       FontWeight.bold,
                                              //                   color: Colors.black,
                                              //                 ),
                                              //               ),
                                              //               angle: 90,
                                              //               positionFactor: 0.5,
                                              //             )
                                              //           ],
                                              //         )
                                              //       ],
                                              //     ),
                                              //   );
                                              // }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Transaction',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Week')
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      20), // Space before the draggable panel
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
                                    margin: const EdgeInsets.only(
                                        top: 10, bottom: 12),
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
          }),
        ));
  }

  void _restartAnimationAfterDelay() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!_animationController.isAnimating && mounted) {
        _animationController.repeat(reverse: false);
      }
    });
  }

  // Rest of your helper methods (_balanceCard, _mostUsedButton, _transactionList) remain the same...
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

  Widget _mostUsedButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
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
    return Obx(() {
      return ListView(
        children: [
          // 🔹 Section 1: Cash Advance
          _buildSectionHeader("Cash Advance", controller.cashAdvanceList.length,
              () {
            setState(() {
              controller.showAllCashAdvance = !controller.showAllCashAdvance;
            });
          }),
          _buildCashAdvanceSection(),

          // 🔹 Section 2: Expense
          _buildSectionHeader("Expense", controller.expenseList.length, () {
            setState(() {
              controller.showAllExpense = !controller.showAllExpense;
            });
          }),
          ..._buildExpenseList(),
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
                controller.showAllCashAdvance && title == "Cash Advance" ||
                        controller.showAllExpense && title == "Expense"
                    ? "See Less ▲"
                    : "See More ▼",
                style: const TextStyle(
                    color: Color.fromARGB(255, 88, 61, 184),
                    fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
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
        trailing: Text('₹${tx.totalAmountTrans}'),
      );
    }).toList();
  }

  String _getTitle(String key) {
    switch (key) {
      case 'Inprogress':
        return 'Total Advance In Progress';
      case 'Pending':
        return 'Total Amount Pending';
      case 'TotalAmountReporting':
        return 'Total Expenses';
      case 'AmountSettled':
        return ' Total Amount Settled';
      default:
        return key;
    }
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
}
