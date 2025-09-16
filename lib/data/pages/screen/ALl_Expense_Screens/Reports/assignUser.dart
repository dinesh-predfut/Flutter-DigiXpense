import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../../../core/constant/Parames/params.dart';
import 'package:digi_xpense/data/models.dart';

import '../../../../../core/constant/url.dart';
import '../../../../../l10n/app_localizations.dart';

class UserAssignmentScreen extends StatefulWidget {
  const UserAssignmentScreen({super.key});

  @override
  State<UserAssignmentScreen> createState() => _UserAssignmentScreenState();
}

class _UserAssignmentScreenState extends State<UserAssignmentScreen> {
  List<Users> allUsers = [];
  List<Users> selectedUsers = [];
  TextEditingController searchAvailableController = TextEditingController();
  TextEditingController searchSelectedController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final reportModel = Provider.of<ReportModel>(context, listen: false);

    _initialize(reportModel);
  }

  Future<void> _initialize(ReportModel reportModel) async {
// Wait for this to complete

    if (reportModel.resrecID.isNotEmpty) {
      await fetchSelectedUsers(reportModel.resrecID);
    }
    await fetchUsers();
  }

  Future<void> fetchSelectedUsers(String resrecID) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Urls.baseURL}/api/v1/reports/reports/selectedusers?RefRecId=$resrecID'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          selectedUsers =
              jsonData.map((userJson) => Users.fromJson(userJson)).toList();
        });
      } else {
        print('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Urls.baseURL}/api/v1/reports/reports/availableusers?RefRecId=0'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          allUsers =
              jsonData.map((userJson) => Users.fromJson(userJson)).toList();
        });
        List<Users> fetchedUsers =
            jsonData.map((userJson) => Users.fromJson(userJson)).toList();

        fetchedUsers.removeWhere((user) =>
            selectedUsers.any((sel) => sel.userName == user.userName));
        setState(() {
          allUsers = fetchedUsers;
        });
      } else {
        print('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Move only selected ones
  // Move only selected ones
void moveUsers(bool moveToSelected) {
  final movedUsers = <Users>[];

  if (moveToSelected) {
    // Get only selected users
    movedUsers.addAll(allUsers.where((u) => u.selected));

    setState(() {
      allUsers.removeWhere((u) => u.selected); // remove from source list
      for (var u in movedUsers) {
        u.selected = false; // reset after moving
      }
      selectedUsers.addAll(movedUsers); // add to destination
    });
  } else {
    movedUsers.addAll(selectedUsers.where((u) => u.selected));

    setState(() {
      selectedUsers.removeWhere((u) => u.selected); // remove from source
      for (var u in movedUsers) {
        u.selected = false; // reset after moving
      }
      allUsers.addAll(movedUsers); // add to destination
    });
  }
}


void moveAllUsersToSelected() {
  setState(() {
    for (var u in allUsers) {
      u.selected = false; // reset selection
    }
    selectedUsers.addAll(allUsers);
    allUsers.clear();
  });
}

void moveAllUsersToAvailable() {
  setState(() {
    for (var u in selectedUsers) {
      u.selected = false; // reset selection
    }
    allUsers.addAll(selectedUsers);
    selectedUsers.clear();
  });
}


  List<Users> _filterUsers(List<Users> users, String query) {
    return users
        .where((u) => u.userName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text(
           AppLocalizations.of(context)!.assignUsers,
          style: const TextStyle(color: Colors.white),
        ),
        // backgroundColor: const Color.fromARGB(255, 3, 2, 95),
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // for leading/back icons
        actionsIconTheme:
            const IconThemeData(color: Colors.white), // for action icons
        foregroundColor: Colors.white, // also applies to text/icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Available Users Column
                  Expanded(
                    child: _buildUserList(
                      title:  AppLocalizations.of(context)!.availableUsers,
                      count: allUsers.length,
                      searchController: searchAvailableController,
                      users: _filterUsers(
                          allUsers, searchAvailableController.text),
                    ),
                  ),

                  // Move Buttons + New Move All Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // Move all available -> selected
                            IconButton(
                              icon:
                                  const Icon(Icons.keyboard_double_arrow_down),
                              tooltip: "${ AppLocalizations.of(context)!.moveAll} →",
                              color: Colors.green,
                              iconSize: 32,
                              onPressed: moveAllUsersToSelected,
                            ),
                            // Move selected available -> selected
                            IconButton(
                              icon: const Icon(Icons.arrow_downward_rounded),
                              tooltip: "${ AppLocalizations.of(context)!.moveSelected}→",
                              color: Colors.purple,
                              iconSize: 28,
                              onPressed: () => moveUsers(true),
                            ),
                            const SizedBox(height: 10),
                            // Move selected selected -> available
                            IconButton(
                              icon: const Icon(Icons.arrow_upward_rounded),
                              tooltip: "← ${ AppLocalizations.of(context)!.moveSelected}",
                              color: Colors.purple,
                              iconSize: 28,
                              onPressed: () => moveUsers(false),
                            ),
                            // Move all selected -> available
                            IconButton(
                              icon: const Icon(Icons.keyboard_double_arrow_up),
                              tooltip: "← ${ AppLocalizations.of(context)!.moveAll}",
                              color: Colors.red,
                              iconSize: 32,
                              onPressed: moveAllUsersToAvailable,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Selected Users Column
                  Expanded(
                    child: _buildUserList(
                      title: AppLocalizations.of(context)!.selectUser,
                      count: selectedUsers.length,
                      searchController: searchSelectedController,
                      users: _filterUsers(
                          selectedUsers, searchSelectedController.text),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  AppLocalizations.of(context)!.back,
                  Colors.grey.shade700,
                  Colors.white,
                  () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _actionButton(
                  AppLocalizations.of(context)!.saveReport,
                  const Color.fromARGB(255, 25, 2, 105),
                  Colors.white,
                  () {
                    print(
                      'Selected: ${selectedUsers.map((u) => u.userName).join(", ")}',
                    );
                    if (selectedUsers.isEmpty) {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.pleaseAssignAnyUser,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      reportModel.finelselectedUsers = [...selectedUsers];
                      reportModel.saveReport(context);
                    }
                  },
                ),
                const SizedBox(width: 8),
                _actionButton(
                 AppLocalizations.of(context)!.cancel,
                  Colors.red.shade700,
                  Colors.white,
                  () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList({
    required String title,
    required int count,
    required TextEditingController searchController,
    required List<Users> users,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "$title ($count)",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  labelText: AppLocalizations.of(context)!.search,
                  labelStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(width: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        user.userName,
                        style: const TextStyle(fontSize: 13),
                      ),
                      value: user.selected,
                      activeColor: const Color.fromARGB(255, 24, 2, 107),
                      onChanged: (value) {
                        setState(() {
                          user.selected = value ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor, // text & icon color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // pill shape
        ),
        elevation: 3,
        shadowColor: Colors.black54,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
