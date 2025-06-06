import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:flutter/material.dart';

import '../../../data/pages/screen/widget/router/router.dart';

class MyDrawer extends StatelessWidget {
  final Color gray = Colors.grey.shade700;
  final TextStyle subTextStyle =
      const TextStyle(fontSize: 14, color: Colors.black87);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 270,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/avatar.png')),
                SizedBox(width: 12),
                Text('Rose',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(Icons.chevron_left)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("MAIN", style: TextStyle(color: gray, fontSize: 12)),
          ),
          const ListTile(
              leading: Icon(Icons.home_outlined), title: Text('Dashboard')),
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
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.generalExpense);
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        title: Text('My Team Expense', style: subTextStyle),
                        selectedColor: AppColors.gradientEnd,
                      ),
                    ),
                    ListTile(
                        title: Text('Pending Approvals', style: subTextStyle)),
                    ListTile(title: Text('Un Process', style: subTextStyle)),
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
                        title: Text('My Cash Advance', style: subTextStyle)),
                    ListTile(
                        title:
                            Text('My Team cash Advance', style: subTextStyle)),
                    ListTile(
                        title: Text('Pending Approvals', style: subTextStyle)),
                  ],
                ),
              ),
            ],
          ),
          const ListTile(
              leading: Icon(Icons.mail_outline), title: Text('Email Hub')),
          const ListTile(
              leading: Icon(Icons.calendar_today), title: Text('Approval Hub')),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Text("SETTINGS", style: TextStyle(color: gray, fontSize: 12)),
          ),
          const ListTile(
              leading: Icon(Icons.settings_outlined), title: Text('Settings')),
          const ListTile(
              leading: Icon(Icons.help_outline), title: Text('Help')),
          const ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout Account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
