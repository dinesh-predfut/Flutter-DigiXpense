import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../data/pages/screen/widget/router/router.dart';
import '../../../data/service.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(Controller());
  String selectedMenu = ''; // Track selected menu
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Drawer Menu Item Widget
  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required String menuKey,
    VoidCallback? onTap,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0), // Slide from left
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selectedMenu == menuKey ? Colors.deepPurple : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selectedMenu == menuKey ? Colors.deepPurple : Colors.black87,
            fontWeight:
                selectedMenu == menuKey ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: selectedMenu == menuKey,
        selectedTileColor: Colors.deepPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          setState(() {
            selectedMenu = menuKey;
          });
          onTap?.call();
        },
      ),
    );
  }

  /// Drawer Header Widget
  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurpleAccent.shade200,
            Colors.deepPurple.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          Obx(() => CircleAvatar(
                radius: 35,
                backgroundImage: controller.isImageLoading.value
                    ? null
                    : controller.profileImage.value != null
                        ? FileImage(controller.profileImage.value!)
                        : null,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: controller.isImageLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : controller.profileImage.value == null
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.white)
                        : null,
              )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Greeting
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText("Hello, 👋"),
                      TyperAnimatedText("Hi there, "),
                      TyperAnimatedText("Welcome back, "),
                    ],
                    repeatForever: true,
                    isRepeatingAnimation: true,
                    pause: const Duration(milliseconds: 800),
                  ),
                ),
                const SizedBox(height: 4),

                // Animated Name
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        Params.userName.isNotEmpty
                            ? Params.userName
                            : "User Name",
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1, // Play once
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),

            // 🌟 Main Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("MAIN",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ),
            _buildDrawerItem(
              title: "Dashboard",
              icon: Icons.home_outlined,
              menuKey: "Dashboard",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.dashboard_Main);
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Expenses"),
              childrenPadding: const EdgeInsets.only(left: 16),
              children: [
                _buildDrawerItem(
                  title: "My Expenses",
                  icon: Icons.arrow_right,
                  menuKey: "My Expenses",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.generalExpense);
                  },
                ),
                _buildDrawerItem(
                  title: "My Team Expenses",
                  icon: Icons.arrow_right,
                  menuKey: "My Team Expenses",
                  onTap: () {
                     Navigator.pushNamed(context, AppRoutes.myTeamExpenseDashboard);
                  },
                ),
                _buildDrawerItem(
                  title: "Pending Approvals",
                  icon: Icons.arrow_right,
                  menuKey: "Pending Approvals",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.approvalDashboard);
                  },
                ),
                _buildDrawerItem(
                  title: "Un Processed",
                  icon: Icons.arrow_right,
                  menuKey: "Un Processed",
                  onTap: () {
                     Navigator.pushNamed(context, AppRoutes.unProcessed);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.money_outlined),
              title: const Text("Cash Advances"),
              childrenPadding: const EdgeInsets.only(left: 16),
              children: [
                _buildDrawerItem(
                  title: "My Cash Advances",
                  icon: Icons.arrow_right,
                  menuKey: "My Cash Advances",
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppRoutes.cashAdvanceRequestDashboard);
                  },
                ),
                _buildDrawerItem(
                  title: "My Team Cash Advances",
                  icon: Icons.arrow_right,
                  menuKey: "My Team Cash Advances",
                  onTap: () {
                     Navigator.pushNamed(
                        context, AppRoutes.myTeamcashAdvanceDashboard);
                  },
                ),
                _buildDrawerItem(
                  title: "Pending Approvals",
                  icon: Icons.arrow_right,
                  menuKey: "Pending Approvals",
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppRoutes.approvalDashboardForDashboard);
                  },
                ),
              ],
            ),

            _buildDrawerItem(
              title: "Email Hub",
              icon: Icons.mail_outline,
              menuKey: "Email Hub",
            ),
            _buildDrawerItem(
              title: "Approval Hub",
              icon: Icons.calendar_today,
              menuKey: "Approval Hub",
            ),

            const Divider(),

            // ⚙️ Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("SETTINGS",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ),
            _buildDrawerItem(
              title: "Settings",
              icon: Icons.settings_outlined,
              menuKey: "Settings",
            ),
            _buildDrawerItem(
              title: "Help",
              icon: Icons.help_outline,
              menuKey: "Help",
            ),

            // 🔴 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Log out",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                controller.profileImage.value = null;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.signin,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
