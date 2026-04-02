import 'dart:convert' show jsonEncode;
import 'dart:io';

import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart'
    show MultiSelectMultiColumnDropdownField;
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/core/constant/url.dart';
import 'package:diginexa/data/models.dart'
    show KanbanBoard, Shelf, TaskItem, Employee, BoardMember;
import 'package:diginexa/data/pages/API_Service/apiService.dart';
import 'package:diginexa/data/pages/screen/Task_Board/addmoreetailsTask.dart'
    show TaskDetailsPage;
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/API_Service/apiService.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String boardId;

  const KanbanBoardScreen({super.key, required this.boardId});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  final Controller controller = Get.find<Controller>();
  bool isSheetAlive = true;

  KanbanBoard? board;
  bool isLoading = true;
  KanbanBoard? originalBoard;
  KanbanBoard? filteredBoard;
  bool isFiltered = false;
  bool get isDarkBoard => filteredBoard?.boardTheme?.toLowerCase() == 'dark';
  late final List<String> _tabTitles = [
    AppLocalizations.of(context)!.board,
    AppLocalizations.of(context)!.grid,
    AppLocalizations.of(context)!.boardSettings,
  ];
  int _selectedTabIndex = 0;
  final TextEditingController searchCtrl = TextEditingController();
  String selectedPriority = 'All';
  String selectedShelf = 'All';
  String selectedLable = 'All';
  String selectedUser = 'All';
  String createBy = 'All';
  String selectedDueDate = 'No Date';
  List<String> getTabTitles(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    List<String> tabs = [loc.board];

    // 👇 Show Grid only if Read permission
    if (PermissionHelper.canRead("Board Management")) {
      tabs.add(loc.grid);
    }

    // 👇 Show Settings only if Update permission
    if (PermissionHelper.canUpdate("Board Management")) {
      tabs.add(loc.boardSettings);
    }

    return tabs;
  }

  @override
  void initState() {
    super.initState();
    controller.fetchEmployeeGroups();
    controller.fetchEmployees();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadKanbanBoard();
    });
  }

  Future<void> loadKanbanBoard() async {
    setState(() => isLoading = true);

    final result = await controller.fetchKanbanBoardAndNavigate(
      context,
      widget.boardId,
      true,
    );

    if (result != null) {
      result.shelfs.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      originalBoard = result;
      controller.originalBoard = result;
      filteredBoard = result;
      controller.shelves.assignAll(result.shelfs);
    }

    setState(() => isLoading = false);
  }

  Future<void> withOutLoadloadKanbanBoard() async {
    // setState(() => isLoading = true);

    final result = await controller.fetchKanbanBoardAndNavigate(
      context,
      widget.boardId,
      true,
    );

    if (result != null) {
      result.shelfs.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      originalBoard = result;
      controller.originalBoard = result;
      filteredBoard = result;
      controller.shelves.assignAll(result.shelfs);
    }

    // setState(() => isLoading = false);
  }
  /* ---------------- FILTER DATA ---------------- */

  List<String> get priorities => ["All", "Low", "Medium", "High"];

  List<String> get shelves => [
    'All',
    ...originalBoard!.shelfs.map((e) => e.shelfName),
  ];
  List<String> get tags {
    if (originalBoard == null) return ['All'];

    final tagSet = <String>{};

    for (final shelf in originalBoard!.shelfs) {
      for (final task in shelf.tasks) {
        for (final tag in task.tags) {
          if (tag.tagName != null && tag.tagName.isNotEmpty) {
            tagSet.add(tag.tagName);
          }
        }
      }
    }

    return ['All', ...tagSet];
  }

  List<String> get users {
    final set = <String>{};

    for (final s in originalBoard!.shelfs) {
      for (final t in s.tasks) {
        for (final u in t.assignedTo) {
          set.add(u.employeeName);
        }
      }
    }

    return ['All', ...set];
  }

  List<String> get createusers {
    final set = <String>{};

    for (final s in originalBoard!.shelfs) {
      for (final t in s.tasks) {
        for (final u in t.assignedTo) {
          set.add(u.employeeName);
        }
      }
    }

    return ['ALL', ...set];
  }

  /* ---------------- APPLY FILTERS ---------------- */
  void applyFilters([String? dueDateValue]) {
    if (originalBoard == null) return;

    final String keyword = searchCtrl.text.toLowerCase();
    final List<Shelf> filteredShelves = [];

    for (final shelf in originalBoard!.shelfs) {
      // Shelf name filter
      if (selectedShelf != 'All' && shelf.shelfName != selectedShelf) continue;

      final List<TaskItem> filteredTasks = [];

      for (final task in shelf.tasks) {
        /// 🔍 SEARCH FILTER
        final bool matchesSearch =
            keyword.isEmpty ||
            task.taskName.toLowerCase().contains(keyword) ||
            task.assignedTo.any(
              (u) => u.employeeName.toLowerCase().contains(keyword),
            );

        /// ⚡ PRIORITY FILTER
        final bool matchesPriority =
            selectedPriority == 'All' || task.priority == selectedPriority;

        /// 👤 ASSIGNED USER FILTER
        final bool matchesUser =
            selectedUser == 'All' ||
            task.assignedTo.any((user) => user.employeeName == selectedUser);

        /// ✏️ CREATED BY FILTER
        final bool matchesCreatedBy =
            createBy == 'All' ||
            (task.createdBy != null && task.createdBy!.userName == createBy);

        /// 🏷️ TAG FILTER (NEW)
        final bool matchesTag =
            selectedLable == 'All' ||
            task.tags.any((tag) => tag.tagName == selectedLable);

        /// 📅 DUE DATE FILTER
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        bool matchesDueDate = true;

        if (dueDateValue == 'Today') {
          matchesDueDate =
              task.plannedStartDate != null &&
              DateUtils.isSameDay(task.plannedStartDate!, todayOnly);
        } else if (dueDateValue == 'Late') {
          matchesDueDate =
              task.plannedStartDate != null &&
              task.plannedStartDate!.isBefore(todayOnly);
        }

        /// ✅ FINAL CONDITION
        if (matchesSearch &&
            matchesPriority &&
            matchesUser &&
            matchesCreatedBy &&
            matchesTag &&
            matchesDueDate) {
          filteredTasks.add(task);
        }
      }

      filteredShelves.add(
        Shelf(
          image: shelf.image,
          shelfId: shelf.shelfId,
          shelfName: shelf.shelfName,
          sortOrder: shelf.sortOrder,
          boardId: shelf.boardId,
          recId: shelf.recId,
          tasks: filteredTasks,
          isCollapsed: shelf.isCollapsed,
          colorPallete: shelf.colorPallete,
        ),
      );
    }

    setState(() {
      filteredBoard = KanbanBoard(
        boardId: originalBoard!.boardId,
        boardName: originalBoard!.boardName,
        shelfs: filteredShelves,
        boardTheme: originalBoard!.boardTheme,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || filteredBoard == null) {
      return const Scaffold(body: Center(child: SkeletonLoaderPage()));
    }
    final backgroundImageUrl = getBoardBackgroundImage(
      filteredBoard!.backgroundImageUrl,
    );

    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        controller.leaveField.value = false;

        controller.resetForm();
        Navigator.pushNamed(context, AppRoutes.boardDashboard);

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(filteredBoard!.boardName)),
        body: Container(
          decoration: BoxDecoration(
            color: backgroundImageUrl == null
                ? (filteredBoard!.isDarkBoard
                      ? Colors.black
                      : Colors.grey.shade100)
                : null,
            image: backgroundImageUrl != null
                ? DecorationImage(image: backgroundImageUrl, fit: BoxFit.cover)
                : null,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (PermissionHelper.canRead("Board Management"))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: isDarkBoard ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: List.generate(_tabTitles.length, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = index;
                                if (index == 0) {
                                  withOutLoadloadKanbanBoard();
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == index
                                    ? theme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTabIndex == index
                                    ? [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  _tabTitles[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedTabIndex == index
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              if (_selectedTabIndex == 0) ...[
                _buildSearchBar(),
                _buildFilterRow(),
                Expanded(child: _buildKanban()),
              ],
              if (_selectedTabIndex == 1) ...[
                Expanded(
                  child: _buildCardViewContent(
                    context,
                    loadKanbanBoard: loadKanbanBoard,
                  ),
                ),
              ],
              if (_selectedTabIndex == 2) ...[
                Expanded(
                  child: BoardSettingsWidget(
                    boardId: widget.boardId,
                    loadKanbanBoard: loadKanbanBoard,
                  ),
                ),
              ],
            ],
          ),
        ),
        floatingActionButton: _selectedTabIndex == 0
            ? FloatingActionButton.extended(
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.addShelf,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showAddShelfBottomSheet(
                    context,
                    boardId: widget.boardId,
                    nextSortOrder: originalBoard!.shelfs.length + 1,
                    onShelfAdded: loadKanbanBoard,
                  );
                },
              )
            : null,
      ),
    );
  }

  ImageProvider? getBoardBackgroundImage(String? value) {
    if (value == null || value.isEmpty) return null;

    /// BASE64 IMAGE
    if (value.startsWith('data:image')) {
      try {
        return MemoryImage(base64Decode(value.split(',').last));
      } catch (_) {
        return null;
      }
    }

    /// NETWORK IMAGE
    if (value.startsWith('http')) {
      return NetworkImage(value);
    }

    return null;
  }

  Widget _buildCardViewContent(
    BuildContext context, {
    required Future<void> Function() loadKanbanBoard,
  }) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonLoaderPage();
      }

      final tasks = controller.allTasks;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addTask),
                  onPressed: () async {
                    await showAddTaskBottomSheetInSecond(
                      context,
                      boardId: widget.boardId,
                      loadKanbanBoard: loadKanbanBoard,
                    );
                  },
                ),
              ),
            ],
          ),

          /// 🔹 TASK LIST
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No Tasks Found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, idx) {
                      final task = tasks[idx];

                      return Dismissible(
                        key: ValueKey(task.taskId),

                        background: _buildSwipeActionLeft(isLoading),

                        /// 👉 Swipe Left (Delete)
                        secondaryBackground: _buildSwipeActionRight(),

                        confirmDismiss: (direction) async {
                          /// 🔹 Swipe → View
                          if (direction == DismissDirection.startToEnd) {
                            setState(() => isLoading = true);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailsPage(
                                  taskRecId: task.recId,
                                  bordeId: originalBoard!.boardId,
                                  mainAccess: false,
                                ),
                              ),
                            );

                            setState(() => isLoading = false);
                            return false;
                          }

                          /// 🔹 Swipe ← Delete
                          if (direction == DismissDirection.endToStart) {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.delete,
                                ),
                                content: Text(
                                  'Delete task "${task.taskName}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.delete,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              setState(() => isLoading = true);

                              setState(() => isLoading = false);
                              return true;
                            }
                          }

                          return false;
                        },

                        /// 🔹 TASK CARD
                        child: _buildTaskStyledCard(task, context),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildTaskStyledCard(TaskItem task, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsPage(
              taskRecId: task.recId,
              bordeId: originalBoard!.boardId,
              mainAccess: false,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              /// 🔹 Due Date (Top Right)
              // Positioned(
              //   right: 0,
              //   top: 0,
              //   child: Text(
              //     formatTaskDate(task.plannedStartDate),
              //     style: TextStyle(
              //       fontSize: 11,
              //       color: Colors.grey[600],
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Task Name (Title)
                  Text(
                    task.taskName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// 🔹 Priority | Status (like Leave meta row)
                  Text(
                    'Priority: ${task.priority} | Status: ${task.statusName}',
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 Approval-like Status (Right aligned)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      task.statusName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: _statusColor(task.statusName),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'Milestone':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'No Due Date';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Widget _buildSwipeActionLeft(bool isLoading) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.blue.shade100,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          else
            const Icon(Icons.remove_red_eye, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            isLoading ? loc.loading : loc.view,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      alignment: Alignment.centerRight,
      color: const Color.fromARGB(255, 115, 142, 229),
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.delete,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }

  String formatDateFromMillis(int? millis) {
    if (millis == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  Future<void> showAddShelfBottomSheet(
    BuildContext context, {
    required String boardId,
    required int nextSortOrder,
    required VoidCallback onShelfAdded,
  }) async {
    final TextEditingController shelfNameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();

    bool isCreating = false;

    File? selectedImage;
    String? base64Image;
    String? fileName;

    Color selectedColor = hexToColor('#FFFFFF');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isCreating = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkBoard ? Colors.black : Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.addShelf,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkBoard ? Colors.white : Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        /// 📷 IMAGE PICKER
                        InkWell(
                          onTap: () async {
                            final picker = ImagePicker();
                            final XFile? picked = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (picked == null || !isSheetAlive) return;

                            final bytes = await File(picked.path).readAsBytes();

                            if (!isSheetAlive) return;

                            setState(() {
                              selectedImage = File(picked.path);
                              base64Image =
                                  "data:image/png;base64,${base64Encode(bytes)}";
                              fileName = picked.name;
                            });
                          },

                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                              image: selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: selectedImage == null
                                ? Icon(
                                    Icons.image,
                                    color: isDarkBoard
                                        ? Colors.white
                                        : Colors.black,
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(width: 16),

                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Pick Color"),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: (color) {
                                      setState(() => selectedColor = color);
                                    },
                                    enableAlpha:
                                        false, // remove transparency slider
                                    displayThumbColor: true,
                                    pickerAreaHeightPercent: 0.8,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Done"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// SHELF NAME
                    TextField(
                      controller: shelfNameCtrl,

                      decoration: InputDecoration(
                        labelText:
                            '${AppLocalizations.of(context)!.shelfName} *',
                        labelStyle: TextStyle(
                          color: isDarkBoard ? Colors.white : Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// DESCRIPTION
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,

                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: isDarkBoard ? Colors.white : Colors.black,
                        ),
                        labelText: AppLocalizations.of(context)!.description,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isCreating
                                ? null
                                : () async {
                                    if (shelfNameCtrl.text.trim().isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: AppLocalizations.of(
                                          context,
                                        )!.shelfNameRequired,
                                        backgroundColor: Colors.red[200],
                                        textColor: Colors.red[800],
                                      );
                                      return;
                                    }
                                    setState(() => isCreating = true);
                                    final payload = {
                                      "BoardId": boardId,
                                      "ShelfName": shelfNameCtrl.text,
                                      "Description": descCtrl.text,
                                      "ColorPallete":
                                          '#${selectedColor.value.toRadixString(16).substring(2)}',
                                      "FileName": fileName ?? "",
                                      "SortOrder": 6,
                                      "base64Data": base64Image ?? "",
                                      "WIPLimit": 0,
                                    };
                                    try {
                                      final res = await ApiService.post(
                                        Uri.parse(
                                          "${Urls.baseURL}/api/v1/kanban/shelfs/shelfs/shelfs",
                                        ),
                                        body: jsonEncode(payload),
                                      );
                                      final Map<String, dynamic> responseData =
                                          jsonDecode(res.body);
                                      final String message =
                                          responseData['detail']?['message'] ??
                                          'No message found';
                                      if (res.statusCode == 200 ||
                                          res.statusCode == 201) {
                                        Fluttertoast.showToast(
                                          msg: message,
                                          backgroundColor: Colors.green[200],
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          textColor: Colors.green[800],
                                          fontSize: 16.0,
                                        );
                                        isSheetAlive =
                                            false; // 🔑 mark disposed
                                        Navigator.pop(context);
                                        loadKanbanBoard();
                                        return;
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: message,
                                          backgroundColor: Colors.red[200],
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          textColor: Colors.red[800],
                                          fontSize: 16.0,
                                        );
                                      }
                                    } catch (_) {
                                      if (!isSheetAlive) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(content: Text("Failed")),
                                      );
                                    }

                                    if (!isSheetAlive) return;
                                    setState(() => isCreating = false);
                                  },

                            child: isCreating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(AppLocalizations.of(context)!.save),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: searchCtrl,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchTasksUsersTags,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (_) => applyFilters(),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkBoard ? Colors.black : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterDropdown(
              icon: Icons.flag,
              label: AppLocalizations.of(context)!.priority,
              value: selectedPriority,
              items: priorities,
              onChanged: (v) {
                selectedPriority = v;
                applyFilters();
              },
            ),

            _filterDropdown(
              icon: Icons.view_column,
              label: AppLocalizations.of(context)!.shelfName,
              value: selectedShelf,
              items: shelves,
              onChanged: (v) {
                selectedShelf = v;
                applyFilters();
              },
            ),
            _filterDropdown(
              icon: Icons.view_column,
              label: AppLocalizations.of(context)!.label,
              value: selectedLable,
              items: tags,
              onChanged: (v) {
                selectedLable = v;
                applyFilters();
              },
            ),
            _filterDropdownEmployee(
              icon: Icons.person_outline,
              label: AppLocalizations.of(context)!.assignUsers,
              value: selectedUser,
              items: users,
              onChanged: (v) {
                selectedUser = v;
                applyFilters();
              },
            ),
            _filterDropdownEmployee(
              icon: Icons.person_outline,
              label: AppLocalizations.of(context)!.createdBy,
              value: createBy,
              items: createusers,
              onChanged: (v) {
                createBy = v;
                applyFilters();
              },
            ),
            _dateFilterDropdown(
              value: selectedDueDate,
              onChanged: (String value) {
                print('selectedDueDate$value');
                selectedDueDate = value;
                applyFilters(value);
              },
            ),

            if (_hasActiveFilters()) _clearFiltersButton(),
          ],
        ),
      ),
    );
  }

  Widget _clearFiltersButton() {
    return TextButton(
      onPressed: clearAllFilters,
      child: const Text('Clear Filters'),
    );
  }

  void clearAllFilters() {
    searchCtrl.clear();
    selectedShelf = 'All';
    selectedPriority = 'All';
    selectedUser = 'All';
    selectedLable = 'All';
    createBy = 'All';
    selectedDueDate = 'No Date';

    applyFilters();
  }

  void clearFilters() {
    setState(() {
      searchCtrl.clear();
      selectedPriority = 'All';
      selectedShelf = 'All';
      selectedUser = 'All';
      selectedLable = 'All';
      selectedDueDate = 'No Date';
      createBy = 'All';
      // Reset board view
      filteredBoard = null;
    });
  }

  bool _hasActiveFilters() {
    return selectedPriority != 'All' ||
        selectedShelf != 'All' ||
        createBy != 'All' ||
        selectedUser != 'All' ||
        selectedLable != 'All' ||
        selectedDueDate != 'No Date' ||
        searchCtrl.text.isNotEmpty;
  }

  Widget _dateFilterDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final List<String> items = ['Late', 'Today', 'No Date'];

    /// ✅ prevent dropdown crash
    final safeValue = items.contains(value) ? value : 'No Date';

    final bool isActive = safeValue != 'No Date';

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          color: isDarkBoard ? Colors.black : Colors.grey.shade100,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeValue,
            isDense: true,
            icon: const Icon(Icons.arrow_drop_down),
            dropdownColor: Theme.of(context).cardColor,
            onChanged: (v) => onChanged(v!),

            /// dropdown menu items
            items: items.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }).toList(),

            /// selected display style
            selectedItemBuilder: (context) {
              return items.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Due Date', // 🔹 localize later if needed
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          e,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final bool isActive = value != 'All';

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          color: isDarkBoard ? Colors.black : Colors.grey.shade100,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (v) => onChanged(v!),
            dropdownColor: Theme.of(context).cardColor,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (context) {
              return items.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          e,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _filterDropdownEmployee({
    required IconData icon,
    required String label,
    required String? value, // allow null
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    // Ensure value exists in items, else fallback to null
    final String? safeValue = items.contains(value) ? value : null;

    // Determine if active (anything other than 'All')
    final bool isActive = safeValue != null && safeValue != 'All';

    // Remove duplicates
    final List<String> uniqueItems = items.toSet().toList();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          color: isDarkBoard ? Colors.black : Colors.grey.shade100,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeValue,
            isDense: true,
            icon: const Icon(Icons.arrow_drop_down),
            hint: Text(
              label,
              style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
            ),
            onChanged: (v) {
              if (v != null) {
                onChanged(v);
                setState(() {}); // rebuild to update styles
              }
            },
            dropdownColor: Theme.of(context).cardColor,
            items: uniqueItems.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8),
                ),
              );
            }).toList(),
            selectedItemBuilder: (context) {
              return uniqueItems.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          e,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKanban() {
    final KanbanBoard? viewBoard = filteredBoard ?? originalBoard;

    if (viewBoard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      buildDefaultDragHandles: false,
      itemCount: viewBoard.shelfs.length,
      onReorder: (oldIndex, newIndex) async {
        if (filteredBoard != null &&
            filteredBoard!.shelfs.length != originalBoard!.shelfs.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clear filters to reorder shelves')),
          );
          return;
        }

        if (newIndex > oldIndex) newIndex--;

        final movedShelf = originalBoard!.shelfs.removeAt(oldIndex);
        originalBoard!.shelfs.insert(newIndex, movedShelf);

        setState(() {
          filteredBoard = originalBoard;
        });

        await controller.updateShelfOrder(
          recId: movedShelf.recId,
          newSortOrder: newIndex + 1,
        );
      },
      itemBuilder: (context, index) {
        final shelf = viewBoard.shelfs[index];

        return Container(
          key: ValueKey(shelf.shelfId),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: ReorderableDelayedDragStartListener(
            index: index,
            child: _ShelfColumn(
              isDarkBoard: isDarkBoard,
              shelf: shelf,
              boardId: viewBoard.boardId,
              onToggle: () {
                setState(() {
                  shelf.isCollapsed = !shelf.isCollapsed;
                });
              },
              onTaskAdded: loadKanbanBoard,
            ),
          ),
        );
      },
    );
  }
}

class _ShelfColumn extends StatelessWidget {
  final Shelf shelf;
  final String boardId;
  final VoidCallback onToggle;
  final VoidCallback onTaskAdded;
  final bool isDarkBoard;
  const _ShelfColumn({
    required this.shelf,
    required this.boardId,
    required this.onToggle,
    required this.onTaskAdded,
    required this.isDarkBoard,
  });

  @override
  Widget build(BuildContext context) {
    final Controller controller = Get.find<Controller>();
    bool isSheetAlive = true;
    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonLoaderPage();
      }

      return Container(
        width: shelf.isCollapsed ? 60 : 300,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          // ✅ Add border here
          border: Border.all(
            color: isDarkBoard
                ? Colors.white
                : Colors.black, // your border color
            width: 1.5, // thickness
          ),
        ),

        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: shelf.isCollapsed
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            child: Text(
                              shelf.tasks.length.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 30),
                          RotatedBox(
                            quarterTurns: 3, // 90° vertical text
                            child: Text(
                              shelf.shelfName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDarkBoard
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _shelfAvatar(shelf.image, size: 24),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              shelf.shelfName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                // color: Colors.black,
                              ),
                            ),
                          ),

                          CircleAvatar(
                            radius: 12,
                            child: Text(
                              shelf.tasks.length.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),

                          const SizedBox(width: 6),

                          /// Burger / Kebab menu
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert, // burger icon
                              color: isDarkBoard ? Colors.white : Colors.black,
                              size: 20,
                            ),
                            onSelected: (value) {
                              if (value == AppLocalizations.of(context)!.edit) {
                                _editShelf(
                                  context,
                                  shelf,
                                  onTaskAdded,
                                  isDarkBoard,
                                );
                              } else if (value ==
                                  AppLocalizations.of(context)!.delete) {
                                _deleteShelf(shelf, context);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: AppLocalizations.of(context)!.edit,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit Shelf'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: AppLocalizations.of(context)!.delete,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Delete Shelf'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Icon(
                            shelf.isCollapsed
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                            color: isDarkBoard ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
              ),
            ),

            if (!shelf.isCollapsed)
              Expanded(
                child: shelf.tasks.isEmpty
                    ? const Center(child: Text("No tasks"))
                    : ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: shelf.tasks.length,
                        itemBuilder: (_, i) => _TaskCard(
                          task: shelf.tasks[i],
                          boardIdNumb: boardId,
                          isDarkBoard: isDarkBoard,
                          callApi: onTaskAdded,
                          onTap: () {
                            print(
                              "Open task details: ${shelf.tasks[i].taskName}",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailsPage(
                                  taskRecId: shelf.tasks[i].recId,
                                  bordeId: shelf.boardId,
                                  mainAccess: true,
                                ),
                              ),
                            );
                            // Get.to(() => TaskDetailsPage(task: task));
                          },
                        ),
                      ),
              ),

            if (!shelf.isCollapsed)
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addTask),
                  onPressed: () async {
                    await showAddTaskBottomSheet(
                      context,
                      shelfId: shelf.shelfId,
                      boardId: boardId,
                      onTaskAdded: onTaskAdded,
                    );
                  },
                ),
              ),

            const SizedBox(height: 26),
          ],
        ),
      );
    });
  }
}

Widget _shelfAvatar(String? url, {double size = 22}) {
  if (url == null || url.isEmpty) {
    return CircleAvatar(
      radius: size / 2,
      child: const Icon(Icons.person, size: 12),
    );
  }

  return CircleAvatar(
    radius: size / 2,
    backgroundColor: Colors.grey.shade200,
    backgroundImage: NetworkImage(url),
    onBackgroundImageError: (_, __) {},
    child: null,
  );
}

Future<void> _editShelf(
  BuildContext context,
  Shelf shelf,
  VoidCallback onTaskAdded,
  bool isDarkBoard,
) async {
  final shelfData = await fetchShelfDetail(shelf.recId);

  if (shelfData == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Failed to load shelf")));
    return;
  }

  await showAddShelfBottomSheet(
    context,
    boardId: shelf.boardId,
    nextSortOrder: shelf.sortOrder,
    onShelfAdded: onTaskAdded,
    isDarkBoard: isDarkBoard,
    shelfData: shelfData,
  );
}

Future<Map<String, dynamic>?> fetchShelfDetail(int recId) async {
  final uri = Uri.parse(
    "${Urls.baseURL}/api/v1/kanban/shelfs/shelfs/shelfs"
    "?filter_query=KANShelfs.RecId__eq=$recId"
    "&page=1&sort_order=asc&screen_name=KANShelfs",
  );

  final res = await ApiService.get(uri);

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data is List && data.isNotEmpty) {
      return data.first;
    }
  }
  return null;
}

void _deleteShelf(Shelf shelf, BuildContext context) {
  _confirmDelete(context, shelf.recId, shelf.boardId);
  // confirmation dialog
  print('Delete Shelf: ${shelf.shelfName}');
}

Future<void> _confirmDelete(context, int recIds, String boardId) async {
  final controller = Get.put(Controller());

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Shelf'),
      content: const Text('Are you sure you want to delete this task?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (result == true) {
    controller.deleteShelf(
      recId: recIds,
      context: context,
      boardIdNumb: boardId,
    );
  }
}

Future<void> showAddShelfBottomSheet(
  BuildContext context, {
  required String boardId,
  required int nextSortOrder,
  required VoidCallback onShelfAdded,
  required Map<String, dynamic> shelfData,
  required bool isDarkBoard,
}) async {
  final shelfNameCtrl = TextEditingController(
    text: shelfData['ShelfName'] ?? '',
  );

  final descCtrl = TextEditingController(text: shelfData['Description'] ?? '');

  final controller = Get.put(Controller());

  Color selectedColor = shelfData['ColorPallete'] != null
      ? hexToColor(shelfData['ColorPallete'])
      : hexToColor('#FFFFFF');

  final int recId = shelfData['RecId'];

  File? selectedImage;
  String? base64Image;
  String? fileName;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      bool isSheetAlive = true;
      bool isCreating = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkBoard ? Colors.black : Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.50,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // /// LOADER
                        // if (controller.isCreating)
                        //   const SizedBox(
                        //     height: 120,
                        //     child: Center(child: SkeletonLoaderPage()),
                        //   ),

                        // /// HEADER
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.addShelf,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkBoard ? Colors.white : Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// IMAGE + COLOR ROW
                        Row(
                          children: [
                            /// IMAGE PICKER
                            InkWell(
                              onTap: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );

                                if (picked == null || !isSheetAlive) return;

                                final bytes = await File(
                                  picked.path,
                                ).readAsBytes();

                                if (!isSheetAlive) return;

                                setState(() {
                                  selectedImage = File(picked.path);
                                  base64Image =
                                      "data:image/png;base64,${base64Encode(bytes)}";
                                  fileName = picked.name;
                                });
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  image: selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: selectedImage == null
                                    ? Icon(
                                        Icons.image,
                                        color: isDarkBoard
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 16),

                            /// COLOR PICKER
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Pick Color"),
                                    content: SizedBox(
                                      height: 400,
                                      width: 300,
                                      child: ColorPicker(
                                        pickerColor: selectedColor,
                                        onColorChanged: (c) =>
                                            selectedColor = c,
                                        enableAlpha: false,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Done"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// SHELF NAME
                        TextField(
                          controller: shelfNameCtrl,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.shelfName} *',
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// DESCRIPTION
                        TextField(
                          controller: descCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.description,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ACTION BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.isCreating
                                    ? null
                                    : () async {
                                        if (shelfNameCtrl.text.trim().isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: AppLocalizations.of(
                                              context,
                                            )!.shelfNameRequired,
                                            backgroundColor: Colors.red[200],
                                            textColor: Colors.red[800],
                                          );
                                          return;
                                        }
                                        setState(() => isCreating = true);

                                        final payload = {
                                          "BoardId": boardId,
                                          "ShelfName": shelfNameCtrl.text,
                                          "Description": descCtrl.text,
                                          "ColorPallete":
                                              '#${selectedColor.value.toRadixString(16).substring(2)}',
                                          "FileName": fileName ?? "",
                                          "SortOrder": nextSortOrder,
                                          "base64Data": base64Image ?? "",
                                          "WIPLimit": 0,
                                        };

                                        try {
                                          final res = await ApiService.put(
                                            Uri.parse(
                                              "${Urls.baseURL}/api/v1/kanban/shelfs/shelfs/shelfsedit?RecId=$recId",
                                            ),
                                            body: jsonEncode(payload),
                                          );

                                          final data = jsonDecode(res.body);
                                          final message =
                                              data['detail']?['message'] ??
                                              'Done';

                                          if (res.statusCode == 200 ||
                                              res.statusCode == 280) {
                                            Navigator.pop(context);
                                            onShelfAdded();

                                            Fluttertoast.showToast(
                                              msg: message,
                                              backgroundColor: Colors.green,
                                            );
                                            setState(() => isCreating = true);
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: message,
                                              backgroundColor: Colors.red,
                                            );
                                            setState(() => isCreating = true);
                                          }
                                        } catch (_) {
                                          if (!isSheetAlive) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Failed"),
                                            ),
                                          );
                                        }

                                        setState(() => isCreating = false);
                                      },
                                child: isCreating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.update,
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Color getShelfColor(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.white;

  try {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return Colors.white;
  }
}

Color hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) {
    return Colors.white; // ✅ fallback color
  }

  hex = hex.replaceAll('#', '');

  if (hex.length == 6) {
    hex = 'FF$hex'; // add alpha
  }

  try {
    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return Colors.white; // ✅ invalid hex safety
  }
}

class _TaskCard extends StatefulWidget {
  final TaskItem task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? callApi;
  final String boardIdNumb;
  final bool isDarkBoard;

  const _TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    required this.boardIdNumb,
    required this.isDarkBoard,
    required this.callApi,
  }) : super(key: key);

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  late List<TaskChecklist> checklist;
  final controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checklist = List.from(widget.task.checkLists);
    controller.fetchCardFields(widget.boardIdNumb);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // color: Colors.white,
          border: Border.all(
            color: widget.isDarkBoard
                ? const Color.fromARGB(83, 255, 255, 255)
                : const Color.fromARGB(92, 0, 0, 0), // your border color
            width: 1.5, // thickness
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.task.taskName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      197,
                      196,
                      195,
                    ), // 👈 background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.task.statusName,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) {
                    if (value == 2) {
                      _showDeleteConfirm(
                        context,
                        widget.task.recId,
                        widget.callApi,
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 2, child: Text('Delete')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// 🔹 LEFT → CALENDAR + DATE
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.task.plannedEndDate != null
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).format(widget.task.plannedEndDate!)
                          : "No Date",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.task.priority,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            /// 🔹 DATE + PRIORITY
            ///
            if (controller.isEnabled('PlannedEndDate') &&
                widget.task.plannedEndDate != null)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text(
                      "Planned End Date",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.task.plannedEndDate != null
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).format(widget.task.plannedStartDate!)
                          : '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            if (controller.isEnabled('PlannedStartDate') &&
                widget.task.plannedEndDate != null)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text(
                      "Planned Start",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.task.plannedStartDate != null
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).format(widget.task.plannedStartDate!)
                          : '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            if (controller.isEnabled('ActualStartDate') &&
                widget.task.actualStartDate != null)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text(
                      "Actual StartDate",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.task.actualStartDate != null
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).format(widget.task.actualStartDate!)
                          : '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            if (controller.isEnabled('ActualEndDate') &&
                widget.task.actualEndDate != null)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text(
                      "Actual EndDate",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.task.actualEndDate != null
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).format(widget.task.actualEndDate!)
                          : '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

            if (controller.isEnabled('PlannedStartDate') &&
                widget.task.plannedEndDate != null)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text(
                      "Planned Start",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.task.plannedStartDate != null
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).format(widget.task.plannedStartDate!)
                          : '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 6),

            /// 🔹 CREATED BY
            _fieldRow("Created By", widget.task.createdBy?.userName ?? 'N/A'),
            if (controller.isEnabled('ParentTaskId') &&
                widget.task.parentTaskId != null)
              _fieldRow("parent Task Id", widget.task.parentTaskId!),
            if (controller.isEnabled('Dependent') &&
                widget.task.dependent != null)
              _fieldRow("Dependent", widget.task.dependent!),

            /// 🔹 ESTIMATED HOURS
            if (controller.isEnabled('EstimatedHours') &&
                widget.task.estimatedHours > 0)
              _fieldRow("Estimated Hours", "${widget.task.estimatedHours} h"),

            /// 🔹 ACTUAL HOURS
            if (controller.isEnabled('ActualHours') &&
                widget.task.actualHours > 0)
              _fieldRow("Actual Hours", "${widget.task.actualHours} h"),

            /// 🔹 ACTUAL HOURS
            if (controller.isEnabled('ChecklistsCount') &&
                widget.task.checklistsCount.isNotEmpty)
              _fieldRow("ChecklistsCount", widget.task.checklistsCount),

            /// 🔹 START DATE
            const SizedBox(height: 10),

            /// 🔹 ASSIGNED USERS
            if (widget.task.assignedTo.isNotEmpty) ...[
              const Text(
                "Assigned To",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Builder(
                builder: (_) {
                  final users = widget.task.assignedTo;
                  final visibleUsers = users.take(2).toList();
                  final remainingCount = users.length - visibleUsers.length;

                  return Row(
                    children: [
                      /// 🔹 FIRST 2 USERS
                      ...visibleUsers.map((user) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getUserColor(user.employeeName),
                          ),
                          child: Text(
                            _getInitials(user.employeeName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),

                      /// 🔹 +N USERS
                      if (remainingCount > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: Text(
                            "+$remainingCount",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 10),

            /// 🔹 CARD TYPE
            if (widget.task.cardType?.cardName != null)
              _chipField(
                "Card Type",
                widget.task.cardType!.cardName!,
                Colors.red,
              ),

            const SizedBox(height: 10),

            /// 🔹 TAGS
            if (widget.task.tags.isNotEmpty) ...[
              const Text(
                "Tags",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),

              Builder(
                builder: (_) {
                  final tags = widget.task.tags;
                  final visibleTags = tags.take(2).toList();
                  final remainingCount = tags.length - visibleTags.length;

                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      /// 🔹 FIRST 2 TAGS
                      ...visibleTags.map((tag) {
                        final color = Color(
                          int.parse(tag.tagColor.replaceAll('#', '0xFF')),
                        );

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag.tagName,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),

                      /// 🔹 +N MORE TAGS
                      if (remainingCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "+$remainingCount",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipField(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- helpers ----------
  void _showDeleteConfirm(
    BuildContext context,
    int recId,
    VoidCallback? callApi,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteKanbanTask(recId); // 👈 pass RecId
              callApi!();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name
        .trim()
        .split(RegExp(r'\s+')) // handles multiple spaces
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _getUserColor(String name) {
    final hash = name.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b);
  }
}

Future<void> showAddTaskBottomSheet(
  BuildContext context, {
  required String shelfId,
  required String boardId,
  required VoidCallback onTaskAdded,
}) async {
  final controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController taskNameCtrl = TextEditingController();
  final TextEditingController dueDateCtrl = TextEditingController();

  /// 🔹 Load board members BEFORE opening sheet
  try {
    controller.boardMembers = await controller.fetchBoardMembers(boardId);
  } catch (e) {
    debugPrint("Board Members Error: $e");
    controller.boardMembers = [];

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load board members")),
      );
    }
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      bool isCreatingTaskOne = false;
      final controller = Get.put(Controller());

      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addTask,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: taskNameCtrl,
                            decoration: InputDecoration(
                              labelText:
                                  "${AppLocalizations.of(context)!.taskName}*",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Task name is required";
                              }
                              if (value.trim().length < 3) {
                                return "Minimum 3 characters required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: dueDateCtrl,
                            enabled: !isCreatingTaskOne,
                            readOnly: true,
                            onTap: isCreatingTaskOne
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      dueDateCtrl.text = DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(date);
                                    }
                                  },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!.plannedEndDate,
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),

                          const SizedBox(height: 12),

                          IgnorePointer(
                            ignoring: isCreatingTaskOne,
                            child:
                                MultiSelectMultiColumnDropdownField<
                                  BoardMember
                                >(
                                  items: controller.boardMembers,
                                  selectedValues: controller.selectedMembers,
                                  dropdownMaxHeight: 300,

                                  isMultiSelect: true,
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.assignUsers,
                                  displayText: (e) => e.userName,
                                  searchValue: (e) => e.userName,
                                  columnHeaders: [
                                    AppLocalizations.of(context)!.id,
                                    AppLocalizations.of(context)!.name,
                                  ],
                                  rowBuilder: (e, _) => Row(
                                    children: [
                                      Expanded(child: Text(e.userId)),
                                      Expanded(child: Text(e.userName)),
                                    ],
                                  ),
                                  onMultiChanged: (vals) {
                                    controller.selectedMembers.assignAll(vals);
                                  },
                                  onChanged: (_) {},
                                ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isCreating
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(
                                          () => controller.isCreating = true,
                                        );

                                        try {
                                          final payload = {
                                            "ShelfId": shelfId,
                                            "TaskName": taskNameCtrl.text,
                                            "DueDate": dueDateCtrl.text.isEmpty
                                                ? null
                                                : dueDateCtrl.text,
                                            "AssignedTo": controller
                                                .selectedMembers
                                                .map((e) => e.userId)
                                                .toList(),
                                          };

                                          final res = await ApiService.post(
                                            Uri.parse(
                                              "${Urls.baseURL}/api/v1/kanban/tasks/tasks/tasks",
                                            ),
                                            body: jsonEncode(payload),
                                          );
                                          final Map<String, dynamic>
                                          responseData = jsonDecode(res.body);
                                          final String message =
                                              responseData['detail']?['message'] ??
                                              'No message found';
                                          if (res.statusCode == 200 ||
                                              res.statusCode == 201) {
                                            taskNameCtrl.clear();
                                            dueDateCtrl.clear();
                                            controller.selectedMembers.clear();
                                            controller.boardMembers.clear();
                                            controller.isCreating = false;
                                            onTaskAdded();
                                            Fluttertoast.showToast(
                                              msg: message,
                                              backgroundColor:
                                                  Colors.green[200],
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              textColor: Colors.green[800],
                                              fontSize: 16.0,
                                            );

                                            /// 🔴 CLOSE SHEET AND EXIT
                                            Navigator.pop(context);
                                            return; // ⛔ STOP HERE
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: message,
                                              backgroundColor: Colors.red[200],
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              textColor: Colors.red[800],
                                              fontSize: 16.0,
                                            );
                                            controller.isCreating = false;
                                            throw Exception();
                                          }
                                        } catch (_) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Failed to create task",
                                              ),
                                            ),
                                          );
                                        }
                                      }

                                      /// ✅ SAFE: only runs if sheet is still open
                                      controller.isCreating = false;
                                    },

                              child: controller.isCreating
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text("Create Task"),
                            ),
                          ),

                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showAddTaskBottomSheetInSecond(
  BuildContext context, {
  required String boardId,
  required Future<void> Function() loadKanbanBoard,
}) async {
  final controller = Get.put(Controller());

  final TextEditingController taskNameCtrl = TextEditingController();
  final TextEditingController dueDateCtrl = TextEditingController();

  /// 🔹 Load board members BEFORE opening sheet
  try {
    controller.boardMembers = await controller.fetchBoardMembers(boardId);
  } catch (e) {
    debugPrint("Board Members Error: $e");
    controller.boardMembers = [];

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load board members")),
      );
    }
  }
  final _formKey = GlobalKey<FormState>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      bool isCreatingTask = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addTask,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: taskNameCtrl,
                            enabled: !isCreatingTask,
                            decoration: InputDecoration(
                              labelText:
                                  '${AppLocalizations.of(context)!.taskName} *',
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: dueDateCtrl,
                            enabled: !isCreatingTask,
                            readOnly: true,
                            onTap: isCreatingTask
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      dueDateCtrl.text = DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(date);
                                    }
                                  },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.dueDate,
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),

                          const SizedBox(height: 12),

                          IgnorePointer(
                            ignoring: isCreatingTask,
                            child:
                                MultiSelectMultiColumnDropdownField<
                                  BoardMember
                                >(
                                  items: controller.boardMembers,
                                  selectedValues: controller.selectedMembers,
                                  isMultiSelect: true,
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.assignUsers,
                                  displayText: (e) => e.userName,
                                  searchValue: (e) => e.userName,
                                  columnHeaders: [
                                    AppLocalizations.of(context)!.id,
                                    AppLocalizations.of(context)!.name,
                                  ],
                                  rowBuilder: (e, _) => Row(
                                    children: [
                                      Expanded(child: Text(e.userId)),
                                      Expanded(child: Text(e.userName)),
                                    ],
                                  ),
                                  onMultiChanged: (vals) {
                                    controller.selectedMembers.assignAll(vals);
                                  },
                                  onChanged: (_) {},
                                ),
                          ),
                          SizedBox(height: 20),
                          IgnorePointer(
                            ignoring: isCreatingTask,
                            child: SearchableMultiColumnDropdownField<Shelf>(
                              items: controller.shelves,
                              selectedValue: controller.selectedBoard.value,

                              labelText: AppLocalizations.of(context)!.stage,
                              displayText: (e) => e.shelfName,
                              searchValue: (e) => e.shelfName,
                              columnHeaders: const ["ShelfName"],
                              rowBuilder: (e, _) => Row(
                                children: [
                                  // Expanded(child: Text(e.shelfId)),
                                  Expanded(child: Text(e.shelfName)),
                                ],
                              ),

                              onChanged: (val) {
                                controller.selectedBoard.value = val;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isCreatingTask
                                  ? null
                                  : () async {
                                      print('isCreatingTask$isCreatingTask');
                                      if (taskNameCtrl.text.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg:
                                              '${AppLocalizations.of(context)!.taskName}${AppLocalizations.of(context)!.fieldRequired}',
                                          backgroundColor: Colors.red[200],
                                          textColor: Colors.red[800],
                                        );
                                        return;
                                      }

                                      setState(() => isCreatingTask = true);

                                      try {
                                        final payload = {
                                          "ShelfId": controller
                                              .selectedBoard
                                              .value!
                                              .shelfId,
                                          "TaskName": taskNameCtrl.text,
                                          "DueDate": dueDateCtrl.text.isEmpty
                                              ? null
                                              : dueDateCtrl.text,
                                          "AssignedTo": controller
                                              .selectedMembers
                                              .map((e) => e.userId)
                                              .toList(),
                                        };

                                        final res = await ApiService.post(
                                          Uri.parse(
                                            "${Urls.baseURL}/api/v1/kanban/tasks/tasks/tasks",
                                          ),
                                          body: jsonEncode(payload),
                                        );

                                        if (res.statusCode == 200 ||
                                            res.statusCode == 201) {
                                          final result = await controller
                                              .fetchKanbanBoardAndNavigate(
                                                context,
                                                controller
                                                    .selectedBoard
                                                    .value!
                                                    .boardId
                                                    .toString(),
                                                true,
                                              );
                                          loadKanbanBoard();
                                          if (result != null) {
                                            result.shelfs.sort(
                                              (a, b) => a.sortOrder.compareTo(
                                                b.sortOrder,
                                              ),
                                            );

                                            controller.originalBoard = result;

                                            controller.shelves.assignAll(
                                              result.shelfs,
                                            );
                                          }
                                          taskNameCtrl.clear();
                                          dueDateCtrl.clear();
                                          controller.selectedMembers.clear();
                                          controller.boardMembers.clear();
                                          controller.selectedBoard.value = null;

                                          Navigator.pop(context);
                                          return;
                                        } else {
                                          throw Exception();
                                        }
                                      } catch (e) {
                                        print("$e");
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Failed to create task",
                                            ),
                                          ),
                                        );
                                      }

                                      /// ✅ SAFE: only runs if sheet is still open
                                      setState(() => isCreatingTask = false);
                                    },

                              child: isCreatingTask
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(AppLocalizations.of(context)!.save),
                            ),
                          ),

                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Color getCardTypeColor(String cardName) {
  switch (cardName.toLowerCase()) {
    case 'feature':
      return Colors.blue.shade100;
    case 'bug':
      return Colors.red.shade100;
    case 'improvement':
      return Colors.orange.shade100;
    case 'spike':
      return Colors.purple.shade100;
    case 'technical debt':
      return Colors.brown.shade100;
    case 'test case':
      return Colors.teal.shade100;
    case 'documentation':
      return Colors.indigo.shade100;
    case 'deployment':
      return Colors.green.shade100;
    case 'review':
      return Colors.cyan.shade100;
    case 'maintenance':
      return Colors.grey.shade300;
    default:
      return Colors.grey.shade200;
  }
}

// Get initials from full name (e.g., "Ram Kumar" -> "RK")
String _getInitials(String fullName) {
  if (fullName.isEmpty) return "?";

  // Split by spaces and filter out empty strings
  List<String> parts = fullName
      .trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return "?";

  if (parts.length == 1) {
    // Single word name: take first 2 letters
    return parts[0].length >= 2
        ? parts[0].substring(0, 2).toUpperCase()
        : parts[0].toUpperCase();
  }

  // Multiple words: take first letter of first two words
  return parts.length >= 2
      ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
      : parts[0].substring(0, 1).toUpperCase();
}

// Generate a consistent color for each user
Color _getUserColor(String userName) {
  // List of nice material colors
  final List<Color> colorPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  // Generate a hash code from the user name
  int hash = 0;
  for (int i = 0; i < userName.length; i++) {
    hash = userName.codeUnitAt(i) + ((hash << 5) - hash);
  }

  // Use hash to pick a color from the palette
  int index = hash.abs() % colorPalette.length;
  return colorPalette[index];
}

class AddTaskBottomSheet extends StatefulWidget {
  final String shelfId;
  final String bordID;
  const AddTaskBottomSheet({
    super.key,
    required this.shelfId,
    required this.bordID,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController taskNameCtrl = TextEditingController();
  final TextEditingController dueDateCtrl = TextEditingController();
  final controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;

  /// Example users list (API based in real case)
  final List<Map<String, String>> users = [
    {"id": "EMP018", "name": "Dinesh"},
    {"id": "EMP019", "name": "Rahul"},
    {"id": "EMP020", "name": "Suresh"},
  ];
  @override
  void initState() {
    super.initState();

    loadMembers();
  }

  List<Map<String, String>> selectedUsers = [];
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        dueDateCtrl.text = date.toIso8601String().split("T").first;
      });
    }
  }

  Future<void> loadMembers() async {
    controller.boardMembers = await controller.fetchBoardMembers(widget.bordID);
    print("boardMembers${controller.boardMembers}");

    setState(() {});
  }

  Future<void> createTask(BuildContext context) async {
    final payload = {
      "ShelfId": widget.shelfId,
      "TaskName": taskNameCtrl.text,
      "DueDate": dueDateCtrl.text,
      "AssignedTo": controller.selectedMembers.map((e) => e.userId).toList(),
    };

    final url = Uri.parse("${Urls.baseURL}/api/v1/kanban/tasks/tasks/tasks");
    final response = await ApiService.post(url, body: jsonEncode(payload));
    // final response = await http.post(
    //   url,
    //   headers: {
    //     "Content-Type": "application/json",
    //     "Authorization": "Bearer YOUR_TOKEN",
    //   },
    //   body: jsonEncode(payload),
    // );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      controller.fetchKanbanBoardAndNavigate(context, widget.bordID, false); //
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Task Created")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create task")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              AppLocalizations.of(context)!.addTask,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// Task Name
            TextFormField(
              controller: taskNameCtrl,
              decoration: const InputDecoration(
                labelText: "Task Name *",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Task name is required";
                }
                if (value.trim().length < 3) {
                  return "Minimum 3 characters required";
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            /// Due Date
            TextField(
              controller: dueDateCtrl,
              readOnly: true,
              onTap: pickDate,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.plannedEndDate,
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// Assign Users (Multi Select)
            const Text("Assign Users"),
            const SizedBox(height: 6),

            SearchableMultiColumnDropdownField<BoardMember>(
              enabled: true,
              labelText: 'Select User(s)',
              items: controller.boardMembers,
              selectedValue: controller.selectedSettingsMembers.value,

              /// Search
              searchValue: (emp) => '${emp.userId} ${emp.userName}',

              /// What shows in field
              displayText: (emp) => emp.userName,

              /// Table header
              columnHeaders: const ['Employee ID', 'Name'],

              /// Row UI
              rowBuilder: (emp, searchQuery) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(emp.userId)),
                      Expanded(child: Text(emp.userName)),
                    ],
                  ),
                );
              },

              onChanged: (emp) {
                controller.selectedSettingsMembers.value = emp;
              }, // ignored for multi-select
            ),

            const SizedBox(height: 20),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      createTask(context);
                    },
                    child: const Text("Create"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openUserSearch() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Users"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            children: users.map((user) {
              final selected = selectedUsers.contains(user);
              return CheckboxListTile(
                value: selected,
                title: Text(user["name"]!),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedUsers.add(user);
                    } else {
                      selectedUsers.remove(user);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}

class BoardSettingsWidget extends StatefulWidget {
  final String boardId;
  final Future<void> Function() loadKanbanBoard;

  const BoardSettingsWidget({
    super.key,
    required this.boardId,
    required this.loadKanbanBoard,
  });

  @override
  State<BoardSettingsWidget> createState() => _BoardSettingsWidgetState();
}

class _BoardSettingsWidgetState extends State<BoardSettingsWidget>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final boardNameCtrl = TextEditingController();
  final ownerNameController = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final referenceTypeCtrl = TextEditingController();
  final referenceIdCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();
  final areaName = TextEditingController();

  final Controller controller = Get.find<Controller>();

  var boardType = 'Public'.obs;
  var sortingOrder = 'By Assignee'.obs;
  var boardTheme = 'System'.obs;
  var enableTimeTracking = false.obs;
  var ownerName = ''.obs;

  var showUrlUpload = false.obs;
  var isLoading = false.obs;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _loadTask();
  }

  RxBool isUpdating = false.obs;

  Future<void> updateBoardSettings() async {
    try {
      isUpdating.value = true;

      final payload = {
        "BoardId": widget.boardId,
        "BoardName": boardNameCtrl.text.trim(),
        "Description": descriptionCtrl.text.trim(),
        "BoardOwnerName": ownerName.value.isNotEmpty ? ownerName.value : null,
        "BoardSettingType": boardType.value,
        "BoardTheme": boardTheme.value,
        "DefaultSortingOrder": reverseMapSorting(sortingOrder.value),
        "TimeTrackingEnabled": enableTimeTracking.value,
        "ReferenceType": referenceTypeCtrl.text.trim().isEmpty
            ? null
            : referenceTypeCtrl.text.trim(),
        "ReferenceId": referenceIdCtrl.text.trim().isEmpty
            ? null
            : referenceIdCtrl.text.trim(),
        "BackgroundImageUrl": imageUrlCtrl.text, // 🔥 base64 string
      };
      print("payload$payload");
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.baseURL}/api/v1/kanban/boards/boardsettings/boardsettings?RecId=${controller.recID}',
        ),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final message = responseData['detail']['message'];

      if (response.statusCode == 280) {
        widget.loadKanbanBoard();
        fetchBoardSettings(widget.boardId);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.red,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isUpdating.value = false;
    }
  }

  String reverseMapSorting(String uiValue) {
    switch (uiValue) {
      case 'Due Date':
        return 'DueDate';
      case 'Priority':
        return 'Priority';
      case 'By Assignee':
        return 'ByAssignee';
      case 'Task Name':
        return 'TaskName';
      case 'Planned End Date':
        return 'PlannedEndDate';
      case 'Tag':
        return 'Tag';
      default:
        return 'Tag';
    }
  }

  Future<void> loadMembers() async {
    controller.boardMembers = await controller.fetchBoardMembers(
      widget.boardId,
    );
    setState(() {});
  }

  Future<void> boardAllemployeeMembers() async {
    controller.boardAllemployeeMembers = await controller.boardmemberslist(
      widget.boardId,
    );
    setState(() {});
  }

  Future<void> fetchBoardSettings(String boardId) async {
    try {
      isLoading.value = true;

      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/kanban/boards/boardsettings/boardsettingsdetails'
        '?BoardId=$boardId'
        '&screen_name=KANBoardMembers',
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        controller.recID = null;
        final settings = BoardSettings.fromJson(data.first);
        print("Data Start Uploaded");

        boardNameCtrl.text = settings.boardName;
        descriptionCtrl.text = settings.description ?? '';
        referenceTypeCtrl.text = settings.referenceType ?? '';
        referenceIdCtrl.text = settings.referenceId ?? '';
        areaName.text = settings.areaName ?? '';
        boardType.value = settings.boardSettingType;
        sortingOrder.value = _mapSorting(settings.defaultSortingOrder);
        boardTheme.value = settings.boardTheme;
        enableTimeTracking.value = settings.timeTrackingEnabled;
        ownerName.value = settings.boardOwnerName;
        controller.recID = settings.recId;
        final user = controller.boardMembers.firstWhereOrNull(
          (u) => u.userId.trim() == ownerName.value.trim(),
        );
        ownerNameController.text = user!.userName;

        if (user != null) controller.selectedSettingsMembers.value = user;
      } else {}
    } catch (e) {
      print("Data Start Uploaded$e");
    } finally {
      isLoading.value = false;
    }
  }

  String _mapSorting(String apiValue) {
    switch (apiValue) {
      case 'DueDate':
        return 'Due Date';
      case 'Priority':
        return 'Priority';
      case 'TaskName':
        return 'Task Name';
      case 'PlannedEndDate':
        return 'Planned End Date';
      case 'Tag':
        return 'Tag';
      case 'ByAssignee':
        return 'By Assignee';
      default:
        return 'By Assignee';
    }
  }

  Future<void> _loadTask() async {
    setState(() {});

    try {
      fetchBoardSettings(widget.boardId);
      await loadMembers();
      await boardAllemployeeMembers();
    } catch (e) {
      debugPrint('Checklist error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// TOP TAB
        TabBar(
          controller: tabController,
          labelColor: Colors.deepPurple,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.generalSettings),
            Tab(text: AppLocalizations.of(context)!.members),
          ],
        ),

        Expanded(
          child: Obx(() {
            if (isLoading.value) {
              return const Center(child: SkeletonLoaderPage());
            }

            return TabBarView(
              controller: tabController,
              children: [
                _generalSettingsUI(widget.boardId),
                _membersUI(widget.boardId, loadMembers),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();

    /// 🔥 Detect image type safely
    final String extension = image.path.split('.').last.toLowerCase();
    final String mimeType = extension == 'png'
        ? 'image/png'
        : extension == 'jpg' || extension == 'jpeg'
        ? 'image/jpeg'
        : 'image/png'; // fallback

    /// 🔥 FINAL FORMAT REQUIRED BY BACKEND
    final String base64WithHeader =
        'data:$mimeType;base64,${base64Encode(bytes)}';

    /// 🔥 SET VALUE
    imageUrlCtrl.text = base64WithHeader;
  }

  /// ================= GENERAL SETTINGS =================
  Widget _generalSettingsUI(String boardId) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(
                  AppLocalizations.of(context)!.boardName,
                  boardNameCtrl,
                  PermissionHelper.canUpdate("Board Management"),
                ),
                _text(
                  AppLocalizations.of(context)!.description,
                  descriptionCtrl,
                  PermissionHelper.canUpdate("Board Management"),
                  maxLines: 3,
                ),

                const SizedBox(height: 10),

                /// BOARD TYPE
                SearchableMultiColumnDropdownField<String>(
                  labelText:
                      '${AppLocalizations.of(context)!.board}${AppLocalizations.of(context)!.type}',
                  items: [
                    AppLocalizations.of(context)!.public,
                    AppLocalizations.of(context)!.private,
                  ],
                  selectedValue: boardType.value,
                  enabled: PermissionHelper.canUpdate("Board Management"),
                  searchValue: (type) => type,
                  displayText: (type) => type,
                  onChanged: (type) => boardType.value = type!,
                  rowBuilder: (type, searchQuery) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Text(type),
                  ),
                  columnHeaders: [AppLocalizations.of(context)!.type],
                ),

                const SizedBox(height: 15),

                /// BOARD OWNER
                MultiSelectMultiColumnDropdownField<BoardMember>(
                  enabled: PermissionHelper.canUpdate("Board Management"),
                  labelText: AppLocalizations.of(context)!.boardOwnerName,
                  items: controller.boardMembers,
                  controller: ownerNameController,

                  selectedValues: controller.selectedMembers,
                  isMultiSelect: false,
                  searchValue: (emp) => '${emp.userId} ${emp.userName}',
                  displayText: (emp) => emp.userName,
                  onMultiChanged: controller.selectedMembers.assignAll,
                  columnHeaders: [
                    AppLocalizations.of(context)!.employeeId,
                    AppLocalizations.of(context)!.employeeName,
                  ],
                  rowBuilder: (emp, searchQuery) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(emp.userId)),
                        Expanded(child: Text(emp.userName)),
                      ],
                    ),
                  ),
                  onChanged: (_) {},
                ),

                const SizedBox(height: 15),

                /// SORTING ORDER
                SearchableMultiColumnDropdownField<String>(
                  labelText: AppLocalizations.of(context)!.defaultSortingOrder,
                  items: [
                    AppLocalizations.of(context)!.byAssignee,
                    AppLocalizations.of(context)!.dueDate,
                    AppLocalizations.of(context)!.priority,
                  ],
                  selectedValue: sortingOrder.value,
                  enabled: PermissionHelper.canUpdate("Board Management"),
                  searchValue: (type) => type,
                  displayText: (type) => type,
                  onChanged: (type) => sortingOrder.value = type!,
                  rowBuilder: (type, searchQuery) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Text(type),
                  ),
                  columnHeaders: [AppLocalizations.of(context)!.type],
                ),

                /// TIME TRACKING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enableTimeTracking,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Transform.scale(
                      scale: 0.75,
                      child: Obx(() {
                        final canUpdate = PermissionHelper.canUpdate(
                          "Board Management",
                        );

                        return Switch(
                          value: enableTimeTracking.value,
                          onChanged: canUpdate
                              ? (v) => enableTimeTracking.value = v
                              : null, // 🔒 disables switch
                        );
                      }),
                    ),
                  ],
                ),

                /// REFERENCE
                Row(
                  children: [
                    Expanded(
                      child: _text(
                        AppLocalizations.of(context)!.referenceName,
                        referenceTypeCtrl,
                        false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _text(
                        AppLocalizations.of(context)!.referenceId,
                        referenceIdCtrl,
                        false,
                      ),
                    ),
                  ],
                ),
                _text(AppLocalizations.of(context)!.areaName, areaName, false),
                const SizedBox(height: 12),

                /// THEME
                Text(
                  AppLocalizations.of(context)!.boardTheme,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Obx(() {
                  final canUpdate = PermissionHelper.canUpdate(
                    "Board Management",
                  );

                  return Row(
                    children: ["Dark", "Light", "SystemDefault"]
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                e,
                                style: const TextStyle(fontSize: 10),
                              ),
                              selected: boardTheme.value == e,
                              onSelected: canUpdate
                                  ? (_) => boardTheme.value = e
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
                const SizedBox(height: 16),

                Obx(() {
                  final canUpdate = PermissionHelper.canUpdate(
                    "Board Management",
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// BACKGROUND IMAGE
                      Text(
                        AppLocalizations.of(context)!.backgroundImage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Row(
                        children: [
                          TextButton(
                            onPressed: canUpdate
                                ? () => showUrlUpload.value = true
                                : null, // 🔒 disable
                            child: Text(AppLocalizations.of(context)!.url),
                          ),
                          TextButton(
                            onPressed: canUpdate
                                ? () => showUrlUpload.value = false
                                : null, // 🔒 disable
                            child: Text(
                              AppLocalizations.of(context)!.fileUpload,
                            ),
                          ),
                        ],
                      ),

                      showUrlUpload.value
                          ? _text(
                              AppLocalizations.of(context)!.imageUrl,
                              imageUrlCtrl,
                              canUpdate, // 🔒 pass editable flag
                            )
                          : InkWell(
                              onTap: canUpdate
                                  ? pickImage
                                  : null, // 🔒 disable tap
                              child: Container(
                                height: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.upload_file, size: 36),
                                    const SizedBox(height: 4),
                                    Text(
                                      imageUrlCtrl.text.isEmpty
                                          ? AppLocalizations.of(
                                              context,
                                            )!.uploadImage
                                          : imageUrlCtrl.text,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                /// ACTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        controller.resetForm();
                        Navigator.pushNamed(
                          context,
                          AppRoutes.kanbanBoardPage,
                          arguments: {"boardId":boardId},
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    const SizedBox(width: 12),
                    if (PermissionHelper.canUpdate("Board Management"))
                      ElevatedButton(
                        onPressed: isUpdating.value
                            ? null
                            : updateBoardSettings,
                        child: Obx(() {
                          return isUpdating.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(AppLocalizations.of(context)!.update);
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _membersUI(String boardId, Future<void> Function() loadMembers) {
    void showLoader(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    void hideLoader(BuildContext context) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    return Column(
      children: [
        /// ADD MEMBER BUTTON
        /// if
        if (PermissionHelper.canUpdate("Board Management"))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text(AppLocalizations.of(context)!.addBoardMembers),
                onPressed: () {
                  _openAddMemberDialog(context, boardId, loadMembers);
                },
              ),
            ),
          ),

        const SizedBox(height: 8),

        /// ✅ THIS FIXES THE ERROR
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.boardMembers.length,
            itemBuilder: (context, index) {
              final member = controller.boardMembers[index];

              return Dismissible(
                key: ValueKey(member.boardMemberId),

                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red.shade400,
                  child: const Icon(
                    Icons.visibility,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red.shade400,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                confirmDismiss: (direction) async {
                  if (member.accessPermission == "Owner") return false;

                  if (direction == DismissDirection.endToStart) {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Remove Member"),
                        content: Text(
                          '${AppLocalizations.of(context)!.remove}"${member.userName}" from board?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(AppLocalizations.of(context)!.remove),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final success = await controller.deleteBoardMember(
                        recId: member.recId,
                      );
                      if (success) {
                        controller.boardMembers.removeAt(index);

                        return true;
                      } else {
                        return false;
                      }
                    }
                  }
                  return false;
                },

                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        member.userName.isNotEmpty
                            ? member.userName[0].toUpperCase()
                            : "?",
                      ),
                    ),
                    title: Text(
                      member.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.email),
                        const SizedBox(height: 4),
                        Text(
                          member.accessPermission,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openAddMemberDialog(
    BuildContext context,
    bordeId,
    Future<void> Function() loadMembers,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  /// HEADER
                  Text(
                    AppLocalizations.of(context)!.addBoardMembers,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  /// GROUP + EMPLOYEE UI
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildEmployeeSelection(),
                          const SizedBox(height: 8),
                          _buildEmployeeGroupSelection(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ACTION BUTTONS
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.selectedGroups.clear();
                              controller.selectedEmployees.clear();
                              controller.selectedMembers.clear();
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Obx(() {
                          return Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                      controller.isSavingMember.value = true;
                                      await _saveBoardMembers(context, bordeId);
                                      loadMembers();
                                      controller.isSavingMember.value = false;
                                    },
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(AppLocalizations.of(context)!.save),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.isLoadingEmployees.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return MultiSelectMultiColumnDropdownField<BoardMember>(
            enabled: true,
            labelText: AppLocalizations.of(context)!.selectUser,
            items: controller.boardAllemployeeMembers,
            selectedValues: controller.selectedMembers,
            isMultiSelect: true,
            dropdownMaxHeight: 300,

            searchValue: (emp) => '${emp.boardMemberId} ${emp.userName} ',
            displayText: (emp) => emp.userName,
            onMultiChanged: (employees) {
              controller.selectedMembers.assignAll(employees);
            },
            columnHeaders: [
              AppLocalizations.of(context)!.employeeId,
              AppLocalizations.of(context)!.employeeName,
              AppLocalizations.of(context)!.department,
            ],
            rowBuilder: (emp, searchQuery) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(emp.userId)),
                    Expanded(child: Text(emp.userName)),
                    // Expanded(child: Text(emp.depo ?? 'N/A')),
                  ],
                ),
              );
            },
            onChanged: (emp) {}, // Not used for multi-select
          );
        }),

        // // Show selected employees
        // Obx(() {
        //   if (controller.selectedEmployees.isEmpty) {
        //     return const SizedBox();
        //   }

        //   return Padding(
        //     padding: const EdgeInsets.only(top: 12),
        //     child: Wrap(
        //       spacing: 8,
        //       runSpacing: 8,
        //       children: controller.selectedEmployees.map((emp) {
        //         return Chip(
        //           label: Text(
        //             emp.fullName,
        //             style: const TextStyle(
        //               fontSize: 13,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),

        //           backgroundColor: Colors.grey.shade100,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(20),
        //             side: BorderSide(color: Colors.grey.shade300),
        //           ),

        //           deleteIcon: Container(
        //             decoration: BoxDecoration(
        //               shape: BoxShape.circle,
        //               color: Colors.grey.shade300,
        //             ),
        //             child: const Icon(
        //               Icons.close,
        //               size: 16,
        //               color: Colors.black54,
        //             ),
        //           ),

        //           deleteIconColor: Colors.black54,

        //           onDeleted: () {
        //             controller.selectedEmployees.remove(emp);
        //           },
        //         );
        //       }).toList(),
        //     ),
        //   );
        // }),
      ],
    );
  }

  Future<void> _saveBoardMembers(BuildContext context, bordeId) async {
    if (controller.boardMembers.isEmpty && controller.selectedGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select users or groups")),
      );
      return;
    }
    controller.isLoading.value = true;
    final payload = {
      "userid": controller.boardMembers.map((e) => e.userId).toList(),
      "groupid": controller.selectedGroups.map((e) => e.id).toList(),
    };
    print("payload$bordeId");
    try {
      final res = await ApiService.post(
        Uri.parse(
          "${Urls.baseURL}/api/v1/kanban/boards/boardmembers/boardmembers"
          "?BoardId=$bordeId",
        ),
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        controller.selectedGroups.clear();
        controller.selectedEmployees.clear();
        controller.boardMembers.clear();
        controller.selectedMembers.clear();

        /// refresh members list
        // await controller.loadBoardMembers(
        //   controller.selectedBoard.value!.boardId,
        // );

        if (context.mounted) Navigator.pop(context);

        final Map<String, dynamic> responseData = jsonDecode(res.body);
        controller.isLoading.value = false;
        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        controller.isLoading.value = false;
        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        throw Exception();
      }
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Failed to add members$e")));
    }
  }

  Widget _buildEmployeeGroupSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 8),
        // Remove Obx wrapper since there are no observable variables inside
        MultiSelectMultiColumnDropdownField<EmployeeGroup>(
          enabled: true,
          labelText: AppLocalizations.of(context)!.selectGroups,
          items: controller.employeeGroups,
          selectedValues: controller.selectedGroups,
          isMultiSelect: true,
          searchValue: (group) => '${group.name} ${group.description ?? ""}',
          displayText: (group) => group.name,
          dropdownMaxHeight: 250,
          onMultiChanged: (groups) {
            controller.selectedGroups.assignAll(groups);

            // Add group members to selected employees
            for (final group in groups) {
              for (final member in group.members) {
                if (!controller.selectedEmployees.any(
                  (e) => e.id == member.id,
                )) {
                  controller.selectedEmployees.add(member);
                }
              }
            }
          },
          columnHeaders: [
            AppLocalizations.of(context)!.group,
            AppLocalizations.of(context)!.description,
          ],
          rowBuilder: (group, searchQuery) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.id,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      group.description ?? 'No description',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          onChanged: (group) {}, // Not used for multi-select
        ),

        // Show selected groups
        // Obx(() {
        //   if (controller.selectedGroups.isEmpty) {
        //     return const SizedBox();
        //   }

        //   return Padding(
        //     padding: const EdgeInsets.only(top: 12),
        //     child: Wrap(
        //       spacing: 8,
        //       runSpacing: 8,
        //       children: controller.selectedGroups.map((group) {
        //         return Chip(
        //           label: Text(group.name),
        //           onDeleted: () {
        //             controller.selectedGroups.remove(group);
        //             // Remove group members from selected employees
        //             for (final member in group.members) {
        //               if (controller.selectedEmployees.any(
        //                 (e) => e.id == member.id,
        //               )) {
        //                 // Check if member is not in any other selected group
        //                 bool isInOtherGroup = false;
        //                 for (final otherGroup in controller.selectedGroups) {
        //                   if (otherGroup != group &&
        //                       otherGroup.members.any(
        //                         (e) => e.id == member.id,
        //                       )) {
        //                     isInOtherGroup = true;
        //                     break;
        //                   }
        //                 }
        //                 if (!isInOtherGroup) {
        //                   controller.selectedEmployees.removeWhere(
        //                     (e) => e.id == member.id,
        //                   );
        //                 }
        //               }
        //             }
        //           },
        //         );
        //       }).toList(),
        //     ),
        //   );
        // }),
      ],
    );
  }

  /// ================= COMMON =================
  Widget _text(
    String label,
    TextEditingController ctrl,
    bool bool, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        enabled: bool,
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}
