import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class TaskDetailsPage extends StatefulWidget {
  final int taskRecId;
  final String bordeId;
  final bool mainAccess;
  const TaskDetailsPage({
    Key? key,
    required this.taskRecId,
    required this.bordeId,
    required this.mainAccess,
  }) : super(key: key);

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final Controller controller = Get.find<Controller>();
  Map<String, String?> dynamicFieldValues = {};

  List<ChecklistItem> checklist = [];
  bool showChecklistOnCard = false;
  List<TextEditingController> checklistControllers = [];
  // Controllers
  final _taskNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _commentsController = TextEditingController();
  final estimatedHours = TextEditingController();
  final version = TextEditingController();
  final actualHours = TextEditingController();
  final cardType = TextEditingController();
  final _commentController = TextEditingController();
  final taskId = TextEditingController();
  bool _isCommentPosting = false;

  TaskDetailModel? _taskDetails;

  DateTime? _startDate;
  DateTime? _dueDate;
  DateTime? plannedStartDate;
  DateTime? plannedEndDate;
  DateTime? _estimatedDate;
  String riskLevel = 'Low';
  String _priority = 'Low';
  String _status = 'Upcoming';
  String? _cardType;
  bool _showNotes = true;
  bool _showList = true;
  bool _loading = true;
  bool _saving = false;

  RxList<CommentModel> comments = <CommentModel>[].obs;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> loadMembers() async {
    controller.boardMembers = await controller.fetchBoardMembers(
      widget.bordeId,
    );
    setState(() {});
  }

  Future<void> loadChecklist() async {
    setState(() {});

    try {
      final result = await controller.fetchChecklist(
        taskRecId: widget.taskRecId,
        context: context,
      );

      checklist = result;

      checklistControllers = checklist
          .map((e) => TextEditingController(text: e.description))
          .toList();
    } catch (e) {
      debugPrint('Checklist error: $e');
    }

    setState(() {});
  }

  Future<void> loadTasks() async {
    controller.tasksValue = await controller.fetchTasks(
      boardId: widget.bordeId,
      taskRecId: widget.taskRecId,
    );
    setState(() {});
  }

  Future<void> loadComments() async {
    final List<CommentModel> result = await controller.fetchComments(
      taskRecId: widget.taskRecId,
    );
    controller.commentKanba.assignAll(result);
  }

  Future<void> loadtags() async {
    final tags = await controller.fetchTaskTags(taskRecId: widget.taskRecId);
    controller.taskTags.assignAll(tags);
  }

  Future<void> loadAttachmentData() async {
    final tags = await controller.fetchAttachments(taskRecId: widget.taskRecId);
    controller.attachments.assignAll(tags);
  }

  Future<void> fetchCardTypes() async {
    final tags = await controller.fetchCardTypes(recId: widget.taskRecId);
    controller.cardType.assignAll(tags);
  }

  Future<void> _loadTask() async {
    _loading = true;
    setState(() {});

    try {
      Future.wait([
        loadtags(),
        loadMembers(),
        fetchCardTypes(),
        loadTasks(),
        loadChecklist(),
        controller.fetchTaskConfig(widget.taskRecId),
      ]);
      _taskDetails = await controller.fetchTaskDetails(
        widget.taskRecId,
        context,
      );

      if (_taskDetails == null) return;

      _taskNameController.text = _taskDetails!.taskName;
      _notesController.text = _taskDetails!.notes ?? '';
      _priority = _taskDetails!.priority;
      _status = _taskDetails!.status;
      taskId.text = _taskDetails!.taskId;
      _showNotes = _taskDetails!.showNotes ?? false;
      showChecklistOnCard = _taskDetails!.showChecklist ?? false;
      _startDate = _taskDetails!.actualStartDate;
      _dueDate = _taskDetails!.actualEndDate;
      plannedEndDate = _taskDetails!.plannedEndDate;
      plannedStartDate = _taskDetails!.plannedStartDate;
      actualHours.text = _taskDetails!.actualHours.toString();
      estimatedHours.text = _taskDetails!.estimatedHours?.toString() ?? "0";

      final cardId = _taskDetails!.cardType?.trim();
      if (cardId != null && cardId.isNotEmpty) {
        controller.selectedCardType.value = controller.cardType
            .firstWhereOrNull((c) => c.boardCardId.trim() == cardId);
      }

      controller.selectedMembers.clear();
      for (final assigned in _taskDetails!.assignedTo) {
        final user = controller.boardMembers.firstWhereOrNull(
          (u) => u.userName == assigned.employeeName,
        );

        if (user != null) {
          controller.selectedMembers.add(user);
        }
      }
      dynamicFieldValues.clear();

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      // for (final field in controller.taskConfig.value?.taskData ?? []) {
      //   dynamicFieldValues[field.fieldName] = field.value;
      // }
      // });
      controller.userIdController.text = controller.selectedMembers
          .map((e) => e.userId)
          .join(', ');

      // controller.selectedTags.clear();
      for (final tag in _taskDetails!.tagId) {
        final matched = controller.taskTags.firstWhereOrNull(
          (t) => t.tagId == tag.tagId,
        );
        controller.selectedTags.add(matched ?? tag);
      }

      controller.selectedDependency.clear();
      // final dependent = _taskDetails!.dependent;
      // if (dependent != null && dependent.trim().isNotEmpty) {
      //   final ids = dependent.split(',').map((e) => e.trim());
      //   for (final id in ids) {
      //     final task = controller.tasksValue.firstWhereOrNull(
      //       (t) => t.taskId.trim() == id,
      //     );
      //     if (task != null) controller.selectedDependency.add(task);
      //   }
      // }

      // final parentId = _taskDetails!.parentTaskId?.trim();
      // controller.selectTast.value = parentId == null
      //     ? null
      //     : controller.tasksValue.firstWhereOrNull(
      //         (t) => t.taskId.trim() == parentId,
      //       );
    } finally {
      _loading = false;
      setState(() {});
    }

    Future.wait([loadAttachmentData(), loadComments()]);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: SkeletonLoaderPage()));
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitForm),
            content: Text(AppLocalizations.of(context)!.exitWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          _clearTaskForm();

          Navigator.of(context).pop();
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          actions: [
            // IconButton(
            //   icon: _saving
            //       ? const CircularProgressIndicator(color: Colors.white)
            //       : const Icon(Icons.save),
            //   onPressed: () {
            //     if (!_saving) _saveTask(context);
            //   },
            // ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TASK NAME
                _section('${AppLocalizations.of(context)!.taskName} *'),
                TextFormField(
                  controller: _taskNameController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  decoration: _inputDecoration(
                    AppLocalizations.of(context)!.enterTaskName,
                  ),
                ),

                const SizedBox(height: 12),

                /// TAGS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ✅ DROPDOWN
                    Obx(() {
                      return MultiSelectMultiColumnDropdownField<TagModel>(
                        key: ValueKey(controller.tagDropdownRefresh.value),

                        enabled: true,
                        labelText: AppLocalizations.of(context)!.selectTags,
                        items: controller.taskTags,
                        selectedValues: controller.selectedTags,
                        isMultiSelect: true,

                        searchValue: (tag) => '${tag.tagId} ${tag.tagName}',
                        displayText: (tag) => tag.tagName,

                        onMultiChanged: (tags) {
                          controller.selectedTags.assignAll(tags);
                        },

                        columnHeaders: [
                          AppLocalizations.of(context)!.tagId,
                          AppLocalizations.of(context)!.tagName,
                        ],

                        rowBuilder: (tag, searchQuery) {
                          Color tagColor;

                          try {
                            tagColor = Color(
                              int.parse(
                                '0xFF${tag.tagColor.replaceAll('#', '')}',
                              ),
                            );
                          } catch (_) {
                            tagColor = Colors.grey;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(tag.tagId)),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tagColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag.tagName,
                                      style: TextStyle(
                                        color: tagColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },

                        onChanged: (_) {},
                      );
                    }),

                    /// ✅ SELECTED TAG CHIPS
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedTags.map((tag) {
                          Color tagColor;
                          try {
                            tagColor = Color(
                              int.parse(
                                '0xFF${tag.tagColor.replaceAll('#', '')}',
                              ),
                            );
                          } catch (_) {
                            tagColor = Colors.grey;
                          }

                          return Chip(
                            label: Text(tag.tagName),
                            backgroundColor: tagColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: tagColor,
                              fontWeight: FontWeight.bold,
                            ),

                            onDeleted: () {
                              controller.selectedTags.remove(tag);

                              /// ✅ instant dropdown sync
                              controller.tagDropdownRefresh.value++;
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return MultiSelectMultiColumnDropdownField<BoardMember>(
                        key: ValueKey(controller.memberDropdownRefresh.value),

                        enabled: true,
                        labelText: AppLocalizations.of(context)!.selectUsers,
                        items: controller.boardMembers,
                        selectedValues: controller.selectedMembers,
                        isMultiSelect: true,

                        searchValue: (emp) => '${emp.userId} ${emp.userName}',
                        displayText: (emp) => emp.userName,

                        onMultiChanged: (employees) {
                          controller.selectedMembers.assignAll(employees);
                        },

                        controller: controller.userIdController,

                        columnHeaders: [
                          AppLocalizations.of(context)!.employeeId,
                          AppLocalizations.of(context)!.name,
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
                              ],
                            ),
                          );
                        },

                        onChanged: (_) {},
                      );
                    }),

                    const SizedBox(height: 12),

                    /// 👤 SELECTED MEMBERS (AVATARS)
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedMembers.map((emp) {
                          /// Initials
                          final names = emp.userName.split(' ');
                          final initials = names.isNotEmpty
                              ? (names.first[0] + names.last[0]).toUpperCase()
                              : '';

                          /// Color from userId
                          final color = Color(
                            (emp.userId.hashCode & 0xFFFFFF) | 0xFF000000,
                          );

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: color.withOpacity(0.25),
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: -6,
                                right: -4,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedMembers.removeWhere(
                                      (e) => e.userId == emp.userId,
                                    );
                                    controller.memberDropdownRefresh.value++;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade700,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                if (controller.selectedMembers.isNotEmpty)
                  const SizedBox(height: 8),
                _datePicker(
                  AppLocalizations.of(context)!.plannedStartDate,
                  plannedStartDate,
                  (d) {
                    if (plannedEndDate != null && d.isAfter(plannedEndDate!)) {
                      _showDateError(
                        context,
                        "Start date cannot be after end date",
                      );
                      return;
                    }
                    setState(() => plannedStartDate = d);
                  },
                ),

                const SizedBox(height: 12),

                _datePicker(
                  AppLocalizations.of(context)!.plannedEndDate,
                  plannedEndDate,
                  (d) {
                    if (plannedStartDate != null &&
                        d.isBefore(plannedStartDate!)) {
                      _showDateError(
                        context,
                        "End date cannot be before start date",
                      );
                      return;
                    }
                    setState(() => plannedEndDate = d);
                  },
                ),

                const SizedBox(height: 12),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: estimatedHours,
                  decoration: _inputDecoration('Estimated Hours'),
                  // validator: (v) {
                  //   if (mandatory && (v == null || v.isEmpty)) {
                  //     return 'Required';
                  //   }
                  //   return null;
                  // },
                ),
                const SizedBox(height: 12),

                /// ASSIGN TO

                // const SizedBox(height: 12),

                /// DATES
                _datePicker(
                  AppLocalizations.of(context)!.actualStartDate,
                  _startDate,
                  (d) {
                    if (_dueDate != null && d.isAfter(_dueDate!)) {
                      _showDateError(
                        context,
                        "Start date cannot be after end date",
                      );
                      return;
                    }
                    setState(() => _startDate = d);
                  },
                ),

                const SizedBox(height: 12),

                _datePicker(
                  AppLocalizations.of(context)!.actualEndDate,
                  _dueDate,
                  (d) {
                    if (_startDate != null && d.isBefore(_startDate!)) {
                      _showDateError(
                        context,
                        "End date cannot be before start date",
                      );
                      return;
                    }
                    setState(() => _dueDate = d);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: actualHours,
                  decoration: _inputDecoration('Actual Hours'),
                ),
                const SizedBox(height: 12),
                //                 /// ESTIMATED HOURS
                //              Obx(() {
                //   final cfg = controller.taskConfig.value;
                // print("cfg?.allowEstimatedHours ${cfg?.allowEstimatedHours }");
                //   final show = cfg?.allowEstimatedHours ?? false;
                //   if (!show) return const SizedBox();

                //   final mandatory = cfg?.mandatoryEstimatedHours ?? false;

                //   return TextFormField(
                //     keyboardType: TextInputType.number,
                //     controller: estimatedHours,
                //     decoration: _inputDecoration(
                //       mandatory ? 'Estimated Hours *' : 'Estimated Hours',
                //     ),
                //     validator: (v) {
                //       if (mandatory && (v == null || v.isEmpty)) {
                //         return 'Required';
                //       }
                //       return null;
                //     },
                //   );
                // }),

                //                 /// CARD TYPE
                //                 Obx(() {
                //   final cfg = controller.taskConfig.value;

                //   /// ✅ safe null handling
                //   final show = cfg?.allowCardTypes ?? false;
                //   if (!show) return const SizedBox();

                //   final mandatory = cfg?.mandatoryCardTypes ?? false;

                //   return Column(
                //     children: [
                SearchableMultiColumnDropdownField<CardTypeModel>(
                  enabled: true,
                  labelText: AppLocalizations.of(context)!.cardType,

                  columnHeaders: [AppLocalizations.of(context)!.cardType],

                  items: controller.cardType,
                  selectedValue: controller.selectedCardType.value,

                  searchValue: (c) => c.cardName,
                  displayText: (c) => c.cardName,

                  onChanged: (c) {
                    controller.selectedCardType.value = c;
                    cardType.text = c?.cardName ?? '';
                  },

                  rowBuilder: (c, _) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(c.cardName),
                  ),
                ),
                //     ],
                //   );
                // }),
                const SizedBox(height: 12),

                /// PRIORITY
                SearchableMultiColumnDropdownField<String>(
                  enabled: true,
                  labelText: AppLocalizations.of(context)!.priority,
                  columnHeaders: [AppLocalizations.of(context)!.type],
                  items: [
                    AppLocalizations.of(context)!.low,
                    AppLocalizations.of(context)!.high,
                    AppLocalizations.of(context)!.medium,
                    AppLocalizations.of(context)!.urgent,
                  ],
                  selectedValue: _priority,
                  searchValue: (code) => code,
                  displayText: (code) => code,
                  onChanged: (code) {
                    _priority = code!;
                  },
                  rowBuilder: (code, searchQuery) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(children: [Expanded(child: Text(code))]),
                    );
                  },
                ),

                //  const SizedBox(height: 12),

                //   /// VERSION
                //   TextFormField(
                //     keyboardType: TextInputType.numberWithOptions(),
                //     controller: version,
                //     decoration: _inputDecoration(
                //       AppLocalizations.of(context)!.version,
                //     ),
                //   ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.settings, size: 20, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      "Configure Fields",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// PARENT TASK
                Obx(() {
                  final fields =
                      controller.taskFields; // RxList<TaskFieldConfig>
                  Widget child = const SizedBox();
                  if (fields.isEmpty) return const SizedBox();

                  return Column(
                    children: fields.map((field) {
                      final label = field.fieldLabel ?? field.fieldName;
                      final mandatory = field.isMandatory ?? false;

                      /// =========================
                      /// LIST TYPE
                      /// =========================
                      // if (field.fieldType == "List") {
                      //   /// Parent Task
                      //   // if (field.fieldName == "Actual Hours") {
                      //   //   return SearchableMultiColumnDropdownField<TaskModel>(
                      //   //     labelText: mandatory ? "$label *" : label,
                      //   //     items: controller.tasksValue,
                      //   //     selectedValue: controller.selectTast.value,
                      //   //     searchValue: (t) => t.taskName,
                      //   //     displayText: (t) => "${t.taskName} ${t.taskId}",
                      //   //     onChanged: (t) => controller.selectTast.value = t,
                      //   //     columnHeaders: const ["Task Id", "Task Name"],
                      //   //     rowBuilder: (t, _) => Row(
                      //   //       children: [
                      //   //         Expanded(child: Text(t.taskId)),
                      //   //         Expanded(child: Text(t.taskName)),
                      //   //       ],
                      //   //     ),
                      //   //   );
                      //   // }

                      //   /// Dependency (MultiSelect)
                      //   if (field.fieldName == "Dependency" &&
                      //       field.allowMultiSelect == true) {
                      //     return MultiSelectMultiColumnDropdownField<TaskModel>(
                      //       labelText: mandatory ? "$label *" : label,
                      //       items: controller.tasksValue,
                      //       selectedValues: controller.selectedDependency,
                      //       isMultiSelect: true,
                      //       searchValue: (t) => "${t.taskId} ${t.taskName}",
                      //       displayText: (t) => t.taskName,
                      //       onMultiChanged: (v) =>
                      //           controller.selectedDependency.assignAll(v),
                      //       columnHeaders: const ["Task Id", "Task Name"],
                      //       rowBuilder: (t, _) => Row(
                      //         children: [
                      //           Expanded(child: Text(t.taskId)),
                      //           Expanded(child: Text(t.taskName)),
                      //         ],
                      //       ), onChanged: (TaskModel? p1) {  },
                      //     );
                      //   }

                      //   /// Other List Fields (Card Types, Risk Level etc.)
                      //   return SearchableMultiColumnDropdownField<String>(
                      //     labelText: mandatory ? "$label *" : label,
                      //     items: controller.getListValues(field),
                      //     selectedValue: controller.dynamicValues[field.fieldName],
                      //     searchValue: (v) => v,
                      //     displayText: (v) => v,
                      //     onChanged: (v) =>
                      //         controller.dynamicValues[field.fieldName] = v,
                      //     columnHeaders: [label],
                      //     rowBuilder: (v, _) => Padding(
                      //       padding: const EdgeInsets.all(12),
                      //       child: Text(v),
                      //     ),
                      //   );
                      // }

                      /// =========================
                      /// INTEGER TYPE
                      /// =========================
                      if (field.fieldType == "Integer") {
                        return TextFormField(
                          decoration: InputDecoration(
                            labelText: mandatory ? "$label *" : label,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              controller.dynamicValues[field.fieldName] = v,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ), // 👈 space here
                        child: child,
                      );
                    }).toList(),
                  );
                }),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.checklist,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),

                    /// Count badge
                    if (checklist.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          checklist.length.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                    const Spacer(),

                    Text(AppLocalizations.of(context)!.showInCard),
                    SizedBox(
                      height: 24,
                      child: Transform.scale(
                        scale: 0.65,
                        child: Switch(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: showChecklistOnCard,
                          onChanged: (v) =>
                              setState(() => showChecklistOnCard = v),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: List.generate(checklist.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          /// Checkbox
                          Checkbox(
                            value: checklist[index].status,
                            onChanged: (val) {
                              setState(() {
                                checklist[index].status = val ?? false;
                              });
                            },
                          ),

                          /// Text field
                          Expanded(
                            child: TextField(
                              controller: checklistControllers[index],
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.addItem,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onChanged: (value) {
                                checklist[index].description = value;
                              },
                            ),
                          ),

                          const SizedBox(width: 6),

                          /// Delete
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                checklistControllers[index].dispose();
                                checklistControllers.removeAt(index);
                                checklist.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      checklist.add(
                        ChecklistItem(description: '', status: false, recId: 0),
                      );
                      checklistControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppLocalizations.of(context)!.addItem),
                ),

                const SizedBox(height: 24),

                /// NOTES WITH TOGGLE
                ///
                Row(
                  children: [
                    const Text(
                      '',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.showInCard,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 24,
                          child: Transform.scale(
                            scale: 0.65,
                            child: Switch(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: _showNotes,
                              onChanged: (v) => setState(() => _showNotes = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _inputDecoration('Enter notes'),
                ),

                const SizedBox(height: 10),

                /// ATTACHMENTS
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.attachments,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    // Row(
                    //   children: [
                    //     Text(
                    //       AppLocalizations.of(context)!.showInCard,
                    //       style: TextStyle(fontWeight: FontWeight.w600),
                    //     ),
                    //     SizedBox(
                    //       height: 24,
                    //       child: Transform.scale(
                    //         scale: 0.65,
                    //         child: Switch(
                    //           materialTapTargetSize:
                    //               MaterialTapTargetSize.shrinkWrap,
                    //           value: controller.showAttachment,
                    //           onChanged: (v) =>
                    //               setState(() => controller.showAttachment = v),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => controller.pickFromGallery(),
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.addAttachment,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                /// ATTACHMENTS LIST (FIXED)
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.attachments.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(AppLocalizations.of(context)!.noDataFound),
                    );
                  }

                  // FIX: Use Column instead of ListView.builder to avoid infinite size
                  return Column(
                    children: controller.attachments.map((attachment) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            attachment.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Download',
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  downloadAttachment(
                                    attachment.filePath,
                                    attachment.fileName,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  controller.removeAttachment(attachment);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 10),

                /// COMMENT INPUT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: _isCommentPosting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send, size: 18),
                          label: Text(
                            _isCommentPosting
                                ? AppLocalizations.of(context)!.posting
                                : AppLocalizations.of(context)!.comment,
                          ),
                          onPressed: _isCommentPosting
                              ? null
                              : () async {
                                  if (_commentController.text.trim().isEmpty)
                                    return;

                                  setState(() {
                                    _isCommentPosting = true;
                                  });

                                  try {
                                    await controller.postComment(
                                      taskId: taskId.text,
                                      commentedBy: Params.userId,
                                      comment: _commentController.text.trim(),
                                    );
                                    await loadComments();
                                    _commentController.clear();
                                  } catch (e) {
                                    // Handle error
                                  } finally {
                                    setState(() {
                                      _isCommentPosting = false;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// COMMENTS LIST (FIXED)
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.commentKanba.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(AppLocalizations.of(context)!.noCommentsYet),
                    );
                  }

                  // FIX: Use Column instead of ListView.builder to avoid infinite size
                  return Column(
                    children: controller.commentKanba.map((c) {
                      final initials = _getInitials(c.commentedBy);
                      final avatarColor = _generateColorFromName(c.commentedBy);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: avatarColor,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            c.commentedBy,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.comment),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    c.createdDatetime,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _saving
                              ? null
                              : _saveTask(context, widget.mainAccess);
                        },
                        child: _saving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2, // thinner circle
                                ),
                              )
                            : Text(AppLocalizations.of(context)!.save),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => {
                          _clearTaskForm(),
                          Navigator.pop(context),
                        },
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) {
      return nameParts[0].length >= 2
          ? nameParts[0].substring(0, 2).toUpperCase()
          : nameParts[0].toUpperCase();
    }
    return (nameParts[0][0] + nameParts[nameParts.length - 1][0]).toUpperCase();
  }

  void _showDateError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Color _generateColorFromName(String name) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.lime,
      Colors.brown,
    ];
    int hash = name.codeUnits.fold(0, (int acc, int unit) => acc + unit);
    return colors[hash % colors.length];
  }

  /// Helper methods
  Future<void> downloadAttachment(String url, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      await Dio().download(url, filePath);
      Fluttertoast.showToast(msg: 'Downloaded to ${dir.path}');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Download failed');
    }
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    labelText: hint,
  );

  Widget _datePicker(String label, DateTime? date, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          initialDate: date ?? DateTime.now(),
        );
        if (d != null) onPick(d);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          date == null ? 'Select date' : DateFormat('dd/MM/yyyy').format(date),
        ),
      ),
    );
  }

  void _clearTaskForm() {
    // Text fields
    _taskNameController.clear();
    _notesController.clear();
    estimatedHours.clear();
    actualHours.clear();
    version.clear();
    taskId.clear();

    // Dates
    _startDate = null;
    _dueDate = null;

    // Flags
    _showNotes = false;
    _showList = false;

    // Dropdown / selections
    _priority = "";
    _status = "";
    _cardType = "";

    // GetX selections
    controller.selectedTags.clear();
    controller.selectedMembers.clear();
    controller.selectedDependency.clear();

    controller.selectedCardType.value = null;
    controller.selectTast.value = null;

    // Force UI refresh
    setState(() {});
  }

  Future<void> _saveTask(BuildContext context, [bool? bool]) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _saving = true;
    setState(() {});

    try {
      final success = await controller.updateTask(
        main: bool,
        recId: widget.taskRecId,
        bordeId: widget.bordeId,
        taskName: _taskNameController.text,
        screenName: 'KANTasks',
        priority: _priority,
        startDate: _startDate,
        dueDate: _dueDate,
        notes: _notesController.text,
        showNotes: _showNotes,
        showChecklist: showChecklistOnCard,
        estimatedHours: double.tryParse(estimatedHours.text) ?? 0,
        status: _status,
        selectedTags: controller.selectedTags,
        selectedMembers: controller.selectedMembers,
        selectedCardType: controller.selectedCardType.value,
        parentTask: controller.selectTast.value,
        selectedDependencies: controller.selectedDependency,
        actualHours: int.tryParse(actualHours.text.trim()) ?? 0,
        version: version.text,
        dependentDescription: '',
        context: context,
        checkLists: checklist,
        taskData: dynamicFieldValues,
        plannedStartDate: plannedStartDate,
        plannedEndDate: plannedEndDate,
        riskLevel: riskLevel,
      );

      _saving = false;
      setState(() {});

      if (success) {
        _clearTaskForm();
      } else {}
    } catch (e) {
      _saving = false;
      setState(() {});
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
