import 'dart:convert';
import 'dart:io';
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/reportMIS.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

class MyReportsDashboard extends StatefulWidget {
  const MyReportsDashboard({super.key});

  @override
  State<MyReportsDashboard> createState() => _MyReportsDashboardState();
}

class _MyReportsDashboardState extends State<MyReportsDashboard>
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
  // late Future<List<ReportModel>> futureReports;
  @override
  void initState() {
    super.initState();
    controller = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerReports.clear();
 if (controller.profileImage.value == null) {
        controller.getProfilePicture();
      }    });
    // / Use existing controller
    controller.selectedStatusmyteam = "In Process";
    _scrollController = ScrollController();
    controller.fetchAndAppendReports();
    // Load data
    // controller.loadProfilePictureFromStorage();
    controller.fetchNotifications();
    controller.getPersonalDetails(context);
  
    // controller.fetchMileageRates();
    // controller.fetchManageExpensesCards().then((_) {
    //   if (controller.manageExpensesCards.isNotEmpty && mounted) {
    //     _animationController = AnimationController(
    //       vsync: this,
    //       duration: const Duration(seconds: 10),
    //     );
    //     _animation =
    //         Tween<double>(begin: 0, end: 1).animate(_animationController)
    //           ..addListener(() {
    //             if (_scrollController.hasClients &&
    //                 _animationController.isAnimating) {
    //               final max = _scrollController.position.maxScrollExtent;
    //               _scrollController.jumpTo(_animation.value * max);
    //             }
    //           });
    //     _animationController.repeat();
    //   }
    // });

    controller.fetchAndAppendReports().then((_) {
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
  // void _onUserScroll() {
  //   if (_animationController.isAnimating) {
  //     _animationController.stop();
  //   }
  //   Future.delayed(const Duration(seconds: 8), () {
  //     if (!mounted) return;
  //     if (!_animationController.isAnimating) {
  //       _animationController.repeat();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
        body: LayoutBuilder(
          builder: (context, constraints) {
        
 final isSmallScreen = constraints.maxWidth < 600;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
            return Column(
              children: [
                // 🔹 Responsive Header
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
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 40, 16, 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Logo
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                 Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0), // Like margin-left
                    child: Text(
                       AppLocalizations.of(context)!.reports,
                      style: const TextStyle(
                        // color: AppColors.gradientEnd, // Text color
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

                const SizedBox(height: 16),

                // 🔹 Responsive Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: controller.searchControllerReports,
                      onChanged: (value) {
                        controller.searchQuery.value = value.toLowerCase();
                      },
                      decoration: InputDecoration(
                        hintText:  AppLocalizations.of(context)!.search,
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

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 🔹 Responsive Dropdown Filter
                      const Expanded(
                          flex: 3, // Takes 3 parts of available space
                          child: SizedBox(
                            width: 1,
                          )),

                      const SizedBox(
                          width: 12), // Spacing between dropdown and button

                      // 🔹 Add Request Button
                      Expanded(
                        flex:
                            3, // Takes 2 parts of space (smaller than dropdown)
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.reportCreateScreen);
                          },
                          icon: const Icon(Icons.add_circle,
                              size: 18, color: Colors.white),
                          label:  Text(
                            AppLocalizations.of(context)!.addReport,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue.shade800,
                            elevation: 4,
                            shadowColor: Colors.blue.shade900.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Expanded(
                  // height: MediaQuery.of(context).size.height * 0.45,
                  child: Obx(() {
                    if (controller.isLoadingGE1.value) {
                      return const SkeletonLoaderPage();
                    }

                    final expenses = controller.getAllListReport;
                    final filteredExpenses = expenses.where((item) {
                      final query = controller.searchQuery.value;
                      if (query.isEmpty) return true;
                      return (item.availableFor?.toLowerCase() ?? '')
                              .contains(query) ||
                          item.name.toLowerCase().contains(query) ||
                          item.functionalArea.toLowerCase().contains(query);
                    }).toList();
                    if (expenses.isEmpty) {
                      return  Center(child: Text( AppLocalizations.of(context)!.noReportFound));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (ctx, idx) {
                        final item = filteredExpenses[idx];

                        return Dismissible(
                          key: ValueKey(item.recId),
                          background: _buildSwipeActionLeft(isLoading),
                          secondaryBackground: _buildSwipeActionRight(),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              setState(() => isLoading = true);

                              // if (item.expenseType == "PerDiem") {
                              //   await controller.fetchSecificPerDiemItem(
                              //       context, item.recId, true);
                              // } else if (item.expenseType ==
                              //     "General Expenses") {
                              //   await controller.fetchSecificExpenseItem(
                              //       context, item.recId);
                              //   controller.fetchExpenseHistory(item.recId);
                              // } else if (item.expenseType == "Mileage") {
                              //   print("Its Call");
                              //   Navigator.pushNamed(
                              //       context, AppRoutes.mileageDetailsPage);
                              // }

                              setState(() => isLoading = false);
                              return false;
                            } else {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title:  Text('${ AppLocalizations.of(context)!.delete}?'),
                                  content: Text('${ AppLocalizations.of(context)!.delete} "${item.recId}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child:  Text(AppLocalizations.of(context)!.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child:  Text(AppLocalizations.of(context)!.delete),
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
            isLoading ? AppLocalizations.of(context)!.loading :AppLocalizations.of(context)!.view,
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
      child:  Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.delete,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStyledCard(ReportModels item, BuildContext context) {
    // print("itemxxx ${item.expenseType}");
    final controller = Get.put(Controller());
    return GestureDetector(
        onTap: () {
          // if (item.expenseType == "PerDiem") {
          controller.navigateToEditReportScreen(context, item.recId, true);
          //   controller.isEditModePerdiem = false;
          // } else if (item.expenseType == "General Expenses") {
          //   print("Expenses${item.recId}");
          //   controller.fetchSecificExpenseItem(context, item.recId, false);
          //   controller.fetchExpenseHistory(item.recId);
          // } else if (item.expenseType == "Mileage") {
          //   controller.fetchMileageDetails(context, item.recId);
          // } else if (item.expenseType == "CashAdvanceReturn") {
          //   controller.fetchSecificCashAdvanceReturn(context, item.recId, false);
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //         content: Text("Unknown expense type: ${item.expenseType}")),
          //   );
          // }
        },
        child: Card(
          // color: const Color.fromARGB(218, 245, 244, 244),
          shadowColor: const Color.fromARGB(255, 82, 78, 78),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Name (Bold Label + Value) + Report Icon
                Row(
                  children: [
                    // Name: John Doe (Bold Label)
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                           
                            fontSize: 16,
                            height: 1.4,
                          ),
                          children: [
                             TextSpan(
                              text: "${AppLocalizations.of(context)!.name}: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: item.name ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Report Icon (Clickable)
                    IconButton(
                      icon: const Icon(
                        Icons.receipt_outlined,
                        color: Color.fromARGB(255, 0, 110, 255),
                        size: 24,
                      ),
                      onPressed: () async {
                        final data = await controller.fetchDataset(
                            item.reportMetaData, context);

                        if (data != null) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportScreen(
                                  data: data,
                                  logicalOperator: '',
                                  rules: item.reportMetaData.isNotEmpty
                                      ? item.reportMetaData[0].rules
                                      : <Rule>[]),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to load report data')),
                          );
                        }
                      },
                      splashRadius: 20,
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),

                // CATEGORY: Finance / HR (Bold Label)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                     
                      fontSize: 14,
                    ),
                    children: [
                       TextSpan(
                        text: AppLocalizations.of(context)!.functionalArea,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: item.functionalArea ?? 'N/A',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                     
                      fontSize: 14,
                    ),
                    children: [
                       TextSpan(
                        text:AppLocalizations.of(context)!.reportAvailability,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: item.reportAvailability ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
