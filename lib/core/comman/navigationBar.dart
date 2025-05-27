import 'package:flutter/material.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';

import 'Side_Bar/side_bar.dart';

class ScaffoldWithNav extends StatefulWidget {
  final List<Widget> pages;
  const ScaffoldWithNav({
    super.key,
    required this.pages,
    this.initialIndex = 0,
  });  final int initialIndex;

  @override
  _ScaffoldWithNavState createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _dialOpen = false;
  bool _isFabOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;  // ← honor what was passed in
  }
  void _onMainFabPressed() {
    setState(() => _dialOpen = !_dialOpen);
    _dialOpen ? _ctrl.forward() : _ctrl.reverse();
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
    // if you used endDrawer instead:
    // _scaffoldKey.currentState?.openEndDrawer();
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

          // Stacked FABs shown only when _isFabOpen is true
          if (_isFabOpen)
            Positioned(
              bottom: 20,
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
        ],
      ),

      // Main FAB that toggles the small FABs
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gradientEnd,
        elevation: 0,
        onPressed: () {
          setState(() {
            _isFabOpen = !_isFabOpen; // toggle visibility
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
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.smart_toy, color: Colors.white),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: _openMenu,  // ← jump to index 3
            ),
          ],
        ),
      ),
    );
  }
}
