// FULL WORKING PUNCH IN / PUNCH OUT SCREEN
// Header is excluded as requested
// Uses GetX + http + intl
// Location & Camera hooks are ready

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:diginexa/core/comman/Side_Bar/side_bar.dart' show MyDrawer;
import 'package:diginexa/core/comman/widgets/languageDropdown.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show GoogleMap, CameraPosition, GoogleMapController, CameraUpdate;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------- ENUM ----------------
enum PunchStatus { inDuty, outDuty }

/// ---------------- CONTROLLER ----------------
class PunchController extends GetxController {}

/// ---------------- SCREEN ----------------
class PunchScreen extends StatefulWidget {
  const PunchScreen({super.key});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  final Controller controller = Get.find<Controller>();
  Rxn<File> profileImage = Rxn<File>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();

  
        WidgetsBinding.instance.addPostFrameCallback((_)async {
    _loadProfileImage();
      controller.updateTime();
          controller.fetchLastPunch();
     controller.checkLocationDisclosure(context);
        });
    controller.timer = Timer.periodic(
      Duration(minutes: 1),
      (_) => controller.updateTime(),
    );
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }
void _loadProfileImage() async {
    //  WidgetsBinding.instance.addPostFrameCallback((_) {
    //    controller.selectedExpenseType = "All Expenses".obs;
    //     controller.selectedStatusDropDown = "Un Reported".obs;
    //     controller.selectedStatus = "Un Reported";});
    controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    //  final prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    prefs.setString('selectedMenu', AppLocalizations.of(context)!.punchInOut);
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
      controller.isImageLoading.value = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final theme = Theme.of(context);
            final primaryColor = theme.primaryColor;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          child:
                          
                           Row(
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
                        )),
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
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 4,
                          child:
                          
                           Row(
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
                        )),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                _userIntro(),
                _punchSection(),
                _lastSessionSection(),
                _selfieSection(),
                _locationSection(),
                const SizedBox(height: 80),
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

  /// USER NAME SECTION
  Widget _userIntro() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              controller.userName.value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 4),
          Text(
             AppLocalizations.of(context)!.wouldYouLikeToPunch,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// PUNCH SECTION
  Widget _punchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM dd, yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final isIn = controller.punchStatus.value == PunchStatus.inDuty;
            return GestureDetector(
              onTap: controller.isLoading.value ? null : controller.onPunchTap,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: (isIn ? Colors.red : Colors.green).withOpacity(
                        0.4,
                      ),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    :  Icon(
                        Icons.fingerprint,
                        color:  isIn ? Colors.red : Colors.green,
                        size: 60,
                      ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: [
                Text(
                  controller.punchStatus.value == PunchStatus.inDuty
                      ?  AppLocalizations.of(context)!.punchInOut
                      :  AppLocalizations.of(context)!.punchIn,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.punchTimeText.value,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.red),
                const SizedBox(width: 6),
               Text(
                  controller.locationText.value.isNotEmpty
                      ? controller.locationText.value
                      : AppLocalizations.of(context)!.fetchingLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Chip(label: Text('${ AppLocalizations.of(context)!.status} : ${controller.statusText.value}')),
          ),
        ],
      ),
    );
  }

  /// LAST SESSION SECTION
  Widget _lastSessionSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             AppLocalizations.of(context)!.lastSession,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                _InfoCard(title:  AppLocalizations.of(context)!.lastIn, value: controller.lastInText.value),
                _InfoCard(
                  title:  AppLocalizations.of(context)!.lastOut,
                  value: controller.lastOutText.value,
                ),
                _InfoCard(
                  title:  AppLocalizations.of(context)!.totalTime,
                  value: controller.totalDurationText.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SELFIE SECTION
  Widget _selfieSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             AppLocalizations.of(context)!.selfieVerification,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => _selfieBox(controller.selfie1.value)),
              const SizedBox(width: 12),
              Obx(() => _selfieBox(controller.selfie1.value)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                                  onPressed: () async {
                  final newFile = await controller.captureSelfie();
                  if (newFile != null) {
                   controller.selfie1.value = newFile; 
                  }
                },

                  child:  Text( AppLocalizations.of(context)!.retake),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selfieBox(File? file) {
    return Expanded(
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: file == null
            ? const Icon(Icons.person, size: 80, color: Colors.grey)
            : Image.file(file, fit: BoxFit.cover),
      ),
    );
  }

  Widget _locationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             AppLocalizations.of(context)!.currentLocation,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          /// 🗺 GOOGLE MAP
          Obx(() {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: controller.currentLatLng.value,
                    zoom: 15,
                  ),

                  /// 📍 MARKERS
                  markers: controller.markers.value,

                  /// 🔵 BLUE DOT
                  myLocationEnabled: true,

                  /// 🎯 CURRENT LOCATION BUTTON (YOU ASKED)
                  myLocationButtonEnabled: true,

                  /// 🎛 UI CONTROLS
                  zoomControlsEnabled: true,
                  compassEnabled: true,

                  onMapCreated: (GoogleMapController mapCtrl) {
                    controller.mapController = mapCtrl;

                    /// Auto move to current location
                    mapCtrl.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        controller.currentLatLng.value,
                        16,
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          /// 📍 LOCATION TEXT
          Obx(
            () => Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  controller.locationText.value.isNotEmpty
                      ? controller.locationText.value
                      : AppLocalizations.of(context)!.fetchingLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// INFO CARD
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90, // 👈 same height for all cards
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 👈 center content
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11, // 👈 reduced
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10, // 👈 reduced
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}



