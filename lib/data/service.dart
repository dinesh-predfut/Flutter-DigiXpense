// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:convert' as request;
import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart'
    show PermissionHelper;
import 'package:diginexa/data/pages/screen/ALl_Expense_Screens/GeneralExpense/Reports%20for%20Expense/reportsCreateForm.dart';
import 'package:diginexa/data/pages/screen/CashAdvanceRequest/Reports%20for%20CashAdvanse/reportsCreateForm.dart';
import 'package:diginexa/data/pages/screen/Leave_Section/My_Leave/Reports%20for%20Leave/reportsCreateForm.dart';
import 'package:diginexa/data/pages/screen/TimeSheet/Reports%20for%20Leave/reportsCreateForm.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:diginexa/data/pages/ApprovalHub/ApprovalPages/externalApproval.dart';
import 'package:diginexa/data/pages/screen/Punch-In_Punch-out/createPunchIn-out.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart'
    show
        ImageCropper,
        CropAspectRatio,
        AndroidUiSettings,
        CroppedFile,
        IOSUiSettings;
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart' show PdfEncryption;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/API_Service/apiService.dart'
    show ApiService;
import 'package:diginexa/data/pages/screen/ALl_Expense_Screens/Reports/reportsCreateForm.dart';
import 'package:diginexa/data/pages/screen/Dashboard_Screen/DashboardItemsByrole/spenders.dart';
import 'package:diginexa/data/pages/screen/Task_Board/addmoreetailsTask.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:diginexa/main.dart';
import 'package:diginexa/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as Apiservice;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:diginexa/core/constant/Parames/models.dart' hide ChecklistItem;
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/core/constant/url.dart';
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

enum TimerStatus { idle, running, paused, completed, cancelled }

enum TrackerTab { runs, segments, events }

class Controller extends GetxController {
  // Localization Preferences Controllers
  final TextEditingController timezoneController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController localeController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController dateFormatController = TextEditingController();
  final TextEditingController emailChipController = TextEditingController();
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
  RxBool isPublic = true.obs;
  RxInt employeeDropdownRefresh = 0.obs;
  TextEditingController boardNameController = TextEditingController();
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskIdController = TextEditingController();
  RxString? titleName = ''.obs;
  RxInt tagDropdownRefresh = 0.obs;
  RxInt memberDropdownRefresh = 0.obs;
  RxInt groupDropdownRefresh = 0.obs;
  // Controller
  var paidAmountError = ''.obs;
  // Controller.dart
  var isReceiptRequired = false.obs;
  var itemisationMandatory = false.obs;
  var minExpenseAmount = 0.0.obs;
  var maxExpenseAmount = 0.0.obs;
  var receiptRequiredLimit = 0.0.obs;
  var unitAmountErrorText = ''.obs;
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
  String? lastCurrency1;
  String? lastAmount1;
  ExchangeRateResponse? cachedExchange1;
  RxString leaveSearchQuery = "".obs;
  RxString boardNameErrorMsg = "".obs;
  String? lastCurrency2;
  String? lastAmount2;

  ExchangeRateResponse? cachedExchange2;
  ExchangeRateResponse? cachedExchangeResponse;
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
  RxBool isReimbursableEnabled = true.obs;
  RxBool isPageLoading = false.obs;
  RxBool showPercentageError = false.obs;

  RxMap<int, String> partialCancelSelection = <int, String>{}.obs;
  RxList<LeaveRequisition> leaveRequisitionList = <LeaveRequisition>[].obs;
  RxList<TimesheetModel> timesheetList = <TimesheetModel>[].obs;
  RxList<TimesheetModel> myTeamtimesheetList = <TimesheetModel>[].obs;
  RxList<TeamAttendance> attendanceList = <TeamAttendance>[].obs;
  RxList<TimesheetModel> sheetsPendingApprovalsList = <TimesheetModel>[].obs;
  RxList<LeaveRequisition> myTeamleaveRequisitionList =
      <LeaveRequisition>[].obs;
  RxList<LeaveCancellationModel> myCancelationleaveRequisitionList =
      <LeaveCancellationModel>[].obs;
  final isSaving = false.obs;
  RxList<LeaveCancellationModel> pendingApproval =
      <LeaveCancellationModel>[].obs;
  int? workitemrecid;
  RxList<PayslipAnalyticsCard> payslipAnalyticsCards =
      <PayslipAnalyticsCard>[].obs;
  RxString selectedReferenceType = ''.obs;
  bool isCreating = false;
  bool timerClicked = false;
  final List<String> referenceTypes = [
    'Expense',
    'Project',
    'Travel',
    'Cash Advance',
    'Payment Proposal',
  ];
  final Map<String, String> dialCodeToIso = {
    '+1': 'US',
    '+7': 'RU',
    '+20': 'EG',
    '+27': 'ZA',
    '+30': 'GR',
    '+31': 'NL',
    '+32': 'BE',
    '+33': 'FR',
    '+34': 'ES',
    '+36': 'HU',
    '+39': 'IT',
    '+40': 'RO',
    '+41': 'CH',
    '+43': 'AT',
    '+44': 'GB',
    '+45': 'DK',
    '+46': 'SE',
    '+47': 'NO',
    '+48': 'PL',
    '+49': 'DE',
    '+51': 'PE',
    '+52': 'MX',
    '+53': 'CU',
    '+54': 'AR',
    '+55': 'BR',
    '+56': 'CL',
    '+57': 'CO',
    '+58': 'VE',
    '+60': 'MY',
    '+61': 'AU',
    '+62': 'ID',
    '+63': 'PH',
    '+64': 'NZ',
    '+65': 'SG',
    '+66': 'TH',
    '+81': 'JP',
    '+82': 'KR',
    '+84': 'VN',
    '+86': 'CN',
    '+90': 'TR',
    '+91': 'IN',
    '+92': 'PK',
    '+93': 'AF',
    '+94': 'LK',
    '+95': 'MM',
    '+98': 'IR',
    '+211': 'SS',
    '+212': 'MA',
    '+213': 'DZ',
    '+216': 'TN',
    '+218': 'LY',
    '+220': 'GM',
    '+221': 'SN',
    '+222': 'MR',
    '+223': 'ML',
    '+224': 'GN',
    '+225': 'CI',
    '+226': 'BF',
    '+227': 'NE',
    '+228': 'TG',
    '+229': 'BJ',
    '+230': 'MU',
    '+231': 'LR',
    '+232': 'SL',
    '+233': 'GH',
    '+234': 'NG',
    '+235': 'TD',
    '+236': 'CF',
    '+237': 'CM',
    '+238': 'CV',
    '+239': 'ST',
    '+240': 'GQ',
    '+241': 'GA',
    '+242': 'CG',
    '+243': 'CD',
    '+244': 'AO',
    '+245': 'GW',
    '+248': 'SC',
    '+249': 'SD',
    '+250': 'RW',
    '+251': 'ET',
    '+252': 'SO',
    '+253': 'DJ',
    '+254': 'KE',
    '+255': 'TZ',
    '+256': 'UG',
    '+257': 'BI',
    '+258': 'MZ',
    '+260': 'ZM',
    '+261': 'MG',
    '+262': 'RE',
    '+263': 'ZW',
    '+264': 'NA',
    '+265': 'MW',
    '+266': 'LS',
    '+267': 'BW',
    '+268': 'SZ',
    '+269': 'KM',
    '+290': 'SH',
    '+291': 'ER',
    '+297': 'AW',
    '+298': 'FO',
    '+299': 'GL',
    '+350': 'GI',
    '+351': 'PT',
    '+352': 'LU',
    '+353': 'IE',
    '+354': 'IS',
    '+355': 'AL',
    '+356': 'MT',
    '+357': 'CY',
    '+358': 'FI',
    '+359': 'BG',
    '+370': 'LT',
    '+371': 'LV',
    '+372': 'EE',
    '+373': 'MD',
    '+374': 'AM',
    '+375': 'BY',
    '+376': 'AD',
    '+377': 'MC',
    '+378': 'SM',
    '+380': 'UA',
    '+381': 'RS',
    '+382': 'ME',
    '+383': 'XK',
    '+385': 'HR',
    '+386': 'SI',
    '+387': 'BA',
    '+389': 'MK',
    '+420': 'CZ',
    '+421': 'SK',
    '+423': 'LI',
    '+500': 'FK',
    '+501': 'BZ',
    '+502': 'GT',
    '+503': 'SV',
    '+504': 'HN',
    '+505': 'NI',
    '+506': 'CR',
    '+507': 'PA',
    '+508': 'PM',
    '+509': 'HT',
    '+590': 'GP',
    '+591': 'BO',
    '+592': 'GY',
    '+593': 'EC',
    '+594': 'GF',
    '+595': 'PY',
    '+596': 'MQ',
    '+597': 'SR',
    '+598': 'UY',
    '+599': 'CW',
    '+670': 'TL',
    '+672': 'NF',
    '+673': 'BN',
    '+674': 'NR',
    '+675': 'PG',
    '+676': 'TO',
    '+677': 'SB',
    '+678': 'VU',
    '+679': 'FJ',
    '+680': 'PW',
    '+681': 'WF',
    '+682': 'CK',
    '+683': 'NU',
    '+685': 'WS',
    '+686': 'KI',
    '+687': 'NC',
    '+688': 'TV',
    '+689': 'PF',
    '+690': 'TK',
    '+691': 'FM',
    '+692': 'MH',
    '+850': 'KP',
    '+852': 'HK',
    '+853': 'MO',
    '+855': 'KH',
    '+856': 'LA',
    '+880': 'BD',
    '+886': 'TW',
    '+960': 'MV',
    '+961': 'LB',
    '+962': 'JO',
    '+963': 'SY',
    '+964': 'IQ',
    '+965': 'KW',
    '+966': 'SA',
    '+967': 'YE',
    '+968': 'OM',
    '+970': 'PS',
    '+971': 'AE',
    '+972': 'IL',
    '+973': 'BH',
    '+974': 'QA',
    '+975': 'BT',
    '+976': 'MN',
    '+977': 'NP',
    '+992': 'TJ',
    '+993': 'TM',
    '+994': 'AZ',
    '+995': 'GE',
    '+996': 'KG',
    '+998': 'UZ',
  };
  RxBool isAmountCalculating = false.obs;
  bool get anyButtonLoading => buttonLoaders.values.any((e) => e == true);
  // Employee Selection
  RxList<Employee> employees = <Employee>[].obs;
  RxList<Employee> selectedEmployees = <Employee>[].obs;
  RxList<EmployeeGroup> employeeGroups = <EmployeeGroup>[].obs;
  RxList<EmployeeGroup> selectedGroups = <EmployeeGroup>[].obs;

  final Rx<TaskModel?> selectTast = Rx<TaskModel?>(null);
  List<BoardMember> boardMembers = [];
  List<BoardMember> boardAllemployeeMembers = [];

  List<TaskModel> tasksValue = [];
  RxList<BoardMember> selectedMembers = <BoardMember>[].obs;
  final Rx<Shelf?> selectedBoard = Rx<Shelf?>(null);
  // RxList<KanbanBoard> selectedBoard= <KanbanBoard>[].obs;
  RxList<TaskModel> selectedDependency = <TaskModel>[].obs;
  RxList<TagModel> selectedTags = <TagModel>[].obs;
  final Rx<BoardMember?> selectedSettingsMembers = Rx<BoardMember?>(null);
  // Loading States
  RxBool isLoading = false.obs;
  RxBool isLoadingOCR = false.obs;

  final RxBool isSavingMember = false.obs;
  RxBool isLogoutLoading = false.obs;
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

  Future<bool> removeAttachment(AttachmentModel attachment) async {
    try {
      final response = await deleteAttachment(attachment.recId);

      if (response) {
        return true; // ✅ success
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  bool validateBoardForm() {
    bool isValid = true;

    final value = boardNameController.text;

    // ❌ Empty or only spaces
    if (value.trim().isEmpty) {
      showBoardNameError.value = true;
      boardNameErrorMsg.value = "Board name is required";
      return false;
    }

    // ❌ Leading space
    if (value.startsWith(' ')) {
      showBoardNameError.value = true;
      boardNameErrorMsg.value = "Should not start with space";
      return false;
    }

    // ❌ Trailing space
    if (value.endsWith(' ')) {
      showBoardNameError.value = true;
      boardNameErrorMsg.value = "Should not end with space";
      return false;
    }

    // ❌ Only spaces / no valid characters
    if (!RegExp(r'[a-zA-Z0-9]').hasMatch(value)) {
      showBoardNameError.value = true;
      boardNameErrorMsg.value = "Enter valid board name";
      return false;
    }

    return isValid;
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
    bool? showNotes,
    bool? showChecklist,
    double estimatedHours = 0,
    String? status,
    List<TagModel> selectedTags = const [],
    List<BoardMember> selectedMembers = const [],
    CardTypeModel? selectedCardType,
    TaskModel? parentTask,
    List<TaskModel> selectedDependencies = const [],
    int? actualHours,
    String? version,
    String? dependentDescription,
    context,
    String? bordeId,
    List<ChecklistItem>? checkLists,
    bool? main,
    required Map<String, String?> taskData,
    DateTime? plannedStartDate,
    DateTime? plannedEndDate,
    required String riskLevel,
  }) async {
    try {
      // Prepare payload
      // / Prepare payload - fix for dependencies
      final payload = {
        "TaskName": taskName,

        "TaskData": {
          "Actual Hours": actualHours ?? 0,
          "Parent Task": parentTask?.taskId ?? "",
          "Estimated Hours": estimatedHours ?? 0,
          "Card Types": selectedCardType?.boardCardId ?? "",
          "Risk Level": riskLevel ?? "",
          "Dependency": selectedDependencies.isNotEmpty
              ? selectedDependencies.map((d) => d.taskId).join(',')
              : "",
        },

        "Notes": notes ?? "",
        "ShowNotes": showNotes,
        "ShowChecklist": showChecklist,

        "EstimatedHours": estimatedHours ?? 0,
        "ActualHours": actualHours ?? 0,

        "Status": status ?? "",
        "Priority": priority,

        // 🟢 Planned Dates (milliseconds)
        "PlannedStartDate": plannedStartDate?.millisecondsSinceEpoch,
        "PlannedEndDate": plannedEndDate?.millisecondsSinceEpoch,

        // 🟢 Actual Dates (milliseconds)
        "ActualStartDate": startDate?.millisecondsSinceEpoch,
        "ActualEndDate": dueDate?.millisecondsSinceEpoch,

        "TagId": selectedTags.isNotEmpty
            ? selectedTags.map((t) => t.tagId).join(',')
            : "",

        "AssignedTo": selectedMembers.isNotEmpty
            ? selectedMembers.map((m) => m.userId).join(',')
            : "",

        "CardType": selectedCardType?.boardCardId ?? "",

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

        "CheckLists":
            checkLists?.map((item) {
              return {
                "Description": item.description,
                "Status": item.status ?? false,
                "RecId": item.recId ?? 0,
              };
            }).toList() ??
            [],

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
        // print('Task updated successfully');
        return true;
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
        // print('Failed to update task: ${response.statusCode}');

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed  to Update task ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // print('Error updating task: $e');
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
  RxBool sheetEnable = false.obs;

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
  RxBool percentageError = false.obs;

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
  int? expenseId;
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
  final TextEditingController allowedPercentage = TextEditingController();
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
  final RxList<LeaveAnalyticsFilter> leaveCodesFilter =
      <LeaveAnalyticsFilter>[].obs;

  // Field configurations
  final RxList<LeaveFieldConfig> fieldConfigsLeave = <LeaveFieldConfig>[].obs;

  // Selected values
  final Rx<LeaveAnalytics?> selectedLeaveCode = Rx<LeaveAnalytics?>(null);
  // final Rx<LeaveAnalyticsFilter?> selectedleaveCodesFilter = Rx<LeaveAnalyticsFilter?>(null);
  // final RxList<LeaveAnalyticsFilter> selectedleaveCodesFilter = <LeaveAnalyticsFilter>[].obs;
  RxList<LeaveAnalyticsFilter> selectedleaveCodesFilter =
      <LeaveAnalyticsFilter>[].obs;
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
      final start = DateFormat('dd-MM-yyyy').format(startDate.value!);
      final end = DateFormat('dd-MM-yyyy').format(endDate.value!);
      datesController.text = '$start - $end';
    } else {
      final start = DateFormat('dd-MM-yyyy').format(today);
      final end = DateFormat('dd-MM-yyyy').format(today);

      datesController.text = '$start - $end';

      // set startDate and endDate using millisecondsSinceEpoch
      startDate.value = DateTime.fromMillisecondsSinceEpoch(
        today.millisecondsSinceEpoch,
        isUtc: true,
      );

      endDate.value = DateTime.fromMillisecondsSinceEpoch(
        today.millisecondsSinceEpoch,
        isUtc: true,
      );
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
    final data = jsonDecode(response.body);
    // print("STATUS => ${response.statusCode}");
    // print("RAW RESPONSE => ${response.body}");
    String message = data['detail']?['message'] ?? data['message'] ?? "Error";
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
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
      );
      Navigator.pop(context);
      throw Exception('Failed to load task details: ${response.statusCode}');
    }
  }

  Future<List<KanbanStatus>> fetchStatuses(String bordeId) async {
    final response = await ApiService.get(
      Uri.parse(
        "${Urls.baseURL}/api/v1/kanban/status/status/status"
        "?filter_query=KANStatus.BoardId__eq%3D$bordeId%26KANStatus.IsActive__eq%3DTrue"
        "&page=1&sort_order=asc",
      ),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      final List list = responseData; // ✅ directly list

      return list.map((e) => KanbanStatus.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load statuses");
    }
  }

  bool showAttachment = true;
  var fieldVisibility = <String, bool>{}.obs;
  Future<void> fetchCardFields(String boardId) async {
    try {
      final url = Uri.parse(
        "https://api.digixpense.com/api/v1/kanban/boards/cardfields/cardfieldslist?BoardId=$boardId&screen_name=KANKanbanCardFields",
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final list = data.map((e) => CardFieldConfig.fromJson(e)).toList();

        /// Convert to Map
        fieldVisibility.value = {
          for (var item in list) item.fieldName: item.isEnabled,
        };
      } else {
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  bool isEnabled(String key) {
    return fieldVisibility[key] == true;
  }

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
    fileItems.clear();
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
    // setButtonLoading('submit', true);

    //  //  // print("CallSubmit");
    if (!_validateForm() && !submit) {
      //  //  // print("CallSubmitErro");
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
      employeeName: Params.employeeName ?? userName.value,
      applicationDate: DateTime.now().millisecondsSinceEpoch,
      calendarId: calendarId!,
      duration: totalRequestedDays.value.toInt(),
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
      workitemrecid: workitemrecid,

      totalDays: totalRequestedDays.value.toInt(),
      // status: submit ? 'Submitted' : 'Draft',
      fromDateHalfDay: false,
      fromDateHalfDayValue: null,
      leaveBalance: leaveBalance!.toDouble(),
      toDateHalfDay: false,
      transactions: leaveDays,
    );

    try {
      await reviewUpdateLeaveRequestFinal(
        context,
        leaveRequest,
        submit: submit,
      );
      // await ApiService().submitLeaveRequest(leaveRequest, isDraft);

      if (context.mounted) {
        // Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit leave request: $e');
    } finally {}
  }

  RxBool isFullPageLoading = false.obs;

  // Method to set full page loading
  void setFullPageLoading(bool loading) {
    isFullPageLoading.value = loading;
  }

  Future<void> submitLeaveRequest(
    BuildContext context,
    bool submit,
    bool resubmit,
  ) async {
    if (totalRequestedDays.value == 0 || totalRequestedDays.value == 0.0) {
      Fluttertoast.showToast(
        msg: "Total Leaves 0 not Vaild ",
        backgroundColor: Colors.orange,
      );
      return;
    }
    if (!_validateForm() && !submit) {
      return;
    }
    // for (final tx in leaveTransactions) {
    //   String derivedDayType = 'FullDay';

    //   if (tx.leaveFirstHalf && !tx.leaveSecondHalf) {
    //     derivedDayType = 'FirstHalf';
    //   } else if (!tx.leaveFirstHalf && tx.leaveSecondHalf) {
    //     derivedDayType = 'SecondHalf';
    //   }

    //   final leaveDay = LeaveTransactionModel(
    //     employeeId: tx.employeeId,
    //     transDate: tx.transDate,
    //     noOfDays: tx.noOfDays,
    //     leaveCode: tx.leaveCode,
    //     leaveFirstHalf: tx.leaveFirstHalf,
    //     leaveSecondHalf: tx.leaveSecondHalf,
    //     isHoliday: tx.isHoliday,
    //     recId: tx.recId,
    //     originalDayType: derivedDayType,
    //     dayType: derivedDayType.obs,
    //     dayTypeLeave: derivedDayType.obs,
    //     approvalStatus: tx.approvalStatus,
    //   );
    //   debugPrint("leaveDay completed$leaveDay");
    //   leaveDays.add(leaveDay);
    //   // totalRequestedDays.value += leaveDay.calculatedDays;
    // }

    fileItems.clear();
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
    final code = countryCodeController.text.trim();
    final phone = phoneController.text.trim();
    final leaveRequest = LeaveRequest(
      leaveId: leaveID ?? leaveIdcontroller.text,
      recId: recID,
      employeeId: Params.employeeId,
      employeeName: Params.employeeName ?? userName.value,
      applicationDate: DateTime.now().millisecondsSinceEpoch,
      calendarId: calendarId ?? '',
      duration: totalRequestedDays.value.toInt(),
      leaveCode: selectedLeaveCode.value?.leaveCode,
      projectId: projectDropDowncontroller.text,
      relieverId: selectedReliever.value?.id,
      startDate: startDate.value,
      endDate: endDate.value,
      location: selectedLocation?.location,
      notifyingUsers: selectedNotifyingUsers.map((e) => e.id).toList(),
      contactNumber:
          "${code.startsWith('+') ? code : '+$code'} ${formatPhone(phone)}",
      comments: comments.value,
      availabilityDuringLeave: selectedAvailability.value,
      outOfOfficeMessage: outOfOfficeMessage.value,
      notifyHR: notifyHR.value,
      notifyTeam: notifyTeam.value,
      isPaidLeave: isPaidLeave.value,
      attachments: [DocumentAttachmentbase64(file: fileItems)],

      // status: submit ? 'Submitted' : 'Draft',
      fromDateHalfDay: false,
      fromDateHalfDayValue: null,
      leaveBalance: leaveBalance!.toDouble(),
      toDateHalfDay: false,
      transactions: leaveDays,
      totalDays: totalRequestedDays.value.toInt(),
    );

    try {
      // setButtonLoading('submit', true);
      await submitLeaveRequestFinal(
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
    } finally {
      setButtonLoading('submit', false);
    }
  }

  String formatPhone(String phone) {
    final clean = phone.replaceAll(' ', '');
    if (clean.length <= 5) return clean;
    return "${clean.substring(0, 5)} ${clean.substring(5)}";
  }

  RxList<LeaveTransactionModel> leaveDays = <LeaveTransactionModel>[].obs;
  RxList<LeaveTransactionforLeave> leaveTransactions =
      <LeaveTransactionforLeave>[].obs;
  RxMap<int, String> modifiedDays = <int, String>{}.obs;

  RxDouble totalRequestedDays = 0.0.obs;
  void calculateTotalDays() {
    double total = 0;
    for (final day in leaveDays) {
      print("totalRequestedDays.value${day.calculatedDays}");
      total += day.calculatedDays;
    }
    totalRequestedDays.value = total;
    // print("totalRequestedDays.value${totalRequestedDays.value}");
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

  RxList<LeaveEmployee> employeesFilter = <LeaveEmployee>[].obs;

  RxList<LeaveEmployee> selectedEmployeesFilter = <LeaveEmployee>[].obs;
  RxString selectedType = ''.obs;

  RxBool showEmployeeField = false.obs;

  RxString employeeLabel = "Employees *".obs;

  String scopeFilters = "my_leaves";
  final employeeController = TextEditingController();

  RxString selectedScope = "department_leaves".obs;

  Future<void> fetchEmployeesFilter() async {
    employeesFilter.clear();
    final payload = {"scope": scopeFilters, "scope_filters": null};

    final response = await ApiService.post(
      Uri.parse(
        "${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/fetchleaveemployeeids",
      ),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      employeesFilter.value = data
          .map((e) => LeaveEmployee.fromJson(e))
          .toList();
    }
  }

  Future<void> fetchLeaveCodes() async {
    final response = await ApiService.get(
      Uri.parse(
        "${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/fetchleavecodes?page=1&sort_order=asc&choosen_fields=Description,LeaveCode",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      leaveCodesFilter.value = (data as List)
          .map((e) => LeaveAnalyticsFilter.fromJson(e))
          .toList();
    }
  }

  void resetFilters() {
    selectedEmployeesFilter.clear();
    scopeFilters = 'my_leaves';
    selectedleaveCodesFilter.clear();
    showEmployeeField.value = false;
    selectedAvailability.value = "All";
    availabilityController.text = "All";
    selectedType.value = "My Leave";
    typeController.text = "My Leave";
  }

  void loadExistingLeaveRequest(LeaveDetailsModel leaveRequest) {
    debugPrint("loadExistingLeaveRequest started");

    /// ---------------- Leave Code ----------------
    final leaveCodeMatch = leaveCodes.firstWhereOrNull(
      (c) => c.leaveCode == leaveRequest.leaveCode,
    );

    selectedLeaveCode.value = leaveCodeMatch;
    leaveCodeController.text = leaveCodeMatch?.leaveCode ?? '';
    leaveBalance = leaveCodeMatch?.leaveBalance;
    fetchCalenderIDLeaveTransactions(
      employeeId: Params.employeeId,
      fromDate: leaveRequest.fromDate,
      toDate: leaveRequest.toDate,
      leaveCode: leaveRequest.leaveCode,
    );

    /// ---------------- Project ----------------
    if (leaveRequest.projectId != null) {
      final projectMatch = project.firstWhereOrNull(
        (p) => p.code == leaveRequest.projectId,
      );

      selectedProject = projectMatch;
      projectDropDowncontroller.text = projectMatch?.name ?? '';
    }
    final transactions = leaveRequest.leaveTransactions;

    if (transactions.isNotEmpty) {
      transactions.sort((a, b) => a.transDate.compareTo(b.transDate));

      startDate.value = DateTime.fromMillisecondsSinceEpoch(
        transactions.first.transDate,
        isUtc: true,
      ).toLocal();

      endDate.value = DateTime.fromMillisecondsSinceEpoch(
        transactions.last.transDate,
        isUtc: true,
      ).toLocal();
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

    updateDatesController();

    /// ---------------- Location ----------------
    if (leaveRequest.leaveLocation != null) {
      final locationMatch = locations.firstWhereOrNull(
        (l) => l.location == leaveRequest.leaveLocation,
      );
      // print("locationController.text${leaveRequest.leaveLocation}");
      selectedLocation = locationMatch;
      locationController.text = leaveRequest.leaveLocation ?? '';
    }

    /// ---------------- Notifying Users ----------------
    selectedNotifyingUsers.clear();

    if (leaveRequest.notifyingUserIds != null) {
      for (final userId in leaveRequest.notifyingUserIds!) {
        final user = employees.firstWhereOrNull((e) => e.id == userId);
        if (user != null) {
          selectedNotifyingUsers.add(user);
        }
      }
    }

    /// ---------------- Applied Date ----------------
    appliedDateController.text = DateFormat('dd-MM-yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(
        leaveRequest.applicationDate,
        isUtc: true,
      ),
    );

    /// ---------------- Other Fields ----------------
    leavephoneController.text = leaveRequest.emergencyContactNumber ?? '';

    totalRequestedDays.value = leaveRequest.duration;
    leaveID = leaveRequest.leaveId;
    leaveIdcontroller.text = leaveRequest.leaveId;

    employeeName.text = leaveRequest.employeeName;
    leaveCancelID.text = leaveRequest.leaveCancelId ?? '';
    employeeIdController.text = leaveRequest.employeeId ?? '';
    comments.value = leaveRequest.reasonForLeave ?? '';
    commentsController.text = comments.value;
    if (leaveRequest.workitemrecid != null) {
      workitemrecid = leaveRequest.workitemrecid!;
    }

    selectedAvailability.value = leaveRequest.availabilityDuringLeave ?? '';
    availabilityController.text = selectedAvailability.value;

    recID = leaveRequest.recId;

    outOfOfficeMessage.value = leaveRequest.outOfOfficeMessage ?? '';
    outOfOfficeMessageController.text = outOfOfficeMessage.value;

    notifyHR.value = leaveRequest.notifyHR;
    notifyTeam.value = leaveRequest.notifyTeamMembers;

    /// ---------------- Leave Transactions ----------------
    leaveDays.clear();
    // totalRequestedDays.value = 0.0;

    for (final tx in leaveRequest.leaveTransactions) {
      String derivedDayType = 'FullDay';

      if (tx.leaveFirstHalf && !tx.leaveSecondHalf) {
        derivedDayType = 'FirstHalf';
      } else if (!tx.leaveFirstHalf && tx.leaveSecondHalf) {
        derivedDayType = 'SecondHalf';
      }
      print("noOfDays${tx.noOfDays}");
      if (tx.leaveCancelId == null) {
        print("leaveCode${tx.leaveCode}");
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
          approvalStatus: tx.approvalStatus,
        );

        leaveDays.add(leaveDay);
        // totalRequestedDays.value += leaveDay.calculatedDays;
      } else {
        print("leaveCancelId${tx.leaveCancelId}");
        final leaveDay = LeaveTransactionModel(
          transDate: tx.transDate,
          noOfDays: tx.noOfDays,

          leaveFirstHalf: tx.leaveFirstHalf,
          leaveSecondHalf: tx.leaveSecondHalf,
          isHoliday: tx.isHoliday,
          recId: tx.recId,
          originalDayType: derivedDayType,
          dayType: derivedDayType.obs,
          dayTypeLeave: derivedDayType.obs,
          approvalStatus: tx.approvalStatus,
        );

        leaveDays.add(leaveDay);
        // totalRequestedDays.value += leaveDay.calculatedDays;
      }
    }
    calculateTotalDays();

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
    Future.microtask(() {
      selectedLeaveIds.addAll([]);
    });
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
        //  //  // print("Push notification permission denied");
        return null;
      }

      String? token = await messaging.getToken();
      //  //  // print("Device Token: $token");
      return token;
    } catch (e) {
      //  //  // print("Error getting device token: $e");
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
      //  //  // print("Error getting device ID: $e");
      return null;
    }
  }

  Future<String> generateToken() async {
    //  //  //  // print("refreshToken${Params.refreshtoken}");
    // // 1. Check if refresh token is available
    final refreshToken = Params.refreshtoken;
    //  //  //  // print("refreshToken${Params.refreshtoken}");
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
      //  //  // print("eeee$e");
      return AppRoutes.signin;
    }
  }

  String selectedStatus = "Un Reported";

  var selectedStatusDropDown = "Un Reported".obs;
  var selectedLeaveStatusDropDown = "Un Reported".obs;
  var selectedTimeSheetStatusDropDown = "Un Reported".obs;
  var selectedLeaveStatusDropDownmyTeam = "In Process".obs;
  var selectedMyTeamSheetStatusDropDownmyTeam = "In Process".obs;
  var selectedExpenseType = "All Expenses".obs;
  String selectedStatusmyteam = "In Process";
  final selectedStatusDropDownmyteam = "In Process".obs;
  String selectedStatusmyteamCashAdvance = "In Process";
  final selectedStatusDropDownmyteamCashAdvance = "In Process".obs;
  var countryCode = ''.obs;
  var phoneNumber = ''.obs;
  List<GESpeficExpense> getSpecificListGExpense = [];
  RxList<GESpeficExpense> specificExpenseList = <GESpeficExpense>[].obs;
  RxList<UnprocessExpenseModels> specificExpenseListUnprocess =
      <UnprocessExpenseModels>[].obs;
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
  var searchQueryPending = ''.obs;
  var searchQueryPendingLeave = ''.obs;
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
  String? organizationCurrency;
  String? paymentMethodeID;
  var paidWithCashAdvance = RxnString(); // nullable reactive string
  var paymentMethodeIDCashAdvance = RxnString();
  String? expenseID;
  String? leaveID;
  int? recID;
  int? recIDItem;
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
  final RxBool isLoadingCAForm = false.obs;
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
  RxList<Map<String, dynamic>> configListSheet = <Map<String, dynamic>>[].obs;
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
    'MM/dd/yyyy': '01/20/2023',
    'dd/MM/yyyy': '20/01/2023',
    'yyyy/MM/dd': '2023/01/20',

    'MM-dd-yyyy': '01-20-2023',
    'dd-MM-yyyy': '20-01-2023',
    'yyyy-MM-dd': '2023-01-20',

    'MM.dd.yyyy': '01.20.2023',
    'dd.MM.yyyy': '20.01.2023',
    'yyyy.MM.dd': '2023.01.20',

    'MMM/dd/yyyy': 'Jan/20/2023',
    'dd/MMM/yyyy': '20/Jan/2023',
    'yyyy/MMM/dd': '2023/Jan/20',

    'MMM-dd-yyyy': 'Jan-20-2023',
    'dd-MMM-yyyy': '20-Jan-2023',
    'yyyy-MMM-dd': '2023-Jan-20',

    'MMM.dd.yyyy': 'Jan.20.2023',
    'dd.MMM.yyyy': '20.Jan.2023',
    'yyyy.MMM.dd': '2023.Jan.20',
  };
  Future signIn(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ThemeColor');
    profileImage.value = null;
    try {
      isLoadingLogin.value = true;
      // showMsg(false);
      //  //  //  // print("countryCodeController.text${countryCodeController.text}");
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
        final orgSettings =
            (decodeData["OrganizationSettings"] as List).first
                as Map<String, dynamic>;

        final userPermissions =
            decodeData["UserPermissions"] as Map<String, dynamic>;
        await prefs.setString("OrganizationSettings", jsonEncode(orgSettings));

        await prefs.setString("UserPermissions", jsonEncode(userPermissions));
        await PermissionHelper.loadPermissions();
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
        organizationCurrency = orgSettings["OrganizationDefaultCurrency"] ?? '';
        if (orgSettings["OrganizationDefaultCurrency"] != null) {
          await prefs.setString(
            'organizationCurrency',
            orgSettings["OrganizationDefaultCurrency"],
          );
        }
        print("organizationCurrency$organizationCurrency");
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
        await prefs.remove('profileImagePath');
        // debugPrint("✅ Token set: ${Params.userToken}");
        await getProfilePicture();
        bool permissionOk = await checkInternet();

        if (!permissionOk) {
          Fluttertoast.showToast(
            msg: "Please grant required permissions",
            backgroundColor: Colors.orange,
          );
          await openAppSettings();
          isLoadingLogin.value = false;
          return;
        }

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
          msg: decodeData["detail"] ?? "Login failed. Please try again.",
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
        msg: "Unable to Connect Server ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      //  //  // print("An error occurred: $e");
    }
  }

  void validatePercentage(String value, String text, Controller controller) {
    // Allow temporary empty state while typing
    if (value.trim().isEmpty) {
      controller.percentageError.value = false; // ✅ allow clearing
      return;
    }

    final number = double.tryParse(value);
    final percentage = double.tryParse(text);

    if (number == null || percentage == null) {
      controller.percentageError.value = true;
    } else if (number < 0 || number > percentage) {
      controller.percentageError.value = true;
    } else {
      controller.percentageError.value = false;
    }
  }

  final teamLeaveAnalytics = <TeamLeaveAnalytics>[].obs;
  Future<void> loadMyTeamLeaveAnalytics() async {
    teamLeaveAnalytics.clear();
    try {
      isLoading.value = true;

      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/myteam-leaveanalytics',
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;

        teamLeaveAnalytics.value = list
            .map((e) => TeamLeaveAnalytics.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Leave analytics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMyLeaveAnalytics() async {
    teamLeaveAnalytics.clear();
    try {
      isLoading.value = true;

      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/leaveanalytics',
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;

        teamLeaveAnalytics.value = list
            .map((e) => TeamLeaveAnalytics.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Leave analytics error: $e');
    } finally {
      isLoading.value = false;
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

      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        final analytics = (decoded['LeaveCodeAnalytics'] as List? ?? [])
            .map<LeaveAnalytics>((e) => LeaveAnalytics.fromJson(e))
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

      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/kanban/template/customtemplate/template',
      );

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        templates.assignAll(
          data.map((e) => BoardTemplate.fromJson(e)).toList(),
        );

        // print("Templates Loaded: $templates");
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load templates (${response.statusCode})",
        );
      }
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

  // Controller
  final RxList<EmployeeId> employeesID = <EmployeeId>[].obs;
  final Rx<EmployeeId?> selectedEmployeeID = Rx<EmployeeId?>(null);
  final TextEditingController employeeDropDownController =
      TextEditingController();

  Future<void> fetchEmployeesID() async {
    isLoadingGE1.value = true;
    final int transactionDate = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/employeeid'
      '?TrackingContext=ExpenseRequisition'
      '&TransactionDate=$transactionDate',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        employeesID.value = data.map((e) => EmployeeId.fromJson(e)).toList();
        selectedEmployeeID.value = employeesID.firstWhereOrNull(
          (emp) => emp.employeeId == Params.employeeId,
        );
        employeeDropDownController.text =
            selectedEmployeeID.value?.employeeId ?? '';
        employeeName.text = selectedEmployeeID.value?.employeeName ?? '';
      } else {
        // handle error
      }
    } catch (e) {
      // handle exception
    } finally {
      isLoadingGE1.value = false;
    }
  }

  TextEditingController typeController = TextEditingController();
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

        // print("Raw JSON response: $decoded");

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
        Navigator.pop(context);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        fetchBoards();
        final message = responseData['detail'];
        Fluttertoast.showToast(
          msg: message ?? "Something went Wrong",
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
      Fluttertoast.showToast(
        msg: "Something went Wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      return null;
    } finally {
      isLoadingGE1.value = false;
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
        'Area': selectedTemplateId.value.isEmpty
            ? null
            : selectedTemplateId.value,
        'Description': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        'ReferenceType': selectedReferenceType.value.isEmpty
            ? null
            : getReferenceType(selectedReferenceType.value),

        'ReferenceId': referenceIdController.text.trim().isEmpty
            ? null
            : referenceIdController.text.trim(),

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
    isPublic.value = true;
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
    //  //  // print("token$token");
    //  //  // print("platform$platform");
    //  //  // print("deviceId$deviceId");
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

      //  //  // print("📱 Registering device with details: $details");

      final response = await ApiService.post(
        Uri.parse('${Urls.baseURL}/api/v1/common/pushnotifications/logout'),

        body: jsonEncode(details),
      );

      // Step 3: Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //  //  // print("✅ Device registered successfully: $data");
      } else {
        //  //  // print("❌ Failed to register device. Status: ${response.statusCode}");
        //  //  // print("Response: ${response.body}");
      }
    } catch (e) {
      //  //  // print("🚨 Error registering device: $e");
    }
  }

  void closeField() {
    clearFormFields();
    resetFieldsMileage();
    clearFormFieldsPerdiem();
  }

  void clearFormFields() {
    expenseIdController.clear();
    //  // print("Cleared ALL2");
    selectedTimesheetIds.clear();
    selectedCashAdvanceIds.clear();
    selectedLeaveIds.clear();
    selectedTimesheetIds.clear();
    referenceID.clear();
    uploadedImages.clear();
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
    multiSelectedItems.clear();
    cashAdvanceRequisitionID.clear();
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
    isEnable.value = isEnable.value;
    isReimbursiteCreate.value = false;
    isBillable.value = false;
    isBillableCreate = false;
    finalItemsCashAdvance = [];
    //  // print("Cleared ALL ");
  }

  void chancelButton(BuildContext context) {
    clearFormFields();
    Navigator.pushNamed(context, AppRoutes.generalExpense);
  }

  void chancelButtonLeave(BuildContext context) {
    resetForm();
    Navigator.pushNamed(context, AppRoutes.leaveDashboard);
  }

  void chancelButtonCA(BuildContext context) {
    clearFormFields();
    Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);
  }

  ExpenseItemUpdate toExpenseItemUpdateModel() {
    return ExpenseItemUpdate(
      recId: recIDItem,
      expenseId: expenseId?.toString(),
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
              double.tryParse(controller?.transAmount.toString() ?? '') ?? 0.0,
          reportAmount:
              double.tryParse(controller?.reportAmount.toString() ?? '') ?? 0.0,
          allocationFactor: controller?.allocationFactor ?? 0.0,
          dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
        );
      }).toList(),
    );
  }

  ExpenseItemUpdate toExpenseItemUpdateModels(int? recId) {
    //  // print("checkRECID$recId");
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

    //  // print("Updated Line Amount: ${unitRate.text}");
    //  // print("Updated Line Amount INR: $lineAmount");
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

    //  // print("Status Code: ${response.statusCode}");
    //  // print("API Body: ${response.body}");

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      return decoded.map((item) => Dashboard.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load widgets: ${response.statusCode}");
    }
  }

  bool? digiScanEnable;
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

      final body = jsonEncode({
        'base64Data': base64String,
        'name': fileName,
        'type': mimeType,
      });

      final response = await ApiService.post(url, body: body);

      Navigator.of(context).pop(); // Close the loader

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        //  // print(" $responseData");
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

        Navigator.pushNamed(
          context,
          AppRoutes.autoScan,
          arguments: {'imageFile': file, 'apiResponse': body},
        );
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'Extract failed';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
      //  final body = jsonDecode(response.body);
      print('Something went wrong$e');

      //  Navigator.pushNamed(
      //   context,
      //   AppRoutes.autoScan,
      //   arguments: {'imageFile': file, 'apiResponse': null},
      // );

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

  void clearTimeSheetForm() {
    /// Header fields
    ///
    ///
    projectDropDowncontroller.clear();
    boardNameController.clear();
    taskIdController.clear();
    selectedProject = null;
    showProjectError.value = false;
    recId = null;
    noteCtrl.clear();
    timeSheetID.clear();
    sheetEnable.value = false;
    durationSeconds.value = 0;
    taskList.clear();
    periodType = 'Weekly';

    /// Line items
    lineItems.clear();
    lineItems.add(LineItemModel());
    timeEntries.clear();

    /// Timer state
    for (final line in lineItems) {
      line.timerRunning.value = false;
      line.timerCompleted.value = false;
      line.elapsedSeconds.value = 0;
    }

    /// Date range & period
    // handled in UI state
  }

  bool isImage(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }

  bool isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  bool isExcel(String path) {
    return path.toLowerCase().endsWith('.xls') ||
        path.toLowerCase().endsWith('.xlsx');
  }

  void openFilePDF(File file) {
    OpenFilex.open(file.path);
  }

  void openFile(BuildContext context, File file, int index) {
    if (!isEnable.value) {
      OpenFilex.open(file.path);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("File Options"),

          content: Text(file.path.split('/').last),

          actions: [
            /// ✅ OPEN ALWAYS AVAILABLE
            TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open"),
              onPressed: () {
                Navigator.pop(context);
                OpenFilex.open(file.path);
              },
            ),

            /// ✅ DELETE ONLY WHEN DISABLED
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                imageFiles.removeAt(index);
              },
            ),

            /// ✅ CLOSE
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void openFilewhileCreate(BuildContext context, File file, int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("File Options"),

          content: Text(file.path.split('/').last),

          actions: [
            /// ✅ OPEN ALWAYS AVAILABLE
            TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open"),
              onPressed: () {
                Navigator.pop(context);
                OpenFilex.open(file.path);
              },
            ),

            /// ✅ DELETE ONLY WHEN DISABLED
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                imageFiles.removeAt(index);
              },
            ),

            /// ✅ CLOSE
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchSpecificTimesheet({
    required int recId,
    required int lockId,
    required BuildContext context,
    required String page,
  }) async {
    isLoadingLeaves.value = true;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/specifictimesheet'
      '?rec_id=$recId&lock_id=$lockId&screen_name=TSRTimesheetHeader',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _appendExistingTimesheetData(data, context, page);
      isLoadingLeaves.value = false;
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';

      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      isLoadingLeaves.value = false;

      Fluttertoast.showToast(msg: "Failed to load timesheet");
    }
  }

  String periodType = 'Weekly';
  String stepValue = '';
  final TextEditingController timeSheetID = TextEditingController();
  DateTimeRange? dateRange;
  String? stepType;
  String? statusApproval;
  void _appendExistingTimesheetData(
    Map<String, dynamic> data,
    BuildContext context,
    String page,
  ) {
    /// HEADER
    projectDropDowncontroller.text = data["ProjectId"] ?? '';
    stepValue = data['StepType'] ?? '';
    periodType = getPeriodTypeForUI(data['Frequency'] ?? '');
    timeSheetID.text = data["TimesheetId"];
    recId = data["RecId"];
    dateRange = DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(data['FromDate'], isUtc: true),
      end: DateTime.fromMillisecondsSinceEpoch(data['ToDate'], isUtc: true),
    );

    // Set status and step type from API data
    statusApproval = data['ApprovalStatus'] ?? 'Created';
    stepType = data['StepType'] ?? '';
    // setTimeSheetStatus(status, stepType);
    workitemrecid = data['workitemrecid'] ?? 0;

    /// CLEAR OLD DATA
    lineItems.clear();
    timeEntries.clear();
    int index = 0;

    /// LINES
    for (final line in data['Timesheetlines']) {
      final lineItem = LineItemModel(
        project: Project(
          code: line['ProjectId'] ?? "",
          name: "",
          isNotEmpty: false,
        ),
        board: BoardModel(
          recId: line['RecId'],
          boardId: line['BoardId'] ?? '',
          boardName: '',
          boardType: '',
          referenceType: '',
          referenceId: '',
          referenceName: '',
          isActive: true,
          areaName: '',
        ),
        task: TaskModelDropDown(
          taskId: line['TaskId'] ?? '',
          taskName: line['TaskName'] ?? '',
          boardId: '',
        ),
        recId: line['RecId'],
      );
      final List<dynamic> customFields = line['LinesCustomfields'] ?? [];

      lineCustomFields[index] = customFields.map((field) {
        return {
          "FieldId": field["FieldId"],
          "FieldName": field["FieldName"],
          "FieldValue": field["FieldValue"] ?? "",
          "CustomFieldEntity": field["CustomFieldEntity"],
          "FieldType": field["FieldType"] ?? "text", // if exists
          "IsMandatory": field["IsMandatory"] ?? false,
          "Options":
              (field["Options"] as List?)?.map((e) => e.toString()).toList() ??
              <String>[],
        };
      }).toList();
      // /// ✅ APPEND LINE CUSTOM FIELDS HERE
      // final List<dynamic> customFields = line['LinesCustomfields'] ?? [];

      // lineItem.lineCustomFields = customFields.map((field) {
      //   return {
      //     "FieldId": field["FieldId"],
      //     "FieldName": field["FieldName"],
      //     "FieldValue": field["FieldValue"] ?? "",
      //     "CustomFieldEntity": field["CustomFieldEntity"],
      //   };
      // }).toList();

      lineItems.add(lineItem);

      final Map<int, TimeEntryModel> dailyMap = {};

      for (final daily in line['DailyEntry']) {
        final int? entryDate = daily['EntryDate'];

        if (entryDate == null) continue;

        dailyMap[entryDate] = TimeEntryModel(
          recId: daily['RecId'],
          entryDate: entryDate,
          timeFrom: daily['TimeFrom'] ?? 0,
          timeTo: daily['TimeTo'] ?? 0,
          totalHours: (daily['TotalHours'] ?? 0).toString(),
          comment: daily['InternalComment'] ?? '',
        );
      }

      timeEntries[index] = dailyMap;
      index++;
    }
    print("pagesss$page");
    if (page == "Team") {
      Navigator.pushNamed(
        context,
        AppRoutes.timeSheetRequestPage,
        arguments: {'status': true, "team": true},
      );
    } else if (page == "Edit") {
      Navigator.pushNamed(
        context,
        AppRoutes.timeSheetRequestPage,
        arguments: {'status': true, "team": false},
      );
    } else if (page == "Approvals") {
      Navigator.pushNamed(
        context,
        AppRoutes.timeSheetRequestPage,
        arguments: {'status': true, "team": false},
      );
    }

    update();
  }

  Future<void> fetchSpecificTimesheetApprvalDetails({
    required int recId,
    required int lockId,
    required BuildContext context,
    required String page,
  }) async {
    isLoadingLeaves.value = true;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/detailedapproval'
      '?workitemrecid=$recId&lock_id=$lockId&screen_name=MyPendingApproval',
    );

    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      isLoadingLeaves.value = false;
      _appendExistingTimesheetData(data, context, page);
    } else {
      isLoadingLeaves.value = false;
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message = responseData['detail'];

      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
    }
  }

  Future<Uint8List?> compressImageUnder1MB(String path) async {
    int quality = 90;
    Uint8List? result;
    final originalBytes = await File(path).readAsBytes();
    final originalSizeKB = originalBytes.lengthInBytes / 1024;
    print("Original Image Size: ${originalSizeKB.toStringAsFixed(2)} KB");
    do {
      result = await FlutterImageCompress.compressWithFile(
        path,
        quality: quality,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );
      if (result != null) {
        final compressedSizeKB = result.lengthInBytes / 1024;

        print(
          "Compressed Size (quality $quality): ${compressedSizeKB.toStringAsFixed(2)} KB",
        );
      }
      quality -= 10;
    } while (result != null &&
        result.lengthInBytes > 1024 * 1024 &&
        quality > 10);

    return result;
  }

  Future<bool> pickImageProfile() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (pickedFile == null) return false;

    isImageLoading.value = true;

    try {
      /// Step 1: Crop Image
      final croppedFile = await cropImage(pickedFile.path);

      if (croppedFile == null) return false;

      profileImage.value = File(croppedFile.path);

      /// Step 2: Compress Image
      final compressedBytes = await compressImageUnder1MB(croppedFile.path);

      if (compressedBytes == null) return false;

      /// Print size
      print("Compressed Size: ${compressedBytes.lengthInBytes / 1024} KB");

      /// Step 3: Convert to Base64
      final base64Str = base64Encode(compressedBytes);

      final dataUrl = 'data:image/jpeg;base64,$base64Str';

      /// Step 4: Upload
      await uploadProfilePicture(dataUrl);

      return true;
    } catch (e) {
      return false;
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<CroppedFile?> cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
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
        //  // print('Failed to load countries');
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
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
        //  // print('Delete failed [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      //  // print('Error deleting profile picture: $e');
      return false;
    }
  }

  Future<void> sendForgetPassword(BuildContext context) async {
    try {
      //  // print("forgotemailController text: ${forgotemailController.text}");

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
          msg: "${decodeData['detail']}",
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

      //  // print("An error occurred: $e");
      rethrow;
    }
  }

  Future<void> loadSavedCredentials() async {
    //  // print("rememberMeLoad$rememberMe");
    final prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('rememberMe') ?? false;
    //  // print("rememberMeLoad${prefs.getBool('rememberMe')}");

    if (rememberMe) {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  Future<void> saveCredentials() async {
    //  // print("rememberMeThink$rememberMe");
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
    //  //  // print("urlss$uri");
    final uri = Uri.parse(url);

    //  // print("urlss$uri");
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
        //  // print('language to load countries$data');
      } else {
        //  // print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      //  // print('Error fetching language: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchTimeZoneList() async {
    //  // print('timezone to load timezone');
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
        //  // print('timezone to load timezone$timezone');
        isLoading.value = false;
      } else {
        //  // print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      //  // print('Error fetching language: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentMethods() async {
    //  // print('Fetching payment methods...');
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

        //  // print('✅ Payment methods loaded: ${paymentMethods.length}');
        isLoading.value = false;
      } else {
        //  // print('❌ Failed to load payment methods: ${response.body}');
        isLoading.value = false;
      }
    } catch (e) {
      //  // print('⚠️ Error fetching payment methods: $e');
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
        //  //  // print('localeData to load countries$countryNames');
      } else {
        //  // print('Failed to load countries');
      }
    } catch (e) {
      //  // print('Error fetching localeData: $e');
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
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<StateModels>> fetchSecondState() async {
    isFetchingStatesSecond.value = true;
    //  // print("countryCode$selectedContectCountryCode");
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
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
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
        //  // print('currencies to load countries$currencies');
      } else {
        //  // print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenseCategory() async {
    expenseCategory.clear();
    final dateToUse = selectedDate ?? DateTime.now();
    //  // print("fetchExpenseCategory${selectedProject?.code}");
    //  // print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    //  // print("fetchExpenseCategory$fromDate");
    try {
      // Safely construct query parameters
      final queryParams = <String, String>{
        'TransactionDate': fromDate!.toStringAsFixed(2),
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
          //  // print('Expense categories loaded: ${expenseCategory.length}');
        } else {
          //  // print('Unexpected response format: $data');
        }
      } else {
        //  // print(
      }
    } catch (e) {
      //  // print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCashAdvanceExpenseCategory() async {
    expenseCategory.clear();
    final dateToUse = selectedDate ?? DateTime.now();
    //  // print("fetchExpenseCategory${selectedProject?.code}");
    //  // print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    //  // print("fetchExpenseCategory$fromDate");
    try {
      // Safely construct query parameters
      final queryParams = <String, String>{
        'TransactionDate': fromDate!.toStringAsFixed(2),
      };

      if (selectedProject?.code != null && selectedProject!.code.isNotEmpty) {
        queryParams['ProjectId'] = selectedProject!.code;
      }

      final url = Uri.parse(
        Urls.cashAdvanceexpenseCategory,
      ).replace(queryParameters: queryParams);
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          expenseCategory.value = data
              .map((e) => ExpenseCategory.fromJson(e))
              .toList();
          //  // print('Expense categories loaded: ${expenseCategory.length}');
        } else {
          //  // print('Unexpected response format: $data');
        }
      } else {
        //  // print(
      }
    } catch (e) {
      //  // print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PayrollsTeams>> fetchPayrollHeaders() async {
    const String url =
        '${Urls.baseURL}/api/v1/payrollregistration/payroll/payrollheader?page=1&sort_order=asc';

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
        // print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('ExceptionPayrole: $e');
      return [];
    }
  }

  Future<List<PayrollsTeams>> fetchmyPayrollHeaders() async {
    String url =
        '${Urls.baseURL}/api/v1/payrollregistration/payroll/payrollheader?filter_query=STPPayRollHeader.EmployeeId__eq%3D${Params.employeeId}&page=1&sort_order=asc';

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
        // print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('ExceptionPayrole: $e');
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

      case "Is Reimbursible":
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
    // isLoadingGE1.value = true;
    final url = Uri.parse(Urls.geconfigureField);
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configList.value = [];
        if (data is List) {
          configList.addAll(data.cast<Map<String, dynamic>>());

          //  // print('Appended configList: $configList');
          // isLoadingGE2.value = false;

          //  // print('currencies to load countries$currencies');
        }
      } else {
        //  // print('Failed to load countries');
        // isLoadingGE2.value = false;
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
      // isLoadingGE2.value = false;
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

          //  // print('Appended configList: $configList');
          // isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          //  // print('currencies to load countries$currencies');
        }
      } else {
        //  // print('Failed to load countries');
        // isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
      // isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<void> Sheetconfiguration() async {
    // isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/masters/fieldmanagement/customfields/timesheetcconfigfields?'
      'filter_query=STPFieldConfigurations.FunctionalEntity__eq%3DTimesheetRequisition&'
      'page=1&sort_order=asc&choosen_fields=FieldId%2CFieldName%2CIsEnabled%2CIsMandatory%2CFunctionalArea%2CRecId',
    );
    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configListSheet.value = [];
        if (data is List) {
          configListSheet.addAll(data.cast<Map<String, dynamic>>());

          //  // print('Appended configList: $configList');
          // isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          //  // print('currencies to load countries$currencies');
        }
      } else {
        //  // print('Failed to load countries');
        // isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
      // isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  // MOVE THIS TO GLOBAL SCOPE
  T findOrFallback<T>(List<T> list, bool Function(T) test, T fallback) {
    return list.firstWhere(test, orElse: () => fallback);
  }

  String normalizeFormat(String format) {
    return format
        .replaceAll('mm', 'MM') // fix month
        .replaceAll('yyyy', 'yyyy')
        .replaceAll('dd', 'dd');
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

      final normalized = normalizeFormat(defaultDateformat!);

      final format = dateFormatMap.entries.firstWhere(
        (e) => e.key == normalized,
        orElse: () => const MapEntry('dd-MM-yyyy', '20-01-2023'),
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
      //  // print("Timezone: $tz - from: ${currencyDropDowncontroller.text}");
      isLoading.value = false;
      userPref.value = true;
    } catch (e) {
      //  // print('Error loading prefs: $e');
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
        //  // print('payment to load countries$payment');
      } else {
        //  // print('Failed to load countries');
      }
    } catch (e) {
      //  // print('Error fetching countries: $e');
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
      //  // print('Error fetching profile picture: $e');
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
  //        //  // print('✅ Loaded cached profile image from $filePath');
  //     } else {
  //        //  // print('⚠️ Cached profile image not found on disk');
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
        //  //  // print("✅ ");
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
        //  // print("❌  ${responseData['detail']['message']}");
        isGEPersonalInfoLoading.value = false;
        // isUploading.value = false;
      }
    } catch (e) {
      //  // print("❌ Exception: $e");
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
    //  // print("selectedTimezone.value.id${selectedTimezonevalue}");
    final Map<String, dynamic> requestBody = {
      "UserId": Params.userId,
      "DefaultCurrency": selectedCurrency.value?.code,
      "DefaultTimeZoneValue": selectedTimezonevalue,
      "DefaultTimeZone": selectedTimezone.value.id,
      "DefaultLanguageId": selectedLanguage?.code,
      "DefaultDateFormat": selectedFormat?.key,
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
      //  // print("requestBody$requestBody");
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
        //  //  // print("✅ ");
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
        buttonLoader.value = false;
      }
    } catch (e) {
      //  // print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<bool> getPersonalDetails(BuildContext context) async {
    isLoading.value = true;
    isImageLoading.value = true;
    //  // print('userId: ${Params.userId}');
    try {
      final uri = Uri.parse(
        '${Urls.getPersonalByID}?UserId=${Params.userId}&lockid=${Params.userId}&screen_name=user',
      );
      final response = await ApiService.get(uri);

      //  // print('Status Code: ${response.statusCode}');
      //  // print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        isLoading.value = false;
        // isImageLoading.value = false;

        // Fluttertoast.showToast(
        //   msg: " ${response.body}",
        //   toastLength: Toast.LENGTH_SHORT,
        // );
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
      parsePhoneNumber(fullNumber);
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
      stateTextController.text = cont['State'] ?? '';
      contactPostalController.text = cont['PostalCode'] ?? '';
      contactaddressID.text = cont['AddressId'] ?? '';
      contactCountryController = cont['Country'] ?? '';
      selectedContectCountryCode = contactCountryController;
      bool isAllEmpty(Map addr) {
        return (addr['Street'] ?? '').toString().trim().isEmpty &&
            (addr['City'] ?? '').toString().trim().isEmpty &&
            (addr['State'] ?? '').toString().trim().isEmpty &&
            (addr['PostalCode'] ?? '').toString().trim().isEmpty &&
            (addr['Country'] ?? '').toString().trim().isEmpty;
      }

      final bool isSameAsPermanents =
          !isAllEmpty(perm) && // ❗ important condition
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
        //  // print(
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
        // fetchState();
        // fetchSecondState();
      });

      // Fluttertoast.showToast(
      //   msg: "Personal details loaded: $selectedCountryCode",
      //   toastLength: Toast.LENGTH_SHORT,
      // );

      isLoading.value = false;

      return true;
    } catch (error) {
      isLoading.value = false;

      return false;
    }
  }

  List<String> countryCodes = [
    '+1',
    '+7',
    '+20',
    '+27',
    '+30',
    '+31',
    '+32',
    '+33',
    '+34',
    '+36',
    '+39',
    '+40',
    '+41',
    '+43',
    '+44',
    '+45',
    '+46',
    '+47',
    '+48',
    '+49',
    '+51',
    '+52',
    '+53',
    '+54',
    '+55',
    '+56',
    '+57',
    '+58',
    '+60',
    '+61',
    '+62',
    '+63',
    '+64',
    '+65',
    '+66',
    '+81',
    '+82',
    '+84',
    '+86',
    '+90',
    '+91',
    '+92',
    '+93',
    '+94',
    '+95',
    '+98',
    '+211',
    '+212',
    '+213',
    '+216',
    '+218',
    '+220',
    '+221',
    '+222',
    '+223',
    '+224',
    '+225',
    '+226',
    '+227',
    '+228',
    '+229',
    '+230',
    '+231',
    '+232',
    '+233',
    '+234',
    '+235',
    '+236',
    '+237',
    '+238',
    '+239',
    '+240',
    '+241',
    '+242',
    '+243',
    '+244',
    '+245',
    '+248',
    '+249',
    '+250',
    '+251',
    '+252',
    '+253',
    '+254',
    '+255',
    '+256',
    '+257',
    '+258',
    '+260',
    '+261',
    '+262',
    '+263',
    '+264',
    '+265',
    '+266',
    '+267',
    '+268',
    '+269',
    '+290',
    '+291',
    '+297',
    '+298',
    '+299',
    '+350',
    '+351',
    '+352',
    '+353',
    '+354',
    '+355',
    '+356',
    '+357',
    '+358',
    '+359',
    '+370',
    '+371',
    '+372',
    '+373',
    '+374',
    '+375',
    '+376',
    '+377',
    '+378',
    '+380',
    '+381',
    '+382',
    '+383',
    '+385',
    '+386',
    '+387',
    '+389',
    '+420',
    '+421',
    '+423',
    '+500',
    '+501',
    '+502',
    '+503',
    '+504',
    '+505',
    '+506',
    '+507',
    '+508',
    '+509',
    '+590',
    '+591',
    '+592',
    '+593',
    '+594',
    '+595',
    '+596',
    '+597',
    '+598',
    '+599',
    '+670',
    '+672',
    '+673',
    '+674',
    '+675',
    '+676',
    '+677',
    '+678',
    '+679',
    '+680',
    '+681',
    '+682',
    '+683',
    '+685',
    '+686',
    '+687',
    '+688',
    '+689',
    '+690',
    '+691',
    '+692',
    '+850',
    '+852',
    '+853',
    '+855',
    '+856',
    '+880',
    '+886',
    '+960',
    '+961',
    '+962',
    '+963',
    '+964',
    '+965',
    '+966',
    '+967',
    '+968',
    '+970',
    '+971',
    '+972',
    '+973',
    '+974',
    '+975',
    '+976',
    '+977',
    '+992',
    '+993',
    '+994',
    '+995',
    '+996',
    '+998',
  ];
  void parsePhoneNumber(String fullNumber) {
    String cleaned = fullNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
    print('Cleaned: "$cleaned"');

    countryCode.value = '';
    phoneNumber.value = cleaned;

    // ✅ Find longest matching country code
    String? matchedCode;

    for (var code in countryCodes) {
      if (cleaned.startsWith(code)) {
        if (matchedCode == null || code.length > matchedCode.length) {
          matchedCode = code;
        }
      }
    }

    if (matchedCode != null) {
      countryCode.value = matchedCode;
      phoneNumber.value = cleaned.substring(matchedCode.length);
    }

    print('CC: "${countryCode.value}"');
    print('Phone: "${phoneNumber.value}"');

    countryCodeController.text = countryCode.value;
    phoneController.text = phoneNumber.value;
  }

  Future<List<MerchantModel>> fetchPaidto() async {
    final dateToUse = selectedDate ?? DateTime.now();
    //  //  // print("fetchPaidto${selectedProject?.code}");
    //  // print("fetchPaidto$selectedDate");
    isLoading.value = true;
    //  // print("fromDate$dateToUse");
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
    //  // print("formatted$formatted");
    final fromDate = parseDateToEpoch(formatted);
    //  // print("fromDate$fromDate");

    // isLoadingGE1.value = true;
    isLoadingGE2.value = true;

    final url = Uri.parse('${Urls.getPaidtoDropdown}$fromDate');

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<MerchantModel> states = List<MerchantModel>.from(
          data.map((item) => MerchantModel.fromJson(item)),
        );

        paidTo.value = states;

        isLoadingGE2.value = false;

        return states;
      } else {
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
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
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        // isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
      // isLoadingGE2.value = false;

      return [];
    }
  }

  Future<List<Project>> fetchProjectName() async {
    final dateToUse = selectedDate ?? DateTime.now();

    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
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

        //  // print("projects$projects");
        isLoadingGE1.value = false;
        isLoadingGE2.value = false;
        return projects;
      } else {
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        isLoadingGE2.value = false;
        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
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

        //  // print("taxGroups$taxGroups");
        isLoadingGE1.value = false;
        return taxGroup;
      } else {
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
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
        // final Map<String, dynamic> responseData = jsonDecode(response.body);
        // final String message =
        //     responseData['detail']?['message'] ?? 'No message found';
        // Fluttertoast.showToast(
        //   msg: message,
        //   backgroundColor: Colors.green[200],
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.BOTTOM,
        //   textColor: Colors.green[800],
        //   fontSize: 16.0,
        // );
        //  // print("units$units");
        isLoadingGE1.value = false;
        return units;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
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

        //  // print("units$units");
        isLoadingGE1.value = false;
        return units;
      } else {
        //  // print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      //  // print('Error fetching states: $e');
      return [];
    }
  }

  RxList<SequenceNumberModel> sequenceList = <SequenceNumberModel>[].obs;
  RxBool isSequenceLoading = false.obs;

  Future<void> loadSequenceModules() async {
    try {
      isSequenceLoading.value = true;

      final response = await ApiService.get(
        Uri.parse(
          "${Urls.baseURL}/api/v1/system/system/sequencenumbers?page=1&limit=10000&sort_by=ModifiedDatetime&sort_order=desc",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        sequenceList.value = data
            .map((e) => SequenceNumberModel.fromJson(e))
            .toList();
      }
    } finally {
      isSequenceLoading.value = false;
    }
  }

  bool hasModule(String moduleName) {
    return sequenceList.any(
      (e) => e.module.toLowerCase() == moduleName.toLowerCase(),
    );
  }

  Future<ExchangeRateResponse?> fetchExchangeRate() async {
    // if (selectedCurrency.value == null) {
    //    //  // print('selectedCurrency is null');
    //   return null;
    // }
    final dateToUse = selectedDate ?? DateTime.now();
    //  // print("fetchExpenseCategory${selectedProject?.code}");
    //  // print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    // print("fetchExpenseCategory$fromDate");
    double? parsedAmount = double.tryParse(paidAmount.text);
    //  // print("parsedAmount$parsedAmount");
    final String amount = parsedAmount != null
        ? parsedAmount.toInt().toStringAsFixed(2)
        : '0';
    final currencyCode =
        selectedCurrency.value?.code ?? currencyDropDowncontroller.text;

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
        //  // print("amountINR: ${quantity.text}");

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
      //  // print('Error fetching exchange rate: $e');
      return null;
    }
    return null;
  }

  String formatDate(dynamic value) {
    if (value == null) return 'No date';

    final dt = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

    final clean = DateTime(dt.year, dt.month, dt.day);

    return DateFormat('dd-MM-yyyy').format(clean);
  }

  Future<List<PaymentMethodModel>> fetchPaidwith() async {
    paymentMethods.clear();
    isPaymentMethodsLoading.value = true;
    final url = Uri.parse(Urls.getPaidwithDropdown);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isPaymentMethodsLoading.value = false;
        paymentMethods.value = (data as List)
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();

        //  // print(

        isLoadingGE2.value = false;

        return paymentMethods;
      } else {
        //  // print(
        isPaymentMethodsLoading.value = false;
        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      //  // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;
      isPaymentMethodsLoading.value = false;
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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );

        return [];
      }
    } catch (e) {
      isLoadingGE1.value = false;
      //  // print('Error fetching Cash Advance: $e');
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
  //             DateFormat('dd-MM-yyyy').format(expense.receiptDate);
  //       }

  //        //  // print("Expense ID: ${expenseIdController.text}");
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
  //        //  // print(
  //           'Failed to load specific expense. Status code: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e, stack) {
  //     isLoadingGE1.value = false;
  //      //  // print('Error fetching specific expense: $e');
  //      //  // print(stack);
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
            'dd-MM-yyyy',
          ).format(expense.receiptDate);
        }

        //  // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.unProcessExpense,
          arguments: {'item': unProcessModelList[0], 'readOnly': bool},
        );

        return unProcessModelList;
      } else {
        isLoadingGE1.value = false;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );

        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      //  // print('Error fetching specific expense: $e');
      //  // print(stack);
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
            'dd-MM-yyyy',
          ).format(expense.receiptDate);
        }

        //  // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpense,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );

        return specificExpenseList;
      } else {
        isLoadingGE1.value = false;
        //  // print(
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      //  // print('Error fetching specific expense: $e');
      //  // print(stack);
      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificExpenseItemUnProcess(
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

        specificExpenseListUnprocess.value = (data as List)
            .map((item) => UnprocessExpenseModels.fromJson(item))
            .toList();

        for (var expense in specificExpenseListUnprocess) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text = DateFormat(
            'dd-MM-yyyy',
          ).format(expense.receiptDate);
        }

        //  // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpense,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );

        return specificExpenseList;
      } else {
        isLoadingGE1.value = false;
        //  // print(
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      //  // print('Error fetching specific expense: $e');
      //  // print(stack);
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
      '${Urls.getSpecificGeneralExpense}/expenseregistration?RecId=$recId&lock_id=$recId',
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
            'dd-MM-yyyy',
          ).format(expense.receiptDate);
        }

        //  // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;

        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificCashAdvanseView,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );

        return specificExpenseList;
      } else {
        isLoadingGE1.value = false;
        //  // print(
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return [];
      }
    } catch (e, stack) {
      isLoadingGE1.value = false;
      //  // print('Error fetching specific expense: $e');
      //  // print(stack);
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
            'dd-MM-yyyy',
          ).format(expense.receiptDate);
        }
        //  // print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificCashAdvanseView,
          arguments: {'item': specificExpenseList[0], 'readOnly': bool},
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );

        return [];
      }
    } catch (e) {
      //  // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<ExpenseModelMileage> fetchMileageDetails(
    context,
    expenseId,
    readOnly,
  ) async {
    isLoadingGE1.value = true;
    final response = await ApiService.get(
      Uri.parse(
        "${Urls.mileageregistrationview}milageregistration?RecId=$expenseId&lock_id=$expenseId&screen_name=MileageRegistration",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final expense = ExpenseModelMileage.fromJson(data[0]); // Assuming array
      //  // print("readOnly$readOnly");
      Navigator.pushNamed(
        context,
        AppRoutes.mileageExpensefirst,
        arguments: {'item': expense, 'isReadOnly': readOnly},
      );
      isLoadingGE1.value = false;
      return expense;
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';

      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red[100],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      isLoadingGE1.value = false;
      throw Exception("Failed to fetch mileage details");
    }
  }

  Future<ExpenseModelMileage> fetchMileageDetailsApproval(
    context,
    expenseId,
    readOnly,
  ) async {
    isLoadingGE1.value = true;
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
      isLoadingGE1.value = false;
      return expense;
    } else {
      isLoadingGE1.value = false;
      throw Exception("Failed to fetch mileage details");
    }
  }

  RxList<int> selectedExpenseIds = <int>[].obs;
  RxList<int> selectedCashAdvanceIds = <int>[].obs;
  RxList<int> selectedTimesheetIds = <int>[].obs;
  RxList<int> selectedLeaveIds = <int>[].obs;
  void toggleTimesheetSelection(int id) {
    if (selectedTimesheetIds.contains(id)) {
      selectedTimesheetIds.remove(id);
    } else {
      selectedTimesheetIds.add(id);
    }
  }

  void toggleLeaveSelection(int id) {
    if (selectedLeaveIds.contains(id)) {
      selectedLeaveIds.remove(id);
    } else {
      selectedLeaveIds.add(id);
    }
  }

  void toggleSelectionExpense(int id) {
    // print("selectedExpenseIds $id");

    if (selectedExpenseIds.contains(id)) {
      selectedExpenseIds.remove(id);
    } else {
      selectedExpenseIds.add(id);
      // print("selectedExpenseIdsddd ${selectedExpenseIds.value}");
    }
  }

  void toggleSelectionCashAdvance(int id) {
    // print("selectedExpenseIds $id");

    if (selectedCashAdvanceIds.contains(id)) {
      selectedCashAdvanceIds.remove(id);
    } else {
      selectedCashAdvanceIds.add(id);
      // print("selectedExpenseIdsddd ${selectedCashAdvanceIds.value}");
    }
  }

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> checkRequiredPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.location,
      Permission.storage,
    ].request();

    return statuses.values.every((e) => e.isGranted);
  }

  /// Request required permissions
  static Future<bool> checkPermissions() async {
    List<Permission> permissions = [
      Permission.camera,
      Permission.location,
      Permission.storage, // or photos for iOS
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    return statuses.values.every((status) => status.isGranted);
  }

  void clearExpenseSelection() {
    selectedExpenseIds.clear();
  }

  Future<bool> postApprovalAction(
    BuildContext context, {
    required List<int> workitemrecid,
    required String decision,
    required String comment,
    // required String userId,
  }) async {
    // print("Its $decision");
    // print("working ID  $workitemrecid");
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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
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
      final String message = responseData['detail']?['message'] ?? '';

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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
      return false;
    }
  }

  Future<bool> postApprovalActionLeavelSheet(
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
        Uri.parse(Urls.sheetApprovals),

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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
      return false;
    }
  }

  Future<bool> approvalHubExternalpostApprovalAction(
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
      "items": workitemrecid,
      "decision": status,
      "comment": comment,
    };

    try {
      final response = await ApiService.put(
        Uri.parse(Urls.externalApprovals),

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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
      return false;
    }
  }

  Future<bool> postApprovalActionLeave(
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

      "userId": status == "Escalated" && userIdController.text.isNotEmpty
          ? userIdController.text
          : null,
    };

    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/masters/approvalmanagement/workflowapproval/approveraction?functionalentity=LeaveRequisition',
        ),

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

        //  // print("✅ Approval Action  ${response.body}");
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
      //  // print("❌ API  $e");
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
            'dd-MM-yyyy',
          ).format(expense.receiptDate);
        }
        print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpenseApproval,
          arguments: {'item': specificExpenseList[0]},
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );

        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
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
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
      "ReceiptDate": DateTime.now().millisecondsSinceEpoch,
      "Source": "Web",
      "ExchRate": 1,
      "ExpenseId": expenseID ?? "",
      "ExpenseType": "Mileage",
      "RecId": recID,
      "Currency": currencyDropDowncontroller.text,
      "MileageRateId": mileageVehicleID.text,
      "VehicleType": selectedVehicleType?.name ?? "Car",
      "FromLocation": tripControllers.first.text,
      "ToLocation": tripControllers.last.text,
      // "RecId": null,
      "CashAdvReqId": cashAdvanceIds.text,
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      "AccountingDistributions": accountingDistributions.isNotEmpty
          ? accountingDistributions.map((e) => e?.toJson()).toList()
          : [],
      "ExpenseTrans": expenseTransMap,
      "ProjectId": projectIdController.text.trim().isEmpty
          ? null
          : projectIdController.text.trim(),
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
    } catch (e) {}
  }

  Future<void> hubreviewMileageRegistration(
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
      "Currency": currencyDropDowncontroller.text,
      "MileageRateId": mileageVehicleID.text,
      "VehicleType": selectedVehicleType?.name ?? "Car",
      "FromLocation": tripControllers.first.text,
      "ToLocation": tripControllers.last.text,
      // "RecId": null,
      "CashAdvReqId": cashAdvanceIds.text,
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      "AccountingDistributions": accountingDistributions.isNotEmpty
          ? accountingDistributions.map((e) => e?.toJson()).toList()
          : [],
      "ExpenseTrans": expenseTransMap,
      "ProjectId": projectIdController.text.trim().isEmpty
          ? null
          : projectIdController.text.trim(),
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
    } catch (e) {}
  }

  Future<void> reviewGendralExpense(
    context,
    bool action,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
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
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paidWithController.text.trim().isEmpty
          ? null
          : paidWithController.text.trim(),
      // "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      // "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      "IsReimbursable": isReimbursite,
      "Currency":
          selectedCurrency.value?.code ?? currencyDropDowncontroller.text,
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
          responseData['detail']?['message']?.toString() ?? '';

      final String message2 =
          responseData['detail']?['message']?.toString() ?? '';
      if (response.statusCode == 200 ||
          response.statusCode == 202 ||
          response.statusCode == 280) {
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
          msg: message2,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      print("Error$e");
    }
  }

  void markInitialized() {
    isInitialized.value = true;
  }

  Future<bool> submitExpenseCancel({
    required int contextRecId,
    required BuildContext context,
  }) async {
    try {
      final Uri url = Uri.parse(
        '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expensecancel'
        '?context_recid=$contextRecId'
        '&screen_name=MyLeave'
        '&functionalentity=LeaveCancellation',
      );

      final response = await ApiService.put(url);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        // debugPrint('✅ Expense cancelled successfully');
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        Navigator.pushNamed(context, AppRoutes.leaveCancellation);

        return true;
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
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
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
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
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paidWithController.text.trim().isEmpty
          ? null
          : paidWithController.text.trim(),
      // "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      // "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      "IsReimbursable": isReimbursable,
      "Currency":
          selectedCurrency.value?.code ?? currencyDropDowncontroller.text,
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
      //  // print("Error$e");
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
        '${Urls.getTrackingDetails}RefRecId__eq%3D$recId&page=1&sort_by=CreatedDatetime&sort_order=asc',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpenseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expense history: ${response.statusCode}');
    }
  }

  Future<List<ExpenseHistory>> fetchLeaveHistory(int? recId) async {
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.getTrackingDetailsLeave}RefRecId__eq%3D$recId&page=1&sort_by=ModifiedBy&sort_order=desc',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpenseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expense history: ${response.statusCode}');
    }
  }

  Future<List<TimeSheetHistory>> fetchTimeSheetHistory(int? refRecId) async {
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/trackinghistory?filter_query=TSRTimesheetLog.'
        'RefRecId__eq%3D$refRecId'
        '&page=1'
        '&sort_by=CreatedDatetime'
        '&sort_order=asc',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => TimeSheetHistory.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load timesheet history: ${response.statusCode}',
      );
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
    //  //  // print("FileChecker");
    isLoadingviewImage.value = true;
    //  //  // print("FileChecker:");
    imageFiles.clear();
    uploadedImages.clear();
    final response = await ApiService.get(
      Uri.parse('${Urls.getExpensImage}$recId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //  //  // print("DDDDDD");
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
        final originalFile = imageFiles[i];

        // ✅ STEP 1: Compress image
        final compressedFile = await compressImage(originalFile);

        // If compression fails, use original file
        final fileToUse = compressedFile ?? originalFile;

        // ✅ STEP 2: Read bytes from compressed file
        final fileBytes = await fileToUse.readAsBytes();

        // ✅ STEP 3: Convert to Base64
        final base64Data = base64Encode(fileBytes);

        final fileName = p.basename(fileToUse.path);
        final mimeType = getMimeType(fileToUse);
        final extension = p.extension(fileToUse.path).replaceAll('.', '');

        // ✅ STEP 4: Generate SHA-256 hash
        final hash = sha256.convert(fileBytes).toString();

        files.add({
          "index": i,
          "name": fileName,
          "type": mimeType,
          "base64Data": base64Data,
          "Hashmapkey": hash,
          "RecId": 0,
          "FileExtension": extension,
        });
      }
    } catch (e) {
      debugPrint("❌ Error while preparing attachments: $e");
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
      //  //  // print("🔍 Debug - totalRequestedAmount: ${trans.lineAdvanceRequested}");
      //  //  // print(
      //   "🔍 Debug - requestedPercentage: ${trans.lineRequestedAdvanceInReporting}",
      // );
      //  //  // print("&&&&&&11${trans.lineAdvanceRequested}");

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
        lineRequestedExchangerate: trans.lineRequestedExchangerate,
        lineEstimatedExchangerate: trans.lineEstimatedExchangerate,
        maxAllowedPercentage: trans.maxAllowedPercentage,
        // baseUnit: trans.baseUnit,
        // baseUnitRequested: trans.baseUnitRequested,
        expenseCategoryId: trans.expenseCategoryId,

        accountingDistributions: trans.accountingDistributions!.map((
          controller,
        ) {
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
      print("""
      --- Expense Transaction ---
      recId: ${recIDItem}
      expenseId: ${trans.expenseId}
      expenseCategoryId: ${trans.expenseCategoryId}
      uomId: ${trans.uomId}
      quantity: ${trans.quantity}
      unitPriceTrans: ${trans.unitPriceTrans}
      taxAmount: ${trans.taxAmount}
      taxGroup: ${trans.taxGroup}
      lineAmountTranss: ${trans.lineAmountTrans}
      lineAmountReporting: ${trans.lineAmountReporting}
      projectId: ${trans.projectId}
      description: ${trans.description}
      isReimbursable: ${trans.isReimbursable}
      isBillable: ${trans.isBillable}
      accountingDistributions: ${trans.accountingDistributions?.map((d) => d.toJson()).toList()}
      ----------------------------
      """);

      // Preserve the original recId from the transaction
      final int? originalRecId = trans.recId ?? expense.recId;

      final taxGroupValue =
          (trans.taxGroup != null && trans.taxGroup.toString().isNotEmpty)
          ? trans.taxGroup
          : null;

      // Map accounting distributions while preserving their recIds
      final mappedDistributions =
          trans.accountingDistributions?.map((dist) {
            //  //  // print("Distribution recId: ${dist.recId}");
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
        recId: trans.recId,
        expenseId: trans.expenseId,
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

      //  //  // print("Final item recId: ${item.recId}");
      finalItemsSpecific.add(item);
    }

    //  //  // print("Total items in finalItemsSpecific: ${finalItemsSpecific.length}");
    //  //  // print(
    //   "Items with recId ${finalItemsSpecific.where((item) => item.recId != null).length}",
    // );
    //  //  // print(
    //   "Items without recId: ${finalItemsSpecific.where((item) => item.recId == null).length}",
    // );
  }

  void addToFinalItemsUnProcess(UnprocessExpenseModels expense) {
    finalItemsSpecific.clear(); // Clear previous items first

    for (var trans in expense.expenseTrans) {
      final int? originalRecId = trans.recId;
      print("""
      --- Expense Transaction ---
      recId: ${originalRecId}
      expenseId: ${trans.expenseId}
      expenseCategoryId: ${trans.expenseCategoryId}
      uomId: ${trans.uomId}
      quantity: ${trans.quantity}
      unitPriceTrans: ${trans.unitPriceTrans}
      taxAmount: ${trans.taxAmount}
      taxGroup: ${trans.taxGroup}
      lineAmountTranss: ${trans.lineAmountTrans}
      lineAmountReporting: ${trans.lineAmountReporting}
      projectId: ${trans.projectId}
      description: ${trans.description}
      isReimbursable: ${trans.isReimbursable}
      isBillable: ${trans.isBillable}
      accountingDistributions: ${trans.accountingDistributions.map((d) => d.toJson()).toList()}
      ----------------------------
      """);

      // Preserve the original recId from the transaction

      final taxGroupValue =
          (trans.taxGroup != null && trans.taxGroup.toString().isNotEmpty)
          ? trans.taxGroup
          : null;

      // Map accounting distributions while preserving their recIds
      final mappedDistributions =
          trans.accountingDistributions?.map((dist) {
            //  //  // print("Distribution recId: ${dist.recId}");
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
        recId: originalRecId,
        expenseId: trans.expenseId,
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

      //  //  // print("Final item recId: ${item.recId}");
      finalItemsSpecific.add(item);
      print(
        "ExpenseTrans recIds: ${finalItemsSpecific.map((e) => e.recId).toList()}",
      );
    }

    //  //  // print("Total items in finalItemsSpecific: ${finalItemsSpecific.length}");
    //  //  // print(
    //   "Items with recId ${finalItemsSpecific.where((item) => item.recId != null).length}",
    // );
    //  //  // print(
    //   "Items without recId: ${finalItemsSpecific.where((item) => item.recId == null).length}",
    // );

    // 🔍 Optional concise debug log
    //        //  //  // print("""
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

    // ✅ Final Summary
    //  //  // print("✅ Total Items Added: ${finalItemsSpecific.length}");
    //  //  // print(
    //   "   Items with RecId: ${finalItemsSpecific.where((e) => e.recId != null).length}",
    // );
    //  //  // print(
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

  RxList<String> allowedExtensions = <String>[].obs;

  Future<void> fetchFileTypes() async {
    try {
      final response = await ApiService.get(
        Uri.parse(
          "${Urls.baseURL}/api/v1/masters/organizationmgmt/organizations/orgdocumentfiletypes?filter_query=STPOrgDocumentFileTypes.IsActive__eq%3Dtrue&page=1&limit=10000000&sort_by=ModifiedDatetime&sort_order=desc",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final extensions = data
            .where((e) => e['IsActive'] == true)
            .map<String>(
              (e) => e['FileExtension']
                  .toString()
                  .replaceAll('.', '') // remove dot
                  .toLowerCase(),
            )
            .toList();

        allowedExtensions.assignAll(extensions);

        debugPrint("✅ Allowed Extensions: $allowedExtensions");
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
    }
  }

  Future<void> saveGeneralExpense(context, bool bool, bool? reSubmit) async {
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    final hideField = hasModule("Expense");
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate${unitAmount.text}");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = finalItems.isNotEmpty;
    //  //  // print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": hideField ? null : expenseIdController.text,
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
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
      "ExpenseCategoryId": categoryController.text.trim(),
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
      //  //  // print("requestBody$requestBody");
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
      } else if (response.statusCode == 440) {
        final data = jsonDecode(response.body);
        clearFormFields();
        final message = data['detail']['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        Navigator.pushNamed(context, AppRoutes.generalExpense);
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
        //  //  // print("❌  ${response.body}");
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

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
        //  //  // print("Justification Error: ${response.body}");
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      //  //  // print("❌ Justification Exception: $e");
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
        //  //  // print("Justification Error: ${response.body}");
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      //  //  // print("❌ Justification Exception: $e");
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
        //  //  // print("Justification Error: ${response.body}");
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      //  //  // print("❌ Justification Exception: $e");
    }
  }

  Future<void> createcashAdvanceReturn(
    context,
    bool bool,
    bool? reSubmit,
    int recId,
    String? expenseId,
  ) async {
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("cashAdvanceIds$cashAdvanceIds");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = finalItems.isNotEmpty;
    //  //  // print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId ?? '',
      if (recId > 0) "RecId": recId,
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
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
      //  //  // print("requestBody$requestBody");
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
        //  //  // print("❌  ${response.body}");
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  CashAdvanceRequestItemizeFornew toCashAdvanceRequestItemize() {
    // Debug prints to verify values
    //  //  // print("🔍 Debug - selectedCategoryId: $selectedCategoryId");
    //  //  // print("🔍 Debug - quantity: ${quantity.text}");
    //  //  // print("🔍 Debug - unitAmount: ${unitAmount.text}");
    //  //  // print("🔍 Debug - paidAmountCA1: ${paidAmountCA1.text}");
    //  //  // print("🔍 Debug - totalRequestedAmount: ${totalRequestedAmount.text}");
    //  //  // print("🔍 Debug - requestedPercentage: ${requestedPercentage.text}");

    return CashAdvanceRequestItemizeFornew(
      expenseCategoryId: selectedCategoryId?.isNotEmpty == true
          ? selectedCategoryId!
          : '',
      quantity: (double.tryParse(quantity.text) ?? 0.0).toInt(),
      uomId: selectedunit?.code ?? "Uom-004",

      // Fixed: Use unitAmount for unit estimated amount, paidAmountCA1 for line amount
      unitEstimatedAmount: (double.tryParse(unitAmount.text) ?? 0.0) == 0.0
          ? (double.tryParse(paidAmountCA1.text) ?? 0.0)
          : (double.tryParse(unitAmount.text) ?? 0.0),
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
      lineEstimatedCurrency: currencyDropDowncontrollerCA3.text,
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
      isPageLoading.value = true;
      //  //  // print("cashAdvTransPayload");
      // Format the request date
      final formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd-MM-yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      final attachmentPayload = await buildDocumentAttachment(imageFiles);
      //  //  // print("cashAdvTransPayload2");
      // Build attachments
      // final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload = finalItemsCashAdvanceNew
          .map((item) => item.toJson())
          .toList();
      //  //  // print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequestDate": requestDate,
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "TotalRequestedAmountInReporting": requestamountINR.text.isNotEmpty
            ? double.tryParse(requestamountINR.text) ?? 0
            : 0,
        "TotalEstimatedAmountInReporting": estimatedamountINR.text.isNotEmpty
            ? double.tryParse(estimatedamountINR.text) ?? 0
            : 0,
        "PrefferedPaymentMethod": paidWithCashAdvance.value!.isEmpty
            ? null
            : paidWithCashAdvance.value,

        "BusinessJustification": justificationController.text,
        "ReferenceId": referenceID.text.trim(),
        "RequisitionId": cashAdvanceRequisitionID.text,
        "CashAdvTrans": cashAdvTransPayload,
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": attachmentPayload},
      };

      //  //  // print("🔗 API Request Body: $requestBody");

      // API call
      final response = await ApiService.post(
        Uri.parse(
          "${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/registercashadvance?functionalentity=CashAdvanceRequisition&submit=$submit&resubmit=${reSubmit ?? false}&screen_name=MyCshAdv",
        ),

        body: jsonEncode(requestBody),
      );

      //  //  // print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];
        isPageLoading.value = false;
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
        isPageLoading.value = false;
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
        isPageLoading.value = false;
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
        isPageLoading.value = false;
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
      print("❌ API Exception: $e");
      Fluttertoast.showToast(
        msg: "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
    isPageLoading.value = false;
  }

  Future<void> saveinEditCashAdvance(
    BuildContext context,
    bool submit,
    bool? reSubmit,
    int? recId, [
    String? reqID,
  ]) async {
    try {
      //  //  // print("cashAdvTransPayload");
      // Format the request date
      final formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd-MM-yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      //  //  // print("cashAdvTransPayload2");
      // Build attachments
      final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload = finalItemsCashAdvance
          .map((item) => item.toJson())
          .toList();
      //  //  // print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequisitionId": reqID ?? "",
        "RecId": recId ?? "",
        "RequestDate": requestDate,
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
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
        "CashAdvTrans": finalItemsCashAdvance
            .map((item) => item.toJson())
            .toList(),
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": attachmentPayload},
      };

      //  //  // print("🔗 API Request Body: $requestBody");

      // API call
      final response = await ApiService.post(
        Uri.parse(
          "${Urls.cashadvanceregistration}registercashadvance?functionalentity=CashAdvanceRequisition&submit=$submit&resubmit=${reSubmit ?? false}&screen_name=MyExpense",
        ),

        body: jsonEncode(requestBody),
      );

      //  //  // print("📥 API Response: ${response.statusCode} ${response.body}");

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
      //  //  // print("❌ API Exception: $e");
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
      //  //  // print("cashAdvTransPayload");
      // Format the request date
      final formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd-MM-yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      //  //  // print("cashAdvTransPayload2");
      // Build attachments
      final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload = finalItemsCashAdvance
          .map((item) => item.toJson())
          .toList();
      //  //  // print("cashAdvTransPayloadx$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequisitionId": requisitionId ?? "",
        "RecId": recId ?? "",
        "workitemrecid": reqID ?? '',
        "RequestDate": requestDate,
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "TotalRequestedAmountInReporting": requestamountINR.text.isNotEmpty
            ? double.tryParse(requestamountINR.text) ?? 0
            : 0,
        "TotalEstimatedAmountInReporting": estimatedamountINR.text.isNotEmpty
            ? double.tryParse(estimatedamountINR.text) ?? 0
            : 0,
        "PrefferedPaymentMethod": paidWithController.text.trim().isEmpty
            ? null
            : paidWithController.text,
        "BusinessJustification": justificationController.text,
        "ReferenceId": referenceID.text.trim(),
        "CashAdvTrans": cashAdvTransPayload,
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": attachmentPayload},
      };

      //  //  // print("🔗 API Request Body: $requestBody");

      // API call
      final response = await ApiService.put(
        Uri.parse(
          "${Urls.cashadvanceregistration}reviewcashadvancerequisition?updateandaccept=$submit&screen_name=MyPendingApproval",
        ),

        body: jsonEncode(requestBody),
      );

      //  //  // print("📥 API Response: ${response.statusCode} ${response.body}");

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
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        Fluttertoast.showToast(
          msg: " $message",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        finalItemsCashAdvance = [];
      }
    } catch (e) {
      //  //  // print("❌ API Exception: $e");
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
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate$attachmentPayload");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
      isLoadingGE1.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
      isLoadingGE1.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
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
      "Currency": currencyDropDowncontroller.text ?? '',
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
      //  //  // print("requestBody$requestBody");
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
        //  //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

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
    int recIds,
  ) async {
    isLoadingGE1.value = true;
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate$attachmentPayload");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
      isLoadingGE1.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
      isLoadingGE1.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "UnprocessedRecId": recIds,
      "EmployeeId": Params.employeeId,
      "EmployeeName": userName.value,
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : paidToController.text ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "ReferenceNumber": referenceID.text,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paymentMethodID.trim().isEmpty ? null : paymentMethodID,
      "TotalAmountTrans": (double.tryParse(paidAmount.text) ?? 0).toInt(),
      "TotalAmountReporting": (double.tryParse(amountINR.text) ?? 0).toInt(),

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": currencyDropDowncontroller.text,
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
          '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=$reSubmit&screen_name=MyExpense&unprocessed_recId=$recIds',
        ),

        body: jsonEncode(requestBody),
      );
      //  //  // print("requestBody$requestBody");
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
        Navigator.pushNamed(context, AppRoutes.unProcessed);
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
        //  //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

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
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate$attachmentPayload");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId ?? '',
      if (recId > 0) "RecId": recId,
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": (paidWithCashAdvance.value?.trim().isEmpty ?? true)
          ? null
          : paidWithCashAdvance.value,
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
    //  //  // print(jsonEncode(requestBody));
    try {
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.cashadvancerequisitions}&submit=$bool&resubmit=$reSubmit&screen_name=MyExpense',
        ),

        body: jsonEncode(requestBody),
      );
      //  //  // print("requestBody$requestBody");
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
        //  //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  static DateTime startOfDayUTC(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// End of day in UTC
  static DateTime endOfDayUTC(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day, 23, 59, 59);
  }

  static int toMillisUTC(DateTime date) {
    return date.toUtc().millisecondsSinceEpoch;
  }

  /// Week range (Monday → Sunday) in UTC
   Map<String, int> getWeekRangeUTC(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));

    final startUtc = startOfDayUTC(start);
    final endUtc = endOfDayUTC(end);

    return {
      "fromDate": startUtc.millisecondsSinceEpoch,
      "toDate": endUtc.millisecondsSinceEpoch,
    };
  }

   Future<RuleConfigSettings?> getRuleConfig({
    required String employeeId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    print("Fetching rule config for Employee ID: $employeeId, From: $fromDate, To: $toDate");
    try {
      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/ruleconfigsettings?employeeid=$employeeId&fromdate=${fromDate.millisecondsSinceEpoch.toString()}&todate=${toDate.millisecondsSinceEpoch.toString()}',
        ),
      );

      if (response.body.isNotEmpty) {
      // Parse the response body as JSON
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return RuleConfigSettings.fromJson(jsonData);
    }
    } catch (e) {
      print("RuleConfig API Error: $e");
    }

    return null;
  }

  Future<void> cashadvanceregistrations(
    context,
    bool bool,
    int recId,
    String expenseId,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate$attachmentPayload");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId ?? '',
      if (recId > 0) "RecId": recId,
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWithController.text.trim().isEmpty
          ? null
          : paidWithController.text.trim(),
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
    //  //  // print(jsonEncode(requestBody));
    try {
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.cashadvanceregistrationApi}updateandaccept=$bool&screen_name=MyPendingApproval',
        ),

        body: jsonEncode(requestBody),
      );
      //  //  // print("requestBody$requestBody");
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
        //  //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  Future<void> cashadvanceregistrationsHub(
    context,
    bool bool,
    int recId,
    String expenseId,
    int workitemrecid,
  ) async {
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate$attachmentPayload");
    //  //  // print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
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
      "PaymentMethod": paidWithController.text.trim().isEmpty
          ? null
          : paidWithController.text.trim(),
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
    //  //  // print(jsonEncode(requestBody));
    try {
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.cashadvanceregistrationApi}updateandaccept=$bool&screen_name=MyPendingApproval',
        ),

        body: jsonEncode(requestBody),
      );
      //  //  // print("requestBody$requestBody");
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
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
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
        //  //  // print("❌  ${response.body}");
        finalItems.clear();
        finalItemsSpecific.clear();
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");

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
  //   final parsedDate = DateFormat('dd-MM-yyyy').parse(dateString);
  //   final receiptDate = parsedDate.millisecondsSinceEpoch;
  //   final attachmentPayload = await buildDocumentAttachment(imageFiles);
  //   if (!bool) {
  //     isUploading.value = true;
  //   } else {
  //     isGESubmitBTNLoading.value = true;
  //   }
  //   final hasValidUnit = selectedunit?.code != null;
  //    //  //  // print("hasValidUnit$hasValidUnit${selectedunit?.code}");

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
  //      //  //  // print("requestBody$requestBody");
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
  //        //  //  // print("❌  ${response.body}");
  //       if (!bool) {
  //         isUploading.value = false;
  //       } else {
  //         isGESubmitBTNLoading.value = false;
  //       }
  //     }
  //   } catch (e) {
  //      //  //  // print("❌ Exception: $e");

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
    //  //  // print("calculatedLineAmount$qty,$unit 2233");
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
        //  //  // print("Fetched Expenses: $getAllListGExpense");

        return getAllListGExpense;
      } else {
        //  //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching expenses: $e');
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
      //  //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchTimeSheetData() async {
    isLoadingLeaves.value = true;
    timesheetList.clear();
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
          // API returned LIST
          timesheetList.addAll(
            decoded.map((e) => TimesheetModel.fromJson(e)).toList(),
          );
        } else if (decoded is Map<String, dynamic>) {
          // API returned SINGLE OBJECT
          timesheetList.add(TimesheetModel.fromJson(decoded));
        }
      } else {
        // print('❌ Timesheet Error: step2');
        timesheetList.clear();
      }
    } catch (e) {
      // print('❌ Timesheet Error: $e');
      timesheetList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchMyteamSheetTimeSheetData() async {
    isLoadingLeaves.value = true;
    myTeamtimesheetList.clear();
    const String baseUrl =
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/myteamtimesheet';

    String? apiStatus;
    switch (selectedStatus) {
      case 'In Process':
        apiStatus = 'Pending';
        break;

      case 'All':
        apiStatus = null;
        break;
    }

    final filterQuery = apiStatus != null
        ? 'TSRTimesheetHeader.ApprovalStatus__eq%3D$apiStatus'
        : '';

    final url = Uri.parse(
      '$baseUrl?filter_query=$filterQuery&page=1&sort_order=asc',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          // API returned LIST
          myTeamtimesheetList.addAll(
            decoded.map((e) => TimesheetModel.fromJson(e)).toList(),
          );
        } else if (decoded is Map<String, dynamic>) {
          // API returned SINGLE OBJECT
          myTeamtimesheetList.add(TimesheetModel.fromJson(decoded));
        }
      } else {
        // print('❌ Timesheet Error: step2');
        myTeamtimesheetList.clear();
      }
    } catch (e) {
      // print('❌ Timesheet Error: $e');
      myTeamtimesheetList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchMyteamattendanceList() async {
    isLoadingLeaves.value = true;
    attendanceList.clear();
    const String baseUrl =
        '${Urls.baseURL}/api/v1/attendenceservices/punchinoutendpoints/myteamattendence?page=1&sort_order=asc';

    final url = Uri.parse(baseUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          // API returned LIST
          attendanceList.addAll(
            decoded.map((e) => TeamAttendance.fromJson(e)).toList(),
          );
        } else if (decoded is Map<String, dynamic>) {
          // API returned SINGLE OBJECT
          attendanceList.add(TeamAttendance.fromJson(decoded));
        }
      } else {
        // print('❌ Timesheet Error: step2');
        attendanceList.clear();
      }
    } catch (e) {
      // print('❌ Timesheet Error: $e');
      attendanceList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchMyattendanceList() async {
    isLoadingLeaves.value = true;
    attendanceList.clear();
    final String baseUrl =
        '${Urls.baseURL}/api/v1/attendenceservices/punchinoutendpoints/punchinpunchouttrans?filter_query=PUNAttendanceTransaction.CreatedBy__eq%3D${Params.userId}%26PUNAttendanceTransaction.IsActive__eq%3DTrue&page=1&sort_order=asc';

    final url = Uri.parse(baseUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          // API returned LIST
          attendanceList.addAll(
            decoded.map((e) => TeamAttendance.fromJson(e)).toList(),
          );
        } else if (decoded is Map<String, dynamic>) {
          // API returned SINGLE OBJECT
          attendanceList.add(TeamAttendance.fromJson(decoded));
        }
      } else {
        // print('❌ Timesheet Error: step2');
        attendanceList.clear();
      }
    } catch (e) {
      // print('❌ Timesheet Error: $e');
      attendanceList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<void> fetchPendingApprovalsTimeSHeet() async {
    isLoadingLeaves.value = true;
    myTeamtimesheetList.clear();
    sheetsPendingApprovalsList.clear();
    const String baseUrl =
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/pendingtimesheetapprovals?filter_query=TSRTimesheetHeader.ApprovalStatus__eq%3DPending&page=1&sort_order=asc';

    final url = Uri.parse(baseUrl);

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          // API returned LIST
          sheetsPendingApprovalsList.addAll(
            decoded.map((e) => TimesheetModel.fromJson(e)).toList(),
          );
        } else if (decoded is Map<String, dynamic>) {
          // API returned SINGLE OBJECT
          sheetsPendingApprovalsList.add(TimesheetModel.fromJson(decoded));
        }
      } else {
        // print('❌ Timesheet Error: step2');
        sheetsPendingApprovalsList.clear();
      }
    } catch (e) {
      // print('❌ Timesheet Error: $e');
      sheetsPendingApprovalsList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  RxList<TaskModelDropDown> allTaskList = <TaskModelDropDown>[].obs;
  RxList<TaskModelDropDown> taskList = <TaskModelDropDown>[].obs;
  RxBool isTaskLoading = false.obs;

  Future<void> fetchTasksTimeSheet({
    required int fromDate,
    required int toDate,
  }) async {
    isTaskLoading.value = true;
    taskList.clear();
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/tasksbyboard?employeeid=${Params.employeeId}&fromdate=$fromDate&todate=$toDate',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          final tasks = decoded
              .map((e) => TaskModelDropDown.fromJson(e))
              .toList();
          allTaskList.assignAll(tasks);
          // taskList.assignAll(tasks);
        } else {
          // print('❌ Task API Error: st33');
          taskList.clear();
        }
      } else {
        // print('❌ Task API Error: st35');
        taskList.clear();
      }
    } catch (e) {
      // print('❌ Task API Error: $e');
      taskList.clear();
    } finally {
      isTaskLoading.value = false;
    }
  }

  void filterTasksByBoardLineItem(String boardId, int index) {
    final filtered = allTaskList
        .where((task) => task.boardId == boardId)
        .toList();

    lineItems[index].filteredTasks.assignAll(filtered);
  }

  void filterTasksByBoard(String boardId) {
    final filtered = allTaskList
        .where((task) => task.boardId == boardId)
        .toList();
    // print("filtered$filtered");
    taskList.assignAll(filtered);
  }

  List<LineItemModel> lineItems = [
    LineItemModel(), // Item 1
  ];
  var timeSheetRange = <TimeSheetRangeModel>[].obs;
  Future<void> loadTimeSheetRange({
    required int fromDate,
    required int toDate,
  }) async {
    try {
      isLoading.value = true;

      final data = await fetchTimeSheetRange(
        fromDate: fromDate,
        toDate: toDate,
      );

      timeSheetRange.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  int getStartOfDayMillis(DateTime date) {
    return DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
  }

  int getEndOfDayMillis(DateTime date) {
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return end.millisecondsSinceEpoch;
  }

  Future<List<TimeSheetRangeModel>> fetchTimeSheetRange({
    required int fromDate,
    required int toDate,
  }) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timesheetrange',
    );

    final payload = {
      "EmployeeId": Params.employeeId,
      "FromDate": fromDate,
      "ToDate": toDate,
    };

    try {
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map<TimeSheetRangeModel>((e) => TimeSheetRangeModel.fromJson(e))
              .toList();
        } else {
          throw Exception('Invalid response format: Expected List');
        }
      } else {
        throw Exception(
          'Failed to load timesheet range '
          '(Status: ${response.statusCode}, Body: ${response.body})',
        );
      }
    } catch (e, stackTrace) {
      // 🔴 Log for debugging
      debugPrint('fetchTimeSheetRange error: $e');
      debugPrintStack(stackTrace: stackTrace);

      // 🔁 Rethrow so UI can handle it (Snackbar, dialog, etc.)
      rethrow;
    }
  }

  final RxMap<int, Map<int, TimeEntryModel>> timeEntries =
      <int, Map<int, TimeEntryModel>>{}.obs;

  Future<void> fetchBoardDropDown() async {
    isTaskLoading.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/boardsbyemp?employeeid=${Params.employeeId}',
    );

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          boardList.assignAll(
            decoded
                .map<BoardModel>(
                  (e) => BoardModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );
        } else {
          // print('❌ Board API Error: Response is not a list');
          boardList.clear();
        }
      } else {
        // print('❌ Board API Error: Invalid status');
        boardList.clear();
      }
    } catch (e) {
      // print('❌ Board API Error: $e');
      boardList.clear();
    } finally {
      isTaskLoading.value = false;
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
        'filter_query=LVRLeaveHeader.ApprovalStatus__eq%3D$apiStatus';

    final url = Uri.parse(
      '$baseUrl?${apiStatus != null ? filterQuery : ""}&page=1&sort_order=asc',
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
      //  //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  bool isAnyButtonLoading() {
    return buttonLoaders.values.any((loading) => loading);
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
        'LVRLeaveCancellationHeader.CreatedBy__eq%3D${Params.userId}${apiStatus != null ? '%26LVRLeaveCancellationHeader.ApprovalStatus__eq%3D$apiStatus' : ""}';

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
      //  //  // print('❌ Error fetching leave requisitions: $e');
      leaveRequisitionList.clear();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  void updateEntry(int lineIndex, int entryDate, TimeEntryModel entry) {
    timeEntries[lineIndex] ??= {};
    timeEntries[lineIndex]![entryDate] = entry;
    timeEntries.refresh();
  }

  void startTimer(int lineIndex, DateTime date) {
    final line = lineItems[lineIndex];

    if (line.timerRunning.value) return;

    line.timerRunning.value = true;
    line.timerCompleted.value = false;
    timerClicked = true;
    // ✅ capture start time ONCE
    line.timerStartMillis = DateTime.now().millisecondsSinceEpoch;

    line.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      line.elapsedSeconds.value++;
    });
  }

  void stopTimer(int lineIndex, DateTime date) {
    final line = lineItems[lineIndex];

    line.timer?.cancel();
    line.timerRunning.value = false;
    line.timerCompleted.value = true; // 👈 ONE TIME ONLY

    final dateKey = date.millisecondsSinceEpoch;

    // ⏰ end time
    final timeToMillis = DateTime.now().millisecondsSinceEpoch;

    // ⏰ start time (stored earlier)
    final timeFromMillis = line.timerStartMillis;

    // 🧮 formatted HH:mm
    final formattedTime = formatSecondsToHHmm(line.elapsedSeconds.value);

    updateEntry(
      lineIndex,
      dateKey,
      TimeEntryModel(
        entryDate: dateKey,
        timeFrom: timeFromMillis,
        timeTo: timeToMillis,
        totalHours: formattedTime,
      ),
    );
  }

  String formatSecondsToHHmm(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> pendingApprovalLeaveRequisitions() async {
    isLoadingLeaves.value = true;
    pendingApproval.clear();
    const String baseUrl =
        '${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/pendingapprovals';

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
      // print('❌ Error fetching leave requisitions: $e');
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
        //  //  // print("Fetched Expenses: $getAllListGExpense");

        return getAllListGExpense;
      } else {
        //  //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingunprocess.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching expenses: $e');
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

        //  //  // print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return getAllListGExpense;
      } else {
        //  //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching expenses: $e');
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

        //  //  // print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return getAllListCashAdvanseMyteams;
      } else {
        //  //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<void> fetchApprovalDetails(BuildContext context) async {
    try {
      final response = await ApiService.get(
        Uri.parse(
          "https://digixepenseapi.loclx.io/api/v1/masters/approvalmanagement/workflowapproval/externalapproval/pendingapprovals?page=1&limit=10",
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => ExternalApprovalMetadataPage(
        //       metadata: jsonData["MetadataJson"],
        //       approverActionId: jsonData["ApproverActionId"],
        //     ),
        //   ),
        // );
      } else {
        throw Exception("Failed to load details");
      }
    } catch (e) {
      // setState(() => isLoading = false);
      debugPrint("Error: $e");
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
        //  //  // print("Fetched pendingApprovals: $pendingApprovals");

        return pendingApprovals;
      } else {
        //  //  // print(

        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching pendingApprovals: $e');
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

        //  //  // print(
        //   "paymentMethods: ${paymentMethods.map((e) => e.paymentMethodName).toList()}",
        // );

        return paymentMethods;
      } else {
        //  //  // print(
        //   'Failed to load payment methods. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      //  //  // print('Error fetching payment methods: $e');
      return [];
    }
  }

  int? parseDateToEpoch(String formattedDate) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(formattedDate.trim());
      return date.millisecondsSinceEpoch;
    } catch (e) {
      return null;
    }
  }

  String formattedDate(int millis) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    return DateFormat('dd-MM-yyyy').format(date.toUtc());
  }

  Future<ExchangeRateResponse?> fetchExchangeRatePerdiem() async {
    // if (selectedCurrency.value == null) {
    //    //  //  // print('selectedCurrency is null');
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
        //  //  // print("amountINR: ${quantity.text}");

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
          exchangeCurrencyCode.text = data['Currencycode'];
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
    print("fromDate111${fromDateController.text}");
    isLoadingGE1.value = true;
    try {
      final fromDate = parseDateToEpoch(fromDateController.text);
      final toDate = parseDateToEpoch(toDateController.text);
      final location = (selectedLocationController ?? '').trim();
      final employeeId = Params.employeeId;
      final token = Params.userToken ?? '';

      // Guard against empty location
      print("fromDate111$fromDate");
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
    // cashAdvanceIds.clear();
    multiSelectedItems.clear();
    buttonLoaders.clear();
    // cashAdvanceIds.text = "";
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
    accountingDistributions.clear();
    update();
    // Reset allocation and accounting distribution data
    allocationLines = [];
    accountingDistributions = [];

    // Optional: Reset any state-managed variables like totals
    // totalAmount.value = 0.0; // Example, if using GetX
    // isLoading.value = false;

    //  //  // print("All form fields cleared.");
  }

  Future<bool> deleteExpense(int recId) async {
    final Uri url = Uri.parse(
      '${Urls.deleteExpense}$recId&screen_name=MyExpense',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        String message = "Expense deleted successfully";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        await fetchGetallGExpense();

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 22, 87, 3),
          textColor: Colors.white,
          fontSize: 16,
        );

        return true;
      } else {
        String message = "Failed to delete expense";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error deleting expense",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );

      return false;
    }
  }

  Future<bool> deleteAttachment(int recId) async {
    final Uri url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/attachments/attachment?RecId=$recId&screen_name=Tasks',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        String message = "Expense deleted successfully";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 22, 87, 3),
          textColor: Colors.white,
          fontSize: 16,
        );

        return true;
      } else {
        String message = "Failed to delete expense";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );

        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBoard(int recId) async {
    final Uri url = Uri.parse(
      '${Urls.baseURL}api/v1/kanban/boards/boards/boards?RecId=$recId',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        String message = "Board deleted successfully";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        await fetchGetallGExpense();

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 22, 87, 3),
          textColor: Colors.white,
          fontSize: 16,
        );

        return true;
      } else {
        String message = "Failed to delete expense";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error deleting expense",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );

      return false;
    }
  }

  Future<bool> deleteLeave(int recId) async {
    final Uri url = Uri.parse(
      '${Urls.deleteLeave}$recId&screen_name=LVRLeaveHeader',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        String message = "Leave deleted successfully";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        await fetchLeaveAnalytics(Params.employeeId, Params.userToken);

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 22, 87, 3),
          textColor: Colors.white,
          fontSize: 16,
        );

        return true;
      } else {
        String message = "Failed to delete leave";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error deleting leave",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );

      return false;
    }
  }

  Future<bool> deleteTimeSheets(int recId) async {
    final Uri url = Uri.parse(
      '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/deletetimesheet?RecId=$recId&screen_name=TSRTimesheetHeader',
    );

    try {
      final response = await ApiService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        String message = "Timesheet deleted successfully";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        // Refresh list
        await fetchTimeSheetData();

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 22, 87, 3),
          textColor: Colors.white,
          fontSize: 16,
        );

        return true;
      } else {
        String message = "Failed to delete timesheet";

        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          message = responseData['detail']?['message'] ?? message;
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error deleting timesheet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );

      return false;
    }
  }

  Future<bool> deleteExpenseUnprocess(int recId) async {
    final String token = Params.userToken ?? ''; // Safely get your bearer token

    final Uri url = Uri.parse(
      '${Urls.deleteExpenseUnprocess}$recId&screen_name=MyExpense',
    );

    try {
      final response = await ApiService.delete(url);
      String message = "Expense deleted successfully";
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
      //  //  // print('❌ Error deleting expense: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> buildCustomFieldValues() {
    return customFields
        .where((field) {
          final fieldType = field['FieldType'];
          final value = fieldType == 'List'
              ? field['SelectedValue']
              : field['EnteredValue'];

          return value != null && value.toString().trim().isNotEmpty;
        })
        .map((field) {
          final fieldType = field['FieldType'];
          final value = fieldType == 'List'
              ? field['SelectedValue']
              : field['EnteredValue'];

          return {
            "CustomFieldEntity": field['CustomFieldEntity'] ?? "",
            "FieldId": field['FieldId'] ?? "",
            "FieldValue": value.toString(),
            "FieldName": field['FieldName'] ?? "",
          };
        })
        .toList();
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
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "ReceiptDate": toDateController.text.isNotEmpty
            ? parseDateToEpoch(toDateController.text)
            : null,
        "Currency": currencyDropDowncontroller.text,
        "Description": purposeController.text.isNotEmpty
            ? purposeController.text
            : '',
        "Source": "Web",
        "ExchRate": 1,
        if (recIds != null) "RecId": recIds,
        "ExpenseType": "PerDiem",
        // "ExpenseCategoryId":null,
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
        // fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        //  //  //  // print("✅ ");
      } else if (response.statusCode == 430) {
        final data = jsonDecode(response.body);

        final message = data['detail']['message'];
        final recId = data['detail']['RecId'];
        clearFormFieldsPerdiem();
        // fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message",
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
        // fetchPerDiemRates();
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

        //  //  // print("❌  ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      print("❌ Exception: $e");
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
    //  //  // print(recId);
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
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "ReceiptDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "Currency": currencyDropDowncontroller.text,
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
        "ExpenseHeaderCustomFieldValues": buildCustomFieldValues,
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
        // fetchPerDiemRates();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: " ${responseData['detail']['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  //  //  // print("✅ ");
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
        //  //  // print("❌  ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");
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
    //  //  // print(recId);
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
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "ReceiptDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "Currency": currencyDropDowncontroller.text,
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
        "ExpenseHeaderCustomFieldValues": buildCustomFieldValues,
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
        // fetchPerDiemRates();
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
        //  //  //  // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        //  //  // print("❌  ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      //  //  // print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<List<PerdiemResponseModel>> fetchSecificPerDiemItem(
    context,
    int recId,
    bool readOnly,
  ) async {
    isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getSpecificPerdiemExpense}$recId&lock_id=$recId',
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
        //       DateFormat('dd-MM-yyyy').format(expense.receiptDate);
        // }
        //  //  //  // print("Perdiem ID: ${expenseIdController.text}");
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.perDiem,
          arguments: {'item': specificPerdiemList[0], 'readOnly': readOnly},
        );
        return specificPerdiemList;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
        //  //  // print(
        //   'Failed to load payment methods. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      //  //  // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;
      isLoadingGE2.value = false;
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
        //       DateFormat('dd-MM-yyyy').format(expense.receiptDate);
        // }
        //  //  //  // print("Perdiem ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.perDiem,
          arguments: {'item': specificPerdiemList[0]},
        );
        return specificPerdiemList;
      } else {
        isLoadingGE1.value = false;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return [];
      }
    } catch (e) {
      //  //  // print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  RxBool isLoadingAll = false.obs;
  RxBool isLoadingUnread = false.obs;
  Future<void> fetchNotifications() async {
    try {
      isLoadingAll.value = true; // ✅ correct flag

      final response = await ApiService.get(
        Uri.parse('${Urls.getNotifications}${Params.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        // ✅ Store ALL notifications — do NOT filter here
        notifications.value = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      isLoadingAll.value = false; // ✅ correct flag
    }
  }

  Future<void> fetchUnreadNotifications() async {
    try {
      isLoadingUnread.value = true; // ✅ correct flag

      final response = await ApiService.get(
        Uri.parse('${Urls.getUnreadedNotifications}${Params.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        unreadNotifications.value = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        // ✅ Update count from unread list
        unreadCount.value = unreadNotifications.length;
      }
    } catch (e) {
      print('❌ Error fetching unread notifications: $e');
    } finally {
      isLoadingUnread.value = false; // ✅ correct flag
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
        //  //  // print("❌ Mark as read failed: ${response.body}");
      }
    } catch (e) {
      //  //  // print("❌ Error marking as read: $e");
    }
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    const apiKey = "AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0";
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:in';

    final response = await ApiService.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //  //  // print("LocationDropDown$data");
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

      //  //  //  // print(
      //   '📍 Current Position: Lat=${position.latitude}, Lng=${position.longitude}',
      // );

      // _currentLatLng = LatLng(position.latitude, position.longitude);
    } else {
      //  //  // print('❌ Location permission not granted');
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
      return {
        "RecId": e.key,
        "CancelRequest": e.value.replaceAll(" ", ""), // ✅ removes space
      };
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
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        Navigator.pushNamed(context, AppRoutes.leaveDashboard);
        return true;
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
        // debugPrint("Cancel Leave Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Cancel Leave Error: $e");
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
          responseData['detail']['message'] ?? 'Cancel Successfully';
      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        Navigator.pushNamed(context, AppRoutes.generalExpense);
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
        Navigator.pushNamed(context, AppRoutes.leaveDashboard);
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
    vehicleTypes.clear();
    isLoadingGE2.value = true;
    final dateToUse = selectedDateMileage ?? DateTime.now();
    //  //  // print("fetchExpenseCategory${selectedProject?.code}");
    //  //  // print("fetchExpenseCategory$selectedDateMileage");
    isLoading.value = true;
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
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
        final data = jsonDecode(response.body);
        final message = data['detail']['message'];
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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
    selectedDateMileage = null;
    expenseIdController.clear();
    employeeIdController.clear();
    mileageVehicleName.clear();
    projectIdController.clear();
    mileageVehicleID.clear();
    selectedVehicleType = null;
    // isRoundTrip = false;
    mileagDateController.clear();
    vehicleTypes.clear();
    isEnable.value = false;
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
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "ReceiptDate": DateTime.now().millisecondsSinceEpoch,
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseId": expenseId ?? "",
        "ExpenseType": "Mileage",
        "RecId": recId,
        "Currency": currencyDropDowncontroller.text,
        "MileageRateId": mileageVehicleID.text,
        "VehicleType": selectedVehicleType?.name ?? "",
        "FromLocation": tripControllers.first.text,
        "ToLocation": tripControllers.last.text,
        "CashAdvReqId": cashAdvanceIds.text,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": accountingDistributions.isNotEmpty
            ? accountingDistributions.map((e) => e?.toJson()).toList()
            : [],
        "ExpenseTrans": expenseTransMap,
        "ProjectId": projectIdController.text.isEmpty
            ? null
            : projectIdController.text,
      };

      // 🔹 Debug log
      //  //  // print("🚀 SUBMIT PAYLOAD => ${jsonEncode(payload)}");

      // 🔹 API call
      final response = await ApiService.post(
        Uri.parse(
          '${Urls.mileageregistration}Submit=$boolValue&Resubmit=$submit&screen_name=MileageRegistration',
        ),

        body: jsonEncode(payload),
      );

      //  //  // print("📡 RESPONSE STATUS: ${response.statusCode}");
      //  //  // print("📡 RESPONSE BODY: ${response.body}");

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
          //  //  // print("❌ Error handling 428 justification: $e");
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
      //  //  // print("🔥 Exception during API call: $e");
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
        "EmployeeId": employeeDropDownController.text.trim().isEmpty
            ? null
            : employeeDropDownController.text.trim(),
        "EmployeeName": employeeName.text.trim().isEmpty
            ? null
            : employeeName.text.trim(),
        "ReceiptDate": DateTime.now().millisecondsSinceEpoch,
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseId": expenseId ?? "",
        "ExpenseType": "Mileage",
        "RecId": recId,
        "Currency": currencyDropDowncontroller.text,
        "MileageRateId": mileageVehicleID.text,
        "VehicleType": selectedVehicleType?.name ?? "Car",
        "FromLocation": tripControllers.first.text,
        "ToLocation": tripControllers.last.text,
        // "RecId": null,
        "CashAdvReqId": cashAdvanceIds.text,
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": accountingDistributions.isNotEmpty
            ? accountingDistributions.map((e) => e?.toJson()).toList()
            : [],
        "ExpenseTrans": expenseTransMap,
        "ProjectId": projectIdController.text,
      };

      // Print payload for debugging
      //  //  // print(jsonEncode(payload));

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
        //  //  //  // print(" ${response.body}");
      }
    } catch (e) {
      //  //  // print("🔥 Exception during API call: $e");
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
    final formatted = DateFormat('dd-MM-yyyy').format(dateToFormat);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
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
    int todayEpoch = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('${Urls.getdimensionsDropdownName}$todayEpoch');

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
    //  //  // print("lastLoadedRole$lastLoadedRole");
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
      //  //  // print('chartData$chartData');
      // isLoading = false;
    } else {
      // Handle error
      isUploadingCards.value = false;
      // isLoading = false;

      //  //  // print(' ${response.statusCode} ${response.body}');
    }
  }

  Future<void> fetchAndReplaceValue() async {
    isUploadingCards.value = true;

    final DateTime now = DateTime.now();

    // ✅ First day of current month
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    // ✅ Today
    final DateTime today = DateTime(now.year, now.month, now.day);

    final int startDate = firstDayOfMonth.millisecondsSinceEpoch;
    final int endDate = today.millisecondsSinceEpoch;

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
      }
    }

    isUploadingCards.value = false;
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
      //  //  // print(" $e");
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

  Future<bool> deleteShelf({
    required int recId,
    required BuildContext context,
    required String boardIdNumb,
  }) async {
    final uri = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/shelfs/shelfs/shelfsdelete?RecId=$recId',
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
        //  //  // print("Fetched users: $usersJson");
        userList.value = usersJson.map((json) => User.fromJson(json)).toList();

        //  //  // print("Fetched users: ${userList.map((u) => u.userName).toList()}");

        // Optional: set default selected user
        if (userList.isNotEmpty) {
          selectedUser.value = userList.first;
          userIdController.text = userList.first.userId;
        }
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      //  //  // print('Error fetching users: $e');
    }
  }

  Future<List<CashAdvanceReqModel>> fetchCashAdvanceRequests() async {
    final dateToUse = selectedDate ?? DateTime.now();

    isUploadingCards.value = true;
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
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
    //  //  // print("Calling fetchAndCombineData (Payslip Analytics)...");
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse('${Urls.baseURL}/api/v1/payslip/analytics'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        //  //  // print("Payslip API response: $data");

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

        //  //  // print("payslipAnalyticsCards: $payslipAnalyticsCards");
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
    manageExpensesCards.clear();
    //  //  // print("Calling fetchManageExpensesCards...");
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/analytics',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        //  //  // print("API response: $data");

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

        //  //  // print("manageExpensesCards: $manageExpensesCards");
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
    //  //  // print("cashAdvanceList");
    try {
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/getcashadvanceheader?filter_query=CSHCashAdvReqHeader.CreatedBy__eq%3D${Params.userId}&page=1&sort_by=ModifiedDatetime&sort_order=desc',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //  //  // print("cashAdvanceList$data");

        cashAdvanceList.value = (data as List)
            .map((item) => CashAdvanceModel.fromJson(item))
            .toList();

        //  //  // print("cashAdvanceList$cashAdvanceList");
        isUploadingCards.value = false;
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch expense cards: ${response.statusCode}',
        );
        isUploadingCards.value = false;
      }
    } catch (e) {
      print("cashadvanse$e");
      Get.snackbar('Error', 'Something went wrong: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> getExpenseList() async {
    //  //  // print("Fetching Expense List...");
    try {
      // Start loader
      isUploadingCards.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/expenseregistration/expenseregistration/expenseheader?filter_query=EXPExpenseHeader.CreatedBy__eq%3D${Params.userId}&page=1&sort_by=ModifiedDatetime&sort_order=desc',
        ),
      );

      //  //  // print("API Response Status: ${response.statusCode}");
      //  //  // print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Ensure API returned a list
        if (decodedData is List && decodedData.isNotEmpty) {
          final expenses = decodedData
              .map((item) => ExpenseListModel.fromJson(item))
              .toList();

          // Assign to observable list
          expenseList.assignAll(expenses);

          //  //  // print("✅ Expense list updated with ${expenseList.length} items");
        } else {}
      } else {}
    } catch (e, stackTrace) {
      //  //  // print("❌ Exception in getExpenseList: $e");
      //  //  // print(stackTrace);
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
        apiStatus = '';
        break;
      default:
        apiStatus = '';
    }

    String filterQuery = 'CSHCashAdvReqHeader.CreatedBy__eq%3D${Params.userId}';

    if (apiStatus.isNotEmpty) {
      filterQuery += '%26CSHCashAdvReqHeader.ApprovalStatus__eq%3D$apiStatus';
    }

    String baseUrl =
        '${Urls.cashAdvanceGetall}?filter_query=$filterQuery&page=1&sort_order=asc';

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
          //  //  // print('⚠️ Unexpected data format: expected a List');
          cashAdvanceList.clear();
        }

        //  //  // print("✅ Fetched Cash Advances: ${cashAdvanceListDashboard.length}");
        isLoadingCA.value = false;
        return cashAdvanceListDashboard.toList();
      } else {
        //  //  //  // print(
        //   '❌ Failed to load cash advances. Status: ${response.statusCode}, Body: ${response.body}',
        // );
        isLoadingCA.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching cash advance requisitions: $e');
      isLoadingCA.value = false;
      return [];
    }
  }

  Future<bool> deleteCashAdvance(int recId) async {
    // if (recId <= 0) return false;
    // print("deleteCashAdvance$recId");
    isDeleting.value = true;
    try {
      // Build URL with query parameters
      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/cashadvancerequisition/cashadvanceregistration/deletecashadvance'
        '?RecId=$recId&screen_name=MyCashAdvance',
      );

      final response = await ApiService.delete(url);

      isDeleting.value = false;
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message =
          responseData['detail']?['message'] ?? 'No message found';
      if (response.statusCode == 204) {
        // Successfully deleted on server
        final responseData = jsonDecode(response.body);

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
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      isDeleting.value = false;
      // print("deleteCashAdvanceeeee$e");

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

          //  //  // print('Appended configList: $configListAdvance');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          //  //  // print('currencies to load countries$currencies');
        }
      } else {
        //  //  // print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      //  //  // print('Error fetching countries: $e');
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

          //  //  // print('justification: $justification');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          //  //  //  // print('currencies to load countries$currencies');
        }
      } else {
        //  //  // print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      //  //  // print('Error fetching countries: $e');
      isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<ExchangeRateResponse?> fetchExchangeRateCA(
    String? currencyCode,
    String? amount,
  ) async {
    final dateToUse = selectedDate ?? DateTime.now();
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
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
      //  //  // print('Error fetching exchange rate: $e');
    }
    return null;
  }

  Map<String, double> exchangeRateCache = {};
  Future<double?> fetchExchangeRatecalculated(String currencyCode) async {
    final dateToUse = selectedDate ?? DateTime.now();
    final formatted = DateFormat('dd-MM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);

    final cacheKey = "$currencyCode-$fromDate";

    // ✅ 1. Check Cache First
    if (exchangeRateCache.containsKey(cacheKey)) {
      return exchangeRateCache[cacheKey];
    }

    final url = Uri.parse('${Urls.exchangeRate}/1/$currencyCode/$fromDate');

    try {
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final double exchangeRate = (data['ExchangeRate'] as num).toDouble();

        // ✅ 2. Store in Cache
        exchangeRateCache[cacheKey] = exchangeRate;

        return exchangeRate;
      }
    } catch (e) {
      debugPrint("Exchange API Error: $e");
    }

    return null;
  }

  Future<double?> fetchMaxAllowedPercentage() async {
    //  //  // print("Callx");
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
          allowedPercentage.text = percentage.toString();
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
      //  //  // print('Error fetching MaxAllowedPercentage: $e');
    }

    return null;
  }

  Future<double?> fetchMaxAllowedPercentageViewReturn() async {
    //  //  // print("Callx");
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
      //  //  // print('Error fetching MaxAllowedPercentage: $e');
    }

    return null;
  }

  Future<Object> fetchSpecificCashAdvanceItem(
    BuildContext context,
    int recId,
    bool bool,
  ) async {
    isLoadingCA.value = true;
    isLoadingGE1.value = true;
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
              ? formatDate(cashAdvance.requestDate)
              : '';
          // Add more controllers if needed
          //  //  // print("Requisition ID: ${requisitionIdController.text}");
        }

        isLoadingCA.value = false;
        isLoadingGE1.value = false;
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
        isLoadingGE1.value = false;
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
        //  //  //  // print(
        //   'Failed to load Cash Advance. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      isLoadingCA.value = false;
      isLoadingGE1.value = false;
      // print('Error fetching Cash Advance: $e');
      return [];
    }
  }

  Future<Object> fetchSpecificCashAdvanceApprovalItem(
    BuildContext context,
    int workitemrecid,
  ) async {
    isLoadingGE1.value = true;
    // print("fetchSpecificCashAdvanceItem");

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

        // Example: Fill  from first item
        if (specificCashAdvanceList.isNotEmpty) {
          final cashAdvance = specificCashAdvanceList[0];
          requisitionIdController.text = cashAdvance.requisitionId ?? '';
          requestDateController.text = cashAdvance.requestDate != null
              ? formatDate(cashAdvance.requestDate)
              : '';
          // Add more  if needed
          //  //  // print("Requisition ID: ${requisitionIdController.text}");
        }

        // Navigate to ViewCashAdvanseReturnForm

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.viewCashAdvanseReturnForms,
          arguments: {'item': specificCashAdvanceList[0]},
        );
        isLoadingGE1.value = false;

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
        isLoadingGE1.value = false;
        //  //  //  // print(
        //   'Failed to load Cash Advance. Status code: ${response.statusCode}',
        // );
        return [];
      }
    } catch (e) {
      isLoadingGE1.value = false;
      // print('Error fetching Cash Advance: $e');
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
    //  //  // print("SuccesFully call All Data");
  }

  Future<void> fetchAndAppendPendingApprovals() async {
    isLoadingGE1.value = true;
    pendingApprovalcashAdvanse.clear();
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
      //  //  // print("Failed to fetch settings: ${response.statusCode}");
      return null;
    }
  }

  Future<SequenceNumber?> fetchCashAdvanceSequence() async {
    final url = Uri.parse(Urls.cashadvancerequisition);

    final response = await ApiService.get(url);

    //  //  // print('Status Codes: ${response.statusCode}');
    //  //  // print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      final sequence = jsonList.firstWhere(
        (item) =>
            item['Module'] == 'CashAdvance' &&
            item['Area'] == 'CashAdvanceRequisitionNo',
        orElse: () => null,
      );
      //  //  // print("sequencess$sequence");
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
    //  //  // print('Comma-separated Text: ${allItems}');
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
    //  //  // print('Selected Cash Advance Items: ${multiSelectedItems.length}');
    for (var item in multiSelectedItems) {
      //  //  // print('→ ID: ${item.cashAdvanceReqId}, Date: ${item.requestDate}');
    }

    //  //  // print('Comma-separated Text: ${cashAdvanceIds.text}');
    //  //  // print('Semicolon-separated for backend: $preloadedCashAdvReqIds');
    viewCashAdvanceLoader.value = false;
  }

  Future<List<CashAdvanceDropDownModel>> fetchExpenseCashAdvanceList() async {
    //  //  // print("currencyDropDowncontroller2${selectedLocation?.city}");
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
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd-MM-yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    //  //  // print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    //  //  // print("receiptDate$attachmentPayload");
    //  //  // print("finalItems${finalItems.length}");

    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    //  //  // print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "workitemrecid": workitemrecid,
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": employeeDropDownController.text.trim().isEmpty
          ? null
          : employeeDropDownController.text.trim(),
      "EmployeeName": employeeName.text.trim().isEmpty
          ? null
          : employeeName.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paidWithController.text.trim().isEmpty
          ? null
          : paidWithController.text.trim(),
      "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      "IsReimbursable": true,
      "Currency":
          selectedCurrency.value?.code ?? currencyDropDowncontroller.text,
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

  RxBool isPaymentMethodsLoading = false.obs;

  Future<Map<String, dynamic>> buildDocumentAttachmentPunchin(
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

        final hash = sha256.convert(fileBytes).toString();

        files.add({
          "index": i,
          "name": fileName,
          "type": mimeType,
          "base64Data": base64Data,
          "Hashmapkey": hash,
        });
      }
    } finally {
      isUploading.value = false;
    }

    // ✅ FINAL STRUCTURE REQUIRED BY BACKEND
    return {
      "DocumentAttachment": {"File": files},
    };
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
      //  //  // print('Error clearing skipped items: $e');
      rethrow;
    }
  }

  // Fetch approval data using unique workitemrecids
  Future<Map<String, dynamic>> fetchApprovalData(
    List<int> workitemrecids,
    String? externalfield, {
    String? field,
    String? value,
  }) async {
    //  //  // print("=== Starting fetchApprovalData ===");
    //  //  // print("Original workitemrecids: $workitemrecids");
    //  //  // print("Filter - Field: $field, Value: $value");

    // Normalize workitemrecids
    final uniqueIds = workitemrecids.toSet().toList();
    final idsParam = uniqueIds.isEmpty ? '0' : uniqueIds.join(',');
    //  //  // print("Final workitemrecid param: $idsParam");

    // Build query parameters
    final Map<String, String> queryParams = {'workitemrecid': idsParam};

    // Add filter params if provided
    if (field?.trim().isNotEmpty ?? false) {
      queryParams['field'] = field!.trim();
    }

    if (value?.trim().isNotEmpty ?? false) {
      queryParams['value'] = value!.trim();
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
    //  //  // print("Request URL: $uri");

    try {
      final response = await ApiService.get(uri);

      //  //  // print("Response status: ${response.statusCode}");
      // Uncomment next line in dev to see raw body
      //  //  //  // print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          if (decoded.first is Map<String, dynamic>) {
            return decoded.first;
          }
        }

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {}; // ✅ safe fallback
      } else {
        throw Exception('Failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      // print("Exception during fetchApprovalData: $e");
      fetchApprovalDetailsExternal(0, field, externalfield);
      rethrow; // Re-throw after logging
    }
  }

  Map<String, dynamic>? metadata;
  Future<void> fetchApprovalDetailsExternal(
    int? workitemrecids,
    String? id,
    String? value,
  ) async {
    metadata = null;
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        Uri.parse(
          "${Urls.baseURL}/api/v1/masters/approvalmanagement/workflowapproval/externalapproval/pendingapprovals"
          "?workitemrecid=${workitemrecids ?? 0}&field=${id ?? ""}&value=${value ?? ''}",
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List && jsonData.isNotEmpty) {
          final firstItem = Map<String, dynamic>.from(jsonData.first);

          // ✅ Assign workitemrecid safely
          workitemrecid = firstItem["workitemrecid"] ?? 0;

          // ✅ Assign metadata safely
          metadata = Map<String, dynamic>.from(firstItem["MetadataJson"] ?? {});

          titleName!.value = "External Approval";
        } else {
          // Empty list response
          metadata!.clear();
        }
      } else {
        throw Exception("Failed to load details");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
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

  Future<ForwardedEmail?> fetchEmailDetails(int recId) async {
    try {
      isLoadingGE2.value = true;
      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/forwardemailmanagement/fetch_specific_emails'
        '?RecId=$recId&screen_name=STPEmailHub',
      );
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        if (jsonList.isNotEmpty) {
          return ForwardedEmail.fromJson(jsonList[0]);
        }
      }
      return null;
    } catch (e) {
      print(e);
    } finally {
      isLoadingGE2.value = false;
    }
  }

  Future<void> fetchAndAppendReports([String? functionalArea]) async {
    getAllListReport.clear();
    isLoadingGE1.value = true;
    final response = await ApiService.get(
      Uri.parse('${Urls.reportsList}?FunctionalArea=$functionalArea'),
    );

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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
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
        builder: (context) => const Center(child: SkeletonLoaderPage()),
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
            builder: (context) => CashAdvanceReportCreateScreen(
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

  void expensenavigateToEditReportScreen(
    BuildContext context,
    int recId,
    bool bool,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: SkeletonLoaderPage()),
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
            builder: (context) => ExpenseReportCreateScreen(
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

  void leavenavigateToEditReportScreen(
    BuildContext context,
    int recId,
    bool bool,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: SkeletonLoaderPage()),
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
            builder: (context) => LeaveReportCreateScreen(
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

  void timeSheetnavigateToEditReportScreen(
    BuildContext context,
    int recId,
    bool bool,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: SkeletonLoaderPage()),
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
            builder: (context) => TimeSheetsReportCreateScreen(
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
      //  //  // print('Error fetching analytics data: $e');
    }
  }

  List<GExpense> get filteredExpenses {
    return getAllListGExpense.where((item) {
      final query = searchQuery.value.toLowerCase();
      final typeFilter = selectedExpenseType.value;

      // ✅ Convert entire object to searchable string
      final searchableText = [
        item.expenseType,
        item.expenseId,
        item.approvalStatus,
        item.employeeName,
        item.totalAmountReporting.toString(),
        item.expenseCategoryId,
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchableText.contains(query);

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

  List<TimesheetModel> get filteredSheet {
    final query = searchQuery.value.toLowerCase();
    final statusFilter = selectedTimeSheetStatusDropDown.value;

    return timesheetList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.timesheetId.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query);

      final apiStatus = mapLeaveStatusToApi(statusFilter);

      final matchesStatus =
          apiStatus == null || item.approvalStatus == apiStatus;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<TimesheetModel> get filteredMyteamSheet {
    final query = searchQuery.value.toLowerCase();
    final statusFilter = selectedMyTeamSheetStatusDropDownmyTeam.value;

    return myTeamtimesheetList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.timesheetId.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query);

      final apiStatus = mapLeaveStatusToApi(statusFilter);

      final matchesStatus =
          apiStatus == null || item.approvalStatus == apiStatus;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<TeamAttendance> get filteredMyteamPunchInOut {
    final query = searchQuery.value.toLowerCase();

    return attendanceList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.transAttendanceId!.toLowerCase().contains(query) ||
          item.employeeId!.toLowerCase().contains(query);

      return matchesQuery;
    }).toList();
  }

  List<TimesheetModel> get filteredMyteamSheetPendingApprovals {
    final query = searchQuery.value.toLowerCase();

    return sheetsPendingApprovalsList.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.timesheetId.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query);

      return matchesQuery;
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
          item.leaveId.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.approvalStatus.toLowerCase().contains(query);

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
  Future<void> fetchAndStoreFeatures(
    String userToken,
    BuildContext context,
  ) async {
    try {
      final response = await ApiService.get(Uri.parse(_baseUrl), context);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Feature> features = jsonData
            .map((item) => Feature.fromJson(item))
            .toList();

        // Save to SharedPreferences as JSON string
        final prefs = await SharedPreferences.getInstance();
        final jsonString = json.encode(jsonData);
        await prefs.setString(_prefsKey, jsonString);
      } else if (response.statusCode == 401) {
        Navigator.pushNamed(context, AppRoutes.login);
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
    // print(featureStates); // DEBUG
    return featureStates[featureId] ?? false;
  }

  Future<void> updateFeatureVisibility() async {
    //  //  // print(showMileage.value);
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
    selectedMembers.clear();

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

  Future<bool> deleteBoardMember({required int recId}) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/boards/boardmembers/boardmembersdelete'
      '?RecId=$recId&screen_name=KANBoardMembers',
    );

    final response = await ApiService.delete(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail'];
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[00],
        textColor: Colors.green[800],
        fontSize: 16.0,
      );
      return true;
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail'];
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<List<BoardMember>> boardmemberslist(String boardId) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/boards/boardmembers/userlistexcludingboardmembers'
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

  Future<void> loadAllCustomFieldValues() async {
    for (var field in customFields) {
      if (field['FieldType'] == 'List') {
        await fetchCustomFieldValues(field['FieldId']);
      }
    }
  }

  Future<void> fetchCustomFieldValues(String fieldId) async {
    final index = customFields.indexWhere(
      (field) => field['FieldId'] == fieldId,
    );
    if (index == -1) return;

    // Prevent multiple API calls
    if (customFields[index]['isLoading'] == true) return;

    customFields[index]['isLoading'] = true;

    final url =
        "${Urls.baseURL}/api/v1/masters/fieldmanagement/customfields/customfieldlistvalues?filter_query=STPCustomFieldListValues.FieldId__eq%3D$fieldId&page=1&sort_order=asc";

    final response = await ApiService.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final options = data.map((e) => CustomDropdownValue.fromJson(e)).toList();

      customFields[index]['Options'] = options;
    }

    customFields[index]['isLoading'] = false;

    customFields.refresh();
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
    selectedDashboard.value = null;
    availableRoles.clear();
    currentRole.value = '';
    try {
      final list = await fetchDashboardWidgets(); // your existing API function
      print('listlist$list');
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
    availableRoles.clear();
    currentRole.value = '';
    selectedDashboard.value = dashboard;

    // 👉 Handle null or empty dashboardData
    if (dashboard.dashboardData == null || dashboard.dashboardData.isEmpty) {
      availableRoles.clear();
      currentRole.value = '';

      // No data → stop here (UI will show empty message)
      return;
    }

    // extract roles
    final extracted = dashboard.dashboardData
        .map((d) => d.currentRole?.trim() ?? '')
        .where((r) => r.isNotEmpty)
        .toSet()
        .toList();

    availableRoles.assignAll(extracted);

    // default role
    currentRole.value = availableRoles.isNotEmpty ? availableRoles.first : '';

    // 👉 Only call API if role exists
    if (currentRole.value.isNotEmpty) {
      await changeRole(currentRole.value, dashboardToUse: dashboard);
    }
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
    print('dashdash$dash');
    // 👉 If null, return empty list
    if (dash == null) return [];

    return dash.dashboardData ?? [];
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

  Future<void> fetchWidgetDataFromEndpoint(DashboardDataItem item) async {
    try {
      final widgetName = item.filterProps?.widgetName ?? '';
      final roleId = item.filterProps?.roleId ?? '';

      if (widgetName.isEmpty || roleId.isEmpty) {
        debugPrint("WidgetName or RoleId missing");
        return;
      }

      String sortBy = "y";
      String extraParams = "";

      /// ✅ Dynamic Date Range → 1st of this month → today (inclusive)
      final now = DateTime.now();

      final DateTime startDate = DateTime(now.year, now.month, 1);

      // +1 day so today is fully included
      final DateTime endDate = DateTime(now.year, now.month, now.day + 1);

      final int startMillis = startDate.millisecondsSinceEpoch;
      final int endMillis = endDate.millisecondsSinceEpoch;
      int today = DateTime.now().millisecondsSinceEpoch;

      /// 🔹 Widget-specific logic
      /// 🔹 Widget-specific logic
      switch (widgetName) {
        case "ExpensesThisMonth":
          sortBy = "Value";
          extraParams = "&start_date=$startMillis&end_date=$endMillis";

        /// SUMMARY BOXES
        case "TotalCashAdvances":
        case "TotalExpenses":
        case "NoOfMyPendingApprovalsCard":
        case "TotalLeaveMonth":
        case "totleavemonth":
        case "NoOfEscalations":
        case "NoOfAutoRejectedApprovals":
        case "NoOfAutoApprovedExpenses":
        case "NoOfApprovalDelegations":
        case "AverageExpenseByEmployees":
          sortBy = "Value";
          break;

        /// LINE CHARTS
        case "CashAdvanceTrends":
        case "ExpenseTrends":
        case "CashAdvanceReturnTrends":
        case "EmployeesLeaveConnectedWithWeekends":
        case "empleaveconectwithweekends":
        case "PolicyComplianceRateForCashAdvances":
        case "Top5Spenders":
        case "ExpensesByEmployeeGrades":
        case "MileageByTop5Employees":
        case "Top5SpendingDepartments":
        case "ExpensesByDepartment":
          sortBy = "y";
          break;

        /// MULTI BAR CHARTS
        case "ExpensesByCategories":
        case "ExpenseBySource":
          sortBy = "YAxis";
          break;

        /// BAR CHARTS
        case "ExpensesByProjects":
        case "NoOfCashAdvancesByApprovalStatus":
        case "CashAdvancesByBusinessJustification":
        case "Top5CashAdvanceRequesters":
        case "NoOfExpensesByStatus":
        case "Top10ExpenseCategoriesByLocations":
        case "top5leavecodevsleaves":
        case "leavetypevsleaves":
        case "top10empleavecancellation":
          sortBy = "y";
          break;

        /// PIE CHARTS
        case "ExpenseAmountByExpenseStatus":
        case "ExpensesAmountByApprovalStatus":
        case "SumOfCashAdvancesByApprovalStatus":
        case "RepeatedPolicyViolationsByEmployeesForCashAdvances":
        case "top10empleavecancelcount":
          sortBy = "YAxis";
          break;

        /// DONUT
        case "ExpensesByPaymentMethods":
          sortBy = "YAxis";
          break;

        /// TABLE WIDGETS
        case "ExpensesByCountries":
        case "LeaveBalanceOverview":
        case "PendingApprovals":
          sortBy = "YAxis";
          break;
        case "leavehistory":
          sortBy = "YAxis";
          extraParams = "end_date=$today&periods=5";
        default:
          sortBy = "YAxis";
      }

      /// 🔹 Draft APIs handled separately
      if (widgetName == "DraftExpenses") {
        await _fetchDraftExpenses();
        return;
      }

      if (widgetName == "draftleaves") {
        await _fetchDraftLeave();
        return;
      }

      if (widgetName == "mypendingleaves") {
        await pendingApprovalLeaveRequisitions();
        return;
      }

      if (widgetName == "MyPendingApprovals") {
        await fetchPendingApprovals();
        return;
      }

      if (widgetName == "leavecalanderview") {
        final fromDate = DateTime(
          now.year,
          now.month,
          1,
        ).millisecondsSinceEpoch;

        final toDate = DateTime(
          now.year,
          now.month + 1,
          0,
          23,
          59,
          59,
        ).millisecondsSinceEpoch;

        await loadCalendarLeaves(fromDate: fromDate, toDate: toDate);
        return;
      }

      /// 🔹 Filters
      final filterQuery = _buildFilterQuery(
        item.filterProps?.advanceFilterations,
      );

      final Uri url = Uri.parse(
        "${Urls.baseURL}/api/v1/dashboard/widgets/$widgetName"
        "?role=$roleId"
        "&page=1"
        "&limit=10"
        "&sort_by=$sortBy"
        "&sort_order=asc"
        "$filterQuery"
        "$extraParams",
      );

      debugPrint("API CALL → $url");

      final response = await ApiService.get(url);

      /// 🔴 Handle 500 or other errors safely
      if (response.statusCode >= 500) {
        debugPrint("SERVER ERROR (${response.statusCode}) → $widgetName");

        final cacheKey = item.id ?? widgetName;

        update();
        return;
      }

      if (response.statusCode != 200) {
        debugPrint("API Failed (${response.statusCode}) for ${item.id}");
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded == null) {
        debugPrint("Empty response for ${item.id}");
        return;
      }

      final widgetResponse = WidgetDataResponse.fromJson(decoded);

      /// Use unique cache key
      final cacheKey = item.id ?? widgetName;

      widgetDataCache[cacheKey] = widgetResponse;

      update(); // Refresh GetX UI
    } catch (e, stack) {
      debugPrint("Error fetching widget ${item.id}: $e");
      debugPrint(stack.toString());
    }
  }

  String _buildFilterQuery(List<AdvanceFilteration>? groups) {
    if (groups == null || groups.isEmpty) return "";

    List<String> filters = [];

    for (var group in groups) {
      for (var rule in group.rules) {
        if (rule.selectedTable.isEmpty ||
            rule.selectedField.isEmpty ||
            rule.selectedCondition.isEmpty ||
            rule.singleValue == null ||
            rule.singleValue.toString().isEmpty) {
          continue;
        }

        String operator;

        switch (rule.selectedCondition) {
          case "equal":
            operator = "__eq";
            break;
          case "not_equal":
            operator = "__not_eq";
            break;
          case "greater_than":
            operator = "__gt";
            break;
          case "less_than":
            operator = "__lt";
            break;
          default:
            operator = "__eq";
        }

        filters.add(
          "&filter_query=${rule.selectedTable}.${rule.selectedField}$operator=${rule.singleValue}",
        );
      }
    }

    if (filters.isEmpty) return "";

    /// 🔥 JOIN USING &
    return filters.join("&");
  }

  String getWidgetType(String widgetName) {
    // print(widgetName);
    const lineCharts = [
      'CashAdvanceTrends',
      'ExpenseTrends',
      'CashAdvanceReturnTrends',
      'leavehistory',
      'EmployeesLeaveConnectedWithWeekends',
      "empleaveconectwithweekends",
      "PolicyComplianceRateForCashAdvances",

      "Top5Spenders",
      "ExpensesByEmployeeGrades",
      "MileageByTop5Employees",
      "Top5SpendingDepartments",
      "ExpensesByDepartment",
    ];
    const multibarCharts = ['ExpensesByCategories', "ExpenseBySource"];
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
      'top10empleavecancellation',
      "top10empleavecancelcount",
    ];

    const pieCharts = [
      'ExpenseAmountByExpenseStatus',
      'SumOfCashAdvancesByApprovalStatus',
      'ExpensesAmountByApprovalStatus',
    ];

    const donutCharts = ['ExpensesByPaymentMethods'];
    const leavecalanderview = ['leavecalanderview'];
    const myPendingApprovals = ['MyPendingApprovals'];
    const mypendingleaves = ['mypendingleaves'];
    const draftleaves = ['draftleaves'];
    const draftExpenses = ['DraftExpenses'];
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
    if (multibarCharts.contains(widgetName)) return 'MultiBarChart';
    if (pieCharts.contains(widgetName)) return 'PieChart';
    if (donutCharts.contains(widgetName)) return 'DonutChart';
    if (summaryBoxes.contains(widgetName)) return 'SummaryBox';
    if (tableWidgets.contains(widgetName)) return 'Table';
    if (tableWidgetsExpense.contains(widgetName)) return 'ExpenseTable';
    if (leavecalanderview.contains(widgetName)) return 'Leavecalanderview';
    if (myPendingApprovals.contains(widgetName))
      return 'MyPendingApprovalsPage';
    if (mypendingleaves.contains(widgetName)) return 'mypendingleaves';
    if (draftleaves.contains(widgetName)) return 'Draftleaves';
    if (draftExpenses.contains(widgetName)) return 'DraftExpenses';
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
        //  //  // print("decodedCall");
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
  //          //  //  // print("Fetched Expenses: $getAllListGExpense");

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

  Future<List<GExpense>> _fetchDraftLeave() async {
    isLoadingGE1.value = true;
    final email = Params.userId ?? "";

    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/leaverequisitions?filter_query=LVRLeaveHeader.CreatedBy__eq%3D$email"
      "%26LVRLeaveHeader.ApprovalStatus__eq%3DCreated&page=1&sort_order=as",
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
        return [];
      } else {
        //  //  // print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      //  //  // print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

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

        final list = (data as List)
            .map((item) => GExpense.fromJson(item))
            .toList();

        getAllListGExpense.value = list;

        isLoadingGE1.value = false;
        return list; // ✅ return actual data
      } else {
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
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

      /// 🔹 Draft handled separately
      if (widgetName == "DraftExpenses") {
        await _fetchDraftExpenses();
        return;
      }
      if (widgetName == "draftleaves") {
        await _fetchDraftLeave();
        return;
      }
      if (widgetName == "mypendingleaves") {
        await pendingApprovalLeaveRequisitions();
        return;
      }

      if (widgetName == "MyPendingApprovals") {
        await fetchPendingApprovals();
        return;
      }
      if (widgetName.toLowerCase() == "leavecalanderview") {
        final now = DateTime.now();

        final fromDate = DateTime(
          now.year,
          now.month,
          1,
        ).millisecondsSinceEpoch;

        final toDate = DateTime(
          now.year,
          now.month + 1,
          0,
          23,
          59,
          59,
        ).millisecondsSinceEpoch;

        await loadCalendarLeaves(fromDate: fromDate, toDate: toDate);

        return;
      }
      String sortBy = "y";
      String extraParams = "";

      /// ✅ Dynamic Date Range → 1st of this month → today (inclusive)
      final now = DateTime.now();

      final DateTime startDate = DateTime(now.year, now.month, 1);

      // +1 day so today is fully included
      final DateTime endDate = DateTime(now.year, now.month, now.day + 1);

      final int startMillis = startDate.millisecondsSinceEpoch;
      final int endMillis = endDate.millisecondsSinceEpoch;

      /// ✅ Widget-based logic
      if (widgetName == "ExpensesThisMonth" ||
          widgetName == "TotalCashAdvances") {
        sortBy = "Value";
        extraParams = "&start_date=$startMillis&end_date=$endMillis";
      } else if (widgetName == "ExpensesByProjects" ||
          widgetName == "ExpensesByCountries" ||
          widgetName == "top10empleavecancellation") {
        sortBy = "y";
      } else if (widgetName == "TotalExpenses" ||
          widgetName == "NoOfMyPendingApprovalsCard" ||
          widgetName == "NoOfEscalations" ||
          widgetName == "AverageExpenseByEmployees" ||
          widgetName == "NoOfApprovalDelegations" ||
          widgetName == "NoOfAutoApprovedExpenses" ||
          widgetName == "NoOfAutoRejectedApprovals") {
        sortBy = "Value";
      } else {
        sortBy = "YAxis";
      }

      /// ✅ API URL
      final url = Uri.parse(
        "${Urls.baseURL}/api/v1/dashboard/widgets/$widgetName"
        "?role=$role"
        "$extraParams"
        "&page=1"
        "&limit=10"
        "&sort_by=$sortBy"
        "&sort_order=asc",
      );

      final response = await ApiService.get(url);

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);

      widgetDataCache[widgetName] = WidgetDataResponse.fromJson(decoded);

      update(); // if using GetX
    } catch (e, s) {
      // debugPrint("Error fetching widget: $e\n$s");
    }
  }

  void _showDateError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
  RxMap<DateTime, List<LeaveDetailsModel>> events =
      <DateTime, List<LeaveDetailsModel>>{}.obs;
  // Currently selected day and events
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  List<LeaveDetailsModel> get selectedEvents =>
      events[_dayKey(selectedDay)] ?? [];

  final isCalendarLoading = false.obs;
  List<LeaveDetailsModel> _allLeaves = []; // full dataset
  final filteredLeavesQuery = <LeaveDetailsModel>[].obs; // observable for UI
  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);
  Future<void> loadCalendarLeaves({
    required int fromDate,
    required int toDate,
  }) async {
    try {
      isCalendarLoading.value = true;

      final url = Uri.parse(
        "${Urls.baseURL}/api/v1/leaverequisition/leavemanagement/fetchcalendarleaves",
      );

      final payload = {
        "scope": scopeFilters,
        "scope_filters": selectedEmployeesFilter.isEmpty
            ? null
            : selectedEmployeesFilter.map((e) => e.employeeName).toList(),
        "from_date": fromDate,
        "to_date": toDate,
      };
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        events.clear();
        final List raw = jsonDecode(response.body);
        _allLeaves = raw.map((e) => LeaveDetailsModel.fromJson(e)).toList();
        _filterLeaves();
      }
    } catch (e) {
      debugPrint('Calendar API error: $e');
    } finally {
      isCalendarLoading.value = false;
    }
  }

  final filterFormKey = GlobalKey<FormState>();
  void _filterLeaves() {
    var result = _allLeaves;
    print("resultresult1$result"); // should print full list

    // 1. Filter by status – only if not null and not "All"
    if (selectedAvailability.value != null &&
        selectedAvailability.value != 'All') {
      print("resultresult11");
      result = result
          .where((leave) => leave.approvalStatus == selectedAvailability.value)
          .toList();
    }

    // 2. Filter by leave codes
    if (selectedleaveCodesFilter.isNotEmpty) {
      print("resultresult22");
      final selectedCodes = selectedleaveCodesFilter
          .map((e) => e.leaveCode)
          .toSet();
      result = result
          .where((leave) => selectedCodes.contains(leave.leaveCode))
          .toList();
    }

    // 3. Filter by employees – use selectedEmployeesFilter, not selectedNotifyingUsers
    if (selectedEmployeesFilter.isNotEmpty) {
      print("resultresult44");
      final selectedEmployeeIds = selectedEmployeesFilter
          .map((e) => e.employeeId) // adjust to your model's employeeId field
          .toSet();
      result = result
          .where((leave) => selectedEmployeeIds.contains(leave.employeeId))
          .toList();
    }

    print("resultresult$result"); // now should show filtered list

    filteredLeavesQuery.assignAll(result);
    buildEventMap(filteredLeavesQuery);
  }

  Map<String, int> getMonthRangeEpoch(DateTime focusedDay) {
    // First day of month (UTC)
    final firstDayUtc = DateTime.utc(focusedDay.year, focusedDay.month, 1);

    // Last day of month (UTC end of day)
    final lastDayUtc = DateTime.utc(
      focusedDay.year,
      focusedDay.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    return {
      'from': firstDayUtc.millisecondsSinceEpoch,
      'to': lastDayUtc.millisecondsSinceEpoch,
    };
  }

  Future<void> loadFromApi(String url) async {
    // implement your API GET and parse JSON then call _buildEventMap
    // after parsing set leaves and call _buildEventMap(); then notifyListeners();
  }
  void buildEventMap(List<LeaveDetailsModel> leaves) {
    // events.clear();

    for (final leave in leaves) {
      final start = DateTime.fromMillisecondsSinceEpoch(
        leave.fromDate,
        isUtc: true,
      );
      final end = DateTime.fromMillisecondsSinceEpoch(
        leave.toDate,
        isUtc: true,
      );

      DateTime day = start;

      while (day.isBefore(end) || isSameDay(day, end)) {
        final key = DateTime(day.year, day.month, day.day);

        events.putIfAbsent(key, () => []);

        final dayLeave = leave.copyWith(); // cleaner way

        events[key]!.add(dayLeave);

        day = day.add(const Duration(days: 1));
      }
    }

    events.refresh(); // 🔥 important for GetX UI update

    print("Calendar Events Updated: ${events.length}");
  }

  String? calendarId;
  double? leaveBalance;
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
      "LeaveCode": (leaveCode.trim().isEmpty) ? null : leaveCode,
    };
    final response = await ApiService.post(url, body: jsonEncode(payload));

    if (response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      leaveBalance = decoded["LeaveBalance"] ?? "";
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

  Future<void> fetchCalenderIDLeaveTransactions({
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
      "LeaveCode": (leaveCode.trim().isEmpty) ? null : leaveCode,
    };
    final response = await ApiService.post(url, body: jsonEncode(payload));

    if (response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      calendarId = decoded["CalendarId"] ?? "";
    } else {}
  }

  Future<bool> submitLeaveRequestFinal(
    context,
    LeaveRequest request, {
    bool submit = false,
    bool resubmit = false,
  }) async {
    // setFullPageLoading(true);

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
      final message = responseData['detail']['message'];

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
      // setFullPageLoading(false);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail']['message'] ?? 'Error';
      Fluttertoast.showToast(
        msg: message,
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

      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      //  // debugPrint("✅ Leave request submitted successfully");
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['detail']['message'] ?? '';
      // final recId = responseData['detail']['RecId'];
      resetForm();
      Navigator.pushNamed(context, AppRoutes.leavePendingApprovals);
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

  Future<LeaveDetailsModel?> fetchSpecificLeaveDetailsMyTeams(
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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final message = responseData['detail']['message'];
        selectedRunIds.clear();
        fetchTimeRuns();
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
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
            'status': true,
          },
        );

        return leaveDetails;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final message = responseData['detail']['message'];
        selectedRunIds.clear();
        fetchTimeRuns();
        Fluttertoast.showToast(
          msg: "$message ",
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
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
    isLoadingLeaves.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/leavemanagement/leavecancellation/leavecancellationdetails'
      '?recid=$recId&lock_id=$recId&screen_name=LVRLeaveCancellationHeader',
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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return null;
      }
    } catch (e) {
      isLoadingLeaves.value = false;
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
    isLoadingLeaves.value = true;

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
            'status': true,
          },
        );
        isLoadingLeaves.value = false;

        return leaveDetails;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['detail']?['message'] ?? 'No message found';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );

        return null;
      }
    } catch (e) {
      // debugPrint('Error fetching leave details: $e');
      return null;
    } finally {
      isLoadingGE2.value = false;
      isLoadingLeaves.value = false;
    }
  }

  /// ---------------- SELECTION STATE ----------------
  RxList<String> selectedPayslipIds = <String>[].obs;

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
    // print("Call Here ");
    if (payslips.isEmpty) return;
    await downLoadPayslips();
    // await downloadPayrollPdf(payslips);
    // clearSelection();
  }

  /// ---------------- EMAIL ----------------
  Future<void> emailPayslips() async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/payrollregistration/payroll/payslipemail',
    );

    final payload = {"RecIds": selectedPayslipIds};
    // print("Payload$payload");
    try {
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        // final Map<String, dynamic> responseData = jsonDecode(response.body);

        // final message = responseData['detail'] ?? 'Expense created';
        Fluttertoast.showToast(
          msg: "Mail Sended  Successfully ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        selectedPayslipIds.clear();
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  // Controller.dart

  RxString payslipSearchQuery = ''.obs;

  List<PayrollsTeams> get filteredPayrollList {
    if (payslipSearchQuery.value.isEmpty) {
      return payrollList;
    }

    final query = payslipSearchQuery.value.toLowerCase();

    return payrollList.where((item) {
      return item.employeeName.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.type.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> downLoadPayslips() async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/payrollregistration/payroll/payslip',
    );

    final payload = {"RecIds": selectedPayslipIds};

    try {
      final response = await ApiService.post(url, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        // ✅ PDF bytes
        final bytes = response.bodyBytes;

        // ✅ Save file
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/Payslip_${DateTime.now().millisecondsSinceEpoch}.pdf';

        final file = File(filePath);
        await file.writeAsBytes(bytes);

        Fluttertoast.showToast(
          msg: "Payslip downloaded successfully",
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );

        // ✅ Open PDF
        await OpenFilex.open(filePath);

        selectedPayslipIds.clear();
      } else {
        Fluttertoast.showToast(
          msg: "Download failed",
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

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

  /// ---------------- Time Trackers ----------------

  TextEditingController noteCtrl = TextEditingController();

  BoardModel? selectedBoards;
  TaskModelDropDown? selectedTask;

  // Timer State
  Rx<TimerStatus> timerStatus = TimerStatus.idle.obs;
  RxInt durationSeconds = 0.obs;
  String? timeRunId;
  Timer? _ticker;

  // Active Timer Details
  Rx<Map<String, dynamic>?> activeTimerDetails = Rx<Map<String, dynamic>?>(
    null,
  );
  RxBool hasActiveTimer = false.obs;
  RxBool isCheckingActiveTimer = false.obs;

  // Tabs
  Rx<TrackerTab> selectedTab = TrackerTab.runs.obs;
  RxBool isTabLoading = false.obs;

  RxList<dynamic> timeRuns = <dynamic>[].obs;
  RxList<dynamic> segments = <dynamic>[].obs;
  RxList<dynamic> eventss = <dynamic>[].obs;

  // Submission State
  RxBool isSubmitting = false.obs;

  // Timer Ticker
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      durationSeconds.value++;
    });
  }

  void stopTicker() {
    _ticker?.cancel();
  }

  /// Check for active timer when app starts
  Future<void> checkActiveTimer() async {
    clearFields();
    isCheckingActiveTimer.value = true;
    try {
      final res = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/timetrackerdetails',
        ),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);

        if (data['TimeRunId'] != null && data['Status'] != null) {
          activeTimerDetails.value = data;
          timeRunId = data['TimeRunId'] ?? '';
          durationSeconds.value = data['Duration'] ?? 0;
          hasActiveTimer.value = true;
          boardNameController.text = data['BoardId'] ?? '';
          noteCtrl.text = data['Notes'] ?? '';
          taskIdController.text = data["TaskId"] ?? '';
          projectDropDowncontroller.text = data["ProjectId"] ?? '';
          // Set timer status
          if (data['Status'] == 'Running') {
            timerStatus.value = TimerStatus.running;
            _startTicker();
          } else if (data['Status'] == 'Paused') {
            timerStatus.value = TimerStatus.paused;
          }

          // Populate form fields
          _populateFormFields(data);
        } else {
          hasActiveTimer.value = false;
          activeTimerDetails.value = null;
          timerStatus.value = TimerStatus.idle;
        }
      }
    } catch (e) {
      // print('Error checking active timer: $e');
      hasActiveTimer.value = false;
    } finally {
      isCheckingActiveTimer.value = false;
    }
  }

  /// Populate form fields from active timer
  void _populateFormFields(Map<String, dynamic> data) {
    // Set notes
    noteCtrl.text = data['Notes'] ?? '';

    // Set project if available in project list
    if (data['ProjectId'] != null) {
      final projectItem = project.firstWhereOrNull(
        (p) => p.code == data['ProjectId'],
      );
      if (projectItem != null) {
        selectedProject = projectItem;
        projectDropDowncontroller.text = projectItem.code;
      }
    }

    // Set board if available in board list
    if (data['BoardId'] != null) {
      final boardItem = boardList.firstWhereOrNull(
        (b) => b.boardId == data['BoardId'],
      );
      if (boardItem != null) {
        selectedBoards = boardItem;
        boardNameController.text = boardItem.boardId;
      }
    }

    // Set task if available in task list
    if (data['TaskId'] != null) {
      final taskItem = taskList.firstWhereOrNull(
        (t) => t.taskId == data['TaskId'],
      );
      if (taskItem != null) {
        selectedTask = taskItem;
        taskNameController.text = taskItem.taskId;
      }
    }
  }

  void clearFields() {
    selectedProject = null;
    selectedBoards = null;
    selectedTask = null;

    projectError.value = "";
    boardError.value = "";
    taskError.value = "";
  }

  RxString projectError = ''.obs;
  RxString boardError = ''.obs;
  RxString taskError = ''.obs;
  bool validateFields() {
    bool isValid = true;
    final config = getFieldConfigSheet("Project Id");
    // print("projectConfig${config.isMandatory}");
    // print("selectedBoards$selectedBoards");
    if (config.isMandatory && selectedProject == null) {
      projectError.value = "Project is required";
      isValid = false;
    } else {
      projectError.value = "";
    }

    if (selectedBoards == null) {
      boardError.value = "Board is required";
      isValid = false;
    } else {
      boardError.value = "";
    }

    if (selectedTask == null) {
      taskError.value = "Task is required";
      isValid = false;
    } else {
      taskError.value = "";
    }
    // print("Final isValid: $isValid");
    return isValid;
  }

  /// Timer Methods
  ///
  final isActionLoading = false.obs;
  Future<void> startTimerTimeSheet() async {
    if (isActionLoading.value) return;
    isActionLoading.value = true;
    try {
      final res = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/start',
        ),
        body: jsonEncode({
          "ProjectId": selectedProject?.code,
          "BoardId": selectedBoards!.boardId,
          "TaskId": selectedTask!.taskId,
          "TaskName": selectedTask!.taskName,
          "Notes": noteCtrl.text,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        timeRunId = data['TimeRunId'];
        timerStatus.value = TimerStatus.running;
        durationSeconds.value = 0;
        hasActiveTimer.value = true;
        activeTimerDetails.value = {
          'TimeRunId': timeRunId,
          'Status': 'Running',
          'TaskId': selectedTask!.taskId,
          'TaskName': selectedTask!.taskName,
          'ProjectId': selectedProject?.code,
          'BoardId': selectedBoards!.boardId,
          'Notes': noteCtrl.text,
        };
        _startTicker();
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message =
            responseData['message'] ?? 'Timer started successfully .';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        await fetchTimeRuns();
      } else {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message =
            responseData['detail']?['message'] ?? 'Something Wrong ';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // print("Failed to start timer:$e");
      Get.snackbar('Error', 'Failed to start timer');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> pauseTimer() async {
    if (timeRunId == null) return;
    if (isActionLoading.value) return;
    isActionLoading.value = true;
    try {
      final res = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/pause',
        ),
        body: jsonEncode({"TimeRunId": timeRunId}),
      );

      if (res.statusCode == 200) {
        timerStatus.value = TimerStatus.paused;
        if (activeTimerDetails.value != null) {
          activeTimerDetails.value!['Status'] = 'Paused';
          activeTimerDetails.refresh();
        }
        stopTicker();
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message = responseData['message'] ?? '';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        // Get.snackbar('Success', 'Timer paused');
      } else {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message =
            responseData['detail']?['message'] ?? 'omething Wrong';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> resumeTimer() async {
    if (timeRunId == null) return;
    if (isActionLoading.value) return;
    isActionLoading.value = true;
    try {
      final res = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/resume',
        ),
        body: jsonEncode({
          "TimeRunId": timeRunId,
          "ProjectId":
              selectedProject?.code ?? activeTimerDetails.value?['ProjectId'],
          "BoardId":
              selectedBoards?.boardId ?? activeTimerDetails.value?['BoardId'],
          "TaskId": selectedTask?.taskId ?? activeTimerDetails.value?['TaskId'],
          "TaskName":
              selectedTask?.taskName ?? activeTimerDetails.value?['TaskName'],
          "Notes": noteCtrl.text,
        }),
      );

      if (res.statusCode == 200) {
        timerStatus.value = TimerStatus.running;
        if (activeTimerDetails.value != null) {
          activeTimerDetails.value!['Status'] = 'Running';
          activeTimerDetails.refresh();
        }
        _startTicker();
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message = responseData['message'] ?? '';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message =
            responseData['detail']?['message'] ?? 'something Wrong';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> completeTimer() async {
    if (timeRunId == null) return;
    if (isActionLoading.value) return;
    isActionLoading.value = true;
    try {
      final res = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/stop',
        ),
        body: jsonEncode({"TimeRunId": timeRunId}),
      );

      if (res.statusCode == 200) {
        timerStatus.value = TimerStatus.completed;
        hasActiveTimer.value = false;
        activeTimerDetails.value = null;
        timeRunId = null;
        stopTicker();
        clearTimeSheetForm();

        await fetchTimeRuns();
        await checkActiveTimer();
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message = responseData['message'] ?? '';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message =
            responseData['detail']?['message'] ?? 'something Wrong';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> cancelTimer() async {
    if (timeRunId == null) return;
    if (isActionLoading.value) return;
    isActionLoading.value = true;
    try {
      final res = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/cancel',
        ),
        body: jsonEncode({"TimeRunId": timeRunId}),
      );

      if (res.statusCode == 200) {
        timerStatus.value = TimerStatus.cancelled;
        hasActiveTimer.value = false;
        activeTimerDetails.value = null;
        timeRunId = null;
        stopTicker();
        clearTimeSheetForm();
        await fetchTimeRuns();
        await checkActiveTimer();
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message = responseData['message'] ?? '';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        await fetchTimeRuns();
      } else {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String message =
            responseData['detail']?['message'] ?? 'something Wrong';

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel timer');
    } finally {
      isActionLoading.value = false;
    }
  }

  /// ---------------- LIST APIS ----------------

  Future<void> fetchTimeRuns() async {
    isTabLoading.value = true;
    final res = await ApiService.get(
      Uri.parse(
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/runs?page=1&sort_order=asc',
      ),
    );

    final body = decodeJson(res.body);

    if (body is List) {
      timeRuns.value = body;
      isTabLoading.value = false;
    } else if (body is Map && body['data'] is List) {
      timeRuns.value = body['data'];
      isTabLoading.value = false;
    } else {
      timeRuns.clear();
      isTabLoading.value = false;
    }
  }

  dynamic decodeJson(String body) {
    return jsonDecode(body);
  }

  String formatUtcMillis(dynamic value) {
    if (value == null) return '--';

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();

      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return '--';
    }
  }

  Future<void> fetchSegments() async {
    isTabLoading.value = true;
    final res = await ApiService.get(
      Uri.parse(
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/segments?page=1&sort_order=asc',
      ),
    );

    final body = decodeJson(res.body);

    if (body is List) {
      segments.value = body;
      isTabLoading.value = false;
    } else if (body is Map && body['data'] is List) {
      segments.value = body['data'];
      isTabLoading.value = false;
    } else {
      segments.clear();
      isTabLoading.value = false;
    }
  }

  Future<void> fetchEvents() async {
    isTabLoading.value = true;
    final res = await ApiService.get(
      Uri.parse(
        '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/timerun/events?page=1&sort_order=asc',
      ),
    );

    final body = decodeJson(res.body);

    if (body is List) {
      eventss.assignAll(body);
      isTabLoading.value = false;
    } else if (body is Map && body['data'] is List) {
      events.assignAll(body['data']);
      isTabLoading.value = false;
    } else {
      events.clear();
      isTabLoading.value = false;
    }
  }

  /// ---------------- TAB SWITCH ----------------
  RxSet<String> selectedRunIds = <String>{}.obs;

  bool isSelectedTimeRun(String id) => selectedRunIds.contains(id);
  void toggleSelectionTimeRUN(String id) {
    if (selectedRunIds.contains(id)) {
      selectedRunIds.remove(id);
    } else {
      selectedRunIds.add(id);
    }
  }

  Future<void> generateTimeSheet({required bool submit}) async {
    if (selectedRunIds.isEmpty) {
      Get.snackbar("Warning", "Please select at least one Time Run");
      return;
    }

    isSubmitting.value = true;

    final payload = {"TimeRunIds": selectedRunIds.toList()};

    try {
      final res = await ApiService.post(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/'
          'timesheetrequisition/createtimesheettimetracker'
          '?Submit=$submit',
        ),
        body: jsonEncode(payload),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final message = responseData['detail']['message'];
        selectedRunIds.clear();
        fetchTimeRuns();
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
          msg: "Timesheet Submit Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Timesheet Submit Error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void changeTabTimeSheet(TrackerTab tab) async {
    if (selectedTab.value == tab) return;

    isTabLoading.value = true;
    selectedTab.value = tab;

    /// OPTIONAL: fetch per-tab data
    switch (tab) {
      case TrackerTab.runs:
        await fetchTimeRuns();
        break;
      case TrackerTab.segments:
        await fetchSegments();
        break;
      case TrackerTab.events:
        await fetchEvents();
        break;
    }

    isTabLoading.value = false;
  }

  Map<String, dynamic> _prepareRequestBody() {
    final employeeId = Params.employeeId;

    List<Map<String, dynamic>> timesheetLines = [];

    for (int i = 0; i < lineItems.length; i++) {
      final line = lineItems[i];

      final timeEntriess = Map.from(timeEntries[i] ?? {});

      List<Map<String, dynamic>> dailyEntries = [];

      timeEntriess.forEach((entryDate, entry) {
        dailyEntries.add({
          "EntryDate": entryDate,
          "TimeFrom": entry.timeFrom,
          "TimeTo": entry.timeTo,
          "TotalHours": double.tryParse(entry.totalHours) ?? 0.0,
          "OTHours": null,
          "TimerRunning": false,
        });
      });

      timesheetLines.add({
        "LinesCustomfields": List<Map<String, dynamic>>.from(
          lineCustomFields[i] ?? [],
        ),
        "ProjectId": (line.project?.code?.isEmpty ?? true)
            ? null
            : line.project!.code,
        "BoardId": line.board?.boardId,
        "TaskId": line.task?.taskId,
        "InternalComment": "",
        "ExternalComment": "",
        "IsConverted": false,
        "RecId": line.recId,
        "DailyEntry": dailyEntries,
        "TaskName": line.task?.taskName ?? "",
      });
    }

    // ✅ RETURN AFTER LOOP
    return {
      "TimesheetId": timeSheetID.text.trim().isEmpty
          ? null
          : timeSheetID.text.trim(),
      "EmployeeId": employeeId,
      "ApplicationDate": DateTime.now().millisecondsSinceEpoch,
      "Source": "Web",
      "CaptureMethod": "Manual",
      "FromDate": dateRange!.start.millisecondsSinceEpoch,
      "ToDate": dateRange!.end.millisecondsSinceEpoch,
      "EmployeeName": Params.employeeName ?? userName.value,
      "TimesheetLocation": null,
      "ReferenceId": null,
      "Frequency": getFrequency(periodType),
      "ProjectId": projectDropDowncontroller.text.isEmpty
          ? null
          : projectDropDowncontroller.text,
      "TimesheetCustomFieldValues": List<Map<String, dynamic>>.from(
        headerCustomFields,
      ),
      "Timesheetlines": timesheetLines,
      "DocumentAttachment": {"File": []},
      "workitemrecid": workitemrecid,
      "RecId": (recId == null || recId == 0) ? null : recId,
      "CalendarId": null,
    };
  }

  Future<void> submitTimeSheet(BuildContext context, bool isResubmit) async {
    try {
      // Validate form
      // if (!_validateForm()) {
      //   Fluttertoast.showToast(
      //     msg: "Required fields are missing. Please fill all mandatory fields.",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     backgroundColor: const Color.fromARGB(255, 250, 1, 1),
      //     textColor: const Color.fromARGB(255, 253, 252, 253),
      //     fontSize: 16.0,
      //   );
      //   return;
      // }

      // Prepare request body
      final requestBody = _prepareRequestBody();
      // print("requestBody$requestBody");
      // Call API
      final response = await ApiService.put(
        Uri.parse(
          '${Urls.baseURL}/api/v1/timesheetrequisition/timesheetrequisition/reviewtimesheetrequisition?updateandaccept=$isResubmit&screen_name=PendingApproval',
        ),
        body: jsonEncode(requestBody),
      );

      // Handle response
      if (response.statusCode == 202 ||
          response.statusCode == 201 ||
          response.statusCode == 280) {
        clearTimeSheetForm();

        periodType = 'Weekly';
        dateRange = null;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final message = responseData['detail']['message'];
        Navigator.pushNamed(context, AppRoutes.timeSheetPendingDashboard);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final message = responseData['detail']['message'];
        // Navigator.pushNamed(context, AppRoutes.timeSheetDashboard);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // print("2222dd$e");
      // Close loading dialog if still open
    }
  }

  String getPeriodTypeForUI(String frequency) {
    switch (frequency) {
      case 'Week':
        return 'Weekly';
      case 'BiWeek':
        return 'BiWeekly';
      case 'Month':
        return 'Monthly';
      case 'Semimonthly':
        return 'Semimonthly';
      case 'Day':
        return 'Day';
      default:
        return 'Weekly';
    }
  }

  String getFrequency(String periodType) {
    // print("periodType$periodType");
    switch (periodType) {
      case 'Weekly':
        return 'Week';
      case 'BiWeekly':
        return 'BiWeek';
      case 'Monthly':
        return 'Month';
      case 'Semimonthly':
        return 'Semimonthly'; // 👈 FULL NAME
      case 'Day':
      default:
        return 'Day';
    }
  }

  final RxList<FieldConfiguration> customFieldConfigs =
      <FieldConfiguration>[].obs;
  final RxBool isLoadingCustomFields = false.obs;
  Future<void> fetchCustomFieldConfigurations() async {
    try {
      isLoadingCustomFields.value = true;

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/masters/fieldmanagement/customfields/timesheetcconfigfields?'
          'filter_query=STPFieldConfigurations.FunctionalEntity__eq%3DTimesheetRequisition&'
          'page=1&sort_order=asc&choosen_fields=FieldId%2CFieldName%2CIsEnabled%2CIsMandatory%2CFunctionalArea%2CRecId',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dynamic rawData = decoded['data'];

        /// 🔥 Normalize to List<Map<String, dynamic>>
        List<Map<String, dynamic>> fields = [];

        if (rawData is List) {
          fields = rawData.cast<Map<String, dynamic>>();
        } else if (rawData is Map<String, dynamic>) {
          fields = [rawData];
        }
      }
    } catch (e) {
      debugPrint('Error fetching custom fields: $e');
    } finally {
      isLoadingCustomFields.value = false;
    }
  }

  // Helper methods to check field status
  bool isFieldEnabled(String fieldId) {
    final config = customFieldConfigs.firstWhereOrNull(
      (field) => field.fieldId == fieldId,
    );
    return config?.isEnabled ?? false;
  }

  bool isFieldMandatory(String fieldId) {
    final config = customFieldConfigs.firstWhereOrNull(
      (field) => field.fieldId == fieldId,
    );
    return config?.isMandatory ?? false;
  }

  FieldConfig getFieldConfigSheet(String fieldName) {
    final field = configListSheet.firstWhere(
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

  String? getFieldName(String fieldId) {
    final config = customFieldConfigs.firstWhereOrNull(
      (field) => field.fieldId == fieldId,
    );
    return config?.fieldName;
  }

  Widget buildConfigurableField({
    required String fieldName,
    required Widget Function(bool isEnabled, bool isMandatory) builder,
  }) {
    return Obx(() {
      final config = getFieldConfigSheet(fieldName);
      if (!config.isEnabled) {
        return const SizedBox.shrink();
      }

      return builder(config.isEnabled, config.isMandatory);
    });
  }

  RxList<Map<String, dynamic>> headerCustomFields =
      <Map<String, dynamic>>[].obs;

  // For line fields, use proper type declaration
  final RxMap<int, List<Map<String, dynamic>>> lineCustomFields =
      <int, List<Map<String, dynamic>>>{}.obs;
  RxList<Map<String, dynamic>> leaveCustomFields = <Map<String, dynamic>>[]
      .obs; // Helper method to safely convert dynamic maps
  Map<String, dynamic> _convertToStringKeyMap(
    Map<dynamic, dynamic> dynamicMap,
  ) {
    final Map<String, dynamic> result = {};

    dynamicMap.forEach((key, value) {
      if (key != null) {
        result[key.toString()] = value;
      }
    });

    return result;
  }

  final RxList<Map<String, dynamic>> masterLineCustomFields =
      <Map<String, dynamic>>[].obs;
  Future<void> fetchCustomFieldsTimeSheet() async {
    try {
      // print('Fetching custom fields from API...');

      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/masters/fieldmanagement/customfields/customfields?filter_query=STPCustomFields.IsActive__eq%3Dtrue&page=1&sort_order=asc',
        ),
      );

      /// ✅ Check API status first
      if (response.statusCode != 200) {
        // print('API failed with status: ${response.statusCode}');
        return;
      }

      dynamic decoded;

      /// ✅ JSON Decode safely
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        // print('JSON decode error: $e');
        return;
      }

      /// ✅ Validate response structure safely
      if (decoded is List) {
        _handleListResponse(decoded);
      } else if (decoded is Map<String, dynamic>) {
        final list = decoded['data'];

        if (list is List) {
          _handleListResponse(list);
        } else {
          // print('Data key is not a List');
        }
      } else {
        // print('Unexpected response format: ${decoded.runtimeType}');
      }
    } catch (e, s) {
      /// ✅ Catch network / unexpected errors
      // print('Custom field fetch error: $e');
      // print('Stacktrace: $s');
    }
  }

  Map<String, dynamic> _parseCustomField(Map<String, dynamic> json) {
    return {
      "id": json["Id"] ?? json["id"],
      "name": json["FieldName"] ?? json["name"] ?? "",
      "type": json["FieldType"] ?? "",
      "isHeader": json["IsHeader"] ?? false,

      /// ✅ SAFE LIST PARSING
      "options": _toStringList(json["Options"]),
      "allowedValues": _toStringList(json["AllowedValues"]),
      "pickList": _toStringList(json["PickList"]),

      /// other fields safe
      "required": json["IsRequired"] ?? false,
      "defaultValue": json["DefaultValue"]?.toString(),
    };
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<void> _handleListResponse(List<dynamic> responseData) async {
    // print('Processing List response with ${responseData.length} items');
    await _processDataList(responseData);
  }

  Future<void> _processDataList(List<dynamic> dataList) async {
    final List<Map<String, dynamic>> tempHeaderFields = [];
    final List<Map<String, dynamic>> tempLineFields = [];
    final List<Map<String, dynamic>> tempLeaveFields = []; // NEW

    int headerCount = 0;
    int lineCount = 0;
    int leaveCount = 0;
    int skippedCount = 0;

    for (var item in dataList) {
      try {
        Map<String, dynamic> fieldData = _convertDynamicToMap(item);

        if (fieldData.isEmpty) {
          skippedCount++;
          continue;
        }

        String objectName =
            _getStringValue(fieldData, 'ObjectName')?.trim() ?? '';

        objectName = objectName.isEmpty
            ? _getStringValue(fieldData, 'Entity')?.trim() ?? ''
            : objectName;

        /// TIMESHEET HEADER
        if (objectName == 'TimesheetRequisitionHeader') {
          final processedField = _createCustomField(
            fieldData,
            'TimesheetRequisitionHeader',
          );

          if (processedField != null) {
            tempHeaderFields.add(processedField);
            headerCount++;
          }
        }
        /// TIMESHEET LINES
        else if (objectName == 'TimesheetRequisitionLines') {
          final processedField = _createCustomField(
            fieldData,
            'TimesheetRequisitionLines',
          );

          if (processedField != null) {
            tempLineFields.add(processedField);
            lineCount++;
          }
        }
        /// 🔥 LEAVE REQUISITION (NEW)
        else if (objectName == 'LeaveRequisition') {
          final processedField = _createCustomField(
            fieldData,
            'LeaveRequisition',
          );

          if (processedField != null) {
            tempLeaveFields.add(processedField);
            leaveCount++;
          }
        } else {
          skippedCount++;
        }
      } catch (e) {
        skippedCount++;
      }
    }

    /// Update Observables

    if (tempHeaderFields.isNotEmpty) {
      headerCustomFields.value = tempHeaderFields;
    }

    if (tempLineFields.isNotEmpty) {
      masterLineCustomFields.assignAll(tempLineFields);

      for (int i = 0; i < lineItems.length; i++) {
        lineCustomFields[i] = masterLineCustomFields.map((f) {
          return {...f, "FieldValue": ""};
        }).toList();
      }
    }

    // /// 🔥 LEAVE FIELDS UPDATE
    // if (tempLeaveFields.isNotEmpty) {
    //  leaveCustomFields[0] = tempLeaveFields as Map<String, dynamic>;
    // }
  }

  // Helper to convert dynamic to Map<String, dynamic>
  Map<String, dynamic> _convertDynamicToMap(dynamic item) {
    final Map<String, dynamic> result = {};

    if (item is Map<String, dynamic>) {
      return item;
    } else if (item is Map) {
      (item as Map<dynamic, dynamic>).forEach((key, value) {
        if (key != null) {
          result[key.toString()] = value;
        }
      });
      return result;
    }
    return {};
  }

  // Helper to get string value with multiple key possibilities
  String? _getStringValue(Map<String, dynamic> map, String key) {
    final keysToTry = [key, key.toLowerCase(), _toCamelCase(key)];

    for (var k in keysToTry) {
      if (map.containsKey(k) && map[k] != null) {
        return map[k].toString();
      }
    }
    return null;
  }

  String _toCamelCase(String str) {
    if (str.isEmpty) return '';
    return str[0].toLowerCase() + str.substring(1);
  }

  // Create custom field map
  Map<String, dynamic>? _createCustomField(
    Map<String, dynamic> fieldData,
    String entityType,
  ) {
    try {
      final fieldId = _getStringValue(fieldData, 'FieldId') ?? '';
      final fieldName =
          _getStringValue(fieldData, 'FieldName') ?? 'Unnamed Field';
      final fieldType = (_getStringValue(fieldData, 'FieldType') ?? 'text')
          .toLowerCase();
      final defaultValue = _getStringValue(fieldData, 'DefaultValue') ?? '';

      // Parse boolean values
      final isMandatory = _parseBool(_getStringValue(fieldData, 'IsMandatory'));
      final isVisible = _parseBool(
        _getStringValue(fieldData, 'IsVisible'),
        true,
      );

      // Get options for dropdown
      List<String> options = [];
      final optionsData = fieldData['Options'] ?? fieldData['options'];
      if (optionsData is List) {
        options = optionsData.map((o) => o.toString()).toList();
      }

      return {
        'CustomFieldEntity': entityType,
        'FieldId': fieldId,
        'FieldName': fieldName,
        'FieldType': fieldType,
        'DefaultValue': defaultValue,
        'FieldValue': defaultValue, // Initialize with default value
        'IsMandatory': isMandatory,
        'IsVisible': isVisible,
        'Options': options,
      };
    } catch (e) {
      // print('Error creating custom field: $e');
      return null;
    }
  }

  // Parse boolean value
  bool _parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }

  Future<void> checkLocationDisclosure(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isShown = prefs.getBool('locationDisclosureShown') ?? false;

    if (!isShown) {
      showLocationDisclosure(context);
    } else {
      fetchCurrentLocation();
    }
  }

  GoogleMapController? mapController;
  Future<void> fetchCurrentLocation() async {
    print("Getting Location ");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(position.latitude, position.longitude);

    currentLatLng.value = latLng;

    markers.value = {
      Marker(markerId: const MarkerId('current_location'), position: latLng),
    };

    locationText.value =
        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

    /// Move camera smoothly
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
  }

  final Rx<LatLng> currentLatLng = const LatLng(
    17.4846,
    78.3843,
  ).obs; // default
  final RxSet<Marker> markers = <Marker>{}.obs;

  void updateLocation(double lat, double lng) {
    final position = LatLng(lat, lng);
    currentLatLng.value = position;

    markers.value = {
      Marker(markerId: const MarkerId('current_location'), position: position),
    };

    locationText.value = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  void showLocationDisclosure(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
            "This app collects location data to verify employee attendance "
            "and field visits even when the app is closed or not in use.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('locationDisclosureShown', true);
                Navigator.pop(context);
                await fetchCurrentLocation(); // CALL YOUR FUNCTION HERE
              },
              child: const Text("Allow"),
            ),
          ],
        );
      },
    );
  }

  // Initialize default fields
  void _initializeDefaultFields() {
    // print('Initializing default custom fields');

    // Default header fields
    headerCustomFields.value = [
      {
        'CustomFieldEntity': 'TimesheetRequisitionHeader',
        'FieldId': 'FI-93',
        'FieldName': 'testtimesheet',
        'FieldType': 'text',
        'DefaultValue': 'testtimesheet',
        'FieldValue': 'testtimesheet',
        'IsMandatory': false,
        'IsVisible': true,
        'Options': [],
      },
      {
        'CustomFieldEntity': 'TimesheetRequisitionHeader',
        'FieldId': 'FI-97',
        'FieldName': 'HiInHeader',
        'FieldType': 'text',
        'DefaultValue': '',
        'FieldValue': '',
        'IsMandatory': false,
        'IsVisible': true,
        'Options': [],
      },
    ];

    // Default line fields
    final defaultLineFields = [
      {
        'CustomFieldEntity': 'TimesheetRequisitionLines',
        'FieldId': 'FI-136',
        'FieldName': 'dfg',
        'FieldType': 'date',
        'DefaultValue': '1764700199999',
        'FieldValue': '1764700199999',
        'IsMandatory': false,
        'IsVisible': true,
        'Options': [],
      },
      {
        'CustomFieldEntity': 'TimesheetRequisitionLines',
        'FieldId': 'FI-98',
        'FieldName': 'HiInLines',
        'FieldType': 'text',
        'DefaultValue': 'HiInLines',
        'FieldValue': 'HiInLines',
        'IsMandatory': false,
        'IsVisible': true,
        'Options': [],
      },
      {
        'CustomFieldEntity': 'TimesheetRequisitionLines',
        'FieldId': 'FI-99',
        'FieldName': 'Hi lines 2',
        'FieldType': 'text',
        'DefaultValue': 'Hi lines 2',
        'FieldValue': 'Hi lines 2',
        'IsMandatory': false,
        'IsVisible': true,
        'Options': [],
      },
    ];

    // Initialize for existing line items
    for (int i = 0; i < lineItems.length; i++) {
      lineCustomFields[i] = List.from(defaultLineFields);
    }
  }

  // Update custom field value
  void updateCustomFieldValue(int? lineIndex, String fieldId, String value) {
    if (lineIndex == null) {
      // Update header field
      for (int i = 0; i < headerCustomFields.length; i++) {
        if (headerCustomFields[i]['FieldId'] == fieldId) {
          headerCustomFields[i] = Map<String, dynamic>.from(
            headerCustomFields[i],
          )..['FieldValue'] = value;
          headerCustomFields.refresh();
          break;
        }
      }
    } else {
      // Update line field
      final fields = lineCustomFields[lineIndex];
      if (fields != null) {
        for (int i = 0; i < fields.length; i++) {
          if (fields[i]['FieldId'] == fieldId) {
            fields[i] = Map<String, dynamic>.from(fields[i])
              ..['FieldValue'] = value;
            lineCustomFields.refresh();
            break;
          }
        }
      }
    }
  }

  // Initialize custom fields for a new line item
  void initializeLineCustomFields(int lineIndex) {
    if (lineCustomFields.containsKey(lineIndex)) return;

    // Copy fields from first line if exists, otherwise use defaults
    if (lineItems.isNotEmpty && lineCustomFields.containsKey(0)) {
      lineCustomFields[lineIndex] = lineCustomFields[0]!
          .map((f) => Map<String, dynamic>.from(f))
          .toList();
    } else {
      // Use default line fields
      lineCustomFields[lineIndex] = [
        {
          'CustomFieldEntity': 'TimesheetRequisitionLines',
          'FieldId': 'FI-136',
          'FieldName': 'dfg',
          'FieldType': 'text',
          'DefaultValue': '1764700199999',
          'FieldValue': '1764700199999',
          'IsMandatory': false,
          'IsVisible': true,
          'Options': [],
        },
        {
          'CustomFieldEntity': 'TimesheetRequisitionLines',
          'FieldId': 'FI-98',
          'FieldName': 'HiInLines',
          'FieldType': 'text',
          'DefaultValue': 'HiInLines',
          'FieldValue': 'HiInLines',
          'IsMandatory': false,
          'IsVisible': true,
          'Options': [],
        },
        {
          'CustomFieldEntity': 'TimesheetRequisitionLines',
          'FieldId': 'FI-99',
          'FieldName': 'Hi lines 2',
          'FieldType': 'text',
          'DefaultValue': 'Hi lines 2',
          'FieldValue': 'Hi lines 2',
          'IsMandatory': false,
          'IsVisible': true,
          'Options': [],
        },
      ];
    }
  }

  // Prepare custom fields for API submission
  List<Map<String, dynamic>> prepareHeaderCustomFieldsForAPI() {
    return headerCustomFields.map((field) {
      return {
        'CustomFieldEntity': field['CustomFieldEntity'] as String,
        'FieldId': field['FieldId'] as String,
        'FieldValue': field['FieldValue'] as String,
        'FieldName': field['FieldName'] as String,
      };
    }).toList();
  }

  List<Map<String, dynamic>> prepareLineCustomFieldsForAPI(int lineIndex) {
    final fields = lineCustomFields[lineIndex] ?? [];
    return fields.map((field) {
      return {
        'CustomFieldEntity': field['CustomFieldEntity'] as String,
        'FieldId': field['FieldId'] as String,
        'FieldValue': field['FieldValue'] as String,
        'FieldName': field['FieldName'] as String,
      };
    }).toList();
  }

  // Add line item with custom fields
  void addLineItem() {
    final newIndex = lineItems.length;
    lineItems.add(LineItemModel());
    initializeLineCustomFields(newIndex);
    // print('✓ Added line item $newIndex with custom fields');
  }

  final punchStatus = PunchStatus.outDuty.obs;

  final locationText = ''.obs;
  final punchTimeText = '--'.obs;
  final statusText = 'Not In'.obs;
  final lastInText = ''.obs;
  final lastOutText = ''.obs;
  final lastInTextResponse = ''.obs;
  final totalDurationText = ''.obs;

  DateTime today = DateTime.now();

  /// FETCH LAST SESSION
  Future<void> fetchLastPunch() async {
    isLoading.value = true;

    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/attendenceservices/punchinoutendpoints/punchinpunchouttrans?filter_query=PUNAttendanceTransaction.EmployeeId__eq%3D${Params.employeeId}%26PUNAttendanceTransaction.IsActive__eq%3DTrue&page=1&sort_by=TransAttendanceId&sort_order=desc&limit=1',
    );

    final res = await ApiService.get(url);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      if (data.isNotEmpty) {
        final item = data.first; // ✅ safe now

        if (item['PunchOutTime'] == null) {
          punchStatus.value = PunchStatus.inDuty;
          statusText.value = 'In';
        } else {
          punchStatus.value = PunchStatus.outDuty;
          statusText.value = 'Not in';
        }

        lastInTextResponse.value = DateTime.fromMillisecondsSinceEpoch(
          item['PunchInTime'],
          isUtc: true,
        ).toIso8601String();

        recID = item['RecId'];

        lastInText.value = formatMillis(item['PunchInTime']);
        lastOutText.value = formatMillis(item['PunchOutTime']);
        totalDurationText.value = formatDuration(item['TotalDuration']);
      } else {
        // ✅ Handle empty response
        punchStatus.value = PunchStatus.outDuty;
        statusText.value = 'No Records';
        lastInText.value = '';
        lastOutText.value = '';
        totalDurationText.value = '';
      }
    }

    isLoading.value = false;
  }

  Timer? timer;
  void updateTime() {
    punchTimeText.value = DateFormat('hh:mm a').format(DateTime.now());
  }

  String formatMillis(int? millis) {
    if (millis == null) return '--';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('MMM d, h:mm a').format(date);
  }

  String formatMillisHours(int? millis) {
    if (millis == null) return '--';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat(' h:mm a').format(date);
  }

  String formatDuration(double? seconds) {
    if (seconds == null) return '--';

    final duration = Duration(seconds: seconds.toInt());

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    // 🔹 More than 24 hours → show days
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    }

    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }

    return '${secs}s';
  }

  // final ImagePicker _pickerSe = ImagePicker();
  final Rx<File?> selfie1 = Rx<File?>(null);
  final Rx<File?> selfie2 = Rx<File?>(null);

  Future<File?> captureSelfie() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70, // optional compression
    );

    if (image == null) return null;

    return File(image.path);
  }

  Future<bool> isLocationEnabled() async {
    // Check if location service is ON (GPS)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please turn ON location");
      return false;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: "Location permission permanently denied. Enable from settings",
      );
      return false;
    }

    return true;
  }

  /// BUTTON TAP
  Future<void> onPunchTap() async {
    isLoading.value = true;

    try {
      final isLocationOk = await isLocationEnabled();
      if (!isLocationOk) return;
      if (punchStatus.value == PunchStatus.outDuty) {
        // 👉 PUNCH IN
        final file = await captureSelfie();

        if (file == null) {
          Fluttertoast.showToast(msg: "Selfie is required for Punch In");
          return;
        }

        selfie1.value = file; // store punch-in selfie
        await punchIn();
      } else {
        // 👉 PUNCH OUT
        final file = await captureSelfie();

        selfie2.value = file; // store punch-out selfie
        await punchOut();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// PUNCH IN
  Future<void> punchIn() async {
    try {
      isLoading.value = true;

      final attachmentPayload = await buildDocumentAttachment([
        if (selfie1.value != null) selfie1.value!,
      ]);

      final payload = {
        "EmployeeId": Params.employeeId,
        "Status": "OnDuty",
        "CaptureMethod": "TimeLog",
        "IsRegularized": true,
        "PunchInDevice": "Mobile",
        "PunchInGeofenceId": "",
        "PunchInLocationId": "",
        "PunchInTime": DateTime.now().toUtc().toIso8601String(),
        "PunchInLocation": [
          currentLatLng.value.longitude,
          currentLatLng.value.latitude,
        ],
        "DocumentAttachment": {"File": attachmentPayload},
        "PunchOutDevice": "Mobile",
        "PunchOutGeofenceId": "",
        "PunchOutLocation": [],
        "PunchOutTime": null,
        "PunchoutLocationId": "",
      };

      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/attendenceservices/punchinoutendpoints/punchinpunchouttrans',
      );

      final response = await ApiService.post(url, body: jsonEncode(payload));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String message = data['detail']?['message'];
        fetchLastPunch();
        isLoading.value = false;
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        String message =
            data?['detail']?['message'] ?? response.body ?? "Server Error";
        punchStatus.value = PunchStatus.outDuty;
        statusText.value = 'Not in';
        isLoading.value = false;
        fetchLastPunch();
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      isLoading.value = false;

      Fluttertoast.showToast(
        msg: "Internal Server Error",
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
      );
      fetchLastPunch();
      debugPrint("Punch In Error: $e");
    } finally {
      isLoading.value = false;
    }

    // Camera + location can be added here

    // punchStatus.value = PunchStatus.inDuty;
    // statusText.value = 'in';
    // punchTimeText.value = _formatTime(DateTime.now());
  }

  bool isFieldMandatoryAdvance(String fieldName) {
    return configListAdvance.any(
      (f) =>
          (f['FieldName']?.toString().trim().toLowerCase() ==
              fieldName.trim().toLowerCase()) &&
          (f['IsEnabled'].toString().toLowerCase() == 'true') &&
          (f['IsMandatory'].toString().toLowerCase() == 'true'),
    );
  }

  /// PUNCH OUT
  Future<void> punchOut() async {
    try {
      isLoading.value = true; // optional loader

      final attachmentPayload = await buildDocumentAttachment([
        if (selfie2.value != null) selfie2.value!,
      ]);

      final payload = {
        "EmployeeId": Params.employeeId,
        "Status": "OnDuty",
        "CaptureMethod": "TimeLog",
        "IsRegularized": true,
        "PunchInDevice": "Mobile",
        "PunchInGeofenceId": "",
        "PunchInLocationId": "",
        "PunchInTime": lastInTextResponse.value,
        "RecId": recID,
        "PunchInLocation": [
          currentLatLng.value.longitude,
          currentLatLng.value.latitude,
        ],
        "DocumentAttachment": {"File": attachmentPayload},
        "PunchOutDevice": "Mobile",
        "PunchOutGeofenceId": "",
        "PunchOutLocation": [
          currentLatLng.value.longitude,
          currentLatLng.value.latitude,
        ],
        "PunchOutTime": isoUtcMicros(),
        "PunchoutLocationId": "",
      };

      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/attendenceservices/punchinoutendpoints/punchinpunchouttrans',
      );

      final response = await ApiService.post(url, body: jsonEncode(payload));

      final data = jsonDecode(response.body);

      // ✅ Safe message extraction
      String message =
          data['detail']?['message'] ?? data['message'] ?? "Punch Out Failed";

      if (response.statusCode == 200 || response.statusCode == 280) {
        fetchLastPunch();

        selfie1.value = null;
        selfie2.value = null;
        isLoading.value = false;

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        isLoading.value = false;
        fetchLastPunch();
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red[100],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      isLoading.value = false;

      Fluttertoast.showToast(
        msg: "Something went wrong. Please try again.",
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
      );

      debugPrint("PunchOut Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // /// LOCATION PLACEHOLDER
  // Future<void> fetchLocation() async {
  //   // Replace with Google Location
  //   locationText.value = '11.45890° N, 78.38426° E';
  // }

  String isoUtcMicros() {
    final u = DateTime.now().toUtc();
    final base = u.toIso8601String().replaceAll('Z', '');
    return base.padRight(26, '0') + 'Z';
  }

  RxBool isAiActive = false.obs;
  RxBool isAiLoading = false.obs;
  Future<void> checkAiHealth() async {
    try {
      isAiLoading.value = true;

      final response = await ApiService.post(
        Uri.parse("${Urls.baseURL}/api/v1/aiapis/aiapis/aihealth"),

        body: jsonEncode({}), // if body required
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 Handle response
        if (data != null && data['status'] == 'active') {
          isAiActive.value = true;
        } else {
          isAiActive.value = false;
        }
      } else {
        isAiActive.value = false;
      }
    } catch (e) {
      isAiActive.value = false;
    } finally {
      isAiLoading.value = false;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  Future<bool> updateChecklistStatus({
    required int recId,
    required bool status,
  }) async {
    final url = Uri.parse(
      '${Urls.baseURL}/api/v1/kanban/tasks/checklist/checkliststatus'
      '?RecId=$recId&Status=$status',
    );

    final res = await ApiService.put(url);

    return res.statusCode == 280;
  }

  Future<File?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 50, // reduce quality (0-100)
        minWidth: 800,
        minHeight: 800,
      );

      if (result == null) return null;

      return File(result.path); // ✅ Fixes Object → File error
    } catch (e) {
      debugPrint("Compression error: $e");
      return null;
    }
  }

  RxList<TaskFieldConfig> taskFields = <TaskFieldConfig>[].obs;

  Map<String, dynamic> dynamicValues = {};

  Future<void> fetchTaskConfig(int taskRecId) async {
    final url = Uri.parse(
      "${Urls.baseURL}/api/v1/kanban/tasks/tasks/configfields?TaskRecId=$taskRecId",
    );

    final res = await ApiService.get(url);

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      taskFields.assignAll(
        decoded.map((e) => TaskFieldConfig.fromJson(e)).toList(),
      );
    } else if (decoded is Map && decoded["TaskData"] is List) {
      taskFields.assignAll(
        (decoded["TaskData"] as List)
            .map((e) => TaskFieldConfig.fromJson(e))
            .toList(),
      );
    } else {
      taskFields.clear();
    }
  }

  List<String> getListValues(TaskFieldConfig field) {
    switch (field.fieldName) {
      case "Card Types":
        return ["Bug", "Feature", "Improvement"];

      case "Risk Level":
        return ["Low", "Medium", "High"];

      default:
        return [];
    }
  }

  Future<void> deleteKanbanTask(int recId) async {
    try {
      setButtonLoading('delete', true);

      final url =
          "${Urls.baseURL}/api/v1/kanban/tasks/tasks/tasks"
          "?RecId=$recId&screen_name=KANTasks";

      final response = await ApiService.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Task deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {}
    } catch (e) {
    } finally {
      setButtonLoading('delete', false);
    }
  }
}
