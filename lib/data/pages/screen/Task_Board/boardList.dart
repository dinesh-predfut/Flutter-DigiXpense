import 'dart:convert' show jsonEncode;
import 'dart:io';

import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart'
    show MultiSelectMultiColumnDropdownField;
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/core/constant/url.dart';
import 'package:digi_xpense/data/models.dart'
    show KanbanBoard, Shelf, TaskItem, Employee, BoardMember;
import 'package:digi_xpense/data/pages/API_Service/apiService.dart';
import 'package:digi_xpense/data/pages/screen/Task_Board/addmoreetailsTask.dart'
    show TaskDetailsPage;
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
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

import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/API_Service/apiService.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';
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
  final List<String> _tabTitles = ['Board', 'Grid', 'Board Settings'];
  int _selectedTabIndex = 0;
  final TextEditingController searchCtrl = TextEditingController();

  String selectedPriority = 'All';
  String selectedShelf = 'All';
  String selectedUser = 'All';
  DateTime? selectedDueDate;

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

  /* ---------------- FILTER DATA ---------------- */

  List<String> get priorities => ['All', 'Low', 'Medium', 'High'];

  List<String> get shelves => [
    'All',
    ...originalBoard!.shelfs.map((e) => e.shelfName),
  ];

  List<String> get users {
    final set = <String>{};
    for (final s in originalBoard!.shelfs) {
      for (final t in s.tasks) {
        t.assignedTo?.forEach(set.add);
      }
    }
    return ['All', ...set];
  }

  /* ---------------- APPLY FILTERS ---------------- */
  void applyFilters() {
    if (originalBoard == null) return;

    final String keyword = searchCtrl.text.toLowerCase();
    final List<Shelf> filteredShelves = [];

    for (final shelf in originalBoard!.shelfs) {
      /// Shelf name filter
      if (selectedShelf != 'All' && shelf.shelfName != selectedShelf) {
        continue;
      }

      final List<TaskItem> filteredTasks = [];

      for (final task in shelf.tasks) {
        /// 🔍 SEARCH FILTER
        final bool matchesSearch =
            keyword.isEmpty ||
            (task.taskName?.toLowerCase().contains(keyword) == true) ||
            (task.assignedTo?.any((u) => u.toLowerCase().contains(keyword)) ==
                true);

        /// ⚡ PRIORITY FILTER
        final bool matchesPriority =
            selectedPriority == 'All' || task.priority == selectedPriority;
        isFiltered = true;

        /// 👤 USER FILTER
        final bool matchesUser =
            selectedUser == 'All' ||
            task.assignedTo?.contains(selectedUser) == true;

        /// 📅 DUE DATE FILTER
        final bool matchesDueDate =
            selectedDueDate == null ||
            (task.dueDate != null &&
                DateUtils.isSameDay(task.dueDate!, selectedDueDate));

        if (matchesSearch && matchesPriority && matchesUser && matchesDueDate) {
          filteredTasks.add(task);
        }
      }

      /// 🔁 CREATE NEW SHELF (NO copyWith)
      filteredShelves.add(
        Shelf(
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
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        controller.leaveField.value = false;
        if (!controller.leaveField.value) {
          controller.resetForm();
          return true;
        }

        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkBoard ? Colors.black : Colors.grey.shade100,

        appBar: AppBar(title: Text(filteredBoard!.boardName)),
        body: Column(
          children: [
            const SizedBox(height: 20),
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
              Expanded(child: _buildCardViewContent(context)),
            ],
            if (_selectedTabIndex == 2) ...[
              Expanded(child: BoardSettingsWidget(widget.boardId)),
            ],
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, size: 28, color: Colors.white),
          onPressed: () {
            showAddShelfBottomSheet(
              context,
              boardId: widget.boardId,
              nextSortOrder: originalBoard!.shelfs.length + 1,
              onShelfAdded: loadKanbanBoard,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardViewContent(BuildContext context) {
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
                  label: const Text("Add Task"),
                  onPressed: () async {
                    await showAddTaskBottomSheetInSecond(
                      context,
                      boardId: widget.boardId,
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
                                title: const Text('Delete'),
                                content: Text(
                                  'Delete task "${task.taskName}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              setState(() => isLoading = true);
                              // await controller.deleteTask(task.recId);
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
              //     formatTaskDate(task.dueDate),
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
    return DateFormat('dd MMM yyyy').format(date);
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

    ;

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
                        "Add Shelf",
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

                        /// 🎨 COLOR PICKER
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Pick Color"),
                                content: BlockPicker(
                                  pickerColor: selectedColor,
                                  onColorChanged: (color) {
                                    setState(() => selectedColor = color);
                                  },
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
                        labelText: "Shelf Name",
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
                        labelText: "Description",
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ACTION BUTTONS
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
                            onPressed: isCreating
                                ? null
                                : () async {
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

                                      if (res.statusCode == 200 ||
                                          res.statusCode == 201) {
                                        isSheetAlive =
                                            false; // 🔑 mark disposed
                                        Navigator.pop(context);
                                        loadKanbanBoard();
                                        return;
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
                                : const Text("Create"),
                          ),
                        ),
                      ],
                    ),
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
          hintText: 'Search tasks, users, tags...',
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
              label: 'Priority',
              value: selectedPriority,
              items: priorities,
              onChanged: (v) {
                selectedPriority = v;
                applyFilters();
              },
            ),

            _filterDropdown(
              icon: Icons.view_column,
              label: 'Shelf',
              value: selectedShelf,
              items: shelves,
              onChanged: (v) {
                selectedShelf = v;
                applyFilters();
              },
            ),

            _filterDropdown(
              icon: Icons.person_outline,
              label: 'Assigned',
              value: selectedUser,
              items: users,
              onChanged: (v) {
                selectedUser = v;
                applyFilters();
              },
            ),

            _dateFilterButton(),

            // if (_hasActiveFilters()) _clearFiltersButton(),
          ],
        ),
      ),
    );
  }

  Widget _clearFiltersButton() {
    return TextButton.icon(
      onPressed: clearFilters,
      icon: const Icon(Icons.close, size: 18),
      label: const Text('Clear'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  void clearFilters() {
    setState(() {
      searchCtrl.clear();
      selectedPriority = 'All';
      selectedShelf = 'All';
      selectedUser = 'All';
      selectedDueDate = null;

      // Reset board view
      filteredBoard = null;
    });
  }

  bool _hasActiveFilters() {
    return selectedPriority != 'All' ||
        selectedShelf != 'All' ||
        selectedUser != 'All' ||
        selectedDueDate != null ||
        searchCtrl.text.isNotEmpty;
  }

  Widget _dateFilterButton() {
    final bool isActive = selectedDueDate != null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: pickDueDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                isActive
                    ? DateFormat('dd MMM').format(selectedDueDate!)
                    : 'Due date',
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ],
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
                    child: Text(e, overflow: TextOverflow.ellipsis),
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
                            fontSize: 13,
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

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Future<void> pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      selectedDueDate = date;
      applyFilters();
    }
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

    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonLoaderPage();
      }

      return Container(
        width: shelf.isCollapsed ? 60 : 300,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (shelf.colorPallete != null && shelf.colorPallete.isNotEmpty)
              ? hexToColor(shelf.colorPallete)
              : (isDarkBoard ? Colors.black : Colors.white),

          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                          Expanded(
                            child: Text(
                              shelf.shelfName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkBoard
                                    ? Colors.white
                                    : Colors.black,
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
                  label: const Text("Add Task"),
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

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TASK NAME + MENU
            if (task.taskName != null && task.taskName!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.taskName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 1) {
                        onEdit?.call();
                      } else if (value == 2) {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 2,
                        child: Text('Delete'),
                        onTap: () {
                          _confirmDelete(context, task.recId, boardIdNumb);
                        },
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 6),

            /// DATE + PRIORITY
            if (task.dueDate != null || task.priority != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.dueDate != null)
                    Text(
                      DateFormat('dd/MM/yyyy').format(task.dueDate!),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                  if (task.priority != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Priority: ${task.priority}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 10),

            /// ASSIGNED USERS
            if (task.assignedTo != null && task.assignedTo!.isNotEmpty)
              Row(
                children: task.assignedTo!.map((user) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getUserColor(user),
                    ),
                    child: Text(
                      _getInitials(user),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),

            if (task.assignedTo != null && task.assignedTo!.isNotEmpty)
              const SizedBox(height: 10),

            /// CARD TYPE
            if (task.cardType?.cardName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.cardType!.cardName!,
                  style: const TextStyle(fontSize: 11),
                ),
              ),

            if (task.cardType?.cardName != null) const SizedBox(height: 10),

            /// ATTACHMENTS
            if (task.taskDocuments != null &&
                task.taskDocuments!.isNotEmpty) ...[
              const Text(
                'Attachment:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${task.taskDocuments!.length} Attachment(s)',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],

            /// TAGS
            if (task.tags != null && task.tags!.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: task.tags!.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(tag.tagColor.replaceAll('#', '0xFF')),
                      ).withOpacity(0.15), // Light background with 15% opacity
                      border: Border.all(
                        color: Color(
                          int.parse(tag.tagColor.replaceAll('#', '0xFF')),
                        ).withOpacity(0.3), // Subtle border
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag.tagName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(
                          int.parse(tag.tagColor.replaceAll('#', '0xFF')),
                        ), // Dark text for contrast
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(context, int recIds, String boardIdNumb) async {
    final controller = Get.put(Controller());

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
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
      controller.deleteTask(
        recId: recIds,
        context: context,
        boardIdNumb: boardIdNumb,
      );
    }
  }

  /// Helpers
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name
        .trim()
        .split(RegExp(r'\s+')) // handles multiple spaces
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getUserColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[name.hashCode % colors.length];
  }
}

Future<void> showAddTaskBottomSheet(
  BuildContext context, {
  required String shelfId,
  required String boardId,
  required VoidCallback onTaskAdded,
}) async {
  final controller = Get.find<Controller>();

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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Add Task",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: taskNameCtrl,
                          enabled: !isCreatingTask,
                          decoration: const InputDecoration(
                            labelText: "Task Name",
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
                          decoration: const InputDecoration(
                            labelText: "Due Date",
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),

                        const SizedBox(height: 12),

                        IgnorePointer(
                          ignoring: isCreatingTask,
                          child:
                              MultiSelectMultiColumnDropdownField<BoardMember>(
                                items: controller.boardMembers,
                                selectedValues: controller.selectedMembers,
                                isMultiSelect: true,
                                labelText: "Assign Users",
                                displayText: (e) => e.userName,
                                searchValue: (e) => e.userName,
                                columnHeaders: const ["ID", "Name"],
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
                            onPressed: isCreatingTask
                                ? null
                                : () async {
                                    if (taskNameCtrl.text.isEmpty) return;

                                    setState(() => isCreatingTask = true);

                                    try {
                                      final payload = {
                                        "ShelfId": shelfId,
                                        "TaskName": taskNameCtrl.text,
                                        "DueDate": dueDateCtrl.text.isEmpty
                                            ? null
                                            : dueDateCtrl.text,
                                        "AssignedTo": controller.selectedMembers
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
                                        taskNameCtrl.clear();
                                        dueDateCtrl.clear();
                                        controller.selectedMembers.clear();
                                        controller.boardMembers.clear();

                                        onTaskAdded();

                                        /// 🔴 CLOSE SHEET AND EXIT
                                        Navigator.pop(context);
                                        return; // ⛔ STOP HERE
                                      } else {
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
          );
        },
      );
    },
  );
}

Future<void> showAddTaskBottomSheetInSecond(
  BuildContext context, {
  required String boardId,
}) async {
  final controller = Get.find<Controller>();

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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Add Task",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: taskNameCtrl,
                          enabled: !isCreatingTask,
                          decoration: const InputDecoration(
                            labelText: "Task Name",
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
                          decoration: const InputDecoration(
                            labelText: "Due Date",
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),

                        const SizedBox(height: 12),

                        IgnorePointer(
                          ignoring: isCreatingTask,
                          child:
                              MultiSelectMultiColumnDropdownField<BoardMember>(
                                items: controller.boardMembers,
                                selectedValues: controller.selectedMembers,
                                isMultiSelect: true,
                                labelText: "Assign Users",
                                displayText: (e) => e.userName,
                                searchValue: (e) => e.userName,
                                columnHeaders: const ["ID", "Name"],
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

                            labelText: "Assign Users",
                            displayText: (e) => e.shelfName,
                            searchValue: (e) => e.shelfName,
                            columnHeaders: const ["BoardId", "BoardName"],
                            rowBuilder: (e, _) => Row(
                              children: [
                                Expanded(child: Text(e.shelfId)),
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
                                    if (taskNameCtrl.text.isEmpty) return;

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
                                        "AssignedTo": controller.selectedMembers
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          const Text(
            "Add Task",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          /// Task Name
          TextField(
            controller: taskNameCtrl,
            decoration: const InputDecoration(
              labelText: "Task Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          /// Due Date
          TextField(
            controller: dueDateCtrl,
            readOnly: true,
            onTap: pickDate,
            decoration: const InputDecoration(
              labelText: "Due Date",
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
  const BoardSettingsWidget(this.boardId, {super.key});

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

      if (response.statusCode == 280) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Get.snackbar("Success", "Board settings updated");
      } else {
        Get.snackbar("Error", response.body);
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
        return 'Assignee';
      default:
        return 'DueDate';
    }
  }

  Future<void> loadMembers() async {
    controller.boardMembers = await controller.fetchBoardMembers(
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
      default:
        return 'By Assignee';
    }
  }

  Future<void> _loadTask() async {
    setState(() {});

    try {
      await loadMembers();
      fetchBoardSettings(widget.boardId);
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
          tabs: const [
            Tab(text: 'General Settings'),
            Tab(text: 'Members'),
          ],
        ),

        Expanded(
          child: Obx(() {
            if (isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: tabController,
              children: [_generalSettingsUI(), _membersUI(widget.boardId)],
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
    imageUrlCtrl.text = base64Encode(bytes);
    //   imageUrlCtrl.text = basename(image.path);

    // /// 🔥 SET VALUE IN TEXTFIELD
    // imageUrlCtrl.text = imageFileName!;

    // debugPrint('Base64 Image Length: ${base64Image!.length}');
  }

  /// ================= GENERAL SETTINGS =================
  Widget _generalSettingsUI() {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text('Board Name', boardNameCtrl, true),
                _text('Description', descriptionCtrl, true, maxLines: 3),

                const SizedBox(height: 10),

                /// BOARD TYPE
                SearchableMultiColumnDropdownField<String>(
                  labelText: 'Board Type',
                  items: const ['Public', 'Private'],
                  selectedValue: boardType.value,
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
                  columnHeaders: const ['Type'],
                ),

                const SizedBox(height: 15),

                /// BOARD OWNER
                MultiSelectMultiColumnDropdownField<BoardMember>(
                  enabled: true,
                  labelText: 'Board Owner Name',
                  items: controller.boardMembers,
                  controller: ownerNameController,
                  selectedValues: controller.selectedMembers,
                  isMultiSelect: false,
                  searchValue: (emp) => '${emp.userId} ${emp.userName}',
                  displayText: (emp) => emp.userName,
                  onMultiChanged: controller.selectedMembers.assignAll,
                  columnHeaders: const ['Employee ID', 'Name'],
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
                  labelText: 'Default Sorting Order',
                  items: const ['By Assignee', 'Due Date', 'Priority'],
                  selectedValue: sortingOrder.value,
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
                  columnHeaders: const ['Type'],
                ),

                /// TIME TRACKING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Time Tracking',
                      style: TextStyle(fontSize: 14),
                    ),
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: enableTimeTracking.value,
                        onChanged: (v) => enableTimeTracking.value = v,
                      ),
                    ),
                  ],
                ),

                /// REFERENCE
                Row(
                  children: [
                    Expanded(
                      child: _text('Reference Type', referenceTypeCtrl, false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _text('Reference ID', referenceIdCtrl, false),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// THEME
                const Text(
                  'Board Theme',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Row(
                  children: ['Dark', 'Light', 'SystemDefault']
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(e, style: TextStyle(fontSize: 10)),
                            selected: boardTheme.value == e,
                            onSelected: (_) => boardTheme.value = e,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                /// BACKGROUND IMAGE
                const Text(
                  'Background Image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Row(
                  children: [
                    TextButton(
                      onPressed: () => showUrlUpload.value = true,
                      child: const Text('URL'),
                    ),
                    TextButton(
                      onPressed: () => showUrlUpload.value = false,
                      child: const Text('File Upload'),
                    ),
                  ],
                ),

                showUrlUpload.value
                    ? _text('Image URL', imageUrlCtrl, true)
                    : InkWell(
                        onTap: pickImage,
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
                                    ? 'Upload Image'
                                    : imageUrlCtrl.text,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                const SizedBox(height: 24),

                /// ACTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: controller.resetForm,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isUpdating.value ? null : updateBoardSettings,
                      child: Obx(() {
                        return isUpdating.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Update');
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

  Widget _membersUI(String boardId) {
    return Column(
      children: [
        /// ADD MEMBER BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("Add Members"),
              onPressed: () {
                _openAddMemberDialog(context, boardId);
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
                  color: Colors.blue.shade400,
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
                          'Remove "${member.userName}" from board?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Remove"),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      controller.boardMembers.removeAt(index);
                      return true;
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
                    trailing: Icon(
                      member.isActive ? Icons.visibility : Icons.visibility_off,
                      color: member.isActive ? Colors.green : Colors.grey,
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

  void _openAddMemberDialog(BuildContext context, bordeId) {
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
                  const Text(
                    "Add Board Members",
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
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
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
                                  : const Text("Save"),
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
            labelText: 'Select User(s)',
            items: controller.boardMembers,
            selectedValues: controller.selectedMembers,
            isMultiSelect: true,
            dropdownMaxHeight: 300,

            searchValue: (emp) => '${emp.boardMemberId} ${emp.userName} ',
            displayText: (emp) => emp.userName,
            onMultiChanged: (employees) {
              controller.selectedMembers.assignAll(employees);
            },
            columnHeaders: const ['Employee ID', 'Name', 'Department'],
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
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
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
          labelText: 'Select Groups',
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
          columnHeaders: const ['Group Name', 'Description'],
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
