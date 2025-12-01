import 'dart:io' show File;

import 'package:digi_xpense/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

class UnProcess extends StatefulWidget {
  const UnProcess({super.key});

  @override
  State<UnProcess> createState() => _UnProcessState();
}

class _UnProcessState extends State<UnProcess> {
  late final Controller controller;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
Rxn<File> profileImage = Rxn<File>();
  @override
  void initState() {
    super.initState();
    controller = Get.find(); // Use existing controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
      controller.searchControllerUnProcess.clear();
       controller.fetchUnprocessExpense();
    });
   
    _loadProfileImage();
  }
    void _loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      // controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
    }
  }
  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        // ✅ Prevent double navigation by replacing instead of popping
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard_Main);
        return false;
      },
       child: Scaffold(
        // backgroundColor: const Color(0xFFF7F7F7),
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: const MyDrawer(),
        body: 

        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final theme = Theme.of(context);
            final primaryColor = theme.primaryColor;
            return Column(
              children: [
               if (primaryColor != const Color(0xFF1e4db7) )
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
                    padding: const EdgeInsets.fromLTRB(6, 40, 6, 16),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _openMenu,
                          icon: Icon(Icons.menu, color: Colors.black, size: 20),
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
                  
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              AppLocalizations.of(context)!.unProcessedExpense,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextField(
                              controller: controller.searchControllerUnProcess,
                              onChanged: (value) {
                                controller.searchQuery.value =
                                    value.toLowerCase();
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .searchExpenses,
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
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
                        
                        Expanded(
                          child: Obx(() {
                            final expenses = controller.getAllListGExpense;
                            final filteredExpenses = expenses.where((item) {
                              final query = controller.searchQuery.value;
                              if (query.isEmpty) return true;

                              // ✅ Safe filter check (null-safe)
                              return item.expenseType
                                      .toLowerCase()
                                      .contains(query) ||
                                  (item.expenseId
                                          ?.toLowerCase()
                                          .contains(query) ??
                                      false);
                            }).toList();

                            if (filteredExpenses.isEmpty) {
                              return Center(
                                child: Text(
                                  "No expenses found",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                             return controller.isLoadingunprocess.value
                        ? const SkeletonLoaderPage()
                        : controller.filteredExpenses.isEmpty
                        ? Center(child: Text(loc.noExpensesFound))
                        : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (ctx, idx) {
                                final item = filteredExpenses[idx];

                                return Dismissible(
                                  // ✅ Stable key (avoid flickering)
                                  key: ValueKey(item.expenseId),
                                  background: _buildSwipeActionLeft(isLoading),
                                  secondaryBackground: _buildSwipeActionRight(),
                                  onDismissed: (direction) async {
                                    final success = await controller
                                        .deleteExpenseUnprocess(item.recId);

                                    if (success) {
                                      controller.getAllListGExpense.removeWhere(
                                          (e) => e.expenseId == item.expenseId);

                                      controller.getAllListGExpense.refresh();
                                    }
                                  },
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      setState(() => isLoading = true);

                                      if (item.expenseType == "PerDiem") {
                                        await controller
                                            .fetchSecificPerDiemItem(
                                                context, item.recId, false);
                                      } else if (item.expenseType ==
                                          "General Expenses") {
                                        await controller
                                            .fetchSecificExpenseItem(
                                                context, item.recId, true);
                                        controller
                                            .fetchExpenseHistory(item.recId);
                                      } else if (item.expenseType ==
                                          "Mileage") {
                                        Navigator.pushNamed(context,
                                            AppRoutes.mileageDetailsPage);
                                      }

                                      setState(() => isLoading = false);
                                      return false; // don't dismiss on view
                                    } else {
                                      final shouldDelete =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(
                                              '${AppLocalizations.of(context)!.delete} ${AppLocalizations.of(context)!.expense}?'),
                                          content: Text(
                                              '${AppLocalizations.of(context)!.deleteConfirmation}"${item.expenseId}"? ${AppLocalizations.of(context)!.deleteWarning}'),
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

                                      return shouldDelete == true;
                                    }
                                  },
                                  child: _buildStyledCard(item, context),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    );
                  },
                )));
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
                count > 99 ? '99+' : '$count',
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
            isLoading
                ? AppLocalizations.of(context)!.loading
                : AppLocalizations.of(context)!.view,
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

  Widget _buildStyledCard(GExpense item, BuildContext context) {
    final controller = Get.find<Controller>();
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final result = await controller.unprocessSpecificEnter(item.recId);
        if (!mounted) return;
        if (result.isNotEmpty) {
          navigator.pushNamed(
            AppRoutes.unProcessExpense,
            arguments: {'item': result[0], 'readOnly': true},
          );
        }
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
                    item.expenseId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    item.receiptDate != null
                        ? DateFormat('dd-MM-yyyy').format(item.receiptDate!)
                        : 'No date',
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
                item.expenseCategoryId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
                      color: const Color.fromARGB(255, 0, 110, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.approvalStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    item.totalAmountTrans.toStringAsFixed(2),
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
}
