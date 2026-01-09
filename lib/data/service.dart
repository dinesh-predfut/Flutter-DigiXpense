// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:convert' as request;
import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' show PdfEncryption;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/API_Service/apiService.dart'
    show ApiService;
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/reportsCreateForm.dart';
import 'package:digi_xpense/data/pages/screen/Dashboard_Screen/DashboardItemsByrole/spenders.dart';
import 'package:digi_xpense/data/pages/screen/Task_Board/addmoreetailsTask.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:digi_xpense/main.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as Apiservice;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:digi_xpense/core/constant/Parames/models.dart'
    hide ChecklistItem;
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/core/constant/url.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
// ignore: duplicate_import
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart' hide PdfDocument, PdfPage, PdfGraphics, PdfFont;
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart'
    show ColumnSeries, DataLabelSettings, CartesianSeries;
import 'package:table_calendar/table_calendar.dart'
    show CalendarFormat, isSameDay;
import 'package:url_launcher/url_launcher.dart';
import 'pages/EmailHub/emailDetailsPage.dart';
import 'pages/screen/widget/router/router.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';

class Controller extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotemailController = TextEditingController();
  final TextEditingController manualPaidToController = TextEditingController();
  // setting
  final TextEditingController countryPresentTextController =
      TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController employeeName = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController officialEmailController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController leavephoneController = TextEditingController();
  final TextEditingController appliedDateController = TextEditingController();
  final TextEditingController leaveIdcontroller = TextEditingController();
  final TextEditingController leaveCancelID = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController locale = TextEditingController();
  final TextEditingController justificationnotes = TextEditingController();
  RxBool isPublic = false.obs;
  TextEditingController boardNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController referenceIdController = TextEditingController();
  // final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController addresspurpose = TextEditingController();
  final TextEditingController cashAdvanceRequisitionID =
      TextEditingController();
  final TextEditingController leavefilterDateController =
      TextEditingController();

  // final TextEditingController country = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController contactStreetController = TextEditingController();
  final TextEditingController contactCityController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController unitRate = TextEditingController();
  final TextEditingController unitRateCA1 = TextEditingController();
  final TextEditingController unitRateCA2 = TextEditingController();

  final TextEditingController quantity = TextEditingController(text: "1.00");
  final TextEditingController uomId = TextEditingController();
  final TextEditingController contactPostalController = TextEditingController();
  final TextEditingController addressID = TextEditingController();
  final TextEditingController contactaddressID = TextEditingController();
  final TextEditingController paidAmount = TextEditingController();
  final TextEditingController paidAmountCA1 = TextEditingController();

  final TextEditingController totalRequestedAmount = TextEditingController();

  final TextEditingController amountINR = TextEditingController();
  final TextEditingController approvalamountINR = TextEditingController();
  final TextEditingController estimatedamountINR = TextEditingController();
  final TextEditingController requestamountINR = TextEditingController();
  final TextEditingController amountINRCA1 = TextEditingController();
  final TextEditingController amountINRCA2 = TextEditingController();
  final TextEditingController lineAmount = TextEditingController();
  final TextEditingController lineAmountINR = TextEditingController();
  late final TextEditingController unitAmount = TextEditingController();
  final TextEditingController taxAmount = TextEditingController();
  final TextEditingController referenceID = TextEditingController();
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController paidToController = TextEditingController();
  final TextEditingController paidWithController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController projectIdController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController mileageVehicleName = TextEditingController();
  final TextEditingController mileageVehicleID = TextEditingController();

  final TextEditingController statePresentTextController =
      TextEditingController();
  final TextEditingController stateconsTextController = TextEditingController();
  final TextEditingController presentCountryTextController =
      TextEditingController();
  final TextEditingController countryConstTextController =
      TextEditingController();
  final TextEditingController stateTextController = TextEditingController();
  List<TextEditingController> expenseIdControllers = [];
  List<TextEditingController> receiptDateControllers = [];
  final List<ItemizeSection> itemizeSections = [];
  final TextEditingController unitAmountView = TextEditingController();
  final TextEditingController unitPriceTrans = TextEditingController();
  final TextEditingController taxGroupController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController unitRateID = TextEditingController();
  late TextEditingController currencyDropDowncontroller =
      TextEditingController();
  late TextEditingController currencyDropDowncontroller2 =
      TextEditingController();
  late TextEditingController prefPaymentMethod = TextEditingController();
  late TextEditingController currencyDropDowncontrollerCA3 =
      TextEditingController();
  late TextEditingController currencyDropDowncontrollerCA2 =
      TextEditingController();
  final TextEditingController projectDropDowncontroller =
      TextEditingController();
  List<TextEditingController> tripControllers = [
    TextEditingController(), // Start Trip
    TextEditingController(), // End Trip
  ];
  RxMap<int, String> partialCancelSelection = <int, String>{}.obs;
  RxList<LeaveRequisition> leaveRequisitionList = <LeaveRequisition>[].obs;
  RxList<LeaveRequisition> myTeamleaveRequisitionList =
      <LeaveRequisition>[].obs;
  RxList<LeaveCancellationModel> myCancelationleaveRequisitionList =
      <LeaveCancellationModel>[].obs;

  RxList<LeaveCancellationModel> pendingApproval =
      <LeaveCancellationModel>[].obs;
  late int workitemrecid;
  RxList<PayslipAnalyticsCard> payslipAnalyticsCards =
      <PayslipAnalyticsCard>[].obs;
  RxString selectedReferenceType = ''.obs;
  final List<String> referenceTypes = [
    'Expense',
    'Project',
    'Travel',
    'Cash Advance',
    'Payment Proposal',
  ];

  // Employee Selection
  RxList<Employee> employees = <Employee>[].obs;
  RxList<Employee> selectedEmployees = <Employee>[].obs;
  RxList<EmployeeGroup> employeeGroups = <EmployeeGroup>[].obs;
  RxList<EmployeeGroup> selectedGroups = <EmployeeGroup>[].obs;

  final Rx<TaskModel?> selectTast = Rx<TaskModel?>(null);
  List<BoardMember> boardMembers = [];
  List<TaskModel> tasksValue = [];
  RxList<BoardMember> selectedMembers = <BoardMember>[].obs;
  final Rx<Shelf?> selectedBoard = Rx<Shelf?>(null);
  // RxList<KanbanBoard> selectedBoard= <KanbanBoard>[].obs;
  RxList<TaskModel> selectedDependency = <TaskModel>[].obs;
  RxList<TagModel> selectedTags = <TagModel>[].obs;
  final Rx<BoardMember?> selectedSettingsMembers = Rx<BoardMember?>(null);
  // Loading States
  RxBool isLoading = false.obs;
  final RxBool isSavingMember = false.obs;

  RxBool isLoadingEmployees = false.obs;
  RxBool isLoadingTemplates = false.obs;
  RxBool isLoadingLeave = false.obs;
  KanbanBoard? originalBoard;
  // Button Loading States
  final RxMap<String, bool> buttonLoaders = <String, bool>{}.obs;
  RxList<TagModel> taskTags = <TagModel>[].obs;
  RxList<CardTypeModel> cardType = <CardTypeModel>[].obs;
  // Validation
  RxBool showBoardNameError = false.obs;
  RxBool showTemplateError = false.obs;
  RxList<AttachmentModel> attachments = <AttachmentModel>[].obs;
  RxList<LocalAttachment> localAttachments = <LocalAttachment>[].obs;
  Rx<Employee?> selectedEmployee = Rx<Employee?>(null);
  List<FileItem> fileItems = [];
  RxBool isLoadingLeaves = false.obs;
  String? mapLeaveStatusToApi(String selectedStatus) {
    switch (selectedStatus) {
      case 'Un Reported':
        return 'Created';
      case 'In Process':
        return 'Pending';
      case 'Approved':
        return 'Approved';
      case 'Cancelled':
        return 'Cancelled';
      case 'Rejected':
        return 'Rejected';
      case 'All':
        return null;
      default:
        return null;
    }
  }

  void removeAttachment(AttachmentModel attachment) {
    attachments.remove(attachment);

    if (!attachment.isLocal) {
      // TODO: call DELETE API here
    }
  }

  Future<void> postComment({
    required String taskId,
    required String commentedBy,
    required String comment,
  }) async {
    final response = await ApiService.post(
      Uri.parse('${Urls.baseURL}/api/v1/kanban/tasks/comments/comments'),

      body: jsonEncode({
        "AssignedTo": [],
        "Comment": comment,
        "CommentedBy": commentedBy,
        "TaskId": taskId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to post comment');
    }
  }

  Future<bool> updateTask({
    required int recId,
    required String taskName,
    required String screenName,
    required String priority,
    required DateTime? startDate,
    required DateTime? dueDate,
    String? notes,
    bool showNotes = false,
    bool showChecklist = false,
    double estimatedHours = 0,
    String? status,
    List<TagModel> selectedTags = const [],
    List<BoardMember> selectedMembers = const [],
    CardTypeModel? selectedCardType,
    TaskModel? parentTask,
    List<TaskModel> selectedDependencies = const [],
    String? actualHours,
    String? version,
    String? dependentDescription,
    context,
    String? bordeId,
    List<ChecklistItem>? checkLists,
    bool? main,
  }) async {
    try {
      // Prepare payload
      // / Prepare payload - fix for dependencies
      final payload = {
        "TaskName": taskName,

        "TaskData": {
          "Actual Hours": actualHours?.isNotEmpty == true ? actualHours : null,
          "Version": version?.isNotEmpty == true ? version : null,
        },

        "Notes": notes ?? "",
        "ShowNotes": showNotes,
        "ShowChecklist": showChecklist,
        "EstimatedHours": estimatedHours ?? 0,
        "Status": status ?? "",
        "Priority": priority,

        "StartDate": startDate != null
            ? DateFormat('yyyy-MM-dd').format(startDate)
            : null,

        "DueDate": dueDate != null
            ? DateFormat('yyyy-MM-dd').format(dueDate)
            : null,

        "TagId": selectedTags.isNotEmpty
            ? selectedTags.map((t) => t.tagId).join(',')
            : "",

        "AssignedTo": selectedMembers.isNotEmpty
            ? selectedMembers.map((m) => m.userId).join(',')
            : "",

        "ParentTaskId": parentTask?.taskId ?? null,

        "Dependent": selectedDependencies.isNotEmpty
            ? selectedDependencies.map((d) => d.taskId).join(',')
            : "",

        "CardType": selectedCardType?.boardCardId ?? null,

        "Attachments": attachments.map((attachment) {
          return {
            "FileName": attachment.fileName,
            "FileType": attachment.fileType,
            "FileSize": attachment.fileSize?.toString() ?? "0",
            "base64Data": attachment.base64Data ?? "",
            "ShowAttachment": attachment.showAttachment,
            "RecId": attachment.recId ?? 0,
          };
        }).toList(),

        "CheckLists": checkLists!.map((item) {
          return {
            "Description": item.description,
            "Status": item.status ?? false,
            "RecId": item.recId ?? 0,
          };
        }).toList(),

        "CustomFieldValues": [],
      };

      // Remove null or empty TaskData if both fields are empty
      if ((payload["TaskData"] as Map).isEmpty) {
        payload.remove("TaskData");
      }

      // Make API call

      final response = await ApiService.put(
        Uri.parse(
          '${Urls.baseURL}/api/v1/kanban/tasks/tasks/update?RecId=$recId',
        ),

        body: jsonEncode(payload),
      );
      if (response.statusCode == 280) {
        if (main ?? true) {
          Navigator.pushNamed(
            context,
            AppRoutes.kanbanBoardPage,
            arguments: {"boardId": bordeId},
          );
        } else {
          Navigator.of(context).pop();
        }

        print('Task updated successfully');
        return true;
      } else {
        print('Failed to update task: ${response.statusCode}');

        return false;
      }
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  final RxBool isDataLoaded = false.obs;
  // Per Diem
  RxString selectedIcon = ''.obs;
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController mileagDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  // final TextEditingController locationController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController selectedCountryCode = TextEditingController();
  final TextEditingController perDiemController = TextEditingController();
  final TextEditingController exchangeCurrencyCode = TextEditingController();
  final TextEditingController amountInController = TextEditingController();
  final TextEditingController exchangeamountInController =
      TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final Map<String, Color> themeColorMap = {
    "RED_THEME": Colors.pinkAccent,
    "GREEN_THEME": Colors.green,
    "BLUE_THEME": Colors.blue,
    "ORANGE_THEME": Colors.orange,
    "PURPLE_THEME": Colors.purple,
    "INDIGO_THEME": Colors.indigo,
    "DARK_RED_THEME": const Color.fromARGB(255, 250, 60, 155),
    "DARK_GREEN_THEME": Color(0xFF1B5E20),
    "DARK_BLUE_THEME": Color(0xFF0D47A1),
    "DARK_INDIGO_THEME": Color(0xFF1A237E),
    "DARK_PURPLE_THEME": Color(0xFF6A1B9A),
    "DARK_ORANGE_THEME": Color(0xFFE65100),
  };
  var currentIndex = 0.obs;
  String? digiSessionId;
  String? cashAdvReqIds;
  String? themeColorCode;
  var showMileage = false.obs;
  var showPerDiem = false.obs;
  var showExpense = false.obs;
  Rx<Dashboard?> selectedDashboard = Rx<Dashboard?>(null);
  Rx<DashboardByRole?> selectedDashboardByrole = Rx<DashboardByRole?>(null);

  RxList<String> availableRoles = <String>[].obs;
  final Map<String, GlobalKey> widgetRenderKeys = {};

  RxString currentRole = "".obs;

  RxBool isLoadingWidgets = false.obs;
  RxBool isExporting = false.obs;
  RxList<WidgetDataResponse> currentDashboardWidgets =
      <WidgetDataResponse>[].obs;

  final wizardConfigs = <WizardConfig>[].obs;
  final widgetDataCache = <String, WidgetDataResponse>{}.obs;
  // final isLoadingWidgets = false.obs;
  // var currentRole = 'Spender'.obs;
  var showCashAdvance = false.obs;
  List<VehicleType> vehicleTypes = []; // Dropdown values from API
  VehicleType? selectedVehicleType; // Currently selected type
  MileageRateResponse? mileageRateResponse;
  List<Map<String, dynamic>> mileageRateLines = [];
  var projectExpenses = <ProjectExpense>[].obs;
  var expensesByStatus = <ExpenseAmountByStatus>[].obs;
  var manageExpensesCards = <ManageExpensesCard>[].obs;
  var managecashAdvanceCards = <ManageExpensesCard>[].obs;
  var customFieldsDropDownvalue = <Map<String, dynamic>>[].obs;
  // var cashAdvanceTrends = <CashAdvanceTrendData>[].obs;
  var isLoadingCashAdvanceTrends = false.obs;
  var isFetchingStates = false.obs;
  var isFetchingStatesSecond = false.obs;
  final List<ExpenseItem> itemizeControllers = <ExpenseItem>[];
  bool isAlcohol = false;
  bool isTobacco = false;
  bool isDuplicated = false;
  RxBool userPref = false.obs;
  RxBool showQuantityError = false.obs;
  RxBool showUnitAmountError = false.obs;
  RxBool showUnitError = false.obs;
  RxBool showTaxAmountError = false.obs;
  RxBool showTaxGroupError = false.obs;
  // var isLoading = false.obs;
  var dashboards = <Dashboard>[].obs;
  var dashboardByRole = <DashboardByRole>[].obs;

  // var selectedDashboard = Rxn<Dashboard>();
  var selectedDashboardIndex = 0.obs;
  RxBool showPaidForError = false.obs;
  RxBool showProjectError = false.obs;
  RxBool enableNextBtn = true.obs;
  RxBool setQuality = true.obs;
  RxBool leaveField = false.obs;
  // Define this at the class level
  Set<int> skippedWorkItems = {};
  var expenseChartData = <ExpenseAmountByStatus>[].obs;
  final RxBool showSkipButton = true.obs;
  SharedPreferences? _prefs;
  List<double>? initialUnitPriceTrans; // Make sure to initialize this list

  final String skippedItemsKey = 'skippedWorkItems';
  RxList<CashAdvanceModel> cashAdvanceList = <CashAdvanceModel>[].obs;
  RxList<ExpenseListModel> expenseList = <ExpenseListModel>[].obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<PendingCashAdvanceApproval> pendingApprovalcashAdvanse = [];
  var isUploadingCards = false.obs;
  var isUploadingCardsUpdate = false.obs;
  var isLoadingStatus = false.obs;
  var callAPIDashBoard = true.obs;
  final RxBool showCancelIcon = true.obs;
  bool showAllCashAdvance = false; // Track see more
  bool showAllExpense = false;
  bool callProfile = false;
  double calculatedAmountINR = 0;
  double calculatedAmountUSD = 0;
  double totalDistanceKm = 0;
  bool isRoundTrip = false;
  RxList<dynamic> customFields = <dynamic>[].obs; // bool isInitialized = true;
  var notifications = <NotificationModel>[].obs;
  var unreadNotifications = <NotificationModel>[].obs;
  late List<ProjectData> chartData = [];
  var projectExpensesbyCategory = <ProjectExpensebycategory>[].obs;
  var resendCountdown = 0.obs;
  int? recId;
  int? rate;
  //
  //
  // CashAdvanceRequest@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  // final Rx<LocationModel?> selectedLocation = Rx<LocationModel?>(null);
  final TextEditingController justificationController = TextEditingController();
  final TextEditingController totalunitEstimatedAmount =
      TextEditingController();
  //  final TextEditingController expenseIdController = TextEditingController();
  RxDouble calculatedPercentage = 0.0.obs;
  String? localFieldValue;
  final TextEditingController requestedPercentage = TextEditingController();
  final TextEditingController requisitionIdController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  RxList<CashAdvanceDropDownModel> cashAdvanceListDropDown =
      <CashAdvanceDropDownModel>[].obs;
  final RxList<CashAdvanceRequisition> cashAdvanceListDashboard =
      <CashAdvanceRequisition>[].obs;
  final RxBool isLoadingCA = false.obs;
  final RxList<Businessjustification> justification =
      <Businessjustification>[].obs;
  Businessjustification? selectedjustification;
  late final TextEditingController cashAdvanceIds =
      TextEditingController(); // ✅ one-liner

  // var selectedStatus = 'All'.obs;
  // Leave@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  RxList<File> uploadedImages = <File>[].obs;

  final RxList<LocationModel> locations = <LocationModel>[].obs;
  final RxList<Employee> notifyingUsers = <Employee>[].obs;
  final RxList<String> availabilityOptions = <String>[
    "Available For Urgent Matters",
    "Not Available",
  ].obs;
  final RxList<LeaveAnalytics> leaveCodes = <LeaveAnalytics>[].obs;

  // Field configurations
  final RxList<LeaveFieldConfig> fieldConfigsLeave = <LeaveFieldConfig>[].obs;

  // Selected values
  final Rx<LeaveAnalytics?> selectedLeaveCode = Rx<LeaveAnalytics?>(null);
  final Rx<CardTypeModel?> selectedCardType = Rx<CardTypeModel?>(null);
  final Rx<Employee?> selectedReliever = Rx<Employee?>(null);
  final RxList<Employee> selectedNotifyingUsers = <Employee>[].obs;
  final RxString selectedAvailability = ''.obs;

  // Form state
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString contactNumber = ''.obs;
  final RxString comments = ''.obs;
  RxList<CommentModel> commentKanba = <CommentModel>[].obs;

  final RxString outOfOfficeMessage = ''.obs;
  final RxBool notifyHR = false.obs;
  final RxBool notifyTeam = false.obs;
  final RxBool isPaidLeave = true.obs;
  final RxInt totalDays = 0.obs;

  // Controllers for text fields
  final TextEditingController leaveCodeController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController relieverController = TextEditingController();
  final TextEditingController datesController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController outOfOfficeMessageController =
      TextEditingController();

  // Loading states
  //  Future<void> fetchLeaveCodes() async {
  //   try {
  //     final response = await ApiService().getLeaveCodes();
  //     leaveCodes.assignAll(response);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> fetchNotifyingUsers() async {
  //   try {
  //     final response = await ApiService().getNotifyingUsers();
  //     notifyingUsers.assignAll(response);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> fetchAvailabilityOptions() async {
  //   try {
  //     final response = await ApiService().getAvailabilityOptions();
  //     availabilityOptions.assignAll(response);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<List<LeaveFieldConfig>> fetchLeaveFieldConfigurations() async {
  //   try {
  //     final response = await ApiService().getLeaveFieldConfigurations();
  //     fieldConfigs.assignAll(response);
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  void setButtonLoading(String buttonId, bool loading) {
    buttonLoaders[buttonId] = loading;
    buttonLoaders.refresh();
  }

  bool isButtonLoading(String buttonId) {
    return buttonLoaders[buttonId] ?? false;
  }

  Rx<DateTime?> selectedFilterDate = Rx<DateTime?>(null);

  // Dropdown filters
  RxString selectedViewType = 'My Leave'.obs;
  RxString selectedStatusLeave = 'All'.obs;

  /// Apply filters
  void applyCalendarFilters() {
    // TODO: Call API / filter local events
    fetchCalendarData();
  }

  /// Clear filters
  void clearCalendarFilters() {
    selectedFilterDate.value = null;
    selectedViewType.value = 'My Leave';
    selectedStatusLeave.value = 'All';
    selectedLeaveCode.value = null;
    selectedEmployee.value = null;
  }

  Future<List<ChecklistItem>> fetchChecklist({
    required int taskRecId,
    required BuildContext context,
  }) async {
    final uri = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/checklist/checklistlist'
      '?screen_name=KANCheckLists'
      '&TaskRecId=$taskRecId',
    );

    final response = await ApiService.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List list = json['CheckLists'] ?? [];

      return list.map((e) => ChecklistItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load checklist');
    }
  }

  void fetchCalendarData() {
    // your existing API logic
  }
  Future<void> pickImages() async {
    final picker = ImagePicker();

    final images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      uploadedImages.addAll(images.map((e) => File(e.path)));
    }
  }

  // void calculateTotalDays() {
  //   if (startDate.value != null && endDate.value != null) {
  //     totalDays.value = endDate.value!.difference(startDate.value!).inDays + 1;
  //   } else {
  //     totalDays.value = 0;
  //   }
  // }

  void updateDatesController() {
    final today = DateTime.now();
    if (startDate.value != null && endDate.value != null) {
      final start = DateFormat('dd/MM/yyyy').format(startDate.value!);
      final end = DateFormat('dd/MM/yyyy').format(endDate.value!);
      datesController.text = '$start - $end';
    } else {
      final start = DateFormat('dd/MM/yyyy').format(today);
      final end = DateFormat('dd/MM/yyyy').format(today);
      datesController.text = '$start - $end';
    }
  }

  Future<List<CommentModel>> fetchComments({required int taskRecId}) async {
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.baseURL}/api/v1/kanban/tasks/comments/commentslist?TaskRecId=$taskRecId',
      ),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded['Comments'] ?? [];
      return list.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<TaskDetailModel> fetchTaskDetails(
    int recId,
    BuildContext context,
  ) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/tasks/taskdetails?'
      'screen_name=KANTasks&'
      'lock_id=$recId&'
      'TaskRecId=$recId',
    );

    final response = await ApiService.get(url);

    print("STATUS => ${response.statusCode}");
    print("RAW RESPONSE => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // ✅ CASE 1: API returns single object (YOUR CASE)
      if (jsonData is Map<String, dynamic>) {
        return TaskDetailModel.fromJson(jsonData);
      }

      // ✅ CASE 2: API returns list
      if (jsonData is List && jsonData.isNotEmpty) {
        return TaskDetailModel.fromJson(jsonData.first as Map<String, dynamic>);
      }

      throw Exception('Unexpected task details response format');
    } else {
      throw Exception('Failed to load task details: ${response.statusCode}');
    }
  }

  bool showAttachment = true;

  Future<void> pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    /// Convert file to base64
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);

    attachments.add(
      AttachmentModel(
        attachmentId: '', // not yet uploaded
        taskId: '', // assign if available
        showAttachment: showAttachment,
        fileType: p.extension(picked.path).replaceFirst('.', ''),
        fileSize: bytes.length.toString(),
        filePath: picked.path, // optional (local preview)
        recId: 0,
        fileName: p.basename(picked.path),
        localFile: file,
        base64Data: base64String,
      ),
    );
  }

  Future<List<AttachmentModel>> fetchAttachments({
    required int taskRecId,
  }) async {
    final uri = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/attachments/attachmentlist'
      '?screen_name=KANTaskDocuments'
      '&TaskRecId=$taskRecId',
    );

    final response = await ApiService.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded['Attachments'] ?? [];

      return list.map((e) => AttachmentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load attachments');
    }
  }

  Future<List<TagModel>> fetchTaskTags({required int taskRecId}) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tags/tags/joints?TaskRecId=$taskRecId',
    );
    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((tag) => TagModel.fromJson(tag)).toList();
    } else {
      throw Exception('Failed to load tags: ${response.statusCode}');
    }
  }

  Future<List<CardTypeModel>> fetchCardTypes({required int recId}) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/cardtypes/cardtypes/cardtypesdropdown?'
      'screen_name=KANCardTypes&'
      'RecId=$recId',
    );
    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map((cardType) => CardTypeModel.fromJson(cardType))
          .toList();
    } else {
      throw Exception('Failed to load card types: ${response.statusCode}');
    }
  }

  void resetForm() {
    leaveField.value = false;
    leaveCodeController.clear();
    leaveCancelID.clear();
    leavephoneController.clear();
    leaveID = null;
    recID = null;
    modifiedDays.clear();
    leaveIdcontroller.clear();
    projectDropDowncontroller.clear();
    leaveCancelID.clear();
    appliedDateController.clear();
    selectedLeaveCode.value = null;
    selectedProject = null;
    selectedReliever.value = null;
    selectedLocation = null;
    selectedNotifyingUsers.clear();
    selectedAvailability.value = '';
    totalRequestedDays.value = 0.0;
    recID = null;
    leaveDays.clear();
    startDate.value = null;
    uploadedImages.clear();
    imageFiles.clear();
    endDate.value = null;
    contactNumber.value = '';
    comments.value = '';
    outOfOfficeMessage.value = '';
    notifyHR.value = false;
    notifyTeam.value = false;
    isPaidLeave.value = true;
    totalDays.value = 0;
    leaveField.value = false;
    leaveCodeController.clear();
    projectController.clear();
    relieverController.clear();
    datesController.clear();
    locationController.clear();
    contactNumberController.clear();
    commentsController.clear();
    availabilityController.clear();
    outOfOfficeMessageController.clear();
  }

  Future<void> submitApprovalLeaveRequest(
    BuildContext context,
    bool submit,
    int workId,
  ) async {
    //  // print("CallSubmit");
    if (!_validateForm() && !submit) {
      Get.snackbar('Error', 'Please fill all required fields');
      //  // print("CallSubmitErro");
      return;
    }
    for (int i = 0; i < uploadedImages.length; i++) {
      File image = uploadedImages[i];
      List<int> imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);

      fileItems.add(
        FileItem(
          index: i,
          name: image.path.split('/').last,
          type: 'image/${image.path.split('.').last}',
          base64Data: base64String,
          hashMapKey: '',
        ),
      );
    }
    final leaveRequest = LeaveRequest(
      leaveId: leaveID,
      recId: recID,
      employeeId: Params.employeeId,
      employeeName: Params.employeeName ??  userName.value,
      applicationDate: DateTime.now().millisecondsSinceEpoch,
      calendarId: calendarId!,
      duration: totalDays.value,
      leaveCode: selectedLeaveCode.value?.leaveCode,
      projectId: selectedProject?.code,
      relieverId: selectedReliever.value?.id,
      startDate: startDate.value,
      endDate: endDate.value,
      location: selectedLocation?.location,
      notifyingUsers: selectedNotifyingUsers.map((e) => e.id).toList(),
      contactNumber: leavephoneController.text,
      comments: comments.value,
      availabilityDuringLeave: selectedAvailability.value,
      outOfOfficeMessage: outOfOfficeMessage.value,
      notifyHR: notifyHR.value,
      notifyTeam: notifyTeam.value,
      isPaidLeave: isPaidLeave.value,
      attachments: [DocumentAttachmentbase64(file: fileItems)],

      totalDays: totalDays.value,
      // status: submit ? 'Submitted' : 'Draft',
      fromDateHalfDay: false,
      fromDateHalfDayValue: null,
      leaveBalance: 34,
      toDateHalfDay: false,
      transactions: leaveDays,
    );

    try {
      setButtonLoading('submit', true);
      reviewUpdateLeaveRequestFinal(context, leaveRequest, submit: submit);
      // await ApiService().submitLeaveRequest(leaveRequest, isDraft);

      if (context.mounted) {
        // Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit leave request: $e');
    } finally {
      setButtonLoading('submit', false);
    }
  }

  Future<void> submitLeaveRequest(
    BuildContext context,
    bool submit,
    bool resubmit,
  ) async {
    //  // print("CallSubmit");
    if (!_validateForm() && !submit) {
      Get.snackbar('Error', 'Please fill all required fields');
      //  // print("CallSubmitErro");
      return;
    }
    for (int i = 0; i < uploadedImages.length; i++) {
      File image = uploadedImages[i];
      List<int> imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);

      fileItems.add(
        FileItem(
          index: i,
          name: image.path.split('/').last,
          type: 'image/${image.path.split('.').last}',
          base64Data: base64String,
          hashMapKey: '',
        ),
      );
    }
    final leaveRequest = LeaveRequest(
      leaveId: leaveID,
      recId: recID,
      employeeId: Params.employeeId,
      employeeName: Params.employeeName ??  userName.value,
      applicationDate: DateTime.now().millisecondsSinceEpoch,
      calendarId: calendarId!,
      duration: totalDays.value,
      leaveCode: selectedLeaveCode.value?.leaveCode,
      projectId: projectDropDowncontroller.text,
      relieverId: selectedReliever.value?.id,
      startDate: startDate.value,
      endDate: endDate.value,
      location: selectedLocation?.location,
      notifyingUsers: selectedNotifyingUsers.map((e) => e.id).toList(),
      contactNumber: leavephoneController.text,
      comments: comments.value,
      availabilityDuringLeave: selectedAvailability.value,
      outOfOfficeMessage: outOfOfficeMessage.value,
      notifyHR: notifyHR.value,
      notifyTeam: notifyTeam.value,
      isPaidLeave: isPaidLeave.value,
      attachments: [DocumentAttachmentbase64(file: fileItems)],

      totalDays: totalDays.value,
      // status: submit ? 'Submitted' : 'Draft',
      fromDateHalfDay: false,
      fromDateHalfDayValue: null,
      leaveBalance: 34,
      toDateHalfDay: false,
      transactions: leaveDays,
    );

    try {
      setButtonLoading('submit', true);
      submitLeaveRequestFinal(
        context,
        leaveRequest,
        resubmit: resubmit,
        submit: submit,
      );
      // await ApiService().submitLeaveRequest(leaveRequest, isDraft);

      if (context.mounted) {
        // Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit leave request: $e');
    } finally {
      setButtonLoading('submit', false);
    }
  }

  RxList<LeaveTransactionModel> leaveDays = <LeaveTransactionModel>[].obs;
  RxList<LeaveTransactionforLeave> leaveTransactions =
      <LeaveTransactionforLeave>[].obs;
  RxMap<int, String> modifiedDays = <int, String>{}.obs;

  RxDouble totalRequestedDays = 0.0.obs;
  void calculateTotalDays() {
    double total = 0;
    for (final day in leaveDays) {
      total += day.calculatedDays;
    }
    totalRequestedDays.value = total;
  }
  // void generateLeaveDays(DateTime from, DateTime to) {
  //   leaveDays.clear();
  //   leaveTransactions.clear();

  //   for (int i = 0; i <= to.difference(from).inDays; i++) {
  //     final date = from.add(Duration(days: i));

  //     final daySelection = LeaveDaySelection(
  //       date: date,
  //       recId: null,
  //       initialType: 'Full Day',
  //       dayType: '',
  //     );
  //     leaveDays.add(daySelection);

  //     leaveTransactions.add(
  //       LeaveTransactionforLeave(
  //         // employeeId: Params.employeeId, // from logged-in user
  //         transDate: date.millisecondsSinceEpoch,
  //         noOfDays: 1.0,
  //         leaveCode: selectedLeaveCode.value!.leaveCode,
  //         leaveFirstHalf: false,
  //         leaveSecondHalf: false,
  //         dateType: DateTypeModel(
  //           dateType: 'Full Day',
  //           noOfDays: 1.0,
  //           isSelected: true,
  //         ),
  //         employeeId: Params.employeeId,
  //       ),
  //     );
  //   }

  //   calculateTotalDays();
  // }

  // void calculateTotalDays() {
  //   double total = 0;

  //   for (var day in leaveDays) {
  //     switch (day.dayType.value) {
  //       case 'Full Day':
  //         total += 1;
  //         break;
  //       case 'First Half':
  //       case 'Second Half':
  //         total += 0.5;
  //         break;
  //     }
  //   }

  //   totalRequestedDays.value = total;
  // }

  bool _validateForm() {
    final leaveCodeConfig = getFieldConfig('Leave Code');
    final projectConfig = getFieldConfig('Project Id');
    final relieverConfig = getFieldConfig('Delegated authority/Reliever');
    final datesConfig = getFieldConfig('Dates');
    final locationConfig = getFieldConfig('Location during leave');
    final contactConfig = getFieldConfig('Contact number');

    if (leaveCodeConfig.isEnabled && leaveCodeConfig.isMandatory) {
      if (selectedLeaveCode.value == null) {
        // debugPrint("❌ Leave Code validation failed");
        return false;
      }
    }

    if (projectConfig.isEnabled && projectConfig.isMandatory) {
      if (selectedProject == null) {
        // debugPrint("❌ Project validation failed");
        return false;
      }
    }

    if (relieverConfig.isEnabled && relieverConfig.isMandatory) {
      if (selectedReliever.value == null) {
        // debugPrint("❌ Reliever validation failed");
        return false;
      }
    }

    if (startDate.value == null || endDate.value == null) {
      // debugPrint("❌ Dates validation failed");
      return false;
    }

    if (locationConfig.isEnabled && locationConfig.isMandatory) {
      if (selectedLocation == null) {
        // debugPrint("❌ Location validation failed");
        return false;
      }
    }

    if (contactConfig.isEnabled && contactConfig.isMandatory) {
      if (leavephoneController.text.isEmpty) {
        // debugPrint("❌ Contact number validation failed");
        return false;
      }
    }

    // debugPrint("✅ Form validation passed");
    return true;
  }

  FieldConfiguration getFieldConfigLeav(String fieldName) {
    return fieldConfigs.firstWhere(
      (config) => config.fieldName == fieldName,
      // orElse: () => LeaveFieldConfig(
      //   fieldName: fieldName,
      //   isEnabled: true,
      //   isMandatory: false, fieldId: '', functionalArea: '', recId: '',
      // ),
    );
  }

  void loadExistingLeaveRequest(LeaveDetailsModel leaveRequest) {
  debugPrint("loadExistingLeaveRequest started");

  /// ---------------- Leave Code ----------------
  final leaveCodeMatch = leaveCodes.firstWhereOrNull(
    (c) => c.leaveCode == leaveRequest.leaveCode,
  );

  selectedLeaveCode.value = leaveCodeMatch;
  leaveCodeController.text = leaveCodeMatch?.leaveCode ?? '';

  /// ---------------- Project ----------------
  if (leaveRequest.projectId != null) {
    final projectMatch = project.firstWhereOrNull(
      (p) => p.code == leaveRequest.projectId,
    );

    selectedProject = projectMatch;
    projectDropDowncontroller.text = projectMatch?.name ?? '';
  }

  /// ---------------- Reliever ----------------
  if (leaveRequest.reliever != null) {
    final relieverMatch = employees.firstWhereOrNull(
      (e) => e.id == leaveRequest.reliever,
    );

    selectedReliever.value = relieverMatch;
    relieverController.text = relieverMatch?.firstName ?? '';
  }

  /// ---------------- Dates ----------------
  startDate.value =
      DateTime.fromMillisecondsSinceEpoch(leaveRequest.fromDate);
  endDate.value =
      DateTime.fromMillisecondsSinceEpoch(leaveRequest.toDate);

  updateDatesController();

  /// ---------------- Location ----------------
  if (leaveRequest.leaveLocation != null) {
    final locationMatch = locations.firstWhereOrNull(
      (l) => l.location == leaveRequest.leaveLocation,
    );

    selectedLocation = locationMatch;
    locationController.text = locationMatch?.location ?? '';
  }

  /// ---------------- Notifying Users ----------------
  selectedNotifyingUsers.clear();

  if (leaveRequest.notifyingUserIds != null) {
    for (final userId in leaveRequest.notifyingUserIds!) {
      final user = employees.firstWhereOrNull(
        (e) => e.id == userId,
      );
      if (user != null) {
        selectedNotifyingUsers.add(user);
      }
    }
  }

  /// ---------------- Applied Date ----------------
  appliedDateController.text = DateFormat('dd/MM/yyyy').format(
    DateTime.fromMillisecondsSinceEpoch(
      leaveRequest.applicationDate,
    ),
  );

  /// ---------------- Other Fields ----------------
  leavephoneController.text =
      leaveRequest.emergencyContactNumber ?? '';

  totalRequestedDays.value = leaveRequest.duration;
  leaveID = leaveRequest.leaveId;
  leaveIdcontroller.text = leaveRequest.leaveId;

  leaveCancelID.text = leaveRequest.leaveCancelId ?? '';

  comments.value = leaveRequest.reasonForLeave ?? '';
  commentsController.text = comments.value;

  selectedAvailability.value =
      leaveRequest.availabilityDuringLeave ?? '';
  availabilityController.text =
      selectedAvailability.value;

  recID = leaveRequest.recId;

  outOfOfficeMessage.value =
      leaveRequest.outOfOfficeMessage ?? '';
  outOfOfficeMessageController.text =
      outOfOfficeMessage.value;

  notifyHR.value = leaveRequest.notifyHR;
  notifyTeam.value = leaveRequest.notifyTeamMembers;

  /// ---------------- Leave Transactions ----------------
  leaveDays.clear();
  totalRequestedDays.value = 0.0;

  createLeaveTransactions(
    employeeId: Params.employeeId,
    fromDate: leaveRequest.fromDate,
    toDate: leaveRequest.toDate,
    leaveCode: leaveRequest.leaveCode,
  );

  for (final tx in leaveRequest.leaveTransactions) {
    String derivedDayType = 'FullDay';

    if (tx.leaveFirstHalf && !tx.leaveSecondHalf) {
      derivedDayType = 'FirstHalf';
    } else if (!tx.leaveFirstHalf && tx.leaveSecondHalf) {
      derivedDayType = 'SecondHalf';
    }

    final leaveDay = LeaveTransactionModel(
      employeeId: tx.employeeId,
      transDate: tx.transDate,
      noOfDays: tx.noOfDays,
      leaveCode: tx.leaveCode,
      leaveFirstHalf: tx.leaveFirstHalf,
      leaveSecondHalf: tx.leaveSecondHalf,
      isHoliday: tx.isHoliday,
      recId: tx.recId,
      originalDayType: derivedDayType,
      dayType: derivedDayType.obs,
      dayTypeLeave: derivedDayType.obs,
    );

    leaveDays.add(leaveDay);
    totalRequestedDays.value += leaveDay.calculatedDays;
  }

  /// ---------------- Paid / Unpaid ----------------
  isPaidLeave.value = !leaveRequest.isLeaveUnPaid;

  debugPrint("loadExistingLeaveRequest completed");
}

  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
    getDeviceToken();
    getPlatform();
    getDeviceId();
    // getInitialRoute();
    // cashAdvanceIds = TextEditingController();
  }

  // void onDayTypeChanged(LeaveTransactionModel day, String? value) {
  //   if (value == null) return;

  //   day.d;
  //   modifiedDays[day.recId!] = value;
  // }

  Future<String?> getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission for iOS
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        //  // print("Push notification permission denied");
        return null;
      }

      String? token = await messaging.getToken();
      //  // print("Device Token: $token");
      return token;
    } catch (e) {
      //  // print("Error getting device token: $e");
      return null;
    }
  }

  String getPlatform() {
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "iOS";
    return "Unknown";
  }

  Future<String?> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // unique Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // unique iOS ID
      }
      return null;
    } catch (e) {
      //  // print("Error getting device ID: $e");
      return null;
    }
  }

  Future<String> generateToken() async {
    //  //  // print("refreshToken${Params.refreshtoken}");
    // // 1. Check if refresh token is available
    final refreshToken = Params.refreshtoken;
    //  //  // print("refreshToken${Params.refreshtoken}");
    // if (refreshToken == null || refreshToken.isEmpty) {
    //   return AppRoutes.entryScreen; // No token at all
    // }

    try {
      // 2. Call API to validate
      final response = await ApiService.post(
        Uri.parse("${Urls.baseURL}/api/v1/tenant/auth/refresh_token"),

        body: jsonEncode({"refresh_token": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["access_token"] != null) {
          // ✅ Token valid → go to Dashboard
          Params.userToken = data["refresh_token"];
          return AppRoutes.dashboard_Main;
        }
      }
      // ❌ Token invalid → signin
      return AppRoutes.signin;
    } catch (e) {
      //  // print("eeee$e");
      return AppRoutes.signin;
    }
  }

  String selectedStatus = "Un Reported";
  var selectedStatusDropDown = "Un Reported".obs;
  var selectedLeaveStatusDropDown = "Un Reported".obs;
  var selectedTimeSheetStatusDropDown = "Un Reported".obs;
  var selectedLeaveStatusDropDownmyTeam = "In Process".obs;
  var selectedExpenseType = "All Expenses".obs;
  String selectedStatusmyteam = "In Process";
  final selectedStatusDropDownmyteam = "In Process".obs;
  String selectedStatusmyteamCashAdvance = "In Process";
  final selectedStatusDropDownmyteamCashAdvance = "In Process".obs;
  var countryCode = ''.obs;
  var phoneNumber = ''.obs;
  List<GESpeficExpense> getSpecificListGExpense = [];
  RxList<GESpeficExpense> specificExpenseList = <GESpeficExpense>[].obs;
  RxList<UnprocessExpenseModels> unProcessModelList =
      <UnprocessExpenseModels>[].obs;
  RxList<CashAdvanceRequestHeader> specificCashAdvanceList =
      <CashAdvanceRequestHeader>[].obs;
  RxList<PerdiemResponseModel> specificPerdiemList =
      <PerdiemResponseModel>[].obs;
  RxList<PerdiemResponseModel> specificLeaveList = <PerdiemResponseModel>[].obs;
  Rx<PerDiemResponseModel?> perdiemResponse = Rx<PerDiemResponseModel?>(null);
  // List<ExpenseItem> expenseItems = [];
  List<ExpenseItem> finalItems = [];
  List<ExpenseItemUpdate> finalItemsSpecific = [];
  // List<CashAdvanceRequestItemize> finalItemsForCashadvance = [];
  List<CashAdvanceRequestItemize> finalItemsCashAdvance = [];
  List<CashAdvanceRequestItemizeFornew> finalItemsCashAdvanceNew = [];
  List<AccountingDistribution?> accountingDistributions = [];
  RxList<GExpense> getAllListGExpense = <GExpense>[].obs;
  RxList<BoardModel> boardList = <BoardModel>[].obs;

  RxList<GExpenseMap> tableListChart = <GExpenseMap>[].obs;

  RxList<ReportModels> getAllListReport = <ReportModels>[].obs;
  RxList<CashAdvanceRequestHeader> getAllListCashAdvanseMyteams =
      <CashAdvanceRequestHeader>[].obs;
  RxList<ExpenseModel> pendingApprovals = <ExpenseModel>[].obs;
  String maritalStatus = 'Single';
  var selectedCurrency = Rxn<Currency>();
  var selectedCurrencyCA1 = Rxn<Currency>();
  var selectedCurrencyCA2 = Rxn<Currency>();
  var manageExpensesSummary = <ManageExpensesSummary>[].obs;
  var isUploadingSummary = false.obs;
  // In your controller
  var searchQuery = ''.obs;
  final searchController = TextEditingController();
  final searchControllerApprovalDashBoard = TextEditingController();
  final searchControllerMyteamsExpense = TextEditingController();
  final searchControllerReports = TextEditingController();
  final searchControllerUnProcess = TextEditingController();
  final searchControllerCashAdvance = TextEditingController();
  final searchControllerCashAdvanceMyteams = TextEditingController();
  final searchControllerCashAdvanceApproval = TextEditingController();
  late double expenseChartvalue = 0.0;
  double? exchangeRate;
  bool isManualEntry = false;
  bool isManualEntryMerchant = false;
  bool isReadOnly = false;
  RxBool isEnable = false.obs;
  RxBool isApprovalEnable = false.obs;
  RxBool isEnablePerDiem = false.obs;
  RxBool viewCashAdvanceLoader = false.obs;
  RxBool paidAmontIsEditable = true.obs;
  RxBool isVisible = false.obs;
  RxBool perDiem = true.obs;
  bool isEditMode = true;
  bool isEditModePerdiem = false;
  RxBool isInitialized = false.obs;
  MerchantModel? selectedPaidto;
  Language? selectedLanguage;
  Project? selectedProject;
  Project? selectedProjectForView;
  LocationModel? selectedLocation;
  ExpenseCategory? selectedCategory;
  TaxGroupModel? selectedTax;
  PaymentMethodModel? selectedPaidWith;
  Unit? selectedunit;
  File? imageFile;
  String? selectedTimezonevalue;
  String? stringCurrency;
  String? paymentMethodeID;
  var paidWithCashAdvance = RxnString(); // nullable reactive string
  var paymentMethodeIDCashAdvance = RxnString();
  String? expenseID;
  String? leaveID;
  int? recID;
  String selectedCurrencyFinal = '';
  List<String> emails = [];
  RxList<User> userList = <User>[].obs; // User list from API
  Rx<User?> selectedUser = Rx<User?>(null); // Selected user
  TextEditingController userIdController =
      TextEditingController(); // For dropdown
  RxString selectedTemplateId = ''.obs;
  RxList<BoardTemplate> templates = <BoardTemplate>[].obs;
  Rx<BoardTemplate?> selectedTemplate = Rx<BoardTemplate?>(null);

  final List<Color> templateColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFFFF8E1), // Light Yellow
    Color(0xFFFCE4EC), // Light Pink
    Color(0xFFE8EAF6), // Light Indigo
    Color(0xFFFBE9E7), // Light Orange
    Color(0xFFE0F2F1), // Light Teal
  ];
  final Map<String, IconData> templateIcons = {
    'Project Management': Icons.dashboard,
    'Customer Support': Icons.headset,
    'Software Development': Icons.code,
    'Marketing': Icons.campaign,
    'HR': Icons.people,
    'Content': Icons.description,
    'Procurement': Icons.shopping_cart,
    'Custom Board': Icons.grid_view,
  };

  List<Map<String, dynamic>> expenseTrans = [];
  RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;
  String country = '';
  String selectedLocationController = '';
  String contactStateController = '';
  String contactCountryController = 'United States';
  String state = '';
  String paymentMethodID = '';
  String? paidWith;
  DateTime? selectedDate;
  DateTime? selectedDateMileage;
  String selectedCategoryId = '';
  String employmentStatus = 'Active';
  String department = 'ENG';
  String firstLineManager = 'EMP0002';
  String secondLineManager = 'EMP0003';
  String hrHead = 'EMP0001';
  String financialManager = 'EMP0002';
  String dimension1 = 'Corporate-BR01-ENG';
  String dimension2 = 'Corporate-BR01-ENG';
  String selectedCountryName = '';
  // String selectedCountryCode = '';
  String selectedContectCountryName = '';
  String selectedContectCountryCode = '';
  String selectedContectStateName = '';
  late int setTheAllcationAmount = 0;
  CashAdvanceDropDownModel? singleSelectedItem; // For single select mode
  // List<CashAdvanceDropDownModel> multiSelectedItems = [];
  final RxList<CashAdvanceDropDownModel> multiSelectedItems =
      <CashAdvanceDropDownModel>[].obs;
  RxList<PaymentMethod> paymentMethodDropDown = <PaymentMethod>[].obs;

  var unreadCount = 0.obs;
  late int editTotalAmount;
  String? preloadedCashAdvReqIds;
  List<AllocationLine> allocationLines = [];
  List<AccountingSplit> split = [AccountingSplit(percentage: 100.0)];
  var isSameAsPermanent = false;
  MapEntry<String, String>? selectedFormat;
  List<FocusNode> focusNodes = [];
  // var notifications = <NotificationItem>[].obs;
  final ImagePicker _picker = ImagePicker();
  bool rememberMe = false;
  bool passwordVisible = false;
  final RxBool isLoadingLogin = false.obs;
  final RxBool isLoadingviewImage = false.obs;
  final RxBool isGESubmitBTNLoading = false.obs;
  final RxBool isGEPersonalInfoLoading = false.obs;
  final RxBool isLoadingGE1 = false.obs;
  final RxBool isLoadingunprocess = false.obs;
  final RxBool isLoadingGE2 = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool forgotisLoading = false.obs;
  var buttonLoader = false.obs;
  RxBool isImageLoading = false.obs;
  // bool forgotisLoading = false.obs;;
  Rx<UserProfile> signInModel = UserProfile().obs;
  // File? profileImage;
  Rxn<File> profileImage = Rxn<File>();
  var selectedContCountry = Rx<Country?>(null);
  var selectedState = Rx<StateModels?>(null);
  var selectedContState = Rx<StateModels?>(null);
  var selectedCountry = Rx<Country?>(null);
  var statesres = <StateModels>[].obs;
  var statesconst = <StateModels>[].obs;
  var paidTo = <MerchantModel>[].obs;
  var project = <Project>[].obs;
  var taxGroup = <TaxGroupModel>[].obs;
  var location = <LocationModel>[].obs;
  var currency = <Currency>[].obs;

  var unit = <Unit>[].obs;
  List<Map<String, dynamic>> files = [];
  Rx<Locales> selectedLocale = Locales(code: '', name: '').obs;
  Rx<Payment> selectedPayment = Payment(code: '', name: '').obs;
  Rx<PaymentMethodModel> selectedPaymentSetting = PaymentMethodModel(
    paymentMethodName: '',
    paymentMethodId: '',
    reimbursible: false,
  ).obs;
  Rx<Timezone> selectedTimezone = Timezone(code: '', name: '', id: '').obs;
  var countries = <Country>[].obs;
  List<Language> language = [];
  List<Timezone> timezone = [];
  List<Locales> localeData = [];
  List<PaymentMethodModel> selectedPaymentSettinglist = [];
  List<LocationModel> locationDropDown = [];
  List<String> languageList = [];
  List<String> countryNames = [];
  List<String> stateList = [];
  RxList<Currency> currencies = <Currency>[].obs;
  var userName = ''.obs;
  final RxList<ExpenseCategory> expenseCategory = <ExpenseCategory>[].obs;
  List<Payment> payment = [];
  RxList<Map<String, dynamic>> configList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> configListAdvance = <Map<String, dynamic>>[].obs;
  RxList<File> imageFiles = <File>[].obs;
  // GeneralExpense
  bool isReimbursite = false;
  bool isReimbursable = false;
  // bool isBillable = false;
  bool isBillableCreate = false;
  RxBool isReimbursiteCreate = false.obs;
  RxBool isBillable = false.obs;
  RxBool isisBillablereate = false.obs;
  var checkboxValues = <String, bool>{}.obs;
  Color getRandomMildColor() {
    Random random = Random();
    int red = (random.nextInt(128) + 127);
    int green = (random.nextInt(128) + 127);
    int blue = (random.nextInt(128) + 127); // 127–255
    return Color.fromARGB(255, red, green, blue);
  }

  Map<String, String> dateFormatMap = {
    'mm_dd_yyyy': 'MM/dd/yyyy',
    'dd_mm_yyyy': 'dd/MM/yyyy',
    'yyyy_mm_dd': 'yyyy/MM/dd',
    'mm_dd_yyyy_dash': 'MM-dd-yyyy',
    'dd_mm_yyyy_dash': 'dd-MM-yyyy',
    'yyyy_mm_dd_dash': 'yyyy-MM-dd',
    'mm_dd_yyyy_dot': 'MM.dd.yyyy',
    'dd_mm_yyyy_dot': 'dd.MM.yyyy',
    'yyyy_mm_dd_dot': 'yyyy.MM.dd',
    'MM_dd_yyyy': 'MM/dd/yyyy',
    'dd_MM_yyyy': 'dd/MM/yyyy',
    'YYYY_MM_DD': 'yyyy/MM/dd',
    'MM_dd_yyyy_dash_alt': 'MM-dd-yyyy',
    'dd_MM_yyyy_dash_alt': 'dd-MM-yyyy',
    'YYYY_MM_DD_dash_alt': 'yyyy-MM-dd',
    'MM_dd_yyyy_dot_alt': 'MM.dd.yyyy',
    'dd_MM_yyyy_dot_alt': 'dd.MM.yyyy',
    'YYYY_MM_DD_dot_alt': 'yyyy.MM.dd',
  };
  Future signIn(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ThemeColor');
    profileImage.value = null;
    try {
      isLoadingLogin.value = true;
      // showMsg(false);
      //  //  // print("countryCodeController.text${countryCodeController.text}");
      var request = http.Request('POST', Uri.parse(Urls.login));
      request.body = json.encode({
        "Email": emailController.text.trim(),
        "PasswordHash": passwordController.text.trim(),
      });
      request.headers.addAll({'Content-Type': 'application/json'});

      http.StreamedResponse response = await request.send();
      var decodeData = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 201) {
        signInModel.value = UserProfile.fromJson(decodeData);

        await SetSharedPref().setData(
          token: signInModel.value.accessToken ?? "null",
          employeeId: signInModel.value.employeeId ?? "null",
          userId: signInModel.value.userId ?? "null",
          refreshtoken: signInModel.value.refreshToken ?? "null",
          userName: signInModel.value.userName ?? "null",
        );

        while (Params.userToken.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        await saveCredentials();

        employeeIdController.text = decodeData['employeeId'] ?? '';
        middleNameController.text = decodeData['UserName'] ?? '';
        firstNameController.text = decodeData['UserName'] ?? '';
        lastNameController.text = decodeData['UserName'] ?? '';
        personalEmailController.text = decodeData['Email'] ?? '';
        userName.value = decodeData['UserName'] ?? '';

        if (decodeData['UserName'] != null) {
          await prefs.setString('userName', decodeData['UserName']);
        }

        final settings =
            (decodeData["UserSettings"] as List).first as Map<String, dynamic>;
        selectedTimezonevalue = settings["DefaultTimeZoneValue"] ?? '';
        stringCurrency = settings["DefaultCurrency"] ?? '';
        paidWithCashAdvance.value = settings["DefaultPaymentMethodId"] ?? '';

        await prefs.setString(
          "ThemeColor",
          settings["ThemeColor"] ?? "BLUE_THEME",
        );

        final themeNotifier = Provider.of<ThemeNotifier>(
          context,
          listen: false,
        );
        final color = ThemeNotifier.themeColorMap[settings["ThemeColor"]]!;
        themeNotifier.setColor(color, themeKey: settings["ThemeColor"]);

        await prefs.setString(
          "LanguageID",
          settings["DefaultLanguageId"] ?? "LUG-01",
        );
        final localeCode = getLocaleCodeFromId(settings["DefaultLanguageId"]);
        Provider.of<LocaleNotifier>(
          context,
          listen: false,
        ).setLocale(Locale(localeCode));

        // debugPrint("✅ Token set: ${Params.userToken}");
        getProfilePicture();
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        Fluttertoast.showToast(
          msg: "Login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        isLoadingLogin.value = false;
      } else {
        isLoadingLogin.value = false;
        Fluttertoast.showToast(
          msg: decodeData["message"] ?? "Login failed. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      isLoadingLogin.value = false;
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      //  // print("An error occurred: $e");
    }
  }

  Future<List<LeaveAnalytics>> fetchLeaveAnalytics(
  String employeeId,
  String token,
) async {
  try {
    isLoadingLeave.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/leavecodeanalytics?employee_id=$employeeId',
    );

    final response = await ApiService.get(
      url,
     
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);

      final analytics = (decoded['LeaveCodeAnalytics'] as List? ?? [])
          .map<LeaveAnalytics>(
              (e) => LeaveAnalytics.fromJson(e))
          .toList();

      return analytics;
    }
  } catch (e) {
    debugPrint('fetchLeaveAnalytics error: $e');
  } finally {
    isLoadingLeave.value = false;
  }

  return <LeaveAnalytics>[];
}

  Future<void> fetchTemplates() async {
    try {
      isLoadingTemplates.value = true;
      // Replace with your actual API call
      // final response = await http.get(Uri.parse('${Urls.baseURL}/api/v1/kanban/template/customtemplate/template'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   templates.assignAll(data.map((e) => BoardTemplate.fromJson(e)).toList());
      // }

      // Mock data based on your JSON
      final mockData = [
        {
          "AreaId": "TAI-1",
          "AreaName": "Project Management",
          "Description": "Project Management",
          "Icon": "mdi-clipboard-text",
          "RecId": 3290000,
        },
        {
          "AreaId": "TAI-2",
          "AreaName": "Customer Support",
          "Description": "Customer Support",
          "Icon": "mdi-headset",
          "RecId": 3290001,
        },
        {
          "AreaId": "TAI-3",
          "AreaName": "Software Development",
          "Description": "Software Development",
          "Icon": "mdi-laptop",
          "RecId": 3290002,
        },
        {
          "AreaId": "TAI-4",
          "AreaName": "Marketing",
          "Description": "Marketing",
          "Icon": "mdi-bullhorn",
          "RecId": 3290003,
        },
        {
          "AreaId": "TAI-5",
          "AreaName": "HR",
          "Description": "HR",
          "Icon": "mdi-account-group",
          "RecId": 3290004,
        },
        {
          "AreaId": "TAI-6",
          "AreaName": "Content",
          "Description": "Content",
          "Icon": "mdi-file-document-edit",
          "RecId": 3290005,
        },
        {
          "AreaId": "TAI-7",
          "AreaName": "Procurement",
          "Description": "Procurement",
          "Icon": "mdi-cart-arrow-down",
          "RecId": 3290006,
        },
        {
          "AreaId": null,
          "AreaName": "Custom Board",
          "Description": "create your custom board",
          "Icon": "mdi-view-grid",
          "RecId": null,
        },
      ];

      templates.assignAll(
        mockData.map((e) => BoardTemplate.fromJson(e)).toList(),
      );
      print("templatestemplates$templates");
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load templates: $e');
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  // Fetch employees from API

  // Fetch employee groups from API
  Future<void> fetchEmployeeGroups() async {
    try {
      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/masters/employeemgmt/employees/employeegroups'
        '?filter_query=EMPEmployeeGroups.IsActive__eq=true'
        '&page=1&limit=10000'
        '&sort_order=desc'
        '&choosen_fields=GroupId,Description',
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        employeeGroups.assignAll(
          data.map<EmployeeGroup>((e) => EmployeeGroup.fromJson(e)).toList(),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to load employee groups',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load employee groups: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  final shelves = <Shelf>[].obs;
  final Rx<KanbanBoard?> board = Rx<KanbanBoard?>(null);
  final RxList<KanbanBoard> kanbanBoards = <KanbanBoard>[].obs;
  bool get isAllSelected =>
      boardMembers.isNotEmpty && selectedMembers.length == boardMembers.length;
  List<TaskItem> get allTasks {
    if (kanbanBoards.isEmpty) return [];

    return kanbanBoards
        .expand((board) => board.shelfs)
        .expand((shelf) => shelf.tasks)
        .toList();
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      selectedMembers.clear();
    } else {
      selectedMembers.assignAll(boardMembers);
    }
  }

  Future<KanbanBoard?> fetchKanbanBoardAndNavigate(
    BuildContext context,
    String boardId,
    bool readOnly,
  ) async {
    isLoadingGE1.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/boards/boards/joints'
      '?screen_name=KANBoards'
      '&BoardId=$boardId',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        print("Raw JSON response: $decoded");

        final boards = KanbanBoard.fromJson(decoded);

        /// ✅ Append to list
        /// Optional: avoid duplicates
        final index = kanbanBoards.indexWhere(
          (b) => b.boardId == boards.boardId,
        );

        if (index == -1) {
          kanbanBoards.add(boards);
        } else {
          kanbanBoards[index] = boards; // update existing
        }

        isLoadingGE1.value = false;

        /// ✅ Navigate WITHOUT arguments

        return boards;
      } else {
        isLoadingGE1.value = false;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        fetchBoards();
        final message = responseData['detail'];
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
          fontSize: 16.0,
        );

        return null;
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      print("Exception occurred: $e");
      print("Stack trace: $stack");
      return null;
    }
  }

  // Validate form
  bool validateForm() {
    bool isValid = true;

    if (boardNameController.text.isEmpty) {
      showBoardNameError.value = true;
      isValid = false;
    } else {
      showBoardNameError.value = false;
    }

    if (selectedTemplate.value == null) {
      showTemplateError.value = true;
      isValid = false;
    } else {
      showTemplateError.value = false;
    }

    return isValid;
  }

  void setReferenceId(Map<String, dynamic> item) {
    switch (selectedReferenceType.value) {
      case 'Expense':
        referenceIdController.text = item['ExpenseId']?.toString() ?? '';
        break;

      case 'Project':
        referenceIdController.text = item['ProjectId']?.toString() ?? '';
        break;

      case 'Travel':
        referenceIdController.text = item['RequisitionId']?.toString() ?? '';
        break;

      case 'Cash Advance':
        referenceIdController.text = item['RequisitionId']?.toString() ?? '';
        break;

      case 'Payment Proposal':
        referenceIdController.text = item['ProposalId']?.toString() ?? '';
        break;
    }
  }

  Future<void> submitForm(
    BuildContext context, {
    bool isSaveDraft = false,
  }) async {
    if (!validateForm()) {
      Fluttertoast.showToast(
        msg: 'Please fill all required fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setButtonLoading(isSaveDraft ? 'save' : 'submit', true);

    try {
      final boardData = {
        'BoardType': isPublic.value ? 'Public' : 'Private',
        'BoardName': boardNameController.text.trim(),
        'Area': selectedTemplateId.value,
        'Description': descriptionController.text.trim(),
        'ReferenceType': getReferenceType(selectedReferenceType.value),

        /// 🔥 FIXED HERE
        'ReferenceId': referenceIdController.text.trim(),

        'template': selectedTemplate.value?.areaName,
        'templateId': selectedTemplate.value?.recId,
        'userid': selectedEmployees.map((e) => e.id).toList(),
        'groupid': selectedGroups.map((g) => g.id).toList(),
      };

      final response = await ApiService.post(
        Uri.parse('${Urls.baseURL}/api/v1/kanban/boards/boards/boards'),
        body: jsonEncode(boardData),
      );

      if (response.statusCode == 201) {
        resetFormBoard();
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        fetchBoards();
        final message = responseData['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final message = responseData['detail'] ?? 'Internal Server Error';
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
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      setButtonLoading(isSaveDraft ? 'save' : 'submit', false);
    }
  }

  // Reset form
  void resetFormBoard() {
    isPublic.value = false;
    boardNameController.clear();
    descriptionController.clear();
    selectedReferenceType.value = '';
    referenceIdController.clear();
    selectedTemplate.value = null;
    selectedEmployees.clear();
    selectedGroups.clear();
    showBoardNameError.value = false;
    showTemplateError.value = false;
  }

  String getReferenceType(String value) {
    switch (value) {
      case 'Expense':
        return 'Expens';
      case 'Payment Proposal':
        return 'PaymentProposal';
      case 'Cash Advance':
        return 'CashAdvance';
      default:
        return value;
    }
  }

  // Load existing board data for editing
  void loadExistingBoard(Map<String, dynamic> boardData) {
    isPublic.value = boardData['visibility'] == 'Public';
    boardNameController.text = boardData['boardName'] ?? '';
    descriptionController.text = boardData['description'] ?? '';
    selectedReferenceType.value = boardData['referenceType'] ?? '';
    referenceIdController.text = boardData['referenceId'] ?? '';

    // Find and set template
    if (boardData['templateId'] != null) {
      final template = templates.firstWhereOrNull(
        (t) => t.recId == boardData['templateId'],
      );
      selectedTemplate.value = template;
    }

    // Load selected employees and groups (you'll need to fetch these from IDs)
  }

  Future<List<Employee>> fetchEmployees() async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/masters/employeemgmt/employees/employees'
      '?filter_query=EMPEmployees.EmploymentEndDate__gte%3D1765823400000'
      '&page=1'
      '&sort_order=asc'
      '&choosen_fields=FirstName,MiddleName,LastName,EmploymentStartDate,EmploymentEndDate,Id',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded.map<Employee>((e) => Employee.fromJson(e)).toList();
      }
    }

    // if (response.statusCode != 200){
    //   final decoded = jsonDecode(response.body);

    // final List list = decoded['data'] ?? decoded;

    // return list.map((e) => Employee.fromJson(e)).toList();
    // }

    return <Employee>[];
  }

  Future<Map<String, dynamic>> getDeviceDetails() async {
    final token = await getDeviceToken();
    final platform = getPlatform();
    final deviceId = await getDeviceId();
    //  // print("token$token");
    //  // print("platform$platform");
    //  // print("deviceId$deviceId");
    return {
      "DeviceToken": token,
      "Platform": platform,
      "DeviceId": deviceId,
      "ProjectId": "test-4aca4",
      "AppIdentifier":
          "1:681028483669:android:28c51bfa3610b72fee32dc", // from AndroidManifest/Info.plist
    };
  }

  Future<void> logout() async {
    try {
      // Step 1: Get device details
      final details = await getDeviceDetails();

      //  // print("📱 Registering device with details: $details");

      final response = await ApiService.post(
        Uri.parse('${Urls.baseURL}/api/v1/common/pushnotifications/logout'),

        body: jsonEncode(details),
      );

      // Step 3: Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //  // print("✅ Device registered successfully: $data");
      } else {
        //  // print("❌ Failed to register device. Status: ${response.statusCode}");
        //  // print("Response: ${response.body}");
      }
    } catch (e) {
      //  // print("🚨 Error registering device: $e");
    }
  }

  void closeField() {
    clearFormFields();
    resetFieldsMileage();
    clearFormFieldsPerdiem();
  }

  void clearFormFields() {
    // print("Cleared ALL2");
    referenceID.clear();
    justificationnotes.clear();
    categoryController.clear();
    projectDropDowncontroller.clear();
    isAlcohol = false;
    isTobacco = false;
    isDuplicated = false;
    selectedIcon.value = "";
    multiSelectedItems.value = [];
    singleSelectedItem = null;
    cashAdvanceListDropDown.clear();
    amountInController.clear();
    // singleSelectedItem=[] as CashAdvanceDropDownModel?;
    cashAdvanceIds.text = "";
    justificationController.clear();
    amountINRCA1.clear();
    referenceID.clear();
    buttonLoaders.clear();
    firstNameController.clear();
    manualPaidToController.clear();
    paidAmount.clear();
    amountINR.clear();
    unitRate.clear();
    expenseIdController.clear();
    isLoadingGE1.value = false;
    // paymentMethodID = null;
    descriptionController.clear();
    taxAmount.clear();
    selectedPaidWith = null;
    selectedjustification = null;
    selectedPaidto = null;
    selectedunit = null;
    selectedCurrency.value = null;
    selectedTax = null;
    selectedProject = null;
    selectedCategory = null;
    selectedDate = DateTime.now();
    imageFiles.clear();
    finalItems.clear();
    finalItemsSpecific.clear();
    files.clear();
    isManualEntryMerchant = false;
    isUploading.value = false;
    isGESubmitBTNLoading.value = false;
    paymentMethodeID = "";
    paidAmontIsEditable.value = true;
    referenceID.clear();
    paidWith = null;
    isVisible.value = false;
    unitAmount.clear();
    isEnable.value = false;
    isReimbursiteCreate.value = false;
    isBillable.value = false;
    isBillableCreate = false;
    finalItemsCashAdvance = [];
    // print("Cleared ALL ");
  }

  void chancelButton(BuildContext context) {
    clearFormFields();
    Navigator.pop(context);
  }

  ExpenseItemUpdate toExpenseItemUpdateModel() {
    // print("Mais${lineAmount.text}");
    return ExpenseItemUpdate(
      recId: recID,
      expenseCategoryId: categoryController.text ?? '',
      quantity: double.tryParse(quantity.text) ?? 1.00,
      uomId: uomId.text ?? '',
      unitPriceTrans: double.tryParse(unitPriceTrans.text) ?? 0,
      taxAmount: double.tryParse(taxAmount.text) ?? 0,
      taxGroup: taxGroupController.text,
      lineAmountTrans: double.tryParse(lineAmount.text) ?? 0,
      lineAmountReporting: double.tryParse(lineAmountINR.text) ?? 0,
      projectId: projectDropDowncontroller.text,
      description: descriptionController.text,
      isReimbursable: isReimbursable,
      isBillable: isBillableCreate,
      //  "Description": descriptionController.text,
      //       "ExpenseCategoryId": selectedCategoryId,
      //       "ExpenseId": 2079768,
      //       "ExpenseTransCustomFieldValues": [],
      //       "ExpenseTransExpensecategorycustomfieldvalues": [],
      //       "IsReimbursable": isReimbursite,
      //       "LineAmountReporting": amountINR.text,
      //       "LineAmountTrans": quantity.text,
      //       "ProjectId": selectedProject!.code,
      //       "Quantity": quantity.text,
      //       "RecId": 2079785,
      //       "TaxAmount": taxAmount.text,
      //       "TaxGroup": selectedTax!.taxGroupId,
      //       "UnitPriceTrans": 223,
      //       "UomId": "Uom-001"
      accountingDistributions: accountingDistributions.map((controller) {
        final dist = AccountingDistribution(
          recId: controller?.recId,
          transAmount:
              double.tryParse(controller?.transAmount.toString() ?? '') ?? 0.0,
          reportAmount:
              double.tryParse(controller?.reportAmount.toString() ?? '') ?? 0.0,
          allocationFactor: controller?.allocationFactor ?? 0.0,
          dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
          // currency: selectedCurrency.value?.code ?? "IND",
        );

        return dist;
      }).toList(),
    );
  }

  ExpenseItemUpdate toExpenseItemUpdateModels(int? recId) {
    // print("checkRECID$recId");
    return ExpenseItemUpdate(
      recId: recId,
      expenseCategoryId: categoryController.text,
      quantity: double.tryParse(quantity.text) ?? 1.0,
      uomId: uomId.text,
      unitPriceTrans: double.tryParse(unitPriceTrans.text) ?? 0,
      taxAmount: double.tryParse(taxAmount.text) ?? 0,
      taxGroup: taxGroupController.text,
      lineAmountTrans: double.tryParse(lineAmount.text) ?? 0,
      lineAmountReporting: double.tryParse(lineAmountINR.text) ?? 0,
      projectId: projectDropDowncontroller.text,
      description: descriptionController.text,
      isReimbursable: isReimbursable,
      isBillable: isBillableCreate,
      accountingDistributions: accountingDistributions.map((controller) {
        return AccountingDistribution(
          recId: controller?.recId,
          transAmount:
              double.tryParse(
                controller?.transAmount.toStringAsFixed(2) ?? '',
              ) ??
              0.0,
          reportAmount:
              double.tryParse(
                controller?.reportAmount.toStringAsFixed(2) ?? '',
              ) ??
              0.0,
          allocationFactor: controller?.allocationFactor ?? 0.0,
          dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
        );
      }).toList(),
    );
  }

  ExpenseItem toExpenseItemModel() {
    return ExpenseItem(
      expenseCategoryId: selectedCategoryId ?? '',
      quantity: double.tryParse(quantity.text) ?? 1.00,
      uomId: selectedunit?.code ?? '',
      unitPriceTrans: double.tryParse(unitAmount.text) ?? 0,
      taxAmount: double.tryParse(taxAmount.text) ?? 0,
      taxGroup: selectedTax?.taxGroupId,
      lineAmountTrans: double.tryParse(lineAmount.text) ?? 0,
      lineAmountReporting: double.tryParse(lineAmountINR.text) ?? 0,
      projectId: selectedProject?.code,
      description: descriptionController.text,
      isReimbursable: isReimbursiteCreate.value,
      isBillable: isBillable.value,
      //  "Description": descriptionController.text,
      //       "ExpenseCategoryId": selectedCategoryId,
      //       "ExpenseId": 2079768,
      //       "ExpenseTransCustomFieldValues": [],
      //       "ExpenseTransExpensecategorycustomfieldvalues": [],
      //       "IsReimbursable": isReimbursite,
      //       "LineAmountReporting": amountINR.text,
      //       "LineAmountTrans": quantity.text,
      //       "ProjectId": selectedProject!.code,
      //       "Quantity": quantity.text,
      //       "RecId": 2079785,
      //       "TaxAmount": taxAmount.text,
      //       "TaxGroup": selectedTax!.taxGroupId,
      //       "UnitPriceTrans": 223,
      //       "UomId": "Uom-001"
      accountingDistributions: accountingDistributions.map((controller) {
        return AccountingDistribution(
          transAmount:
              double.tryParse(
                controller?.transAmount.toStringAsFixed(2) ?? '',
              ) ??
              0.0,
          reportAmount:
              double.tryParse(
                controller?.reportAmount.toStringAsFixed(2) ?? '',
              ) ??
              0.0,
          allocationFactor: controller?.allocationFactor ?? 0.0,
          dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
        );
      }).toList(),
    );
  }

  void calculateLineAmounts(
    Controller itemController, [
    ExpenseItemUpdate? expenseTran,
  ]) {
    double quantity = double.tryParse(itemController.quantity.text) ?? 0.0;
    double unitPrice =
        double.tryParse(itemController.unitPriceTrans.text) ?? 0.0;
    double unitRates = double.tryParse(unitRate.text) ?? 0.0;

    double lineAmount = quantity * unitPrice;
    double lineAmountInINR = lineAmount * unitRates;

    // update both fields directly
    itemController.lineAmount.text = lineAmount.toStringAsFixed(2);
    itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

    expenseTran = itemController.toExpenseItemUpdateModel();

    // print("Updated Line Amount: ${unitRate.text}");
    // print("Updated Line Amount INR: $lineAmount");
  }

  Future<List<PaidForModel>> fetchPaidForList() async {
    final url = Uri.parse(Urls.dimensionValueDropDown);

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => PaidForModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch Paid For list: ${response.statusCode}');
    }
  }

  Future<void> changeDashboard(Dashboard dashboard) async {
    selectedDashboard(dashboard);
    // await loadDashboardData(dashboard);
  }

  Future<List<Dashboard>> fetchDashboardWidgets() async {
    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/dashboard/dashboard/dashboardandusermappingjoins",
    );

    final response = await ApiService.get(
      url,
      // headers: {
      //   "Content-Type": "application/json",
      //   'Authorization': 'Bearer ${Params.userToken ?? ''}',
      //   'DigiSessionID': digiSessionId.toString(),
      // },
    );

    // print("Status Code: ${response.statusCode}");
    // print("API Body: ${response.body}");

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      return decoded.map((item) => Dashboard.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load widgets: ${response.statusCode}");
    }
  }

  Future<void> sendUploadedFileToServer(BuildContext context, File file) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          // backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  // color: Colors.deepPurpleAccent,
                  strokeWidth: 4,
                ),
                const SizedBox(height: 20),
                Text(
                  '${AppLocalizations.of(context)!.pleaseWait}\n${AppLocalizations.of(context)!.extractingReceipt}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    // color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      final fileName = p.basename(file.path);
      final mimeType = lookupMimeType(file.path) ?? 'image/png';

      final url = Uri.parse(Urls.autoScanExtract);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken ?? ''}',
      };

      final body = jsonEncode({
        'base64Data': base64String,
        'name': fileName,
        'type': mimeType,
      });

      final response = await ApiService.post(url, body: body);

      Navigator.of(context).pop(); // Close the loader

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print(" $responseData");
        // imageFiles.add(file);
        // Navigate with image + response data
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.autoScan,
          arguments: {'imageFile': file, 'apiResponse': responseData},
        );
      } else {
        final body = jsonDecode(response.body);

        final message =
            body['detail']?['message'] ??
            body['message'] ??
            'Something went wrong';
        Navigator.pushNamed(
          context,
          AppRoutes.autoScan,
          arguments: {'imageFile': file, 'apiResponse': body},
        );
        // Fluttertoast.showToast(
        //   msg: message,
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: const Color.fromARGB(255, 250, 1, 1),
        //   textColor: const Color.fromARGB(255, 212, 210, 241),
        //   fontSize: 16.0,
        // );
      }
    } catch (e) {
      //  final body = jsonDecode(response.body);
      // print(e);
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 250, 1, 1),
        textColor: const Color.fromARGB(255, 253, 252, 253),
        fontSize: 16.0,
      );
    }
  }

  Future<bool> pickImageProfile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return false;
    isImageLoading.value = true;
    profileImage.value = File(pickedFile.path);
    try {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Str = base64Encode(bytes);
      final dataUrl = 'data:image/png;base64,$base64Str';
      await uploadProfilePicture(dataUrl);
      return true;
    } catch (e) {
      // print('Error picking/uploading image: $e');
      return false;
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<void> uploadProfilePicture(String base64Image) async {
    final url = Uri.parse('${Urls.updateProfilePicture}${Params.userId}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Params.userToken ?? ''}',
    };
    final body = jsonEncode({'ProfilePicture': base64Image});
    final response = await ApiService.patch(url, body: body);
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final String message =
        responseData['detail']?['message'] ?? 'No message found';
    if (response.statusCode == 200 || response.statusCode == 280) {
      await Future.delayed(const Duration(seconds: 2));
      await getProfilePicture();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 35, 2, 124),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      profileImage.value = null;
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 173, 3, 3),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<List<Country>> fetchCountries() async {
    final url = Uri.parse(Urls.countryList);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        countries.value = List<Country>.from(
          data.map((item) => Country.fromJson(item)),
        );

        countryNames = countries.map((c) => c.name).toList();

        return countries;
      } else {
        // print('Failed to load countries');
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error fetching countries: $e');
      throw Exception('Error fetching countries: $e');
    }
  }

  Future<bool> deleteProfilePicture() async {
    try {
      const defaultProfileBase64 =
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABzUlEQVR42mL8//8/AzSACylCxEZMDAwM7e3twb+5uTkZ4GLiIiZmRkZGdvDw8HBCQkIGdlBQUHhzwMDAwPpPyMjI2Pj48gDsDAwMIAEODg7+Qn5+f2YGBgTmNjY1fAp0JOTg4G5GBgYH8BDEhIS/GYyMjJ+QExMDvxvb29f8BeoGBgbiASUlJZcRgYGAB8o6OjqwmZmZkTwSkoKEqDg4PD//z8/M8DJCSkuJnwQHR0d0mBsbCwHkFJSUtAMjIyPMjJycpE8BQUFF4gICAg/2BgYGHwD5GRkUnJSUlZ8T///9/9BQUFAh4eHj/Pz8+D8VFxc/AYmJiVHBYGBg3wIWFhYH8b179z8GRgYGRsTk5+YfgYGBoZlA8uXLf0NLS0v8f+vr6f+BgYF7g4eHBfwMDw3+QkpLCJQUFBeYyMzN/gYGBAYwAAAwBXmHrXs+3bXgAAAABJRU5ErkJggg==";

      final url = Uri.parse('${Urls.updateProfilePicture}${Params.userId}');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken ?? ''}',
      };

      final body = jsonEncode({
        'ProfilePicture': 'data:image/png;base64,$defaultProfileBase64',
      });

      final response = await ApiService.patch(url, body: body);

      if (response.statusCode == 200 || response.statusCode == 280) {
        final responseData = jsonDecode(response.body);
        profileImage.value = null;

        Fluttertoast.showToast(
          msg: "${responseData['detail']['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 35, 2, 124),
          textColor: const Color.fromARGB(255, 253, 252, 253),
          fontSize: 16.0,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profileImagePath');
        return true;
      } else {
        // print('Delete failed [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      // print('Error deleting profile picture: $e');
      return false;
    }
  }

  Future<void> sendForgetPassword(BuildContext context) async {
    try {
      // print("forgotemailController text: ${forgotemailController.text}");

      forgotisLoading.value = true;

      final response = await ApiService.post(
        Uri.parse('${Urls.forgetPassword}${forgotemailController.text}'),
      );

      final decodeData = jsonDecode(response.body);

      if (response.statusCode == 280) {
        forgotisLoading.value = false;

        Fluttertoast.showToast(
          msg:
              "Reset Password Link Sended Your Mail ID :${{forgotemailController.text}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // You can navigate here if needed
        // Navigator.push(...);
      } else {
        forgotisLoading.value = false;

        Fluttertoast.showToast(
          msg: "${decodeData['detail']['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      forgotisLoading.value = false;

      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // print("An error occurred: $e");
      rethrow;
    }
  }

  Future<void> loadSavedCredentials() async {
    // print("rememberMeLoad$rememberMe");
    final prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('rememberMe') ?? false;
    // print("rememberMeLoad${prefs.getBool('rememberMe')}");

    if (rememberMe) {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  Future<void> saveCredentials() async {
    // print("rememberMeThink$rememberMe");
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
  }

  Future<void> launchURL(String url) async {
    //  // print("urlss$uri");
    final uri = Uri.parse(url);

    // print("urlss$uri");
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ); // or .inAppWebView
  }

  Future<void> fetchLanguageList() async {
    isLoading.value = true;
    final url = Uri.parse(Urls.languageList);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // countryList = List<Country>.from(
        //   data.map((item) => Country.fromJson(item)),
        // );
        final data = jsonDecode(response.body);
        language = List<Language>.from(
          data.map((item) => Language.fromJson(item)),
        );
        isLoading.value = false;
        countryNames = language.map((c) => c.code).toList();
        // print('language to load countries$data');
      } else {
        // print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      // print('Error fetching language: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchTimeZoneList() async {
    // print('timezone to load timezone');
    isLoading.value = true;
    final url = Uri.parse(Urls.timeZoneDropdown);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // countryList = List<Country>.from(
        //   data.map((item) => Country.fromJson(item)),
        // );
        final data = jsonDecode(response.body);
        timezone = List<Timezone>.from(
          data.map((item) => Timezone.fromJson(item)),
        );
        // countryNames = timezone.map((c) => c.name).toList();
        // print('timezone to load timezone$timezone');
        isLoading.value = false;
      } else {
        // print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      // print('Error fetching language: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentMethods() async {
    // print('Fetching payment methods...');
    isLoading.value = true;

    final url = Uri.parse(Urls.paymentMethodId);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Map API data to List<PaymentMethod>
        selectedPaymentSettinglist = List<PaymentMethodModel>.from(
          data.map((item) => PaymentMethodModel.fromJson(item)),
        );
        // data.map((item) => PaymentMethod.fromJson(item)).toList();

        // print('✅ Payment methods loaded: ${paymentMethods.length}');
        isLoading.value = false;
      } else {
        // print('❌ Failed to load payment methods: ${response.body}');
        isLoading.value = false;
      }
    } catch (e) {
      // print('⚠️ Error fetching payment methods: $e');
      isLoading.value = false;
    }
  }

  Future<void> localeDropdown() async {
    final url = Uri.parse(Urls.locale);
    isLoading.value = true;
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        localeData = List<Locales>.from(
          data.map((item) => Locales.fromJson(item)),
        );
        isLoading.value = false;
        // countryNames = localeData.map((c) => c.name).toList();
        //  // print('localeData to load countries$countryNames');
      } else {
        // print('Failed to load countries');
      }
    } catch (e) {
      // print('Error fetching localeData: $e');
    }
  }

  Future<List<StateModels>> fetchState([String? code]) async {
    isFetchingStates.value = true;
    final countryCode = selectedCountry.value!.code ?? "IND";
    final url = Uri.parse(
      '${Urls.stateList}$countryCode&page=1&sort_by=StateName&sort_order=asc&choosen_fields=StateName%2CStateId',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        isLoading.value = true;
        final data = jsonDecode(response.body);

        final List<StateModels> states = List<StateModels>.from(
          data.map((item) => StateModels.fromJson(item)),
        );

        statesres.value = states;
        isFetchingStates.value = false;
        isLoading.value = false;
        return states;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<StateModels>> fetchSecondState() async {
    isFetchingStatesSecond.value = true;
    // print("countryCode$selectedContectCountryCode");
    final countryCode = selectedContectCountryCode ?? "IND";
    final url = Uri.parse(
      '${Urls.stateList}$countryCode&page=1&sort_by=StateName&sort_order=asc&choosen_fields=StateName%2CStateId',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        isLoading.value = true;
        final data = jsonDecode(response.body);

        final List<StateModels> states = List<StateModels>.from(
          data.map((item) => StateModels.fromJson(item)),
        );

        statesconst.value = states;
        isFetchingStatesSecond.value = false;
        isLoading.value = false;
        return states;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      return [];
    }
  }

  Future<void> currencyDropDown() async {
    isLoading.value = true;
    final url = Uri.parse(Urls.correncyDropdown);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;

        currencies.value = data
            .map((e) => Currency.fromJson(e))
            .toSet()
            .toList();

        isLoading.value = false;
        // print('currencies to load countries$currencies');
      } else {
        // print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      // print('Error fetching countries: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenseCategory() async {
    final dateToUse = selectedDate ?? DateTime.now();
    // print("fetchExpenseCategory${selectedProject?.code}");
    // print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    // print("fetchExpenseCategory$fromDate");
    try {
      // Safely construct query parameters
      final queryParams = <String, String>{
        'TransactionDate': fromDate.toStringAsFixed(2),
      };

      if (selectedProject?.code != null && selectedProject!.code.isNotEmpty) {
        queryParams['ProjectId'] = selectedProject!.code;
      }

      final url = Uri.parse(
        Urls.expenseCategory,
      ).replace(queryParameters: queryParams);
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          expenseCategory.value = data
              .map((e) => ExpenseCategory.fromJson(e))
              .toList();
          // print('Expense categories loaded: ${expenseCategory.length}');
        } else {
          // print('Unexpected response format: $data');
        }
      } else {
        // print(
      }
    } catch (e) {
      // print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PayrollsTeams>> fetchPayrollHeaders() async {
    const String url =
        'https://api.digixpense.com/api/v1/payrollregistration/payroll/payrollheader?page=1&sort_order=asc';

    try {
      final response = await ApiService.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If response is list
        if (data is List) {
          return data.map((json) => PayrollsTeams.fromJson(json)).toList();
        }

        // If response has object with key, e.g. `data`
        if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => PayrollsTeams.fromJson(json))
              .toList();
        }

        return [];
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('ExceptionPayrole: $e');
      return [];
    }
  }

  FieldConfig getFieldConfig(String fieldName) {
    final field = configList.firstWhere(
      (f) => f['FieldName'] == fieldName,
      orElse: () => {
        'FieldName': fieldName,
        'IsEnabled': false,
        'IsMandatory': false,
      }, // Default values if not found
    );

    return FieldConfig(
      field['IsEnabled'] == true,
      field['IsMandatory'] == true,
    );
  }

  bool validateAllFields() {
    for (var field in configList) {
      final String name = field['FieldName'];
      final bool enabled = field['IsEnabled'] == true;
      final bool mandatory = field['IsMandatory'] == true;

      // Skip hidden fields
      if (!enabled) continue;

      // If mandatory → must have value
      if (mandatory) {
        final value = getFieldValue(name);

        if (value.trim().isEmpty || value == "null") {
          // showError("$name is required");
          return false;
        }
      }
    }

    return true;
  }

  String getFieldValue(String fieldName) {
    switch (fieldName) {
      case "Project Id":
        return projectDropDowncontroller.text;

      case "Tax Group":
        return taxGroupController.text;

      case "Tax Amount":
        return taxAmount.text;

      case "is Reimbursible":
        return isReimbursable.toString(); // or Yes/No

      case "Refrence Id":
        return referenceID.text;

      case "Is Billable":
        return isBillable.toString();

      case "Location":
        return locationController.text;

      default:
        return "";
    }
  }

  Future<void> configuration() async {
    // isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.geconfigureField);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configList.value = [];
        if (data is List) {
          configList.addAll(data.cast<Map<String, dynamic>>());

          // print('Appended configList: $configList');
          // isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          // print('currencies to load countries$currencies');
        }
      } else {
        // print('Failed to load countries');
        // isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      // print('Error fetching countries: $e');
      // isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<void> leaveconfiguration() async {
    // isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.geconfigureFieldLeave);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configList.value = [];
        if (data is List) {
          configList.addAll(data.cast<Map<String, dynamic>>());

          // print('Appended configList: $configList');
          // isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          // print('currencies to load countries$currencies');
        }
      } else {
        // print('Failed to load countries');
        // isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      // print('Error fetching countries: $e');
      // isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  // MOVE THIS TO GLOBAL SCOPE
  T findOrFallback<T>(List<T> list, bool Function(T) test, T fallback) {
    return list.firstWhere(test, orElse: () => fallback);
  }

  Future<void> getUserPref(BuildContext context) async {
    // isLoading.value = true;
    userPref.value = false;
    isLoadingGE1.value = true;

    final url = Uri.parse(
      '${Urls.getuserPreferencesAPI}${Params.userId}&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode != 200) {
        throw Exception('Status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List || decoded.isEmpty) {
        throw Exception('Empty or invalid prefs');
      }
      // isLoading.value = true;
      final prefs = decoded.first as Map<String, dynamic>;

      // collect values first
      final defaultCurrencyCode = prefs['DefaultCurrency'] as String?;
      final defaultLanguageId = prefs['DefaultLanguageId'] as String?;
      final defaultTimezoneName = prefs['DefaultTimeZone'] as String?;
      final defaultPaymentId = prefs['DefaultPaymentMethodId'] as String?;
      final defaultDateformat = prefs['DefaultDateFormat'] as String?;
      final defaultLocale = prefs['DecimalSeperator'] as String?;
      final defaultReceiptEmailRaw =
          prefs['EmailsForRecieptForwarding'] as String?;
      selectedTimezonevalue = prefs["DefaultTimeZoneValue"] ?? '';
      stringCurrency = prefs["DefaultCurrency"] ?? '';
      paidWithCashAdvance.value = prefs["DefaultPaymentMethodId"] ?? '';
      final themeKey = prefs["ThemeColor"] as String?;

      if (themeKey != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("ThemeColor", themeKey);
        final themeNotifier = Provider.of<ThemeNotifier>(
          context,
          listen: false,
        );
        final color = ThemeNotifier.themeColorMap[themeKey]!;
        themeNotifier.setColor(color, themeKey: themeKey);
      }

      // assign values (defer observable triggers)
      final currency = findOrFallback<Currency>(
        currencies,
        (c) => c.code == defaultCurrencyCode,
        Currency(code: '', name: '', symbol: ''),
      );
      selectedCurrency.value = currency;
      final lang = findOrFallback<Language>(
        language,
        (l) => l.code == defaultLanguageId,
        Language(code: '', name: ''),
      );

      final locale = findOrFallback<Locales>(
        localeData,
        (l) => l.code == defaultLocale,
        Locales(code: '', name: ''),
      );

      final tz = findOrFallback<Timezone>(
        timezone,
        (t) => t.id == defaultTimezoneName,
        Timezone(code: '', name: '', id: ''),
      );

      final pay = findOrFallback<PaymentMethodModel>(
        selectedPaymentSettinglist,
        (p) => p.paymentMethodId == defaultPaymentId,
        PaymentMethodModel(
          paymentMethodId: '',
          paymentMethodName: '',
          reimbursible: false,
        ),
      );

      final format = dateFormatMap.entries.firstWhere(
        (e) => e.value == defaultDateformat,
        orElse: () => const MapEntry('dd_mm_yyyy', 'dd/MM/yyyy'),
      );

      final emailList =
          defaultReceiptEmailRaw
              ?.split(';')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [];
      currencyDropDowncontroller.text = defaultCurrencyCode!;
      currencyDropDowncontroller2.text = defaultCurrencyCode;
      // finally assign to observables after all heavy work done
      selectedCurrency.value = currency;
      selectedLanguage = lang;
      selectedLocale.value = locale;
      selectedTimezone.value = tz;
      selectedPaymentSetting.value = pay;
      prefPaymentMethod.text = pay.paymentMethodId;
      selectedFormat = format;
      emails = emailList;
      fetchExchangeRate();
      // DEBUG
      // print("Timezone: $tz - from: ${currencyDropDowncontroller.text}");
      isLoading.value = false;
      userPref.value = true;
    } catch (e) {
      // print('Error loading prefs: $e');
    } finally {
      isLoading.value = false;
      isLoadingGE1.value = false;
      userPref.value = true;
    }
  }

  Future<void> paymentMethode() async {
    final url = Uri.parse(Urls.defalutPayment);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        payment = data.map((e) => Payment.fromJson(e)).toList();
        isLoading.value = false;
        // print('payment to load countries$payment');
      } else {
        // print('Failed to load countries');
      }
    } catch (e) {
      // print('Error fetching countries: $e');
    }
  }

  Future<void> getProfilePicture() async {
    isImageLoading.value = true;
    final url = Uri.parse('${Urls.getProfilePicture}${Params.userId}');
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final String base64String = response.body;
        final cleaned = base64String.contains(',')
            ? base64String.split(',')[1]
            : base64String;
        final Uint8List bytes = base64Decode(cleaned);
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/profile_image_${Params.userId}_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(bytes);
        imageCache.clear();
        imageCache.clearLiveImages();
        profileImage.value = null;
        profileImage.value = file;
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('profileImagePath', file.path);
        isImageLoading.value = false;
      } else {
        isImageLoading.value = false;
      }
    } catch (e) {
      // print('Error fetching profile picture: $e');
      isImageLoading.value = false;
    }
  }
  // Future<void> loadProfilePictureFromStorage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final filePath = prefs.getString('profile_image_path');

  //   if (filePath != null) {
  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       profileImage.value = file;
  //        // print('✅ Loaded cached profile image from $filePath');
  //     } else {
  //        // print('⚠️ Cached profile image not found on disk');
  //       profileImage.value = null;
  //     }
  //   }
  // }

  Future<void> updateProfileDetails() async {
    // buttonLoader.value = true;
    isGEPersonalInfoLoading.value = true;

    final Map<String, dynamic> requestBody = {
      "ContactNumber": '${countryCodeController.text} ${phoneController.text}',
      "employeeaddress": [
        {
          "AddressId": addressID.text,
          "Country": selectedCountryCode.text,
          "State": statePresentTextController.text,
          "Street": street.text,
          "City": city.text,
          "PostalCode": postalCode.text,
          "Addresspurpose": "Permanent",
        },
        {
          "AddressId": contactaddressID.text,
          "Country": selectedContectCountryCode,
          "State": stateTextController.text,
          "Street": contactStreetController.text,
          "City": contactCityController.text,
          "PostalCode": contactPostalController.text,
          "Addresspurpose": "Contact",
        },
      ],
    };

    try {
      final response = await ApiService.put(
        Uri.parse('${Urls.updateAddressDetails}${Params.userId}'),

        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 280) {
        isGEPersonalInfoLoading.value = false;
        // isUploading.value = false;
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("✅ ");
      } else {
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: "  ${responseData['detail']['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("❌  ${responseData['detail']['message']}");
        isGEPersonalInfoLoading.value = false;
        // isUploading.value = false;
      }
    } catch (e) {
      // print("❌ Exception: $e");
      isGEPersonalInfoLoading.value = false;
    }
  }

  String getLocaleCodeFromId(String id) {
    switch (id) {
      case 'LUG-01':
        return 'en';
      case 'LUG-02':
        return 'ar';
      case 'LUG-03':
        return 'zh';
      case 'LUG-04':
        return 'fr';
      default:
        return 'en'; // fallback
    }
  }

  // UserPref Update APi
  Future<void> userPreferences(BuildContext context) async {
    buttonLoader.value = true;
    // print("selectedTimezone.value.id${selectedTimezonevalue}");
    final Map<String, dynamic> requestBody = {
      "UserId": Params.userId,
      "DefaultCurrency": selectedCurrency.value?.code,
      "DefaultTimeZoneValue": selectedTimezonevalue,
      "DefaultTimeZone": selectedTimezone.value.id,
      "DefaultLanguageId": selectedLanguage?.code,
      "DefaultDateFormat": selectedFormat?.value,
      "EmailsForRecieptForwarding": emails.join(';'),
      "ShowAnalyticsOnList": true,
      "DefaultPaymentMethodId": (prefPaymentMethod.text.isEmpty)
          ? null
          : prefPaymentMethod.text,

      "ThemeDirection": false,
      "ThemeColor": themeColorCode,
      "DecimalSeperator": selectedLocale.value.code,
    };

    try {
      final response = await ApiService.put(
        Uri.parse('${Urls.userPreferencesAPI}${Params.userId}'),

        body: jsonEncode(requestBody),
      );
      // print("requestBody$requestBody");
      if (response.statusCode == 280) {
        buttonLoader.value = false;
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        final localeCode = getLocaleCodeFromId(selectedLanguage!.code);
        Provider.of<LocaleNotifier>(
          context,
          listen: false,
        ).setLocale(Locale(localeCode));
        await prefs.setString("ThemeColor", themeColorCode!);
        final themeNotifier =
            // ignore: use_build_context_synchronously
            Provider.of<ThemeNotifier>(context, listen: false);
        final color = ThemeNotifier.themeColorMap[themeColorCode!]!;
        themeNotifier.setColor(color, themeKey: themeColorCode!);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("❌  ${response.body}");
        buttonLoader.value = false;
      }
    } catch (e) {
      // print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<bool> getPersonalDetails(BuildContext context) async {
    isLoading.value = true;
    isImageLoading.value = true;
    // print('userId: ${Params.userId}');
    try {
      final uri = Uri.parse(
        '${Urls.getPersonalByID}?UserId=${Params.userId}&lockid=${Params.userId}&screen_name=user',
      );
      final response = await ApiService.get(uri);

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        isLoading.value = false;
        // isImageLoading.value = false;

        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
        );
        return false;
      }

      // Decode and map fields
      final List<dynamic> rawList = jsonDecode(response.body);
      if (rawList.isEmpty) {
        Fluttertoast.showToast(
          msg: "No personal data returned.",
          toastLength: Toast.LENGTH_SHORT,
        );
        isLoading.value = false;
        return false;
      }
      isLoading.value = true;
      final Map<String, dynamic> data = rawList.first as Map<String, dynamic>;
      final Map<String, dynamic> emp = data['Employee'] as Map<String, dynamic>;

      // Top‐level / email
      personalEmailController.text = data['Email'] ?? '';

      // Employee details
      employeeIdController.text = emp['EmployeeId'] ?? '';
      firstNameController.text = emp['FirstName'] ?? '';
      middleNameController.text = emp['MiddleName'] ?? '';
      lastNameController.text = emp['LastName'] ?? '';
      if (userName.value.isEmpty) {
        userName.value =
            "${emp['FirstName'] ?? ''} ${emp['MiddleName'] ?? ''} ${emp['LastName'] ?? ''}"
                .trim();
      }

      gender.text = emp['Gender'] ?? '';
      final fullNumber = emp['ContactNumber'] ?? '';
      isLoading.value = true;
      if (fullNumber.length > 4) {
        final parts = fullNumber.trim().split(' ');
        // print("Splitted Parts: $parts");

        if (parts.isNotEmpty) {
          countryCode.value = parts[0]; // Country code
          final phone = parts.sublist(1).join('');
          phoneNumber.value = phone;

          countryCodeController.text = countryCode.value;
          phoneController.text = phoneNumber.value;

          // print("Phone without country code: ${phoneNumber.value}");
        } else {
          countryCode.value = '';
          phoneNumber.value = fullNumber;

          countryCodeController.text = '';
          phoneController.text = phoneNumber.value;
        }
      } else {
        countryCode.value = '';
        phoneNumber.value = fullNumber;

        countryCodeController.text = '';
        phoneController.text = phoneNumber.value;

        // print("Short phone input: ${phoneNumber.value}");
      }

      // Addresses (if you have these controllers)
      final List<Map<String, dynamic>> addresses =
          (data['EMPEmployeeAddresses'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

      final perm = addresses.firstWhere(
        (a) => a['Addresspurpose'] == 'Permanent',
        orElse: () => {},
      );
      final cont = addresses.firstWhere(
        (a) => a['Addresspurpose'] == 'Contact',
        orElse: () => {},
      );
      isLoading.value = true;

      street.text = perm['Street'] ?? '';
      city.text = perm['City'] ?? '';
      state = perm['State'] ?? '';
      statePresentTextController.text = state;
      postalCode.text = perm['PostalCode'] ?? '';
      addressID.text = perm['AddressId'] ?? '';
      selectedCountryCode.text = perm['Country'] ?? '';

      contactStreetController.text = cont['Street'] ?? '';
      contactCityController.text = cont['City'] ?? '';
      contactStateController = cont['State'] ?? '';
      stateTextController.text = contactStateController;
      contactPostalController.text = cont['PostalCode'] ?? '';
      contactaddressID.text = cont['AddressId'] ?? '';
      contactCountryController = cont['Country'] ?? '';

      final bool isSameAsPermanents =
          (perm['Street'] == cont['Street']) &&
          (perm['City'] == cont['City']) &&
          (perm['State'] == cont['State']) &&
          (perm['PostalCode'] == cont['PostalCode']) &&
          (perm['Country'] == cont['Country']);

      isSameAsPermanent = isSameAsPermanents;
      // Delay mapping with Timer to ensure dropdown options are loaded
      Timer(const Duration(seconds: 5), () {
        selectedCountry.value = countries.firstWhere(
          (p) => p.code == selectedCountryCode.text,
          orElse: () => Country(code: '', name: ''),
        );
        isLoading.value = true;
        if (isSameAsPermanents) {
          selectedContCountry.value = countries.firstWhere(
            (p) => p.code == contactCountryController,
            orElse: () => Country(code: '', name: ''),
          );
          countryConstTextController.text = selectedContCountry.value!.name;
        }
        // print(
        //   "electedContCountry.value!.code${selectedContCountry.value?.code}",
        // );
        // selectedContectCountryCode = selectedContCountry.value!.code;
        isLoading.value = false;
        selectedState.value = statesres.firstWhere(
          (p) => p.name == state,
          orElse: () => StateModels(code: '', name: ''),
        );

        selectedContState.value = statesres.firstWhere(
          (p) => p.name == contactStateController,
          orElse: () => StateModels(code: '', name: ''),
        );
        fetchState();
        fetchSecondState();
      });

      // Fluttertoast.showToast(
      //   msg: "Personal details loaded: $selectedCountryCode",
      //   toastLength: Toast.LENGTH_SHORT,
      // );

      isLoading.value = false;

      return true;
    } catch (error) {
      isLoading.value = false;
      // print('Error Occurreds: $error');
      Fluttertoast.showToast(
        msg: "An error occurred: $error",
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }

  Future<List<MerchantModel>> fetchPaidto() async {
    final dateToUse = selectedDate ?? DateTime.now();
    //  // print("fetchPaidto${selectedProject?.code}");
    // print("fetchPaidto$selectedDate");
    isLoading.value = true;
    // print("fromDate$dateToUse");
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    // print("formatted$formatted");
    final fromDate = parseDateToEpoch(formatted);
    // print("fromDate$fromDate");

    isLoadingGE1.value = true;
    isLoadingGE2.value = true;

    final url = Uri.parse('${Urls.getPaidtoDropdown}$fromDate');

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<MerchantModel> states = List<MerchantModel>.from(
          data.map((item) => MerchantModel.fromJson(item)),
        );

        paidTo.value = states;

        isLoadingGE1.value = false;
        isLoadingGE2.value = false;

        return states;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      isLoadingGE2.value = false;

      return [];
    }
  }

  Future<List<LocationModel>> fetchLocation() async {
    // isLoadingGE2.value = true;

    final url = Uri.parse(Urls.locationDropDown);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        locationDropDown = List<LocationModel>.from(
          data.map((item) => LocationModel.fromJson(item)),
        );
        location.value = locationDropDown;

        isLoadingGE2.value = false;

        return locationDropDown;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        // isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      // isLoadingGE2.value = false;

      return [];
    }
  }

  Future<List<Project>> fetchProjectName() async {
    final dateToUse = selectedDate ?? DateTime.now();

    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    final employeeId = Params.employeeId;
    isLoadingGE1.value = true;
    isLoadingGE2.value = true;
    final url = Uri.parse(
      '${Urls.getProjectDropdown}?EmployeeId=$employeeId&TransactionDate=$fromDate',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        // isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<Project> projects = List<Project>.from(
          data.map((item) => Project.fromJson(item)),
        );

        project.value = projects;

        // print("projects$projects");
        isLoadingGE1.value = false;
        isLoadingGE2.value = false;
        return projects;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        isLoadingGE2.value = false;
        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      isLoadingGE1.value = false;
      isLoadingGE2.value = false;
      return [];
    }
  }

  Future<List<TaxGroupModel>> fetchTaxGroup() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.taxGroup);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<TaxGroupModel> taxGroups = List<TaxGroupModel>.from(
          data.map((item) => TaxGroupModel.fromJson(item)),
        );

        taxGroup.value = taxGroups;

        // print("taxGroups$taxGroups");
        isLoadingGE1.value = false;
        return taxGroup;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<Unit>> fetchUnit() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.unitDropdown);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<Unit> units = List<Unit>.from(
          data.map((item) => Unit.fromJson(item)),
        );

        unit.value = units;

        // print("units$units");
        isLoadingGE1.value = false;
        return units;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<Unit>> fetchcurrencySymbol() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.currencySymbol);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<Unit> units = List<Unit>.from(
          data.map((item) => Unit.fromJson(item)),
        );

        unit.value = units;

        // print("units$units");
        isLoadingGE1.value = false;
        return units;
      } else {
        // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Error fetching states: $e');
      return [];
    }
  }

  Future<ExchangeRateResponse?> fetchExchangeRate() async {
    // if (selectedCurrency.value == null) {
    //    // print('selectedCurrency is null');
    //   return null;
    // }
    final dateToUse = selectedDate ?? DateTime.now();
    // print("fetchExpenseCategory${selectedProject?.code}");
    // print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    // print("fetchExpenseCategory$fromDate");
    double? parsedAmount = double.tryParse(paidAmount.text);
    // print("parsedAmount$parsedAmount");
    final String amount = parsedAmount != null
        ? parsedAmount.toInt().toStringAsFixed(2)
        : '0';
    final currencyCode = selectedCurrency.value?.code ?? "INR";

    final url = Uri.parse(
      '${Urls.exchangeRate}/$amount/$currencyCode/$fromDate',
    );

    try {
      final response = await ApiService.get(url);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);
        // print("amountINR: ${quantity.text}");

        if (data['ExchangeRate'] != null && data['BaseUnit'] != null) {
          unitRate.text = data['ExchangeRate'].toStringAsFixed(2);

          final double totalAmount = (data['Total_Amount'] is String)
              ? double.tryParse(data['Total_Amount']) ?? 0
              : (data['Total_Amount']?.toDouble() ?? 0);

          final double rate = data['ExchangeRate']?.toDouble() ?? 1;
          final double totalINR = totalAmount * rate;

          amountINR.text = totalAmount.toStringAsFixed(2);
          exchangeRate = rate;
          unitRate.text = rate.toStringAsFixed(2);
          amountInController.text = totalAmount.toStringAsFixed(2);
          lineAmount.text = totalAmount.toStringAsFixed(2);
          lineAmountINR.text = totalINR.toStringAsFixed(2);
          quantity.text = rate.toStringAsFixed(2);
        }
        for (var itemController in itemizeControllers) {
          calculateLineAmounts(itemController as Controller);
        }
        return ExchangeRateResponse.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        unitRate.clear();
      }
    } catch (e) {
      // print('Error fetching exchange rate: $e');
      return null;
    }
    return null;
  }

  Future<List<PaymentMethodModel>> fetchPaidwith() async {
    isLoadingGE2.value = true;
    final url = Uri.parse(Urls.getPaidwithDropdown);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        paymentMethods.value = (data as List)
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();

        // print(

        isLoadingGE2.value = false;

        return paymentMethods;
      } else {
        // print(

        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<List<UnprocessExpenseModels>> unprocessSpecificEnter(
    int workitemrecid,
  ) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getSpecificUnprocess}RecId=$workitemrecid&lock_id=$workitemrecid&screen_name=MyExpense',
    );
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        unProcessModelList.value = (data as List)
            .map((item) => UnprocessExpenseModels.fromJson(item))
            .toList();
        isLoadingGE1.value = false;
        return unProcessModelList;
      } else {
        isLoadingGE1.value = false;
        // print(

        return [];
      }
    } catch (e) {
      isLoadingGE1.value = false;
      // print('Error fetching Cash Advance: $e');
      return [];
    }
  }

  // Future<List<GESpeficExpense>> unprocessSpecificEnter(int recId) async {
  //   isLoadingGE1.value = true;

  //   final url = Uri.parse('${Urls.getSpecificUnprocess}RecId=$recId');

  //   try {
  //     final request = ApiService.Request('GET', url)
  //       ..headers.addAll({
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${Params.userToken ?? ''}',
  //       });

  //     final streamed = await request.send();
  //     final response = await ApiService.Response.fromStream(streamed);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       specificExpenseList.value = (data as List)
  //           .map((item) => GESpeficExpense.fromJson(item))
  //           .toList();

  //       for (var expense in specificExpenseList) {
  //         expenseIdController.text = expense.expenseId;
  //         receiptDateController.text =
  //             DateFormat('dd/MM/yyyy').format(expense.receiptDate);
  //       }

  //        // print("Expense ID: ${expenseIdController.text}");
  //       isLoadingGE1.value = false;
  //       Navigator.pushNamed(
  //         context,
  //         AppRoutes.viewCashAdvanseReturnForms,
  //         arguments: {
  //           'item': specificCashAdvanceList[0],
  //         },
  //       );
  //     } else {
  //       isLoadingGE1.value = false;
  //        // print(
  //           'Failed to load specific expense. Status code: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e, stack) {
  //     isLoadingGE1.value = false;
  //      // print('Error fetching specific expense: $e');
  //      // print(stack);
  //     return [];
  //   }
  // }
  Future<List<UnprocessExpenseModels>> fetchSecificExpenseItemEmailHub(
    context,
    int recId,
    bool bool,
    String status,
  ) async {
    isLoadingGE1.value = true;
    late Uri url;

    if (status == "unprocessedexpense") {
      url = Uri.parse(
        '${Urls.getSpecificGeneralExpense}/$status?RecId=$recId&lock_id=$recId&screen_name=MyExpense',
      );
    } else {
      url = Uri.parse(
        '${Urls.getSpecificGeneralExpense}/expenseregistration?RecId=$recId&redirection=false',
      );
    }

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        unProcessModelList.value = (data as List)
            .map((item) => UnprocessExpenseModels.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(expense.receiptDate);
        }

        // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.unProcessExpense,
          arguments: {'item': unProcessModelList[0], 'readOnly': bool},
        );

        return unProcessModelList;
      } else {
        isLoadingGE1.value = false;
        // print(

        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      // print('Error fetching specific expense: $e');
      // print(stack);
      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificExpenseItem(
    context,
    int recId, [
    bool? bool,
  ]) async {
    isLoadingGE1.value = true;

    final url = Uri.parse(
      '${Urls.getSpecificGeneralExpense}/expenseregistration?RecId=$recId&lock_id=$recId&screen_name=MyExpense',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(expense.receiptDate);
        }

        // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpense,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );

        return specificExpenseList;
      } else {
        isLoadingGE1.value = false;
        // print(

        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      // print('Error fetching specific expense: $e');
      // print(stack);
      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificCashAdvanceReturn(
    context,
    int recId,
    bool bool,
  ) async {
    isLoadingGE1.value = true;

    final url = Uri.parse(
      '${Urls.getSpecificGeneralExpense}/expenseregistration?RecId=$recId',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(expense.receiptDate);
        }

        // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificCashAdvanseView,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );

        return specificExpenseList;
      } else {
        isLoadingGE1.value = false;
        // print(

        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      // print('Error fetching specific expense: $e');
      // print(stack);
      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificCashAdvanceReturnApproval(
    context,
    int workitemrecid,
    bool bool,
  ) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getSpecificCashAdvanceApproval}workitemrecid=$workitemrecid&lock_id=$workitemrecid&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(expense.receiptDate);
        }
        // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificCashAdvanseView,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        // print(

        return [];
      }
    } catch (e) {
      // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<ExpenseModelMileage> fetchMileageDetails(
    context,
    expenseId,
    readOnly,
  ) async {
    final response = await ApiService.get(
      Uri.parse(
        "${Urls.mileageregistrationview}milageregistration?RecId=$expenseId&lock_id=$expenseId&screen_name=MileageRegistration",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final expense = ExpenseModelMileage.fromJson(data[0]); // Assuming array
      // print("readOnly$readOnly");
      Navigator.pushNamed(
        context,
        AppRoutes.mileageExpensefirst,
        arguments: {'item': expense, 'isReadOnly': readOnly},
      );

      return expense;
    } else {
      throw Exception("Failed to fetch mileage details");
    }
  }

  Future<ExpenseModelMileage> fetchMileageDetailsApproval(
    context,
    expenseId,
    readOnly,
  ) async {
    final response = await ApiService.get(
      Uri.parse(
        "${Urls.mileageregistrationview}detailedapproval?workitemrecid=$expenseId",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final expense = ExpenseModelMileage.fromJson(data[0]); // Assuming array

      Navigator.pushNamed(
        context,
        AppRoutes.mileageExpensefirst,
        arguments: {'item': expense, 'isReadOnly': readOnly},
      );

      return expense;
    } else {
      throw Exception("Failed to fetch mileage details");
    }
  }

  Future<bool> postApprovalAction(
    BuildContext context, {
    required List<int> workitemrecid,
    required String decision,
    required String comment,
    // required String userId,
  }) async {
    print("Its $decision");
    final String status;
    if (decision == "Approve") {
      status = "Approved";
    } else if (decision == "Reject") {
      status = "Rejected";
    } else if (decision == "Escalate") {
      status = "Escalated";
    } else {
      status = decision; // Any other status stays the same
    }

    final Map<String, dynamic> payload = {
      "workitemrecid": workitemrecid,
      "decision": status,
      "comment": comment,
      "usedFor": "MyPendingApproval",
      "userId": status == "Escalated" && userIdController.text.isNotEmpty
          ? userIdController.text
          : null,
    };

    try {
      final response = await ApiService.post(
        Uri.parse(Urls.updateApprovalStatus),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';

      if (response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        clearFormFields();

        // print("✅ Approval Action  ${response.body}");
        return true;
      } else {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      // print("❌ API  $e");
      return false;
    }
  }

  Future<bool> postApprovalActionLeavel(
    BuildContext context, {
    required List<int> workitemrecid,
    required String decision,
    required String comment,
    // required String userId,
  }) async {
    final String status;
    if (decision == "Approve") {
      status = "Approved";
    } else if (decision == "Reject") {
      status = "Rejected";
    } else if (decision == "Escalate") {
      status = "Escalated";
    } else {
      status = decision; // Any other status stays the same
    }

    final Map<String, dynamic> payload = {
      "workitemrecid": workitemrecid,
      "decision": status,
      "comment": comment,
      "usedFor": "MyPendingApproval",
      "userId": status == "Escalated" && userIdController.text.isNotEmpty
          ? userIdController.text
          : null,
    };

    try {
      final response = await ApiService.post(
        Uri.parse(Urls.updateApprovalStatusLeave),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';

      if (response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        resetForm();

        // print("✅ Approval Action  ${response.body}");
        return true;
      } else {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      // print("❌ API  $e");
      return false;
    }
  }

  Future<bool> approvalHubpostApprovalAction(
    BuildContext context, {
    required List<int> workitemrecid,
    required String decision,
    required String comment,
    // required String userId,
  }) async {
    final String status;
    if (decision == "Approve") {
      status = "Approved";
    } else if (decision == "Reject") {
      status = "Rejected";
    } else if (decision == "Escalate") {
      status = "Escalated";
    } else {
      status = decision; // Any other status stays the same
    }

    final Map<String, dynamic> payload = {
      "workitemrecid": workitemrecid,
      "decision": status,
      "comment": comment,
      "usedFor": "MyPendingApproval",
      "userId": status == "Escalated" && userIdController.text.isNotEmpty
          ? userIdController.text
          : null,
    };

    try {
      final response = await ApiService.post(
        Uri.parse(Urls.updateApprovalStatus),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
        clearFormFields();

        // print("✅ Approval Action  ${response.body}");
        return true;
      } else {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      // print("❌ API  $e");
      return false;
    }
  }

  Future<bool> postApprovalActioncashAdvance(
    BuildContext context, {
    required List<int> workitemrecid,
    required String decision,
    required String comment,
    // required String userId,
  }) async {
    final String status;
    if (decision == "Approve") {
      status = "Approved";
    } else if (decision == "Reject") {
      status = "Rejected";
    } else if (decision == "Escalate") {
      status = "Escalated";
    } else {
      status = decision; // Any other status stays the same
    }

    final Map<String, dynamic> payload = {
      "UserId": "",
      "workitemrecid": workitemrecid,
      "decision": status,
      "comment": comment,
      "usedFor": "MyPendingApproval",
      "userId": status == "Escalated" && userIdController.text.isNotEmpty
          ? userIdController.text
          : null,
    };

    try {
      final response = await ApiService.post(
        Uri.parse(Urls.updateApprovalStatusCashAdvance),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        clearFormFields();

        // print("✅ Approval Action  ${response.body}");
        return true;
      } else {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      // print("❌ API  $e");
      return false;
    }
  }

  Future<List<GESpeficExpense>> fetchSecificApprovalExpenseItem(
    context,
    int recId,
  ) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getSpecificGeneralExpenseApproval}workitemrecid=$recId&lock_id=$recId&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        clearFormFields();
        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(expense.receiptDate);
        }
        // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpenseApproval,
          arguments: {'item': specificExpenseList[0]},
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        // print(

        return [];
      }
    } catch (e) {
      // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<void> reviewMileageRegistration(
    context,
    bool action,
    int workitemrecid,
  ) async {
    final expenseTranArray = buildExpenseTrans();
    Map<String, dynamic> expenseTransMap = {};
    for (int i = 0; i < expenseTranArray.length; i++) {
      expenseTransMap[i.toStringAsFixed(2)] = expenseTranArray[i];
    }
    final payload = {
      "workitemrecid": workitemrecid,
      "TotalAmountTrans": calculatedAmountINR,
      "TotalAmountReporting": calculatedAmountINR,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "ReceiptDate": DateTime.now().millisecondsSinceEpoch,
      "Source": "Web",
      "ExchRate": 1,
      "ExpenseId": expenseID ?? "",
      "ExpenseType": "Mileage",
      "RecId": recID,
      "Currency": "INR",
      "MileageRateId": mileageVehicleID.text,
      "VehicleType": selectedVehicleType?.name ?? "Car",
      "FromLocation": tripControllers.first.text,
      "ToLocation": tripControllers.last.text,
      // "RecId": null,
      "CashAdvReqId": cashAdvanceIds.text,
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      "AccountingDistributions": [],
      "ExpenseTrans": expenseTransMap,
      "ProjectId": projectIdController.text,
    };

    final url = Uri.parse(
      '${Urls.reviewUpDate}updateandaccept=$action&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.put(url, body: jsonEncode(payload));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 202 || response.statusCode == 280) {
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        resetFieldsMileage();
        clearFormFieldsPerdiem();
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        clearFormFields();
        final data = jsonDecode(response.body);
        final detail = data['detail'];

        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await approvalJustification(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }

        return;
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: ' $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> reviewGendralExpense(
    context,
    bool action,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    // print("receiptDate$attachmentPayload");
    // print("finalItems${finalItems.length}");

    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "workitemrecid": workitemrecid,
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paidWithController.text ?? '',
      // "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      // "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      "IsReimbursable": isReimbursite,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting": approvalamountINR.text.isNotEmpty
          ? double.tryParse(approvalamountINR.text) ?? 0
          : 0,
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1.0
          : 1.0,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1.0
          : 1.0,
      "Source": "Web",
      "IsBillable": isBillableCreate,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],

      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItemsSpecific.map((item) => item.toJson()).toList(),
    };

    final url = Uri.parse(
      '${Urls.reviewexpenseregistration}updateandaccept=$action&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.put(url, body: jsonEncode(requestBody));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 202 || response.statusCode == 280) {
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        resetFieldsMileage();
        clearFormFields();
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        clearFormFields();
        final data = jsonDecode(response.body);
        final detail = data['detail'];

        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await approvalJustification(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }

        return;
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      // print("Error$e");
      Fluttertoast.showToast(
        msg: ' $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void markInitialized() {
    isInitialized.value = true;
  }

  Future<bool> submitExpenseCancel({required int contextRecId}) async {
    try {
      final Uri url = Uri.parse(
        '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expensecancel'
        '?context_recid=$contextRecId'
        '&screen_name=MyLeave'
        '&functionalentity=LeaveCancellation',
      );

      final response = await ApiService.put(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // debugPrint('✅ Expense cancelled successfully');
        return true;
      } else {
        //  // debugPrint(
        //   '❌ Cancel failed: ${response.statusCode} - ${response.body}',
        // );
        return false;
      }
    } catch (e) {
      // debugPrint('❌ Error in expense cancel API: $e');
      return false;
    }
  }

  Future<void> hubreviewGendralExpense(
    context,
    bool action,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    // print("receiptDate$attachmentPayload");
    // print("finalItems${finalItems.length}");

    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "workitemrecid": workitemrecid,
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paidWithController.text ?? '',
      // "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      // "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      "IsReimbursable": true,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting": approvalamountINR.text.isNotEmpty
          ? double.tryParse(approvalamountINR.text) ?? 0
          : 0,
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1.0
          : 1.0,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1.0
          : 1.0,
      "Source": "Web",
      "IsBillable": false,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],

      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItemsSpecific.map((item) => item.toJson()).toList(),
    };

    final url = Uri.parse(
      '${Urls.reviewexpenseregistration}updateandaccept=$action&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.put(url, body: jsonEncode(requestBody));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 202 || response.statusCode == 280) {
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
        resetFieldsMileage();
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      // print("Error$e");
      Fluttertoast.showToast(
        msg: ' $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<List<ExpenseHistory>> fetchExpenseHistory(int? recId) async {
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.getTrackingDetails}RefRecId__eq%3D$recId&page=1&sort_by=ModifiedBy&sort_order=desc',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpenseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expense history: ${response.statusCode}');
    }
  }

  Future<List<ExpenseHistory>> cashadvanceTracking(int? recId) async {
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.cashadvanceTracking}RefRecId__eq%3D$recId&page=1&page=1&sort_by=CreatedDatetime&sort_order=asc',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpenseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expense history: ${response.statusCode}');
    }
  }

  Future<List<File>> fetchExpenseDocImage([int? recId]) async {
    //  // print("FileChecker");
    isLoadingviewImage.value = true;
    //  // print("FileChecker:");
    imageFiles.clear();
    final response = await ApiService.get(
      Uri.parse('${Urls.getExpensImage}$recId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //  // print("DDDDDD");
      final List<dynamic> attachments = data['DocumentAttachment'] ?? [];
      isLoadingviewImage.value = false;
      for (var attachment in attachments) {
        final String base64Str = attachment['base64Data'];
        final String fileName = attachment['name'] ?? 'image.jpg';

        // Decode base64
        final bytes = base64Decode(base64Str);

        // Get temporary directory
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');

        // Write to file
        await file.writeAsBytes(bytes);
        imageFiles.add(file);
        uploadedImages.add(file);
        isLoadingviewImage.value = false;
      }
      isLoadingviewImage.value = false;
      return imageFiles;
    } else {
      isLoadingviewImage.value = false;
      throw Exception(
        'Failed to load expense document images: ${response.statusCode}',
      );
    }
  }

  Future<String> convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  String getMimeType(File file) {
    return lookupMimeType(file.path) ?? 'application/octet-stream';
  }

  Future<List<Map<String, dynamic>>> buildDocumentAttachment(
    List<File> imageFiles,
  ) async {
    isUploading.value = true;

    final List<Map<String, dynamic>> files = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileBytes = await file.readAsBytes();

        final base64Data = base64Encode(fileBytes);
        final fileName = p.basename(file.path);
        final mimeType = getMimeType(file);

        // ✅ Generate SHA-256 hash as Hashmapkey
        final hash = sha256.convert(fileBytes).toString();
        //  // print("FileChecker: $hash");
        files.add({
          "index": i,
          "name": fileName,
          "type": mimeType,
          "base64Data": base64Data,
          "Hashmapkey": hash,
        });
      }
    } catch (e) {
      //  // print("❌ Error while preparing attachments: $e");
    } finally {
      isUploading.value = false;
    }

    return files;
  }

  void cashAdvanceReturnFinalItem(CashAdvanceRequestHeader expense) {
    final items = expense.cshCashAdvReqTrans.map((trans) {
      final taxGroupValue = (taxGroup.isNotEmpty)
          ? taxGroup.first.taxGroupId
          : '';
      //  // print("🔍 Debug - totalRequestedAmount: ${trans.lineAdvanceRequested}");
      //  // print(
      //   "🔍 Debug - requestedPercentage: ${trans.lineRequestedAdvanceInReporting}",
      // );
      //  // print("&&&&&&11${trans.lineAdvanceRequested}");
      final newItem = CashAdvanceRequestItemize(
        recId: trans.recId,
        cashAdvReqHeader: trans.cashAdvReqHeader,
        description: trans.description,
        quantity: trans.quantity,
        uomId: trans.uomId,
        percentage: trans.percentage,
        unitEstimatedAmount: trans.unitEstimatedAmount,
        lineEstimatedCurrency: trans.lineEstimatedCurrency,
        lineRequestedCurrency: trans.lineRequestedCurrency,
        projectId: trans.projectId,
        location: trans.location,
        lineEstimatedAmount: trans.lineEstimatedAmount,
        lineEstimatedAmountInReporting: trans.lineEstimatedAmountInReporting,
        lineAdvanceRequested: trans.lineAdvanceRequested,
        lineRequestedAdvanceInReporting: trans.lineRequestedAdvanceInReporting,
        lineRequestedExchangerate: trans.estimatedExchangerate,
        lineEstimatedExchangerate: trans.lineEstimatedAmount,
        maxAllowedPercentage: trans.maxAllowedPercentage,
        // baseUnit: trans.baseUnit,
        // baseUnitRequested: trans.baseUnitRequested,
        expenseCategoryId: trans.expenseCategoryId,

        accountingDistributions: accountingDistributions.map((controller) {
          return AccountingDistribution(
            transAmount:
                double.tryParse(
                  controller?.transAmount.toStringAsFixed(2) ?? '',
                ) ??
                0.0,
            reportAmount:
                double.tryParse(
                  controller?.reportAmount.toStringAsFixed(2) ?? '',
                ) ??
                0.0,
            allocationFactor: controller?.allocationFactor ?? 0.0,
            dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
          );
        }).toList(),
      );

      return newItem;
    }).toList();

    finalItemsCashAdvance.addAll(items);
  }

  void addToFinalItems(GESpeficExpense expense) {
    finalItemsSpecific.clear(); // Clear previous items first

    for (var trans in expense.expenseTrans) {
      //    // print("""
      // --- Expense Transaction ---
      // recId: ${trans.recId}
      // expenseId: ${trans.expenseId}
      // expenseCategoryId: ${trans.expenseCategoryId}
      // uomId: ${trans.uomId}
      // quantity: ${trans.quantity}
      // unitPriceTrans: ${trans.unitPriceTrans}
      // taxAmount: ${trans.taxAmount}
      // taxGroup: ${trans.taxGroup}
      // lineAmountTranss: ${trans.lineAmountTrans}
      // lineAmountReporting: ${trans.lineAmountReporting}
      // projectId: ${trans.projectId}
      // description: ${trans.description}
      // isReimbursable: ${trans.isReimbursable}
      // isBillable: ${trans.isBillable}
      // accountingDistributions: ${trans.accountingDistributions?.map((d) => d.toJson()).toList()}
      // ----------------------------
      // """);

      // Preserve the original recId from the transaction
      final int? originalRecId = trans.recId ?? expense.recId;

      final taxGroupValue =
          (trans.taxGroup != null && trans.taxGroup.toString().isNotEmpty)
          ? trans.taxGroup
          : null;

      // Map accounting distributions while preserving their recIds
      final mappedDistributions =
          trans.accountingDistributions?.map((dist) {
            //  // print("Distribution recId: ${dist.recId}");
            return AccountingDistribution(
              transAmount: dist.transAmount,
              reportAmount: dist.reportAmount,
              dimensionValueId: dist.dimensionValueId,
              allocationFactor: dist.allocationFactor,
              recId: dist.recId, // Preserve the distribution recId
            );
          }).toList() ??
          [];

      // Create the expense item update model with preserved recId
      final item = ExpenseItemUpdate(
        recId: originalRecId, // ✅ This preserves the original recId
        expenseId: int.tryParse(expenseID ?? ''), // Parent expense ID
        expenseCategoryId: trans.expenseCategoryId,
        uomId: trans.uomId,
        quantity: trans.quantity,
        unitPriceTrans: trans.unitPriceTrans,
        taxAmount: trans.taxAmount,
        taxGroup: taxGroupValue,
        lineAmountTrans: trans.lineAmountTrans,
        lineAmountReporting: trans.lineAmountReporting,
        projectId: trans.projectId,
        description: trans.description ?? '',
        isReimbursable: trans.isReimbursable,
        isBillable: trans.isBillable,
        accountingDistributions: mappedDistributions,
      );

      //  // print("Final item recId: ${item.recId}");
      finalItemsSpecific.add(item);
    }

    //  // print("Total items in finalItemsSpecific: ${finalItemsSpecific.length}");
    //  // print(
    //   "Items with recId ${finalItemsSpecific.where((item) => item.recId != null).length}",
    // );
    //  // print(
    //   "Items without recId: ${finalItemsSpecific.where((item) => item.recId == null).length}",
    // );
  }

  void addToFinalItemsUnProcess(UnprocessExpenseModels expense) {
    // Clear any previously stored items
    finalItemsSpecific.clear();

    if (expense.expenseTrans.isEmpty) {
      //  // print(
      //   "⚠️ No expense transactions found for Expense ID: ${expense.expenseId}",
      // );
      return;
    }

    for (var trans in expense.expenseTrans) {
      final int? originalRecId = trans.recId ?? expense.recId;

      final taxGroupValue =
          (trans.taxGroup != null && trans.taxGroup!.trim().isNotEmpty)
          ? trans.taxGroup
          : null;

      // Map and preserve AccountingDistribution recIds safely
      final mappedDistributions =
          trans.accountingDistributions
              ?.map(
                (dist) => AccountingDistribution(
                  transAmount: dist.transAmount,
                  reportAmount: dist.reportAmount,
                  dimensionValueId: dist.dimensionValueId,
                  allocationFactor: dist.allocationFactor,
                  recId: dist.recId,
                ),
              )
              .toList() ??
          [];

      // ✅ Create ExpenseItemUpdate object
      final item = ExpenseItemUpdate(
        recId: originalRecId,
        expenseId: int.tryParse(
          expense.expenseId.replaceAll(RegExp(r'[^0-9]'), ''),
        ), // safer parse
        expenseCategoryId: trans.expenseCategoryId,
        uomId: trans.uomId,
        quantity: trans.quantity ?? 0,
        unitPriceTrans: trans.unitPriceTrans ?? 0,
        taxAmount: trans.taxAmount ?? 0,
        taxGroup: taxGroupValue,
        lineAmountTrans: trans.lineAmountTrans ?? 0,
        lineAmountReporting: trans.lineAmountReporting ?? 0,
        projectId: trans.projectId,
        description: trans.description ?? '',
        isReimbursable: trans.isReimbursable,
        isBillable: trans.isBillable,
        accountingDistributions: mappedDistributions,
      );

      finalItemsSpecific.add(item);

      // 🔍 Optional concise debug log
      //        //  // print("""
      // ---------------------------
      // Expense Item Added:
      //   ExpenseId: ${expense.expenseId}
      //   Transaction RecId: ${trans.recId}
      //   Final RecId Used: ${item.recId}
      //   TaxGroup: ${item.taxGroup}
      //   LineAmountTrans: ${item.lineAmountTrans}
      //   Accounting Dist Count: ${mappedDistributions.length}
      // ---------------------------
      // """);
    }

    // ✅ Final Summary
    //  // print("✅ Total Items Added: ${finalItemsSpecific.length}");
    //  // print(
    //   "   Items with RecId: ${finalItemsSpecific.where((e) => e.recId != null).length}",
    // );
    //  // print(
    //   "   Items without RecId: ${finalItemsSpecific.where((e) => e.recId == null).length}",
    // );
  }

  double getTotalLineAmount() {
    double total = 0.0;
    for (var section in itemizeSections) {
      double amount = double.tryParse(section.amount.toStringAsFixed(2)) ?? 0.0;
      total += amount;
    }
    return total;
  }

  Future<void> saveGeneralExpense(context, bool bool, bool? reSubmit) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("receiptDate${unitAmount.text}");
    //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = finalItems.isNotEmpty;
    //  // print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": '',
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWithCashAdvance.value!.isEmpty
          ? null
          : paidWithCashAdvance.value,

      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty
          ? double.tryParse(amountINR.text) ?? 0
          : 0,

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": currencyDropDowncontroller.text,
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "IsAlcohol": isAlcohol,
      "IsDuplicated": isDuplicated,
      "IsForged": false,
      "IsTobacco": isTobacco,
      "Source": "Web",
      // if (!hasValidUnit) "ExpenseCategoryId": categoryController.text.trim(),
      "IsBillable": isBillable.value,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      if (!hasValidUnit) "ExpenseCategoryId": categoryController.text.trim(),
      // if (!hasValidUnit) "ExpenseCategoryId": selectedCategoryId,
      if (!hasValidUnit) 'ProjectId': selectedProject?.code,
      if (!hasValidUnit) 'Description': descriptionController.text,
      if (!hasValidUnit)
        "TaxGroup": !hasValidUnit ? selectedTax?.taxGroupId : null,
      if (!hasValidUnit) "TaxAmount": double.tryParse(taxAmount.text) ?? 0,
      if (!hasValidUnit)
        'AccountingDistributions': accountingDistributions
            .map((e) => e?.toJson())
            .toList(),
      "DocumentAttachment": {"File": attachmentPayload},
      if (hasValidUnit && finalItems.isNotEmpty)
        "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=${reSubmit ?? false}&screen_name=MyExpense',
        ),

        body: jsonEncode(requestBody),
      );
      //  // print("requestBody$requestBody");
      if (response.statusCode == 201) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'] ?? 'Expense created';
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        clearFormFields();
        final data = jsonDecode(response.body);
        final detail = data['detail'];

        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await logJustificationAPI(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }

        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }

        return;
      } else {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  String formatCashAdvanceIds(List<String> ids) {
    return ids.join(';');
  }

  Future<void> logJustificationAPI(
    String justificationNote,
    List<String> justificationReq,
    int refRecId,
    List<dynamic> refRecLineId,
    String policyId,
    String versionNumber,
    context,
  ) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/policymanagement/policyverify/log_justification?functionalentity=ExpenseRequisition',
    );

    final payload = {
      "JustificationNotes": justificationNote,
      "RefRecId": refRecId,
      "JustificationRequirements": justificationReq,
      "TransactionType": "Expense",
      "RefRecLineId": refRecLineId,
      "PolicyId": policyId,
      "VersionNumber": versionNumber,
    };

    try {
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        //  // print("Justification Error: ${response.body}");
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      //  // print("❌ Justification Exception: $e");
    }
  }

  Future<void> approvalJustification(
    String justificationNote,
    List<String> justificationReq,
    int refRecId,
    List<dynamic> refRecLineId,
    String policyId,
    String versionNumber,
    context,
  ) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/policymanagement/policyverify/log_justification?functionalentity=ExpenseRequisition',
    );

    final payload = {
      "JustificationNotes": justificationNote,
      "RefRecId": refRecId,
      "JustificationRequirements": justificationReq,
      "TransactionType": "Expense",
      "RefRecLineId": refRecLineId,
      "PolicyId": policyId,
      "VersionNumber": versionNumber,
    };

    try {
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        //  // print("Justification Error: ${response.body}");
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      //  // print("❌ Justification Exception: $e");
    }
  }

  Future<void> cashAdvanceRequestDashboard(
    String justificationNote,
    List<String> justificationReq,
    int refRecId,
    List<dynamic> refRecLineId,
    String policyId,
    String versionNumber,
    context,
  ) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/policymanagement/policyverify/log_justification?functionalentity=CashAdvanceRequisition',
    );

    final payload = {
      "JustificationNotes": justificationNote,
      "RefRecId": refRecId,
      "JustificationRequirements": justificationReq,
      "TransactionType": "Expense",
      "RefRecLineId": refRecLineId,
      "PolicyId": policyId,
      "VersionNumber": versionNumber,
    };

    try {
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        //  // print("Justification Error: ${response.body}");
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      //  // print("❌ Justification Exception: $e");
    }
  }

  Future<void> createcashAdvanceReturn(
    context,
    bool bool,
    bool? reSubmit,
    int recId,
    String? expenseId,
  ) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("cashAdvanceIds$cashAdvanceIds");
    //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = finalItems.isNotEmpty;
    //  // print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId ?? '',
      if (recId > 0) "RecId": recId,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWithCashAdvance.value,
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty
          ? double.tryParse(amountINR.text) ?? 0
          : 0,

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": currencyDropDowncontroller.text,
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,

      "Source": "Web",
      "IsBillable": isBillable.value,
      "ExpenseType": "CashAdvanceReturn",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      if (!hasValidUnit) "ExpenseCategoryId": selectedCategoryId,
      if (!hasValidUnit) 'ProjectId': selectedProject?.code,
      if (!hasValidUnit) 'Description': descriptionController.text,
      if (!hasValidUnit)
        "TaxGroup": !hasValidUnit ? selectedTax?.taxGroupId : null,
      if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
      if (!hasValidUnit)
        'AccountingDistributions': accountingDistributions
            .map((e) => e?.toJson())
            .toList(),
      "DocumentAttachment": {"File": attachmentPayload},
      if (hasValidUnit && finalItems.isNotEmpty)
        "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.cashadvancerequisitions}&submit=$bool&resubmit=${reSubmit ?? false}&screen_name=MyExpense',
        ),

        body: jsonEncode(requestBody),
      );
      //  // print("requestBody$requestBody");
      if (response.statusCode == 201 || response.statusCode == 280) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'] ?? 'Expense created';
        final recId = data['detail']['RecId'];
        clearFormFields();

        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  CashAdvanceRequestItemizeFornew toCashAdvanceRequestItemize() {
    // Debug prints to verify values
    //  // print("🔍 Debug - selectedCategoryId: $selectedCategoryId");
    //  // print("🔍 Debug - quantity: ${quantity.text}");
    //  // print("🔍 Debug - unitAmount: ${unitAmount.text}");
    //  // print("🔍 Debug - paidAmountCA1: ${paidAmountCA1.text}");
    //  // print("🔍 Debug - totalRequestedAmount: ${totalRequestedAmount.text}");
    //  // print("🔍 Debug - requestedPercentage: ${requestedPercentage.text}");

    return CashAdvanceRequestItemizeFornew(
      expenseCategoryId: selectedCategoryId?.isNotEmpty == true
          ? selectedCategoryId!
          : '',
      quantity: (double.tryParse(quantity.text) ?? 0.0).toInt(),
      uomId: selectedunit?.code ?? '',

      // Fixed: Use unitAmount for unit estimated amount, paidAmountCA1 for line amount
      unitEstimatedAmount: double.tryParse(unitAmount.text) ?? 0.0,
      lineEstimatedAmount: double.tryParse(paidAmountCA1.text) ?? 0.0,
      lineEstimatedAmountInReporting: double.tryParse(amountINRCA1.text) ?? 0.0,

      taxAmount: double.tryParse(taxAmount.text) ?? 0.0,
      taxGroup: selectedTax?.taxGroupId,

      projectId: selectedProject?.code,
      location: selectedLocation?.city,
      description: descriptionController.text,
      isReimbursable: isReimbursite,
      isBillable: isBillableCreate,

      createdBy: Params.userId ?? '',
      createdDatetime: DateTime.now().millisecondsSinceEpoch,

      requestDate: DateTime.now().millisecondsSinceEpoch,
      employeeId: Params.employeeId ?? '',

      // Currency and exchange rates
      estimatedCurrency: currencyDropDowncontrollerCA3.text,
      exchRate: double.tryParse(unitRateCA1.text) ?? 1.0,
      userExchRate: double.tryParse(unitRateCA1.text) ?? 1.0,

      // Requested amounts
      totalRequestedAmount: double.tryParse(totalRequestedAmount.text) ?? 0.0,
      totalRequestedAmountInReporting:
          double.tryParse(amountINRCA2.text) ?? 0.0,

      // Line advance requested amounts
      lineAdvanceRequested: double.tryParse(totalRequestedAmount.text) ?? 0.0,
      lineRequestedAdvanceInReporting:
          double.tryParse(amountINRCA2.text) ?? 0.0,
      lineRequestedCurrency: currencyDropDowncontrollerCA2.text,
      lineRequestedExchangerate: double.tryParse(unitRateCA2.text) ?? 0.0,

      // Percentage values - FIXED: Remove the .toInt() to preserve decimal values
      maxAllowedPercentage: (double.tryParse(requestedPercentage.text) ?? 1)
          .toInt(),
      percentage: (double.tryParse(requestedPercentage.text) ?? 1).toInt(),

      // Accounting Distributions - FIXED null safety
      accountingDistributions: accountingDistributions
          .where((c) => c != null)
          .map((controller) {
            return AccountingDistribution(
              transAmount:
                  double.tryParse(controller!.transAmount.toStringAsFixed(2)) ??
                  0.0,
              reportAmount:
                  double.tryParse(controller.reportAmount.toStringAsFixed(2)) ??
                  0.0,
              allocationFactor: controller.allocationFactor ?? 0.0,
              dimensionValueId: controller.dimensionValueId ?? 'Branch001',
            );
          })
          .toList(),
    );
  }

  Future<void> saveCashAdvance(
    BuildContext context,
    bool submit,
    bool? reSubmit,
    int? recId, [
    String? reqID,
  ]) async {
    try {
      //  // print("cashAdvTransPayload");
      // Format the request date
      final formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      final attachmentPayload = await buildDocumentAttachment(imageFiles);
      //  // print("cashAdvTransPayload2");
      // Build attachments
      // final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload = finalItemsCashAdvanceNew
          .map((item) => item.toJson())
          .toList();
      //  // print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequestDate": requestDate,
        "EmployeeId": Params.employeeId,
        "EmployeeName": userName.value,
        "TotalRequestedAmountInReporting": requestamountINR.text.isNotEmpty
            ? double.tryParse(requestamountINR.text) ?? 0
            : 0,
        "TotalEstimatedAmountInReporting": estimatedamountINR.text.isNotEmpty
            ? double.tryParse(estimatedamountINR.text) ?? 0
            : 0,
        "PrefferedPaymentMethod": paidWithCashAdvance.value,
        "BusinessJustification": justificationController.text,
        "ReferenceId": referenceID.text.trim(),
        "RequisitionId": expenseIdController.text,
        "CashAdvTrans": cashAdvTransPayload,
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": attachmentPayload},
      };

      //  // print("🔗 API Request Body: $requestBody");

      // API call
      final response = await ApiService.post(
        Uri.parse(
          "${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/registercashadvance?functionalentity=CashAdvanceRequisition&submit=$submit&resubmit=${reSubmit ?? false}&screen_name=MyCshAdv",
        ),

        body: jsonEncode(requestBody),
      );

      //  // print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];

        clearFormFields();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);

        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 406) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];

        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.red[800],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[100],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        clearFormFields();
        final data = jsonDecode(response.body);
        final detail = data['detail'];

        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await cashAdvanceRequestDashboard(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      //  // print("❌ API Exception: $e");
      Fluttertoast.showToast(
        msg: "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> saveinEditCashAdvance(
    BuildContext context,
    bool submit,
    bool? reSubmit,
    int? recId, [
    String? reqID,
  ]) async {
    try {
      //  // print("cashAdvTransPayload");
      // Format the request date
      final formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      //  // print("cashAdvTransPayload2");
      // Build attachments
      final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload = finalItemsCashAdvance
          .map((item) => item.toJson())
          .toList();
      //  // print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequisitionId": reqID ?? "",
        "RecId": recId ?? "",
        "RequestDate": requestDate,
        "EmployeeId": Params.employeeId,
        "EmployeeName": userName.value,
        "TotalRequestedAmountInReporting": requestamountINR.text.isNotEmpty
            ? double.tryParse(requestamountINR.text) ?? 0
            : 0,
        "TotalEstimatedAmountInReporting": estimatedamountINR.text.isNotEmpty
            ? double.tryParse(estimatedamountINR.text) ?? 0
            : 0,
        "PrefferedPaymentMethod": paidWithController.text.isEmpty
            ? null
            : paidWithController.text,

        "BusinessJustification": justificationController.text,
        "ReferenceId": referenceID.text.trim(),
        "CashAdvTrans": cashAdvTransPayload,
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": attachmentPayload},
      };

      //  // print("🔗 API Request Body: $requestBody");

      // API call
      final response = await ApiService.post(
        Uri.parse(
          "${Urls.cashadvanceregistration}registercashadvance?functionalentity=CashAdvanceRequisition&submit=$submit&resubmit=${reSubmit ?? false}&screen_name=MyExpense",
        ),

        body: jsonEncode(requestBody),
      );

      //  // print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];

        clearFormFields();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);

        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 406) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];

        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.red[800],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[100],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        clearFormFields();
        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await cashAdvanceRequestDashboard(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        finalItemsCashAdvance = [];
      }
    } catch (e) {
      //  // print("❌ API Exception: $e");
      Fluttertoast.showToast(
        msg: "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      finalItemsCashAdvance = [];
    }
  }

  Future<void> reviewandUpdateCashAdvance(
    BuildContext context,
    bool submit,
    int? recId,
    String? requisitionId, [
    int? reqID,
  ]) async {
    try {
      //  // print("cashAdvTransPayload");
      // Format the request date
      final formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      //  // print("cashAdvTransPayload2");
      // Build attachments
      final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload = finalItemsCashAdvance
          .map((item) => item.toJson())
          .toList();
      //  // print("cashAdvTransPayloadx$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequisitionId": requisitionId ?? "",
        "RecId": recId ?? "",
        "workitemrecid": reqID ?? '',
        "RequestDate": requestDate,
        "EmployeeId": Params.employeeId,
        "EmployeeName": userName.value,
        "TotalRequestedAmountInReporting": requestamountINR.text.isNotEmpty
            ? double.tryParse(requestamountINR.text) ?? 0
            : 0,
        "TotalEstimatedAmountInReporting": estimatedamountINR.text.isNotEmpty
            ? double.tryParse(estimatedamountINR.text) ?? 0
            : 0,
        "PrefferedPaymentMethod": paidWithController.text,
        "BusinessJustification": justificationController.text,
        "ReferenceId": referenceID.text.trim(),
        "CashAdvTrans": cashAdvTransPayload,
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": attachmentPayload},
      };

      //  // print("🔗 API Request Body: $requestBody");

      // API call
      final response = await ApiService.put(
        Uri.parse(
          "${Urls.cashadvanceregistration}reviewcashadvancerequisition?updateandaccept=$submit&screen_name=MyPendingApproval",
        ),

        body: jsonEncode(requestBody),
      );

      //  // print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 202 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];

        clearFormFields();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.approvalDashboardForDashboard);

        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.approvalDashboardForDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        clearFormFields();
        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await logJustificationAPI(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        finalItemsCashAdvance = [];
      }
    } catch (e) {
      //  // print("❌ API Exception: $e");
      Fluttertoast.showToast(
        msg: "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      finalItemsCashAdvance = [];
    }
  }

  Future<void> saveinviewPageGeneralExpense(
    context,
    bool bool,
    bool? reSubmit,
    int recId,
  ) async {
    isLoadingGE1.value = true;
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("receiptDate$attachmentPayload");
    //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
      isLoadingGE1.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
      isLoadingGE1.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "ReferenceNumber": referenceID.text,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": (paymentMethodID == null || paymentMethodID.isEmpty)
          ? null
          : paymentMethodID,
      "TotalAmountTrans": (double.tryParse(paidAmount.text) ?? 0).toInt(),
      "TotalAmountReporting": (double.tryParse(amountINR.text) ?? 0).toInt(),

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "Source": "Web",
      "IsAlcohol": isAlcohol,
      "IsDuplicated": isDuplicated,
      "IsForged": false,
      "IsTobacco": isTobacco,
      "IsBillable": isBillableCreate,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) 'ProjectId': selectedProject?.code ?? '',
      // if (!hasValidUnit) 'Description': descriptionController.text,
      // if (!hasValidUnit) "TaxGroup": selectedTax?.taxGroupId ?? '',
      // if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
      // if (!hasValidUnit)
      //   'AccountingDistributions':
      //       accountingDistributions.map((e) => e?.toJson()).toList(),
      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItemsSpecific.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=$reSubmit&screen_name=MyExpenseSubmit=$bool&Resubmit=$reSubmit&screen_name=MyExpense',
        ),

        body: jsonEncode(requestBody),
      );
      //  // print("requestBody$requestBody");
      if (response.statusCode == 280) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'] ?? 'Expense created';
        final recId = data['detail']['RecId'];
        clearFormFields();
        isLoadingGE1.value = false;
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        clearFormFields();
        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await logJustificationAPI(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }

        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }

        return;
      } else {
        isLoadingGE1.value = false;
        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  Future<void> saveinviewPageGeneralExpenseUnProcess(
    context,
    bool bool,
    bool? reSubmit,
    int recId,
  ) async {
    isLoadingGE1.value = true;
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("receiptDate$attachmentPayload");
    //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
      isLoadingGE1.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
      isLoadingGE1.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "UnprocessedRecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "ReferenceNumber": referenceID.text,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paymentMethodID,
      "TotalAmountTrans": (double.tryParse(paidAmount.text) ?? 0).toInt(),
      "TotalAmountReporting": (double.tryParse(amountINR.text) ?? 0).toInt(),

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "Source": "Web",
      "IsAlcohol": isAlcohol,
      "IsDuplicated": isDuplicated,
      "IsForged": false,
      "IsTobacco": isTobacco,
      "IsBillable": isBillableCreate,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) 'ProjectId': selectedProject?.code ?? '',
      // if (!hasValidUnit) 'Description': descriptionController.text,
      // if (!hasValidUnit) "TaxGroup": selectedTax?.taxGroupId ?? '',
      // if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
      // if (!hasValidUnit)
      //   'AccountingDistributions':
      //       accountingDistributions.map((e) => e?.toJson()).toList(),
      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItemsSpecific.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=$reSubmit&screen_name=MyExpense&unprocessed_recId=$recId',
        ),

        body: jsonEncode(requestBody),
      );
      //  // print("requestBody$requestBody");
      if (response.statusCode == 280 || response.statusCode == 201) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'] ?? 'Expense created';
        final recId = data['detail']['RecId'];
        clearFormFields();
        isLoadingGE1.value = false;
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 430) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        clearFormFields();
        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await logJustificationAPI(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }

        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }

        return;
      } else {
        isLoadingGE1.value = false;
        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  Future<void> editAndUpdateCashAdvance(
    context,
    bool bool,
    bool? reSubmit,
    int recId,
    String expenseId,
  ) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("receiptDate$attachmentPayload");
    //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId ?? '',
      if (recId > 0) "RecId": recId,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWithCashAdvance.value,
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty
          ? double.tryParse(amountINR.text) ?? 0
          : 0,

      // if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency":
          selectedCurrency.value?.code ?? currencyDropDowncontroller.text,
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,

      "Source": "Web",
      "IsBillable": isBillable.value,
      "ExpenseType": "CashAdvanceReturn",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) 'ProjectId': selectedProject?.code ?? '',
      // if (!hasValidUnit) 'Description': descriptionController.text,
      // if (!hasValidUnit) "TaxGroup": selectedTax?.taxGroupId ?? '',
      // if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
      // if (!hasValidUnit)
      //   'AccountingDistributions':
      //       accountingDistributions.map((e) => e?.toJson()).toList(),
      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItemsSpecific.map((item) => item.toJson()).toList(),
    };
    //  // print(jsonEncode(requestBody));
    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.cashadvancerequisitions}&submit=$bool&resubmit=$reSubmit&screen_name=MyExpense',
        ),

        body: jsonEncode(requestBody),
      );
      //  // print("requestBody$requestBody");
      if (response.statusCode == 280) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'] ?? 'Expense created';
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  Future<void> cashadvanceregistrations(
    context,
    bool bool,
    int recId,
    String expenseId,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("receiptDate$attachmentPayload");
    //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId ?? '',
      if (recId > 0) "RecId": recId,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWithCashAdvance.value,
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty
          ? double.tryParse(amountINR.text) ?? 0
          : 0,

      // if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "UserExchRate": unitRate.text.isNotEmpty
          ? double.tryParse(unitRate.text) ?? 1
          : 1,
      "workitemrecid": workitemrecid,
      "Source": "Web",
      "IsBillable": isBillable.value,
      "ExpenseType": "CashAdvanceReturn",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      // if (!hasValidUnit) 'ProjectId': selectedProject?.code ?? '',
      // if (!hasValidUnit) 'Description': descriptionController.text,
      // if (!hasValidUnit) "TaxGroup": selectedTax?.taxGroupId ?? '',
      // if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
      // if (!hasValidUnit)
      //   'AccountingDistributions':
      //       accountingDistributions.map((e) => e?.toJson()).toList(),
      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItemsSpecific.map((item) => item.toJson()).toList(),
    };
    //  // print(jsonEncode(requestBody));
    try {
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.cashadvanceregistrationApi}updateandaccept=$bool&screen_name=MyPendingApproval',
        ),

        body: jsonEncode(requestBody),
      );
      //  // print("requestBody$requestBody");
      if (response.statusCode == 202 || response.statusCode == 280) {
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
        final data = jsonDecode(response.body);

        final message = data['detail']['message'] ?? 'Expense created';
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: " ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }
  // Future<void> saveinviewPageGeneralExpense(context, bool bool) async {
  //   final digiSessionIdNew = const Uuid().v4();

  //   final dateString = receiptDateController.text.trim();
  //   final parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);
  //   final receiptDate = parsedDate.millisecondsSinceEpoch;
  //   final attachmentPayload = await buildDocumentAttachment(imageFiles);
  //   if (!bool) {
  //     isUploading.value = true;
  //   } else {
  //     isGESubmitBTNLoading.value = true;
  //   }
  //   final hasValidUnit = selectedunit?.code != null;
  //    //  // print("hasValidUnit$hasValidUnit${selectedunit?.code}");

  //   final Map<String, dynamic> requestBody = {
  //     "ReceiptDate": receiptDate,
  //     "ExpenseId": "",
  //     "EmployeeId": Params.employeeId,
  //     "EmployeeName": firstNameController.text.trim(),
  //     "MerchantName": isManualEntryMerchant
  //         ? manualPaidToController.text.trim()
  //         : selectedPaidto?.merchantNames ?? '',
  //     "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
  //     "CashAdvReqId": '',
  //     "Location": "", // or locationController.text.trim()
  //     "PaymentMethod": paymentMethodeID ?? paymentMethodID,
  //     "TotalAmountTrans": double.tryParse(paidAmount.text) ?? 0.0,
  //     "TotalAmountReporting": double.tryParse(amountINR.text) ?? 0.0,
  //     'ProjectId': selectedProject?.code ?? projectDropDowncontroller.text,
  //     "IsReimbursable": true,
  //     "Currency": selectedCurrency.value?.code ?? 'INR',
  //     "ExchRate": double.tryParse(unitRate.text) ?? 1.0,
  //     "UserExchRate": double.tryParse(unitRate.text) ?? 1.0,
  //     "Source": "Web",
  //     "IsBillable": false,
  //     "ExpenseType": "General Expenses",
  //     "ExpenseHeaderCustomFieldValues": [],
  //     "ExpenseHeaderExpensecategorycustomfieldvalues": [],
  //     if (!hasValidUnit) "ExpenseCategoryId": "Bus",
  //     if (!hasValidUnit)
  //       'ProjectId': selectedProject?.code ?? projectDropDowncontroller.text,
  //     if (!hasValidUnit) 'Description': descriptionController.text,
  //     if (!hasValidUnit)
  //       "TaxGroup": selectedTax?.taxGroupId ?? taxGroupController.text,
  //     if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
  //     // 'AccountingDistributions':
  //     //     accountingDistributions.map((e) => e.toJson()).toList(),
  //     "DocumentAttachment": {
  //       "File": attachmentPayload,
  //     },
  //     if (hasValidUnit && finalItems.isNotEmpty)
  //       "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
  //   };

  //   try {
  //     final response = await ApiService.post(
  //       Uri.parse(
  //           '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=false&screen_name=MyExpense'),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer ${Params.userToken}",
  //         'DigiSessionID': digiSessionIdNew,
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //      //  // print("requestBody$requestBody");
  //     if (response.statusCode == 201) {
  //       if (!bool) {
  //         isUploading.value = false;
  //       } else {
  //         isGESubmitBTNLoading.value = false;
  //       }
  //       final data = jsonDecode(response.body);

  //       final message = data['detail']['message'] ?? 'Expense created';
  //       final recId = data['detail']['RecId'];
  //       Navigator.pushNamed(context, AppRoutes.generalExpense);
  //       Fluttertoast.showToast(
  //         msg: "$message ",
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: " ${response.body}",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         backgroundColor: const Color.fromARGB(255, 250, 1, 1),
  //         textColor: const Color.fromARGB(255, 212, 210, 241),
  //         fontSize: 16.0,
  //       );
  //        //  // print("❌  ${response.body}");
  //       if (!bool) {
  //         isUploading.value = false;
  //       } else {
  //         isGESubmitBTNLoading.value = false;
  //       }
  //     }
  //   } catch (e) {
  //      //  // print("❌ Exception: $e");

  //     if (!bool) {
  //       isUploading.value = false;
  //     } else {
  //       isGESubmitBTNLoading.value = false;
  //     }
  //   }
  // }

  void recalculateAmounts() {
    final qty = double.tryParse(quantity.text) ?? 0.0;
    final unit = double.tryParse(unitAmount.text) ?? 0.0;

    final calculatedLineAmount = qty * unit;
    //  // print("calculatedLineAmount$qty,$unit 2233");
    lineAmount.text = calculatedLineAmount.toStringAsFixed(2);
    lineAmountINR.text = calculatedLineAmount.toStringAsFixed(2);
  }

  Future<List<BoardModel>> fetchBoards() async {
    isLoadingGE1.value = true;
    final url = Uri.parse('${Urls.baseURL}/api/v1/kanban/boards/boards/boards');

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));

        boardList.value = (data)
            .map((item) => BoardModel.fromJson(item))
            .toList();
        isLoadingGE1.value = false;
        return boardList;
      } else {
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<List<GExpense>> fetchGetallGExpense() async {
    isLoadingGE1.value = true;

    final String baseUrl = '${Urls.getallGeneralExpense}${Params.userId}';
    const String commonParams = '&page=1&sort_order=asc';

    String? apiStatus;
    switch (selectedStatus) {
      case 'Un Reported':
        apiStatus = 'Created';
        break;
      case 'In Process':
        apiStatus = 'Pending';
        break;
      case 'Approved':
        apiStatus = 'Approved';
        break;
      case 'Cancelled':
      case 'Rejected':
        apiStatus = selectedStatus;
        break;
      case 'All':
        apiStatus = null;
        break;
    }

    final String fullUrl = apiStatus != null
        ? '$baseUrl%26EXPExpenseHeader.ApprovalStatus__eq%3D$apiStatus$commonParams'
        : '$baseUrl$commonParams';

    final url = Uri.parse(fullUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        getAllListGExpense.value = (data as List)
            .map((item) => GExpense.fromJson(item))
            .toList();

        isLoadingGE1.value = false;
        //  // print("Fetched Expenses: $getAllListGExpense");

        return getAllListGExpense;
      } else {
        //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<void> fetchLeaveRequisitions() async {
    isLoadingLeaves.value = true;

    const String baseUrl =
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/leaverequisitions';

    String? apiStatus;
    switch (selectedStatus) {
      case 'Un Reported':
        apiStatus = 'Created';
        break;
      case 'In Process':
        apiStatus = 'Pending';
        break;
      case 'Approved':
        apiStatus = 'Approved';
        break;
      case 'Cancelled':
      case 'Rejected':
        apiStatus = selectedStatus;
        break;
      case 'All':
        apiStatus = null;
        break;
    }

    final filterQuery =
        'LVRLeaveHeader.CreatedBy__eq%3D${Params.userId}'
        '${apiStatus != null ? '%26LVRLeaveHeader.ApprovalStatus__eq%3D$apiStatus' : ''}';

    final url = Uri.parse(
      '$baseUrl?filter_query=$filterQuery&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          leaveRequisitionList.assignAll(
            decoded.map((e) => LeaveRequisition.fromJson(e)).toList(),
          );
        } else {
          leaveRequisitionList.clear();
        }
      } else {
        leaveRequisitionList.clear();
      }
    } catch (e) {
      //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchTimeSheetData() async {
    isLoadingLeaves.value = true;

    const String baseUrl =
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timesheetheader';

    String? apiStatus;
    switch (selectedStatus) {
      case 'Un Reported':
        apiStatus = 'Created';
        break;
      case 'In Process':
        apiStatus = 'Pending';
        break;
      case 'Approved':
        apiStatus = 'Approved';
        break;
      case 'Cancelled':
      case 'Rejected':
        apiStatus = selectedStatus;
        break;
      case 'All':
        apiStatus = null;
        break;
    }

    final filterQuery =
        'TSRTimesheetHeader.CreatedBy__eq%3D${Params.userId}'
        '${apiStatus != null ? '%26TSRTimesheetHeader.ApprovalStatus__eq%3D$apiStatus' : ''}';

    final url = Uri.parse(
      '$baseUrl?filter_query=$filterQuery&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          leaveRequisitionList.assignAll(
            decoded.map((e) => LeaveRequisition.fromJson(e)).toList(),
          );
        } else {
          leaveRequisitionList.clear();
        }
      } else {
        leaveRequisitionList.clear();
      }
    } catch (e) {
      //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchMyteamsLeaveRequisitions() async {
    isLoadingLeaves.value = true;

    const String baseUrl =
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/myteamleaves';

    String? apiStatus;
    switch (selectedStatus) {
      case 'In Process':
        apiStatus = 'Pending';
        break;
      case 'All':
        apiStatus = null;
        break;
    }

    final filterQuery =
        'LVRLeaveHeader.CreatedBy__eq%3D${Params.userId}'
        '${apiStatus != null ? '%26LVRLeaveHeader.ApprovalStatus__eq%3D$apiStatus' : ''}';

    final url = Uri.parse(
      '$baseUrl?filter_query=$filterQuery&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          myTeamleaveRequisitionList.assignAll(
            decoded.map((e) => LeaveRequisition.fromJson(e)).toList(),
          );
        } else {
          myTeamleaveRequisitionList.clear();
        }
      } else {
        myTeamleaveRequisitionList.clear();
      }
    } catch (e) {
      //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchMyteamsLeaveCancellation() async {
    isLoadingLeaves.value = true;

    const String baseUrl =
        '${Urls.baseURL}/api/v1/leavemanagement/leavecancellation/leavecancellations';

    String? apiStatus;
    switch (selectedStatus) {
      case 'In Process':
        apiStatus = 'Pending';
        break;
      case 'All':
        apiStatus = null;
        break;
    }

    final filterQuery =
        'LVRLeaveCancellationHeader.CreatedBy__eq%3D${Params.userId}';

    final url = Uri.parse(
      '$baseUrl?filter_query=$filterQuery&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          myCancelationleaveRequisitionList.assignAll(
            decoded.map((e) => LeaveCancellationModel.fromJson(e)).toList(),
          );
        } else {
          myCancelationleaveRequisitionList.clear();
        }
      } else {
        myCancelationleaveRequisitionList.clear();
      }
    } catch (e) {
      //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> pendingApprovalLeaveRequisitions() async {
    isLoadingLeaves.value = true;

    const String baseUrl =
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/pendingapprovals?';

    final url = Uri.parse(
      '$baseUrl?filter_query=LVRLeaveHeader.ApprovalStatus__eq%3DPending&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          pendingApproval.assignAll(
            decoded.map((e) => LeaveCancellationModel.fromJson(e)).toList(),
          );
        } else {
          pendingApproval.clear();
        }
      } else {
        pendingApproval.clear();
      }
    } catch (e) {
      //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<List<GExpense>> fetchUnprocessExpense() async {
    isLoadingunprocess.value = true;
    final url = Uri.parse(
      '${Urls.unProcessedList}${Params.userId}&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        getAllListGExpense.value = (data as List)
            .map((item) => GExpense.fromJson(item))
            .toList();

        isLoadingunprocess.value = false;
        //  // print("Fetched Expenses: $getAllListGExpense");

        return getAllListGExpense;
      } else {
        //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingunprocess.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching expenses: $e');
      isLoadingunprocess.value = false;
      return [];
    }
  }

  Future<List<GExpense>> fetchAllmyTeamsExpens() async {
    isLoadingGE1.value = true;

    const String baseBaseUrl = Urls.getallMyteamsGeneralExpense;
    const String commonParams = "&page=1&sort_order=asc";

    String? filterStatus;
    switch (selectedStatusmyteam) {
      case 'In Process':
        filterStatus = 'Pending';
        break;
      case 'All':
        filterStatus = null;
        break;
      // Add more cases as needed
    }

    // Dynamically build the filter_query
    String filterQuery = '';
    if (filterStatus != null) {
      final encodedQuery = Uri.encodeComponent(
        "EXPExpenseHeader.ApprovalStatus__eq=$filterStatus",
      );
      filterQuery = "filter_query=$encodedQuery";
    }

    final String fullUrl = "$baseBaseUrl$filterQuery$commonParams";
    final url = Uri.parse(fullUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        getAllListGExpense.value = (data as List)
            .map((item) => GExpense.fromJson(item))
            .toList();

        //  // print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return getAllListGExpense;
      } else {
        //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<List<CashAdvanceRequestHeader>> fetchAllmyTeamsCashAdvanse() async {
    isLoadingGE1.value = true;
    getAllListGExpense.clear();
    const String baseBaseUrl = Urls.getallMyteamsCashAdvanseRequest;
    const String commonParams = "&page=1&sort_order=asc";

    String? filterStatus;
    switch (selectedStatusmyteamCashAdvance) {
      case 'In Process':
        filterStatus = 'Pending';
        break;
      case 'All':
        filterStatus = null;
        break;
      // Add more cases as needed
    }

    // Dynamically build the filter_query
    String filterQuery = '';
    if (filterStatus != null) {
      final encodedQuery = Uri.encodeComponent(
        "CSHCashAdvReqHeader.ApprovalStatus__eq=$filterStatus",
      );
      filterQuery = "filter_query=$encodedQuery";
    }

    final String fullUrl = "$baseBaseUrl$filterQuery$commonParams";
    final url = Uri.parse(fullUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        getAllListCashAdvanseMyteams.value = (data as List)
            .map((item) => CashAdvanceRequestHeader.fromJson(item))
            .toList();

        //  // print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return getAllListCashAdvanseMyteams;
      } else {
        //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<List<ExpenseModel>> fetchPendingApprovals() async {
    isLoadingGE1.value = true;

    try {
      final response = await ApiService.get(Uri.parse(Urls.pendingApprovals));
      // final streamed = await request.send();
      // final response = await ApiService.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        pendingApprovals.clear();
        pendingApprovals.value = (data)
            .map((item) => ExpenseModel.fromJson(item))
            .toList();

        isLoadingGE1.value = false;
        //  // print("Fetched pendingApprovals: $pendingApprovals");

        return pendingApprovals;
      } else {
        //  // print(

        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching pendingApprovals: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<List<ExpenseModel>> fetchExpenses(String token) async {
    // const String url = 'https://yourapi.com/expenses'; // Replace with your API URL

    final response = await ApiService.get(Uri.parse(Urls.pendingApprovals));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<PaymentMethodModel>> fetchPerDiemPrefillDatas() async {
    isLoadingGE1.value = true;

    final url = Uri.parse(Urls.getPaidwithDropdown);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isLoadingGE1.value = false;

        paymentMethods.value = (data as List)
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();

        //  // print(
        //   "paymentMethods: ${paymentMethods.map((e) => e.paymentMethodName).toList()}",
        // );

        return paymentMethods;
      } else {
        //  // print(
        //   'Failed to load payment methods. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      //  // print('Error fetching payment methods: $e');
      return [];
    }
  }

  int parseDateToEpoch(String formattedDate) {
    final date = DateFormat('dd-MMM-yyyy').parse(formattedDate);
    return date.millisecondsSinceEpoch;
  }

  String formattedDate(int millis) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<ExchangeRateResponse?> fetchExchangeRatePerdiem() async {
    // if (selectedCurrency.value == null) {
    //    //  // print('selectedCurrency is null');
    //   return null;
    // }

    final toDate = parseDateToEpoch(toDateController.text);
    final url = Uri.parse(
      '${Urls.exchangeRate}/${exchangeamountInController.text}/${exchangeCurrencyCode.text}/$toDate',
    );

    try {
      final response = await ApiService.get(url);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);
        //  // print("amountINR: ${quantity.text}");

        if (data['ExchangeRate'] != null && data['BaseUnit'] != null) {
          unitRate.text = data['ExchangeRate'].toStringAsFixed(2);

          final double totalAmount = (data['Total_Amount'] is String)
              ? double.tryParse(data['Total_Amount']) ?? 0
              : (data['Total_Amount']?.toDouble() ?? 0);

          final double rate = data['ExchangeRate']?.toDouble() ?? 1;
          final double totalINR = totalAmount * rate;

          amountINR.text = totalINR.toStringAsFixed(2);
          exchangeRate = rate;
          unitRate.text = rate.toStringAsFixed(2);
          amountInController.text = totalAmount.toStringAsFixed(2);
          lineAmount.text = totalAmount.toStringAsFixed(2);
          lineAmountINR.text = totalINR.toStringAsFixed(2);
          quantity.text = rate.toStringAsFixed(2);
        }

        return ExchangeRateResponse.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        unitRate.clear();
      }
    } catch (e) {
      //  // print('Error fetching exchange rate: $e');
      return null;
    }
    return null;
  }

  Future<List<AllocationLine>> fetchPerDiemRates() async {
    //  // print('its Callies');
    isLoadingGE1.value = true;
    try {
      final fromDate = parseDateToEpoch(fromDateController.text);
      final toDate = parseDateToEpoch(toDateController.text);
      final location = (selectedLocationController ?? '').trim();
      final employeeId = Params.employeeId;
      final token = Params.userToken ?? '';

      // Guard against empty location

      final url = Uri.parse(
        '${Urls.perDiemFetchRate}$fromDate&Todate=$toDate&Location=$location&EmployeeId=$employeeId',
      );
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final parsedResponse = PerDiemResponseModel.fromJson(body);
        exchangeCurrencyCode.text = parsedResponse.currencyCode;
        perdiemResponse.value = parsedResponse;
        perDiem.value = true;
        allocationLines = parsedResponse.allocationLines ?? [];
        daysController.text = parsedResponse.totalDays.toStringAsFixed(2);
        exchangeamountInController.text = parsedResponse.totalAmountTrans
            .toStringAsFixed(2);
        perDiemController.text = parsedResponse.perdiemId.toString();

        isLoadingGE1.value = false;
        return allocationLines;
      } else {
        final body = jsonDecode(response.body);

        final message =
            body['detail']?['message'] ??
            body['message'] ??
            'Something went wrong';

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      isLoadingGE1.value = false;
      return [];
    }
  }

  void clearFormFieldsPerdiem() {
    cashAdvanceListDropDown.clear();
    // Clear text controllers
    cashAdvanceIds.clear();
    multiSelectedItems.clear();
    buttonLoaders.clear();
    cashAdvanceIds.text = "";
    isEditModePerdiem = false;
    isEditMode = true;
    setTheAllcationAmount = 0;
    amountInController.clear();
    firstNameController.clear();
    purposeController.clear();
    fromDateController.clear();
    toDateController.clear();
    isManualEntryMerchant = false;
    projectIdController.clear();
    locationController.clear();
    daysController.clear();
    exchangeamountInController.clear();
    perDiemController.clear();
    locationController.clear();
    mileageVehicleID.clear();
    mileageVehicleName.clear();
    totalDistanceKm = 0;
    calculatedAmountINR = 0;
    // isRoundTrip = false;
    // projectIdController.clear();  RxString selectedIcon = ''.obs;
    isRoundTrip = false;
    // Reset dropdowns or selections
    selectedProject = null;
    // tripControllers.clear();
    selectedVehicleType = null;
    selectedLocation = null;
    selectedLocation = null;
    split.clear();
    update();
    // Reset allocation and accounting distribution data
    allocationLines = [];
    accountingDistributions = [];

    // Optional: Reset any state-managed variables like totals
    // totalAmount.value = 0.0; // Example, if using GetX
    // isLoading.value = false;

    //  // print("All form fields cleared.");
  }

  Future<void> deleteExpense(int recId) async {
    final String token = Params.userToken ?? ''; // get your bearer token safely

    final Uri url = Uri.parse(
      '${Urls.deleteExpense}$recId&screen_name=MyExpense',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchGetallGExpense();
        //  // print('✅ Expense deleted successfully');
      } else {
        //  // print('❌ Failed to delete expense: ${response.statusCode}');
        //  // print('Response body: ${response.body}');
      }
    } catch (e) {
      //  // print('❌ Error deleting expense: $e');
    }
  }

  Future<void> deleteLeave(int recId) async {
    final String token = Params.userToken ?? ''; // get your bearer token safely

    final Uri url = Uri.parse(
      '${Urls.deleteLeave}$recId&screen_name=LVRLeaveHeader',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchLeaveAnalytics(Params.employeeId, Params.userToken);
        //  // print('✅ Expense deleted successfully');
      } else {
        //  // print('❌ Failed to delete expense: ${response.statusCode}');
        //  // print('Response body: ${response.body}');
      }
    } catch (e) {
      //  // print('❌ Error deleting expense: $e');
    }
  }

  Future<bool> deleteExpenseUnprocess(int recId) async {
    final String token = Params.userToken ?? ''; // Safely get your bearer token

    final Uri url = Uri.parse(
      '${Urls.deleteExpenseUnprocess}$recId&screen_name=MyExpense',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = jsonDecode(response.body);
        await fetchUnprocessExpense(); // Be sure to await for UI sync
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 22, 87, 3),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 59, 250, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );

        return false;
      }
    } catch (e) {
      //  // print('❌ Error deleting expense: $e');
      return false;
    }
  }

  Future<void> updatePerDiemDetails(
    context,
    bool bool,
    bool resubmit,
    int? recIds, [
    String? expenseID,
  ]) async {
    Map<String, dynamic> buildPayload() {
      return {
        "ExpenseId": expenseID ?? '',
        // ignore: prefer_null_aware_operators
        "ProjectId": selectedProject != null ? selectedProject?.code : null,
        "TotalAmountTrans": exchangeamountInController.text.isNotEmpty
            ? double.parse(exchangeamountInController.text).round()
            : 0,
        "TotalAmountReporting": amountInController.text.isNotEmpty
            ? double.parse(amountInController.text).round()
            : 0,
        "EmployeeId": Params.employeeId ?? '',
        "EmployeeName": userName.value,
        "ReceiptDate": toDateController.text.isNotEmpty
            ? parseDateToEpoch(toDateController.text)
            : null,
        "Currency": selectedCurrency.value?.code ?? 'INR',
        "Description": purposeController.text.isNotEmpty
            ? purposeController.text
            : '',
        "Source": "Web",
        "ExchRate": 1,
        if (recIds != null) "RecId": recIds,
        "ExpenseType": "PerDiem",
        "Location": selectedLocation?.location ?? '',
        "CashAdvReqId": cashAdvanceIds.text,
        "FromDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "ToDate": toDateController.text.isNotEmpty
            ? parseDateToEpoch(toDateController.text)
            : null,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": accountingDistributions.isNotEmpty
            ? accountingDistributions.map((e) => e?.toJson()).toList()
            : [],
        "AllocationLines": allocationLines.isNotEmpty
            ? allocationLines.map((e) => e.toJson()).toList()
            : [],
      };
    }

    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.perDiemRegistration}&Submit=$bool&Resubmit=$resubmit&screen_name=PerDiemRegistration',
        ),

        body: jsonEncode(buildPayload()),
      );

      if (response.statusCode == 201 || response.statusCode == 280) {
        buttonLoader.value = false;
        isUploading.value = false;
        clearFormFieldsPerdiem();
        fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  //  // print("✅ ");
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFieldsPerdiem();
        fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        clearFormFieldsPerdiem();
        fetchPerDiemRates();
        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await logJustificationAPI(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }
      } else {
        final body = jsonDecode(response.body);
        final message =
            body['detail']?['message'] ??
            body['message'] ??
            'Something went wrong';

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );

        //  // print("❌  ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      //  // print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<void> perdiemApprovalReview(
    context,
    bool bool,
    int? workitemrecid,
    String? recId,
    String expenseID,
  ) async {
    // buttonLoader.value = true;
    // isUploading.value = true;
    //  // print(recId);
    Map<String, dynamic> buildPayload() {
      return {
        "ExpenseId": expenseID ?? '',
        "RecId": recId,
        "ProjectId": selectedProject != null ? selectedProject?.code : null,
        "TotalAmountTrans": exchangeamountInController.text.isNotEmpty
            ? double.parse(exchangeamountInController.text)
            : 0.0,
        "TotalAmountReporting": amountInController.text.isNotEmpty
            ? double.parse(amountInController.text)
            : 0.0,
        "EmployeeId": Params.employeeId ?? '',
        "EmployeeName": userName.value,
        "ReceiptDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "Currency": "INR",
        "Description": purposeController.text.isNotEmpty
            ? purposeController.text
            : '',
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseType": "PerDiem",
        "Location": selectedLocation?.location ?? '',
        "CashAdvReqId": cashAdvanceIds.text,
        "workitemrecid": workitemrecid,
        "FromDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "ToDate": toDateController.text.isNotEmpty
            ? parseDateToEpoch(toDateController.text)
            : null,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": accountingDistributions.isNotEmpty
            ? accountingDistributions.map((e) => e?.toJson()).toList()
            : [],
        "AllocationLines": allocationLines.isNotEmpty
            ? allocationLines.map((e) => e.toJson()).toList()
            : [],
      };
    }

    try {
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.approvalPerdiemreview}updateandaccept=$bool&screen_name=MyPendingApproval',
        ),

        body: jsonEncode(buildPayload()),
      );

      if (response.statusCode == 202 || response.statusCode == 280) {
        buttonLoader.value = false;
        isUploading.value = false;
        clearFormFieldsPerdiem();
        fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  //  // print("✅ ");
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFields();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else if (response.statusCode == 428) {
        clearFormFields();
        final data = jsonDecode(response.body);
        final detail = data['detail'];

        final List<String> justificationReq = List<String>.from(
          detail['message'] ?? [],
        );
        final String policyId = detail['policyid'] ?? '';
        final String versionNumber = detail['version_number'] ?? '';
        final int refRecId = detail['refrecid'] ?? 0;
        final List<dynamic> refRecLineId = detail['refreclineid'] ?? [];

        final justificationNote = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.justificationRequired,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (justificationReq.isNotEmpty)
                    Text(
                      justificationReq.join("\n\n"),
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(
                        context,
                      )!.enterJustification,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        )!.pleaseEnterJustification,
                        backgroundColor: Colors.orange[200],
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );

        if (justificationNote != null && justificationNote.isNotEmpty) {
          await approvalJustification(
            justificationNote,
            justificationReq,
            refRecId,
            refRecLineId,
            policyId,
            versionNumber,
            context,
          );
        }

        return;
      } else {
        final body = jsonDecode(response.body);
        final message =
            body['detail']?['message'] ??
            body['message'] ??
            'Something went wrong';

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      //  // print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<void> hubperdiemApprovalReview(
    context,
    bool bool,
    int? workitemrecid,
    String? recId,
    String expenseID,
  ) async {
    // buttonLoader.value = true;
    // isUploading.value = true;
    //  // print(recId);
    Map<String, dynamic> buildPayload() {
      return {
        "ExpenseId": expenseID ?? '',
        "RecId": recId,
        "ProjectId": selectedProject != null ? selectedProject?.code : null,
        "TotalAmountTrans": amountInController.text.isNotEmpty
            ? amountInController.text
            : '0',
        "TotalAmountReporting": amountInController.text.isNotEmpty
            ? amountInController.text
            : '0',
        "EmployeeId": Params.employeeId ?? '',
        "EmployeeName": userName.value,
        "ReceiptDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "Currency": "INR",
        "Description": purposeController.text.isNotEmpty
            ? purposeController.text
            : '',
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseType": "PerDiem",
        "Location": selectedLocation?.location ?? '',
        "CashAdvReqId": cashAdvanceIds.text,
        "workitemrecid": workitemrecid,
        "FromDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "ToDate": toDateController.text.isNotEmpty
            ? parseDateToEpoch(toDateController.text)
            : null,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": accountingDistributions.isNotEmpty
            ? accountingDistributions.map((e) => e?.toJson()).toList()
            : [],
        "AllocationLines": allocationLines.isNotEmpty
            ? allocationLines.map((e) => e.toJson()).toList()
            : [],
      };
    }

    try {
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.approvalPerdiemreview}updateandaccept=$bool&screen_name=MyPendingApproval',
        ),

        body: jsonEncode(buildPayload()),
      );

      if (response.statusCode == 202 || response.statusCode == 280) {
        buttonLoader.value = false;
        isUploading.value = false;
        clearFormFieldsPerdiem();
        fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  //  // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  // print("❌  ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      //  // print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<List<PerdiemResponseModel>> fetchSecificPerDiemItem(
    context,
    int recId,
    bool readOnly,
  ) async {
    isLoadingGE2.value = true;
    final url = Uri.parse('${Urls.getSpecificPerdiemExpense}$recId');

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificPerdiemList.value = (data as List)
            .map((item) => PerdiemResponseModel.fromJson(item))
            .toList();

        // for (var expense in specificPerdiemList) {
        //   expenseIdController.text = expense.expenseId;
        //   receiptDateController.text =
        //       DateFormat('dd/MM/yyyy').format(expense.receiptDate);
        // }
        //  //  // print("Perdiem ID: ${expenseIdController.text}");
        isLoadingGE2.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.perDiem,
          arguments: {'item': specificPerdiemList[0], 'readOnly': readOnly},
        );
        return specificPerdiemList;
      } else {
        isLoadingGE2.value = false;
        //  // print(
        //   'Failed to load payment methods. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      //  // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<List<PerdiemResponseModel>> fetchSecificPerDiemItemApproval(
    context,
    int recId,
  ) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getSpecificPerdiemExpenseApproval}workitemrecid=$recId&lock_id=$recId&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificPerdiemList.value = (data as List)
            .map((item) => PerdiemResponseModel.fromJson(item))
            .toList();

        // for (var expense in specificPerdiemList) {
        //   expenseIdController.text = expense.expenseId;
        //   receiptDateController.text =
        //       DateFormat('dd/MM/yyyy').format(expense.receiptDate);
        // }
        //  //  // print("Perdiem ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.perDiem,
          arguments: {'item': specificPerdiemList[0]},
        );
        return specificPerdiemList;
      } else {
        isLoadingGE1.value = false;
        //  //  // print(
        //   'Failed to load payment methods. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      //  // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      // Make API call
      final response = await ApiService.get(
        Uri.parse('${Urls.getNotifications}${Params.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        // Map JSON to NotificationModel
        notifications.value = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        // Filter unread notifications
        unreadNotifications.value = notifications
            .where((n) => !n.read)
            .toList();
        unreadCount.value = unreadNotifications.length;
        //  // print("unreadNotifications.value${unreadCount.value}");
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      //  // print('❌ Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(NotificationModel notification) async {
    try {
      final url = Uri.parse(
        "${Urls.baseURL}/api/v1/websocket/notifications/${notification.recId}/read/",
      );

      // Call API
      final response = await ApiService.put(url);

      if (response.statusCode == 200) {
        notification.read = true;
        unreadNotifications.removeWhere((n) => n.recId == notification.recId);
        unreadNotifications.refresh();
        notifications.refresh();
      } else {
        //  // print("❌ Mark as read failed: ${response.body}");
      }
    } catch (e) {
      //  // print("❌ Error marking as read: $e");
    }
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    const apiKey = "AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0";
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:in';

    final response = await ApiService.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //  // print("LocationDropDown$data");
      final predictions = data['predictions'] as List;
      return predictions.map((p) => p['description'] as String).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  Future<void> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Permission granted; now get current position
      final position = await Geolocator.getCurrentPosition();

      //  //  // print(
      //   '📍 Current Position: Lat=${position.latitude}, Lng=${position.longitude}',
      // );

      // _currentLatLng = LatLng(position.latitude, position.longitude);
    } else {
      //  // print('❌ Location permission not granted');
    }
  }

  Future<void> cancelExpense(BuildContext context, String contextRecId) async {
    // Static values
    const String screenName = "MyExpense";
    const String functionalEntity = "ExpenseRequisition";

    final String apiUrl =
        '${Urls.cancelApprovals}context_recid=$contextRecId&screen_name=$screenName&functionalentity=$functionalEntity';

    try {
      final response = await ApiService.put(Uri.parse(apiUrl));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 || response.statusCode == 202) {
        clearFormFieldsPerdiem();
        clearFormFields();
        chancelButton(context);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.generalExpense);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: " $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // void setLeaveTransactionsFromApi(
  //   List<LeaveTransactionforLeave> apiTransactions,
  // ) {
  //   leaveDays.clear();

  //   for (final trans in apiTransactions) {
  //     leaveDays.add(
  //       LeaveDaySelection(
  //         recId: trans.recId!, // ✅ REAL backend RecId
  //         date: DateTime.fromMillisecondsSinceEpoch(trans.transDate),
  //         dayType: _getInitialDayType(trans),
  //         initialType: '',
  //       ),
  //     );
  //   }
  // }

  String _getInitialDayType(LeaveTransactionforLeave trans) {
    if (trans.leaveFirstHalf && trans.leaveSecondHalf) {
      return 'FullDay';
    } else if (trans.leaveFirstHalf) {
      return 'FirstHalf';
    } else if (trans.leaveSecondHalf) {
      return 'SecondHalf';
    }
    return 'FullDay';
  }

  List<Map<String, dynamic>> buildPartialCancelTrans() {
    return modifiedDays.entries.map((e) {
      return {"RecId": e.key, "CancelRequest": e.value};
    }).toList();
  }

  Future<bool> cancelLeave(
    BuildContext context, {
    required int leaveReqId,
    required String cancellationType, // "Full" | "Partial"
    required String reason,
  }) async {
    try {
      // final headers = await getHeaders();

      final body = {
        "LeaveReqId": leaveReqId,
        "CancellationType": cancellationType,
        "CancellationDate": DateTime.now().millisecondsSinceEpoch,
        "ReasonForCancellation": reason,
        "LeaveCancellationTrans": buildPartialCancelTrans(),
      };

      final response = await ApiService.post(
        Uri.parse(
          "${Urls.baseURL}/api/v1/leavemanagement/leavecancellation/cancelleaves",
        ),

        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // debugPrint("Cancel Leave Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      // debugPrint("Cancel Leave Error: $e");
      return false;
    }
  }

  Future<void> submitPartialCancellation(
    BuildContext context, {
    required int leaveReqId,
    required String reason,
  }) async {
    try {
      setButtonLoading('cancel', true);

      final payload = {
        "LeaveReqId": leaveReqId,
        "CancellationType": "Partial",
        "CancellationDate": DateTime.now().millisecondsSinceEpoch,
        "ReasonForCancellation": reason,
        "LeaveCancellationTrans": buildPartialCancelTrans(),
      };

      final response = await ApiService.post(
        Uri.parse(
          "${Urls.baseURL}/api/v1/leavemanagement/leavecancellation/cancelleaves",
        ),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']['message'] ?? 'No message found';
      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(207, 248, 1, 1),
          textColor: const Color.fromARGB(255, 243, 242, 242),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Partial cancellation failed");
    } finally {
      setButtonLoading('cancel', false);
    }
  }

  Future<void> leavecancelExpense(
    BuildContext context,
    String contextRecId,
  ) async {
    // Static values
    const String screenName = "MyLeave";
    const String functionalEntity = "LeaveRequisition";

    final String apiUrl =
        '${Urls.cancelApprovals}context_recid=$contextRecId&screen_name=$screenName&functionalentity=$functionalEntity';

    try {
      final response = await ApiService.put(Uri.parse(apiUrl));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 || response.statusCode == 202) {
        clearFormFieldsPerdiem();
        resetForm();
        clearFormFields();
        chancelButton(context);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.generalExpense);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: " $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> cancelCashadvance(
    BuildContext context,
    String contextRecId,
  ) async {
    // Static values
    const String screenName = "MyCashAdvance";
    const String functionalEntity = "CashAdvanceRequisition";

    final String apiUrl =
        '${Urls.cancelApprovals}context_recid=$contextRecId&screen_name=$screenName&functionalentity=$functionalEntity';

    try {
      final response = await ApiService.put(Uri.parse(apiUrl));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 || response.statusCode == 202) {
        clearFormFieldsPerdiem();
        clearFormFields();
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: " $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> fetchMileageRates() async {
    isLoadingGE2.value = true;
    final dateToUse = selectedDateMileage ?? DateTime.now();
    //  // print("fetchExpenseCategory${selectedProject?.code}");
    //  // print("fetchExpenseCategory$selectedDateMileage");
    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    try {
      final response = await ApiService.get(
        Uri.parse(
          '${Urls.empmileagevehicledetails}${Params.employeeId}&ReceiptDate=$fromDate',
        ),
      );

      if (response.statusCode == 200) {
        isLoadingGE2.value = false;

        final data = jsonDecode(response.body);

        vehicleTypes = (data as List)
            .map((item) => VehicleType.fromJson(item))
            .toList();

        // selectedVehicleType = vehicleTypes.first;

        //  // debugPrint(
        //   "Vehicle Types: ${vehicleTypes.map((v) => v.name).toList()}",
        // );
        isLoadingGE2.value = false;
      } else {
        // debugPrint("API  ${response.statusCode}");
        isLoadingGE2.value = false;
      }
    } catch (e) {
      // debugPrint("API  $e");
      isLoadingGE2.value = false;
    }
  }

  void calculateAmount() {
    double ratePerKm = 0;

    for (var rate in selectedVehicleType!.mileageRateLines) {
      if ((rate.maximumDistances == 0 &&
              totalDistanceKm >= rate.minimumDistances) ||
          // For bounded ranges
          (totalDistanceKm >= rate.minimumDistances &&
              totalDistanceKm <= rate.maximumDistances)) {
        ratePerKm = rate.mileageRate;
        break;
      }
    }

    calculatedAmountINR = totalDistanceKm * ratePerKm;
    calculatedAmountUSD = calculatedAmountINR / 80; // Approx USD conversion

    // debugPrint("Selected Vehicle: ${selectedVehicleType!.name}");
    // debugPrint("Rate per KM: $ratePerKm");
    // debugPrint("Total Distance: $totalDistanceKm");
    // debugPrint("Amount (INR): $calculatedAmountINR");
    // debugPrint("Amount (USD): $calculatedAmountUSD");
  }

  // Future<List<Map<String, dynamic>>> buildExpenseTransList(
  //   List<TextEditingController> tripControllers,
  //   bool isRoundTrip,
  //   String googleApiKey,
  // ) async {
  //   List<Map<String, dynamic>> expenseTrans = [];

  //   for (int i = 0; i < tripControllers.length - 1; i++) {
  //     String from = tripControllers[i].text.trim();
  //     String to = tripControllers[i + 1].text.trim();

  //     double distance = await getDistanceBetween(from, to, googleApiKey);

  //     // ✅ Forward trip segment
  //     expenseTrans.add({
  //       "FromLocation": from,
  //       "ToLocation": to,
  //       "Quantity": distance,
  //     });
  //   }

  //   if (isRoundTrip) {
  //     // ✅ Add return trips (reverse all)
  //     for (int i = tripControllers.length - 1; i > 0; i--) {
  //       String from = tripControllers[i].text.trim();
  //       String to = tripControllers[i - 1].text.trim();

  //       double distance = await getDistanceBetween(from, to, googleApiKey);

  //       expenseTrans.add({
  //         "FromLocation": from,
  //         "ToLocation": to,
  //         "Quantity": distance,
  //       });
  //     }
  //   }

  //   return expenseTrans;
  // }

  List<Map<String, dynamic>> buildExpenseTrans() {
    // List<Map<String, dynamic>> expenseTrans = [];
    List<Map<String, dynamic>> expenseTrans = [];

    for (int i = 0; i < tripControllers.length - 1; i++) {
      String from = tripControllers[i].text.trim();
      String to = tripControllers[i + 1].text.trim();

      // ✅ Forward trip segment
      expenseTrans.add({
        "FromLocation": from,
        "ToLocation": to,
        "Quantity": isRoundTrip ? calculatedAmountINR / 2 : calculatedAmountINR,
      });
    }

    if (isRoundTrip) {
      for (int i = tripControllers.length - 1; i > 0; i--) {
        String from = tripControllers[i].text.trim();
        String to = tripControllers[i - 1].text.trim();

        double distance = calculatedAmountINR / 2;

        expenseTrans.add({
          "FromLocation": from,
          "ToLocation": to,
          "Quantity": distance,
        });
      }
    }

    return expenseTrans;
  }

  void resetFieldsMileage() {
    cashAdvanceListDropDown.clear();
    expenseIdController.clear();
    employeeIdController.clear();
    mileageVehicleName.clear();
    projectIdController.clear();
    mileageVehicleID.clear();
    selectedVehicleType = null;
    // isRoundTrip = false;
    mileagDateController.clear();
    vehicleTypes.clear();

    tripControllers.clear();
    tripControllers.add(TextEditingController());
    tripControllers.add(TextEditingController());
  }

  Future<void> submitMileageExpense(
    context,
    bool boolValue,
    bool submit,
    int? recId, [
    String? expenseId,
  ]) async {
    try {
      // 🔹 Build ExpenseTrans payload
      final expenseTranArray = buildExpenseTrans();
      Map<String, dynamic> expenseTransMap = {};

      for (int i = 0; i < expenseTranArray.length; i++) {
        expenseTransMap[i.toString()] = expenseTranArray[i];
      }

      // 🔹 Prepare main payload
      final payload = {
        "TotalAmountTrans": calculatedAmountINR,
        "TotalAmountReporting": calculatedAmountINR,
        "EmployeeId": Params.employeeId,
        "EmployeeName": userName.value,
        "ReceiptDate": DateTime.now().millisecondsSinceEpoch,
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseId": expenseId ?? "",
        "ExpenseType": "Mileage",
        "RecId": recId,
        "Currency": "INR",
        "MileageRateId": mileageVehicleID.text,
        "VehicleType": selectedVehicleType?.name ?? "Car",
        "FromLocation": tripControllers.first.text,
        "ToLocation": tripControllers.last.text,
        "CashAdvReqId": cashAdvanceIds.text,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": [],
        "ExpenseTrans": expenseTransMap,
        "ProjectId": projectIdController.text.isEmpty
            ? null
            : projectIdController.text,
      };

      // 🔹 Debug log
      //  // print("🚀 SUBMIT PAYLOAD => ${jsonEncode(payload)}");

      // 🔹 API call
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.mileageregistration}Submit=$boolValue&Resubmit=$submit&screen_name=MileageRegistration',
        ),

        body: jsonEncode(payload),
      );

      //  // print("📡 RESPONSE STATUS: ${response.statusCode}");
      //  // print("📡 RESPONSE BODY: ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // ✅ Safely extract message (can be List or String)
      dynamic msgData = responseData['detail']?['message'];
      String message = 'No message found';

      if (msgData is String) {
        message = msgData;
      } else if (msgData is List) {
        message = msgData.join("\n");
      }

      // ✅ Success responses
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 208 ||
          response.statusCode == 280) {
        resetFieldsMileage();
        clearFormFieldsPerdiem();

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );

        Navigator.pushNamed(context, AppRoutes.generalExpense);
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        resetFieldsMileage();
        clearFormFieldsPerdiem();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.orange[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      }
      // 🟡 Policy justification required (HTTP 428)
      else if (response.statusCode == 428) {
        resetFieldsMileage();
        clearFormFieldsPerdiem();

        try {
          final detail = responseData['detail'] ?? {};

          // Handle message safely
          dynamic msg = detail['message'];
          List<String> justificationReq = [];

          if (msg is List) {
            justificationReq = msg.map((e) => e.toString()).toList();
          } else if (msg is String) {
            justificationReq = [msg];
          } else {
            justificationReq = ["Justification required"];
          }

          final String policyId = detail['policyid']?.toString() ?? '';
          final String versionNumber =
              detail['version_number']?.toString() ?? '';
          final int refRecId =
              int.tryParse(detail['refrecid']?.toString() ?? '0') ?? 0;
          final List<dynamic> refRecLineId = (detail['refreclineid'] is List)
              ? detail['refreclineid']
              : [];

          // 🟢 Show Justification Dialog
          final justificationNote = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.justificationRequired,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (justificationReq.isNotEmpty)
                      Text(
                        justificationReq.join("\n\n"),
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(
                          context,
                        )!.enterJustification,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(context, text);
                      } else {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          )!.pleaseEnterJustification,
                          backgroundColor: Colors.orange[200],
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              );
            },
          );

          // 🔹 Call justification API if user entered a note
          if (justificationNote != null && justificationNote.isNotEmpty) {
            await logJustificationAPI(
              justificationNote,
              justificationReq,
              refRecId,
              refRecLineId,
              policyId,
              versionNumber,
              context,
            );
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red[200],
            textColor: Colors.red[800],
          );
          //  // print("❌ Error handling 428 justification: $e");
        }
      }
      // 🔴 Other errors
      else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
        expenseTrans = [];
        expenseTrans.clear();
      }
    } catch (e) {
      //  // print("🔥 Exception during API call: $e");
    }
  }

  Future<void> approvalHubsubmitMileageExpense(
    context,
    bool bool,
    bool submit,
    int? recId, [
    String? expenseId,
  ]) async {
    try {
      // Build ExpenseTrans payload
      final expenseTranArray = buildExpenseTrans();
      Map<String, dynamic> expenseTransMap = {};
      for (int i = 0; i < expenseTranArray.length; i++) {
        expenseTransMap[i.toStringAsFixed(2)] = expenseTranArray[i];
      }
      // Prepare main payload
      final payload = {
        "TotalAmountTrans": calculatedAmountINR,
        "TotalAmountReporting": calculatedAmountINR,
        "EmployeeId": Params.employeeId,
        "EmployeeName": userName.value,
        "ReceiptDate": DateTime.now().millisecondsSinceEpoch,
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseId": expenseId ?? "",
        "ExpenseType": "Mileage",
        "RecId": recId,
        "Currency": "INR",
        "MileageRateId": mileageVehicleID.text,
        "VehicleType": selectedVehicleType?.name ?? "Car",
        "FromLocation": tripControllers.first.text,
        "ToLocation": tripControllers.last.text,
        // "RecId": null,
        "CashAdvReqId": cashAdvanceIds.text,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": [],
        "ExpenseTrans": expenseTransMap,
        "ProjectId": projectIdController.text,
      };

      // Print payload for debugging
      //  // print(jsonEncode(payload));

      // Send POST API request
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.mileageregistration}Submit=$bool&Resubmit=$submit&screen_name=MileageRegistration',
        ),

        body: jsonEncode(payload),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 208 ||
          response.statusCode == 280) {
        resetFieldsMileage();
        clearFormFieldsPerdiem();
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
        expenseTrans = [];
        expenseTrans.clear();
        //  //  // print(" ${response.body}");
      }
    } catch (e) {
      //  // print("🔥 Exception during API call: $e");
    }
  }

  double calculateTotal(List<Map<String, dynamic>> expenseTrans) {
    double total = 0;
    for (var trip in expenseTrans) {
      total += (trip['Quantity'] as num).toDouble() * 40; // 40 INR/KM
    }
    return total;
  }

  Future<void> fetchCustomFields() async {
    isLoadingGE1.value = true;

    final DateTime dateToFormat = selectedDate ?? DateTime.now();
    final formatted = DateFormat('dd/MM/yyyy').format(dateToFormat);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final url = Uri.parse(
      '${Urls.getCustomField}=PerDiem&Fromdate=$receiptDate',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> fetchedFields = json.decode(response.body);
      isLoadingGE1.value = false;

      customFields.value = fetchedFields;
    } else {
      isLoadingGE1.value = false;

      throw Exception('Failed to load custom fields: ${response.statusCode}');
    }
  }

  Future<List<DimensionHierarchy>> fetchDimensionHierarchies() async {
    final url = Uri.parse('${Urls.getdimensionsDropdownName}1752172200000');

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DimensionHierarchy.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dimension hierarchies');
    }
  }

  Future<List<DimensionValue>> fetchDimensionValues() async {
    final url = Uri.parse(Urls.getdimensionsDropdownValue);

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DimensionValue.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dimension values');
    }
  }

  String lastLoadedRole = "";
  Future<void> fetchChartDataOnce(String role) async {
    //  // print("lastLoadedRole$lastLoadedRole");
    if (lastLoadedRole == role) return; // already loaded
    lastLoadedRole = role;

    await fetchChartData(role);
  }

  Future<void> fetchChartData(String currentRole) async {
    // if (lastLoadedRole == currentRole) return; // already loaded
    // lastLoadedRole = currentRole;
    final int endDate = DateTime.now().millisecondsSinceEpoch;
    isUploadingCards.value = true;
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.cashAdvanceChart}?role=$currentRole&end_date=$endDate&periods=5&period_type=Weekly&page=1&limit=10&sort_by=YAxis&sort_order=asc',
      ),
    );

    if (response.statusCode == 200) {
      isUploadingCards.value = false;
      final jsonResponse = json.decode(response.body);
      final xAxis = List<String>.from(jsonResponse['XAxis']);
      final yAxis = List<double>.from(
        jsonResponse['YAxis'].map((e) => (e ?? 0).toDouble()),
      ); // Null safety

      chartData = List.generate(
        xAxis.length,
        (index) => ProjectData(xAxis[index], yAxis[index]),
      );
      isUploadingCards.value = false;
      //  // print('chartData$chartData');
      // isLoading = false;
    } else {
      // Handle error
      isUploadingCards.value = false;
      // isLoading = false;

      //  // print(' ${response.statusCode} ${response.body}');
    }
  }

  Future<void> fetchAndReplaceValue() async {
    isUploadingCards.value = true;
    final int endDate = DateTime.now().millisecondsSinceEpoch;
    final int startDate = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;

    final String apiUrl =
        '${Urls.expenseChart}'
        '?role=Spender'
        '&start_date=$startDate'
        '&end_date=$endDate'
        '&page=1'
        '&limit=10'
        '&sort_by=Value'
        '&sort_order=asc';

    final response = await ApiService.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['Value'] != null) {
        expenseChartvalue = (jsonData['Value'] as num).toDouble();

        //  // print("Value $expenseChartvalue  API response");
        isUploadingCards.value = false;
      } else {
        //  // print("Value not found in API response");
        isUploadingCards.value = false;
      }
    } else {
      //  // print('Failed to fetch data: ${response.statusCode}');
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchExpensesByProjects() async {
    try {
      isUploadingCards.value = true;

      const String apiUrl =
          '${Urls.projectExpenseChart}'
          '';

      final response = await ApiService.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final expenses = jsonData
            .map((item) => ProjectExpense.fromJson(item))
            .toList();

        projectExpenses.value = expenses;
        isUploadingCards.value = false;
      } else {
        // Get.snackbar("Error", "Failed to fetch data: ${response.statusCode}");
        isUploadingCards.value = false;
      }
    } catch (e) {
      //  // print(" $e");
      Get.snackbar("Error", "Something went wrong!");
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchExpensesByCategory() async {
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/dashboard/widgets/ExpensesByCategories?',
        ),
      );

      if (response.statusCode == 200) {
        isUploadingCards.value = false;

        final data = json.decode(response.body);

        List<String> categories = List<String>.from(data['XAxis']);
        List<dynamic> yAxis = data['YAxis'];

        // Combine data for each category (sum of all statuses)
        List<ProjectExpensebycategory> expenses = [];
        for (int i = 0; i < categories.length; i++) {
          double total = 0.0;
          for (var status in yAxis) {
            total += (status['data'][i] ?? 0.0);
          }
          expenses.add(
            ProjectExpensebycategory(
              x: categories[i],
              y: total,
              color: getRandomMildColor(),
            ),
          );
        }

        projectExpensesbyCategory.assignAll(expenses);
        isUploadingCards.value = false;
      } else {
        // Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}');
        isUploadingCards.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch data: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchExpensesByStatus() async {
    try {
      isUploadingCards.value = true;
      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/dashboard/widgets/ExpenseAmountByExpenseStatus?',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<String> xAxis = List<String>.from(jsonResponse['XAxis']);
        List<double> yAxis = List<double>.from(
          jsonResponse['YAxis'].map((e) => e.toDouble()),
        );

        final data = List.generate(
          xAxis.length,
          (index) => ExpenseAmountByStatus.fromJson(xAxis[index], yAxis[index]),
        );

        expensesByStatus.assignAll(data);
        isUploadingCards.value = false;
      } else {
        // Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}');
        isUploadingCards.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchManageExpensesSummary() async {
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/dashboard/dashboard/manageexpenses?employeeid=${Params.employeeId}',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Convert Map<String, double> to List<ManageExpensesSummary>
        final summary = jsonResponse.entries.map((e) {
          return ManageExpensesSummary(
            status: e.key,
            amount: (e.value as num).toDouble(),
          );
        }).toList();

        manageExpensesSummary.assignAll(summary);
        isUploadingCards.value = false;
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch summary: ${response.statusCode}',
        );
        isUploadingCards.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  var isLoadingReference = false.obs;
  var selectedReferenceId = ''.obs;
  var referenceList = <Map<String, dynamic>>[].obs;
  var selectedReference = Rxn<Map<String, dynamic>>();
  List<String> get referenceHeaders {
    switch (selectedReferenceType.value) {
      case 'Expense':
        return ['Expense ID', 'Expense Type'];
      case 'Project':
        return ['Project ID', 'Project Name'];
      case 'Travel':
        return ['Requisition ID', 'Requested By'];
      case 'Cash Advance':
        return ['Requisition ID', 'Approval Status'];
      case 'Payment Proposal':
        return ['Proposal ID', 'Proposal Status'];
      default:
        return [];
    }
  }

  Future<bool> deleteTask({
    required int recId,
    required BuildContext context,
    required String boardIdNumb,
  }) async {
    final uri = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/tasks/tasks'
      '?RecId=$recId'
      '&screen_name=KANTasks',
    );

    try {
      final response = await ApiService.delete(uri);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pushNamed(
          context,
          AppRoutes.kanbanBoardPage,
          arguments: {"boardId": boardIdNumb},
        );
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        return true;
      } else {
        debugPrint('Delete failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  Future<void> updateShelfOrder({
    required int recId,
    required int newSortOrder,
  }) async {
    try {
      final uri = Uri.parse(
        '${Urls.baseURL}/api/v1/kanban/shelfs/shelfs/shelfs'
        '?rec_id=$recId'
        '&new_sort_order=$newSortOrder',
      );

      final response = await ApiService.put(uri);

      if (response.statusCode != 200) {
        debugPrint("Shelf reorder failed");
      }
    } catch (e) {
      debugPrint("Shelf reorder error: $e");
    }
  }

  Future<void> fetchReferenceList() async {
    isLoadingReference.value = true;
    referenceList.clear();
    selectedReference.value = null;
    try {
      late String url;

      switch (selectedReferenceType.value) {
        case 'Expense':
          url =
              '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expenseheader'
              '?filter_query=&page=1&sort_order=asc'
              '&choosen_fields=ExpenseId,EmployeeId,ExpenseType';
          break;

        case 'Project':
          url =
              '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/projectid'
              '?EmployeeId=${Params.employeeId}';
          break;

        case 'Travel':
          url =
              '${Urls.baseURL}/api/v1/travelrequisition/travelrequisitionendpoints/travelrequisitions'
              '?page=1&sort_order=asc'
              '&choosen_fields=RequisitionId,RequestedBy';
          break;

        case 'Cash Advance':
          url =
              '${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/getcashadvanceheader'
              '?page=1&sort_order=asc'
              '&choosen_fields=RequisitionId,ApprovalStatus';
          break;

        case 'Payment Proposal':
          url =
              '${Urls.baseURL}/api/v1/reimbursementmgmt/reimbursement/paymentproposalheader'
              '?page=1&sort_order=asc'
              '&choosen_fields=ProposalId,ProposalStatus';
          break;

        default:
          return;
      }

      final response = await ApiService.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        referenceList.value = data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoadingReference.value = false;
    }
  }

  String _getDisplayValue(Map<String, dynamic> e) {
    switch (selectedReferenceType.value) {
      case 'Expense':
        return e['ExpenseId'].toString();
      case 'Project':
        return e['ProjectId'].toString();
      case 'Travel':
        return e['RequisitionId'].toString();
      case 'Cash Advance':
        return e['RequisitionId'].toString();
      case 'Payment Proposal':
        return e['ProposalId'].toString();
      default:
        return '';
    }
  }

  String getSearchValue(Map<String, dynamic> item) {
    switch (selectedReferenceType.value) {
      case 'Expense':
        return '${item['ExpenseId']} ';
      case 'Project':
        return '${item['ProjectId']} ';
      case 'Travel':
        return '${item['RequisitionId']} ';
      case 'Cash Advance':
        return '${item['RequisitionId']} ';
      case 'Payment Proposal':
        return '${item['ProposalId']} ';
      default:
        return '';
    }
  }

  Future<void> fetchUsers() async {
    final rawUrl =
        "${Urls.esCalateUserList}${Params.userId}"
        "&page=1"
        "&sort_order=asc"
        "&choosen_fields=UserName%2CUserId";

    try {
      final uri = Uri.parse(rawUrl); // ✅ convert String to Uri

      final response = await ApiService.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        //  // print("Fetched users: $usersJson");
        userList.value = usersJson.map((json) => User.fromJson(json)).toList();

        //  // print("Fetched users: ${userList.map((u) => u.userName).toList()}");

        // Optional: set default selected user
        if (userList.isNotEmpty) {
          selectedUser.value = userList.first;
          userIdController.text = userList.first.userId;
        }
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      //  // print('Error fetching users: $e');
    }
  }

  Future<List<CashAdvanceReqModel>> fetchCashAdvanceRequests() async {
    final dateToUse = selectedDate ?? DateTime.now();

    isUploadingCards.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    String url =
        "${Urls.cashAdvanceList}"
        "?employee_id=${Params.employeeId}&ProjectId=${projectIdController.text}&Location=&ExpenseCategoryId=$selectedCategoryId&PaymentMethod=$paymentMethodID&Currency=INR&ReceiptDate=$fromDate";

    final response = await ApiService.get(Uri.parse(url));

    if (response.statusCode == 200) {
      isUploadingCards.value = false;
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CashAdvanceReqModel.fromJson(json)).toList();
    } else {
      isUploadingCards.value = false;

      throw Exception('Failed to load Cash Advance Requests');
    }
  }

  Future<void> fetchAndCombineDataPaySlip() async {
    //  // print("Calling fetchAndCombineData (Payslip Analytics)...");
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse('${Urls.baseURL}/api/v1/payslip/analytics'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        //  // print("Payslip API response: $data");

        payslipAnalyticsCards.clear();

        for (var item in data) {
          /// 1️⃣ Total Net Pay
          if (item.containsKey('TotalNetPay')) {
            payslipAnalyticsCards.add(
              PayslipAnalyticsCard(
                title: 'Total Net Pay',
                value: (item['TotalNetPay'] ?? 0).toDouble(),
              ),
            );
          }
          /// 2️⃣ Annual Leave Balance
          else if (item.containsKey('AnnualLeaveBalance')) {
            payslipAnalyticsCards.add(
              PayslipAnalyticsCard(
                title: 'Annual Leave Balance',
                value: (item['AnnualLeaveBalance'] ?? 0).toDouble(),
              ),
            );
          }
          /// 3️⃣ Current vs Last Month Net Pay
          else if (item.containsKey('CurrentMonthNetPay')) {
            payslipAnalyticsCards.add(
              PayslipAnalyticsCard(
                title: 'Monthly Net Pay',
                value: (item['CurrentMonthNetPay'] ?? 0).toDouble(),
                secondaryValue: (item['LastMonthNetPay'] ?? 0).toDouble(),
              ),
            );
          }
        }

        //  // print("payslipAnalyticsCards: $payslipAnalyticsCards");
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch payslip analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchManageExpensesCards() async {
    //  // print("Calling fetchManageExpensesCards...");
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/analytics',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        //  // print("API response: $data");

        // Clear the existing cards
        manageExpensesCards.clear();

        for (var item in data) {
          if (item.containsKey('PendingAmount')) {
            manageExpensesCards.add(
              ManageExpensesCard(
                status: 'Inprogress', // Expenses In Progress (Total)
                amount: (item['PendingAmount'] ?? 0).toDouble(),
                count: (item['PendingCount'] ?? 0).toInt(),
              ),
            );
          } else if (item.containsKey('ApprovedAmount')) {
            manageExpensesCards.add(
              ManageExpensesCard(
                status: 'TotalAmountReporting', // Approved Expenses (Total)
                amount: (item['ApprovedAmount'] ?? 0).toDouble(),
                count: (item['ApprovedCount'] ?? 0).toInt(),
              ),
            );
          } else if (item.containsKey('AllAmount')) {
            manageExpensesCards.add(
              ManageExpensesCard(
                status: 'AmountSettled', // All Expenses (Total)
                amount: (item['AllAmount'] ?? 0).toDouble(),
                count: (item['AllCount'] ?? 0).toInt(),
              ),
            );
          }
        }

        //  // print("manageExpensesCards: $manageExpensesCards");
        isUploadingCards.value = false;
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch expense cards: ${response.statusCode}',
        );
        isUploadingCards.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> getCashAdvanceAPI() async {
    //  // print("cashAdvanceList");
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/getcashadvanceheader?filter_query=CSHCashAdvReqHeader.CreatedBy__eq%3D${Params.userId}&page=1&sort_by=ModifiedDatetime&sort_order=desc',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //  // print("cashAdvanceList$data");

        cashAdvanceList.value = (data as List)
            .map((item) => CashAdvanceModel.fromJson(item))
            .toList();

        //  // print("cashAdvanceList$cashAdvanceList");
        isUploadingCards.value = false;
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch expense cards: ${response.statusCode}',
        );
        isUploadingCards.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> getExpenseList() async {
    //  // print("Fetching Expense List...");
    try {
      // Start loader
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expenseheader?filter_query=EXPExpenseHeader.CreatedBy__eq%3D${Params.userId}&page=1&sort_by=ModifiedDatetime&sort_order=desc',
        ),
      );

      //  // print("API Response Status: ${response.statusCode}");
      //  // print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Ensure API returned a list
        if (decodedData is List && decodedData.isNotEmpty) {
          final expenses = decodedData
              .map((item) => ExpenseListModel.fromJson(item))
              .toList();

          // Assign to observable list
          expenseList.assignAll(expenses);

          //  // print("✅ Expense list updated with ${expenseList.length} items");
        } else {
          //  // print("⚠️ API returned an empty or unexpected data format");
          Get.snackbar('Info', 'No expense records found.');
        }
      } else {
        //  // print("❌ API  ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Failed to fetch expenses. Status Code: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      //  // print("❌ Exception in getExpenseList: $e");
      //  // print(stackTrace);
      Get.snackbar('Error', 'Something went wrong while fetching expenses');
    } finally {
      // Stop loader
      isUploadingCards.value = false;
    }
  }

  // ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️ Cash Advance request Field⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  //
  final RxBool isDeleting = false.obs;
  final RxList<FieldConfiguration> fieldConfigs = <FieldConfiguration>[].obs;
  final RxBool isLoadingConfig = false.obs;
  Future<List<CashAdvanceRequisition>> fetchCashAdvanceRequisitions() async {
    isLoadingCA.value = true;

    String? apiStatus;
    switch (selectedStatus) {
      case 'Un Reported':
        apiStatus = 'Created';
        break;
      case 'In Process':
        apiStatus = 'Pending';
        break;
      case 'Approved':
        apiStatus = 'Approved';
        break;
      case 'Cancelled':
      case 'Rejected':
        apiStatus = selectedStatus;
        break;
      case 'All':
        apiStatus = null;
        break;
      default:
        apiStatus = null;
    }

    String baseUrl =
        '${Urls.cashAdvanceGetall}?filter_query=CSHCashAdvReqHeader.CreatedBy__eq%3D${Params.userId}%26CSHCashAdvReqHeader.ApprovalStatus__eq%3D$apiStatus&page=1&sort_order=asc';
    final Uri url = Uri.parse(baseUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          cashAdvanceListDashboard.value = data
              .map((item) => CashAdvanceRequisition.fromJson(item))
              .toList();
        } else {
          //  // print('⚠️ Unexpected data format: expected a List');
          cashAdvanceList.clear();
        }

        //  // print("✅ Fetched Cash Advances: ${cashAdvanceListDashboard.length}");
        isLoadingCA.value = false;
        return cashAdvanceListDashboard.toList();
      } else {
        //  //  // print(
        //   '❌ Failed to load cash advances. Status: ${response.statusCode}, Body: ${response.body}',
        // );
        isLoadingCA.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching cash advance requisitions: $e');
      isLoadingCA.value = false;
      return [];
    }
  }

  Future<bool> deleteCashAdvance(int recId) async {
    if (recId <= 0) return false;

    isDeleting.value = true;
    try {
      // Build URL with query parameters
      final url = Uri.parse(
        ' ${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/deletecashadvance '
        '?RecId=$recId&screen_name=MyCashAdvance',
      );

      final response = await ApiService.get(url);

      isDeleting.value = false;

      if (response.statusCode == 200) {
        // Successfully deleted on server
        final responseData = jsonDecode(response.body);

        // Optional: Check success flag from body
        final success = responseData['success'] as bool? ?? false;
        if (success || responseData['message']?.contains('success') == true) {
          // Remove locally
          cashAdvanceList.removeWhere((item) => item.recId == recId);
          Get.snackbar(
            "Success",
            "Cash advance deleted successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Delete failed');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      isDeleting.value = false;
      Get.snackbar(
        "Delete Failed",
        e.toString().contains("401")
            ? "Unauthorized. Please log in again."
            : "Could not delete request. Please try again.",
      );
      return false;
    }
  }

  Future<void> getconfigureFieldCashAdvance() async {
    isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.geconfigureFieldCashAdvance);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configListAdvance.value = [];
        if (data is List) {
          configListAdvance.addAll(data.cast<Map<String, dynamic>>());

          //  // print('Appended configList: $configListAdvance');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          //  // print('currencies to load countries$currencies');
        }
      } else {
        //  // print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
      isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<void> fetchBusinessjustification() async {
    isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.businessJustification);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // configListAdvance.value = [];
        if (data is List) {
          justification.assignAll(
            data.map((json) => Businessjustification.fromJson(json)).toList(),
          );

          //  // print('justification: $justification');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          //  //  // print('currencies to load countries$currencies');
        }
      } else {
        //  // print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
      isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<ExchangeRateResponse?> fetchExchangeRateCA(
    String? currencyCode,
    String? amount,
  ) async {
    final dateToUse = selectedDate ?? DateTime.now();
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    String? currencyCodes = currencyCode;
    final currencyValue = currencyCodes ?? "INR";

    double? parsedAmount = double.tryParse(amount!);
    final String amounts = parsedAmount != null
        ? parsedAmount.toInt().toStringAsFixed(2)
        : '0';

    final url = Uri.parse(
      '${Urls.exchangeRate}/$amounts/$currencyValue/$fromDate',
    );

    try {
      final response = await ApiService.get(url);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ExchangeRate'] != null && data['BaseUnit'] != null) {
          return ExchangeRateResponse.fromJson(data);
        }
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
    } catch (e) {
      //  // print('Error fetching exchange rate: $e');
    }
    return null;
  }

  Future<double?> fetchMaxAllowedPercentage() async {
    //  // print("Callx");
    // Get the required values directly from controller
    final dateToUse = selectedDate ?? DateTime.now();
    final String requestDateEpoch = dateToUse.millisecondsSinceEpoch
        .toStringAsFixed(2);
    final String employeeId = Params.employeeId;
    final String expenseCategory = selectedCategoryId;
    final String location = locationController.text ?? '';

    final url = Uri.parse(
      '${Urls.maxAllowedPercentage}'
      'RequestDate=$requestDateEpoch'
      '&EmployeeId=$employeeId'
      '&ExpenseCategory=$expenseCategory'
      '&Location=$location',
    );

    try {
      final response = await ApiService.get(url);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['MaxAllowedPercentage'] != null) {
          final double percentage = (data['MaxAllowedPercentage'] as num)
              .toDouble();

          requestedPercentage.text = percentage.toString();

          return percentage;
        }
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
    } catch (e) {
      //  // print('Error fetching MaxAllowedPercentage: $e');
    }

    return null;
  }

  Future<Object> fetchSpecificCashAdvanceItem(
    BuildContext context,
    int recId,
    bool bool,
  ) async {
    isLoadingCA.value = true;

    // Build the URL with query parameters
    final url = Uri.parse(
      '${Urls.getSpecificCashAdvance}recid=$recId&lock_id=$recId&screen_name=MyCashAdvance',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificCashAdvanceList.value = (data as List)
            .map((item) => CashAdvanceRequestHeader.fromJson(item))
            .toList();

        // Example: Fill controllers from first item
        if (specificCashAdvanceList.isNotEmpty) {
          final cashAdvance = specificCashAdvanceList[0];
          requisitionIdController.text = cashAdvance.requisitionId ?? '';
          requestDateController.text = cashAdvance.requestDate != null
              ? DateFormat('dd/MM/yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(cashAdvance.requestDate!),
                )
              : '';
          // Add more controllers if needed
          //  // print("Requisition ID: ${requisitionIdController.text}");
        }

        isLoadingCA.value = false;

        // Navigate to ViewCashAdvanseReturnForm

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.viewCashAdvanseReturnForms,
          arguments: {'item': specificCashAdvanceList[0], "readOnly": bool},
        );
        return specificCashAdvanceList;
      } else {
        isLoadingCA.value = false;
        final data = jsonDecode(response.body);
        final String message = data['detail']?['message'] ?? 'No message found';
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        //  //  // print(
        //   'Failed to load Cash Advance. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      isLoadingCA.value = false;
      //  // print('Error fetching Cash Advance: $e');
      return [];
    }
  }

  Future<Object> fetchSpecificCashAdvanceApprovalItem(
    BuildContext context,
    int workitemrecid,
  ) async {
    isLoadingCA.value = true;

    // Build the URL with query parameters
    final url = Uri.parse(
      '${Urls.myPendingApproval}detailedapproval?workitemrecid=$workitemrecid&lock_id=$workitemrecid&&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificCashAdvanceList.value = (data as List)
            .map((item) => CashAdvanceRequestHeader.fromJson(item))
            .toList();

        // Example: Fill controllers from first item
        if (specificCashAdvanceList.isNotEmpty) {
          final cashAdvance = specificCashAdvanceList[0];
          requisitionIdController.text = cashAdvance.requisitionId ?? '';
          requestDateController.text = cashAdvance.requestDate != null
              ? DateFormat('dd/MM/yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(cashAdvance.requestDate!),
                )
              : '';
          // Add more controllers if needed
          //  // print("Requisition ID: ${requisitionIdController.text}");
        }

        isLoadingCA.value = false;

        // Navigate to ViewCashAdvanseReturnForm

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.viewCashAdvanseReturnForms,
          arguments: {'item': specificCashAdvanceList[0]},
        );
        return specificCashAdvanceList;
      } else {
        final data = jsonDecode(response.body);
        final String message = data['detail']?['message'] ?? 'No message found';
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        isLoadingCA.value = false;
        //  //  // print(
        //   'Failed to load Cash Advance. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      isLoadingCA.value = false;
      //  // print('Error fetching Cash Advance: $e');
      return [];
    }
  }

  Timer? _debounce;

  void calculateAndFetchAmounts() {
    final qty = double.tryParse(quantity.text) ?? 0.0;
    final unit = double.tryParse(unitAmount.text) ?? 0.0;

    final calculatedLineAmount = qty * unit;

    totalunitEstimatedAmount.text = calculatedLineAmount.toStringAsFixed(2);
    paidAmount.text = calculatedLineAmount.toStringAsFixed(2);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final paidAmountText = totalunitEstimatedAmount.text.trim();
      final double paidAmounts = double.tryParse(paidAmountText) ?? 0.0;
      final currency = currencyDropDowncontrollerCA3.text;

      if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
        final results = await Future.wait([
          fetchExchangeRateCA(currency, paidAmountText),
          fetchMaxAllowedPercentage(),
        ]);

        final exchangeResponse1 = results[0] as ExchangeRateResponse?;
        if (exchangeResponse1 != null) {
          unitRateCA1.text = exchangeResponse1.exchangeRate.toStringAsFixed(2);
          amountINRCA1.text = exchangeResponse1.totalAmount.toStringAsFixed(2);
          isVisible.value = true;
        }

        final maxPercentage = results[1] as double?;
        if (maxPercentage != null && maxPercentage > 0) {
          double calculatedPercentage = (paidAmounts * maxPercentage) / 100;

          totalRequestedAmount.text = calculatedPercentage.toStringAsFixed(2);
          calculatedPercentage = calculatedPercentage;
          requestedPercentage.text = '${maxPercentage.toInt()} %';

          if (calculatedPercentage > 100) {
            Fluttertoast.showToast(
              msg: 'Paid amount exceeds maximum allowed percentage!',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }

        final reqPaidAmount = totalRequestedAmount.text.trim();
        final reqCurrency = currencyDropDowncontrollerCA2.text;

        if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
          final exchangeResponse = await fetchExchangeRateCA(
            reqCurrency,
            reqPaidAmount,
          );

          if (exchangeResponse != null) {
            unitRateCA2.text = exchangeResponse.exchangeRate.toStringAsFixed(2);
            amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
          }
        }
      }
    });
    //  // print("SuccesFully call All Data");
  }

  Future<void> fetchAndAppendPendingApprovals() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getApprovalDashboardData}pendingcashasvanceapprovals?filter_query=CSHCashAdvReqHeader.ApprovalStatus__eq%3DPending&page=1&sort_order=asc',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      final List<PendingCashAdvanceApproval> newApprovals = jsonData
          .map((item) => PendingCashAdvanceApproval.fromJson(item))
          .toList();

      pendingApprovalcashAdvanse.addAll(newApprovals);

      isLoadingGE1.value = false;
    } else {
      isLoadingGE1.value = false;
      throw Exception('Failed to load pending approvals');
    }
  }

  Future<CashAdvanceGeneralSettings?> fetchGeneralSettings() async {
    final url = Uri.parse(Urls.cashadvanceGeneralSettings);

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Assuming the response is a list or has `data` array
      final settingsJson = (decoded is List ? decoded[0] : decoded['data'][0]);
      return CashAdvanceGeneralSettings.fromJson(settingsJson);
    } else {
      //  // print("Failed to fetch settings: ${response.statusCode}");
      return null;
    }
  }

  Future<SequenceNumber?> fetchCashAdvanceSequence() async {
    final url = Uri.parse(Urls.cashadvancerequisition);

    final response = await ApiService.get(url);

    //  // print('Status Codes: ${response.statusCode}');
    //  // print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      final sequence = jsonList.firstWhere(
        (item) =>
            item['Module'] == 'CashAdvance' &&
            item['Area'] == 'CashAdvanceRequisitionNo',
        orElse: () => null,
      );
      //  // print("sequencess$sequence");
      if (sequence != null) {
        return SequenceNumber.fromJson(sequence);
      }
    } else {
      throw Exception('Failed to load sequence numbers');
    }
    return null;
  }

  Future<List<CashAdvanceDropDownModel>> fetchCashAdvanceList() async {
    viewCashAdvanceLoader.value = true;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/cshadvreqid?employee_id=${Params.employeeId}&ProjectId=&Location=&ExpenseCategoryId=&PaymentMethod=${paymentMethodeID ?? ''}&Currency=${currencyDropDowncontroller.text ?? ''}&ReceiptDate=${selectedDate ?? ''}',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      viewCashAdvanceLoader.value = false;

      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => CashAdvanceDropDownModel.fromJson(item))
          .toList();
    } else {
      viewCashAdvanceLoader.value = false;

      throw Exception('Failed to fetch cash advance list');
    }
  }

  void preloadCashAdvanceSelections(
    List<CashAdvanceDropDownModel> allItems,
    String? idsString,
  ) {
    if (idsString == null || idsString.isEmpty) return;
    //  // print('Comma-separated Text: ${allItems}');
    viewCashAdvanceLoader.value = true;
    cashAdvanceIds.text = "";
    multiSelectedItems.clear();

    // ✅ Ensure IDs are unique before filtering
    final ids = idsString.split(';').toSet().toList();

    // Filter matching items
    final selectedItems = allItems
        .where((item) => ids.contains(item.cashAdvanceReqId))
        .toList();

    // ✅ Remove duplicates based on cashAdvanceReqId
    final uniqueSelectedItems = <String, CashAdvanceDropDownModel>{};
    for (var item in selectedItems) {
      uniqueSelectedItems[item.cashAdvanceReqId] = item;
    }

    multiSelectedItems.assignAll(uniqueSelectedItems.values.toList());

    // Update display text
    cashAdvanceIds.text = multiSelectedItems
        .map((item) => item.cashAdvanceReqId)
        .join(', ');

    // Maintain backend format
    preloadedCashAdvReqIds = multiSelectedItems
        .map((item) => item.cashAdvanceReqId)
        .join(';');

    // Debug
    //  // print('Selected Cash Advance Items: ${multiSelectedItems.length}');
    for (var item in multiSelectedItems) {
      //  // print('→ ID: ${item.cashAdvanceReqId}, Date: ${item.requestDate}');
    }

    //  // print('Comma-separated Text: ${cashAdvanceIds.text}');
    //  // print('Semicolon-separated for backend: $preloadedCashAdvReqIds');
    viewCashAdvanceLoader.value = false;
  }

  Future<List<CashAdvanceDropDownModel>> fetchExpenseCashAdvanceList() async {
    //  // print("currencyDropDowncontroller2${selectedLocation?.city}");
    viewCashAdvanceLoader.value = true;
    int receiptDateMillis =
        (selectedDate ?? DateTime.now()).millisecondsSinceEpoch;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvreqids?EmployeeId=${Params.employeeId}&ProjectId=${selectedProject?.code ?? ''}&Location=${selectedLocation?.city ?? ''}&ExpenseCategoryId=&PaymentMethod=${paymentMethodeID ?? ''}&Currency=${currencyDropDowncontroller2.text ?? ""}&ReceiptDate=${receiptDateMillis ?? ''}',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      viewCashAdvanceLoader.value = false;

      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => CashAdvanceDropDownModel.fromJson(item))
          .toList();
    } else {
      viewCashAdvanceLoader.value = false;

      throw Exception('Failed to fetch cash advance list');
    }
  }

  Future<void> approvalHubreviewGendralExpense(
    context,
    bool action,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  // print("receiptDate$attachmentPayload");
    //  // print("finalItems${finalItems.length}");

    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "workitemrecid": workitemrecid,
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paidWithController.text ?? '',
      "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      "IsReimbursable": true,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": unitRate.text.isNotEmpty ? unitRate.text : '1.0',
      "UserExchRate": unitRate.text.isNotEmpty ? unitRate.text : '1.0',
      "Source": "Web",
      "IsBillable": false,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],

      "DocumentAttachment": {"File": attachmentPayload},
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    final url = Uri.parse(
      '${Urls.reviewexpenseregistration}updateandaccept=$action&screen_name=MyPendingApproval',
    );

    try {
      final response = await ApiService.put(url, body: jsonEncode(requestBody));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 202 || response.statusCode == 280) {
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
        resetFieldsMileage();

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: ' $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Load skipped work items from SharedPreferences
  Future<void> loadSkippedItems() async {
    final storage = await prefs;
    final savedList = storage.getStringList('skippedWorkItems');

    // ✅ Always assign as Set<int>
    skippedWorkItems = savedList != null
        ? savedList
              .map((e) => int.tryParse(e) ?? 0)
              .where((e) => e != 0)
              .toSet()
        : <int>{};

    showSkipButton.value = skippedWorkItems.isNotEmpty;
  }

  // Save skipped work items to SharedPreferences
  Future<void> saveSkippedItems() async {
    final storage = await prefs;

    // ✅ Convert Set<int> to List<String> before saving
    await storage.setStringList(
      'skippedWorkItems',
      skippedWorkItems.map((e) => e.toStringAsFixed(2)).toList(),
    );
  }

  // Skip the current item and update storage + UI
  Future<void> skipCurrentItem(int workitemrecid, BuildContext context) async {
    isLoadingGE2.value = true;
    try {
      final wasAdded = skippedWorkItems.add(
        workitemrecid,
      ); // ✅ Set ensures no duplicates

      if (wasAdded) {
        await saveSkippedItems();
        showSkipButton.value = true;

        if (context.mounted) {
          Navigator.pushNamed(context, AppRoutes.approvalHubMain);
          Fluttertoast.showToast(
            msg: "Expense skipped",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green[100],
            textColor: Colors.green[800],
          );
        }
        isLoadingGE2.value = false;
      } else {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: "Already skipped this expense!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange[100],
            textColor: Colors.orange[800],
          );
        }
        isLoadingGE2.value = false;
      }
    } catch (e) {
      isLoadingGE2.value = false;

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error skipping item: $e')));
      }
    }
  }

  // Clear skipped work items from memory and SharedPreferences
  Future<void> clearSkippedItems(BuildContext context) async {
    try {
      skippedWorkItems.clear(); // ✅ Clears Set<int>

      final storage = await prefs;
      await storage.remove('skippedWorkItems');

      showSkipButton.value = false;
      update(); // If using GetX

      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
        Fluttertoast.showToast(
          msg: "Skipped items cleared",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      }
    } catch (e) {
      //  // print('Error clearing skipped items: $e');
      rethrow;
    }
  }

  // Fetch approval data using unique workitemrecids
  Future<Map<String, dynamic>> fetchApprovalData(
    List<int> workitemrecids, {
    String? field,
    String? value,
  }) async {
    //  // print("=== Starting fetchApprovalData ===");
    //  // print("Original workitemrecids: $workitemrecids");
    //  // print("Filter - Field: $field, Value: $value");

    // Normalize workitemrecids
    final uniqueIds = workitemrecids.toSet().toList();
    final idsParam = uniqueIds.isEmpty ? '0' : uniqueIds.join(',');
    //  // print("Final workitemrecid param: $idsParam");

    // Build query parameters
    final Map<String, String> queryParams = {'workitemrecid': idsParam};

    // Add filter params if provided
    if (field != null && field.trim().isNotEmpty) {
      queryParams['field'] = field.trim();
    }
    if (value != null && value.trim().isNotEmpty) {
      queryParams['value'] = value.trim();
    }

    // // Construct URL with proper encoding
    // final uri = Uri.https(
    //   Uri.parse(Urls.baseURL).host,
    //   '/api/v1/masters/approvalmanagement/workflowapproval/userapproval',
    //   queryParams,
    // );
    final uri = Uri.parse(
      "${Urls.baseURL}/api/v1/masters/approvalmanagement/workflowapproval/userapproval",
    ).replace(queryParameters: queryParams);
    //  // print("Request URL: $uri");

    try {
      final response = await ApiService.get(uri);

      //  // print("Response status: ${response.statusCode}");
      // Uncomment next line in dev to see raw body
      //  //  // print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.isNotEmpty && jsonData[0] is Map<String, dynamic>) {
          //  // print("Successfully parsed approval data");
          return jsonData[0] as Map<String, dynamic>;
        } else {
          //  // print("No valid data found in response");
          throw Exception('Invalid or empty data structure returned from API');
        }
      } else {
        //  //  // print(
        //   "API Error - Status: ${response.statusCode}, Body: ${response.body}",
        // );
        throw Exception(
          'Failed to load approval data: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      //  // print("Exception during fetchApprovalData: $e");
      rethrow; // Re-throw after logging
    }
  }

  Future<Map<String, dynamic>> getEmailHubList({List<String>? statuses}) async {
    try {
      final uniqueStatuses = statuses?.toSet().toList() ?? [];
      final statusParam = uniqueStatuses.isEmpty
          ? ''
          : '?status=${uniqueStatuses.join(',')}';

      final url = Uri.parse(
        '${Urls.emailHubList}${Params.userId}&page=1&sort_order=asc',
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> listData = jsonDecode(response.body);

        return {
          'status': 'success',
          'emails': listData
              .map(
                (item) => EmailHubModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        };
      } else {
        throw Exception('Failed to fetch email hub list');
      }
    } catch (e) {
      throw Exception('Failed to fetch email hub list: $e');
    }
  }

  Future<EmailHubModel> getSpecificEmail(String emailId) async {
    try {
      final url = Uri.parse('${Urls.emailHubGetSpecific}?emailId=$emailId');

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null) {
          return EmailHubModel.fromJson(data['data']);
        } else {
          throw Exception('Email not found');
        }
      } else {
        throw Exception(
          'Failed to fetch specific email: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch specific email: $e');
    }
  }

  Future<void> processEmails(String emailIds) async {
    try {
      final payload = jsonEncode({'emailIds': emailIds, 'action': 'process'});

      final response = await ApiService.post(
        Uri.parse(Urls.emailHubProcess),

        body: payload,
      );

      if (response.statusCode != 200) {
        throw Exception('Processing failed');
      }
    } catch (e) {
      throw Exception('Failed to process emails: $e');
    }
  }

  Future<void> rejectEmails(String emailIds, String reason) async {
    try {
      final payload = jsonEncode({
        'emailIds': emailIds,
        'action': 'reject',
        'reason': reason,
      });

      final response = await ApiService.post(
        Uri.parse(Urls.emailHubReject),

        body: payload,
      );

      if (response.statusCode != 200) {
        throw Exception('Rejection failed');
      }
    } catch (e) {
      throw Exception('Failed to reject emails: $e');
    }
  }

  Future<void> fetchEmailDetails(int recId, BuildContext context) async {
    isLoadingGE2.value = true;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/forwardemailmanagement/fetch_specific_emails?RecId=$recId&screen_name=STPEmailHub',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      if (jsonList.isNotEmpty) {
        final email = ForwardedEmail.fromJson(jsonList[0]);

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EmailDetailPage(email: email)),
        );
        isLoadingGE2.value = false;
      } else {
        isLoadingGE2.value = false;

        throw Exception('No email data found.');
      }
    }
  }

  Future<void> fetchAndAppendReports() async {
    isLoadingGE1.value = true;
    final response = await ApiService.get(Uri.parse(Urls.reportsList));

    if (response.statusCode == 200) {
      isLoadingGE1.value = false;

      final List<dynamic> body = json.decode(response.body);

      getAllListReport.addAll(
        body.map((json) => ReportModels.fromJson(json)).toList(),
      );
      isLoadingGE1.value = false;
    } else {
      isLoadingGE1.value = false;

      throw Exception('Failed to load reports');
    }
  }

  Future<Map<String, dynamic>?> fetchReportDetails(int recId) async {
    try {
      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/reports/reports/reports?'
          'filter_query=STPReportsTables.RecId__eq=$recId&'
          'page=1&'
          'sort_order=asc&'
          'lock_id=$recId&'
          'screen_name=STPReportsTables',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data.first; // Return the first report if list is not empty
        }
        return null;
      } else {
        throw Exception('Failed to load report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }

  void navigateToEditReportScreen(
    BuildContext context,
    int recId,
    bool bool,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch report data
      final reportData = await fetchReportDetails(recId);

      // Close loading indicator
      Navigator.of(context).pop();

      if (reportData != null) {
        // Navigate to edit screen with the report data
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportCreateScreen(
              existingReport: reportData,
              isEdit: bool,
              isEditable: false,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Report not found')));
      }
    } catch (e) {
      // Close loading indicator if still showing
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(' ${e.toString()}')));
    }
  }

  Future<void> fetchAndCombineData() async {
    try {
      // API calls in parallel
      final responses = await Future.wait([
        ApiService.get(Uri.parse(Urls.expenseregistration)),
        ApiService.get(Uri.parse(Urls.cashadvanceanalytics)),
      ]);

      final expenseData = json.decode(responses[0].body) as List;
      final advanceData = json.decode(responses[1].body) as List;

      // Extract values (index based on API order)
      final approvedExpenses = expenseData[1];
      final pendingExpenses = expenseData[4];
      final approvedAdvances = advanceData[1];
      final pendingAdvances = advanceData[4];

      // Store in ManageExpensesCard list
      manageExpensesCards.value = [
        ManageExpensesCard(
          status: 'Approved Expenses (Total)',
          amount: (approvedExpenses['ApprovedAmount'] ?? 0).toDouble(),
          count: (approvedExpenses['ApprovedCount'] ?? 0).toInt(),
        ),
        ManageExpensesCard(
          status: 'Expenses In Progress (Total)',
          amount: (pendingExpenses['PendingAmount'] ?? 0).toDouble(),
          count: (pendingExpenses['PendingCount'] ?? 0).toInt(),
        ),
        ManageExpensesCard(
          status: 'Approved Advances (Total)',
          amount: (approvedAdvances['ApprovedAmount'] ?? 0).toDouble(),
          count: (approvedAdvances['ApprovedCount'] ?? 0).toInt(),
        ),
        ManageExpensesCard(
          status: 'Advances In Progress (Total)',
          amount: (pendingAdvances['PendingAmount'] ?? 0).toDouble(),
          count: (pendingAdvances['PendingCount'] ?? 0).toInt(),
        ),
      ];

      // Chart data (with amount + count)
      expenseChartData.value = manageExpensesCards
          .map(
            (card) => ExpenseAmountByStatus.fromJson(
              card.status,
              card.amount,
              card.count,
            ),
          )
          .toList();
    } catch (e) {
      //  // print('Error fetching analytics data: $e');
    }
  }

  List<GExpense> get filteredExpenses {
    return getAllListGExpense.where((item) {
      final query = searchQuery.value.toLowerCase();
      final typeFilter = selectedExpenseType.value;

      // ✅ Step 1: Match search query
      final matchesQuery =
          query.isEmpty ||
          item.expenseType.toLowerCase().contains(query) ||
          item.expenseId.toLowerCase().contains(query);

      // ✅ Step 2: Match expenseType dropdown
      final matchesExpenseType =
          (typeFilter == "All Expenses") || (item.expenseType == typeFilter);

      return matchesQuery && matchesExpenseType;
    }).toList();
  }

  List<BoardModel> get filteredboardList {
    return boardList.where((item) {
      final query = searchQuery.value.toLowerCase();

      // ✅ Step 1: Match search query
      final matchesQuery =
          query.isEmpty ||
          item.boardName.toLowerCase().contains(query) ||
          item.boardName.toLowerCase().contains(query);

      return matchesQuery;
    }).toList();
  }

  List<LeaveRequisition> get filteredLeaves {
    final query = searchQuery.value.toLowerCase();
    final statusFilter = selectedLeaveStatusDropDown.value;

    return leaveRequisitionList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.leaveCode.toLowerCase().contains(query) ||
          item.leaveId.toLowerCase().contains(query);

      final apiStatus = mapLeaveStatusToApi(statusFilter);

      final matchesStatus =
          apiStatus == null || item.approvalStatus == apiStatus;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<LeaveRequisition> get myTeamsfilteredLeaves {
    final query = searchQuery.value.toLowerCase();
    final statusFilter = selectedLeaveStatusDropDownmyTeam.value;

    return myTeamleaveRequisitionList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.leaveCode.toLowerCase().contains(query) ||
          item.leaveId.toLowerCase().contains(query);

      final apiStatus = mapLeaveStatusToApi(statusFilter);

      final matchesStatus =
          apiStatus == null || item.approvalStatus == apiStatus;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<LeaveCancellationModel> get myCancelationfilteredLeaves {
    final query = searchQuery.value.toLowerCase();
    final statusFilter = selectedLeaveStatusDropDownmyTeam.value;

    return myCancelationleaveRequisitionList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.leaveCancelId.toLowerCase().contains(query) ||
          item.leaveCancelId.toLowerCase().contains(query);

      final apiStatus = mapLeaveStatusToApi(statusFilter);

      final matchesStatus =
          apiStatus == null || item.approvalStatus == apiStatus;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<LeaveCancellationModel> get approvalsfilteredLeaves {
    final query = searchQuery.value.toLowerCase();
    // final statusFilter = selectedLeaveStatusDropDownmyTeam.value;

    return pendingApproval.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.leaveCancelId.toLowerCase().contains(query) ||
          item.leaveCancelId.toLowerCase().contains(query);

      return matchesQuery;
    }).toList();
  }

  List<ExpenseModel> get filteredpendingApprovals {
    return pendingApprovals.where((item) {
      final query = searchQuery.value.toLowerCase();
      final typeFilter = selectedExpenseType.value;

      // ✅ Step 1: Match search query
      final matchesQuery =
          query.isEmpty ||
          item.expenseType.toLowerCase().contains(query) ||
          item.expenseId.toLowerCase().contains(query);

      // ✅ Step 2: Match expenseType dropdown
      final matchesExpenseType =
          (typeFilter == "All Expenses") || (item.expenseType == typeFilter);

      return matchesQuery && matchesExpenseType;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchDataset(
    List<ReportMetaData> reportMetaData,
    BuildContext context,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Params.userToken}',
    };

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/masters/reports/conditions/reportsdata?functionalarea=ExpenseRequisition',
    );

    final body = json.encode(reportMetaData.map((e) => e.toJson()).toList());

    final response = await ApiService.post(url, body: body);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const ReportScreen(),
      //     ));
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception(
        'Failed to load data: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static const String _baseUrl =
      '${Urls.baseURL}/api/v1/masters/organizationmgmt/organizations/featureenablement?page=1&sort_order=asc';
  static const String _prefsKey = 'feature_enablement_data';

  // Fetch features from API and save to local storage
  Future<void> fetchAndStoreFeatures(String userToken) async {
    try {
      final response = await ApiService.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Feature> features = jsonData
            .map((item) => Feature.fromJson(item))
            .toList();

        // Save to SharedPreferences as JSON string
        final prefs = await SharedPreferences.getInstance();
        final jsonString = json.encode(jsonData);
        await prefs.setString(_prefsKey, jsonString);
      } else {
        throw Exception('Failed to load features: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Load features from local storage
  Future<List<Feature>> loadFeaturesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => Feature.fromJson(item)).toList();
  }

  // Flatten all features (including nested children) into a map for quick lookup
  Future<Map<String, bool>> getAllFeatureStates() async {
    final features = await loadFeaturesFromStorage();
    final Map<String, bool> featureMap = {};

    void addFeatureRecursive(Feature feature) {
      featureMap[feature.id] = feature.isEnable;
      for (var child in feature.children) {
        addFeatureRecursive(child);
      }
    }

    for (var feature in features) {
      addFeatureRecursive(feature);
    }

    return featureMap;
  }

  // Check if a specific feature is enabled
  Future<bool> isFeatureEnabled(String featureId) async {
    final featureStates = await getAllFeatureStates();
    return featureStates[featureId] ?? false;
  }

  Future<void> updateFeatureVisibility() async {
    //  // print(showMileage.value);
    showMileage.value = await isFeatureEnabled("EnableMileage");
    showPerDiem.value = await isFeatureEnabled("EnablePerdiem");
    showExpense.value = await isFeatureEnabled("EnableGeneralExpense");
    showCashAdvance.value = await isFeatureEnabled(
      "EnableCashAdvanceRequisition",
    );
  }

  Future<List<TaskModel>> fetchTasks({
    required String boardId,
    required int taskRecId,
  }) async {
    final uri = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/tasks/taskslist'
      '?BoardId=$boardId&TaskRecId=$taskRecId',
    );

    final response = await ApiService.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded['Tasks'] ?? [];

      return list.map((e) => TaskModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<List<BoardMember>> fetchBoardMembers(String boardId) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/boards/boardmembers/boardmemberslist'
      '?screen_name=KANBoardMembers&BoardId=$boardId',
    );

    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((e) => BoardMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final message = responseData['detail']['message'];
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[00],
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      return <BoardMember>[];
    }
  }

  Widget buildCategoryIcon(String iconPath) {
    if (iconPath.startsWith('data:image')) {
      try {
        final base64Data = iconPath.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(bytes, height: 24, width: 24, fit: BoxFit.contain);
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.redAccent);
      }
    } else {
      return Image.asset(iconPath, height: 24, width: 24, fit: BoxFit.contain);
    }
  }

  Future<void> fetchCustomFieldValues(String fieldId) async {
    final url =
        "${Urls.baseURL}/api/v1/masters/fieldmanagement/customfields/customfieldlistvalues?filter_query=STPCustomFieldListValues.FieldId__eq%3D$fieldId&page=1&sort_order=asc";

    final response = await ApiService.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final options = data.map((e) => CustomDropdownValue.fromJson(e)).toList();

      // ✅ Find index inside customFields (used in UI)
      final index = customFields.indexWhere(
        (field) => field['FieldId'] == fieldId,
      );

      if (index != -1) {
        customFields[index]['Options'] = options;
        customFields.refresh(); // ✅ Refresh UI
      }
    } else {
      //  // print('Failed to load dropdown values: ${response.statusCode}');
    }
  }

  String updateRole(String url, String role) {
    // Remove all role=XYZ params
    url = url.replaceAll(RegExp(r'([&?])role=[^&]*'), '');

    // Remove trailing ? or &
    url = url.replaceAll(RegExp(r'[?&]$'), '');

    // Add correct role param
    return url.contains('?') ? "$url&role=$role" : "$url?role=$role";
  }

  Dashboard? currentDashboard;

  // Cache of responses per widget name
  // final Map<String, WidgetDataResponse> widgetDataCache = {};

  // bool isLoading = false;
  Future<void> loadDashboards() async {
    try {
      final list = await fetchDashboardWidgets(); // your existing API function
      dashboards.assignAll(list);
      if (dashboards.isNotEmpty) {
        // Pick first dashboard by default
        selectedDashboard.value = dashboards.first;
        await onDashboardChanged(dashboards.first);
      }
    } catch (e) {
      // debugPrint('Failed to load dashboards: $e');
      rethrow;
    }
  }

  //  final Map<String, WidgetDataResponse> widgetDataCache = {};
  // --- Called when user picks a dashboard from the dropdown ---
  Future<void> onDashboardChanged(Dashboard dashboard) async {
    selectedDashboard.value = dashboard;

    // extract roles from dashboardData items
    final extracted = dashboard.dashboardData
        .map((d) => d.currentRole?.trim() ?? '')
        .where((r) => r.isNotEmpty)
        .toSet()
        .toList();

    availableRoles.assignAll(extracted);

    // default role
    if (availableRoles.isNotEmpty) {
      currentRole.value = availableRoles.first;
    } else {
      currentRole.value = '';
    }

    // fetch widgets for the default role
    await changeRole(currentRole.value, dashboardToUse: dashboard);
  }

  // --- Change role (and optionally use dashboard to filter) ---
  Future<void> changeRole(String newRole, {Dashboard? dashboardToUse}) async {
    if (newRole == currentRole.value && dashboardToUse == null) return;

    currentRole.value = newRole;

    if (dashboardToUse != null) {
      // build a filtered Dashboard that only contains dashboardData items for the role
      final filtered = Dashboard(
        dashBoardType: dashboardToUse.dashBoardType,
        dashBoardName: dashboardToUse.dashBoardName,
        dashBoardTitle: dashboardToUse.dashBoardTitle,
        description: dashboardToUse.description,
        userId: dashboardToUse.userId,
        dashBoardRecId: dashboardToUse.dashBoardRecId,
        recId: dashboardToUse.recId,
        isDefault: dashboardToUse.isDefault,
        dashboardData: dashboardToUse.dashboardData
            .where(
              (d) =>
                  (d.currentRole ?? '').toLowerCase() == newRole.toLowerCase(),
            )
            .toList(),
      );

      await fetchWidgetsFromDashboard(filtered);
    } else {
      // If no dashboard provided, use currently selected dashboard
      final dash = selectedDashboard.value;
      if (dash != null) {
        final filtered = Dashboard(
          dashBoardType: dash.dashBoardType,
          dashBoardName: dash.dashBoardName,
          dashBoardTitle: dash.dashBoardTitle,
          description: dash.description,
          userId: dash.userId,
          dashBoardRecId: dash.dashBoardRecId,
          recId: dash.recId,
          isDefault: dash.isDefault,
          dashboardData: dash.dashboardData
              .where(
                (d) =>
                    (d.currentRole ?? '').toLowerCase() ==
                    newRole.toLowerCase(),
              )
              .toList(),
        );
        await fetchWidgetsFromDashboard(filtered);
      }
    }
  }

  // --- Use Dashboard.dashboardData items as your "wizard" configs ---
  List<DashboardDataItem> getWizardsForCurrentRole() {
    final dash = selectedDashboard.value;
    if (dash == null) return [];
    for (var item in dash.dashboardData) {
      //        //  // print("""
      // ID: ${item.filterProps?.widgetName}
      // Title: ${item.filterProps?.roleId}
      // currentRole: ${item.currentRole}
      // -------------------------------
      // """);
    }
    final role = currentRole.value.toLowerCase();
    //  // print("rolerole${currentRole.value.toLowerCase()}");
    // Use dashboardData (the list of widgets), not dashBoardType
    return dash.dashboardData;
  }

  // --- Fetch each widget's data (keeps your existing implementation, but uses dashboardData items) ---
  Future<void> fetchWidgetsFromDashboard(Dashboard dashboard) async {
    isLoadingWidgets.value = true;
    widgetDataCache.clear();

    try {
      final widgetsToCall = dashboard.dashboardData;

      // 1️⃣ Create futures (no await here)
      final List<Future<void>> futures = widgetsToCall.map((item) {
        return fetchWidgetDataFromEndpoint(item);
      }).toList();

      // 2️⃣ Wait for ALL widget APIs together
      await Future.wait(futures);
    } finally {
      isLoadingWidgets.value = false;
    }
  }

  /// Fetch a widget's data using DashboardDataItem (dashboard.dashboardData element)
  Future<void> fetchWidgetDataFromEndpoint(DashboardDataItem item) async {
    try {
      final endpoint = item.filterProps!.widgetName;
      final widgetName = item.filterProps?.widgetName ?? '';
      String sortBy = "y";
      String extraParams = "";

      if (widgetName == "ExpensesThisMonth" ||
          widgetName == "TotalCashAdvances") {
        sortBy = "Value";
        extraParams = "&start_date=1764527400000&end_date=1767205799998";
      } else if (widgetName == "ExpensesByProjects" ||
          widgetName == "ExpensesByCountries") {
        sortBy = "y";
      } else if (widgetName == "TotalExpenses" ||
          widgetName == "NoOfMyPendingApprovalsCard" ||
          widgetName == "NoOfEscalations" ||
          widgetName == "MyPendingApprovals") {
        sortBy = "Value";
      } else {
        sortBy = "YAxis";
      }
      if (widgetName == "DraftExpenses") {
        await _fetchDraftExpenses();
        return;
      }
      final url = Uri.parse(
        "${Urls.baseURL}/api/v1/dashboard/widgets/$widgetName"
        "?role=${item.filterProps?.roleId}$extraParams&page=1&limit=10&sort_by=$sortBy&sort_order=asc",
      );

      final response = await ApiService.get(
        url,
        // headers: {
        //   "Content-Type": "application/json",
        //   "Authorization": "Bearer ${Params.userToken ?? ''}",
        //   "DigiSessionID": digiSessionId.toString(),
        // },
      );

      //  // debugPrint(
      //   "➡️ Fetching widget: ${item.filterProps?.widgetName} | $endpoint",
      // );

      //  // debugPrint("⬅️ Response ${item.widgetName}: ${response.statusCode}");

      // 2️⃣ Validate success
      if (response.statusCode != 200) {
        //  // debugPrint("❌ Failed to load widget ${item.widgetName} | HTTP ${response.statusCode}");
        return;
      }

      final decoded = jsonDecode(response.body);

      // 3️⃣ Parse data
      final widgetResponse = WidgetDataResponse.fromJson(decoded);

      // 4️⃣ Select proper cache key
      final cacheKey = item.filterProps!.widgetName.isNotEmpty
          ? item.filterProps!.widgetName
          : endpoint;

      widgetDataCache[cacheKey] = widgetResponse;
      update();
    } catch (e, stack) {
      // 5️⃣ Improved error logging
      //  // debugPrint(
      //   "❌ Exception while fetching widget ${item.filterProps!.widgetName}: $e",
      // );
      //  // debugPrint("📌 Stacktrace: $stack");
    }
  }

  String getWidgetType(String widgetName) {
    const lineCharts = [
      'CashAdvanceTrends',
      'ExpenseTrends',
      'CashAdvanceReturnTrends',
      'leavehistory',
      'EmployeesLeaveConnectedWithWeekends',
      "PolicyComplianceRateForCashAdvances",
    ];
    const MultibarCharts = ['ExpensesByCategories', "ExpenseBySource"];
    const barCharts = [
      'ExpensesByProjects',
      'RepeatedPolicyViolationsByEmployeesForCashAdvances',
      'SumOfCashAdvancesByApprovalStatus',
      'NoOfCashAdvancesByApprovalStatus',
      'CashAdvancesByBusinessJustification',
      'Top5CashAdvanceRequesters',
      'NoOfExpensesByStatus',
      'Top10ExpenseCategoriesByLocations',
      'top5leavecodevsleaves',
      'leavetypevsleaves',
    ];

    const pieCharts = [
      'ExpenseAmountByExpenseStatus',
      'SumOfCashAdvancesByApprovalStatus',
      'ExpensesAmountByApprovalStatus',
    ];

    const donutCharts = ['ExpensesByPaymentMethods'];

    const summaryBoxes = [
      'TotalCashAdvances',
      'TotalExpenses',
      'ExpensesThisMonth',
      'NoOfMyPendingApprovalsCard',
      'TotalLeaveMonth',
      'NoOfEscalations',
      "NoOfAutoRejectedApprovals",
      "NoOfAutoApprovedExpenses",
      "NoOfApprovalDelegations",
      "AverageExpenseByEmployees",
      "totleavemonth",
    ];

    const tableWidgets = [
      'ExpensesByCountries',
      'LeaveBalanceOverview',
      'PendingApprovals',
    ];
    const tableWidgetsExpense = ['DraftExpenses'];

    if (lineCharts.contains(widgetName)) return 'LineChart';
    if (barCharts.contains(widgetName)) return 'BarChart';
    if (MultibarCharts.contains(widgetName)) return 'MultiBarChart';
    if (pieCharts.contains(widgetName)) return 'PieChart';
    if (donutCharts.contains(widgetName)) return 'DonutChart';
    if (summaryBoxes.contains(widgetName)) return 'SummaryBox';
    if (tableWidgets.contains(widgetName)) return 'Table';
    if (tableWidgetsExpense.contains(widgetName)) return 'ExpenseTable';

    return 'Generic';
  }

  // Example helper to get cached widget data
  WidgetDataResponse? getWidgetData(String widgetName) =>
      widgetDataCache[widgetName];

  // Unique method names as requested
  Future<List<DashboardByRole>> fetchDashboardWidgetsForSpenders() async {
    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/dashboard/dashboard/widgets?filter_query=SYSWidgets.RoleIdSpender&page=1&sort_order=asc",
    );
    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((item) => DashboardByRole.fromJson(item)).toList();
      } else {
        //  // print("decodedCall");
        return [];
      }
    } else {
      throw Exception("Failed to load dashboards: ${response.statusCode}");
    }
  }

  Future<void> loadSpendersDashboards(String role) async {
    try {
      isLoading.value = true;

      // 1️⃣ Fetch dashboard config
      final list = await fetchDashboardWidgetsForSpenders();
      dashboardByRole.assignAll(list);

      // 2️⃣ Get widgets for current role
      final widgets = getSpendersWidgetsForCurrentRole(role);

      // 3️⃣ Fire ALL widget APIs in parallel
      final futures = widgets.map((item) {
        return fetchSpendersWidgetData(item, role);
      }).toList();

      await Future.wait(futures);

      update();
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> onSpendersDashboardChanged(DashboardByRole dashboard) async {
  //   selectedDashboardByrole.value = dashboard;
  //   final roles = dashboard.widgetName
  //       .map((d) => d.currentRole.trim())
  //       .where((r) => r.isNotEmpty)
  //       .toSet()
  //       .toList();
  //   availableRoles.assignAll(roles);
  //   currentRole.value = availableRoles.isNotEmpty ? availableRoles.first : '';
  //   await changeSpendersRole(currentRole.value, dashboardToUse: dashboard);
  // }

  // Future<void> changeSpendersRole(String role, {Dashboard? dashboardToUse}) async {
  //   // if (role == currentRole.value && dashboardToUse == null) return;
  //   // currentRole.value = role;

  //   // Dashboard effective = dashboardToUse ??
  //   //     (selectedDashboard.value ??
  //   //         Dashboard(dashBoardName: 'none', dashBoardTitle: '', dashboardData: []));

  //   // final filtered = Dashboard(
  //   //   dashBoardName: effective.dashBoardName,
  //   //   dashBoardTitle: effective.dashBoardTitle,
  //   //   dashboardData: effective.dashboardData
  //   //       .where((d) => (d.currentRole ?? '').toLowerCase() == role.toLowerCase())
  //   //       .toList(),
  //   // );

  //   // await fetchSpendersWidgets(filtered);

  //    if (role == currentRole.value && dashboardToUse == null) return;

  //   currentRole.value = role;

  //   if (dashboardToUse != null) {
  //     // build a filtered Dashboard that only contains dashboardData items for the role
  //     final filtered = Dashboard(
  //       dashBoardType: dashboardToUse.dashBoardType,
  //       dashBoardName: dashboardToUse.dashBoardName,
  //       dashBoardTitle: dashboardToUse.dashBoardTitle,
  //       description: dashboardToUse.description,
  //       userId: dashboardToUse.userId,
  //       dashBoardRecId: dashboardToUse.dashBoardRecId,
  //       recId: dashboardToUse.recId,
  //       isDefault: dashboardToUse.isDefault,
  //       dashboardData: dashboardToUse.dashboardData
  //           .where((d) => (d.currentRole ?? '').toLowerCase() == role.toLowerCase())
  //           .toList(),
  //     );

  //     await fetchSpendersWidgets(filtered);
  //   } else {
  //     // If no dashboard provided, use currently selected dashboard
  //     final dash = selectedDashboard.value;
  //     if (dash != null) {
  //       final filtered = Dashboard(
  //         dashBoardType: dash.dashBoardType,
  //         dashBoardName: dash.dashBoardName,
  //         dashBoardTitle: dash.dashBoardTitle,
  //         description: dash.description,
  //         userId: dash.userId,
  //         dashBoardRecId: dash.dashBoardRecId,
  //         recId: dash.recId,
  //         isDefault: dash.isDefault,
  //         dashboardData: dash.dashboardData
  //             .where((d) => (d.currentRole ?? '').toLowerCase() == role.toLowerCase())
  //             .toList(),
  //       );
  //       await fetchSpendersWidgets(filtered);
  //     }
  //   }
  // }

  // // Use this to get the current widgets list for UI
  Future<void> openExportSelection(BuildContext context, String role) async {
    final widgets = getSpendersWidgetsForCurrentRole(role);

    if (widgets.isEmpty) {
      Get.snackbar('No widgets', 'Nothing to export for the selected role');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SpendersExportSelector(
          widgets: widgets,
          onExportSelected: (selected) async {
            await _exportSelectedWidgets(selected);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  Future<void> _exportSelectedWidgets(
    List<DashboardByRole> selectedWidgets,
  ) async {
    isExporting.value = true;

    try {
      final itemsWithKeys = <MapEntry<DashboardByRole, GlobalKey>>[];

      // Get keys for selected widgets
      for (final widgetItem in selectedWidgets) {
        final widgetName = widgetItem.widgetName ?? '';
        final key = widgetRenderKeys[widgetName] ?? GlobalKey();

        // Store the key if it doesn't exist
        if (!widgetRenderKeys.containsKey(widgetName)) {
          widgetRenderKeys[widgetName] = key;
        }

        itemsWithKeys.add(MapEntry(widgetItem, key));
      }

      // Export to PDF
      await SpendersExportService.exportWidgetsToPdfDynamic(itemsWithKeys);
    } catch (e) {
      Get.snackbar('Export Error', 'Failed to export: $e');
    } finally {
      isExporting.value = false;
    }
  }

  List<DashboardByRole> getSpendersWidgetsForCurrentRole(String roleId) {
    return dashboardByRole
        .where(
          (w) => w.roleId?.trim().toLowerCase() == roleId.trim().toLowerCase(),
        )
        .toList();
  }

  Future<void> fetchSpendersWidgets(List<DashboardByRole> widgetsList) async {
    isLoadingWidgets.value = true;
    widgetDataCache.clear();
    widgetRenderKeys.clear();

    try {
      // 1️⃣ Create keys first (no await here)
      for (final item in widgetsList) {
        final keyName = item.widgetName ?? DateTime.now().toIso8601String();
        widgetRenderKeys[keyName] = GlobalKey();
      }

      // 2️⃣ Create API futures
      final List<Future<void>> futures = widgetsList
          .where((item) => item.roleId != null)
          .map((item) {
            return fetchSpendersWidgetData(item, item.roleId!);
          })
          .toList();

      // 3️⃣ Await ALL APIs at the same time
      await Future.wait(futures);
    } finally {
      isLoadingWidgets.value = false;
    }
  }

  // Future<void> _fetchDraftExpenses() async {
  //   try {
  //     final email = Params.userId ?? "";

  //     final url = Uri.parse(
  //       "${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expenseheader"
  //       "?filter_query=EXPExpenseHeader.CreatedBy__eq%3D$email"
  //       "%26EXPExpenseHeader.ApprovalStatus__eq%3DCreated"
  //       "&page=1&sort_order=asc",
  //     );

  //     final response = await ApiService.get(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer ${Params.userToken ?? ''}",
  //         "DigiSessionID": digiSessionId.toString(),
  //       },
  //     );

  //     if (response.statusCode != 200) return;

  //     final decoded = jsonDecode(response.body);
  //  getAllListGExpense.value = (data as List)
  //             .map((item) => GExpense.fromJson(item))
  //             .toList();

  //         isLoadingGE1.value = false;
  //          //  // print("Fetched Expenses: $getAllListGExpense");

  //         return getAllListGExpense;
  //     if (decoded is! List) {
  //        // debugPrint("DraftExpenses API did not return a List");
  //       return;
  //     }

  //     widgetDataCache["DraftExpenses"] = WidgetDataResponse.fromJson({
  //       "list": decoded,       // store list directly
  //       "count": decoded.length,
  //     });

  //   } catch (e, s) {
  //      // debugPrint("Error fetching DraftExpenses: $e\n$s");
  //   }
  // }
  Future<List<GExpense>> _fetchDraftExpenses() async {
    isLoadingGE1.value = true;
    final email = Params.userId ?? "";

    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expenseheader"
      "?filter_query=EXPExpenseHeader.CreatedBy__eq%3D$email"
      "%26EXPExpenseHeader.ApprovalStatus__eq%3DCreated"
      "&page=1&sort_order=asc",
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        getAllListGExpense.value = (data as List)
            .map((item) => GExpense.fromJson(item))
            .toList();

        //  // print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return [];
      } else {
        //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  // print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<void> fetchSpendersWidgetData(
    DashboardByRole item,
    String role,
  ) async {
    try {
      final widgetName = item.widgetName ?? '';
      if (widgetName.isEmpty) return;

      // SPECIAL CASE: DraftExpenses → different API
      if (widgetName == "DraftExpenses") {
        await _fetchDraftExpenses();
        return;
      }

      // DEFAULT BEHAVIOR for all other widgets
      String sortBy = "y";
      String extraParams = "";

      if (widgetName == "ExpensesThisMonth" ||
          widgetName == "TotalCashAdvances") {
        sortBy = "Value";
        extraParams = "&start_date=1764527400000&end_date=1767205799998";
      } else if (widgetName == "ExpensesByProjects" ||
          widgetName == "ExpensesByCountries") {
        sortBy = "y";
      } else if (widgetName == "TotalExpenses" ||
          widgetName == "NoOfMyPendingApprovalsCard" ||
          widgetName == "NoOfEscalations") {
        sortBy = "Value";
      } else {
        sortBy = "YAxis";
      }

      final url = Uri.parse(
        "${Urls.baseURL}/api/v1/dashboard/widgets/$widgetName"
        "?role=$role$extraParams&page=1&limit=10&sort_by=$sortBy&sort_order=asc",
      );

      final response = await ApiService.get(url);

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);

      widgetDataCache[widgetName] = WidgetDataResponse.fromJson(decoded);
    } catch (e, s) {
      //  // debugPrint("Error fetching widget $widgetName: $e\n$s");
    }
  }

  WidgetDataResponse? getSpendersWidgetData(String widgetName) =>
      widgetDataCache[widgetName];

  // String getSpendersWidgetType(String widgetName) {
  //   const lineCharts = [
  //     'CashAdvanceTrends',
  //     'ExpenseTrends',
  //     'CashAdvanceReturnTrends',
  //     'leavehistory',
  //     'EmployeesLeaveConnectedWithWeekends',
  //   ];

  //   const barCharts = [
  //     'ExpensesByCategories',
  //     'ExpensesByProjects',
  //     'RepeatedPolicyViolationsByEmployeesForCashAdvances',
  //     'SumOfCashAdvancesByApprovalStatus',
  //     'NoOfCashAdvancesByApprovalStatus',
  //     'CashAdvancesByBusinessJustification',
  //     'Top5CashAdvanceRequesters',
  //     'ExpenseBySource',
  //     'NoOfExpensesByStatus',
  //     'Top10ExpenseCategoriesByLocations',
  //     'Top5Leavecodevsleaves',
  //     'LeaveTypeVsLeaves',
  //   ];

  //   const pieCharts = [
  //     'ExpenseAmountByExpenseStatus',
  //     'SumOfCashAdvancesByApprovalStatus',
  //     "ExpensesAmountByApprovalStatus"
  //   ];

  //   const donutCharts = ['ExpensesByPaymentMethods'];

  //   const summaryBoxes = [
  //     'TotalCashAdvances',
  //     'TotalExpenses',
  //     'ExpensesThisMonth',
  //     'NoOfMyPendingApprovalsCard',
  //     'TotalLeaveMonth',
  //     'NoOfEscalations'
  //   ];

  //   const tableWidgets = [
  //     'DraftExpenses',
  //     'ExpensesByCountries',
  //     'LeaveBalanceOverview',
  //     'PendingApprovals',
  //   ];

  //   if (lineCharts.contains(widgetName)) return 'LineChart';
  //   if (barCharts.contains(widgetName)) return 'BarChart';
  //   if (pieCharts.contains(widgetName)) return 'PieChart';
  //   if (donutCharts.contains(widgetName)) return 'DonutChart';
  //   if (summaryBoxes.contains(widgetName)) return 'SummaryBox';
  //   if (tableWidgets.contains(widgetName)) return 'Table';
  //   return 'Generic';
  // }
  List<CartesianSeries<ProjectExpensebycategory, String>>
  convertMultiSeriesChart(Map<String, dynamic> data) {
    if (data.isEmpty) return [];

    final xAxisRaw = data['XAxis'];
    final yAxisRaw = data['YAxis'];

    // Safety checks
    if (xAxisRaw == null || yAxisRaw == null) return [];
    if (xAxisRaw is! List || yAxisRaw is! List) return [];

    final xAxis = List<String>.from(xAxisRaw);
    final yAxisGroups = List<Map<String, dynamic>>.from(yAxisRaw);

    final List<CartesianSeries<ProjectExpensebycategory, String>> seriesList =
        [];

    int seriesIndex = 0;

    for (var group in yAxisGroups) {
      final String name = group['name'] ?? 'Series $seriesIndex';
      final List<dynamic>? values = group['data'] as List<dynamic>?;

      if (values == null) continue;

      final List<ProjectExpensebycategory> chartPoints = [];

      for (int i = 0; i < xAxis.length; i++) {
        final yVal = (i < values.length && values[i] != null)
            ? (values[i] as num).toDouble()
            : 0.0;

        chartPoints.add(
          ProjectExpensebycategory(
            x: xAxis[i],
            y: yVal,
            color: Colors
                .primaries[seriesIndex % Colors.primaries.length]
                .shade300,
          ),
        );
      }

      seriesList.add(
        ColumnSeries<ProjectExpensebycategory, String>(
          name: name,
          dataSource: chartPoints,
          xValueMapper: (dp, _) => dp.x,
          yValueMapper: (dp, _) => dp.y,
          pointColorMapper: (dp, _) => dp.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      );

      seriesIndex++;
    }

    return seriesList;
  }

  List<ChartDataPoint> convertSpendersChartPoints(WidgetDataResponse data) {
    final points = <ChartDataPoint>[];
    final raw = data.raw;

    // -----------------------------------
    // Case 1: XAxis + YAxis (Simple Charts)
    // -----------------------------------
    if (raw is Map && raw.containsKey('XAxis') && raw.containsKey('YAxis')) {
      final xAxis = List<String>.from(raw['XAxis'] ?? []);
      final yAxis = List<dynamic>.from(raw['YAxis'] ?? []);

      for (var i = 0; i < xAxis.length; i++) {
        final yVal = i < yAxis.length ? yAxis[i] : 0;
        points.add(
          ChartDataPoint(x: xAxis[i], y: (yVal is num) ? yVal.toDouble() : 0.0),
        );
      }
      return points;
    }

    // -----------------------------------
    // Case 2: raw['data'] is a List
    // -----------------------------------
    if (raw is Map && raw['data'] is List) {
      final List list = raw['data'];

      for (final element in list) {
        if (element is Map) {
          final x =
              element['period'] ??
              element['category'] ??
              element['label'] ??
              element['x'] ??
              '';
          final y =
              element['amount'] ??
              element['value'] ??
              element['y'] ??
              element['count'] ??
              0;

          final yDouble = (y is num)
              ? y.toDouble()
              : double.tryParse(y.toString()) ?? 0.0;

          if (x.toString().isNotEmpty) {
            points.add(ChartDataPoint(x: x.toString(), y: yDouble));
          }
        }
      }

      return points;
    }

    // -----------------------------------
    // Case 3: raw IS a List (your new format)
    // MUST check raw is List before iterating!
    // -----------------------------------
    if (raw is List) {
      final list = raw as List<dynamic>;
      for (final element in list) {
        if (element is Map &&
            element.containsKey('x') &&
            element.containsKey('y')) {
          final x = element['x'];
          final y = element['y'];

          final yDouble = (y is num)
              ? y.toDouble()
              : double.tryParse(y.toString()) ?? 0.0;

          points.add(ChartDataPoint(x: x.toString(), y: yDouble));
        }
      }

      return points;
    }

    return points;
  }

  List<LeaveDetailsModel> leaves = [];

  // Map by local date (Y,M,D) to list of transactions
  final Map<DateTime, List<LeaveDetailsModel>> events = {};

  // Currently selected day and events
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  List<LeaveDetailsModel> get selectedEvents =>
      events[_dayKey(selectedDay)] ?? [];

  Future<void> loadCalendarLeaves() async {
    leaves = await fetchCalendarLeaves();

    buildEventMap(leaves); // <-- REQUIRED

    // notifyListeners(); // <-- REQUIRED
  }

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);
  Future<List<LeaveDetailsModel>> fetchCalendarLeaves() async {
    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/fetchcalendarleaves",
    );

    final payload = {
      "scope": "my_leaves",
      "scope_filters": null,
      "from_date": 1763231400000,
      "to_date": 1768501799998,
    };

    final response = await ApiService.post(url, body: jsonEncode(payload));

    if (response.statusCode == 200) {
      final List raw = jsonDecode(response.body);

      return raw.map((e) => LeaveDetailsModel.fromJson(e)).toList();
      // _buildEventMap();
    } else {
      throw Exception(
        'Failed to fetch calendar leaves: ${response.statusCode}',
      );
    }
  }

  Future<void> loadFromApi(String url) async {
    // implement your API GET and parse JSON then call _buildEventMap
    // after parsing set leaves and call _buildEventMap(); then notifyListeners();
  }

  void buildEventMap(List<LeaveDetailsModel> leaves) {
    events.clear();

    for (final leave in leaves) {
      final start = DateTime.fromMillisecondsSinceEpoch(leave.fromDate);
      final end = DateTime.fromMillisecondsSinceEpoch(leave.toDate);

      DateTime day = start;
      while (day.isBefore(end) || isSameDay(day, end)) {
        final key = DateTime(day.year, day.month, day.day);
        events.putIfAbsent(key, () => []);

        // Create a new LeaveDetailsModel for each day with the current date
        final dayLeave = LeaveDetailsModel(
          leaveId: leave.leaveId,
          applicationDate: leave.applicationDate,
          reasonForLeave: leave.reasonForLeave,
          employeeId: leave.employeeId,
          employeeName: leave.employeeName,
          fromDate: leave.fromDate,
          fromDateHalfDay: leave.fromDateHalfDay,
          fromDateHalfDayValue: leave.fromDateHalfDayValue,
          leaveCode: leave.leaveCode,
          reliever: leave.reliever,
          toDate: leave.toDate,
          toDateHalfDay: leave.toDateHalfDay,
          toDateHalfDayValue: leave.toDateHalfDayValue,
          recId: leave.recId,
          projectId: leave.projectId,
          notifyHR: leave.notifyHR,
          notifyTeamMembers: leave.notifyTeamMembers,
          notifyingUserIds: leave.notifyingUserIds,
          outOfOfficeMessage: leave.outOfOfficeMessage,
          isLeaveUnPaid: leave.isLeaveUnPaid,
          emergencyContactNumber: leave.emergencyContactNumber,
          availabilityDuringLeave: leave.availabilityDuringLeave,
          leaveLocation: leave.leaveLocation,
          duration: leave.duration,
          leaveBalance: leave.leaveBalance,
          approvalStatus: leave.approvalStatus,
          leaveDateType: leave.leaveDateType,
          calendarId: leave.calendarId,
          leaveStatus: leave.leaveStatus,
          leaveColor: leave.leaveColor,
          leaveTransactions: leave.leaveTransactions,
          leaveCustomFieldValues: leave.leaveCustomFieldValues,
        );

        events[key]!.add(dayLeave);

        day = day.add(const Duration(days: 1));
      }
    }
  }

  String? calendarId;

  void onDaySelected(DateTime day, DateTime focused) {
    selectedDay = day;
    focusedDay = focused;
    // notifyListeners();
  }

  void changeFormat(CalendarFormat format) {
    calendarFormat = format;
    // notifyListeners();
  }

  Future<void> createLeaveTransactions({
    required String employeeId,
    required int fromDate,
    required int toDate,
    required String leaveCode,
  }) async {
    leaveDays.clear();
    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/createleavetransactions",
    );

    final payload = {
      "EmployeeId": employeeId,
      "FromDate": fromDate,
      "ToDate": toDate,
      "LeaveCode": leaveCode,
    };
    final response = await ApiService.post(url, body: jsonEncode(payload));

    if (response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      calendarId = decoded["CalendarId"] ?? "";
      final List<dynamic> transactions = decoded["LeaveTransactions"] ?? [];

      leaveDays.addAll(
        transactions.map((e) => LeaveTransactionModel.fromJson(e)).toList(),
      );
      debugPrint("Leave Transactions Created");
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail']['message'] ?? 'Expense created';

      Fluttertoast.showToast(
        msg: "$message ",
        backgroundColor: Colors.red[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      debugPrint("Error: ${response.body}");
    }
  }

  Future<bool> submitLeaveRequestFinal(
    context,
    LeaveRequest request, {
    bool submit = false,
    bool resubmit = false,
  }) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/requestleave'
      '?functionalentity=LeaveRequisition'
      '&submit=$submit'
      '&resubmit=$resubmit'
      '&screen_name=MyLeaves',
    );

    final response = await ApiService.post(
      url,

      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail']['message'] ?? 'Expense created';

      resetForm();
      Navigator.pushNamed(context, AppRoutes.leaveDashboard);
      Fluttertoast.showToast(
        msg: "$message ",
        backgroundColor: Colors.green[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.green[800],
        fontSize: 16.0,
      );
      return true;
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail']['message'] ?? 'Expense created';

      Fluttertoast.showToast(
        msg: "$message ",
        backgroundColor: Colors.red[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<bool> reviewUpdateLeaveRequestFinal(
    context,
    LeaveRequest request, {
    bool submit = false,
  }) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/approverreview?updateandaccept=$submit&screen_name=PendingApproval',
    );

    final response = await ApiService.put(
      url,
      // headers: {
      //   'Authorization': 'Bearer ${Params.userToken}',
      //   'Content-Type': 'application/json',
      //   'DigiSessionID': digiSessionId.toString(),
      // },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //  // debugPrint("✅ Leave request submitted successfully");
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail']['message'] ?? 'Expense created';
      // final recId = responseData['detail']['RecId'];
      resetForm();
      Navigator.pushNamed(context, AppRoutes.leaveDashboard);
      Fluttertoast.showToast(
        msg: "$message ",
        backgroundColor: Colors.green[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.green[800],
        fontSize: 16.0,
      );
      return true;
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final message = responseData['detail'] ?? 'Expense created';

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      //  // debugPrint(
      //   "❌ Leave request failed: ${response.statusCode} ${response.body}",
      // );
      return false;
    }
  }

  Future<LeaveDetailsModel?> fetchSpecificLeaveDetails(
    BuildContext context,
    int recId,
    bool readOnly,
  ) async {
    isLoadingLeaves.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/leavedetails'
      '?recid=$recId&lock_id=$recId&screen_name=LVRLeaveHeader',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final leaveDetails = LeaveDetailsModel.fromJson(data);

        isLoadingLeaves.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.viewLeave,
          arguments: {
            'item': leaveDetails,
            'readOnly': readOnly,
            'status': false,
          },
        );

        return leaveDetails;
      } else {
        isLoadingLeaves.value = false;
        //  // debugPrint('Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      isLoadingLeaves.value = false;
      //  // debugPrint('Error fetching leave details: $e');
      return null;
    }
  }

  Future<LeaveDetailsModel?> fetchSpecificLeaveDetailsCacelation(
    BuildContext context,
    int recId,
    bool readOnly,
  ) async {
    isLoadingGE2.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/leavemanagement/leavecancellation/leavecancellationdetails'
      '?recid=$recId&lock_id=$recId&screen_name=LVRLeaveCancellationHeader',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final leaveDetails = LeaveDetailsModel.fromJson(data);

        isLoadingGE2.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.viewLeave,
          arguments: {
            'item': leaveDetails,
            'readOnly': readOnly,
            'status': false,
          },
        );

        return leaveDetails;
      } else {
        isLoadingGE2.value = false;
        //  // debugPrint('Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      isLoadingGE2.value = false;
      // debugPrint('Error fetching leave details: $e');
      return null;
    }
  }

  Future<LeaveDetailsModel?> fetchSpecificApprovalDetails(
    BuildContext context,
    int recId,
    bool readOnly,
    bool isEmpty,
  ) async {
    isLoadingGE2.value = true;

    late Uri url;

    if (isEmpty) {
      // 👉 when empty case
      url = Uri.parse(
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/detailedapproval'
        '?workitemrecid=$recId&lock_id=$recId&screen_name=MyPendingApproval',
      );
    } else {
      // 👉 normal case
      url = Uri.parse(
        '${Urls.baseURL}/api/v1/leavemanagement/leavecancellation/detailedapproval'
        '?workitemrecid=$recId&lock_id=$recId&screen_name=MyPendingApproval',
      );
    }

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final leaveDetails = LeaveDetailsModel.fromJson(data);

        Navigator.pushNamed(
          context,
          AppRoutes.viewLeave,
          arguments: {
            'item': leaveDetails,
            'readOnly': readOnly,
            'status': false,
          },
        );

        return leaveDetails;
      } else {
        // debugPrint('Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // debugPrint('Error fetching leave details: $e');
      return null;
    } finally {
      isLoadingGE2.value = false;
    }
  }

  /// ---------------- SELECTION STATE ----------------
  RxSet<String> selectedPayslipIds = <String>{}.obs;

  bool isSelected(String id) => selectedPayslipIds.contains(id);

  void toggleSelection(String id) {
    selectedPayslipIds.contains(id)
        ? selectedPayslipIds.remove(id)
        : selectedPayslipIds.add(id);
  }

  void clearSelection() => selectedPayslipIds.clear();

  /// ---------------- GET SELECTED ITEMS ----------------
  List<PayrollsTeams> getSelectedPayslips(List<PayrollsTeams> source) {
    return source
        .where((e) => selectedPayslipIds.contains(e.recId.toString()))
        .toList();
  }

  Future<File> generatePayslipPdf(List<PayrollsTeams> payslips) async {
    final pdf = pw.Document();
    final dir = await getApplicationDocumentsDirectory();

    // ✅ Unicode-safe Google Font
    final font = await PdfGoogleFonts.nunitoExtraLight();

    for (final p in payslips) {
      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(base: font),
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Payslip", style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 12),

              pw.Text(
                "Employee Name: ${p.employeeName}",
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                "Employee ID: ${p.employeeId}",
                style: pw.TextStyle(fontSize: 14),
              ),

              if (p.paymentDate != null)
                pw.Text(
                  "Payment Date: ${DateFormat('dd-MM-yyyy').format(p.paymentDate!)}",
                  style: pw.TextStyle(fontSize: 14),
                ),

              pw.SizedBox(height: 8),

              pw.Text(
                "Payslip Type: ${p.type}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text("Source: ${p.source}", style: pw.TextStyle(fontSize: 14)),

              pw.SizedBox(height: 12),
              pw.Divider(),
            ],
          ),
        ),
      );
    }

    final file = File(
      "${dir.path}/Payslip_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// ---------------- DOWNLOAD ----------------
  Future<void> downloadPayslips(List<PayrollsTeams> payslips) async {
    print("Call Here ");
    if (payslips.isEmpty) return;
    await downloadPayrollPdf(payslips);
    // clearSelection();
  }

  /// ---------------- EMAIL ----------------
  // Future<void> emailPayslips(
  //   List<GExpense> payslips,
  //   String userEmail,
  // ) async {
  //   if (payslips.isEmpty) return;

  //   final file = await generatePayslipPdf(payslips);

  //   final email = Email(
  //     subject: 'Payslip Details',
  //     body: 'Please find attached payslip(s).',
  //     recipients: [userEmail],
  //     attachmentPaths: [file.path],
  //     isHTML: false,
  //   );

  //   await FlutterEmailSender.send(email);
  //   clearSelection();
  // }
  RxList<PayrollsTeams> payrollList = <PayrollsTeams>[].obs;
  RxSet<String> selectedIds = <String>{}.obs;

  /// Toggle checkbox
  void toggleSelectionRole(String id) {
    selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);
  }

  bool isSelectedRole(String id) => selectedIds.contains(id);
  RxBool isPayrollLoading = true.obs;
  RxBool isDownloadingPayslips = false.obs;
  RxBool isEmailingPayslips = false.obs;

  /// Selected payrolls
  List<PayrollsTeams> get selectedPayrolls =>
      payrollList.where((e) => selectedIds.contains(e.employeeId)).toList();

  Future<void> downloadPayrollPdf(List<PayrollsTeams> payrolls) async {
    // ✅ Create document FIRST
    final PdfDocument document = PdfDocument();

    document.security.userPassword = '1234'; // 🔐 PDF password
    document.security.ownerPassword = 'admin';

    final PdfPage page = document.pages.add();
    final PdfGraphics g = page.graphics;

    final PdfFont headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      18,
      style: PdfFontStyle.bold,
    );

    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

    double y = 0;

    g.drawString(
      'Payroll Report',
      headerFont,
      bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 30),
    );

    y += 40;

    for (final p in payrolls) {
      g.drawString(
        'Employee Name: ${p.employeeName}',
        bodyFont,
        bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
      );
      y += 20;

      g.drawString(
        'Employee ID: ${p.employeeId}',
        bodyFont,
        bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
      );
      y += 20;

      if (p.paymentDate != null) {
        g.drawString(
          'Payment Date: ${DateFormat('dd-MM-yyyy').format(p.paymentDate!)}',
          bodyFont,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
        );
        y += 20;
      }

      g.drawString(
        'Payroll ID: ${p.employeeId}',
        bodyFont,
        bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
      );
      y += 20;

      g.drawString(
        'Amount: ₹ ${p.periodStartDate}',
        bodyFont,
        bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
      );
      y += 30;
    }

    final List<int> bytes = document.saveSync();
    document.dispose();

    final Uint8List pdfBytes = Uint8List.fromList(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Payroll_Report.pdf');
    await file.writeAsBytes(pdfBytes);

    await Printing.sharePdf(
      bytes: pdfBytes, // ✅ FIXED
      filename: 'Payroll_Report.pdf',
    );
  }
}
