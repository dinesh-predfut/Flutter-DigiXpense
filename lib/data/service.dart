// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  final TextEditingController contactPostalController = TextEditingController();

  String maritalStatus = 'Single';
  Currency? selectedCurrency;
  Payment? selectedPayment;
  String selectedCurrencyFinal = '';
  String gender = 'Female';
  String country = 'United States';
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
  File? imageFile;
  var isSameAsPermanent = false;

  final ImagePicker _picker = ImagePicker();
  bool rememberMe = false;
  bool passwordVisible = false;
  bool isLoading = false;
  bool forgotisLoading = false;
  Rx<UserProfile> signInModel = UserProfile().obs;
  File? profileImage;
  List<Country> countries = [];
  List<Language> language = [];
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

  Future signIn(BuildContext context) async {
    try {
      // isLoading = true;
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
        await saveCredentials();
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);

        signInModel.value = UserProfile.fromJson(decodeData);

        employeeIdController.text = decodeData['employeeId'] ?? '';
        middleNameController.text = decodeData['UserName'] ?? '';
        firstNameController.text = decodeData['UserName'] ?? '';
        lastNameController.text = decodeData['UserName'] ?? '';
        personalEmailController.text = decodeData['Email'] ?? '';

        SetSharedPref().setData(
          token: signInModel.value.accessToken ?? "null",
          employeeId: signInModel.value.employeeId ?? "null",
          userId: signInModel.value.userId ?? "null",
          refreshtoken: signInModel.value.refreshToken ?? "null",
        );

        // isLoading(false);
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
        isLoading = false;
        // Navigate to LandingPage
        // ignore: use_build_context_synchronously
      } else {
        isLoading = false;
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
      isLoading = false;
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

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
    }
    ;
  }

  Future<bool> getPersonalDetails(BuildContext context) async {
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
        return false;
      }

      final Map<String, dynamic> data = rawList.first as Map<String, dynamic>;
      final Map<String, dynamic> emp = data['Employee'] as Map<String, dynamic>;

      // Top‐level / email
      personalEmailController.text = data['Email'] ?? '';

      // Employee details
      employeeIdController.text = emp['EmployeeId'] ?? '';
      firstNameController.text = emp['FirstName'] ?? '';
      middleNameController.text = emp['MiddleName'] ?? '';
      lastNameController.text = emp['LastName'] ?? '';
      phoneController.text = emp['ContactNumber'] ?? '';
      gender = emp['Gender'] ?? '';
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

      street.text = perm['Street'] ?? '';
      city.text = perm['City'] ?? '';
      state = perm['State'] ?? '';
      postalCode.text = perm['PostalCode'] ?? '';
      country = perm['Country'] ?? '';
      contactStreetController.text = cont['Street'] ?? '';
      contactCityController.text = cont['City'] ?? '';
      contactStateController = cont['State'] ?? '';
      contactPostalController.text = cont['PostalCode'] ?? '';
      contactCountryController = cont['Country'] ?? '';

      // Optionally show a toast on success
      Fluttertoast.showToast(
        msg: "Personal details loaded",
        toastLength: Toast.LENGTH_SHORT,
      );

      return true;
    } catch (error) {
      print('Error Occurred: $error');
      Fluttertoast.showToast(
        msg: "An error occurred: $error",
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }

  // Future<bool> kinDetails(BuildContext context) async {
  //   print('userId: ${Params.userId}');
  //   try {
  //     var request = http.Request('POST', Uri.parse(Urls.kinDetails));
  //     request.body = json.encode({
  //       "customerId": Params.userId,
  //       "id": kinID,
  //       "name": fullName.text,
  //       "relationship": relationShip.text,
  //       "phoneNumber": countryCodeController.text + phoneNumber.text,
  //       "email": email.text,
  //       "address": address.text
  //     });

  //     request.headers.addAll({
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer ${Params.userToken ?? ''}',
  //     });

  //     print('Request: ${request.body}');

  //     // Send request
  //     http.StreamedResponse streamedResponse = await request.send();
  //     var decodedResponse = await http.Response.fromStream(streamedResponse);

  //     print('decodedResponse Code: ${decodedResponse}');
  //     print('Response Body: ${decodedResponse.body}');

  //     if (decodedResponse.statusCode == 200) {
  //       // ignore: use_build_context_synchronously

  //       Fluttertoast.showToast(
  //         msg: "Employment Updated Successfully",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         backgroundColor: Colors.grey,
  //         textColor: Colors.white,
  //       );
  //       return true;
  //     } else {
  //       print('Error: ${decodedResponse.body}');
  //       Fluttertoast.showToast(
  //         msg: "Error: ${decodedResponse.body}",
  //         toastLength: Toast.LENGTH_SHORT,
  //       );
  //       return false;
  //     }
  //   } catch (error) {
  //     print('Error Occurred: $error');
  //     Fluttertoast.showToast(
  //       msg: "An error occurred: $error",
  //       toastLength: Toast.LENGTH_SHORT,
  //     );
  //     return false;
  //   }
  // }
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

  Future<void> fetchCountries() async {
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
        // final data = jsonDecode(response.body);
        // countryList = List<Country>.from(
        //   data.map((item) => Country.fromJson(item)),
        // );
        final data = jsonDecode(response.body);
        countries =
            List<Country>.from(data.map((item) => Country.fromJson(item)));
        countryNames = countries.map((c) => c.name).toList();
        print('Failed to load countries$countryNames');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> fetchLanguageList() async {
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
        countryNames = countries.map((c) => c.name).toList();
        print('Failed to load countries$countryNames');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> fetchState() async {
    final url = Uri.parse(
        '${Urls.stateList}$selectedCountryCode&page=1&sort_by=StateName&sort_order=asc&choosen_fields=StateName%2CStateId');
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

        stateList = List<String>.from(
          data.map((item) => item['StateName'].toString()),
        );
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> currencyDropDown() async {
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
        print('currencies to load countries$currencies');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
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
        print('payment to load countries$payment');
      } else {
        print('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }
}
