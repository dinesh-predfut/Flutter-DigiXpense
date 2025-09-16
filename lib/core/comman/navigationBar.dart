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

      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          setState(() {
            controller.imageFiles.add(File(croppedFile.path));
          });
        }
      }
    } catch (e) {
      print("Error picking or cropping image: $e");
      Fluttertoast.showToast(
        msg: "Failed to upload image",
        backgroundColor: Colors.red,
      );
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<File?> _cropImage(File file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        )
      ],
    );

    if (croppedFile != null) {
      final croppedImage = File(croppedFile.path);
      // ignore: use_build_context_synchronously
      await controller.sendUploadedFileToServer(context, croppedImage);

      // Navigator.pushNamed(
      //   context,
      //   AppRoutes.autoScan,
      //   arguments: croppedImage,
      // );
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

  

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
                      _pickImage(ImageSource.camera);
                    },
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'fab2',
                    mini: true,
                    backgroundColor: primaryColor,
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },
                    child:
                        const Icon(Icons.photo, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
        if (_isAddFabOpen)
  Positioned(
    bottom: 90,
    right: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 10),

        _fabButton(
          context,
          AppRoutes.mileageExpensefirst,
          "assets/vodometer.png",
          AppLocalizations.of(context)!.mileage,
          "addFab4",
        ),

        const SizedBox(height: 10),
        _fabButton(
          context,
          AppRoutes.perDiem,
          "assets/perDiem.png",
          AppLocalizations.of(context)!.perDiem,
          "addFab2",
        ),

        const SizedBox(height: 10),
        _fabButton(
          context,
          AppRoutes.expenseForm,
          "assets/general.png",
          AppLocalizations.of(context)!.generalExpense,
          "addFab1",
        ),

        const SizedBox(height: 10),
        _fabButton(
          context,
          AppRoutes.formCashAdvanceRequest,
          "assets/cashAdvanse.png",
          AppLocalizations.of(context)!.cashAdvance,
          "addFab5",
        ),
      ],
    ),
  ),

        ],
      ),
      floatingActionButton: !isKeyboardOpen
        ? FloatingActionButton(
            backgroundColor: primaryColor,
            elevation: 0,
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen;
                _isAddFabOpen = false; // Close other FAB group
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
Widget _fabButton(BuildContext context, String route, String asset, String label, String tag) {
   final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 140), // ✅ equal width
    child: FloatingActionButton.extended(
      heroTag: tag,
      backgroundColor: primaryColor,
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      icon: Image.asset(asset, height: 14),
      label: Text(label, style: const TextStyle(color: Colors.white,fontSize: 10)),
    ),
  );
}

  Widget _buildBottomAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    return BottomAppBar(
     
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      height: 60,
      color: primaryColor,
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
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                  _isFabOpen = false;
                  _isAddFabOpen = false;
                });
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
