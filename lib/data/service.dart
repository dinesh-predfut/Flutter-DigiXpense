// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
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
// ignore: duplicate_import
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/screen/widget/router/router.dart';
import 'package:path_provider/path_provider.dart';

class Controller extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotemailController = TextEditingController();
  // setting
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

  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController contactStreetController = TextEditingController();
  final TextEditingController contactCityController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();

  final TextEditingController contactPostalController = TextEditingController();
  final TextEditingController addressID = TextEditingController();
  final TextEditingController contactaddressID = TextEditingController();
  String maritalStatus = 'Single';
  Currency? selectedCurrency;

  // StateModels? selectedContState;
//  Country? selectedContCountry;
  Locales? selectedLocale;
  Payment? selectedPayment;
  Language? selectedLanguage;
  Timezone? selectedTimezone;
  String? selectedTimezonevalue;
  String? stringCurrency;
  String selectedCurrencyFinal = '';
  List<String> emails = [];
  String country = '';
  String contactStateController = '';
  String contactCountryController = 'United States';
  String state = '';
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

  File? imageFile;
  var isSameAsPermanent = false;
  MapEntry<String, String>? selectedFormat;

  final ImagePicker _picker = ImagePicker();
  bool rememberMe = false;
  bool passwordVisible = false;
  final RxBool isLoading = false.obs;
  var buttonLoader = false.obs;
  RxBool isImageLoading = false.obs;
  bool forgotisLoading = false;
  Rx<UserProfile> signInModel = UserProfile().obs;
  // File? profileImage;
  Rxn<File> profileImage = Rxn<File>();
  var selectedContCountry = Rx<Country?>(null);
  var selectedState = Rx<StateModels?>(null);
  var selectedContState = Rx<StateModels?>(null);
  var selectedCountry = Rx<Country?>(null);
  var statesres = <StateModels>[].obs;
  var countries = <Country>[].obs;
  List<Language> language = [];
  List<Timezone> timezone = [];
  List<Locales> localeData = [];
  List<String> languageList = [];
  List<String> countryNames = [];
  List<String> stateList = [];
  List<Currency> currencies = [];
  List<Payment> payment = [];
  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
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

      rethrow;
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
    print("object");
    if (profileImage.value == null) return;

    final bytes = await profileImage.value!.readAsBytes();
    final base64String = base64Encode(bytes);
    print("object$base64String");

    final url = Uri.parse(
      '${Urls.updateProfilePicture}${Params.userId}',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Params.userToken ?? ''}',
    };
    final body = jsonEncode({
      'ProfilePicture': 'data:image/png;base64,$base64String',
    });

    final response = await http.patch(url, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 280) {
      final responseData = jsonDecode(response.body);
      profileImage.value = null;
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
      // you might parse response.body here to show validation errors
    }
  }

  Future<void> sendForgetPassword(BuildContext context) async {
    try {
      print("forgotemailController text: ${forgotemailController.text}");

      forgotisLoading = true;

      final response = await http.post(
          Uri.parse('${Urls.forgetPassword}${forgotemailController.text}'),
          headers: {
            'Content-Type': 'application/json',
          });

      final decodeData = jsonDecode(response.body);

      if (response.statusCode == 280) {
        forgotisLoading = false;

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
        forgotisLoading = false;

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
      forgotisLoading = false;

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
        // print('language to load countries$countryNames');
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

  Future<List<StateModels>> fetchState() async {
    final url = Uri.parse(
      '${Urls.stateList}$selectedCountryCode&page=1&sort_by=StateName&sort_order=asc&choosen_fields=StateName%2CStateId',
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

  Future<void> getUserPref() async {
    isLoading.value = true;
    final url = Uri.parse(
        '${Urls.getuserPreferencesAPI}${Params.userId}&page=1&sort_order=asc');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List &&
            decoded.isNotEmpty &&
            decoded.first is Map<String, dynamic>) {
          final prefs = decoded.first as Map<String, dynamic>;
          final defaultCurrencyCode = prefs['DefaultCurrency'];
          final defaultLanguageId = prefs['DefaultLanguageId'];
          final defaultTimezoneName = prefs['DefaultTimeZone'];
          final defaultPaymentId = prefs['DefaultPaymentMethodId'];
          final defaultDateformat = prefs['DefaultDateFormat'];
          final defaultReceiptEmail = prefs['EmailsForRecieptForwarding'];
          print('Selected preferences loaded$defaultTimezoneName');

          selectedCurrency = currencies.firstWhere(
            (c) => c.code == defaultCurrencyCode,
            orElse: () => Currency(code: "", name: "", symbol: ""),
          );

          selectedLanguage = language.firstWhere(
            (l) => l.code == defaultLanguageId,
            orElse: () => Language(code: "", name: ""),
          );

          selectedTimezone = timezone.firstWhere(
            (t) => t.id == defaultTimezoneName,
            orElse: () => Timezone(code: "", name: "", id: ""),
          );

          selectedPayment = payment.firstWhere(
            (p) => p.code == defaultPaymentId,
            orElse: () => Payment(code: '', name: ''),
          );
          selectedFormat = dateFormatMap.entries.firstWhere(
            (entry) => entry.value == defaultDateformat,
            orElse: () => const MapEntry(
                'dd_mm_yyyy', 'dd/MM/yyyy'), // or your app’s default
          );
          if (defaultReceiptEmail != null && defaultReceiptEmail is String) {
            emails =
                defaultReceiptEmail.split(';').map((e) => e.trim()).toList();
          }
          isLoading.value = false;
          print("selectedTimezone${selectedTimezone!.name}");
          // print('selectedFormat preferences loaded${language.}.');
        } else {
          print('Unexpected response formats: ${decoded.runtimeType}');
          isLoading.value = false;
        }
      } else {
        print('Failed to load preferences: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (e) {
      print('Error fetching preferences: $e');
      isLoading.value = false;
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
    final Map<String, dynamic> requestBody = {
      "ContactNumber": '${countryCodeController.text} ${phoneController.text}',
      "employeeaddress": [
        {
          "AddressId": addressID.text,
          "Country": selectedCountryCode,
          "State": state,
          "Street": street.text,
          "City": city.text,
          "PostalCode": postalCode.text,
          "Addresspurpose": "Permanent"
        },
        {
          "AddressId": contactaddressID.text,
          "Country": selectedContectCountryCode,
          "State": contactStateController,
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
          msg: "Error: ${response.statusCode} - ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.statusCode} - ${response.body}");
        buttonLoader.value = false;
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
      "DefaultCurrency": selectedCurrency?.code,
      "DefaultTimeZoneValue": selectedTimezonevalue,
      "DefaultTimeZone": selectedTimezone?.id,
      "DefaultLanguageId": selectedLanguage?.code,
      "DefaultDateFormat": selectedFormat?.value,
      "EmailsForRecieptForwarding": emails.join(';'),
      "ShowAnalyticsOnList": true,
      "DefaultPaymentMethodId": selectedPayment?.code,
      "ThemeDirection": false,
      "ThemeColor": "GREEN_THEME",
      "DecimalSeperator": selectedLocale?.code
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
          msg: "Error: ${response.statusCode} - ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 250, 1, 1),
          textColor: Color.fromARGB(255, 212, 210, 241),
          fontSize: 16.0,
        );
        print("❌ Error: ${response.statusCode} - ${response.body}");
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
        final parts = fullNumber.split(' ');
        print(" phoneController.text2$parts");
        if (parts.length == 3) {
          countryCodeController.text = parts[0];
          phoneController.text = "${parts[2]}";
          print(" phoneController.text${phoneController.text}");
        } else {
          countryCodeController.text = '';
          phoneController.text = fullNumber;
        }
      } else {
        countryCodeController.text = '';
        phoneController.text = fullNumber;
        print(" phoneController.text3${phoneController.text}");
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
      postalCode.text = perm['PostalCode'] ?? '';
      addressID.text = perm["AddressId"];
      selectedCountryCode = perm['Country'] ?? '';
      contactStreetController.text = cont['Street'] ?? '';
      contactCityController.text = cont['City'] ?? '';
      contactStateController = cont['State'] ?? '';
      contactPostalController.text = cont['PostalCode'] ?? '';
      contactaddressID.text = cont['AddressId'] ?? '';
      contactCountryController = cont['Country'] ?? '';
      // fetchState();
      // Optionally show a toast on success
      isLoading.value = true;
      Timer(const Duration(seconds: 5), () {
        selectedCountry.value = countries.firstWhere(
          (p) => p.code == selectedCountryCode,
          orElse: () => Country(code: '', name: ''),
        );

        selectedContCountry.value = countries.firstWhere(
          (p) => p.code == contactCountryController,
          orElse: () => Country(code: '', name: ''),
        );
        selectedState.value = statesres.firstWhere(
          (p) => p.name == state,
          orElse: () => StateModels(code: '', name: ''),
        );
        selectedContState.value = statesres.firstWhere(
          (p) => p.name == contactStateController,
          orElse: () => StateModels(code: '', name: ''),
        );
        print(
            "selectedState$statesres${contactStateController},${selectedContCountry.value!.code}");
      });
      Fluttertoast.showToast(
        msg: "Personal details loaded${selectedCountryCode}",
        toastLength: Toast.LENGTH_SHORT,
      );
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
}
