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

  void _showFullImage(File file, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(file),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: "zoom_in_$index",
                      onPressed: _zoomIn,
                      child: const Icon(Icons.zoom_in),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "zoom_out_$index",
                      onPressed: _zoomOut,
                      child: const Icon(Icons.zoom_out),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "edit_$index",
                      onPressed: () => _cropImage(file),
                      child: const Icon(Icons.edit),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "delete_$index",
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          controller.imageFiles.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.delete),
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      drawer: MyDrawer(),
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
                    backgroundColor: AppColors.gradientEnd,
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
                    backgroundColor: AppColors.gradientEnd,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingActionButton(
                    heroTag: 'addFab1',
                    mini: true,
                    backgroundColor: AppColors.gradientEnd,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.expenseForm);
                    },
                    child: Image.asset("assets/general.png"),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'addFab2',
                    mini: true,
                    backgroundColor: AppColors.gradientEnd,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.perDiem);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0), // Adjust padding as needed
                      child: Image.asset("assets/perDiem.png"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'addFab3',
                    mini: true,
                    backgroundColor: AppColors.gradientEnd,
                    onPressed: () {
                      //  Navigator.pushNamed(context, AppRoutes.cashAdvanceReturnForms);
                      Navigator.pushNamed(
                          context, AppRoutes.formCashAdvanceRequest);
                    },
                    child: Image.asset("assets/cashAdvanse.png"),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'addFab4',
                    mini: true,
                    backgroundColor: AppColors.gradientEnd,
                    onPressed: () {
                      Navigator.pushNamed(
                          context, AppRoutes.mileageExpensefirst);
                    },
                    child: Image.asset("assets/vodometer.png"),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gradientEnd,
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      height: 60,
      color: AppColors.gradientEnd,
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
