import 'dart:io';

import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../../l10n/app_localizations.dart';
import 'Side_Bar/side_bar.dart';

class ScaffoldWithNav extends StatefulWidget {
  final List<Widget> pages;
  final int initialIndex;

  const ScaffoldWithNav({
    super.key,
    required this.pages,
    this.initialIndex = 0,
  });

  @override
  _ScaffoldWithNavState createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFabOpen = false;
  bool _isAddFabOpen = false;
  bool? showExpense;
  bool? showPerDiem;
  bool? showMileage;
  bool? showCashAdvans;
  bool? digiScanEnable;
  final controller = Get.put(Controller());
  final PhotoViewController _photoViewController = PhotoViewController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      controller.isImageLoading.value = true;

      // 🧩 Pick image safely
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) {
        Fluttertoast.showToast(
          msg: "No image selected",
          backgroundColor: Colors.orange,
        );
        return;
      }

      // 🧩 Crop image
      final croppedFile = await _cropImage(File(pickedFile.path));

      if (croppedFile == null) {
        Fluttertoast.showToast(
          msg: "Image cropping cancelled",
          backgroundColor: Colors.orange,
        );
        return;
      }

      // 🧩 Update state only if widget still mounted
      if (!mounted) return;
      setState(() {
        controller.imageFiles.add(croppedFile);
      });
    } catch (e, stack) {
      debugPrint("❌ Error picking or cropping image: $e");
      debugPrint(stack.toString());
      Fluttertoast.showToast(
        msg: "Failed to upload image: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<File?> _cropImage(File file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: false),
      ],
    );

    if (croppedFile != null) {
      final croppedImage = File(croppedFile.path);

      // ✅ Check feature states before deciding what to do next
      final featureStates = await controller.getAllFeatureStates();

      if (digiScanEnable!) {
        // ✅ AutoScan enabled → upload directly
        // ignore: use_build_context_synchronously
        await controller.sendUploadedFileToServer(context, croppedImage);
      } else {
        // 🚫 AutoScan disabled → go to AutoScan page manually
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.autoScan,
          arguments: {'imageFile': croppedImage, 'apiResponse': {}},
        );
      }

      return croppedImage;
    }

    return null;
  }

  void _zoomIn() {
    _photoViewController.scale = _photoViewController.scale! * 1.2;
  }

  void _zoomOut() {
    _photoViewController.scale = _photoViewController.scale! / 1.2;
  }

  void _deleteImage() {
    setState(() {
      controller.imageFile = null;
    });
  }

  Future<void> loadFuture() async {
    // Remove setState from here and call it after all async operations
    final expense = await controller.isFeatureEnabled('EnableGeneralExpense');
    final perDiem = await controller.isFeatureEnabled('EnablePerdiem');
    final mileage = await controller.isFeatureEnabled('EnableMileage');
    final digiScan = await controller.isFeatureEnabled('DigiScanning');
    // Update state once after all async operations complete
    setState(() {
      showExpense = expense;
      showPerDiem = perDiem;
      showMileage = mileage;
      digiScanEnable = digiScan;
    });
    print("digiScan$digiScan");
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    print("Initial index set to: $_currentIndex");

    // Call loadFuture without wrapping in setState
    loadFuture();
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0.0;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          widget.pages[_currentIndex],

          // Camera / Gallery FAB group
          if (_isFabOpen)
            Positioned(
              bottom: 90,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'fab1',
                    mini: true,
                    backgroundColor: primaryColor,
                    onPressed: () {
                      controller.imageFiles.clear();
                      _pickImage(ImageSource.camera);
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'fab2',
                    mini: true,
                    backgroundColor: primaryColor,
                    onPressed: () {
                      controller.imageFiles.clear();
                      _pickImage(ImageSource.gallery);
                    },
                    child: const Icon(
                      Icons.photo,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

          // Add FAB group controlled by backend feature flags
          if (_isAddFabOpen)
            FutureBuilder<Map<String, bool>>(
              future: controller.getAllFeatureStates(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(); // show nothing while loading
                }

                final featureStates = snapshot.data!;

                // Only show buttons that are enabled in backend
                final visibleFabs = [
                  if (featureStates['EnableMileage'] == true)
                    {
                      'route': AppRoutes.mileageExpensefirst,
                      'asset': 'assets/vodometer.png',
                      'label': AppLocalizations.of(context)!.mileage,
                      'tag': 'addFabMileage',
                    },
                  if (featureStates['EnablePerdiem'] == true)
                    {
                      'route': AppRoutes.perDiem,
                      'asset': 'assets/perDiem.png',
                      'label': AppLocalizations.of(context)!.perDiem,
                      'tag': 'addFabPerDiem',
                    },
                  if (featureStates['EnableGeneralExpense'] == true)
                    {
                      'route': AppRoutes.expenseForm,
                      'asset': 'assets/general.png',
                      'label': AppLocalizations.of(context)!.generalExpense,
                      'tag': 'addFabExpense',
                    },
                  if (featureStates['EnableCashAdvanceRequisition'] == true)
                    {
                      'route': AppRoutes.formCashAdvanceRequest,
                      'asset': 'assets/cashAdvanse.png',
                      'label': AppLocalizations.of(context)!.cashAdvance,
                      'tag': 'addFabCashAdvance',
                    },
                ];

                if (visibleFabs.isEmpty) return const SizedBox();

                return Positioned(
                  bottom: 90,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var fab in visibleFabs) ...[
                        const SizedBox(height: 10),
                        _fabButton(
                          context,
                          fab['route'] as String,
                          fab['asset'] as String,
                          fab['label'] as String,
                          fab['tag'] as String,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      floatingActionButton: !isKeyboardOpen
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 0,
              onPressed: () {
                setState(() {
                  _isFabOpen = !_isFabOpen;
                  _isAddFabOpen = false; 
                });
              },
              child: Icon(
                _isFabOpen ? Icons.close : Icons.document_scanner,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _fabButton(
    BuildContext context,
    String route,
    String asset,
    String label,
    String tag,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140), // ✅ equal width
      child: FloatingActionButton.extended(
        heroTag: tag,
        backgroundColor:  Theme.of(context).colorScheme.secondary,
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        icon: Image.asset(asset, height: 14),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondary = theme.colorScheme.secondary;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      height: 60,
      color: Theme.of(context).colorScheme.secondary,
      child: Container(
        height: 30,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _isFabOpen = false;
                  _isAddFabOpen = false;
                });
              },
            ),
            IconButton(
              icon: Icon(
                _isAddFabOpen ? Icons.close : Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isAddFabOpen = !_isAddFabOpen;
                  _isFabOpen = false;
                });
              },
            ),
            const SizedBox(width: 48),

            IconButton(
              icon: const Icon(Icons.smart_toy, color: Colors.white),
              onPressed: () async {
                final featureStates = await controller.getAllFeatureStates();
                final bool? isEnabled =
                    featureStates['EnableAIAnalytics']; // use your feature key

                if (isEnabled == true) {
                  setState(() {
                    _currentIndex = 2;
                    _isFabOpen = false;
                    _isAddFabOpen = false;
                  });
                } else {
                  if (context.mounted) {
                    Fluttertoast.showToast(
                      msg: "This feature is disabled",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: const Color.fromARGB(255, 250, 1, 1),
                      textColor: const Color.fromARGB(255, 253, 252, 253),
                      fontSize: 16.0,
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _openMenu();
                setState(() {
                  _isFabOpen = false;
                  _isAddFabOpen = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
