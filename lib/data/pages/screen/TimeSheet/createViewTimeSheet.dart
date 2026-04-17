import 'dart:async';
import 'dart:convert';
import 'package:diginexa/core/comman/widgets/customTimesheetDatePicker.dart';
import 'package:diginexa/core/comman/widgets/loaderbutton.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart'
    show PermissionHelper;
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/core/constant/url.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/API_Service/apiService.dart'
    show ApiService;
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'package:intl/intl.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:dio/dio.dart';

import '../../../../core/comman/widgets/pageLoaders.dart'; // Add this for API calls

class ProjectModel {
  final String code;
  final String name;
  ProjectModel(this.code, this.name);
}

class TaskModel {
  final String id;
  final String name;
  TaskModel(this.id, this.name);
}

class TimeSheetRequestPage extends StatefulWidget {
  final bool status;
  final bool? team;
  const TimeSheetRequestPage({super.key, required this.status, this.team});

  @override
  State<TimeSheetRequestPage> createState() => _TimeSheetRequestPageState();
}

class _TimeSheetRequestPageState extends State<TimeSheetRequestPage> {
  /// =======================
  /// FORM STATE
  /// =======================

  final Controller controller = Get.find<Controller>();

  /// =======================
  /// CONTROLLERS
  /// =======================
  final TextEditingController projectCtrl = TextEditingController();
  final TextEditingController boardCtrl = TextEditingController();
  final TextEditingController taskCtrl = TextEditingController();
  final TextEditingController taskNameCtrl = TextEditingController();
  late Future<List<TimeSheetHistory>> timeSheetHistoryFuture;

  /// =======================
  /// DROPDOWN DATA (API)
  /// =======================
  final List<ProjectModel> projects = [
    ProjectModel('AUT', 'AutomatedSuite'),
    ProjectModel('HR', 'HR Portal'),
  ];

  final List<String> periodTypes = [
    'Day',
    'Weekly',
    'BiWeekly',
    'Semimonthly',
    'Monthly',
  ];
  String getFrequency(String periodType) {
    print("periodType$periodType");

    switch (periodType) {
      case 'Weekly':
        return 'Week';
      case 'BiWeekly':
        return 'Biweekly';
      case 'Monthly':
        return 'Month';
      case 'Semimonthly':
        return 'Semimonthly'; // 👈 FULL NAME
      case 'Day':
        return 'Day';
      default:
        return 'None';
    }
  }

  /// =======================
  /// FORM VALIDATION
  /// =======================
  bool _validateForm() {
    bool isValid = true;
    final config = controller.getFieldConfigSheet("Project Id");
    print("Project Id${config.isMandatory}");
    // Validate main form fields
    if (config.isMandatory &&
        controller.projectDropDowncontroller.text.isEmpty) {
      controller.showProjectError.value = true;
      isValid = false;
    } else {
      controller.showProjectError.value = false;
    }

    if (controller.dateRange == null) {
      isValid = false;
    }

    // Validate line items
    if (controller.lineItems.isEmpty) {
      isValid = false;
    }

    for (int i = 0; i < controller.lineItems.length; i++) {
      final line = controller.lineItems[i];

      if (line.project == null && config.isMandatory) {
        isValid = false;
      }

      if (line.board == null) {
        isValid = false;
      }

      if (line.task == null) {
        isValid = false;
      }
    }

    return isValid;
  }

  /// =======================
  /// PREPARE API REQUEST BODY
  /// =======================
  Map<String, dynamic> _prepareRequestBody() {
    // Get current employee info (you might need to get this from your auth system)
    final employeeId = Params.employeeId; // Replace with actual employee ID
    final employeeName = Params.employeeName;
    print("REDID${controller.recId}");

    List<Map<String, dynamic>> timesheetLines = [];

    for (int i = 0; i < controller.lineItems.length; i++) {
      final line = controller.lineItems[i];
      final timeEntries = controller.timeEntries[i] ?? {};

      // Prepare DailyEntry for this line
      List<Map<String, dynamic>> dailyEntries = [];

      timeEntries.forEach((entryDate, entry) {
        dailyEntries.add({
          "EntryDate": entryDate,
          "TimeFrom": entry.timeFrom,
          "TimeTo": entry.timeTo,
          "TotalHours": double.tryParse(entry.totalHours) ?? 0.0,
          "OTHours": null,
          "TimerRunning": false,
          "InternalComment": entry.comment,
          "RecId": entry.recId,
        });
      });

      // Add custom fields if needed
      List<Map<String, dynamic>> linesCustomFields = controller
          .prepareLineCustomFieldsForAPI(i);

      timesheetLines.add({
        "LinesCustomfields": linesCustomFields,
        "ProjectId": line.project?.code?.isEmpty == true
            ? null
            : line.project?.code,

        "BoardId": line.board?.boardId ?? "",
        "TaskId": line.task?.taskId ?? "",
        "InternalComment": "",
        "ExternalComment": "",
        "IsConverted": false,
        "RecId": line.recId,
        "DailyEntry": dailyEntries,
        "TaskName": line.task?.taskName ?? "",
      });
    }

    List<Map<String, dynamic>> timesheetCustomFieldValues = controller
        .prepareHeaderCustomFieldsForAPI();
    return {
      "TimesheetId": controller.timeSheetID.text.trim().isEmpty
          ? null
          : controller.timeSheetID.text.trim(),

      "EmployeeId": employeeId,
      "ApplicationDate": DateTime.now().millisecondsSinceEpoch,
      "Source": "Web",
      "CaptureMethod": controller.timerClicked ? "TimeTracker" : "Manual",
      "FromDate": controller.dateRange!.start.millisecondsSinceEpoch,
      "ToDate": controller.dateRange!.end.millisecondsSinceEpoch,
      "EmployeeName": Params.employeeName ?? controller.userName.value,
      "TimesheetLocation": null,
      "ReferenceId": null,
      "Frequency": getFrequency(controller.periodType.value),
      // Convert "Weekly" to "Week"
      "ProjectId": controller.projectDropDowncontroller.text.isEmpty
          ? null
          : controller.projectDropDowncontroller.text,

      "TimesheetCustomFieldValues": timesheetCustomFieldValues,
      "Timesheetlines": timesheetLines,
      "DocumentAttachment": {"File": []},
      "RecId": (controller.recId == null || controller.recId == 0)
          ? null
          : controller.recId,
      "CalendarId": null,
    };
  }

  /// =======================
  /// SUBMIT API CALL
  /// =======================
  Future<void> _submitTimeSheet(BuildContext context, bool isResubmit) async {
    try {
      // Prepare request body
      final requestBody = _prepareRequestBody();
      print("requestBody$requestBody");
      // Call API
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/createtimesheetmanual?Submit=true&Resubmit=$isResubmit&screen_name=MyTimesheets&functionalentity=TimesheetRequisition',
        ),
        body: jsonEncode(requestBody),
      );

      // Handle response
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 280) {
        controller.clearTimeSheetForm();

        setState(() {
          controller.periodType.value = '';
          controller.dateRange = null;
        });
        Navigator.pushNamed(context, AppRoutes.timeSheetDashboard);
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message ?? "Timesheet Resubmitted Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Timesheet Submit Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("2222dd$e");
      // Close loading dialog if still open
    }
  }

  /// =======================
  /// SAVE AS DRAFT API CALL
  /// =======================
  Future<void> _saveAsDraft(BuildContext context) async {
    try {
      // Prepare request body (same as submit but with Submit=false)
      final requestBody = _prepareRequestBody();

      // Call API with Submit=false for draft
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/createtimesheetmanual?Submit=false&Resubmit=false&screen_name=MyTimesheets&functionalentity=TimesheetRequisition',
        ),
        body: jsonEncode(requestBody),
      );

      // Handle response
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 280) {
        controller.clearTimeSheetForm();

        setState(() {
          controller.periodType.value = '';
          controller.dateRange = null;
        });
        Navigator.pushNamed(context, AppRoutes.timeSheetDashboard);
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final message = responseData['detail']['message'];

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {}
  }

  /// =======================
  /// CANCEL TIMESHEET API CALL
  /// =======================
  Future<void> _cancelTimeSheet() async {
    print("_cancelTimeSheet");

    try {
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expensecancel'
          '?context_recid=${controller.recId}'
          '&screen_name=MyTimesheet'
          '&functionalentity=TimesheetRequisition',
        ),
      );

      if (!mounted) return; // 🔥 VERY IMPORTANT

      if (response.statusCode == 200 || response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: "Timesheet Cancelled Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushNamed(context, AppRoutes.timeSheetDashboard);
      }
    } catch (e) {
      print("Cancel error: $e");
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Add these variables for status management

  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();

    if (widget.status) {
      timeSheetHistoryFuture = controller.fetchTimeSheetHistory(
        controller.recId,
      );
      controller.fetchUsers();
    }
    // controller.Sheetconfiguration();

    // Initialize status from widget data if exists
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.isLoading.value = true;
      await init();
      controller.loadSequenceModules();

      controller.Sheetconfiguration();
      if (PermissionHelper.canUpdate("Timesheet Requisition")) {
        controller.isEnable.value = false;
      }
      if (controller.statusApproval == "Review") {
        controller.isEnable.value = false;
      }
      if (widget.team!) {
        controller.sheetEnable.value = false;
      }
      if (!widget.status) {
        if (controller.statusApproval == "Approved") {
          controller.sheetEnable.value = false;
        } else {
          controller.sheetEnable.value = true;
        }

        // final now = DateTime.now();

        // // 1st day of current month
        // final startDate = DateTime(now.year, now.month, 1);

        // // 7th day of current month
        // final endDate = DateTime(now.year, now.month, 7);

        // controller.dateRange = DateTimeRange(start: startDate, end: endDate);
      }
      controller.fetchProjectName();
      controller.fetchBoardDropDown();

      controller.fetchTasksTimeSheet(
        fromDate: controller.dateRange!.start.millisecondsSinceEpoch,
        toDate: controller.dateRange!.end.millisecondsSinceEpoch,
      );
      final start = controller.dateRange!.start;
      final end = controller.dateRange!.end;

      controller.loadTimeSheetRange(
        fromDate: DateTime(
          start.year,
          start.month,
          start.day,
        ).millisecondsSinceEpoch,

        toDate: DateTime(
          end.year,
          end.month,
          end.day,
          23,
          59,
          59,
          999,
        ).millisecondsSinceEpoch,
      );
      controller.isLoading.value = false;
    });
  }

  // In your controller's initialization
  Future<void> init() async {
    DateTime now = DateTime.now();
    final range = controller.getWeekRangeUTC(DateTime.now());
    final config = await controller.getRuleConfig(
      employeeId: Params.employeeId,
      fromDate: DateTime.fromMillisecondsSinceEpoch(range['fromDate']!),
      toDate: DateTime.fromMillisecondsSinceEpoch(range['toDate']!),
    );
    controller.ruleConfig = config;
    if (config != null) {
      controller.periodType.value = controller.getPeriodTypeForUI(
        config.entryFrequency ?? '',
      );
    }
    print(controller.periodType.value);
    final frequency = config?.entryFrequency ?? "";

    controller.dateRange = _getDateRangeByPeriod(
      frequency,
      now,
      weekStart: config?.dayWeekStarts ?? "Monday",
      monthStart: config?.dayMonthStarts ?? "1st",
    );
    // Use frequency value
  }

  DateTimeRange getRangeFromConfig(
    String type,
    DateTime date, {
    String weekStart = "Monday",
    String monthStart = "1st",
  }) {
    date = DateTime(date.year, date.month, date.day);

    int getWeekdayIndex(String day) {
      const map = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
      };
      return map[day] ?? 1;
    }

    int weekStartIndex = getWeekdayIndex(weekStart);

    // ================= WEEK =================
    if (type == "Weekly") {
      int diff = (date.weekday - weekStartIndex + 7) % 7;
      DateTime start = date.subtract(Duration(days: diff));
      DateTime end = start.add(const Duration(days: 6));

      return DateTimeRange(start: start, end: end);
    }

    // ================= BIWEEKLY =================
    if (type == "BiWeekly") {
      int diff = (date.weekday - weekStartIndex + 7) % 7;
      DateTime currentWeekStart = date.subtract(Duration(days: diff));

      // Align to previous even week cycle
      int weekNumber = int.parse(
        "${currentWeekStart.year}${currentWeekStart.month}${currentWeekStart.day}",
      );

      bool isEven = currentWeekStart.day % 14 < 7;

      DateTime start = isEven
          ? currentWeekStart.subtract(const Duration(days: 7))
          : currentWeekStart;

      DateTime end = start.add(const Duration(days: 13));

      return DateTimeRange(start: start, end: end);
    }

    // ================= MONTH =================
    if (type == "Monthly") {
      DateTime start = DateTime(date.year, date.month, 1);
      DateTime end = DateTime(date.year, date.month + 1, 0);

      return DateTimeRange(start: start, end: end);
    }

    // ================= SEMI-MONTH =================
    if (type == "Semimonthly") {
      int day = date.day;

      if (day <= 15) {
        DateTime start = DateTime(date.year, date.month, 1);
        DateTime end = DateTime(date.year, date.month, 15);

        return DateTimeRange(start: start, end: end);
      } else {
        DateTime start = DateTime(date.year, date.month, 16);
        DateTime end = DateTime(date.year, date.month + 1, 0);

        return DateTimeRange(start: start, end: end);
      }
    }

    // fallback
    return DateTimeRange(start: date, end: date);
  }

  int getWeekdayFromString(String day) {
    switch (day) {
      case "Monday":
        return DateTime.monday;
      case "Tuesday":
        return DateTime.tuesday;
      case "Wednesday":
        return DateTime.wednesday;
      case "Thursday":
        return DateTime.thursday;
      case "Friday":
        return DateTime.friday;
      case "Saturday":
        return DateTime.saturday;
      case "Sunday":
        return DateTime.sunday;
      default:
        return DateTime.monday; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.leaveField.value = false;
        if (!controller.sheetEnable.value) {
          controller.clearTimeSheetForm();
          return true;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: controller.leaveField.value
                ? Text(AppLocalizations.of(context)!.exitForm)
                : const Text("View Time Sheet"),
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          controller.clearTimeSheetForm();

          Navigator.of(context).pop();
          return true;
        }

        return false;
      },
      child: Scaffold(
        // backgroundColor: const Color(0xfff6f7fb),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.timeSheetRequestForm),
          centerTitle: true,
          actions: [
            if (!widget.team! &&
                widget.status &&
                PermissionHelper.canRead("Timesheet Requisition") &&
                controller.statusApproval != "Approved" &&
                controller.statusApproval != "Cancelled" &&
                controller.statusApproval != "Pending")
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.sheetEnable.value
                        ? Icons
                              .remove_red_eye // View
                        : Icons.edit_document, // Edit
                  ),
                  onPressed: () {
                    controller.sheetEnable.toggle();
                  },
                ),
              ),
          ],
        ),

        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: SkeletonLoaderPage());
          }
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _topForm(),
                        const SizedBox(height: 16),
                        _actionButtons(),
                        const SizedBox(height: 16),
                        ..._buildLineItems(),
                        if (widget.status)
                          _buildSection(
                            title: AppLocalizations.of(
                              context,
                            )!.trackingHistory,
                            children: [
                              const SizedBox(height: 12),
                              FutureBuilder<List<TimeSheetHistory>>(
                                future: timeSheetHistoryFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.noHistoryMessage,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final historyList = snapshot.data!;

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: historyList.length,
                                    itemBuilder: (context, index) {
                                      return _buildTimelineItem(
                                        historyList[index],
                                        index == historyList.length - 1,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        if (PermissionHelper.canUpdate("Timesheet Requisition"))
                          _buildBottomButtons(context),
                        if (!PermissionHelper.canUpdate(
                          "Timesheet Requisition",
                        ))
                          _buildViewModeButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildViewModeButtons() {
    return Column(
      children: [
        const SizedBox(height: 22),

        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            AppLocalizations.of(context)!.close,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            collapsedIconColor: Colors.grey,
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            children: children,
          ),
        ),
      ),
    );
  }

  /// =======================
  /// TOP FORM
  /// =======================
  Widget _topForm() {
    return Obx(() {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() {
                final hideField = controller.hasModule("TimeSheetManagement");
                if (controller.isSequenceLoading.value) {
                  return const SizedBox(); // or loader
                }
                if (controller.timeSheetID.text.isEmpty) {
                  if (hideField) {
                    return const SizedBox.shrink(); // ✅ hide
                  }
                }

                return Column(
                  children: [
                    TextFormField(
                      enabled: !hideField,
                      controller: controller.timeSheetID,
                      decoration: InputDecoration(
                        labelText:
                            '${AppLocalizations.of(context)!.timesheetRequisitionId} *',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              Row(
                children: [
                  controller.buildConfigurableField(
                    fieldName: 'Project Id',
                    builder: (isEnabled, isMandatory) {
                      return Expanded(
                        child: SearchableMultiColumnDropdownField<Project>(
                          labelText:
                              '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""} ',
                          enabled: controller.sheetEnable.value,
                          columnHeaders: [
                            AppLocalizations.of(context)!.projectName,
                            AppLocalizations.of(context)!.projectId,
                          ],
                          items: controller.project,
                          // dropdownWidth: 300,
                          controller: controller.projectDropDowncontroller,
                          selectedValue: controller.selectedProject,
                          validator: (value) {
                            if (controller
                                    .projectDropDowncontroller
                                    .text
                                    .isEmpty &&
                                isMandatory) {
                              return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          searchValue: (proj) => '${proj.name} ${proj.code}',
                          displayText: (proj) => proj.code,
                          onChanged: (proj) {
                            controller.projectDropDowncontroller.text =
                                proj!.code;
                            setState(() {
                              controller.selectedProject = proj;
                              controller.showProjectError.value = false;
                            });
                          },
                          rowBuilder: (proj, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(child: Text(proj.name)),
                                  Expanded(child: Text(proj.code)),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  controller.buildConfigurableField(
                    fieldName: 'Project Id',
                    builder: (isEnabled, isMandatory) {
                      return const SizedBox(width: 12);
                    },
                  ),
                  Expanded(child: _periodDropdown()),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: !controller.sheetEnable.value ? null : _pickDateRange,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.dateRange} *',
                    enabled: controller.sheetEnable.value,

                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                    errorText: controller.dateRange == null
                        ? 'This field is required'
                        : null,
                  ),
                  child: Text(
                    controller.dateRange == null
                        ? 'Select'
                        : '${DateFormat('dd-MM-yyyy').format(controller.dateRange!.start)} - '
                              '${DateFormat('dd-MM-yyyy').format(controller.dateRange!.end)}',
                  ),
                ),
              ),
              Obx(() => _buildHeaderCustomFields()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCustomFields() {
    if (controller.headerCustomFields.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 10),
        ...controller.headerCustomFields.map((field) {
          final isMandatory = field['IsMandatory'] ?? false;
          final label = '${field['FieldName']}${isMandatory ? ' *' : ''}';
          final fieldType =
              field['FieldType']?.toString().toLowerCase() ?? 'text';
          final enable = controller.sheetEnable.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCustomFieldWidget(
              field: field,
              enable: enable,
              label: label,
              fieldType: fieldType,
              onChanged: (value) {
                controller.updateCustomFieldValue(
                  null,
                  field['FieldId'],
                  value,
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  // Build custom field widget based on type
  Widget _buildCustomFieldWidget({
    required Map<String, dynamic> field,
    required String label,
    required String fieldType,
    required Function(String) onChanged,
    required bool enable,
  }) {
    final controller = TextEditingController(
      text: field['FieldValue']?.toString() ?? '',
    );

    final isMandatory = field['IsMandatory'] ?? false;

    switch (fieldType) {
      case 'dropdown':
      case 'select':
        final options = List<String>.from(field['Options'] ?? []);

        return DropdownButtonFormField<String>(
          value: field['FieldValue']?.toString(),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: enable
              ? (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                }
              : null,
          validator: enable
              ? (value) {
                  if (isMandatory && (value == null || value.isEmpty)) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );

      case 'date':
        return TextFormField(
          controller: controller,
          enabled: enable,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: enable
                  ? () async {
                      final date = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final formattedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);
                        controller.text = formattedDate;
                        onChanged(formattedDate);
                      }
                    }
                  : null,
            ),
          ),
          readOnly: true,
          validator: enable
              ? (value) {
                  if (isMandatory && (value == null || value.isEmpty)) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );

      case 'number':
        return TextFormField(
          controller: controller,
          enabled: enable,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: enable ? onChanged : null,
          validator: enable
              ? (value) {
                  if (isMandatory && (value == null || value.isEmpty)) {
                    return 'This field is required';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }
              : null,
        );

      default: // text, textarea
        return TextFormField(
          controller: controller,
          enabled: enable,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: fieldType == 'textarea' ? 3 : 1,
          onChanged: enable ? onChanged : null,
          validator: enable
              ? (value) {
                  if (isMandatory && (value == null || value.isEmpty)) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );
    }
  }

  Widget _buildTimelineItem(TimeSheetHistory item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Timeline indicator
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 60, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),

        /// Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.eventType,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(item.notes),
              const SizedBox(height: 4),
              Text(
                '${item.userName} • ${_formatDate(item.createdDatetime)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    return DateFormat('dd-MM-yyyy, hh:mm a').format(date);
  }

  Widget _periodDropdown() {
    return Obx(() {
      return SearchableMultiColumnDropdownField<String>(
        labelText: "${AppLocalizations.of(context)!.periodType} *",
        columnHeaders: ["Type"],
        enabled: controller.sheetEnable.value,

        items: periodTypes,
        selectedValue: controller.periodType.value,

        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.periodTypeIsRequired;
          }
          return null;
        },

        searchValue: (type) => type,
        displayText: (type) => type,

        onChanged: (type) {
          controller.periodType.value = type!;

          controller.dateRange = _getDateRangeByPeriod(
            type,
            DateTime.now(),
            weekStart: controller.ruleConfig?.dayWeekStarts ?? "",
            monthStart: controller.ruleConfig?.dayMonthStarts ?? "",
          );

          controller.loadTimeSheetRange(
            fromDate: controller.getStartOfDayMillis(
              controller.dateRange!.start,
            ),
            toDate: controller.getEndOfDayMillis(controller.dateRange!.end),
          );
        },

        rowBuilder: (type, searchQuery) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(children: [Expanded(child: Text(type))]),
          );
        },
      );
    });
  }

  /// =======================
  /// ACTION BUTTONS
  /// =======================
  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          onPressed: () {
            if (controller.sheetEnable.value) {
              final newIndex = controller.lineItems.length;

              setState(() {
                controller.lineItems.add(LineItemModel());

                controller.lineCustomFields[newIndex] = controller
                    .masterLineCustomFields
                    .map((field) {
                      return {
                        ...field,
                        "FieldValue": "", // ensure empty
                      };
                    })
                    .toList();
              });

              controller.lineCustomFields.refresh();
            }
          },
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.addLine),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            final line = controller.lineItems[controller.lineItems.length - 1];
            if (controller.sheetEnable.value &&
                !line.timerRunning.value &&
                controller.enableTimerButton.value) {
              setState(() {
                controller.lineItems.add(LineItemModel());
              });

              final today = DateTime.now();
              controller.startTimer(controller.lineItems.length - 1, today);
            }
          },
          icon: const Icon(Icons.timer),
          label: Text(AppLocalizations.of(context)!.addTimer),
        ),
      ],
    );
  }

  /// =======================
  /// LINE ITEMS
  /// =======================
  List<Widget> _buildLineItems() {
    return List.generate(controller.lineItems.length, (index) {
      return _lineItem(index);
    });
  }

  Widget _lineItem(int index) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.lineItem} - ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (controller.lineItems.length > 1 &&
                    controller.sheetEnable.value)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => controller.lineItems.removeAt(index));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            /// PROJECT & BOARD
            controller.buildConfigurableField(
              fieldName: 'Project Id',
              builder: (isEnabled, isMandatory) {
                return SearchableMultiColumnDropdownField<Project>(
                  labelText:
                      '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""} ',
                  enabled: controller.sheetEnable.value,
                  columnHeaders: [
                    AppLocalizations.of(context)!.projectName,
                    AppLocalizations.of(context)!.projectId,
                  ],
                  items: controller.project,

                  selectedValue: controller.lineItems[index].project,
                  validator: (value) {
                    if (value == null && isMandatory) {
                      return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
                    }
                    return null;
                  },
                  searchValue: (proj) => '${proj.name} ${proj.code}',
                  displayText: (proj) => proj.code,
                  onChanged: (proj) {
                    setState(() {
                      controller.lineItems[index].project = proj;
                    });
                  },
                  rowBuilder: (proj, searchQuery) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Expanded(child: Text(proj.name)),
                          Expanded(child: Text(proj.code)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 13),

            // Expanded(
            //   child: SearchableMultiColumnDropdownField<Project>(
            //     labelText: '${AppLocalizations.of(context)!.projectId} *',
            //     columnHeaders: [
            //       AppLocalizations.of(context)!.projectName,
            //       AppLocalizations.of(context)!.projectId,
            //     ],
            //     items: controller.project,
            //     dropdownWidth: 300,
            //     enabled: controller.sheetEnable.value,

            //     selectedValue: controller.lineItems[index].project,
            //     validator: (value) {
            //       if (value == null) {
            //         return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
            //       }
            //       return null;
            //     },
            //     searchValue: (proj) => '${proj.name} ${proj.code}',
            //     displayText: (proj) => proj.code,
            //     onChanged: (proj) {
            //       setState(() {
            //         controller.lineItems[index].project = proj;
            //       });
            //     },
            //     rowBuilder: (proj, searchQuery) {
            //       return Padding(
            //         padding: const EdgeInsets.symmetric(
            //           vertical: 12,
            //           horizontal: 16,
            //         ),
            //         child: Row(
            //           children: [
            //             Expanded(child: Text(proj.name)),
            //             Expanded(child: Text(proj.code)),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
            SearchableMultiColumnDropdownField<BoardModel>(
              labelText: '${AppLocalizations.of(context)!.boardName} *',
              columnHeaders: [
                AppLocalizations.of(context)!.id,
                AppLocalizations.of(context)!.name,
              ],
              items: controller.boardList,
              enabled: controller.sheetEnable.value,

              selectedValue: controller.lineItems[index].board,
              // dropdownWidth: 300,
              // alignLeft: -150,
              displayText: (b) => b.boardId,
              searchValue: (b) => '${b.boardId} ${b.boardName}',
              rowBuilder: (b, _) => Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(child: Text(b.boardId)),
                  Expanded(child: Text(b.boardName)),
                ],
              ),
              onChanged: (b) {
                setState(() {
                  controller.lineItems[index].board = b;

                  controller.lineItems[index].task = null;
                });

                if (b != null) {
                  controller.filterTasksByBoardLineItem(b.boardId, index);
                }
              },
            ),

            const SizedBox(height: 12),

            /// TASK & TASK NAME
            Row(
              children: [
                Expanded(
                  child: SearchableMultiColumnDropdownField<TaskModelDropDown>(
                    labelText: '${AppLocalizations.of(context)!.taskName} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.id,
                      AppLocalizations.of(context)!.name,
                    ],
                    items: controller.lineItems[index].filteredTasks,
                    enabled: controller.sheetEnable.value,

                    // dropdownWidth: 300,
                    selectedValue: controller.lineItems[index].task,
                    displayText: (t) => t.taskId,
                    searchValue: (t) => '${t.taskId} ${t.taskName}',
                    rowBuilder: (t, _) => Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(child: Text(t.taskId)),
                        Expanded(child: Text(t.taskName)),
                      ],
                    ),
                    onChanged: (t) {
                      setState(() {
                        controller.lineItems[index].task = t;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// HOURS SCROLLER
            _hourScroller(index),
          ],
        ),
      ),
    );
  }

  Widget _lineCustomFields(int lineIndex) {
    return Obx(() {
      final lineFields = controller.lineCustomFields[lineIndex] ?? [];
      print("lineFieldsss$lineFields");
      if (lineFields.isEmpty) {
        return const SizedBox.shrink();
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: lineFields.map((field) {
            final fieldName = field['FieldName'] as String? ?? 'Unnamed Field';
            final fieldType = (field['FieldType'] as String? ?? 'text')
                .toLowerCase();
            final fieldValue = field['FieldValue'];
            final isVisible = field['IsVisible'] as bool? ?? true;
            final options = field['Options'] as List<String>? ?? [];

            // Skip if not visible
            if (!isVisible) return const SizedBox.shrink();

            // Format value based on field type
            String displayValue = _formatFieldValue(
              fieldValue,
              fieldType,
              options,
            );

            return Container(
              width: 190,
              height: 200,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade500, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Field Name
                  Text(
                    fieldName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Field Value with type-specific styling
                  GestureDetector(
                    onTap: controller.sheetEnable.value
                        ? () => _openLineCustomFieldPopup(
                            context,
                            lineIndex,
                            field,
                          )
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              fieldValue == null ||
                                  fieldValue.toString().isEmpty
                              ? Colors.grey.shade300
                              : Colors.blue.shade100,
                          width: 1,
                        ),
                      ),
                      child: _buildFieldValueDisplay(
                        displayValue,
                        fieldType,
                        fieldValue,
                      ),
                    ),
                  ),

                  // Field type indicator
                  // const SizedBox(height: 4),
                  // Text(
                  //   _getFieldTypeLabel(fieldType),
                  //   style: TextStyle(
                  //     fontSize: 9,
                  //     color: Colors.grey.shade600,
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  // ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // Helper method to format field value based on type
  String _formatFieldValue(
    dynamic value,
    String fieldType,
    List<String> options,
  ) {
    if (value == null || value.toString().isEmpty) {
      return '';
    }

    switch (fieldType) {
      case 'date':
        try {
          // Assuming timestamp in milliseconds
          final timestamp = int.tryParse(value.toString());
          if (timestamp != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              timestamp,
              isUtc: true,
            );
            return DateFormat('dd-MM-yyyy').format(date);
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
        return value.toString();

      case 'datetime':
      case 'timestamp':
        try {
          final timestamp = int.tryParse(value.toString());
          if (timestamp != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              timestamp,
              isUtc: true,
            );
            return DateFormat('dd-MM-yyyy HH:mm').format(date);
          }
        } catch (e) {
          print('Error parsing datetime: $e');
        }
        return value.toString();

      case 'boolean':
      case 'checkbox':
        final strValue = value.toString().toLowerCase();
        if (strValue == 'true' || strValue == '1' || strValue == 'yes') {
          return 'Yes';
        } else if (strValue == 'false' || strValue == '0' || strValue == 'no') {
          return 'No';
        }
        return value.toString();

      case 'dropdown':
      case 'select':
      case 'option':
        // Try to find matching option
        if (options.isNotEmpty) {
          final selected = options.firstWhere(
            (option) => option.toString() == value.toString(),
            orElse: () => value.toString(),
          );
          return selected;
        }
        return value.toString();

      case 'number':
      case 'integer':
      case 'decimal':
        try {
          // Format with commas for thousands
          final number = double.tryParse(value.toString());
          if (number != null) {
            return NumberFormat('#,##0.##').format(number);
          }
        } catch (e) {
          print('Error formatting number: $e');
        }
        return value.toString();

      case 'currency':
      case 'money':
        try {
          final number = double.tryParse(value.toString());
          if (number != null) {
            return NumberFormat.currency(
              symbol: '₹',
              decimalDigits: 2,
            ).format(number);
          }
        } catch (e) {
          print('Error formatting currency: $e');
        }
        return value.toString();

      case 'percentage':
        try {
          final number = double.tryParse(value.toString());
          if (number != null) {
            return '${number.toStringAsFixed(2)}%';
          }
        } catch (e) {
          print('Error formatting percentage: $e');
        }
        return value.toString();

      case 'email':
        return value.toString();

      case 'phone':
      case 'telephone':
        // Format phone number if possible
        final phone = value.toString().replaceAll(RegExp(r'[^\d+]'), '');
        if (phone.length >= 10) {
          return '+91 ${phone.substring(phone.length - 10, phone.length - 5)} ${phone.substring(phone.length - 5)}';
        }
        return value.toString();

      case 'url':
      case 'link':
        return value.toString();

      case 'multiline':
      case 'textarea':
        final text = value.toString();
        if (text.length > 20) {
          return '${text.substring(0, 20)}...';
        }
        return text;

      case 'text':
      default:
        return value.toString();
    }
  }

  // Widget to build field value display with appropriate styling
  Widget _buildFieldValueDisplay(
    String displayValue,
    String fieldType,
    dynamic originalValue,
  ) {
    final isEmpty = displayValue.isEmpty;

    if (isEmpty) {
      return Text(
        'Click to set value',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    switch (fieldType) {
      case 'date':
      case 'datetime':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
          ),
        );

      case 'boolean':
      case 'checkbox':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              displayValue.toLowerCase() == 'yes'
                  ? Icons.check_circle
                  : Icons.cancel,
              color: displayValue.toLowerCase() == 'yes'
                  ? Colors.green
                  : Colors.red,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: displayValue.toLowerCase() == 'yes'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        );

      case 'dropdown':
      case 'select':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.purple,
          ),
        );

      case 'number':
      case 'integer':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.green,
            fontFamily: 'Monospace',
          ),
        );

      case 'currency':
      case 'money':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.green,
            fontFamily: 'Monospace',
          ),
        );

      case 'percentage':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.orange,
            fontFamily: 'Monospace',
          ),
        );

      case 'email':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        );

      case 'url':
      case 'link':
        return Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        );

      case 'multiline':
      case 'textarea':
        return Row(
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: const TextStyle(fontSize: 11, color: Colors.brown),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (originalValue != null && originalValue.toString().length > 20)
              Icon(Icons.more_horiz, size: 14, color: Colors.grey.shade600),
          ],
        );

      default:
        return Text(
          displayValue,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  // Helper to get field type label
  String _getFieldTypeLabel(String fieldType) {
    switch (fieldType) {
      case 'date':
        return 'Date';
      case 'datetime':
        return 'Date & Time';
      case 'timestamp':
        return 'Timestamp';
      case 'boolean':
        return 'Yes/No';
      case 'checkbox':
        return 'Checkbox';
      case 'dropdown':
        return 'Dropdown';
      case 'select':
        return 'Select';
      case 'option':
        return 'Options';
      case 'number':
        return 'Number';
      case 'integer':
        return 'Integer';
      case 'decimal':
        return 'Decimal';
      case 'currency':
        return 'Currency';
      case 'money':
        return 'Money';
      case 'percentage':
        return 'Percentage';
      case 'email':
        return 'Email';
      case 'phone':
        return 'Phone';
      case 'telephone':
        return 'Telephone';
      case 'url':
        return 'URL';
      case 'link':
        return 'Link';
      case 'multiline':
        return 'Text Area';
      case 'textarea':
        return 'Long Text';
      case 'text':
        return 'Text';
      default:
        return fieldType;
    }
  }

  void _openLineCustomFieldPopup(
    BuildContext context,
    int lineIndex,
    Map<String, dynamic> field,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LineCustomFieldSheet(lineIndex: lineIndex, field: field),
    );
  }

  /// =======================
  /// HOUR SCROLLER
  /// =======================
  Widget _hourScroller(int index) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 90,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final dates = controller.timeSheetRange;

      return SizedBox(
        height: 120, // extra space for custom fields
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HOURS
              Row(
                children: List.generate(dates.length, (i) {
                  return _HourItem(lineIndex: index, item: dates[i]);
                }),
              ),

              const SizedBox(width: 12),

              /// LINE CUSTOM FIELDS (scrolls together)
              _lineCustomFields(index),
            ],
          ),
        ),
      );
    });
  }

  /// =======================
  /// COMPREHENSIVE BOTTOM BUTTONS
  /// =======================
  Widget _buildBottomButtons(BuildContext context) {
    // For new timesheet creation
    if (!widget.status) {
      return _buildNewTimeSheetButtons(context);
    }

    // For existing timesheet (view/edit mode)
    return _buildExistingTimeSheetButtons(context);
  }

  /// New timesheet creation buttons
  Widget _buildNewTimeSheetButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// 🔹 SUBMIT BUTTON
          Obx(() {
            final isSubmitLoading = controller.buttonLoaders['submit'] ?? false;
            final isAnyLoading = controller.buttonLoaders.values.any(
              (loading) => loading,
            );

            return CustomLoaderButton(
              text: AppLocalizations.of(context)!.submit,
              isLoading: isSubmitLoading,
              disabled: isAnyLoading,
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadius.circular(30),
              backgroundColor: const Color.fromARGB(255, 29, 1, 128),
              onPressed: () async {
                if (!_validateForm()) {
                  Fluttertoast.showToast(
                    msg:
                        "Required fields are missing. Please fill all mandatory fields.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: const Color.fromARGB(255, 250, 1, 1),
                    textColor: const Color.fromARGB(255, 253, 252, 253),
                    fontSize: 16.0,
                  );
                  return;
                }

                controller.setButtonLoading('submit', true);
                await _submitTimeSheet(context, false);
                controller.setButtonLoading('submit', false);
              },
            );
          }),

          const SizedBox(height: 12),

          /// 🔹 SAVE & CANCEL BUTTONS
          Row(
            children: [
              /// SAVE BUTTON
              Obx(() {
                final isSaveLoading = controller.buttonLoaders['save'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: CustomLoaderButton(
                    text: AppLocalizations.of(context)!.save,
                    isLoading: isSaveLoading,
                    disabled: isAnyLoading,
                    backgroundColor: const Color(0xFF1E7503),
                    onPressed: () async {
                      if (!_validateForm()) {
                        Fluttertoast.showToast(
                          msg:
                              "Required fields are missing. Please fill all mandatory fields.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
                          textColor: const Color.fromARGB(255, 253, 252, 253),
                          fontSize: 16.0,
                        );
                        return;
                      }

                      controller.setButtonLoading('save', true);
                      await _saveAsDraft(context);
                      controller.setButtonLoading('save', false);
                    },
                  ),
                );
              }),

              const SizedBox(width: 12),

              /// CANCEL BUTTON
              Expanded(
                child: CustomLoaderButton(
                  text: AppLocalizations.of(context)!.close,
                  isLoading: false,
                  disabled: false,
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    controller.clearTimeSheetForm();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Existing timesheet buttons based on status
  Widget _buildExistingTimeSheetButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// APPROVAL ACTION BUTTONS (For approvers)
          if (controller.stepType!.isNotEmpty) ...[
            _buildApprovalActionButtons(),
          ] else ...[
            /// USER ACTION BUTTONS
            if (controller.sheetEnable.value ||
                controller.stepType!.isEmpty &&
                    controller.statusApproval == "Pending" &&
                    !widget.team!) ...[
              _buildUserActionButtons(context),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => {
                        controller.clearTimeSheetForm(),
                        Navigator.of(context).pop(),
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ),
                ],
              ),
            ],
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildApprovalActionButtons() {
    // Add null checks
    if (controller.statusApproval == null) return const SizedBox.shrink();

    final stepType = controller.stepType;
    if (stepType == "Approval") {
      controller.leaveField.value = true;
    }
    if (stepType == "Review") {
      controller.sheetEnable.value = true;
    }
    if (stepType == null || stepType.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (stepType == "Review")
          Row(
            children: [
              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isUpdateAcceptLoading =
                    controller.buttonLoaders['update_accept'] ?? false;
                final isRejectLoading =
                    controller.buttonLoaders['reject'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: ElevatedButton(
                    onPressed: (isUpdateLoading || isAnyLoading)
                        ? null
                        : () {
                            controller.setButtonLoading('update', true);
                            controller
                                .submitTimeSheet(context, false)
                                .whenComplete(() {
                                  controller.setButtonLoading('update', false);
                                });
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isUpdateLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.update,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isUpdateAcceptLoading =
                    controller.buttonLoaders['update_accept'] ?? false;
                final isRejectLoading =
                    controller.buttonLoaders['reject'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: ElevatedButton(
                    onPressed: (isUpdateAcceptLoading || isAnyLoading)
                        ? null
                        : () {
                            controller.setButtonLoading('update_accept', true);
                            controller
                                .submitTimeSheet(context, true)
                                .whenComplete(() {
                                  controller.setButtonLoading(
                                    'update_accept',
                                    false,
                                  );
                                });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isUpdateAcceptLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.updateAndAccept,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),

        if (stepType == "Review") const SizedBox(height: 12),

        if (stepType == "Review")
          Row(
            children: [
              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isUpdateAcceptLoading =
                    controller.buttonLoaders['update_accept'] ?? false;
                final isRejectLoading =
                    controller.buttonLoaders['reject'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: ElevatedButton(
                    onPressed: (isRejectLoading || isAnyLoading)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading('reject', true);
                              showActionPopup(context, "Reject");
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                    ),
                    child: isRejectLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.reject,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.closeField();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ],
          ),

        if (stepType == "Approval")
          Row(
            children: [
              Obx(() {
                final isLoading = controller.buttonLoaders['approve'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            controller.setButtonLoading('approve', true);
                            showActionPopup(context, "Approve");
                            controller.setButtonLoading('approve', false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 30, 117, 3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.approvals,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              Obx(() {
                final isLoading =
                    controller.buttonLoaders['reject_approval'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            controller.setButtonLoading(
                              'reject_approval',
                              true,
                            );
                            showActionPopup(context, "Reject");
                            controller.setButtonLoading(
                              'reject_approval',
                              false,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.reject,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),
            ],
          ),

        if (stepType == "Approval")
          Row(
            children: [
              Obx(() {
                final isLoading = controller.buttonLoaders['escalate'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            controller.setButtonLoading('escalate', true);
                            showActionPopup(context, "Escalate");
                            controller.setButtonLoading('escalate', false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.escalate,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.chancelButton(context);
                    controller.closeField();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${AppLocalizations.of(context)!.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${AppLocalizations.of(context)!.user} *',
                          columnHeaders: [
                            AppLocalizations.of(context)!.userName,
                            AppLocalizations.of(context)!.userId,
                          ],
                          items: controller.userList,
                          selectedValue: controller.selectedUser.value,
                          searchValue: (user) =>
                              '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(user.userName)),
                                  Expanded(child: Text(user.userId)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.teal,
                            width: 2,
                          ),
                        ),
                        errorText: isCommentError
                            ? 'Comment is required.'
                            : null,
                      ),
                      onChanged: (value) {
                        if (isCommentError && value.trim().isNotEmpty) {
                          setState(() => isCommentError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.closeField();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();
                            if (status != "Approve" && comment.isEmpty) {
                              setState(() => isCommentError = true);
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) =>
                                  const Center(child: SkeletonLoaderPage()),
                            );

                            final success = await controller
                                .postApprovalActionLeavelSheet(
                                  context,
                                  workitemrecid: [controller.workitemrecid!],
                                  decision: status,
                                  comment: commentController.text,
                                );

                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              controller.setButtonLoading('reject', false);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.timeSheetPendingDashboard,
                              );
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit action'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// User action buttons based on timesheet status
  Widget _buildUserActionButtons(BuildContext context) {
    return Column(
      children: [
        if (controller.statusApproval == "Rejected" &&
            controller.sheetEnable.value)
          Obx(() {
            final isResubmitLoading =
                controller.buttonLoaders['resubmit'] ?? false;
            final isAnyLoading = controller.buttonLoaders.values.any(
              (loading) => loading,
            );
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 29, 1, 128),
                ),
                onPressed: isResubmitLoading || isAnyLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          controller.setButtonLoading('resubmit', true);

                          try {
                            await _submitTimeSheet(context, true);
                          } finally {
                            controller.setButtonLoading('resubmit', false);
                          }
                        }
                      },
                child: isResubmitLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.resubmit,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          }),

        /// RESUBMIT BUTTON for Rejected status
        if (controller.statusApproval == "Rejected" &&
            controller.sheetEnable.value)
          Row(
            children: [
              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdateLoading || isAnyLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading('update', true);

                              try {
                                await _saveAsDraft(context);
                              } finally {
                                controller.setButtonLoading('update', false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E7503),
                    ),
                    child: isUpdateLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.update,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.clearTimeSheetForm();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
            ],
          ),

        /// SUBMIT & SAVE BUTTONS for Created status
        if (controller.statusApproval == "Created" &&
            controller.sheetEnable.value)
          Column(
            children: [
              /// SUBMIT BUTTON
              /// 🔹 SUBMIT BUTTON
              Obx(() {
                final isSubmitLoading =
                    controller.buttonLoaders['submit'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color.fromARGB(255, 29, 1, 128),
                    ),
                    onPressed: (isSubmitLoading || isAnyLoading)
                        ? null
                        : () async {
                            if (!_validateForm()) {
                              Fluttertoast.showToast(
                                msg:
                                    "Required fields are missing. Please fill all mandatory fields.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  250,
                                  1,
                                  1,
                                ),
                                textColor: const Color.fromARGB(
                                  255,
                                  253,
                                  252,
                                  253,
                                ),
                                fontSize: 16.0,
                              );
                              return;
                            }

                            controller.setButtonLoading('submit', true);
                            await _submitTimeSheet(context, false);
                            controller.setButtonLoading('submit', false);
                          },
                    child: isSubmitLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.submit,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              /// 🔹 SAVE & CANCEL BUTTONS
              Row(
                children: [
                  /// SAVE BUTTON
                  Obx(() {
                    final isSaveLoading =
                        controller.buttonLoaders['save'] ?? false;

                    final isAnyLoading = controller.buttonLoaders.values.any(
                      (loading) => loading,
                    );

                    return Expanded(
                      child: ElevatedButton(
                        onPressed: (isSaveLoading || isAnyLoading)
                            ? null
                            : () async {
                                if (!_validateForm()) {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Required fields are missing. Please fill all mandatory fields.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      250,
                                      1,
                                      1,
                                    ),
                                    textColor: const Color.fromARGB(
                                      255,
                                      253,
                                      252,
                                      253,
                                    ),
                                    fontSize: 16.0,
                                  );
                                  return;
                                }

                                controller.setButtonLoading('save', true);
                                await _saveAsDraft(context);
                                controller.setButtonLoading('save', false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E7503),
                        ),
                        child: isSaveLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.save,
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    );
                  }),

                  const SizedBox(width: 12),

                  /// CANCEL BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.clearTimeSheetForm();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                ],
              ),
            ],
          ),

        /// CANCEL & CLOSE BUTTONS for Approval status
        if (controller.statusApproval == "Pending")
          Row(
            children: [
              Obx(() {
                final isLoading =
                    controller.buttonLoaders['cancelSheet'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              controller.setButtonLoading('cancelSheet', true);
                              await _cancelTimeSheet();
                            } finally {
                              controller.setButtonLoading('cancelSheet', false);
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE99797),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.red),
                          ),
                  ),
                );
              }),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => {
                    controller.clearTimeSheetForm(),
                    Navigator.of(context).pop(),
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),

        /// CLOSE BUTTON for Approved status
        if (controller.statusApproval == "Approved" &&
            controller.sheetEnable.value)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => {
                    controller.clearTimeSheetForm(),
                    Navigator.of(context).pop(),
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Action popup for reject/approve actions
  void _showActionPopup(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Timesheet'),
        content: const Text('Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle the action here
              if (action == "Reject") {
                // Call reject API
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// Cancel confirmation dialog
  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Timesheet'),
        content: const Text('Are you sure you want to cancel this timesheet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// DATE PICKER
  /// =======================
  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _pickDateRange() async {
    DateTime today = DateTime.now();
    DateTime lastDate = DateTime(today.year, today.month, today.day);

    final weekStart = controller.ruleConfig?.dayWeekStarts ?? "";
    final monthStart = controller.ruleConfig?.dayMonthStarts ?? "";
    final frequency = controller.ruleConfig?.entryFrequency ?? "";

    /// ✅ Default fallback
    controller.dateRange ??= DateTimeRange(
      start: lastDate.subtract(const Duration(days: 6)),
      end: lastDate,
    );

    DateTime start = _onlyDate(controller.dateRange!.start);
    DateTime now = DateTime.now();

    /// 🔥 ALIGN BEFORE PICKER (MAIN FIX)
    final alignedRange = _getDateRangeByPeriod(
      frequency,
      now,
      weekStart: weekStart,
      monthStart: monthStart,
    );

    DateTime safeStart = alignedRange.start;
    DateTime safeEnd = alignedRange.end;

    /// ❗ FIX: Prevent future crash
    if (safeEnd.isAfter(lastDate)) {
      safeEnd = lastDate;
    }

    /// ❗ EXTRA SAFETY
    if (safeStart.isAfter(safeEnd)) {
      safeStart = safeEnd;
    }

    DateTimeRange safeRange = DateTimeRange(
      start: _onlyDate(safeStart),
      end: _onlyDate(safeEnd),
    );

    /// 📅 OPEN PICKER — replaces showDateRangePicker
    final result = await showPeriodPicker(
      context: context,
      periodType: controller
          .periodType
          .value, // "Week" / "Biweekly" / "Month" / "SemiMonth"
      weekStart: weekStart,
      monthStart: monthStart,
      initialDate: controller.dateRange!.start,
      firstDate: DateTime(2024),
      lastDate: lastDate,
      getRangeFromConfig: _getDateRangeByPeriod,
    );

    if (result != null) {
      // result is already a fully aligned DateTimeRange — no need to re-align
      setState(() {
        controller.dateRange = result;
      });
      controller.fetchTasksTimeSheet(
        fromDate: controller.getStartOfDayMillis(result.start),
        toDate: controller.getEndOfDayMillis(result.end),
      );
      controller.loadTimeSheetRange(
        fromDate: controller.getStartOfDayMillis(result.start),
        toDate: controller.getEndOfDayMillis(result.end),
      );
    }
  }

  DateTime getStartOfWeek(DateTime date, String weekStart) {
    final startWeekday = getWeekdayFromString(weekStart);
    print("Start Weekday: $startWeekday");
    int diff = date.weekday - startWeekday;
    if (diff < 0) diff += 7;

    return DateTime(date.year, date.month, date.day - diff);
  }

  DateTime getEndOfWeek(DateTime start) {
    return DateTime(start.year, start.month, start.day + 6);
  }

  DateTimeRange _getDateRangeByPeriod(
  String type,
  DateTime date, {
  String weekStart = "",
  String monthStart = "",
}) {
  date = DateTime(date.year, date.month, date.day);
  type = type.replaceAll("-", "").toLowerCase();

  print("type: $type, weekStart: $weekStart, monthStart: $monthStart");

  int getWeekdayFromString(String day) {
    const map = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7,
    };
    return map[day.toLowerCase()] ?? 1;
  }

  int extractDay(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '').trim();
    return int.tryParse(digits) ?? 0;
  }

  int getSafeDay(int year, int month, int day) {
    int lastDay = DateTime(year, month + 1, 0).day;
    return day.clamp(1, lastDay);
  }

  DateTime startDate;
  DateTime endDate;

  // ================= WEEK =================
  if (type == "week" || type == "weekly") {
    if (weekStart.trim().isEmpty) {
      /// ✅ No config: tapped date IS the start
      startDate = date;
    } else {
      int startWeekday = getWeekdayFromString(weekStart);
      int diff = date.weekday - startWeekday;
      if (diff < 0) diff += 7;
      startDate = date.subtract(Duration(days: diff));
    }
    endDate = startDate.add(const Duration(days: 6));
  }

  // ================= BIWEEKLY =================
  else if (type == "biweekly") {
    if (weekStart.trim().isEmpty) {
      /// ✅ No config: tapped date IS the start
      startDate = date;
    } else {
      int startWeekday = getWeekdayFromString(weekStart);
      int diff = date.weekday - startWeekday;
      if (diff < 0) diff += 7;
      DateTime currentWeekStart = date.subtract(Duration(days: diff));
      startDate = currentWeekStart.subtract(const Duration(days: 7));
    }
    endDate = startDate.add(const Duration(days: 13));
  }

  // ================= MONTHLY =================
  else if (type == "monthly") {
    if (monthStart.trim().isEmpty) {
      /// ✅ No config: tapped date IS the start, end = same day next month - 1
      startDate = date;
      endDate = DateTime(
        date.year,
        date.month + 1,
        getSafeDay(date.year, date.month + 1, date.day - 1),
      );
    } else {
      int startDay = extractDay(monthStart);

      if (startDay <= 0) {
        /// ✅ Fallback if extractDay fails
        startDate = date;
        endDate = DateTime(
          date.year,
          date.month + 1,
          getSafeDay(date.year, date.month + 1, date.day - 1),
        );
      } else if (date.day >= startDay) {
        startDate = DateTime(
          date.year,
          date.month,
          getSafeDay(date.year, date.month, startDay),
        );
        endDate = DateTime(
          date.year,
          date.month + 1,
          getSafeDay(date.year, date.month + 1, startDay - 1),
        );
      } else {
        startDate = DateTime(
          date.year,
          date.month - 1,
          getSafeDay(date.year, date.month - 1, startDay),
        );
        endDate = DateTime(
          date.year,
          date.month,
          getSafeDay(date.year, date.month, startDay - 1),
        );
      }
    }
  }

  // ================= SEMI-MONTHLY =================
  else if (type == "semimonth" || type == "semimonthly") {
    if (date.day <= 15) {
      startDate = DateTime(date.year, date.month, 1);
      endDate = DateTime(date.year, date.month, 15);
    } else {
      startDate = DateTime(date.year, date.month, 16);
      endDate = DateTime(date.year, date.month + 1, 0);
    }
    // ℹ️ SemiMonth has fixed halves — weekStart/monthStart don't apply
  }

  // ================= DEFAULT =================
  else {
    startDate = date;
    endDate = date;
  }

  return DateTimeRange(start: startDate, end: endDate);
}

  DateTimeRange getBiWeeklyRange() {
    final now = DateTime.now();

    /// Normalize today (remove time)
    final today = DateTime(now.year, now.month, now.day);

    /// Step 1: Find this week's Monday
    int diff = today.weekday - DateTime.monday;
    DateTime thisWeekMonday = today.subtract(Duration(days: diff));

    /// Step 2: Last week's Sunday (end of last completed week)
    DateTime lastWeekSunday = thisWeekMonday.subtract(const Duration(days: 1));

    /// Step 3: Start = 13 days before that (2 weeks total)
    DateTime startDate = lastWeekSunday.subtract(const Duration(days: 13));

    DateTime endDate = lastWeekSunday;

    print("BiWeekly Start: $startDate");
    print("BiWeekly End: $endDate");

    return DateTimeRange(start: startDate, end: endDate);
  }
}

/// =======================
/// APPEND EXISTING DATA METHOD
/// =======================

// Rest of your existing code remains the same...

class _HourItem extends StatelessWidget {
  final int lineIndex;
  final TimeSheetRangeModel item;

  const _HourItem({super.key, required this.lineIndex, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Controller());

    final entryKey = item.entryDate.millisecondsSinceEpoch;

    /// 📅 Today
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    /// 📅 Item date
    final itemDate = DateTime(
      item.entryDate.year,
      item.entryDate.month,
      item.entryDate.day,
    );

    /// 📊 Data
    final line = controller.lineItems[lineIndex];
    final entry = controller.timeEntries[lineIndex]?[entryKey];

    final isRunning = line.timerRunning.value;
    final seconds = line.elapsedSeconds.value;

    /// 🔥 LIMIT (null or 0 = unlimited)
    final int? limit = controller.limitpostdate;
    final bool noLimit = limit == null || limit == 0;

    /// 📊 DATE DIFFERENCE
    final difference = todayOnly.difference(itemDate).inDays;

    final isFuture = difference < 0;
    final isToday = difference == 0;

    /// 🔥 PAST RULE (ONLY past dates)
    final isAllowedPastDay = noLimit
        ? difference > 0
        : (difference > 0 && difference <= limit!);

    /// 🔥 TODAY RULE (always enabled unless blocked by holiday/weekend)
    final isTodayAllowed = true;

    /// ❌ FINAL DISABLE LOGIC
    final isDisabled =
        item.weekend ||
        item.holiday ||
        isFuture ||
        (!isTodayAllowed && isToday) ||
        (!isToday && !isAllowedPastDay);

    /// ▶️ TIMER BUTTON
    final showTimerButton = isToday && controller.sheetEnable.value;

    /// 🔍 DEBUG
    print("""
Date: ${item.entryDate}
difference: $difference
limit: $limit
noLimit: $noLimit
isFuture: $isFuture
isToday: $isToday
isAllowedPastDay: $isAllowedPastDay
isDisabled: $isDisabled
""");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : () => _openTimePopup(context),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDisabled
              ? Colors.grey.shade100
              : Theme.of(context).colorScheme.surface,
          border: Border.all(color: isDisabled ? Colors.grey : Colors.blue),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 📅 Day
            Text(
              DateFormat('EEE').format(item.entryDate),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            /// 📅 Date
            Text(
              DateFormat('dd MMM').format(item.entryDate),
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ⏱ Hours
                Text(
                  entry?.totalHours ?? '0',
                  style: const TextStyle(fontSize: 10),
                ),

                /// ▶️ Timer Button
                if (showTimerButton)
                  GestureDetector(
                    onTap: () {
                      if (isRunning) {
                        controller.stopTimer(lineIndex, item.entryDate);
                      } else {
                        controller.startTimer(lineIndex, item.entryDate);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.play_arrow,
                        size: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  void _openTimePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          TimeDetailsSheet(lineIndex: lineIndex, entryDate: item.entryDate),
    );
  }
}

class LineCustomFieldSheet extends StatefulWidget {
  final int lineIndex;
  final Map<String, dynamic> field;

  const LineCustomFieldSheet({
    super.key,
    required this.lineIndex,
    required this.field,
  });

  @override
  State<LineCustomFieldSheet> createState() => _LineCustomFieldSheetState();
}

class _LineCustomFieldSheetState extends State<LineCustomFieldSheet> {
  late TextEditingController _controller;
  final controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();

    final fieldType =
        widget.field['FieldType']?.toString().toLowerCase() ?? 'text';

    String value = widget.field['FieldValue']?.toString() ?? '';

    /// ✅ If date field and value exists → convert millis to formatted date
    if (fieldType == 'date') {
      try {
        int millis = int.parse(value);

        /// If API sends seconds (10 digits)
        if (millis.toString().length == 10) {
          millis *= 1000;
        }

        value = DateFormat(
          'dd-MM-yyyy',
        ).format(DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true));
      } catch (e) {
        print("Invalid date millis");
      }
    }

    _controller = TextEditingController(text: value);
  }

  @override
  Widget build(BuildContext context) {
    final fieldType =
        widget.field['FieldType']?.toString().toLowerCase() ?? 'text';
    final isMandatory = widget.field['IsMandatory'] ?? false;
    final label = '${widget.field['FieldName']}${isMandatory ? ' *' : ''}';
    // final initialDate = DateFormat('dd-MM-yyyy').parse(_controller.text);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.field['FieldName'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (fieldType == 'dropdown' || fieldType == 'select')
              DropdownButtonFormField<String>(
                value: _controller.text.isEmpty ? null : _controller.text,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
                items: (widget.field['Options'] as List<dynamic>?)
                    ?.map((option) => option.toString())
                    .map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _controller.text = value;
                  }
                },
              )
            else if (fieldType == 'date')
              TextFormField(
                controller: _controller,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime initialDate = DateTime.now();

                      if (_controller.text.isNotEmpty) {
                        try {
                          initialDate = DateFormat(
                            'dd-MM-yyyy',
                          ).parse(_controller.text);
                        } catch (_) {}
                      }

                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        _controller.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);
                      }
                    },
                  ),
                ),
              )
            else
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
                maxLines: fieldType == 'textarea' ? 3 : 1,
                keyboardType: fieldType == 'number'
                    ? TextInputType.number
                    : TextInputType.text,
              ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    String finalValue = _controller.text;

                    if (fieldType == 'date' && finalValue.isNotEmpty) {
                      try {
                        final parsedDate = DateFormat(
                          'dd-MM-yyyy',
                        ).parse(finalValue);

                        finalValue = parsedDate.millisecondsSinceEpoch
                            .toString();
                      } catch (_) {}
                    }

                    controller.updateCustomFieldValue(
                      widget.lineIndex,
                      widget.field['FieldId'],
                      finalValue,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimeDetailsSheet extends StatefulWidget {
  final int lineIndex;
  final DateTime entryDate;

  const TimeDetailsSheet({
    super.key,
    required this.lineIndex,
    required this.entryDate,
  });

  @override
  State<TimeDetailsSheet> createState() => _TimeDetailsSheetState();
}

class _TimeDetailsSheetState extends State<TimeDetailsSheet> {
  final controller = Get.put(Controller());

  final timeFromCtrl = TextEditingController();
  final timeToCtrl = TextEditingController();
  final totalHoursCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  final DateFormat timeFormat = DateFormat('hh:mm a');

  int? timeFromMillis;
  int? timeToMillis;

  bool isTimerBasedEntry = false;

  bool get isTimerCompleted =>
      controller.lineItems[widget.lineIndex].timerCompleted.value;

  @override
  void initState() {
    super.initState();

    final key = widget.entryDate.millisecondsSinceEpoch;
    final existing = controller.timeEntries[widget.lineIndex]?[key];
    if (existing != null) {
      // print("RecId: ${existing.recId}");
      print("EntryDate: ${existing.entryDate}");
      print("From: ${existing.timeFrom}");
      print("To: ${existing.timeTo}");
      print("Hours: ${existing.totalHours}");
      print("comment: ${existing.comment}");
    } else {
      print("No entry found");
    }
    if (existing != null) {
      totalHoursCtrl.text = existing.totalHours;
      commentCtrl.text = existing.comment ?? '';

      timeFromMillis = existing.timeFrom;
      timeToMillis = existing.timeTo;

      if (timeFromMillis != null) {
        timeFromCtrl.text = timeFormat.format(
          DateTime.fromMillisecondsSinceEpoch(timeFromMillis!, isUtc: true),
        );
      }

      if (timeToMillis != null) {
        timeToCtrl.text = timeFormat.format(
          DateTime.fromMillisecondsSinceEpoch(timeToMillis!, isUtc: true),
        );
      }
    }
  }

  Future<void> _pickTime(TextEditingController ctrl, bool isFrom) async {
    if (isTimerBasedEntry) return;

    int? existingMillis = isFrom ? timeFromMillis : timeToMillis;

    TimeOfDay initialTime;

    if (existingMillis != null) {
      final existingDateTime = DateTime.fromMillisecondsSinceEpoch(
        existingMillis,
        isUtc: true,
      );

      initialTime = TimeOfDay(
        hour: existingDateTime.hour,
        minute: existingDateTime.minute,
      );
    } else {
      initialTime = TimeOfDay.now();
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final date = widget.entryDate;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      picked.hour,
      picked.minute,
    );

    final selectedMillis = dateTime.millisecondsSinceEpoch;

    /// Validation
    if (!isFrom &&
        timeFromMillis != null &&
        selectedMillis <= timeFromMillis!) {
      Fluttertoast.showToast(
        msg: "Time To must be greater than Time From",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      ctrl.text = timeFormat.format(dateTime);

      if (isFrom) {
        timeFromMillis = selectedMillis;

        if (timeToMillis != null && timeToMillis! <= timeFromMillis!) {
          timeToMillis = null;
          timeToCtrl.clear();
        }
      } else {
        timeToMillis = selectedMillis;
      }
    });

    _calculateTotalHours();
  }

  void _calculateTotalHours() {
    if (timeFromMillis != null && timeToMillis != null) {
      final diff = DateTime.fromMillisecondsSinceEpoch(timeToMillis!)
          .difference(
            DateTime.fromMillisecondsSinceEpoch(timeFromMillis!, isUtc: true),
          );

      final hours = diff.inMinutes / 60;
      totalHoursCtrl.text = hours.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    timeFromCtrl.dispose();
    timeToCtrl.dispose();
    totalHoursCtrl.dispose();
    commentCtrl.dispose();
    super.dispose();
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
          Center(
            child: Text(
              AppLocalizations.of(context)!.timeDetails,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          /// Time From
          ///
          controller.buildConfigurableField(
            fieldName: "Startime-Endtime",
            builder: (isEnabled, isMandatory) {
              return Obx(
                () => TextField(
                  controller: timeFromCtrl,
                  readOnly: true,
                  enabled: controller.sheetEnable.value,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.startTime} *",
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () => _pickTime(timeFromCtrl, true),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          /// Time To
          controller.buildConfigurableField(
            fieldName: "Startime-Endtime",
            builder: (isEnabled, isMandatory) {
              return Obx(
                () => TextField(
                  controller: timeToCtrl,
                  readOnly: true,
                  enabled: controller.sheetEnable.value,
                  decoration: InputDecoration(
                    labelText: "${AppLocalizations.of(context)!.endTime} *",
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () => _pickTime(timeToCtrl, false),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          /// Total Hours
          TextField(
            controller: totalHoursCtrl,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            // readOnly: true,
            enabled: controller.sheetEnable.value,
            decoration: InputDecoration(
              labelText: "${AppLocalizations.of(context)!.totalHours} *",
            ),
          ),

          const SizedBox(height: 12),

          /// Comment
          Obx(
            () => TextField(
              controller: commentCtrl,
              enabled: controller.sheetEnable.value,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.comment,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.close),
              ),

              const SizedBox(width: 8),

              Obx(
                () => controller.sheetEnable.value
                    ? ElevatedButton(
                        onPressed: () {
                          final key = widget.entryDate.millisecondsSinceEpoch;

                          controller.updateEntry(
                            widget.lineIndex,
                            key,
                            TimeEntryModel(
                              entryDate: key,
                              timeFrom: timeFromMillis,
                              timeTo: timeToMillis,
                              totalHours: totalHoursCtrl.text,
                              comment: commentCtrl.text,
                              recId: controller
                                  .timeEntries[widget.lineIndex]?[key]
                                  ?.recId,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      )
                    : const SizedBox(),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TimeTrackerView extends StatefulWidget {
  const TimeTrackerView({super.key});

  @override
  State<TimeTrackerView> createState() => _TimeTrackerViewState();
}

class _TimeTrackerViewState extends State<TimeTrackerView> {
  final Controller controller = Get.put(Controller());
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    // Initialize date range
    final now = DateTime.now();

    // 1st day of current month
    final startDate = DateTime(now.year, now.month, 1);

    // 7th day of current month
    final endDate = DateTime(now.year, now.month, 7);

    controller.dateRange = DateTimeRange(start: startDate, end: endDate);

    // Fetch initial data
    controller.fetchEvents();
    controller.fetchTimeRuns();
    controller.fetchSegments();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check for active timer first
      await controller.checkActiveTimer();
      controller.Sheetconfiguration();
      // Then fetch other data
      controller.fetchProjectName();
      controller.fetchBoardDropDown();
      controller.fetchTasksTimeSheet(
        fromDate: controller.dateRange!.start.millisecondsSinceEpoch,
        toDate: controller.dateRange!.end.millisecondsSinceEpoch,
      );
    });
  }

  @override
  void dispose() {
    controller.clearTimeSheetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Active Timer Banner (if exists)
              Obx(() {
                if (controller.isCheckingActiveTimer.value) {
                  return const LinearProgressIndicator();
                }
                // if (controller.hasActiveTimer.value &&
                //     controller.activeTimerDetails.value != null) {
                //   return _activeTimerBanner();
                // }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),

              _formSection(context),
              const SizedBox(height: 20),
              _timerBox(),
              const SizedBox(height: 20),
              _tabs(),
              const SizedBox(height: 20),
              _generateButtons(),
              _tabContent(),
              const SizedBox(height: 20), // Extra padding at bottom
            ]),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Form Section
  Widget _formSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              controller.buildConfigurableField(
                fieldName: 'Project Id',
                builder: (isEnabled, isMandatory) {
                  return SearchableMultiColumnDropdownField<Project>(
                    labelText:
                        '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""} ',

                    columnHeaders: [
                      AppLocalizations.of(context)!.projectName,
                      AppLocalizations.of(context)!.projectId,
                    ],
                    items: controller.project,
                    // dropdownWidth: 300,
                    controller: controller.projectDropDowncontroller,
                    selectedValue: controller.selectedProject,
                    validator: (value) {
                      if (controller.projectDropDowncontroller.text.isEmpty &&
                          isMandatory) {
                        return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
                      }
                      return null;
                    },
                    searchValue: (proj) => '${proj.name} ${proj.code}',
                    displayText: (proj) => proj.code,
                    onChanged: (proj) {
                      controller.projectDropDowncontroller.text = proj!.code;
                      setState(() {
                        controller.selectedProject = proj;
                        controller.showProjectError.value = false;
                        controller.projectError.value = '';
                      });
                    },
                    rowBuilder: (proj, searchQuery) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Expanded(child: Text(proj.name)),
                            Expanded(child: Text(proj.code)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              Obx(
                () => controller.projectError.value.isNotEmpty
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            controller.projectError.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 12),

              SearchableMultiColumnDropdownField<BoardModel>(
                key: ValueKey('board_dropdown_${controller.boardList.length}'),
                labelText: '${AppLocalizations.of(context)!.boardName}*',
                columnHeaders: [
                  AppLocalizations.of(context)!.id,
                  AppLocalizations.of(context)!.name,
                ],
                items: controller.boardList,
                selectedValue: controller.selectedBoards,
                controller: controller.boardNameController,
                displayText: (b) => b.boardId,
                searchValue: (b) => '${b.boardId} ${b.boardName}',
                rowBuilder: (b, _) => Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(child: Text(b.boardId)),
                    Expanded(child: Text(b.boardName)),
                  ],
                ),
                onChanged: (b) {
                  controller.boardError.value = '';
                  controller.selectedBoards = b;
                  controller.boardNameController.text = b?.boardId ?? '';
                  if (b != null) {
                    controller.filterTasksByBoard(b.boardId);
                  }
                },
              ),
              Obx(
                () => controller.boardError.value.isNotEmpty
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            controller.boardError.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 12),

              SearchableMultiColumnDropdownField<TaskModelDropDown>(
                key: ValueKey('task_dropdown_${controller.taskList.length}'),
                labelText: '${AppLocalizations.of(context)!.taskName} *',
                columnHeaders: [
                  AppLocalizations.of(context)!.id,
                  AppLocalizations.of(context)!.name,
                ],
                items: controller.taskList,
                selectedValue: controller.selectedTask,
                controller: controller.taskIdController,
                displayText: (t) => t.taskId,
                searchValue: (t) => '${t.taskId} ${t.taskName}',
                rowBuilder: (t, _) => Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(child: Text(t.taskId)),
                    Expanded(child: Text(t.taskName)),
                  ],
                ),
                onChanged: (t) {
                  controller.selectedTask = t;
                  controller.taskNameController.text = t?.taskId ?? '';
                  controller.taskIdController.text = t?.taskId ?? '';
                  controller.taskError.value = '';
                },
              ),

              Obx(
                () => controller.taskError.value.isNotEmpty
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            controller.taskError.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('notes_field'),
                controller: controller.noteCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.enterNotes,
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _projectDropdown(BuildContext context) {
    return SearchableMultiColumnDropdownField<Project>(
      key: ValueKey('project_dropdown_${controller.project.length}'),
      labelText: '${AppLocalizations.of(context)!.projectId} *',
      columnHeaders: [
        AppLocalizations.of(context)!.projectName,
        AppLocalizations.of(context)!.projectId,
      ],
      items: controller.project,
      controller: controller.projectDropDowncontroller,
      selectedValue: controller.selectedProject,
      validator: (_) {
        if (controller.projectDropDowncontroller.text.isEmpty) {
          return AppLocalizations.of(context)!.pleaseSelectProject;
        }
        return null;
      },
      searchValue: (p) => '${p.name} ${p.code}',
      displayText: (p) => p.code,
      onChanged: (p) {
        controller.projectDropDowncontroller.text = p?.code ?? '';
        controller.selectedProject = p;
        controller.showProjectError.value = false;
      },
      rowBuilder: (p, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(p.name)),
            Expanded(child: Text(p.code)),
          ],
        ),
      ),
    );
  }

  /// Timer Box
  Widget _timerBox() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Obx(() {
              final s = controller.durationSeconds.value;
              final h = (s ~/ 3600).toString().padLeft(2, '0');
              final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
              final sec = (s % 60).toString().padLeft(2, '0');
              return Column(
                children: [
                  Text(
                    '$h:$m:$sec',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final status = controller.timerStatus.value;
                    return Text(
                      status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                        letterSpacing: 1,
                      ),
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 24),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return Colors.green;
      case TimerStatus.paused:
        return Colors.amber;
      case TimerStatus.completed:
        return Colors.blue;
      case TimerStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buttons() {
    return Obx(() {
      final status = controller.timerStatus.value;
      final hasActive = controller.hasActiveTimer.value;

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          // Start button - only show if no active timer
          if (!hasActive || status == TimerStatus.idle)
            _actionBtn(
              key: const ValueKey('start_button'),
              icon: Icons.play_arrow,
              label: AppLocalizations.of(context)!.start,
              color: Colors.green,
              enabled: true,
              onTap: () {
                if (controller.validateFields()) {
                  controller.startTimerTimeSheet();
                }
              },
            ),

          // Pause button - only for running timer
          if (hasActive && status == TimerStatus.running)
            _actionBtn(
              key: const ValueKey('pause_button'),
              icon: Icons.pause,
              label: AppLocalizations.of(context)!.pause,
              color: Colors.amber,
              enabled: true,
              onTap: controller.pauseTimer,
            ),

          // Resume button - only for paused timer
          if (hasActive && status == TimerStatus.paused)
            _actionBtn(
              key: const ValueKey('resume_button'),
              icon: Icons.play_circle_fill,
              label: AppLocalizations.of(context)!.resume,
              color: Colors.blue,
              enabled: true,
              onTap: controller.resumeTimer,
            ),

          // Complete button - for any active timer
          if (hasActive && status != TimerStatus.idle)
            _actionBtn(
              key: const ValueKey('complete_button'),
              icon: Icons.check_circle,
              label: AppLocalizations.of(context)!.complete,
              color: Colors.green,
              enabled: true,
              onTap: controller.completeTimer,
            ),

          // Cancel button - for any active timer
          if (hasActive && status != TimerStatus.idle)
            _actionBtn(
              key: const ValueKey('cancel_button'),
              icon: Icons.cancel,
              label: AppLocalizations.of(context)!.cancel,
              color: Colors.red,
              enabled: true,
              onTap: controller.cancelTimer,
            ),
        ],
      );
    });
  }

  Widget _actionBtn({
    required Key key,
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isLoading = controller.isActionLoading.value;

      return ElevatedButton(
        key: key,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: (!enabled || isLoading) ? null : onTap,
        child: SizedBox(
          height: 24,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
        ),
      );
    });
  }

  /// Tabs
  Widget _tabs() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,

          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: TrackerTab.values.map((tab) {
            final selected = controller.selectedTab.value == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTabTimeSheet(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? Colors.lightBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tab.name.capitalizeFirst!,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: selected
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// Generate Buttons
  Widget _generateButtons() {
    return Obx(() {
      if (controller.selectedTab.value != TrackerTab.runs) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Generate Time Sheet
            Expanded(
              child: ElevatedButton(
                key: const ValueKey('generate_button'),
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.generateTimeSheet(submit: false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green.shade500,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.generateTimeSheet,
                        textAlign: TextAlign.center,
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // Generate & Submit Time Sheet
            Expanded(
              child: ElevatedButton(
                key: const ValueKey('generate_submit_button'),
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.generateTimeSheet(submit: true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.generateAndSubmit,
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Tab Content
  Widget _tabContent() {
    return Obx(() {
      if (controller.isTabLoading.value) {
        return const SizedBox(height: 400, child: SkeletonLoaderPage());
      }

      switch (controller.selectedTab.value) {
        case TrackerTab.runs:
          return _runsList(controller.timeRuns);
        case TrackerTab.segments:
          return _segmentsList(controller.segments);
        case TrackerTab.events:
          return _eventsList(controller.eventss);
      }
    });
  }

  Widget _runsList(List data) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.timer_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noTimeRunsFound,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, i) {
        final item = data[i];
        final id = item['TimeRunId'].toString();
        final isActive =
            controller.hasActiveTimer.value &&
            controller.activeTimerDetails.value?['TimeRunId'] == id;

        return Obx(() {
          final isSelected = controller.isSelectedTimeRun(id);

          return Dismissible(
            key: ValueKey('run_$id'),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart ||
                  direction == DismissDirection.startToEnd) {
                _openRunDetailsBottomSheet(item);
              }
              return false;
            },
            background: _swipeBg(Icons.arrow_forward, Alignment.centerLeft),
            secondaryBackground: _swipeBg(
              Icons.arrow_back,
              Alignment.centerRight,
            ),
            child: GestureDetector(
              onLongPress: () => controller.toggleSelectionTimeRUN(id),
              onTap: () {
                if (controller.selectedRunIds.isNotEmpty) {
                  controller.toggleSelectionTimeRUN(id);
                } else {
                  _openRunDetailsBottomSheet(item);
                }
              },
              child: Card(
                color: isSelected
                    ? Colors.blue.shade50
                    : isActive
                    ? Colors.green.shade50
                    : null,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isActive ? Colors.green : Colors.transparent,
                    width: isActive ? 2 : 0,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['TaskName'] ?? 'Unnamed Task',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${AppLocalizations.of(context)!.employeeId}: ${item['EmployeeId']}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${AppLocalizations.of(context)!.timeRunId}: ${item['TimeRunId']}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${AppLocalizations.of(context)!.duration}: ${item['TotalHours'] ?? '--'} hours",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.formatUtcMillis(
                                  item['StartedAtUtc'],
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item['Status'] == 'Completed'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['Status'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: item['Status'] == 'Completed'
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (controller.selectedRunIds.isNotEmpty)
                      Positioned(
                        top: 12,
                        right: 8,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) =>
                              controller.toggleSelectionTimeRUN(id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _segmentsList(List data) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.list_alt, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noDataFound,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (ctx, idx) {
        final item = data[idx];
        final segmentId = item['TimeRunSegmentId'] ?? idx.toString();

        return Dismissible(
          key: ValueKey('segment_$segmentId'),
          background: _buildSwipeActionLeft(),

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              _openSegmentsDetailsBottomSheet(item);
              return false;
            }
            return false;
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.segment}: ${item['TimeRunSegmentId'] ?? '--'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${item['Duration'] ?? '0'} hrs',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue.shade50,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.timeRunId}: ${item['TimeRunId']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context)!.segment}: ${item['SegmentSeq']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.start}: ${_formatDate(item['StartAtUtc'])}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.end}: ${_formatDate(item['EndAtUtc'])}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _eventsList(List data) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.event_note, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noEventsFound,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (ctx, idx) {
        final item = data[idx];
        final eventId = item['TimeRunEventId'] ?? idx.toString();

        return Dismissible(
          key: ValueKey('event_$eventId'),
          background: _buildSwipeActionLeft(),
          secondaryBackground: _buildSwipeActionLeft(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              _openEventDetailsBottomSheet(item);
              return false;
            }
            return false;
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.event}: ${item['TimeRunEventId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventColor(item['EventType']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['EventType'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.timeRunId}: ${item['TimeRunId']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.occurred}: ${_formatDate(item['OccurredAtUtc'])}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getEventColor(String? eventType) {
    switch (eventType?.toLowerCase()) {
      case 'start':
        return Colors.green;
      case 'pause':
        return Colors.amber;
      case 'resume':
        return Colors.blue;
      case 'stop':
        return Colors.red;
      case 'cancel':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  String _formatDate(dynamic millis) {
    if (millis == null) return '--';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(millis.toString()) ?? 0,
        isUtc: true,
      ).toLocal();
      return DateFormat('dd/MM/yy HH:mm').format(date);
    } catch (_) {
      return '--';
    }
  }

  /// Bottom Sheets
  void _openRunDetailsBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _sheetHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _detailField(
                              AppLocalizations.of(context)!.timeRunId,
                              item['TimeRunId'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.taskName,
                              "${item['TaskName']} (${item['TaskId']})",
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.projectId,
                              item['ProjectId'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.board,
                              item['BoardId'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.status,
                              item['Status'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.duration,
                              "${item['TotalHours'] ?? '--'} hours",
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.started,
                              _formatDate(item['StartedAtUtc']),
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.ended,
                              _formatDate(item['EndedAtUtc']),
                            ),
                            if (item['Notes'] != null &&
                                item['Notes'].isNotEmpty)
                              _detailField("Notes", item['Notes']),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openSegmentsDetailsBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SegmentEditBottomSheet(item: item, controller: controller);
      },
    );
  }

  void _openEventDetailsBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _sheetHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _detailField(
                              AppLocalizations.of(context)!.event,
                              item['TimeRunEventId'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.timeRunId,
                              item['TimeRunId'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.eventType,
                              item['EventType'],
                            ),
                            _detailField(
                              AppLocalizations.of(context)!.occurred,
                              _formatDate(item['OccurredAtUtc']),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(value ?? '--', style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _sheetHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.details,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _swipeBg(IconData icon, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.blue.shade100,
      child: Icon(icon, color: Colors.blue, size: 24),
    );
  }

  Widget _buildSwipeActionLeft() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility, color: Colors.white),
          SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.viewDetails,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Separate widget for segment edit bottom sheet to isolate state
class SegmentEditBottomSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final Controller controller;

  const SegmentEditBottomSheet({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<SegmentEditBottomSheet> createState() => _SegmentEditBottomSheetState();
}

class _SegmentEditBottomSheetState extends State<SegmentEditBottomSheet> {
  late final GlobalKey<FormState> _formKey;
  late Map<String, dynamic> _initialItem;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _initialItem = Map.from(widget.item);
    _prepareControllers();
  }

  void _prepareControllers() {
    widget.controller.boardNameController.text = _initialItem['BoardId'] ?? '';
    widget.controller.taskNameController.text = _initialItem['TaskName'] ?? '';
    widget.controller.taskIdController.text = _initialItem['TaskId'] ?? '';
    widget.controller.projectDropDowncontroller.text =
        _initialItem['ProjectId'] ?? '';
    widget.controller.noteCtrl.text = _initialItem['Notes'] ?? '';

    // Set selected values
    final project = widget.controller.project.firstWhereOrNull(
      (p) => p.code == _initialItem['ProjectId'],
    );
    if (project != null) {
      widget.controller.selectedProject = project;
    }

    final board = widget.controller.boardList.firstWhereOrNull(
      (b) => b.boardId == _initialItem['BoardId'],
    );
    if (board != null) {
      widget.controller.selectedBoards = board;
    }

    final task = widget.controller.taskList.firstWhereOrNull(
      (t) => t.taskId == _initialItem['TaskId'],
    );
    if (task != null) {
      widget.controller.selectedTask = task;
    }
  }

  String _formatDate(dynamic millis) {
    if (millis == null) return '--';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(millis.toString()) ?? 0,
        isUtc: true,
      ).toLocal();
      return DateFormat('dd-MM-yyyy, hh:mm a').format(date);
    } catch (_) {
      return '--';
    }
  }

  Future<void> _saveSegment() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    final payload = {
      "TimeRunId": _initialItem['TimeRunId'],
      "TimeRunSegmentId": _initialItem['TimeRunSegmentId'],
      "ProjectId": widget.controller.projectDropDowncontroller.text,
      "BoardId": widget.controller.boardNameController.text,
      "TaskId": widget.controller.taskIdController.text,
      "TaskName": widget.controller.taskNameController.text,
      "Notes": widget.controller.noteCtrl.text,
      "RecId": _initialItem['RecId'],
    };

    try {
      final res = await ApiService.put(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/timesegmentupdate'
          '?RecId=${_initialItem['RecId']}'
          '&screen_name=TSRTimeRunSegment',
        ),
        body: jsonEncode(payload),
      );

      if (res.statusCode == 280) {
        final responseData = jsonDecode(res.body);
        final message =
            responseData['detail']['message'] ?? 'Updated successfully';

        // Update the data
        widget.controller.fetchSegments();

        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );

        // Close bottom sheet
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          setState(() => _isSaving = false);
          Get.snackbar(
            "Error",
            "Failed: ${res.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Get.snackbar(
          "Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void dispose() {
    // Don't clear controllers here as they're shared with parent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return AnimatedPadding(
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sheetHeader(),
                      const SizedBox(height: 16),

                      _disabledField(
                        label: AppLocalizations.of(context)!.segmentId,
                        value: _initialItem['TimeRunSegmentId'],
                      ),
                      _disabledField(
                        label: AppLocalizations.of(context)!.timeRunId,
                        value: _initialItem['TimeRunId'],
                      ),
                      _disabledField(
                        label: AppLocalizations.of(context)!.segmentSequence,
                        value: _initialItem['SegmentSeq'].toString(),
                      ),
                      widget.controller.buildConfigurableField(
                        fieldName: "Startime-Endtime",
                        builder: (isEnabled, isMandatory) {
                          return _disabledField(
                            label:
                                "${AppLocalizations.of(context)!.startTime}  ${isMandatory ? "*" : ""}",
                            value: _formatDate(_initialItem['StartAtUtc']),
                            icon: Icons.calendar_today_outlined,
                          );
                        },
                      ),
                      widget.controller.buildConfigurableField(
                        fieldName: "Startime-Endtime",
                        builder: (isEnabled, isMandatory) {
                          return _disabledField(
                            label:
                                "${AppLocalizations.of(context)!.endTime} ${isMandatory ? "*" : ""}",
                            value: _formatDate(_initialItem['EndAtUtc']),
                            icon: Icons.event_outlined,
                          );
                        },
                      ),

                      _disabledField(
                        label: AppLocalizations.of(context)!.durationInHours,
                        value: _initialItem['Duration'].toString(),
                        icon: Icons.timer_outlined,
                      ),
                      _disabledField(
                        label: AppLocalizations.of(context)!.endEvent,
                        value: _initialItem['EndReason'],
                        icon: Icons.flag_outlined,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.updateDetails,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      widget.controller.buildConfigurableField(
                        fieldName: "Project Id",
                        builder: (isEnabled, isMandatory) {
                          return SearchableMultiColumnDropdownField<Project>(
                            key: const ValueKey('bottom_sheet_project'),
                            labelText:
                                '${AppLocalizations.of(context)!.projectId}  ${isMandatory ? "*" : ""}',
                            columnHeaders: [
                              AppLocalizations.of(context)!.projectName,
                              AppLocalizations.of(context)!.projectId,
                            ],
                            items: widget.controller.project,
                            controller:
                                widget.controller.projectDropDowncontroller,
                            selectedValue: widget.controller.selectedProject,
                            validator: (_) {
                              if (widget
                                  .controller
                                  .projectDropDowncontroller
                                  .text
                                  .isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.pleaseSelectProject;
                              }
                              return null;
                            },
                            searchValue: (p) => '${p.name} ${p.code}',
                            displayText: (p) => p.code,
                            onChanged: (p) {
                              widget.controller.projectDropDowncontroller.text =
                                  p?.code ?? '';
                              widget.controller.selectedProject = p;
                              widget.controller.showProjectError.value = false;
                            },
                            rowBuilder: (p, _) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Text(p.name)),
                                  Expanded(child: Text(p.code)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Board dropdown
                      SearchableMultiColumnDropdownField<BoardModel>(
                        key: const ValueKey('bottom_sheet_board'),
                        labelText:
                            '${AppLocalizations.of(context)!.boardName} *',
                        columnHeaders: [
                          AppLocalizations.of(context)!.id,
                          AppLocalizations.of(context)!.name,
                        ],
                        items: widget.controller.boardList,
                        selectedValue: widget.controller.selectedBoards,
                        controller: widget.controller.boardNameController,
                        displayText: (b) => b.boardId,
                        searchValue: (b) => '${b.boardId} ${b.boardName}',
                        rowBuilder: (b, _) => Row(
                          children: [
                            SizedBox(width: 10),
                            Expanded(child: Text(b.boardId)),
                            Expanded(child: Text(b.boardName)),
                          ],
                        ),
                        onChanged: (b) {
                          widget.controller.boardNameController.text =
                              b?.boardId ?? '';
                          widget.controller.selectedBoards = b;
                        },
                        validator: (_) {
                          if (widget
                              .controller
                              .boardNameController
                              .text
                              .isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.boardNameIsRequired;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Task dropdown
                      SearchableMultiColumnDropdownField<TaskModelDropDown>(
                        key: const ValueKey('bottom_sheet_task'),
                        labelText: '${AppLocalizations.of(context)!.taskId} *',
                        columnHeaders: [
                          AppLocalizations.of(context)!.id,
                          AppLocalizations.of(context)!.name,
                        ],
                        items: widget.controller.taskList,
                        selectedValue: widget.controller.selectedTask,
                        controller: widget.controller.taskNameController,
                        displayText: (t) => t.taskId,
                        searchValue: (t) => '${t.taskId} ${t.taskName}',
                        rowBuilder: (t, _) => Row(
                          children: [
                            Expanded(child: Text(t.taskId)),
                            Expanded(child: Text(t.taskName)),
                          ],
                        ),
                        onChanged: (t) {
                          widget.controller.selectedTask = t;
                          widget.controller.taskNameController.text =
                              t?.taskName ?? '';
                          widget.controller.taskIdController.text =
                              t?.taskId ?? '';
                        },
                        validator: (_) {
                          if (widget
                              .controller
                              .taskNameController
                              .text
                              .isEmpty) {
                            return 'Task ID is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Notes field
                      TextFormField(
                        key: const ValueKey('bottom_sheet_notes'),
                        controller: widget.controller.noteCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.enterNotes,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      // Save and Close buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              key: const ValueKey('save_button'),
                              onPressed: _isSaving ? null : _saveSegment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: _isSaving
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              key: const ValueKey('close_button'),
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(AppLocalizations.of(context)!.close),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sheetHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.editSegment,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _disabledField({
    required String label,
    String? value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value ?? '--',
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: icon != null ? Icon(icon) : null,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

Future<DateTimeRange?> showPeriodPicker({
  required BuildContext context,
  required String periodType,
  required String weekStart,
  required String monthStart,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required DateTimeRange Function(
    String,
    DateTime, {
    String weekStart,
    String monthStart,
  })
  getRangeFromConfig,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (_) => PeriodPickerDialog(
      periodType: periodType,
      weekStart: weekStart,
      monthStart: monthStart,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      getRangeFromConfig: getRangeFromConfig,
    ),
  );
}
