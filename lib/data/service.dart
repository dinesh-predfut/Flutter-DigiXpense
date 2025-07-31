// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/CashAdvanceRequest/cashAdvanceReturnEditForm.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:digi_xpense/core/constant/Parames/models.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/core/constant/url.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/forgetPassword.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
// ignore: duplicate_import
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/screen/widget/router/router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class Controller extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotemailController = TextEditingController();
  final TextEditingController manualPaidToController = TextEditingController();
  // setting
  final TextEditingController countryPresentTextController =
      TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController officialEmailController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController locale = TextEditingController();
  // final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController addresspurpose = TextEditingController();
  final TextEditingController cashAdvanceRequisitionID =
      TextEditingController();

  // final TextEditingController country = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
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
// Per Diem

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController mileagDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  // final TextEditingController locationController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController perDiemController = TextEditingController();
  final TextEditingController amountInController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  String? digiSessionId;
  List<VehicleType> vehicleTypes = []; // Dropdown values from API
  VehicleType? selectedVehicleType; // Currently selected type
  MileageRateResponse? mileageRateResponse;
  List<Map<String, dynamic>> mileageRateLines = [];
  var projectExpenses = <ProjectExpense>[].obs;
  var expensesByStatus = <ExpenseAmountByStatus>[].obs;
  var manageExpensesCards = <ManageExpensesCard>[].obs;
  var managecashAdvanceCards = <ManageExpensesCard>[].obs;

  RxList<CashAdvanceModel> cashAdvanceList = <CashAdvanceModel>[].obs;
  RxList<ExpenseListModel> expenseList = <ExpenseListModel>[].obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<PendingCashAdvanceApproval> pendingApprovalcashAdvanse = [];
  var isUploadingCards = false.obs;
  var isLoadingStatus = false.obs;
  var callAPIDashBoard = true.obs;
  bool showAllCashAdvance = false; // Track see more
  bool showAllExpense = false;
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
  // CashAdvanceRequest@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  final TextEditingController justificationController = TextEditingController();
  final TextEditingController totalunitEstimatedAmount =
      TextEditingController();
//  final TextEditingController expenseIdController = TextEditingController();
  RxDouble calculatedPercentage = 0.0.obs;
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
  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
    fetchNotifications();
    // cashAdvanceIds = TextEditingController();
  }

  RxMap<String, bool> buttonLoaders = <String, bool>{}.obs;

  void setButtonLoading(String buttonName, bool isLoading) {
    buttonLoaders[buttonName] = isLoading;
  }

  String selectedStatus = "Un Reported";
  final selectedStatusDropDown = "Un Reported".obs;
  String selectedStatusmyteam = "In Process";
  final selectedStatusDropDownmyteam = "In Process".obs;
   String selectedStatusmyteamCashAdvance = "In Process";
  final selectedStatusDropDownmyteamCashAdvance = "In Process".obs;
  var countryCode = ''.obs;
  var phoneNumber = ''.obs;
  List<GESpeficExpense> getSpecificListGExpense = [];
  RxList<GESpeficExpense> specificExpenseList = <GESpeficExpense>[].obs;
  RxList<CashAdvanceRequestHeader> specificCashAdvanceList =
      <CashAdvanceRequestHeader>[].obs;
  RxList<PerdiemResponseModel> specificPerdiemList =
      <PerdiemResponseModel>[].obs;
  Rx<PerDiemResponseModel?> perdiemResponse = Rx<PerDiemResponseModel?>(null);
  // List<ExpenseItem> expenseItems = [];
  List<ExpenseItem> finalItems = [];
  // List<CashAdvanceRequestItemize> finalItemsForCashadvance = [];
  List<CashAdvanceRequestItemize> finalItemsCashAdvance = [];
  List<CashAdvanceRequestItemizeFornew> finalItemsCashAdvanceNew = [];
  List<AccountingDistribution?> accountingDistributions = [];
  RxList<GExpense> getAllListGExpense = <GExpense>[].obs;
    RxList<CashAdvanceRequestHeader> getAllListCashAdvanseMyteams = <CashAdvanceRequestHeader>[].obs;
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
  late double expenseChartvalue = 0.0;
  late double exchangeRate;
  bool isManualEntry = false;
  bool isManualEntryMerchant = false;
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
  String? expenseID;
  int? recID;
  String selectedCurrencyFinal = '';
  List<String> emails = [];
  RxList<User> userList = <User>[].obs; // User list from API
  Rx<User?> selectedUser = Rx<User?>(null); // Selected user
  TextEditingController userIdController =
      TextEditingController(); // For dropdown

  List<Map<String, dynamic>> expenseTrans = [];
  RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;
  String country = '';
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
  String selectedCountryCode = '';
  String selectedContectCountryName = '';
  String selectedContectCountryCode = '';
  String selectedContectStateName = '';
  late int setTheAllcationAmount = 0;
  CashAdvanceDropDownModel? singleSelectedItem; // For single select mode
  // List<CashAdvanceDropDownModel> multiSelectedItems = [];
  final RxList<CashAdvanceDropDownModel> multiSelectedItems =
      <CashAdvanceDropDownModel>[].obs;

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
  final RxBool isLoading = false.obs;
  final RxBool isLoadingLogin = false.obs;
  final RxBool isLoadingviewImage = false.obs;
  final RxBool isGESubmitBTNLoading = false.obs;
  final RxBool isGEPersonalInfoLoading = false.obs;
  final RxBool isLoadingGE1 = false.obs;
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
  Rx<Timezone> selectedTimezone = Timezone(code: '', name: '', id: '').obs;
  var countries = <Country>[].obs;
  List<Language> language = [];
  List<Timezone> timezone = [];
  List<Locales> localeData = [];
  List<LocationModel> locationDropDown = [];
  List<String> languageList = [];
  List<String> countryNames = [];
  List<String> stateList = [];
  RxList<Currency> currencies = <Currency>[].obs;

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
  RxBool isBillable = false.obs; // ✅ Reactive
  RxBool isisBillablereate = false.obs;
  var checkboxValues = <String, bool>{}.obs;
  Color getRandomMildColor() {
    Random random = Random();
    int red = (random.nextInt(128) + 127); // 127–255
    int green = (random.nextInt(128) + 127); // 127–255
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
    try {
      isLoadingLogin.value = true;
      // showMsg(false);
      // print("countryCodeController.text${countryCodeController.text}");
      var request = http.Request('POST', Uri.parse(Urls.login));
      request.body = json.encode({
        "Email": emailController.text.trim(),
        "PasswordHash": passwordController.text.trim(),
      });
      request.headers.addAll({'Content-Type': 'application/json'});

      http.StreamedResponse response = await request.send();
      var decodeData = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 201) {
        isLoadingLogin.value = false;
        await saveCredentials();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);

        signInModel.value = UserProfile.fromJson(decodeData);

        employeeIdController.text = decodeData['employeeId'] ?? '';
        middleNameController.text = decodeData['UserName'] ?? '';
        firstNameController.text = decodeData['UserName'] ?? '';
        lastNameController.text = decodeData['UserName'] ?? '';
        personalEmailController.text = decodeData['Email'] ?? '';
        final settings =
            (decodeData["UserSettings"] as List).first as Map<String, dynamic>;
        selectedTimezonevalue = settings["DefaultTimeZoneValue"] ?? '';
        stringCurrency = settings["DefaultCurrency"] ?? '';
        // selectedLanguage = settings["DefaultLanguageId"] ?? '';
        // selectedPayment = settings["DefaultPaymentMethodId"] ?? '';
        // selectedFormat = settings["DefaultDateFormat"] ?? '';
        print("setting$selectedCurrency");
        SetSharedPref().setData(
            token: signInModel.value.accessToken ?? "null",
            employeeId: signInModel.value.employeeId ?? "null",
            userId: signInModel.value.userId ?? "null",
            refreshtoken: signInModel.value.refreshToken ?? "null",
            userName: signInModel.value.userName ?? "null");

        // showMsg(false);

        // Show success toast
        Fluttertoast.showToast(
          msg: "Login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        isLoadingLogin.value = false;
        // Navigate to LandingPage
        // ignore: use_build_context_synchronously
      } else {
        isLoadingLogin.value = false;
        // Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        // Show error toast
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
      // ignore: use_build_context_synchronously
      // Navigator.pushNamed(context, AppRoutes.dashboard_Main);
      // Show exception toast
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("An error occurred: $e");
      isLoadingLogin.value = false;
      rethrow;
    }
  }

  void clearFormFields() {
    print("Cleared ALL2");
    multiSelectedItems.value = [];
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
    selectedDate = DateTime.now();
    imageFiles.clear();
    finalItems.clear();
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
    finalItemsCashAdvance = [];
    print("Cleared ALL ");
  }

  void chancelButton(BuildContext context) {
    clearFormFields();
    Navigator.pop(context);
  }

  ExpenseItemUpdate toExpenseItemUpdateModel() {
    return ExpenseItemUpdate(
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
                double.tryParse(controller?.transAmount.toString() ?? '') ??
                    0.0,
            reportAmount:
                double.tryParse(controller?.reportAmount.toString() ?? '') ??
                    0.0,
            allocationFactor: controller?.allocationFactor ?? 0.0,
            dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
            currency: selectedCurrency.value?.code ?? "IND");
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
      isReimbursable: isReimbursite,
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
        return AccountingDistribution(
            transAmount:
                double.tryParse(controller?.transAmount.toString() ?? '') ??
                    0.0,
            reportAmount:
                double.tryParse(controller?.reportAmount.toString() ?? '') ??
                    0.0,
            allocationFactor: controller?.allocationFactor ?? 0.0,
            dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
            currency: selectedCurrency.value?.code ?? "IND");
      }).toList(),
    );
  }

  void calculateLineAmounts(Controller itemController) {
    double quantity = double.tryParse(itemController.quantity.text) ?? 0.0;
    double unitPrice =
        double.tryParse(itemController.unitPriceTrans.text) ?? 0.0;

    double lineAmount = quantity * unitPrice;

    double lineAmountInINR = lineAmount;

    itemController.lineAmount.text = lineAmount.toStringAsFixed(2);
    itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);
  }

  Future<List<PaidForModel>> fetchPaidForList() async {
    final url = Uri.parse(Urls.dimensionValueDropDown);

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${Params.userToken ?? ''}',
        'DigiSessionID': digiSessionId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => PaidForModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch Paid For list: ${response.statusCode}');
    }
  }

  Future<void> sendUploadedFileToServer(BuildContext context, File file) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
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

      final response = await http.post(url, headers: headers, body: body);

      Navigator.of(context).pop(); // Close the loader

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("Success: $responseData");

        // Navigate with image + response data
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.autoScan,
          arguments: {
            'imageFile': file,
            'apiResponse': responseData,
          },
        );
      } else {
        print('Failed: ${response.statusCode} => ${response.body}');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Upload failed:${response.statusCode} => ${response.body}')),
        );
      }
    } catch (e) {
      // Navigator.of(context).pop(); // Ensure loader closes on error too
      print("Exception: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> pickImageProfile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    isImageLoading.value = true;
    profileImage.value = File(pickedFile.path);

    try {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Str = base64Encode(bytes);
      final dataUrl = 'data:image/png;base64,$base64Str';

      await uploadProfilePicture(dataUrl);
      print('Upload done, profileImage = ${profileImage.value}');
    } catch (e) {
      print('Error picking/uploading image: $e');
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<void> uploadProfilePicture(String base64Image) async {
    final url = Uri.parse(
      '${Urls.updateProfilePicture}${Params.userId}',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Params.userToken ?? ''}',
    };
    final body = jsonEncode({
      'ProfilePicture': base64Image,
    });

    final response = await http.patch(url, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 280) {
      final responseData = jsonDecode(response.body);
      print('Upload successful: ${responseData['detail']}');
      Fluttertoast.showToast(
        msg: "${responseData['detail']}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 35, 2, 124),
        textColor: const Color.fromARGB(255, 253, 252, 253),
        fontSize: 16.0,
      );
    } else {
      print('Upload failed [${response.statusCode}]: ${response.body}');
      profileImage.value = null;
      Fluttertoast.showToast(
        msg: response.body,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 173, 3, 3),
        textColor: const Color.fromARGB(255, 253, 252, 253),
        fontSize: 16.0,
      );
      // you might parse response.body here to show validation errors
    }
  }

  Future<List<Country>> fetchCountries() async {
    final url = Uri.parse(Urls.countryList);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        countries.value =
            List<Country>.from(data.map((item) => Country.fromJson(item)));

        countryNames = countries.map((c) => c.name).toList();

        return countries;
      } else {
        print('Failed to load countries');
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching countries: $e');
      throw Exception('Error fetching countries: $e');
    }
  }

  Future<void> deleteProfilePicture() async {
    print("Deleting profile picture");

    const defaultProfileBase64 =
        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABzUlEQVR42mL8//8/AzSACylCxEZMDAwM7e3twb+5uTkZ4GLiIiZmRkZGdvDw8HBCQkIGdlBQUHhzwMDAwPpPyMjI2Pj48gDsDAwMIAEODg7+Qn5+f2YGBgTmNjY1fAp0JOTg4G5GBgYH8BDEhIS/GYyMjJ+QExMDvxvb29f8BeoGBgbiASUlJZcRgYGAB8o6OjqwmZmZkTwSkoKEqDg4PD//z8/M8DJCSkuJnwQHR0d0mBsbCwHkFJSUtAMjIyPMjJycpE8BQUFF4gICAg/2BgYGHwD5GRkUnJSUlZ8T///9/9BQUFAh4eHj/Pz8+D8VFxc/AYmJiVHBYGBg3wIWFhYH8b179z8GRgYGRsTk5+YfgYGBoZlA8uXLf0NLS0v8f+vr6f+BgYF7g4eHBfwMDw3+QkpLCJQUFBeYyMzN/gYGBAYwAAAwBXmHrXs+3bXgAAAABJRU5ErkJggg==";

    final url = Uri.parse(
      '${Urls.updateProfilePicture}${Params.userId}',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Params.userToken ?? ''}',
    };

    final body = jsonEncode({
      'ProfilePicture': 'data:image/png;base64,$defaultProfileBase64',
    });

    final response = await http.patch(url, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 280) {
      final responseData = jsonDecode(response.body);
      profileImage.value = null;
      print('Delete successful: ${responseData['detail']}');
      Fluttertoast.showToast(
        msg: "${responseData['detail']}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 35, 2, 124),
        textColor: const Color.fromARGB(255, 253, 252, 253),
        fontSize: 16.0,
      );
    } else {
      print('Delete failed [${response.statusCode}]: ${response.body}');
    }
  }

  Future<void> sendForgetPassword(BuildContext context) async {
    try {
      print("forgotemailController text: ${forgotemailController.text}");

      forgotisLoading.value = true;

      final response = await http.post(
          Uri.parse('${Urls.forgetPassword}${forgotemailController.text}'),
          headers: {
            'Content-Type': 'application/json',
          });

      final decodeData = jsonDecode(response.body);

      if (response.statusCode == 280) {
        forgotisLoading.value = false;

        Fluttertoast.showToast(
          msg: "Reset Password Link Sended Your Mail ID :${{
            forgotemailController.text
          }}",
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

      print("An error occurred: $e");
      rethrow;
    }
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  Future<void> saveCredentials() async {
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
    // print("urlss$uri");
    final uri = Uri.parse(url);

    print("urlss$uri");
    await launchUrl(uri,
        mode: LaunchMode.externalApplication); // or .inAppWebView
  }

  Future<void> fetchLanguageList() async {
    isLoading.value = true;
    final url = Uri.parse(Urls.languageList);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // countryList = List<Country>.from(
        //   data.map((item) => Country.fromJson(item)),
        // );
        final data = jsonDecode(response.body);
        language =
            List<Language>.from(data.map((item) => Language.fromJson(item)));
        isLoading.value = false;
        countryNames = language.map((c) => c.code).toList();
        print('language to load countries$data');
      } else {
        print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      print('Error fetching language: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchTimeZoneList() async {
    print('timezone to load timezone');
    isLoading.value = true;
    final url = Uri.parse(Urls.timeZoneDropdown);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // countryList = List<Country>.from(
        //   data.map((item) => Country.fromJson(item)),
        // );
        final data = jsonDecode(response.body);
        timezone =
            List<Timezone>.from(data.map((item) => Timezone.fromJson(item)));
        // countryNames = timezone.map((c) => c.name).toList();
        print('timezone to load timezone$timezone');
        isLoading.value = false;
      } else {
        print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      print('Error fetching language: $e');
      isLoading.value = false;
    }
  }

  Future<void> localeDropdown() async {
    final url = Uri.parse(Urls.locale);
    isLoading.value = true;
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        localeData =
            List<Locales>.from(data.map((item) => Locales.fromJson(item)));
        isLoading.value = false;
        // countryNames = localeData.map((c) => c.name).toList();
        // print('localeData to load countries$countryNames');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching localeData: $e');
    }
  }

  Future<List<StateModels>> fetchState([String? code]) async {
    final countryCode = selectedCountry.value!.code ?? "IND";
    final url = Uri.parse(
      '${Urls.stateList}$countryCode&page=1&sort_by=StateName&sort_order=asc&choosen_fields=StateName%2CStateId',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoading.value = true;
        final data = jsonDecode(response.body);

        final List<StateModels> states = List<StateModels>.from(
          data.map((item) => StateModels.fromJson(item)),
        );

        statesres.value = states;

        isLoading.value = false;
        return states;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<StateModels>> fetchSecondState() async {
    print("countryCode$selectedContectCountryCode");
    final countryCode = selectedContectCountryCode ?? "IND";
    final url = Uri.parse(
      '${Urls.stateList}$countryCode&page=1&sort_by=StateName&sort_order=asc&choosen_fields=StateName%2CStateId',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoading.value = true;
        final data = jsonDecode(response.body);

        final List<StateModels> states = List<StateModels>.from(
          data.map((item) => StateModels.fromJson(item)),
        );

        statesconst.value = states;

        isLoading.value = false;
        return states;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      return [];
    }
  }

  Future<void> currencyDropDown() async {
    isLoading.value = true;
    final url = Uri.parse(Urls.correncyDropdown);
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        currencies.value = data.map((e) => Currency.fromJson(e)).toList();
        isLoading.value = false;
        print('currencies to load countries$currencies');
      } else {
        print('Failed to load countries');
        isLoading.value = false;
      }
    } catch (e) {
      print('Error fetching countries: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenseCategory() async {
    final dateToUse = selectedDate ?? DateTime.now();
    print("fetchExpenseCategory${selectedProject?.code}");
    print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    print("fetchExpenseCategory$fromDate");
    try {
      // Safely construct query parameters
      final queryParams = <String, String>{
        'TransactionDate': fromDate.toString(),
      };

      if (selectedProject?.code != null && selectedProject!.code.isNotEmpty) {
        queryParams['ProjectId'] = selectedProject!.code;
      }

      final url =
          Uri.parse(Urls.expenseCategory).replace(queryParameters: queryParams);

      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          expenseCategory.value =
              data.map((e) => ExpenseCategory.fromJson(e)).toList();
          print('Expense categories loaded: ${expenseCategory.length}');
        } else {
          print('Unexpected response format: $data');
        }
      } else {
        print(
            'Failed to load expense categories. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> configuration() async {
    isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.geconfigureField);
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configList.value = [];
        if (data is List) {
          configList.addAll(data.cast<Map<String, dynamic>>());

          print('Appended configList: $configList');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          print('currencies to load countries$currencies');
        }
      } else {
        print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      print('Error fetching countries: $e');
      isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  // MOVE THIS TO GLOBAL SCOPE
  T findOrFallback<T>(List<T> list, bool Function(T) test, T fallback) {
    return list.firstWhere(test, orElse: () => fallback);
  }

  Future<void> getUserPref() async {
    isLoading.value = true;
    isLoadingGE1.value = true;

    final url = Uri.parse(
      '${Urls.getuserPreferencesAPI}${Params.userId}&page=1&sort_order=asc',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List || decoded.isEmpty) {
        throw Exception('Empty or invalid prefs');
      }
      isLoading.value = true;
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

      final pay = findOrFallback<Payment>(
        payment,
        (p) => p.code == defaultPaymentId,
        Payment(code: '', name: ''),
      );

      final format = dateFormatMap.entries.firstWhere(
        (e) => e.value == defaultDateformat,
        orElse: () => const MapEntry('dd_mm_yyyy', 'dd/MM/yyyy'),
      );

      final emailList = defaultReceiptEmailRaw
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
      selectedPayment.value = pay;
      selectedFormat = format;
      emails = emailList;
      fetchExchangeRate();
      // DEBUG
      print("Timezone: $tz - from: $currencyDropDowncontroller");
      isLoading.value = false;
    } catch (e) {
      print('Error loading prefs: $e');
    } finally {
      isLoading.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<void> paymentMethode() async {
    final url = Uri.parse(Urls.defalutPayment);
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        payment = data.map((e) => Payment.fromJson(e)).toList();
        isLoading.value = false;
        print('payment to load countries$payment');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> getProfilePicture() async {
    profileImage.value = null; // Clear old image
    final url = Uri.parse('${Urls.getProfilePicture}${Params.userId}');
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        print('✅ Profile picture fetched successfully');

        final String base64String = response.body;
        final cleaned = base64String.contains(',')
            ? base64String.split(',')[1]
            : base64String;

        final Uint8List bytes = base64Decode(cleaned);

        // Save image to temporary directory
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/profile_image.png');
        await file.writeAsBytes(bytes);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', file.toString());
        profileImage.value = file;

        print(' Profile image stored at: ${file.path}');
      } else {
        print('Failed to fetch profile picture: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error fetching profile picture: $e');
    }
  }

  Future<void> loadProfilePictureFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final filePath = prefs.getString('profile_image_path');

    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        profileImage.value = file;
        print('✅ Loaded cached profile image from $filePath');
      } else {
        print('⚠️ Cached profile image not found on disk');
        profileImage.value = null;
      }
    }
  }

  Future<void> updateProfileDetails() async {
    // buttonLoader.value = true;
    isGEPersonalInfoLoading.value = true;

    final Map<String, dynamic> requestBody = {
      "ContactNumber": '${countryCodeController.text} ${phoneController.text}',
      "employeeaddress": [
        {
          "AddressId": addressID.text,
          "Country": selectedCountryCode,
          "State": statePresentTextController.text,
          "Street": street.text,
          "City": city.text,
          "PostalCode": postalCode.text,
          "Addresspurpose": "Permanent"
        },
        {
          "AddressId": contactaddressID.text,
          "Country": selectedContectCountryCode,
          "State": stateTextController.text,
          "Street": contactStreetController.text,
          "City": contactCityController.text,
          "PostalCode": contactPostalController.text,
          "Addresspurpose": "Contact"
        }
      ]
    };

    try {
      final response = await http.put(
        Uri.parse('${Urls.updateAddressDetails}${Params.userId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 280) {
        isGEPersonalInfoLoading.value = false;
        // isUploading.value = false;
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: "Success: ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error:  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        isGEPersonalInfoLoading.value = false;
        // isUploading.value = false;
      }
    } catch (e) {
      print("❌ Exception: $e");
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
  Future<void> userPreferences() async {
    buttonLoader.value = true;
    final Map<String, dynamic> requestBody = {
      "UserId": Params.userId,
      "DefaultCurrency": selectedCurrency.value?.code,
      "DefaultTimeZoneValue": selectedTimezonevalue,
      "DefaultTimeZone": selectedTimezone.value.id,
      "DefaultLanguageId": selectedLanguage?.code,
      "DefaultDateFormat": selectedFormat?.value,
      "EmailsForRecieptForwarding": emails.join(';'),
      "ShowAnalyticsOnList": true,
      "DefaultPaymentMethodId": selectedPayment.value.code,
      "ThemeDirection": false,
      "ThemeColor": "GREEN_THEME",
      "DecimalSeperator": selectedLocale.value.code
    };

    try {
      final response = await http.put(
        Uri.parse('${Urls.userPreferencesAPI}${Params.userId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );
      print("requestBody$requestBody");
      if (response.statusCode == 280) {
        buttonLoader.value = false;
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: "Success: ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        buttonLoader.value = false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<bool> getPersonalDetails(BuildContext context) async {
    isLoading.value = true;
    print('userId: ${Params.userId}');
    try {
      final uri = Uri.parse(
          '${Urls.getPersonalByID}?UserId=${Params.userId}&lockid=${Params.userId}&screen_name=user');
      final request = http.Request('GET', uri)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      print('Requesting: $uri');

      // Send request
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        isLoading.value = false;
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
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

      gender.text = emp['Gender'] ?? '';
      final fullNumber = emp['ContactNumber'] ?? '';
      isLoading.value = true;
      if (fullNumber.length > 4) {
        final parts = fullNumber.trim().split(' ');
        print("Splitted Parts: $parts");

        if (parts.isNotEmpty) {
          countryCode.value = parts[0]; // Country code
          final phone = parts.sublist(1).join('');
          phoneNumber.value = phone;

          countryCodeController.text = countryCode.value;
          phoneController.text = phoneNumber.value;

          print("Phone without country code: ${phoneNumber.value}");
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

        print("Short phone input: ${phoneNumber.value}");
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
      selectedCountryCode = perm['Country'] ?? '';

      contactStreetController.text = cont['Street'] ?? '';
      contactCityController.text = cont['City'] ?? '';
      contactStateController = cont['State'] ?? '';
      stateTextController.text = contactStateController;
      contactPostalController.text = cont['PostalCode'] ?? '';
      contactaddressID.text = cont['AddressId'] ?? '';
      contactCountryController = cont['Country'] ?? '';

      final bool isSameAsPermanents = (perm['Street'] == cont['Street']) &&
          (perm['City'] == cont['City']) &&
          (perm['State'] == cont['State']) &&
          (perm['PostalCode'] == cont['PostalCode']) &&
          (perm['Country'] == cont['Country']);

      isSameAsPermanent = isSameAsPermanents;
// Delay mapping with Timer to ensure dropdown options are loaded
      Timer(const Duration(seconds: 5), () {
        selectedCountry.value = countries.firstWhere(
          (p) => p.code == selectedCountryCode,
          orElse: () => Country(code: '', name: ''),
        );
        isLoading.value = true;
        selectedContCountry.value = countries.firstWhere(
          (p) => p.code == contactCountryController,
          orElse: () => Country(code: '', name: ''),
        );

        countryConstTextController.text = selectedContCountry.value!.name;
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
        print("Selected State: ${selectedState.value}, "
            "Contact State: $contactStateController, "
            "Country Code: ${selectedContCountry.value!.code}");
      });

      // Fluttertoast.showToast(
      //   msg: "Personal details loaded: $selectedCountryCode",
      //   toastLength: Toast.LENGTH_SHORT,
      // );

      isLoading.value = false;

      return true;
    } catch (error) {
      isLoading.value = false;
      print('Error Occurreds: $error');
      Fluttertoast.showToast(
        msg: "An error occurred: $error",
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }

  Future<List<MerchantModel>> fetchPaidto() async {
    final dateToUse = selectedDate ?? DateTime.now();
    print("fetchPaidto${selectedProject?.code}");
    print("fetchPaidto$selectedDate");
    isLoading.value = true;
    print("fromDate$dateToUse");
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    print("formatted$formatted");
    final fromDate = parseDateToEpoch(formatted);
    print("fromDate$fromDate");

    isLoadingGE1.value = true;
    isLoadingGE2.value = true;

    final url = Uri.parse(
      '${Urls.getPaidtoDropdown}$fromDate',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
        print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      isLoadingGE2.value = false;

      return [];
    }
  }

  Future<List<LocationModel>> fetchLocation() async {
    isLoadingGE2.value = true;

    final url = Uri.parse(Urls.locationDropDown);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoading.value = true;
        final data = jsonDecode(response.body);

        locationDropDown = List<LocationModel>.from(
            data.map((item) => LocationModel.fromJson(item)));
        location.value = locationDropDown;
        isLoading.value = false;
        isLoadingGE2.value = false;

        return locationDropDown;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      isLoadingGE2.value = false;

      return [];
    }
  }

  Future<List<Project>> fetchProjectName() async {
    final dateToUse = selectedDate ?? DateTime.now();

    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    isLoadingGE1.value = true;
    isLoadingGE2.value = true;
    final url = Uri.parse(
      '${Urls.getProjectDropdown}$fromDate',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        // isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<Project> projects = List<Project>.from(
          data.map((item) => Project.fromJson(item)),
        );

        project.value = projects;

        print("projects$projects");
        isLoadingGE1.value = false;
        isLoadingGE2.value = false;
        return projects;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        isLoadingGE2.value = false;
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      isLoadingGE1.value = false;
      isLoadingGE2.value = false;
      return [];
    }
  }

  Future<List<TaxGroupModel>> fetchTaxGroup() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      Urls.taxGroup,
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<TaxGroupModel> taxGroups = List<TaxGroupModel>.from(
          data.map((item) => TaxGroupModel.fromJson(item)),
        );

        taxGroup.value = taxGroups;

        print("taxGroups$taxGroups");
        isLoadingGE1.value = false;
        return taxGroup;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<Unit>> fetchUnit() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      Urls.unitDropdown,
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<Unit> units = List<Unit>.from(
          data.map((item) => Unit.fromJson(item)),
        );

        unit.value = units;

        print("units$units");
        isLoadingGE1.value = false;
        return units;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<Unit>> fetchcurrencySymbol() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      Urls.currencySymbol,
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);

        final List<Unit> units = List<Unit>.from(
          data.map((item) => Unit.fromJson(item)),
        );

        unit.value = units;

        print("units$units");
        isLoadingGE1.value = false;
        return units;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      return [];
    }
  }

  Future<ExchangeRateResponse?> fetchExchangeRate() async {
    // if (selectedCurrency.value == null) {
    //   print('selectedCurrency is null');
    //   return null;
    // }
    final dateToUse = selectedDate ?? DateTime.now();
    print("fetchExpenseCategory${selectedProject?.code}");
    print("fetchExpenseCategory$selectedDate");
    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    print("fetchExpenseCategory$fromDate");
    double? parsedAmount = double.tryParse(paidAmount.text);
    print("parsedAmount$parsedAmount");
    final String amount =
        parsedAmount != null ? parsedAmount.toInt().toString() : '0';
    final currencyCode = selectedCurrency.value?.code ?? "INR";

    final url = Uri.parse(
      '${Urls.exchangeRate}/$amount/${currencyDropDowncontroller.text}/$fromDate',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        isLoadingGE1.value = false;
        final data = jsonDecode(response.body);
        print("amountINR: ${quantity.text}");

        if (data['ExchangeRate'] != null && data['BaseUnit'] != null) {
          unitRate.text = data['ExchangeRate'].toString();

          final double totalAmount = (data['Total_Amount'] is String)
              ? double.tryParse(data['Total_Amount']) ?? 0
              : (data['Total_Amount']?.toDouble() ?? 0);

          final double rate = data['ExchangeRate']?.toDouble() ?? 1;
          final double totalINR = totalAmount * rate;

          amountINR.text = totalINR.toStringAsFixed(2);
          exchangeRate = rate;

          lineAmount.text = totalAmount.toString();
          lineAmountINR.text = totalINR.toStringAsFixed(2);
          quantity.text = rate.toString();
        }

        return ExchangeRateResponse.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        unitRate.clear();
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return null;
    }
    return null;
  }

  Future<List<PaymentMethodModel>> fetchPaidwith() async {
    isLoadingGE2.value = true;
    final url = Uri.parse(Urls.getPaidwithDropdown);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        paymentMethods.value = (data as List)
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();

        print(
            "paymentMethods: ${paymentMethods.map((e) => e.paymentMethodName).toList()}");
        isLoadingGE2.value = false;

        return paymentMethods;
      } else {
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        isLoadingGE2.value = false;

        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificExpenseItem(context, int recId,
      [bool? bool]) async {
    isLoadingGE1.value = true;
    final url = Uri.parse('${Urls.getSpecificGeneralExpense}RecId=$recId');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text =
              DateFormat('dd/MM/yyyy').format(expense.receiptDate);
        }
        print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpense,
          arguments: {
            'item': specificExpenseList[0],
            "readOnly": bool,
          },
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificCashAdvanceReturn(
      context, int recId, bool bool) async {
    isLoadingGE1.value = true;
    final url = Uri.parse('${Urls.getSpecificGeneralExpense}RecId=$recId');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text =
              DateFormat('dd/MM/yyyy').format(expense.receiptDate);
        }
        print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificCashAdvanseView,
          arguments: {'item': specificExpenseList[0], "readOnly": bool},
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<List<GESpeficExpense>> fetchSecificCashAdvanceReturnApproval(
      context, int workitemrecid) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
        '${Urls.getSpecificCashAdvanceApproval}workitemrecid=$workitemrecid&lock_id=$workitemrecid&screen_name=MyPendingApproval');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text =
              DateFormat('dd/MM/yyyy').format(expense.receiptDate);
        }
        print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificCashAdvanseView,
          arguments: {
            'item': specificExpenseList[0],
          },
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<ExpenseModelMileage> fetchMileageDetails(context, expenseId) async {
    final response = await http.get(
      Uri.parse(
          "${Urls.mileageregistrationview}milageregistration?RecId=$expenseId&lock_id=$expenseId&screen_name=MileageRegistration"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final expense = ExpenseModelMileage.fromJson(data[0]); // Assuming array

      Navigator.pushNamed(
        context,
        AppRoutes.mileageDetailsPage,
        arguments: {
          'item': expense,
        },
      );

      return expense;
    } else {
      throw Exception("Failed to fetch mileage details");
    }
  }

  Future<ExpenseModelMileage> fetchMileageDetailsApproval(
      context, expenseId) async {
    final response = await http.get(
      Uri.parse(
          "${Urls.mileageregistrationview}detailedapproval?workitemrecid=$expenseId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final expense = ExpenseModelMileage.fromJson(data[0]); // Assuming array

      Navigator.pushNamed(
        context,
        AppRoutes.mileageExpensefirst,
        arguments: {
          'item': expense,
        },
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
      final response = await http.post(
        Uri.parse(Urls.updateApprovalStatus),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        clearFormFields();

        print("✅ Approval Action Success: ${response.body}");
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      print("❌ API Error: $e");
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
      "workitemrecid": workitemrecid,
      "decision": status,
      "comment": comment,
      "usedFor": "MyPendingApproval",
      "userId": status == "Escalated" && userIdController.text.isNotEmpty
          ? userIdController.text
          : null,
    };

    try {
      final response = await http.post(
        Uri.parse(Urls.updateApprovalStatusCashAdvance),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 202) {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
        clearFormFields();

        print("✅ Approval Action Success: ${response.body}");
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      print("❌ API Error: $e");
      return false;
    }
  }

  Future<List<GESpeficExpense>> fetchSecificApprovalExpenseItem(
      context, int recId) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
        '${Urls.getSpecificGeneralExpenseApproval}workitemrecid=$recId&lock_id=$recId&screen_name=MyPendingApproval');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        clearFormFields();
        specificExpenseList.value = (data as List)
            .map((item) => GESpeficExpense.fromJson(item))
            .toList();

        for (var expense in specificExpenseList) {
          expenseIdController.text = expense.expenseId;
          receiptDateController.text =
              DateFormat('dd/MM/yyyy').format(expense.receiptDate);
        }
        print("Expense ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.getSpecificExpenseApproval,
          arguments: {
            'item': specificExpenseList[0],
          },
        );
        return getSpecificListGExpense;
      } else {
        isLoadingGE1.value = false;
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<void> reviewMileageRegistration(
      context, bool action, int workitemrecid) async {
    final expenseTranArray = buildExpenseTrans();
    Map<String, dynamic> expenseTransMap = {};
    for (int i = 0; i < expenseTranArray.length; i++) {
      expenseTransMap[i.toString()] = expenseTranArray[i];
    }
    final payload = {
      "workitemrecid": workitemrecid,
      "TotalAmountTrans": calculatedAmountINR,
      "TotalAmountReporting": calculatedAmountINR,
      "EmployeeId": Params.employeeId,
      "EmployeeName": "Dinesh",
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
      "CashAdvReqId": "",
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
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
          'DigiSessionID': digiSessionId.toString(),
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 202 || response.statusCode == 280) {
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        resetFieldsMileage();
        clearFormFieldsPerdiem();
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> reviewGendralExpense(
      context, bool action, int workitemrecid) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    print("receiptDate$attachmentPayload");
    print("finalItems${finalItems.length}");

    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "workitemrecid": workitemrecid,
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": firstNameController.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": '',
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

      "DocumentAttachment": {
        "File": attachmentPayload,
      },
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    final url = Uri.parse(
      '${Urls.reviewexpenseregistration}updateandaccept=$action&screen_name=MyPendingApproval',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
          'DigiSessionID': digiSessionId.toString(),
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 202 || response.statusCode == 280) {
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        resetFieldsMileage();
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<List<ExpenseHistory>> fetchExpenseHistory(int? recId) async {
    final response = await http.get(
      Uri.parse(
          '${Urls.getTrackingDetails}RefRecId__eq%3D$recId&page=1&sort_by=ModifiedBy&sort_order=desc'),
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpenseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expense history: ${response.statusCode}');
    }
  }

  Future<List<ExpenseHistory>> cashadvanceTracking(int? recId) async {
    final response = await http.get(
      Uri.parse(
          '${Urls.cashadvanceTracking}RefRecId__eq%3D$recId&page=1&page=1&sort_by=CreatedDatetime&sort_order=asc'),
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpenseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expense history: ${response.statusCode}');
    }
  }

  Future<List<File>> fetchExpenseDocImage([int? recId]) async {
    print("FileChecker:");
    imageFiles.value = [];
    final response = await http.get(
      Uri.parse('${Urls.getExpensImage}$recId'),
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

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
        isLoadingviewImage.value = false;
      }
      isLoadingviewImage.value = false;
      return imageFiles;
    } else {
      isLoadingviewImage.value = false;
      throw Exception(
          'Failed to load expense document images: ${response.statusCode}');
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
      List<File> imageFiles) async {
    isUploading.value = true;

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final base64Data = base64Encode(await file.readAsBytes());
        final fileName = p.basename(file.path);
        final mimeType = getMimeType(file);

        files.add({
          "index": i,
          "name": fileName,
          "type": mimeType,
          "base64Data": base64Data,
          "Hashmapkey": ""
        });
        print("FileChecker: $files");
      }
    } catch (e) {
      print("❌ Error while preparing attachments: $e");
    } finally {
      isUploading.value = false; // hide loader
    }

    return files;
  }

  void cashAdvanceReturnFinalItem(CashAdvanceRequestHeader expense) {
    final items = expense.cshCashAdvReqTrans.map((trans) {
      final taxGroupValue =
          (taxGroup.isNotEmpty) ? taxGroup.first.taxGroupId : '';
      print("&&&&&&${trans.description}");
      final newItem = CashAdvanceRequestItemize(
        recId: trans.recId,
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
        // lineAdvanceRequested: double.tryParse(paidAmount.text) ?? 0.0,
        lineRequestedAdvanceInReporting: trans.lineRequestedAdvanceInReporting,
        lineRequestedExchangerate: trans.estimatedExchangerate,
        lineEstimatedExchangerate: trans.lineEstimatedAmount,
        maxAllowedPercentage: trans.maxAllowedPercentage,
        baseUnit: trans.baseUnit,
        baseUnitRequested: trans.baseUnitRequested,
        expenseCategoryId: trans.expenseCategoryId,

        accountingDistributions: accountingDistributions.map((controller) {
          return AccountingDistribution(
              transAmount:
                  double.tryParse(controller?.transAmount.toString() ?? '') ??
                      0.0,
              reportAmount:
                  double.tryParse(controller?.reportAmount.toString() ?? '') ??
                      0.0,
              allocationFactor: controller?.allocationFactor ?? 0.0,
              dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
              currency: selectedCurrency.value?.code ?? "IND");
        }).toList(),
      );

      return newItem;
    }).toList();

    finalItemsCashAdvance.addAll(items);
  }

  void addToFinalItems(GESpeficExpense expense) {
    final items = expense.expenseTrans.map((trans) {
      final taxGroupValue =
          (trans.taxGroup != null && trans.taxGroup.toString().isNotEmpty)
              ? trans.taxGroup
              : null;
      print("&&&&&&${trans.recId}");
      return ExpenseItem(
        quantity: trans.quantity,
        recId: recID,
        expenseCategoryId: trans.expenseCategoryId,
        uomId: trans.uomId,
        unitPriceTrans: trans.unitPriceTrans,
        taxAmount: trans.taxAmount,
        taxGroup: taxGroupValue,
        lineAmountTrans: trans.lineAmountTrans,
        lineAmountReporting: trans.lineAmountReporting,
        projectId: trans.projectId,
        description: trans.description ?? '',
        isReimbursable: trans.isReimbursable,
        isBillable: trans.isBillable,
        accountingDistributions: trans.accountingDistributions,
      );
    }).toList();

    finalItems.addAll(items);
  }

  double getTotalLineAmount() {
    double total = 0.0;
    for (var section in itemizeSections) {
      double amount = double.tryParse(section.amount.toString()) ?? 0.0;
      total += amount;
    }
    return total;
  }

  Future<void> saveGeneralExpense(context, bool bool, bool? reSubmit) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    print("receiptDate$attachmentPayload");
    print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 0;
    print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": "",
      "EmployeeId": Params.employeeId,
      "EmployeeName": firstNameController.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": '',
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWith,
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting":
          amountINR.text.isNotEmpty ? double.tryParse(amountINR.text) ?? 0 : 0,

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate":
          unitRate.text.isNotEmpty ? double.tryParse(unitRate.text) ?? 1 : 1,
      "UserExchRate":
          unitRate.text.isNotEmpty ? double.tryParse(unitRate.text) ?? 1 : 1,

      "Source": "Web",
      if (!hasValidUnit) "IsBillable": isBillable.value,
      "ExpenseType": "General Expenses",
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
        'AccountingDistributions':
            accountingDistributions.map((e) => e?.toJson()).toList(),
      "DocumentAttachment": {
        "File": attachmentPayload,
      },
      if (hasValidUnit && finalItems.isNotEmpty)
        "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(
            '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=${reSubmit ?? false}&screen_name=MyExpenseSubmit=$bool&Resubmit=false&screen_name=MyExpense'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );
      print("requestBody$requestBody");
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
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      print("❌ Exception: $e");

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

  Future<void> createcashAdvanceReturn(
      context, bool bool, bool? reSubmit) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    print("cashAdvanceIds$cashAdvanceIds");
    print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 0;
    print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": "",
      "EmployeeId": Params.employeeId,
      "EmployeeName": firstNameController.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()
      "ReferenceNumber": referenceID.text,
      "PaymentMethod": paidWith,
      "TotalAmountTrans": paidAmount.text.isNotEmpty
          ? double.tryParse(paidAmount.text) ?? 0
          : 0,
      "TotalAmountReporting":
          amountINR.text.isNotEmpty ? double.tryParse(amountINR.text) ?? 0 : 0,

      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate":
          unitRate.text.isNotEmpty ? double.tryParse(unitRate.text) ?? 1 : 1,
      "UserExchRate":
          unitRate.text.isNotEmpty ? double.tryParse(unitRate.text) ?? 1 : 1,

      "Source": "Web",
      if (!hasValidUnit) "IsBillable": isBillable.value,
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
        'AccountingDistributions':
            accountingDistributions.map((e) => e?.toJson()).toList(),
      "DocumentAttachment": {
        "File": attachmentPayload,
      },
      if (hasValidUnit && finalItems.isNotEmpty)
        "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(
            '${Urls.cashadvancerequisitions}&Submit=$bool&Resubmit=${reSubmit ?? false}&screen_name=MyExpense'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );
      print("requestBody$requestBody");
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
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  CashAdvanceRequestItemizeFornew toCashAdvanceRequestItemize() {
    return CashAdvanceRequestItemizeFornew(
      expenseCategoryId: selectedCategoryId ?? '',
      quantity: (double.tryParse(quantity.text) ?? 0).toInt(),
      uomId: selectedunit?.code ?? '',
      unitEstimatedAmount: double.tryParse(paidAmountCA1.text) ?? 1,
      taxAmount: double.tryParse(taxAmount.text) ?? 1,
      taxGroup: selectedTax?.taxGroupId,
      lineEstimatedAmount: double.tryParse(estimatedamountINR.text) ?? 1,
      lineEstimatedAmountInReporting:
          double.tryParse(estimatedamountINR.text) ?? 1,
      projectId: selectedProject?.code,
      description: descriptionController.text,
      isReimbursable: isReimbursite,
      isBillable: isBillableCreate,
      baseUnit: (double.tryParse(unitRateCA1.text) ?? 1).toInt(),

      baseUnitRequested: (double.tryParse(unitRateCA2.text) ?? 1).toInt(),

      createdBy: Params.userId ?? '',
      createdDatetime: DateTime.now().millisecondsSinceEpoch,
      // maxAllowedPercentage: 100,
      // percentage: int.tryParse(requestedPercentage.text) ?? 100,
      // percentage: 100,

      location: selectedLocation!.city,
      requestDate: DateTime.now().millisecondsSinceEpoch,
      employeeId: Params.employeeId ?? '',
      estimatedCurrency: selectedCurrency.value?.code ?? "INR",
      // estimatedExchangerate: selectedExchangeRate ?? 1.0,
      exchRate: double.tryParse(quantity.text) ?? 1,
      // paymentMethodId: paymentMethodId?.'',
      // paymentMethodName: selectedPaymentMethod?.paymentMethodName ?? '',
      userExchRate: double.tryParse(quantity.text) ?? 1,

      totalEstimatedAmount: double.tryParse(paidAmountCA1.text) ?? 0.0,
      totalEstimatedAmountInReporting:
          double.tryParse(paidAmountCA1.text) ?? 0.0,
      totalRequestedAmount: double.tryParse(totalRequestedAmount.text) ?? 0.0,
      totalRequestedAmountInReporting:
          double.tryParse(totalRequestedAmount.text) ?? 0.0,
      lineAdvanceRequested: double.tryParse(totalRequestedAmount.text) ?? 0.0,
      lineRequestedAdvanceInReporting:
          double.tryParse(totalRequestedAmount.text) ?? 0.0,
      lineRequestedCurrency: currencyDropDowncontrollerCA3.text ?? "",
      lineRequestedExchangerate: double.tryParse(unitRateCA1.text) ?? 0.0,
      maxAllowedPercentage:
          (double.tryParse(requestedPercentage.text) ?? 1).toInt(),
      percentage: (double.tryParse(requestedPercentage.text) ?? 1).toInt(),
      // // ✅ Business Justification
      // businessJustification: BusinessJustification(
      //   id: selectedBusinessJustification?.id ?? '',
      //   name: selectedBusinessJustification?.name ?? '',
      //   applicability: selectedBusinessJustification?.applicability ?? '',
      //   description: selectedBusinessJustification?.description ?? '',
      // ),

      // prefferedPaymentMethod: PrefferedPaymentMethod(
      //   paymentMethodId: selectedPaymentMethod?.paymentMethodId ?? '',
      //   paymentMethodName: selectedPaymentMethod?.paymentMethodName ?? '',
      //   isSelected: selectedPaymentMethod?.isSelected ?? false,
      // ),

      // ✅ CSH Header Category Custom Field Values
      // cshHeaderCategoryCustomFieldValues: cshCategoryFields.map((field) {
      //   return CustomFieldValue(
      //     customFieldEntity: field.customFieldEntity,
      //     fieldId: field.fieldId,
      //     fieldValue: field.fieldValue,
      //     fieldName: field.fieldName,
      //   );
      // }).toList(),

      // // ✅ CSH Header Custom Field Values
      // cshHeaderCustomFieldValues: cshHeaderCustomFields.map((field) {
      //   return CustomFieldValue(
      //     customFieldEntity: field.customFieldEntity,
      //     fieldId: field.fieldId,
      //     fieldValue: field.fieldValue,
      //     fieldName: field.fieldName,
      //   );
      // }).toList(),

      // ✅ Accounting Distributions
      accountingDistributions: accountingDistributions.map((controller) {
        return AccountingDistribution(
          transAmount:
              double.tryParse(controller?.transAmount.toString() ?? '') ?? 0.0,
          reportAmount:
              double.tryParse(controller?.reportAmount.toString() ?? '') ?? 0.0,
          allocationFactor: controller?.allocationFactor ?? 0.0,
          dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
          currency: selectedCurrency.value?.code ?? "INR",
        );
      }).toList(),

      // // ✅ Document Attachments
      // documentAttachment: attachedDocuments.map((doc) {
      //   return DocumentAttachment(
      //     fileName: doc.fileName,
      //     fileType: doc.fileType,
      //     fileUrl: doc.fileUrl,
      //     uploadedDatetime: doc.uploadedDatetime,
      //     uploadedBy: currentUserEmail ?? '',
      //   );
      // }).toList(),

      // cashAdvTrans: cashAdvanceTransactions,
    );
  }

  Future<void> saveCashAdvance(
      BuildContext context, bool submit, bool? reSubmit, int? recId,
      [String? reqID]) async {
    try {
      print("cashAdvTransPayload");
      // Format the request date
      final formattedDate =
          DateFormat('dd/MM/yyyy').format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      print("cashAdvTransPayload2");
      // Build attachments
      // final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload =
          finalItemsCashAdvanceNew.map((item) => item.toJson()).toList();
      print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequestDate": requestDate,
        "EmployeeId": Params.employeeId,
        "EmployeeName": Params.userName,
        "TotalRequestedAmountInReporting": requestamountINR.text.isNotEmpty
            ? double.tryParse(requestamountINR.text) ?? 0
            : 0,
        "TotalEstimatedAmountInReporting": estimatedamountINR.text.isNotEmpty
            ? double.tryParse(estimatedamountINR.text) ?? 0
            : 0,
        "PrefferedPaymentMethod": paidWithController.text,
        "BusinessJustification": justificationController.text,
        "ReferenceId": referenceID.text.trim(),
        "RequisitionId": expenseIdController.text,
        "CashAdvTrans": cashAdvTransPayload,
        "CSHHeaderCustomFieldValues": [],
        "DocumentAttachment": {"File": []},
      };

      print("🔗 API Request Body: $requestBody");

      // API call
      final response = await http.post(
        Uri.parse(
            "https://api.digixpense.com/api/v1/cashadvancerequisition/cashadvanceregistration/registercashadvance?functionalentity=CashAdvanceRequisition&submit=$submit&resubmit=${reSubmit ?? false}&screen_name=MyCshAdv"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );

      print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];

        clearFormFields();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);

        Fluttertoast.showToast(
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
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
  }

  Future<void> saveinEditCashAdvance(
      BuildContext context, bool submit, bool? reSubmit, int? recId,
      [String? reqID]) async {
    try {
      print("cashAdvTransPayload");
      // Format the request date
      final formattedDate =
          DateFormat('dd/MM/yyyy').format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      print("cashAdvTransPayload2");
      // Build attachments
      // final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload =
          finalItemsCashAdvance.map((item) => item.toJson()).toList();
      print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequisitionId": reqID ?? "",
        "RecId": recId ?? "",
        "RequestDate": requestDate,
        "EmployeeId": Params.employeeId,
        "EmployeeName": Params.userName,
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
        "DocumentAttachment": {"File": []},
      };

      print("🔗 API Request Body: $requestBody");

      // API call
      final response = await http.post(
        Uri.parse(
            "${Urls.cashadvanceregistration}registercashadvance?functionalentity=CashAdvanceRequisition&submit=$submit&resubmit=${reSubmit ?? false}&screen_name=MyCshAdv"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );

      print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];

        clearFormFields();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);

        Fluttertoast.showToast(
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        finalItemsCashAdvance = [];
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
      finalItemsCashAdvance = [];
    }
  }

  Future<void> reviewandUpdateCashAdvance(
      BuildContext context, bool submit, int? recId,
      [String? reqID]) async {
    try {
      print("cashAdvTransPayload");
      // Format the request date
      final formattedDate =
          DateFormat('dd/MM/yyyy').format(selectedDate ?? DateTime.now());
      final parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
      final requestDate = parsedDate.millisecondsSinceEpoch;
      print("cashAdvTransPayload2");
      // Build attachments
      // final attachmentPayload = await buildDocumentAttachment(imageFiles);

      // Build CashAdvTrans items
      final cashAdvTransPayload =
          finalItemsCashAdvance.map((item) => item.toJson()).toList();
      print("cashAdvTransPayload$cashAdvTransPayload");

      // Construct request body
      final Map<String, dynamic> requestBody = {
        "RequisitionId": reqID ?? "",
        "RecId": recId ?? "",
        "RequestDate": requestDate,
        "EmployeeId": Params.employeeId,
        "EmployeeName": Params.userName,
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
        "DocumentAttachment": {"File": []},
      };

      print("🔗 API Request Body: $requestBody");

      // API call
      final response = await http.put(
        Uri.parse(
            "${Urls.cashadvanceregistration}reviewcashadvancerequisition?updateandaccept=$submit&screen_name=MyPendingApproval"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );

      print("📥 API Response: ${response.statusCode} ${response.body}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 280) {
        final data = jsonDecode(response.body);
        final message = data['detail']['message'] ?? 'Cash advance created';
        final recId = data['detail']['RecId'];

        clearFormFields();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);

        Fluttertoast.showToast(
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        finalItemsCashAdvance = [];
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
      finalItemsCashAdvance = [];
    }
  }

  Future<void> saveinviewPageGeneralExpense(
      context, bool bool, bool? reSubmit, int recId) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    print("receiptDate$attachmentPayload");
    print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": firstNameController.text.trim(),
      "MerchantName": isManualEntryMerchant
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntryMerchant ? null : selectedPaidto?.merchantId,
      "ReferenceNumber": referenceID.text,
      "CashAdvReqId": '',
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paymentMethodID,
      "TotalAmountTrans": paidAmount.text.isNotEmpty ? paidAmount.text : 0,
      "TotalAmountReporting": amountINR.text.isNotEmpty ? amountINR.text : 0,
      if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": unitRate.text.isNotEmpty ? unitRate.text : '1.0',
      "UserExchRate": unitRate.text.isNotEmpty ? unitRate.text : '1.0',
      "Source": "Web",
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
      "DocumentAttachment": {
        "File": attachmentPayload,
      },
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(
            '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=$reSubmit&screen_name=MyExpenseSubmit=$bool&Resubmit=$reSubmit&screen_name=MyExpense'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );
      print("requestBody$requestBody");
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
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        finalItems.clear();

        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      print("❌ Exception: $e");

      if (!bool) {
        isUploading.value = false;
      } else {
        isGESubmitBTNLoading.value = false;
      }
    }
  }

  Future<void> editAndUpdateCashAdvance(
      context, bool bool, bool? reSubmit, int recId) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    print("receiptDate$attachmentPayload");
    print("finalItems${finalItems.length}");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = (double.tryParse(unitAmount.text) ?? 0) > 1;

    print("hasValidUnit$hasValidUnit${unitAmountView.text}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseID,
      "RecId": recID,
      "EmployeeId": Params.employeeId,
      "EmployeeName": Params.employeeName,
      "PaymentMethod": paidWithController.text,
      "ReferenceNumber": referenceID.text,
      "CashAdvReqId": cashAdvanceIds.text,
      "Location": "", // or locationController.text.trim()

      "TotalAmountTrans": double.tryParse(paidAmount.text) ?? 0,
      "TotalAmountReporting": double.tryParse(amountINR.text) ?? 0,
      // if (!hasValidUnit) "IsReimbursable": isReimbursiteCreate.value,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": double.tryParse(unitRate.text) ?? 0,
      "UserExchRate": double.tryParse(unitRate.text) ?? 0,
      "Source": "Web",

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
      "DocumentAttachment": {
        "File": attachmentPayload,
      },
      // if (hasValidUnit && finalItems.isNotEmpty)
      "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };
    print(jsonEncode(requestBody));
    try {
      final response = await http.post(
        Uri.parse(
            '${Urls.cashadvancerequisitions}&submit=$bool&resubmit=$reSubmit&screen_name=MyExpense'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(requestBody),
      );
      print("requestBody$requestBody");
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
          msg: "$message (RecId: $recId)",
          backgroundColor: Colors.green[100],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.green[800],
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        finalItems.clear();

        if (!bool) {
          isUploading.value = false;
        } else {
          isGESubmitBTNLoading.value = false;
        }
      }
    } catch (e) {
      print("❌ Exception: $e");

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
  //   print("hasValidUnit$hasValidUnit${selectedunit?.code}");

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
  //     final response = await http.post(
  //       Uri.parse(
  //           '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=false&screen_name=MyExpense'),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer ${Params.userToken}",
  //         'DigiSessionID': digiSessionIdNew,
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //     print("requestBody$requestBody");
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
  //         msg: "$message (RecId: $recId)",
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: "Error: ${response.body}",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         backgroundColor: const Color.fromARGB(255, 250, 1, 1),
  //         textColor: const Color.fromARGB(255, 212, 210, 241),
  //         fontSize: 16.0,
  //       );
  //       print("❌ Error: ${response.body}");
  //       if (!bool) {
  //         isUploading.value = false;
  //       } else {
  //         isGESubmitBTNLoading.value = false;
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Exception: $e");

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
    print("calculatedLineAmount$qty,$unit 2233");
    lineAmount.text = calculatedLineAmount.toStringAsFixed(2);
    lineAmountINR.text = calculatedLineAmount.toStringAsFixed(2);
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
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        getAllListGExpense.value =
            (data as List).map((item) => GExpense.fromJson(item)).toList();

        isLoadingGE1.value = false;
        print("Fetched Expenses: $getAllListGExpense");

        return getAllListGExpense;
      } else {
        print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }
 Future<List<GExpense>> fetchUnprocessExpense() async {
    isLoadingGE1.value = true;
    final url = Uri.parse('${Urls.unProcessedList}${Params.userId}&page=1&sort_order=asc');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        getAllListGExpense.value =
            (data as List).map((item) => GExpense.fromJson(item)).toList();

        isLoadingGE1.value = false;
        print("Fetched Expenses: $getAllListGExpense");

        return getAllListGExpense;
      } else {
        print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
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
          "EXPExpenseHeader.ApprovalStatus__eq=$filterStatus");
      filterQuery = "filter_query=$encodedQuery";
    }

    final String fullUrl = "$baseBaseUrl$filterQuery$commonParams";
    final url = Uri.parse(fullUrl);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        getAllListGExpense.value =
            (data as List).map((item) => GExpense.fromJson(item)).toList();

        print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return getAllListGExpense;
      } else {
        print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      print('❌ Error fetching expenses: $e');
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
          "CSHCashAdvReqHeader.ApprovalStatus__eq=$filterStatus");
      filterQuery = "filter_query=$encodedQuery";
    }

    final String fullUrl = "$baseBaseUrl$filterQuery$commonParams";
    final url = Uri.parse(fullUrl);

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        getAllListCashAdvanseMyteams.value =
            (data as List).map((item) => CashAdvanceRequestHeader.fromJson(item)).toList();

        print("✅ Fetched Expenses: $getAllListGExpense");
        isLoadingGE1.value = false;
        return getAllListCashAdvanseMyteams;
      } else {
        print('❌ Failed to load expenses. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      print('❌ Error fetching expenses: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<List<ExpenseModel>> fetchPendingApprovals() async {
    isLoadingGE1.value = true;

    try {
      final response = await http.get(
        Uri.parse(Urls.pendingApprovals),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        },
      );
      // final streamed = await request.send();
      // final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        pendingApprovals.clear();
        pendingApprovals.value =
            (data).map((item) => ExpenseModel.fromJson(item)).toList();

        isLoadingGE1.value = false;
        print("Fetched pendingApprovals: $pendingApprovals");

        return pendingApprovals;
      } else {
        print(
            '❌ Failed to load pendingApprovals. Status code: ${response.statusCode}');
        isLoadingGE1.value = false;
        return [];
      }
    } catch (e) {
      print('❌ Error fetching pendingApprovals: $e');
      isLoadingGE1.value = false;
      return [];
    }
  }

  Future<List<ExpenseModel>> fetchExpenses(String token) async {
    // const String url = 'https://yourapi.com/expenses'; // Replace with your API URL

    final response = await http.get(
      Uri.parse(Urls.pendingApprovals),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

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
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isLoadingGE1.value = false;

        paymentMethods.value = (data as List)
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();

        print(
            "paymentMethods: ${paymentMethods.map((e) => e.paymentMethodName).toList()}");

        return paymentMethods;
      } else {
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      return [];
    }
  }

  int parseDateToEpoch(String formattedDate) {
    final date = DateFormat('dd-MMM-yyyy').parse(formattedDate);
    return date.millisecondsSinceEpoch;
  }

  Future<List<AllocationLine>> fetchPerDiemRates() async {
    isLoadingGE1.value = true;

    try {
      final fromDate = parseDateToEpoch(fromDateController.text);
      final toDate = parseDateToEpoch(toDateController.text);
      final location = selectedLocation?.location ?? '';
      final employeeId = Params.employeeId;
      final token = Params.userToken ?? '';

      final url = Uri.parse(
        '${Urls.perDiemFetchRate}$fromDate&Todate=$toDate&Location=$location&EmployeeId=$employeeId',
      );

      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final decodeData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final parsedResponse = PerDiemResponseModel.fromJson(body);
        isLoadingGE1.value = false;

        perdiemResponse.value = parsedResponse;
        perDiem.value = true;
        allocationLines = parsedResponse.allocationLines ?? [];
        print("allocationLinesData$allocationLines");
        daysController.text = parsedResponse.totalDays.toString();
        amountInController.text =
            parsedResponse.totalAmountTrans.toStringAsFixed(2);
        perDiemController.text = parsedResponse.perdiemId.toString();

        return allocationLines;
      } else if (response.statusCode == 404) {
        // Fluttertoast.showToast(
        //   msg: decodeData["detail"]["message"] ?? "Per Diem data not found",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    } finally {
      isLoadingGE1.value = false;
    }
  }

  void clearFormFieldsPerdiem() {
    // Clear text controllers
    multiSelectedItems.value = [];
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
    perDiemController.clear();
    locationController.clear();
    mileageVehicleID.clear();
    mileageVehicleName.clear();
    totalDistanceKm = 0;
    calculatedAmountINR = 0;
    // isRoundTrip = false;
    // projectIdController.clear();
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

    print("All form fields cleared.");
  }

  Future<void> deleteExpense(int recId) async {
    final String token = Params.userToken ?? ''; // get your bearer token safely

    final Uri url = Uri.parse(
      '${Urls.deleteExpense}$recId&screen_name=MyExpense',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchGetallGExpense();
        print('✅ Expense deleted successfully');
      } else {
        print('❌ Failed to delete expense: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error deleting expense: $e');
    }
  }

  Future<void> updatePerDiemDetails(
      context, bool bool, bool resubmit, int? recIds,
      [String? expenseID]) async {
    Map<String, dynamic> buildPayload() {
      return {
        "ExpenseId": expenseID ?? '',
        // ignore: prefer_null_aware_operators
        "ProjectId": selectedProject != null ? selectedProject?.code : null,
        "TotalAmountTrans": amountInController.text.isNotEmpty
            ? double.parse(amountInController.text)
            : 0.0,
        "TotalAmountReporting": amountInController.text.isNotEmpty
            ? double.parse(amountInController.text)
            : 0.0,

        "EmployeeId": Params.employeeId ?? '',
        "EmployeeName":
            firstNameController.text.isNotEmpty ? firstNameController.text : '',
        "ReceiptDate": toDateController.text.isNotEmpty
            ? parseDateToEpoch(toDateController.text)
            : null,
        "Currency": "INR",
        "Description":
            purposeController.text.isNotEmpty ? purposeController.text : '',
        "Source": "Web",
        "ExchRate": 1,
        "RecId": recIds,
        "ExpenseType": "PerDiem",
        "Location": selectedLocation?.location ?? '',
        "CashAdvReqId": "",
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
      final response = await http.post(
        Uri.parse(
            '${Urls.perDiemRegistration}&Submit=$bool&Resubmit=$resubmit&screen_name=PerDiemRegistration'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
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
          msg: "Success: ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error:  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<void> perdiemApprovalReview(context, bool bool, int? workitemrecid,
      String? recId, String expenseID) async {
    // buttonLoader.value = true;
    // isUploading.value = true;
    print(recId);
    Map<String, dynamic> buildPayload() {
      return {
        "ExpenseId": expenseID ?? '',
        "RecId": recId,
        "ProjectId": selectedProject != null ? selectedProject?.code : null,
        "TotalAmountTrans":
            amountInController.text.isNotEmpty ? amountInController.text : '0',
        "TotalAmountReporting":
            amountInController.text.isNotEmpty ? amountInController.text : '0',
        "EmployeeId": Params.employeeId ?? '',
        "EmployeeName":
            firstNameController.text.isNotEmpty ? firstNameController.text : '',
        "ReceiptDate": fromDateController.text.isNotEmpty
            ? parseDateToEpoch(fromDateController.text)
            : null,
        "Currency": "INR",
        "Description":
            purposeController.text.isNotEmpty ? purposeController.text : '',
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseType": "PerDiem",
        "Location": selectedLocation?.location ?? '',
        "CashAdvReqId": "",
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
      final response = await http.put(
        Uri.parse(
            '${Urls.approvalPerdiemreview}updateandaccept=$bool&screen_name=MyPendingApproval'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
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
          msg: "Success: ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 88, 1, 250),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error:  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 250, 1, 1),
          textColor: const Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.body}");
        buttonLoader.value = false;
        isUploading.value = false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      buttonLoader.value = false;
    }
  }

  Future<List<PerdiemResponseModel>> fetchSecificPerDiemItem(
      context, int recId, bool readOnly) async {
    isLoadingGE1.value = true;
    final url = Uri.parse('${Urls.getSpecificPerdiemExpense}$recId');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
        // print("Perdiem ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.perDiem,
          arguments: {'item': specificPerdiemList[0], 'readOnly': readOnly},
        );
        return specificPerdiemList;
      } else {
        isLoadingGE1.value = false;
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<List<PerdiemResponseModel>> fetchSecificPerDiemItemApproval(
      context, int recId) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
        '${Urls.getSpecificPerdiemExpenseApproval}workitemrecid=$recId&lock_id=$recId&screen_name=MyPendingApproval');

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
        // print("Perdiem ID: ${expenseIdController.text}");
        isLoadingGE1.value = false;
        Navigator.pushNamed(
          context,
          AppRoutes.perDiem,
          arguments: {
            'item': specificPerdiemList[0],
          },
        );
        return specificPerdiemList;
      } else {
        isLoadingGE1.value = false;
        print(
            'Failed to load payment methods. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      isLoadingGE1.value = false;

      return [];
    }
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      // Make API call
      final response = await http.get(
        Uri.parse('${Urls.getNotifications}${Params.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        // Map JSON to NotificationModel
        notifications.value =
            data.map((e) => NotificationModel.fromJson(e)).toList();

        // Filter unread notifications
        unreadNotifications.value =
            notifications.where((n) => !n.read).toList();
        unreadCount.value = unreadNotifications.length;
        print("unreadNotifications.value${unreadCount.value}");
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(NotificationModel notification) {
    notification.read = true;
    unreadNotifications.removeWhere((n) => n.recId == notification.recId);
    unreadNotifications.refresh();
    notifications.refresh();
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    const apiKey = "AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0";
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:in';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("LocationDropDown$data");
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

      print(
          '📍 Current Position: Lat=${position.latitude}, Lng=${position.longitude}');

      // _currentLatLng = LatLng(position.latitude, position.longitude);
    } else {
      print('❌ Location permission not granted');
    }
  }

  Future<void> cancelExpense(BuildContext context, String contextRecId) async {
    // Static values
    const String screenName = "MyExpense";
    const String functionalEntity = "ExpenseRequisition";

    final String apiUrl =
        '${Urls.cancelApprovals}context_recid=$contextRecId&screen_name=$screenName&functionalentity=$functionalEntity';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}', // API Token in header
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        clearFormFieldsPerdiem();
        clearFormFields();
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.generalExpense);
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
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
    print("fetchExpenseCategory${selectedProject?.code}");
    print("fetchExpenseCategory$selectedDateMileage");
    isLoading.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    try {
      final response = await http.get(
        Uri.parse(
            '${Urls.empmileagevehicledetails}${Params.employeeId}&ReceiptDate=$fromDate'),
        headers: {
          "Authorization": 'Bearer ${Params.userToken ?? ''}',
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        isLoadingGE2.value = false;

        final data = jsonDecode(response.body);

        vehicleTypes =
            (data as List).map((item) => VehicleType.fromJson(item)).toList();

        // selectedVehicleType = vehicleTypes.first;

        debugPrint(
            "Vehicle Types: ${vehicleTypes.map((v) => v.name).toList()}");
        isLoadingGE2.value = false;
      } else {
        debugPrint("API Error: ${response.statusCode}");
        isLoadingGE2.value = false;
      }
    } catch (e) {
      debugPrint("API Error: $e");
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

    debugPrint("Selected Vehicle: ${selectedVehicleType!.name}");
    debugPrint("Rate per KM: $ratePerKm");
    debugPrint("Total Distance: $totalDistanceKm");
    debugPrint("Amount (INR): $calculatedAmountINR");
    debugPrint("Amount (USD): $calculatedAmountUSD");
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

  Future<void> submitMileageExpense(context, bool bool, bool submit, int? recId,
      [String? expenseId]) async {
    try {
      // Build ExpenseTrans payload
      final expenseTranArray = buildExpenseTrans();
      Map<String, dynamic> expenseTransMap = {};
      for (int i = 0; i < expenseTranArray.length; i++) {
        expenseTransMap[i.toString()] = expenseTranArray[i];
      }
      // Prepare main payload
      final payload = {
        "TotalAmountTrans": calculatedAmountINR,
        "TotalAmountReporting": calculatedAmountINR,
        "EmployeeId": Params.employeeId,
        "EmployeeName": Params.employeeName,
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
        "CashAdvReqId": "",
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions": [],
        "ExpenseTrans": expenseTransMap,
        "ProjectId": projectIdController.text,
      };

      // Print payload for debugging
      print(jsonEncode(payload));

      // Send POST API request
      final response = await http.post(
        Uri.parse(
            '${Urls.mileageregistration}Submit=$bool&Resubmit=$submit&screen_name=MileageRegistration'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Params.userToken}",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 208 ||
          response.statusCode == 280) {
        resetFieldsMileage();
        clearFormFieldsPerdiem();
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[100],
          textColor: Colors.green[800],
        );
        Navigator.pushNamed(context, AppRoutes.generalExpense);
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
        expenseTrans = [];
        expenseTrans.clear();
        // print("Error: ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception during API call: $e");
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
    print("receiptDate$receiptDate");
    final url =
        Uri.parse('${Urls.getCustomField}=PerDiem&Fromdate=$receiptDate');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${Params.userToken}",
        "Content-Type": "application/json",
      },
    );

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

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DimensionHierarchy.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dimension hierarchies');
    }
  }

  Future<List<DimensionValue>> fetchDimensionValues() async {
    final url = Uri.parse(Urls.getdimensionsDropdownValue);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
        'DigiSessionID': digiSessionId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DimensionValue.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dimension values');
    }
  }

  Future<void> fetchChartData() async {
    final int endDate = DateTime.now().millisecondsSinceEpoch;
    isUploadingCards.value = true;
    final response = await http.get(
      Uri.parse(
          '${Urls.cashAdvanceChart}$endDate&periods=5&period_type=Weekly&page=1&limit=10&sort_by=YAxis&sort_order=asc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken}', // 👈 Pass token
      },
    );

    if (response.statusCode == 200) {
      isUploadingCards.value = false;
      final jsonResponse = json.decode(response.body);
      final xAxis = List<String>.from(jsonResponse['XAxis']);
      final yAxis = List<double>.from(
          jsonResponse['YAxis'].map((e) => (e ?? 0).toDouble())); // Null safety

      chartData = List.generate(
        xAxis.length,
        (index) => ProjectData(xAxis[index], yAxis[index]),
      );
      isUploadingCards.value = false;
      print('chartData$chartData');
      // isLoading = false;
    } else {
      // Handle error
      isUploadingCards.value = false;
      // isLoading = false;

      print('Error: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> fetchAndReplaceValue() async {
    isUploadingCards.value = true;
    final int endDate = DateTime.now().millisecondsSinceEpoch;
    final int startDate = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;

    final String apiUrl = '${Urls.expenseChart}'
        '?role=Spender'
        '&start_date=$startDate'
        '&end_date=$endDate'
        '&page=1'
        '&limit=10'
        '&sort_by=Value'
        '&sort_order=asc';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${Params.userToken}', // 👈 Pass your token here
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['Value'] != null) {
        expenseChartvalue = (jsonData['Value'] as num).toDouble();

        print("Value $expenseChartvalue  API response");
        isUploadingCards.value = false;
      } else {
        print("Value not found in API response");
        isUploadingCards.value = false;
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchExpensesByProjects() async {
    try {
      isUploadingCards.value = true;

      const String apiUrl = '${Urls.projectExpenseChart}'
          '?role=Spender&page=1&limit=10&sort_by=y&sort_order=asc';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}', // Pass your token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final expenses =
            jsonData.map((item) => ProjectExpense.fromJson(item)).toList();

        projectExpenses.value = expenses;
        isUploadingCards.value = false;
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch data: ${response.statusCode}",
        );
        isUploadingCards.value = false;
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Something went wrong!");
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchExpensesByCategory() async {
    try {
      isUploadingCards.value = true;

      final response = await http.get(
        Uri.parse(
            'https://api.digixpense.com/api/v1/dashboard/widgets/ExpensesByCategories?role=Spender&page=1&limit=10&sort_by=YAxis&sort_order=asc'),
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
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
          expenses.add(ProjectExpensebycategory(
              x: categories[i], y: total, color: getRandomMildColor()));
        }

        projectExpensesbyCategory.assignAll(expenses);
        isUploadingCards.value = false;
      } else {
        Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}');
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
      final response = await http.get(
        Uri.parse(
          'https://api.digixpense.com/api/v1/dashboard/widgets/ExpenseAmountByExpenseStatus?role=Spender&page=1&limit=10&sort_by=YAxis&sort_order=asc',
        ),
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<String> xAxis = List<String>.from(jsonResponse['XAxis']);
        List<double> yAxis =
            List<double>.from(jsonResponse['YAxis'].map((e) => e.toDouble()));

        final data = List.generate(
          xAxis.length,
          (index) => ExpenseAmountByStatus.fromJson(xAxis[index], yAxis[index]),
        );

        expensesByStatus.assignAll(data);
        isUploadingCards.value = false;
      } else {
        Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}');
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

      final response = await http.get(
        Uri.parse(
            'https://api.digixpense.com/api/v1/dashboard/dashboard/manageexpenses?employeeid=${Params.employeeId}'),
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
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
            'Error', 'Failed to fetch summary: ${response.statusCode}');
        isUploadingCards.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
      isUploadingCards.value = false;
    } finally {
      isUploadingCards.value = false;
    }
  }

  Future<void> fetchUsers() async {
    final rawUrl = "${Urls.esCalateUserList}${Params.userId}"
        "&page=1"
        "&sort_order=asc"
        "&choosen_fields=UserName%2CUserId";

    try {
      final uri = Uri.parse(rawUrl); // ✅ convert String to Uri

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        print("Fetched users: $usersJson");
        userList.value = usersJson.map((json) => User.fromJson(json)).toList();

        print("Fetched users: ${userList.map((u) => u.userName).toList()}");

        // Optional: set default selected user
        if (userList.isNotEmpty) {
          selectedUser.value = userList.first;
          userIdController.text = userList.first.userId;
        }
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<List<CashAdvanceReqModel>> fetchCashAdvanceRequests() async {
    final dateToUse = selectedDate ?? DateTime.now();

    isUploadingCards.value = true;
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);
    String url = "${Urls.cashAdvanceList}"
        "?employee_id=${Params.employeeId}&ProjectId=${projectIdController.text}&Location=&ExpenseCategoryId=$selectedCategoryId&PaymentMethod=$paymentMethodID&Currency=INR&ReceiptDate=$fromDate";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      isUploadingCards.value = false;
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CashAdvanceReqModel.fromJson(json)).toList();
    } else {
      isUploadingCards.value = false;

      throw Exception('Failed to load Cash Advance Requests');
    }
  }

  Future<void> fetchManageExpensesCards() async {
    print("Calling fetchManageExpensesCards...");
    try {
      isUploadingCards.value = true;

      final response = await http.get(
        Uri.parse(
            'https://api.digixpense.com/api/v1/expenseregistration/expenseregistration/analytics'),
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("API response: $data");

        // Clear the existing cards
        manageExpensesCards.clear();

        // Iterate over the response and map data to your model
        for (var item in data) {
          if (item.containsKey('PendingAmount')) {
            manageExpensesCards.add(
              ManageExpensesCard(
                status: 'Inprogress', // Label as "Expenses In Progress (Total)"
                amount: item['PendingAmount']?.toDouble() ?? 0.0,
              ),
            );
          } else if (item.containsKey('ApprovedAmount')) {
            manageExpensesCards.add(
              ManageExpensesCard(
                status:
                    'TotalAmountReporting', // Label as "Approved Expenses (Total)"
                amount: item['ApprovedAmount']?.toDouble() ?? 0.0,
              ),
            );
          } else if (item.containsKey('AllAmount')) {
            manageExpensesCards.add(
              ManageExpensesCard(
                status: 'AmountSettled', // Label as "All Expenses (Total)"
                amount: item['AllAmount']?.toDouble() ?? 0.0,
              ),
            );
          }
        }

        print("manageExpensesCards: $manageExpensesCards");
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
    print("cashAdvanceList");
    try {
      isUploadingCards.value = true;

      final response = await http.get(
        Uri.parse(
          'https://api.digixpense.com/api/v1/cashadvancerequisition/cashadvanceregistration/getcashadvanceheader?filter_query=CSHCashAdvReqHeader.CreatedBy__eq%3D${Params.userId}&page=1&sort_by=ModifiedDatetime&sort_order=desc',
        ),
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("cashAdvanceList$data");

        cashAdvanceList.value = (data as List)
            .map((item) => CashAdvanceModel.fromJson(item))
            .toList();

        print("cashAdvanceList$cashAdvanceList");
        isUploadingCards.value = false;
      } else {
        Get.snackbar(
            'Error', 'Failed to fetch expense cards: ${response.statusCode}');
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
    print("Fetching Expense List...");
    try {
      // Start loader
      isUploadingCards.value = true;

      final response = await http.get(
        Uri.parse(
          'https://api.digixpense.com/api/v1/expenseregistration/expenseregistration/expenseheader?filter_query=EXPExpenseHeader.CreatedBy__eq%3D${Params.userId}&page=1&limit=5&sort_by=ModifiedDatetime&sort_order=desc',
        ),
        headers: {
          'Authorization': 'Bearer ${Params.userToken}',
          'Content-Type': 'application/json',
        },
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Ensure API returned a list
        if (decodedData is List && decodedData.isNotEmpty) {
          final expenses = decodedData
              .map((item) => ExpenseListModel.fromJson(item))
              .toList();

          // Assign to observable list
          expenseList.assignAll(expenses);

          print("✅ Expense list updated with ${expenseList.length} items");
        } else {
          print("⚠️ API returned an empty or unexpected data format");
          Get.snackbar('Info', 'No expense records found.');
        }
      } else {
        print("❌ API Error: ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Failed to fetch expenses. Status Code: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print("❌ Exception in getExpenseList: $e");
      print(stackTrace);
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
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          cashAdvanceListDashboard.value = data
              .map((item) => CashAdvanceRequisition.fromJson(item))
              .toList();
        } else {
          print('⚠️ Unexpected data format: expected a List');
          cashAdvanceList.clear();
        }

        print("✅ Fetched Cash Advances: ${cashAdvanceListDashboard.length}");
        isLoadingCA.value = false;
        return cashAdvanceListDashboard.toList();
      } else {
        print(
            '❌ Failed to load cash advances. Status: ${response.statusCode}, Body: ${response.body}');
        isLoadingCA.value = false;
        return [];
      }
    } catch (e) {
      print('❌ Error fetching cash advance requisitions: $e');
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
        ' https://api.digixpense.com/api/v1/cashadvancerequisition/cashadvanceregistration/deletecashadvance '
        '?RecId=$recId&screen_name=MyCashAdvance',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${Params.userToken ?? ""}',
          'Content-Type': 'application/json',
        },
      );

      isDeleting.value = false;

      if (response.statusCode == 200) {
        // Successfully deleted on server
        final responseData = jsonDecode(response.body);

        // Optional: Check success flag from body
        final success = responseData['success'] as bool? ?? false;
        if (success || responseData['message']?.contains('success') == true) {
          // Remove locally
          cashAdvanceList.removeWhere((item) => item.recId == recId);
          Get.snackbar("Success", "Cash advance deleted successfully",
              backgroundColor: Colors.green, colorText: Colors.white);
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Delete failed');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      isDeleting.value = false;
      Get.snackbar(
          "Delete Failed",
          e.toString().contains("401")
              ? "Unauthorized. Please log in again."
              : "Could not delete request. Please try again.");
      return false;
    }
  }

  Future<void> getconfigureFieldCashAdvance() async {
    isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.geconfigureFieldCashAdvance);
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        configListAdvance.value = [];
        if (data is List) {
          configListAdvance.addAll(data.cast<Map<String, dynamic>>());

          print('Appended configList: $configListAdvance');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          print('currencies to load countries$currencies');
        }
      } else {
        print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      print('Error fetching countries: $e');
      isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<void> fetchBusinessjustification() async {
    isLoadingGE2.value = true;
    isLoadingGE1.value = true;
    final url = Uri.parse(Urls.businessJustification);
    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // configListAdvance.value = [];
        if (data is List) {
          justification.assignAll(data
              .map((json) => Businessjustification.fromJson(json))
              .toList());

          print('justification: $justification');
          isLoadingGE2.value = false;
          isLoadingGE1.value = false;
          // print('currencies to load countries$currencies');
        }
      } else {
        print('Failed to load countries');
        isLoadingGE2.value = false;
        isLoadingGE1.value = false;
      }
    } catch (e) {
      print('Error fetching countries: $e');
      isLoadingGE2.value = false;
      isLoadingGE1.value = false;
    }
  }

  Future<ExchangeRateResponse?> fetchExchangeRateCA(
      String currencyCode, String amount) async {
    final dateToUse = selectedDate ?? DateTime.now();
    final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
    final fromDate = parseDateToEpoch(formatted);

    double? parsedAmount = double.tryParse(paidAmount.text);
    // final String amount = parsedAmount != null ? parsedAmount.toInt().toString() : '0';

    final url = Uri.parse(
      '${Urls.exchangeRate}/${amount ?? 0}/${currencyCode ?? "INR"}/$fromDate',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ExchangeRate'] != null && data['BaseUnit'] != null) {
          return ExchangeRateResponse.fromJson(data);
        }
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
    }
    return null;
  }

  Future<double?> fetchMaxAllowedPercentage() async {
    print("Callx");
    // Get the required values directly from controller
    final dateToUse = selectedDate ?? DateTime.now();
    final String requestDateEpoch = dateToUse.millisecondsSinceEpoch.toString();
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
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['MaxAllowedPercentage'] != null) {
          final double percentage =
              (data['MaxAllowedPercentage'] as num).toDouble();

          requestedPercentage.text = '${percentage.toInt()} %';

          return percentage;
        }
      } else {
        Fluttertoast.showToast(
          msg: response.body,
          backgroundColor: Colors.red[200],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red[800],
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error fetching MaxAllowedPercentage: $e');
    }

    return null;
  }

  Future<Object> fetchSpecificCashAdvanceItem(
      BuildContext context, int recId) async {
    isLoadingCA.value = true;

    // Build the URL with query parameters
    final url = Uri.parse(
      '${Urls.getSpecificCashAdvance}recid=$recId&lock_id=$recId&screen_name=MyCashAdvance',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
                  DateTime.fromMillisecondsSinceEpoch(cashAdvance.requestDate!))
              : '';
          // Add more controllers if needed
          print("Requisition ID: ${requisitionIdController.text}");
        }

        isLoadingCA.value = false;

        // Navigate to ViewCashAdvanseReturnForm

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.viewCashAdvanseReturnForms,
          arguments: {
            'item': specificCashAdvanceList[0],
          },
        );
        return specificCashAdvanceList;
      } else {
        isLoadingCA.value = false;
        print(
            'Failed to load Cash Advance. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      isLoadingCA.value = false;
      print('Error fetching Cash Advance: $e');
      return [];
    }
  }

  Future<Object> fetchSpecificCashAdvanceApprovalItem(
      BuildContext context, int workitemrecid) async {
    isLoadingCA.value = true;

    // Build the URL with query parameters
    final url = Uri.parse(
      '${Urls.myPendingApproval}detailedapproval?workitemrecid=$workitemrecid&lock_id=$workitemrecid&&screen_name=MyPendingApproval',
    );

    try {
      final request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        });

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
                  DateTime.fromMillisecondsSinceEpoch(cashAdvance.requestDate!))
              : '';
          // Add more controllers if needed
          print("Requisition ID: ${requisitionIdController.text}");
        }

        isLoadingCA.value = false;

        // Navigate to ViewCashAdvanseReturnForm

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          AppRoutes.viewCashAdvanseReturnForms,
          arguments: {
            'item': specificCashAdvanceList[0],
          },
        );
        return specificCashAdvanceList;
      } else {
        isLoadingCA.value = false;
        print(
            'Failed to load Cash Advance. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      isLoadingCA.value = false;
      print('Error fetching Cash Advance: $e');
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
          unitRateCA1.text = exchangeResponse1.exchangeRate.toString();
          amountINRCA1.text = exchangeResponse1.totalAmount.toStringAsFixed(2);
          isVisible.value = true;
        }

        final maxPercentage = results[1] as double?;
        if (maxPercentage != null && maxPercentage > 0) {
          double calculatedPercentage = (paidAmounts * maxPercentage) / 100;

          totalRequestedAmount.text = calculatedPercentage.toString();
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
          final exchangeResponse =
              await fetchExchangeRateCA(reqCurrency, reqPaidAmount);

          if (exchangeResponse != null) {
            unitRateCA2.text = exchangeResponse.exchangeRate.toString();
            amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
          }
        }
      }
    });
    print("SuccesFully call All Data");
  }

  Future<void> fetchAndAppendPendingApprovals() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      '${Urls.getApprovalDashboardData}pendingcashasvanceapprovals?filter_query=CSHCashAdvReqHeader.ApprovalStatus__eq%3DPending&page=1&sort_order=asc',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      final List<PendingCashAdvanceApproval> newApprovals = jsonData
          .map((item) => PendingCashAdvanceApproval.fromJson(item))
          .toList();

      pendingApprovalcashAdvanse.addAll(newApprovals);

      // ✅ Append to the existing list
      pendingApprovalcashAdvanse.addAll(newApprovals);

      isLoadingGE1.value = false;
    } else {
      isLoadingGE1.value = false;
      throw Exception('Failed to load pending approvals');
    }
  }

  Future<CashAdvanceGeneralSettings?> fetchGeneralSettings() async {
    final url = Uri.parse(Urls.cashadvanceGeneralSettings);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Params.userToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Assuming the response is a list or has `data` array
      final settingsJson = (decoded is List ? decoded[0] : decoded['data'][0]);
      return CashAdvanceGeneralSettings.fromJson(settingsJson);
    } else {
      print("Failed to fetch settings: ${response.statusCode}");
      return null;
    }
  }

  Future<SequenceNumber?> fetchCashAdvanceSequence() async {
    final url = Uri.parse(
      Urls.cashadvancerequisition,
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken}',
      },
    );

    print('Status Codes: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      final sequence = jsonList.firstWhere(
        (item) =>
            item['Module'] == 'CashAdvance' &&
            item['Area'] == 'CashAdvanceRequisitionNo',
        orElse: () => null,
      );
      print("sequencess$sequence");
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
        'https://api.digixpense.com/api/v1/cashadvancerequisition/cashadvanceregistration/cshadvreqid?employee_id=${Params.employeeId}&ProjectId=&Location=&ExpenseCategoryId=&PaymentMethod=${paymentMethodeID ?? ''}&Currency=${currencyDropDowncontroller ?? ''}&ReceiptDate=${selectedDate ?? ''}');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Params.userToken}',
      },
    );

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
      List<CashAdvanceDropDownModel> allItems, String? idsString) {
    if (idsString == null || idsString.isEmpty) return;
    viewCashAdvanceLoader.value = true;
    cashAdvanceIds.text = "";
    multiSelectedItems.value = [];
    final ids = idsString.split(';');

    // Filter and assign selected items
    multiSelectedItems.assignAll(
      allItems.where((item) => ids.contains(item.cashAdvanceReqId)).toList(),
    );

    // Update the display text
    cashAdvanceIds.text =
        multiSelectedItems.map((item) => item.cashAdvanceReqId).join(', ');

    // Maintain the semicolon-separated format for backend
    preloadedCashAdvReqIds =
        multiSelectedItems.map((item) => item.cashAdvanceReqId).join(';');

    // 🔍 Print debug values
    print('Selected Cash Advance Items:$multiSelectedItems.value');
    for (var item in multiSelectedItems.value) {
      print('→ ID: ${item.cashAdvanceReqId}, Date: ${item.requestDate}');
    }

    print('Comma-separated Text: ${cashAdvanceIds.text}');
    print('Semicolon-separated for backend: $preloadedCashAdvReqIds');
    viewCashAdvanceLoader.value = false;
  }
}
