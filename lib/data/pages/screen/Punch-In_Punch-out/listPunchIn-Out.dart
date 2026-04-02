import 'dart:convert';
import 'dart:io';
import 'package:diginexa/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:diginexa/core/comman/widgets/languageDropdown.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/noDataFind.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart' show Params;
import 'package:diginexa/data/models.dart' show TeamAttendance;
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/leaveCalenderView.dart';
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/view_CreateLeave.dart';
import 'package:diginexa/data/pages/screen/TimeSheet/createViewTimeSheet.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class MyAttendanceList extends StatefulWidget {
  const MyAttendanceList({super.key});

  @override
  State<MyAttendanceList> createState() => _MyAttendanceList();
}

class _MyAttendanceList extends State<MyAttendanceList>
    with TickerProviderStateMixin {
  late final Controller controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // Tab related variables

  bool isLoading = false;
  Rxn<File> profileImage = Rxn<File>();

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
      controller.searchQuery.value = '';
      _loadProfileImage();
    });

    controller.fetchNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPersonalDetails(context);
      controller.fetchMyattendanceList().then((_) {
        controller.isLoadingLeaves.value = false;
      });
    });
  }

  void _loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'selectedMenu',
      AppLocalizations.of(context)!.punchInOutList,
    );
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      controller.isImageLoading.value = false;
    }
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
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
        controller.selectedStatus = "Un Reported";
        controller.selectedTimeSheetStatusDropDown.value = "Un Reported";
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
                      AppLocalizations.of(context)!.myAttendanceList,
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

                // 🔹 Content based on selected tab
                Expanded(child: _buildCardViewContent(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardViewContent(BuildContext context) {
    return Obx(() {
      print("isLoadingLeaves => ${controller.isLoadingLeaves.value}");

      if (controller.isLoadingLeaves.value) {
        return const SkeletonLoaderPage();
      }

      if (controller.filteredMyteamPunchInOut.isEmpty) {
        return const CommonNoDataWidget();
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: controller.filteredMyteamPunchInOut.length,
        itemBuilder: (ctx, idx) {
          final item = controller.filteredMyteamPunchInOut[idx];

          return Dismissible(
            key: ValueKey(item.transAttendanceId),
            background: _buildSwipeActionLeft(isLoading),

            confirmDismiss: (direction) async {
              setState(() => isLoading = true);

              if (direction == DismissDirection.startToEnd) {
                // 👉 Swipe Right Action
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceViewDialog(item: item),
                  ),
                );
              } else if (direction == DismissDirection.endToStart) {
                // 👉 Swipe Left Action
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceViewDialog(item: item),
                  ),
                );
              }

              setState(() => isLoading = false);

              return false; // prevent actual dismissal
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

  Widget _buildStyledCard(TeamAttendance item, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AttendanceViewDialog(item: item)),
        );
      },
      child: SizedBox(
        width: double.infinity, // ✅ FULL WIDTH
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.transAttendanceId ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.employeeId}: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: item.employeeId ?? '-'),
                      const TextSpan(text: '  ||  '),
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.employeeName} ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: item.employeeName ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.punchIn}: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: epochToIso(item.punchInTime)),
                      const TextSpan(text: '  ||  '),
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.punchOut}: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: epochToIso(item.punchOutTime)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.totalHours} : ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: secondsToHms(item.totalDuration)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String secondsToHms(num? seconds) {
    if (seconds == null) return '0h 0m 0s';

    final totalSeconds = seconds.toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;

    return '${hours}h ${minutes}m ${secs}s';
  }

  String epochToIsoClean(int? epoch) {
    if (epoch == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch).toLocal();
    return DateFormat('dd MM yyyy').format(dt);
  }

String epochToIso(int? epoch) {
  if (epoch == null) return '-';
  final dt = DateTime.fromMillisecondsSinceEpoch(epoch).toLocal();
  return DateFormat('dd-MM-yyyy HH:mm:ss').format(dt);
}
}

class AttendanceViewDialog extends StatelessWidget {
  final TeamAttendance item;

  const AttendanceViewDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewAttendanceTransaction),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            customTextField(
              label: AppLocalizations.of(context)!.transactionId,
              value: item.transAttendanceId,
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.employeeId,
              value: item.employeeId,
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.employeeName,
              value: item.employeeName,
            ),
            const SizedBox(height: 20),

            customTextField(
              label: AppLocalizations.of(context)!.punchInTime,
              value: epochToDateTime(item.punchInTime),
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.punchOutTime,
              value: epochToDateTime(item.punchOutTime),
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.totalDuration,
              value: secondsToHms(item.totalDuration),
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.captureType,
              value: item.captureMethod,
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.punchInGeofenceId,
              value: item.punchInGeofenceId,
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.punchOutGeofenceId,
              value: item.punchOutGeofenceId,
            ),
            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.isRegularized,
              value: item.isRegularized == true ? 'Yes' : 'No',
            ),
            const SizedBox(height: 20),

            customTextField(
              label: AppLocalizations.of(context)!.punchInLocation,
              value: formatLocation(item.punchInLocation),
            ),

            const SizedBox(height: 20),
            customTextField(
              label: AppLocalizations.of(context)!.punchOutLocation,
              value: formatLocation(item.punchOutLocation),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight, // Align to the top-right
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTextField({
    required String label,
    TextEditingController? controller,
    String? value,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true, // Non-editable
      initialValue: value ?? '',
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(137, 218, 216, 216),
        labelText: label, // Label now inside the field
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced border radius
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1, // Thinner border
          ),
        ),

        // enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        // ),
      ),
    );
  }

  String formatLocation(List<double>? location) {
    if (location == null || location.length < 2) return '-';
    final lat = location[0].toStringAsFixed(6);
    final lng = location[1].toStringAsFixed(6);
    return 'Lat: $lat, Lng: $lng';
  }

  String secondsToHms(num? seconds) {
    if (seconds == null) return '0h 0m 0s';
    final totalSeconds = seconds.toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;
    return '${hours}h ${minutes}m ${secs}s';
  }

  String epochToDateTime(int? epoch) {
    if (epoch == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch).toLocal();
    return DateFormat('dd-MM-yyyy, hh:mm a').format(dt);
  }
}
