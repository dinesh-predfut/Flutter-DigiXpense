import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

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
                      // camera action
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
                      // gallery action
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
                      // Action 2
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
                      // Action 3
                    },
                    child: Image.asset("assets/cashAdvanse.png"),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'addFab4',
                    mini: true,
                    backgroundColor: AppColors.gradientEnd,
                    onPressed: () {
                      // Action 4
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
