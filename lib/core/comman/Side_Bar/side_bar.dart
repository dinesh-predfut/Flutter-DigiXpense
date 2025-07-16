import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/pages/screen/widget/router/router.dart';
import '../../../data/service.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final Color gray = Colors.grey.shade700;
  final TextStyle subTextStyle =
      const TextStyle(fontSize: 14, color: Colors.black87);
  final controller = Get.put(Controller());

  String selectedMenu = ''; // Track selected menu

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 270,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                      radius: 40,
                      backgroundImage: controller.isImageLoading.value
                          ? null
                          : controller.profileImage.value != null
                              ? FileImage(controller.profileImage.value!)
                              : null,
                      child: controller.isImageLoading.value
                          ? const CircularProgressIndicator()
                          : controller.profileImage.value == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                    )),
                const SizedBox(width: 12),
                Text(
                    controller.firstNameController.text.isNotEmpty
                        ? controller.firstNameController.text
                        : "Name",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("MAIN", style: TextStyle(color: gray, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Dashboard'),
            selected: selectedMenu == 'Dashboard',
            selectedTileColor: Colors.deepPurple.shade100,
            onTap: () {
              setState(() {
                selectedMenu = 'Dashboard';
              });
              Navigator.pushNamed(context, AppRoutes.dashboard_Main);
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Expenses'),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('My Expense', style: subTextStyle),
                      selected: selectedMenu == 'My Expense',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'My Expense';
                        });
                        Navigator.pushNamed(context, AppRoutes.generalExpense);
                      },
                    ),
                    ListTile(
                      title: Text('My Team Expense', style: subTextStyle),
                      selected: selectedMenu == 'My Team Expense',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'My Team Expense';
                        });
                        // Navigate if needed
                      },
                    ),
                    ListTile(
                      title: Text('Pending Approvals', style: subTextStyle),
                      selected: selectedMenu == 'Pending Approvals',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'Pending Approvals';
                        });
                        Navigator.pushNamed(
                            context, AppRoutes.approvalDashboard);
                      },
                    ),
                    ListTile(
                      title: Text('Un Process', style: subTextStyle),
                      selected: selectedMenu == 'Un Process',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'Un Process';
                        });
                        // Navigate if needed
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.money_outlined),
            title: const Text('Cash Advance'),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('My Cash Advance', style: subTextStyle),
                      selected: selectedMenu == 'My Cash Advance',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'My Cash Advance';
                        });
                        // Navigate if needed
                      },
                    ),
                    ListTile(
                      title: Text('My Team cash Advance', style: subTextStyle),
                      selected: selectedMenu == 'My Team cash Advance',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'My Team cash Advance';
                        });
                        // Navigate if needed
                      },
                    ),
                    ListTile(
                      title: Text('Pending Approvals', style: subTextStyle),
                      selected: selectedMenu == 'Cash Pending Approvals',
                      selectedTileColor: Colors.deepPurple.shade100,
                      onTap: () {
                        setState(() {
                          selectedMenu = 'Cash Pending Approvals';
                        });
                        // Navigate if needed
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Email Hub'),
            selected: selectedMenu == 'Email Hub',
            selectedTileColor: Colors.deepPurple.shade100,
            onTap: () {
              setState(() {
                selectedMenu = 'Email Hub';
              });
              // Navigate if needed
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Approval Hub'),
            selected: selectedMenu == 'Approval Hub',
            selectedTileColor: Colors.deepPurple.shade100,
            onTap: () {
              setState(() {
                selectedMenu = 'Approval Hub';
              });
              // Navigate if needed
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Text("SETTINGS", style: TextStyle(color: gray, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            selected: selectedMenu == 'Settings',
            selectedTileColor: Colors.deepPurple.shade100,
            onTap: () {
              setState(() {
                selectedMenu = 'Settings';
              });
              // Navigate if needed
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            selected: selectedMenu == 'Help',
            selectedTileColor: Colors.deepPurple.shade100,
            onTap: () {
              setState(() {
                selectedMenu = 'Help';
              });
              // Navigate if needed
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () async {
              setState(() {
                controller.profileImage.value = null;
              });

              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.signin,
                (route) => false,
              );
            },
            title: const Text(
              'Log out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
