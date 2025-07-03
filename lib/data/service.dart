// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:digi_xpense/data/models.dart';
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
  final TextEditingController quantity = TextEditingController();
  final TextEditingController contactPostalController = TextEditingController();
  final TextEditingController addressID = TextEditingController();
  final TextEditingController contactaddressID = TextEditingController();
  final TextEditingController paidAmount = TextEditingController();
  final TextEditingController amountINR = TextEditingController();
  final TextEditingController lineAmount = TextEditingController();
  final TextEditingController lineAmountINR = TextEditingController();
  final TextEditingController unitAmount = TextEditingController();
  final TextEditingController taxAmount = TextEditingController();
  final TextEditingController referenceID = TextEditingController();
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController paidToController = TextEditingController();
  final TextEditingController paidWithController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController ProjectIdController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
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
  final TextEditingController taxGroupController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController unitRateID = TextEditingController();
  final TextEditingController currencyDropDowncontroller =
      TextEditingController();
  final TextEditingController projectDropDowncontroller =
      TextEditingController();

// Per Diem
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  // final TextEditingController locationController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController perDiemController = TextEditingController();
  final TextEditingController amountInController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  late String digiSessionId;

  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
    fetchNotifications();
  }

  String selectedStatus = "Un Reported";
  var countryCode = ''.obs;
  var phoneNumber = ''.obs;
  List<GESpeficExpense> getSpecificListGExpense = [];
  RxList<GESpeficExpense> specificExpenseList = <GESpeficExpense>[].obs;
  RxList<PerdiemResponseModel> specificPerdiemList =
      <PerdiemResponseModel>[].obs;
  Rx<PerDiemResponseModel?> perdiemResponse = Rx<PerDiemResponseModel?>(null);
  // List<ExpenseItem> expenseItems = [];
  List<ExpenseItem> finalItems = [];
  List<AccountingDistribution?> accountingDistributions = [];
  RxList<GExpense> getAllListGExpense = <GExpense>[].obs;
  String maritalStatus = 'Single';
  var selectedCurrency = Rxn<Currency>();
  late double exchangeRate;
  bool isManualEntry = false;
  RxBool isEnable = false.obs;
  RxBool isEnablePerDiem = false.obs;
  RxBool paidAmontIsEditable = true.obs;
  RxBool perDiem = true.obs;
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
  String selectedCurrencyFinal = '';
  List<String> emails = [];
  RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;
  String country = '';
  String contactStateController = '';
  String contactCountryController = 'United States';
  String state = '';
  String paymentMethodID = '';
  String? paidWith;
  DateTime? selectedDate;
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
  late int editTotalAmount;
  List<AllocationLine> allocationLines = [];
  List<AccountingSplit> split = [AccountingSplit(percentage: 100.0)];
  var isSameAsPermanent = false;
  MapEntry<String, String>? selectedFormat;
  var notifications = <NotificationItem>[].obs;
  final ImagePicker _picker = ImagePicker();
  bool rememberMe = false;
  bool passwordVisible = false;
  final RxBool isLoading = false.obs;
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
  List<Currency> currencies = [];

  final RxList<ExpenseCategory> expenseCategory = <ExpenseCategory>[].obs;
  List<Payment> payment = [];
  RxList<Map<String, dynamic>> configList = <Map<String, dynamic>>[].obs;
  RxList<File> imageFiles = <File>[].obs;
// GeneralExpense
  late bool isBillable;
  late bool isReimbursite;

  var checkboxValues = <String, bool>{}.obs;

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
      isLoading.value = true;
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
        isLoading.value = false;
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
        );

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
        isLoading.value = false;
        // Navigate to LandingPage
        // ignore: use_build_context_synchronously
      } else {
        isLoading.value = false;
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
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
      isLoading.value = false;
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, AppRoutes.dashboard_Main);
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
      isLoading.value = false;
      rethrow;
    }
  }

  void clearFormFields() {
    firstNameController.clear();
    manualPaidToController.clear();
    paidAmount.clear();
    amountINR.clear();
    unitRate.clear();
    descriptionController.clear();
    taxAmount.clear();
    selectedPaidWith = null;
    selectedPaidto = null;
    selectedunit = null;
    selectedCurrency.value = null;
    selectedTax = null;
    selectedProject = null;
    selectedDate = DateTime.now();
    imageFiles.clear();
    finalItems.clear();
    files.clear();
    isManualEntry = false;
    isUploading.value = false;
    isGESubmitBTNLoading.value = false;
    paymentMethodeID = "";
  }

  ExpenseItem toModel() {
    return ExpenseItem(
      expenseCategoryId: "Bus",
      quantity: double.tryParse(quantity.text) ?? 1.00,
      uomId: selectedunit?.code ?? '',
      unitPriceTrans: double.tryParse(unitAmount.text) ?? 0,
      taxAmount: double.tryParse(taxAmount.text) ?? 0,
      taxGroup: selectedTax?.taxGroupId ?? '',
      lineAmountTrans: double.tryParse(paidAmount.text) ?? 0,
      lineAmountReporting: double.tryParse(paidAmount.text) ?? 0,
      projectId: selectedProject?.code ?? '',
      description: descriptionController.text,
      isReimbursable: checkboxValues['is Reimbursible'] ?? false,
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
      accountingDistributions: [
        AccountingDistribution(
          transAmount: double.tryParse(unitAmount.text) ?? 0,
          reportAmount: double.tryParse(paidAmount.text) ?? 0,
          allocationFactor: 100,
          dimensionValueId: 'Branch001',
        )
      ],
    );
  }

  Future<List<PaidForModel>> fetchPaidForList() async {
    final url = Uri.parse(Urls.dimensionValueDropDown);

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${Params.userToken ?? ''}',
        'DigiSessionID': digiSessionId,
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
      // Show loading dialog
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
        backgroundColor: Color.fromARGB(255, 35, 2, 124),
        textColor: Color.fromARGB(255, 253, 252, 253),
        fontSize: 16.0,
      );
    } else {
      print('Upload failed [${response.statusCode}]: ${response.body}');
      profileImage.value = null;
      Fluttertoast.showToast(
        msg: response.body,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 173, 3, 3),
        textColor: Color.fromARGB(255, 253, 252, 253),
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
        backgroundColor: Color.fromARGB(255, 35, 2, 124),
        textColor: Color.fromARGB(255, 253, 252, 253),
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
          msg: decodeData["message"] ?? "Login failed. Please try again.",
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

        currencies = data.map((e) => Currency.fromJson(e)).toList();
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
    isLoading.value = true;

    try {
      const String transactionDate = '1749580200000';

      // Safely construct query parameters
      final queryParams = <String, String>{
        'TransactionDate': transactionDate,
      };

      if (selectedProject?.code != null && selectedProject!.code.isNotEmpty) {
        queryParams['ProjectCode'] = selectedProject!.code;
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
          print('currencies to load countries$currencies');
        }
      } else {
        print('Failed to load countries');
        isLoadingGE2.value = false;
      }
    } catch (e) {
      print('Error fetching countries: $e');
      isLoadingGE2.value = false;
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
      print("Timezone: $tz - from: $defaultTimezoneName");
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
        print('✅ Profile picture saved to ${response.statusCode}');
        final String base64String = response.body;
        print('✅ Profile picture saved to $base64String');

        final cleaned = base64String.contains(',')
            ? base64String.split(',')[1]
            : base64String;

        final Uint8List bytes = base64Decode(cleaned);

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/profile_image.png');
        await file.writeAsBytes(bytes);

        profileImage.value = file;

        print('✅ Profile image stored at: ${file.path}');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> updateProfileDetails() async {
    buttonLoader.value = true;
    isUploading.value = true;

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
        buttonLoader.value = false;
        isUploading.value = false;
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: "Success: ${responseData['detail']['message']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 88, 1, 250),
          textColor: Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error:  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
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
          backgroundColor: Color.fromARGB(255, 88, 1, 250),
          textColor: Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
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

// Delay mapping with Timer to ensure dropdown options are loaded
      Timer(const Duration(seconds: 5), () {
        selectedCountry.value = countries.firstWhere(
          (p) => p.code == selectedCountryCode,
          orElse: () => Country(code: '', name: ''),
        );

        selectedContCountry.value = countries.firstWhere(
          (p) => p.code == contactCountryController,
          orElse: () => Country(code: '', name: ''),
        );

        selectedContectCountryCode = selectedCountry.value!.code;

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
    isLoadingGE1.value = true;
    final url = Uri.parse(
      Urls.getPaidtoDropdown,
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

  Future<List<LocationModel>> fetchLocation() async {
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
        return locationDropDown;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
      return [];
    }
  }

  Future<List<Project>> fetchProjectName() async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
      Urls.getProjectDropdown,
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

        final List<Project> projects = List<Project>.from(
          data.map((item) => Project.fromJson(item)),
        );

        project.value = projects;

        print("projects$projects");
        isLoadingGE1.value = false;
        return projects;
      } else {
        print('Failed to load states. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching states: $e');
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
    if (selectedCurrency.value == null) {
      print('selectedCurrency is null');
      return null;
    }

    double? parsedAmount = double.tryParse(paidAmount.text);
    final String amount =
        parsedAmount != null ? parsedAmount.toInt().toString() : '0';

    final url = Uri.parse(
      '${Urls.exchangeRate}/$amount/${selectedCurrency.value!.code}/1749580200000',
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
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return null;
    }
    return null;
  }

  Future<List<PaymentMethodModel>> fetchPaidwith() async {
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

  Future<List<GESpeficExpense>> fetchSecificExpenseItem(
      context, int recId) async {
    isLoadingGE1.value = true;
    final url = Uri.parse(
        '${Urls.getSpecificGeneralExpense}RecId=$recId&lock_id=$recId&screen_name=MyExpense');

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

  Future<List<ExpenseHistory>> fetchExpenseHistory(int? recId) async {
    ;
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

  Future<List<File>> fetchExpenseDocImage([int? recId]) async {
    isLoadingviewImage.value = true;
    const String token = 'your_token_here';
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

  Future<void> saveGeneralExpense(context, bool bool) async {
    final formatted = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final parsedDate = DateFormat('dd/MM/yyyy').parse(formatted.toString());
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    print("receiptDate$receiptDate");
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    print("receiptDate$attachmentPayload");
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = selectedunit?.code != null;
    print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": "",
      "EmployeeId": Params.employeeId,
      "EmployeeName": firstNameController.text.trim(),
      "MerchantName": isManualEntry
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntry ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": '',
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paymentMethodeID ?? '',
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
      "ExpenseCategoryId": "Bus",
      if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      if (!hasValidUnit) 'ProjectId': selectedProject?.code ?? '',
      if (!hasValidUnit) 'Description': descriptionController.text,
      if (!hasValidUnit) "TaxGroup": selectedTax?.taxGroupId ?? '',
      if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
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
            '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=false&screen_name=MyExpenseSubmit=$bool&Resubmit=false&screen_name=MyExpense'),
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
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
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

  Future<void> saveinviewPageGeneralExpense(context, bool bool) async {
    final dateString = receiptDateController.text.trim();
    final parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);
    final receiptDate = parsedDate.millisecondsSinceEpoch;
    final attachmentPayload = await buildDocumentAttachment(imageFiles);
    if (!bool) {
      isUploading.value = true;
    } else {
      isGESubmitBTNLoading.value = true;
    }
    final hasValidUnit = selectedunit?.code != null;
    print("hasValidUnit$hasValidUnit${selectedunit?.code}");
    final Map<String, dynamic> requestBody = {
      "ReceiptDate": receiptDate,
      "ExpenseId": "",
      "EmployeeId": Params.employeeId,
      "EmployeeName": firstNameController.text.trim(),
      "MerchantName": isManualEntry
          ? manualPaidToController.text.trim()
          : selectedPaidto?.merchantNames ?? '',
      "MerchantId": isManualEntry ? null : selectedPaidto?.merchantId,
      "CashAdvReqId": '',
      "Location": "", // or locationController.text.trim()
      "PaymentMethod": paymentMethodeID ?? paymentMethodID,
      "TotalAmountTrans": double.tryParse(paidAmount.text) ?? 0.0,
      "TotalAmountReporting": double.tryParse(amountINR.text) ?? 0.0,
      'ProjectId': selectedProject?.code ?? projectDropDowncontroller.text,
      "IsReimbursable": true,
      "Currency": selectedCurrency.value?.code ?? 'INR',
      "ExchRate": double.tryParse(unitRate.text) ?? 1.0,
      "UserExchRate": double.tryParse(unitRate.text) ?? 1.0,
      "Source": "Web",
      "IsBillable": false,
      "ExpenseType": "General Expenses",
      "ExpenseHeaderCustomFieldValues": [],
      "ExpenseHeaderExpensecategorycustomfieldvalues": [],
      if (!hasValidUnit) "ExpenseCategoryId": "Bus",
      if (!hasValidUnit)
        'ProjectId': selectedProject?.code ?? projectDropDowncontroller.text,
      if (!hasValidUnit) 'Description': descriptionController.text,
      if (!hasValidUnit)
        "TaxGroup": selectedTax?.taxGroupId ?? taxGroupController.text,
      if (!hasValidUnit) "TaxAmont": double.tryParse(taxAmount.text) ?? 0,
      // 'AccountingDistributions':
      //     accountingDistributions.map((e) => e.toJson()).toList(),
      "DocumentAttachment": {
        "File": attachmentPayload,
      },
      if (hasValidUnit && finalItems.isNotEmpty)
        "ExpenseTrans": finalItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(
            '${Urls.saveGenderalExpense}&Submit=$bool&Resubmit=false&screen_name=MyExpense'),
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
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        Fluttertoast.showToast(
          msg: "$message (RecId: $recId)",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
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
      case 'Approval':
      case 'Cancelled':
      case 'Rejected':
        apiStatus = selectedStatus;
        break;
      case 'All':
        apiStatus = null;
        break;
    }

    // 🛠️ Build full URL
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
        Fluttertoast.showToast(
          msg: decodeData["detail"]["message"] ?? "Per Diem data not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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
    setTheAllcationAmount = 0;
    amountInController.clear();
    firstNameController.clear();
    purposeController.clear();
    fromDateController.clear();
    toDateController.clear();
    isManualEntry = false;
    // Reset dropdowns or selections
    selectedProject = null;
    selectedLocation = null;
    split.clear();
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
      context, bool bool, bool resubmit, String? recId) async {
    // buttonLoader.value = true;
    // isUploading.value = true;
    print(recId);
    Map<String, dynamic> buildPayload() {
      return {
        "ExpenseId": recId ?? '',
        "ProjectId": selectedProject!.code,
        "TotalAmountTrans": amountInController.text,
        "TotalAmountReporting": amountInController.text,
        "EmployeeId": Params.employeeId,
        "EmployeeName": firstNameController.text,
        "ReceiptDate": parseDateToEpoch(fromDateController.text),
        "Currency": "INR",
        "Description": purposeController.text,
        "Source": "Web",
        "ExchRate": 1,
        "ExpenseType": "PerDiem",
        "Location": selectedLocation!.location,
        "CashAdvReqId": "",
        "FromDate": parseDateToEpoch(fromDateController.text),
        "ToDate": parseDateToEpoch(toDateController.text),
        "ExpenseHeaderCustomFieldValues": [],
        "ExpenseHeaderExpensecategorycustomfieldvalues": [],
        "AccountingDistributions":
            accountingDistributions.map((e) => e?.toJson()).toList(),
        "AllocationLines": allocationLines.map((e) => e.toJson()).toList(),
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

      if (response.statusCode == 201) {
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
          backgroundColor: Color.fromARGB(255, 88, 1, 250),
          textColor: Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        // print("✅ ");
      } else {
        Fluttertoast.showToast(
          msg: "Error:  ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
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
      context, int recId) async {
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

  void fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    notifications.value = [
      NotificationItem(
        id: 'EMP002',
        title:
            'You Request ID:EMP002 for Mileage as Approved by Dodi Taison Rs.32.00',
        time: '11.00 AM',
        imageUrl: 'https://i.pravatar.cc/100?img=1',
        isRead: false,
      ),
      NotificationItem(
        id: 'HU002',
        title:
            'You Request ID:HU002 for Per Diem as Approved by Dodi Taison Rs.232.00',
        time: '10.50 AM',
        imageUrl: 'https://i.pravatar.cc/100?img=2',
        isRead: false,
      ),
      NotificationItem(
        id: 'HU0022',
        title:
            'You Request ID:HU0022 for Per Diem as Approved by Dodi Taison Rs.232.00',
        time: '10.32 AM',
        imageUrl: 'https://i.pravatar.cc/100?img=3',
        isRead: true,
      ),
      NotificationItem(
        id: 'HU0023',
        title:
            'You Request ID:HU002 for Per Diem as Rejected by Dodi Taison Rs.232.00',
        time: '08.40 AM',
        imageUrl: 'https://i.pravatar.cc/100?img=4',
        isRead: true,
      ),
    ];
  }

  void markAsRead(NotificationItem item) {
    final index = notifications.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      notifications[index] = NotificationItem(
        id: item.id,
        title: item.title,
        time: item.time,
        imageUrl: item.imageUrl,
        isRead: true,
      );
    }
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    const apiKey =
        "AIzaSyDk9NqdMVKgLTvuMAVDU71JYxOD0CQQ7QQ";
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:in';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

    print('📍 Current Position: Lat=${position.latitude}, Lng=${position.longitude}');

 
      // _currentLatLng = LatLng(position.latitude, position.longitude);
   
  } else {
    print('❌ Location permission not granted');
  }
}

  List<NotificationItem> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();
}
