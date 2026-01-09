import 'dart:convert';
import 'dart:io';
import 'package:digi_xpense/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart'
    show GExpense, ManageExpensesCard, PayslipAnalyticsCard, PayrollsTeams;
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';

class Payslip_Dashboard extends StatefulWidget {
  const Payslip_Dashboard({super.key});

  @override
  State<Payslip_Dashboard> createState() => _Payslip_DashboardState();
}

class _Payslip_DashboardState extends State<Payslip_Dashboard>
    with TickerProviderStateMixin {
  final Controller controller = Get.find<Controller>();
  bool isLoading = true;
  Rxn<File> profileImage = Rxn<File>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
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
  void initState() {
    super.initState();
    loadPayrolls();
    _loadProfileImage();
    controller.fetchNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPersonalDetails(context);
    });
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> loadPayrolls() async {
    controller.isPayrollLoading.value = true;
    try {
      final result = await controller.fetchPayrollHeaders();
      controller.payrollList.assignAll(result);
    } finally {
      controller.isPayrollLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
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
                    padding: const EdgeInsets.fromLTRB(6, 40, 6, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Like margin-left
                    child: Text(
                      "Payroll Dashboard",
                      style: const TextStyle(
                        // color: AppColors.gradientEnd, // Text color
                        fontSize: 16, // font-size
                        fontWeight: FontWeight.bold, // font-weight: bold
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        // height: 1.2,
                      ),
                    ),
                  ),
                ),

                // const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final count = controller.selectedPayslipIds.length;
                        return ElevatedButton.icon(
                          onPressed: count == 0
                              ? null
                              : () async {
                                  final selected = controller
                                      .getSelectedPayslips(
                                        controller.payrollList,
                                      );
                                  // await controller.emailPayslips(
                                  //   selected,
                                  //   controller.userEmail,
                                  // );
                                },
                          icon: const Icon(Icons.email),
                          label: Text(
                            count == 0 ? "Send to Mail" : "Send (${count})",
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      child: Obx(() {
                        final count = controller.selectedPayslipIds.length;
                        return ElevatedButton.icon(
                          onPressed: count == 0
                              ? null
                              : () async {
                                  final selected = controller
                                      .getSelectedPayslips(
                                        controller.payrollList,
                                      );
                                  await controller.downloadPayslips(selected);
                                },
                          icon: const Icon(Icons.download),
                          label: Text(
                            count == 0 ? "Download" : "Download (${count})",
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                // const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    if (controller.isPayrollLoading.value) {
                      return const SkeletonLoaderPage(); // Full list skeleton
                    }

                    if (controller.payrollList.isEmpty) {
                      return const Center(
                        child: Text(
                          "Payslips not available",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: controller.payrollList.length,
                      itemBuilder: (context, index) {
                        final item = controller.payrollList[index];
                        return _buildPayrollStyledCard(item, context);
                      },
                    );
                  }),
                ),

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

  Widget _buildPayrollStyledCard(PayrollsTeams item, BuildContext context) {
    final controller = Get.find<Controller>();

    return Obx(() {
      final isSelected = controller.isSelected(item.recId.toString());

      return GestureDetector(
        onLongPress: () => controller.toggleSelection(item.recId.toString()),

        onTap: () {
          if (controller.selectedPayslipIds.isNotEmpty) {
            controller.toggleSelection(item.recId.toString());
            return;
          }

          /// 👉 OPEN PAYSLIP DETAILS / PDF
          // controller.openPayslipDetails(context, item.recId);
        },

        child: Card(
          color: isSelected ? Colors.blue.shade50 : null,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.employeeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          item.paymentDate != null
                              ? DateFormat(
                                  'dd-MM-yyyy',
                                ).format(item.paymentDate!)
                              : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// EMPLOYEE ID
                    Text(
                      'Employee ID: ${item.employeeId}',
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 6),

                    /// BOTTOM ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.type,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          item.source,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// ✅ CHECKBOX
              Positioned(
                top: 20,
                right: 6,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) =>
                      controller.toggleSelection(item.recId.toString()),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
