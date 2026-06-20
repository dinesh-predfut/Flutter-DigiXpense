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
import 'package:media_scanner/media_scanner.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:html/parser.dart' as html_parser;

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
  List<KanbanStatus> _statusList = [];
  KanbanStatus? _selectedStatus;
  bool _isDownloading = false;
  List<ChecklistItem> checklist = [];
  bool showChecklistOnCard = false;
  List<TextEditingController> checklistControllers = [];
  String? _deletingFile;
  // Controllers
  final _taskNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _commentsController = TextEditingController();
  final estimatedHours = TextEditingController();
  final version = TextEditingController();
  final actualHours = TextEditingController();
  final cardType = TextEditingController();
  final cardTypeName = TextEditingController();

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
  String? _createdName;
  String? _createdUserId;
  String? _cardType;
  bool _showNotes = true;
  bool _showList = true;
  bool _loading = true;
  bool _saving = false;

  Future<void> _fetchCustomFieldsForCard(CardTypeModel? selectedCard) async {
    if (selectedCard == null) return;
    print("selectedCard${selectedCard.boardCardId}");
    await controller.fetchCustomFieldsBoards(
      taskRecId: widget.taskRecId,
      cardId: cardTypeName.text, // Use the card ID from the selected card
    );
  }

  Widget buildPreviewWidget(String path) {
    /// 📱 LOCAL FILE
    if (path.startsWith('/') || path.startsWith('file://')) {
      final file = File(path.replaceFirst('file://', ''));

      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            file,
            fit: BoxFit.contain,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return const SizedBox(); // wait until ready
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text("Failed to load local image"));
            },
          ),
        ],
      );
    }
    /// 🌐 NETWORK FILE
    else if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,

        /// 🔄 LOADING PROGRESS
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },

        /// ❌ ERROR
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text("Failed to load image"));
        },
      );
    }

    /// ❌ OTHER FILE TYPES
    return const Center(child: Text("Preview not available"));
  }

  Widget _buildCustomFields() {
    return Obx(() {
      if (controller.isLoadingCustomFields.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.customFieldsBoards.isEmpty) {
        return const SizedBox.shrink();
      }
      // print(
      //   "controller.customFieldsBoards${controller.customFieldsBoards.value}",
      // );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.settings, size: 20, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Custom Fields",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.customFieldsBoards.map((field) {
            // print("FIELD DATA => ${field.fieldName} ${field.fieldType}");

            return _buildCustomFieldWidget(field);
          }).toList(),
        ],
      );
    });
  }

  // Build individual custom field widget based on field type
  Widget _buildCustomFieldWidget(CustomFieldModel field) {
    final label = field.fieldLabel;
    final isMandatory = field.isMandatory;

    switch (field.fieldType) {
      case 'Amount':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: isMandatory ? '$label *' : label,
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              controller.customFieldValues[field.fieldName] = value;
            },
          ),
        );

      case 'Text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: isMandatory ? '$label *' : label,
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              controller.customFieldValues[field.fieldName] = value;
            },
          ),
        );

      case 'List':
        // If it's a list/select type field
        List<String> options = field.defaultValue
            .split(',')
            .map((e) => e.trim())
            .toList();
        if (options.isEmpty) options = ['Option 1', 'Option 2', 'Option 3'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SearchableMultiColumnDropdownField<String>(
            labelText: isMandatory ? '$label *' : label,
            columnHeaders: [label],
            items: options,
            selectedValue: controller.customFieldValues[field.fieldName] ?? '',
            searchValue: (v) => v,
            displayText: (v) => v,
            onChanged: (selected) {
              controller.customFieldValues[field.fieldName] = selected ?? '';
            },
            rowBuilder: (v, _) =>
                Padding(padding: const EdgeInsets.all(12), child: Text(v)),
          ),
        );

      case 'Date':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _datePicker(
            label,
            controller.customFieldValues[field.fieldName] != null
                ? DateTime.tryParse(
                    controller.customFieldValues[field.fieldName],
                  )
                : null,
            (date) {
              controller.customFieldValues[field.fieldName] = date
                  .toIso8601String();
            },
          ),
        );

      case 'Boolean':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(label),
              const Spacer(),
              Switch(
                value: controller.customFieldValues[field.fieldName] ?? false,
                onChanged: (value) {
                  controller.customFieldValues[field.fieldName] = value;
                },
              ),
            ],
          ),
        );

      default:
        // Default to text field
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: isMandatory ? '$label *' : label,
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              controller.customFieldValues[field.fieldName] = value;
            },
          ),
        );
    }
  }

  RxList<CommentModel> comments = <CommentModel>[].obs;
  Future<void> downloadAttachment(String path, String fileName) async {
    try {
      String tempPath;

      /// 📂 Step 1: Save to TEMP (app storage)
      final tempDir = await getTemporaryDirectory();
      tempPath = "${tempDir.path}/$fileName";

      /// 🌐 NETWORK FILE
      if (path.startsWith('http')) {
        await Dio().download(path, tempPath);
      }
      /// 📱 LOCAL FILE
      else if (path.startsWith('/') || path.startsWith('file://')) {
        final file = File(path.replaceFirst('file://', ''));
        if (await file.exists()) {
          await file.copy(tempPath);
        } else {
          throw Exception("Local file not found");
        }
      }

      /// 📸 Step 2: Save using system (Gallery visible)
      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: fileName,
      );

      final savedPath = await FlutterFileDialog.saveFile(params: params);

      print("✅ Saved to Gallery: $savedPath");
    } catch (e) {
      print("❌ Download error: $e");
    }
  }

  void loadStatuses() async {
    try {
      final data = await controller.fetchStatuses(widget.bordeId);
      setState(() {
        _statusList = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadTask();
      loadStatuses();
    });
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
      // Wait for all initial data to load
      await Future.wait([
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

      // Set basic task details
      _taskNameController.text = _taskDetails!.taskName;
      _notesController.text = _taskDetails!.notes != null
          ? parseHtmlString(_taskDetails!.notes!)
          : '';
      _priority = _taskDetails!.priority;
      _status = _taskDetails!.status;
      taskId.text = _taskDetails!.taskId;
      _createdName = _taskDetails?.createdBy?.userName ?? '';
      _createdUserId = _taskDetails?.createdBy?.userId ?? '';
      _showNotes = _taskDetails!.showNotes ?? false;
      showChecklistOnCard = _taskDetails!.showChecklist ?? false;
      _startDate = _taskDetails!.actualStartDate;
      _dueDate = _taskDetails!.actualEndDate;
      plannedEndDate = _taskDetails!.plannedEndDate;
      plannedStartDate = _taskDetails!.plannedStartDate;
      actualHours.text = _taskDetails!.actualHours.toString();
      estimatedHours.text = _taskDetails!.estimatedHours?.toString() ?? "0";
      
      print("plannedStartDate$plannedStartDate");

      // ========== CARD TYPE ==========
      final cardId = _taskDetails!.cardType?.trim();
      if (cardId != null && cardId.isNotEmpty) {
        controller.selectedCardType.value = controller.cardType
            .firstWhereOrNull((c) => c.boardCardId.trim() == cardId);
        
        // Set card type name for custom fields fetch
        cardTypeName.text = cardId;
        cardType.text = controller.selectedCardType.value?.cardName ?? '';
        
        // Fetch custom fields for this card type
        await _fetchCustomFieldsForCard(controller.selectedCardType.value);
      }

      // ========== STATUS ==========
      _selectedStatus = _statusList.firstWhere(
        (s) => s.id == _taskDetails!.status,
        orElse: () => _statusList.first,
      );

      // ========== ASSIGNED MEMBERS ==========
      controller.selectedMembers.clear();
      for (final assigned in _taskDetails!.assignedTo) {
        final user = controller.boardMembers.firstWhereOrNull(
          (u) => u.userName == assigned.employeeName,
        );
        print("useruser$user");
        if (user != null) {
          controller.selectedMembers.add(user);
        }
      }
      
      controller.userIdController.text = controller.selectedMembers
          .map((e) => e.userId)
          .join(', ');

      // ========== TAGS ==========
      controller.selectedTags.clear();
      for (final tag in _taskDetails!.tagId) {
        final matched = controller.taskTags.firstWhereOrNull(
          (t) => t.tagId == tag.tagId,
        );
        controller.selectedTags.add(matched ?? tag);
      }

      // ========== TASK CONFIG / DYNAMIC FIELDS ==========
      // Load dynamic field values from task config
      if (controller.taskConfig.value?.taskData != null) {
        // Clear existing dynamic values
        controller.dynamicValues?.clear();
        
        for (final field in controller.taskConfig.value!.taskData) {
          // For each field, set its value
          if (field.value != null) {
            controller.dynamicValues![field.fieldName!] = field.value;
          }
        }
        
        // Also store task fields for UI rendering
        controller.taskFields.assignAll(controller.taskConfig.value!.taskData);
      }

      // ========== CUSTOM FIELDS ==========
      // Clear existing custom field values
      controller.customFieldValues.clear();
      
      // Load custom field values if they exist in task details
      if (_taskDetails!.customFields != null) {
        // Assuming customFields is a Map<String, dynamic> or List<CustomFieldValue>
        // You'll need to adapt this based on your actual data structure
        for (final field in _taskDetails!.customFields!) {
          // This depends on your actual data structure
          // Example: if customFields is a list of {fieldName: value}
          controller.customFieldValues[field.fieldName] = field;
        }
      }
      
      // Also fetch custom fields from the API if needed
      if (cardId != null && cardId.isNotEmpty) {
        await _fetchCustomFieldsForCard(controller.selectedCardType.value);
      }

      // ========== DEPENDENCIES (commented out) ==========
      // controller.selectedDependency.clear();
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

    // Load attachments and comments after everything else
    await Future.wait([loadAttachmentData(), loadComments()]);
  }

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  Widget buildDynamicField(TaskFieldConfig field) {
    final label = field.fieldLabel ?? field.fieldName;
    final mandatory = field.isMandatory ?? false;

    switch (field.fieldType) {
      // Amount / Decimal / Currency
      case "Amount":
      case "Decimal":
      case "Currency":
      case "Number":
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            decoration: InputDecoration(
              labelText: mandatory ? "$label *" : label,
              border: const OutlineInputBorder(),
            ),

            validator: (value) {
              if (mandatory && (value == null || value.trim().isEmpty)) {
                return "$label is required";
              }

              if (value != null &&
                  value.isNotEmpty &&
                  double.tryParse(value) == null) {
                return "Enter valid $label";
              }

              return null;
            },

            onChanged: (value) {
              controller.dynamicValues![field.fieldName!] =
                  double.tryParse(value) ?? value;
            },
          ),
        );

      // Integer
      case "Integer":
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: mandatory ? "$label *" : label,
              border: const OutlineInputBorder(),
            ),

            validator: (value) {
              if (mandatory && (value == null || value.isEmpty)) {
                return "$label is required";
              }

              if (value != null &&
                  value.isNotEmpty &&
                  int.tryParse(value) == null) {
                return "Enter valid number";
              }

              return null;
            },

            onChanged: (value) {
              controller.dynamicValues![field.fieldName!] =
                  int.tryParse(value) ?? value;
            },
          ),
        );

      // Text
      case "Text":
      case "String":
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: mandatory ? "$label *" : label,
              border: const OutlineInputBorder(),
            ),

            validator: (value) {
              if (mandatory && (value == null || value.trim().isEmpty)) {
                return "$label is required";
              }

              return null;
            },

            onChanged: (value) {
              controller.dynamicValues![field.fieldName!] = value;
            },
          ),
        );

      // URL
      case "Url":
      case "URL":
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            keyboardType: TextInputType.url,

            decoration: InputDecoration(
              labelText: mandatory ? "$label *" : label,
              border: const OutlineInputBorder(),
            ),

            validator: (value) {
              if (mandatory && (value == null || value.isEmpty)) {
                return "$label is required";
              }

              if (value != null &&
                  value.isNotEmpty &&
                  !Uri.tryParse(value)!.hasAbsolutePath) {
                return "Enter valid URL";
              }

              return null;
            },

            onChanged: (value) {
              controller.dynamicValues![field.fieldName!] = value;
            },
          ),
        );

      // Dropdown / List
      case "List":
      case "SystemList":
        final options = (field.listValues ?? [])
            .map((e) => e.taskName)
            .toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SearchableMultiColumnDropdownField<String>(
            labelText: mandatory ? '$label *' : label,

            columnHeaders: [label!],

            items: options,

            selectedValue: controller.customFieldValues[field.fieldName] ?? '',

            searchValue: (v) => v,

            displayText: (v) => v,

            onChanged: (selected) {
              controller.customFieldValues[field.fieldName!] = selected ?? '';
            },

            rowBuilder: (v, _) {
              return Padding(padding: const EdgeInsets.all(12), child: Text(v));
            },
          ),
        );

      // Boolean
      case "Boolean":
      case "YesNo":
        return SwitchListTile(
          title: Text(label!),

          value: controller.dynamicValues![field.fieldName] ?? false,

          onChanged: (value) {
            controller.dynamicValues![field.fieldName!] = value;
          },
        );

      // Date
      case "Date":
        return TextFormField(
          readOnly: true,

          decoration: InputDecoration(
            labelText: mandatory ? "$label *" : label,
            border: const OutlineInputBorder(),
          ),

          validator: (value) {
            if (mandatory && (value == null || value.isEmpty)) {
              return "$label is required";
            }

            return null;
          },

          onTap: () {
            // open date picker here
          },
        );

      default:
        return TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),

          onChanged: (value) {
            controller.dynamicValues![field.fieldName!] = value;
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: SkeletonLoaderPage()));
    }
    int selectedCount = checklist.where((item) => item.status == true).length;
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
                if (_createdName != null)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 👇 Avatar
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              (_createdName != null)
                                  ? _createdName![0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // 👇 Text content
                          Flexible(
                            child: Text(
                              "Created By: $_createdName | $_createdUserId",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// TASK NAME
                // _section('${AppLocalizations.of(context)!.taskName} *'),
                TextFormField(
                  controller: _taskNameController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  decoration: _inputDecoration(
                    '${AppLocalizations.of(context)!.taskName} *',
                  ),
                ),

                const SizedBox(height: 12),

                /// TAGS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ✅ DROPDOWN
                    Obx(() {
                      /// 🔥 FILTER OUT SELECTED TAGS (NO DUPLICATES)
                      final availableTags = controller.taskTags
                          .where(
                            (tag) => !controller.selectedTags.any(
                              (selected) => selected.tagId == tag.tagId,
                            ),
                          )
                          .toList();

                      return MultiSelectMultiColumnDropdownField<TagModel>(
                        key: ValueKey(controller.tagDropdownRefresh.value),
                        showSelectedText: false,
                        enabled: true,
                        labelText: AppLocalizations.of(context)!.tags,

                        /// ✅ FILTERED LIST
                        items: availableTags,

                        /// ✅ STILL PASS SELECTED VALUES
                        selectedValues: controller.selectedTags,

                        isMultiSelect: true,

                        searchValue: (tag) => '${tag.tagId} ${tag.tagName}',
                        displayText: (tag) => '\u200B', // zero-width space
                        /// 🔥 SAFE MULTI SELECT (NO DUPLICATES)
                        onMultiChanged: (tags) {
                          final uniqueMap = <String, TagModel>{};

                          for (var tag in tags) {
                            uniqueMap[tag.tagId] = tag;
                          }

                          controller.selectedTags.assignAll(
                            uniqueMap.values.toList(),
                          );
                        },

                        columnHeaders: [
                          AppLocalizations.of(context)!.tagId,
                          AppLocalizations.of(context)!.tagName,
                        ],

                        /// ✅ ROW DESIGN
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

                    const SizedBox(height: 10),

                    /// ✅ SELECTED TAG CHIPS
                    Obx(() {
                      if (controller.selectedTags.isEmpty)
                        return const SizedBox();

                      return Wrap(
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

                            /// 🔥 REMOVE TAG
                            onDeleted: () {
                              controller.selectedTags.remove(tag);

                              /// 🔥 FORCE DROPDOWN REFRESH
                              controller.tagDropdownRefresh.value++;
                            },
                          );
                        }).toList(),
                      );
                    }),
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
                        labelText:
                            '${AppLocalizations.of(context)!.assignUsers} *',
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
                  const SizedBox(height: 12),
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

                  onChanged: (c) async {
                    print("Selected Card Object: $c");
                    print("Card Name: ${c?.cardName}");
                    print("Board Card ID: ${c?.boardCardId}");

                    controller.selectedCardType.value = c;

                    cardType.text = c?.cardName ?? '';
                    cardTypeName.text = c?.boardCardId?.toString() ?? "";

                    print("cardTypeName value: ${cardTypeName.text}");

                    if (c != null && cardTypeName.text.isNotEmpty) {
                      await _fetchCustomFieldsForCard(c);
                    } else {
                      controller.customFieldsBoards.clear();
                      print("Card ID is empty, API not called");
                    }
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

                const SizedBox(height: 12),
                SearchableMultiColumnDropdownField<KanbanStatus>(
                  enabled: true,
                  labelText: AppLocalizations.of(context)!.status,
                  columnHeaders: [AppLocalizations.of(context)!.type],

                  items: _statusList,

                  selectedValue: _selectedStatus,

                  searchValue: (item) => item.name,
                  displayText: (item) => item.name,

                  onChanged: (item) {
                    setState(() {
                      _selectedStatus = item!;
                    });
                  },

                  rowBuilder: (item, searchQuery) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(children: [Expanded(child: Text(item.name))]),
                    );
                  },
                ),
                //   /// VERSION
                //   TextFormField(
                //     keyboardType: TextInputType.numberWithOptions(),
                //     controller: version,
                //     decoration: _inputDecoration(
                //       AppLocalizations.of(context)!.version,
                //     ),
                //   ),
                const SizedBox(height: 12),
                if (controller.taskFields.isNotEmpty)
                  Obx(() {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.settings,
                              size: 20,
                              color: Colors.blueAccent,
                            ),
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
                        ...controller.taskFields.map((field) {
                          return buildDynamicField(field);
                        }).toList(),
                      ],
                    );
                  }),
                const SizedBox(height: 12),

                _buildCustomFields(),
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
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$selectedCount/${checklist.length}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                    const Spacer(),

                    // Text(AppLocalizations.of(context)!.showInCard),
                    // SizedBox(
                    //   height: 24,
                    //   child: Transform.scale(
                    //     scale: 0.65,
                    //     child: Switch(
                    //       materialTapTargetSize:
                    //           MaterialTapTargetSize.shrinkWrap,
                    //       value: showChecklistOnCard,
                    //       onChanged: (v) =>
                    //           setState(() => showChecklistOnCard = v),
                    //     ),
                    //   ),
                    // ),
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

                const SizedBox(height: 14),

                /// NOTES WITH TOGGLE
                ///
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
                              /// 👁 Preview
                              IconButton(
                                tooltip: 'Preview',
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  showAttachmentPreview(context, attachment);
                                },
                              ),

                              /// ⬇️ Download
                              IconButton(
                                tooltip: 'Download',
                                icon: _isDownloading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.download),
                                onPressed: _isDownloading
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isDownloading = true;
                                        });

                                        try {
                                          await downloadAttachment(
                                            attachment.filePath,
                                            attachment.fileName,
                                          );
                                        } catch (e) {
                                          print(e);
                                        } finally {
                                          setState(() {
                                            _isDownloading = false;
                                          });
                                        }
                                      },
                              ),

                              /// 🗑 Delete
                              IconButton(
                                tooltip: 'Delete',
                                icon: _deletingFile == attachment.fileName
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                onPressed: _deletingFile == attachment.fileName
                                    ? null
                                    : () async {
                                        setState(() {
                                          _deletingFile = attachment.fileName;
                                        });

                                        try {
                                          final success = await controller
                                              .removeAttachment(attachment);

                                          if (success == true) {
                                            setState(() {
                                              controller.attachments.remove(
                                                attachment,
                                              ); // ✅ remove only after success
                                            });
                                          }
                                        } catch (e) {
                                          print(e);
                                        } finally {
                                          setState(() {
                                            controller.attachments.remove(
                                              attachment,
                                            ); // ✅ remove only after success
                                          });
                                          setState(() {
                                            _deletingFile = null;
                                          });
                                        }
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
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.comment,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor, // or any color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${controller.commentKanba.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                                DateFormat('dd-MM-yyyy, hh:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    c.createdDatetime,
                                    isUtc: true,
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

  void showAttachmentPreview(BuildContext context, attachment) {
    final String path = attachment.filePath;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            height: 400,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        attachment.fileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                /// ✅ Just call widget (no conditions here)
                Expanded(child: buildPreviewWidget(path)),
              ],
            ),
          ),
        );
      },
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

  // /// Helper methods
  // Future<void> downloadAttachment(String url, String fileName) async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final filePath = '${dir.path}/$fileName';
  //     await Dio().download(url, filePath);
  //     Fluttertoast.showToast(msg: 'Downloaded to ${dir.path}');
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: 'Download failed');
  //   }
  // }

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
          date == null
              ? 'Select date'
              : DateFormat(
                  controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                ).format(date.toLocal()),
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

  List<Map<String, dynamic>> _buildCustomFieldValuesPayload() {
    final List<Map<String, dynamic>> payload = [];

    for (final field in controller.customFieldsBoards) {
      final enteredValue = controller.customFieldValues[field.fieldName];
      if (enteredValue == null)
        continue; // skip untouched fields if backend prefers that

      payload.add({
        "FieldId": field.fieldId, // <-- need to confirm this property name
        "FieldValue": enteredValue,
        "FieldName": field.fieldName,
        "RecId": 0,
      });
    }

    return payload;
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
        // taskData: controller.dynamicValues,
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
        taskData: controller.dynamicValues,
        plannedStartDate: plannedStartDate,
        plannedEndDate: plannedEndDate,
        riskLevel: riskLevel,
        customFieldValues: _buildCustomFieldValuesPayload(),
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
