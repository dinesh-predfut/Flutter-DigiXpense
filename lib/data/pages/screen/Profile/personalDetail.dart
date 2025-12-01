import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:digi_xpense/core/comman/widgets/multiColumnDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/main.dart';
import 'package:digi_xpense/theme/settheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/comman/widgets/button.dart';
import '../../../../core/comman/widgets/dateSelector.dart';
import '../../../../core/comman/widgets/pageLoaders.dart';
import '../../../models.dart';
import 'package:flutter/services.dart';
import 'package:digi_xpense/l10n/app_localizations.dart'; // import 'package:flutter_chips_input/flutter_chips_input.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final controller = Get.put(Controller());
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  FocusNode _contactStateFocusNode = FocusNode();
  FocusNode _contCountryFocusNode = FocusNode();
  final TextEditingController textcontroller = TextEditingController();
  final TextEditingController _statePresentStateTextController =
      TextEditingController();
late Future<Map<String, bool>> featureFuture;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> filteredOptions = [];
  List<Map<String, dynamic>> filteredStateOptions = [];
  FocusNode _statePresentFocusNode = FocusNode();
  Future<List<StateModels>>? statesFuture;
  Future<List<Country>>? constCountryFuture;
  String _stateSearchQuery = '';
  String _statePresentSearchQuery = '';
  RxBool isButtonDisabled = false.obs;
  RxBool dataLoading = false.obs;
  bool isTyping = false;
  String _ContCountry = '';
  String _presentCountry = '';
  bool _showResults = false;
  bool _showResultsContCountr = false;
  bool _disableField = true;
  bool _showResultsPresentCountr = false;
  bool _showResultsPresentState = false;
  bool showDropdown = false;
  bool _isSectionDisabled = false;
  bool _didPopulateInitialstate = false;
  var isFetchingStates = false.obs;
  bool _didPopulateInitial = false;
  bool _didPopulateInitialcountry = false;
  bool _didPopulateInitialcontcountry = false;
  bool hasEmailError = false;
  Rxn<File> profileImage = Rxn<File>();
  final RegExp _emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
  FocusNode _presentCountryFocusNode = FocusNode();
  String? _errorText;

  void _validateOnChange(String value) {
    final invalid = value
        .split(',')
        .map((e) => e.trim())
        .any((e) => e.isNotEmpty && !_emailRegex.hasMatch(e));

    setState(() {
      hasEmailError = invalid;
      _errorText = invalid ? "One or more emails are invalid" : null;
      isTyping = value.trim().isNotEmpty;
    });
  }

  Future<void> _disableSectionTemporarily() async {
    setState(() {
      _isSectionDisabled = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      _isSectionDisabled = false;
    });
  }

  String cleanSymbol(String? symbol) {
    if (symbol == null || symbol.trim().isEmpty) {
      return '';
    }
    // Just sanitize nulls/empty, but keep actual symbols like ₹, $, €, £, ¥
    return symbol.trim();
  }

  void _addEmails(String value) {
    _validateOnChange(value);

    if (!hasEmailError) {
      final newEmails = value
          .split(',')
          .map((e) => e.trim())
          .where(
            (e) =>
                e.isNotEmpty &&
                _emailRegex.hasMatch(e) &&
                !controller.emails.contains(e),
          )
          .toList();

      setState(() {
        controller.emails.addAll(newEmails);
        _controller.clear();
        _errorText = null;
        isTyping = false;
      });

      print("Added: $newEmails");
    }
  }

  void _removeEmail(String email) {
    setState(() => controller.emails.remove(email));
  }

  @override
  void initState() {
    super.initState();

    if (controller.isSameAsPermanent) {
      toggleSameAddress(true);
    }
    _presentCountryFocusNode.addListener(() {
      if (_presentCountryFocusNode.hasFocus) {
        setState(() {
          _showResultsPresentCountr = true;
        });
      }
    });
    _statePresentFocusNode.addListener(() {
      if (_statePresentFocusNode.hasFocus) {
        setState(() {
          _showResultsPresentState = true;
        });
      }
    });
    _contactStateFocusNode.addListener(() {
      if (_contactStateFocusNode.hasFocus) {
        setState(() {
          _showResults = true;
        });
      }
    });
 featureFuture = controller.getAllFeatureStates();
    // controller.getProfilePicture();

    // if (controller.contactStreetController.text.isEmpty &&
    //     controller.selectedContCountry.value == null &&
    //     controller.selectedContCountry.value == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllData();
    });
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    // controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      setState(() {});
      controller.isImageLoading.value = false;
    } else {
      // await controller.getProfilePicture();
    }
  }

  Future<void> fetchAllData() async {
    // Run all API calls in parallel
    dataLoading.value = true;
    await Future.wait([
      controller.fetchCountries(),
      controller.fetchTimeZoneList(),
      controller.localeDropdown(),
      controller.getPersonalDetails(context),

      controller.fetchPaymentMethods(),
      controller.fetchLanguageList(),
      controller.currencyDropDown(),
      controller.paymentMethode(),
    ]);

    // Call getUserPref() after all above complete
    controller.getUserPref(context);

    // Then update UI state based on isSameAsPermanent
    if (controller.isSameAsPermanent) {
      setState(() {
        _disableField = false;
      });
    }
    dataLoading.value = false;
    setState(() {});
  }

  Future<void> fetchCountries() async {
    final response = await controller.fetchCountries();
    controller.countries.assignAll(response);
  }

  Future<void> fetchState(selectedCountryCode) async {
    final response = await controller.fetchCountries();
    controller.countries.assignAll(response);
  }

  void toggleSameAddress(bool value) {
    setState(() {
      controller.isSameAsPermanent = value;
      print("isSameAsPermanent${controller.selectedCountryCode.text}");
      if (value) {
        controller.contactStreetController.text = controller.street.text;
        controller.contactCityController.text = controller.city.text;
        // controller.selectedContState = controller.selectedContState;
        controller.contactPostalController.text = controller.postalCode.text;
        controller.countryConstTextController.text =
            controller.presentCountryTextController.text;
        // controller.countryConstTextController.text = controller.selectedCountryName;
        controller.stateTextController.text =
            controller.statePresentTextController.text;
        controller.selectedContectCountryCode =
            controller.selectedCountryCode.text;
        _disableField = false;
        _contCountryFocusNode.addListener(() {
          if (_contCountryFocusNode.hasFocus) {
            setState(() {
              _showResultsContCountr = true;
            });
          }
        });
      } else {
        controller.contactStreetController.clear();
        controller.contactCityController.clear();
        controller.contactStateController = "";
        controller.contactPostalController.clear();
        controller.contactCountryController = "";
        controller.countryConstTextController.text = "";
        controller.stateTextController.text = "";
        _disableField = true;
        // controller.presentCountryTextController.text = "";
      }
    });
  }

  // @override
  // void dispose() {
  //     controller.stateTextController.dispose();
  // controller.countryConstTextController.dispose();
  // controller.contactCityController.dispose();
  // controller.contactStreetController.dispose();
  // controller.contactPostalController.dispose();

  // controller.selectedTimezone.value = Timezone(code: '', name: '', id: '');
  // controller.selectedPaymentSetting.value = PaymentMethodModel(
  //   paymentMethodName: '',
  //   paymentMethodId: '',
  //   reimbursible: false,
  // );
  // controller.selectedCurrency.value = null;
  // controller.selectedLanguage!.value = null;
  // controller.selectedLocale.value = Locales(code: '', name: '');
  //   _focusNode.dispose();
  //   textcontroller.dispose();
  //   _presentCountryFocusNode.dispose();
  //   _statePresentFocusNode.dispose();
  //   _contCountryFocusNode.dispose();
  //   _contactStateFocusNode.dispose();
  //   super.dispose();
  // }

  void _cancelInput() {
    _controller.clear();

    setState(() {
      _errorText = null;
      isTyping = false;
    });
  }

  final Map<String, dynamic> countryPhoneLengths = {};

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        controller.stateTextController.clear();
        // controller.countryConstTextController.clear();
        controller.contactCityController.clear();
        controller.contactStreetController.clear();

        controller.stateTextController.clear();
        controller.contactPostalController.clear();
        controller.selectedTimezone.value = Timezone(
          code: '',
          name: '',
          id: '',
        );
        controller.selectedPaymentSetting.value = PaymentMethodModel(
          paymentMethodName: '',
          paymentMethodId: '',
          reimbursible: false,
        );
        controller.selectedCurrency.value = null;
        controller.presentCountryTextController.clear();
        controller.selectedLanguage = null;
        controller.selectedLocale.value = Locales(code: '', name: '');
        controller.contactStreetController.clear();
        controller.contactCityController.clear();
        controller.contactPostalController.clear();
        controller.countryConstTextController.clear();
        controller.stateTextController.clear();
        controller.presentCountryTextController.clear();
        controller.statePresentTextController.clear();
        controller.street.clear();
        controller.city.clear();
        controller.postalCode.clear();

        controller.selectedContectCountryCode = '';
        controller.selectedCountryCode.text = '';
        controller.selectedCountry.value = null;
        controller.selectedTimezone.value = Timezone(
          code: '',
          name: '',
          id: '',
        );
        controller.selectedPaymentSetting.value = PaymentMethodModel(
          paymentMethodName: '',
          paymentMethodId: '',
          reimbursible: false,
        );
        controller.selectedCurrency.value = null;
        controller.selectedLanguage = null;
        controller.selectedLocale.value = Locales(code: '', name: '');
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true; // stay on the page
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.personalDetails,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Obx(() {
          return controller.isLoading.value && dataLoading.value
              ? const SkeletonLoaderPage()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Obx(() {
                            if (controller.isImageLoading.value) {
                              return const CircleAvatar(
                                radius: 60,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            final file = profileImage.value;

                            return CircleAvatar(
                              radius: 60,
                              backgroundImage: file != null
                                  ? FileImage(file, scale: 1.0)
                                  : null,
                              key: UniqueKey(),
                              child: file == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            );
                          }),

                          Positioned(
                            bottom: 0,
                            right: MediaQuery.of(context).size.width / 2 - 177,
                            child: GestureDetector(
                              onTap: () => showEditPopup(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 168, 176, 248),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Color.fromARGB(255, 1, 63, 114),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value.trim()
                            : "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Center(
                        child: Text(
                          controller.personalEmailController.text,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: _buildSection(
                              title: loc.personalInformation,
                              children: [
                                _textField(
                                  loc.firstName,
                                  controller.firstNameController,
                                  isEnabled: false,
                                ),
                                const SizedBox(height: 8),
                                _textField(
                                  loc.middleName,
                                  controller.middleNameController,
                                  isEnabled: false,
                                ),
                                const SizedBox(height: 8),
                                _textField(
                                  loc.lastName,
                                  controller.lastNameController,
                                  isEnabled: false,
                                ),
                                const SizedBox(height: 8),
                                _textField(
                                  loc.personalMailId,
                                  controller.personalEmailController,
                                  isEnabled: false,
                                ),
                                const SizedBox(height: 8),
                                // _dateField("Date of Birth", controller.dobController),
                                // const SizedBox(height: 20),
                                SizedBox(
                                  child: IntlPhoneField(
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: loc.phoneNumber,
                                      labelStyle: TextStyle(
  color: Theme.of(context).colorScheme.primary,
),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        
                                      ),
                                      counterText: "",
                                    ),
                                    initialCountryCode: 'IN',
                                    onChanged: (phone) {
                                      controller.countryCodeController.text =
                                          phone.countryCode;
                                    },
                                    onCountryChanged: (country) {
                                      controller.countryCodeController.text =
                                          "+${country.dialCode}";
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (phone) async {
                                      if (phone == null ||
                                          phone.number.trim().isEmpty) {
                                        return loc.enterPhoneNumber;
                                      }

                                      isButtonDisabled.value = true;

                                      // Phone number validation - simplified for now
                                      if (phone.completeNumber.length < 10) {
                                        isButtonDisabled.value = false;
                                        return 'Invalid phone number for ${phone.countryCode}';
                                      }

                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 8),
                                _textField(
                                  loc.gender,
                                  controller.gender,
                                  isEnabled: false,
                                ),
                                const SizedBox(height: 20),
                                // _dropdown(
                                //     "Gender", controller.gender, ["Male", "Female", "others"],
                                //     (String? val) {
                                //   if (val != null) {
                                //     setState(() => controller.gender = val);
                                //   }
                                // }),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    loc.permanentAddress,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _textField(
                                  loc.street,
                                  controller.street,
                                  onChanged: (value) {
                                    if (controller.isSameAsPermanent == true) {
                                      toggleSameAddress(
                                        controller.isSameAsPermanent,
                                      );
                                    }
                                  },
                                ),
                                _textField(
                                  loc.city,
                                  controller.city,
                                  onChanged: (value) {
                                    if (controller.isSameAsPermanent == true) {
                                      toggleSameAddress(
                                        controller.isSameAsPermanent,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                Obx(() {
                                  final countryList = controller.countries;
                                  final lowerQuery = _presentCountry
                                      .toLowerCase();

                                  final filteredPresentCountry = [
                                    ...countryList.where(
                                      (c) => c.name.toLowerCase().startsWith(
                                        lowerQuery,
                                      ),
                                    ),
                                    ...countryList.where(
                                      (c) =>
                                          c.name.toLowerCase().contains(
                                            lowerQuery,
                                          ) &&
                                          !c.name.toLowerCase().startsWith(
                                            lowerQuery,
                                          ),
                                    ),
                                    ...countryList.where(
                                      (c) => !c.name.toLowerCase().contains(
                                        lowerQuery,
                                      ),
                                    ),
                                  ];

                                  if (!_didPopulateInitialcountry &&
                                      controller.selectedCountry.value !=
                                          null &&
                                      controller
                                          .selectedCountry
                                          .value!
                                          .code
                                          .isNotEmpty) {
                                    controller
                                            .presentCountryTextController
                                            .text =
                                        controller.selectedCountry.value!.name;
                                    _didPopulateInitialcountry = true;
                                  }

                                  return FormField<Country>(
                                    initialValue:
                                        controller.selectedCountry.value,
                                    validator: (value) {
                                      // ✅ Validation logic
                                      if (!_disableField)
                                        return null; // Skip validation if field disabled
                                      if (value == null || value.name.isEmpty) {
                                        return 'Please select a country';
                                      }
                                      return null;
                                    },
                                    builder: (stateField) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            controller: controller
                                                .presentCountryTextController,
                                            focusNode: _presentCountryFocusNode,
                                            decoration: InputDecoration(
                                              labelText:
                                                  '${loc.searchCountry}*',
                                                  labelStyle: TextStyle(
  color: Theme.of(context).colorScheme.primary,
),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _showResultsPresentCountr
                                                      ? Icons.arrow_drop_up
                                                      : Icons
                                                            .arrow_drop_down_outlined,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _showResultsPresentCountr =
                                                        !_showResultsPresentCountr;
                                                    _showResultsContCountr =
                                                        false;
                                                    _showResultsPresentState =
                                                        false;
                                                    _showResults = false;
                                                    if (_showResultsPresentCountr) {
                                                      _presentCountryFocusNode
                                                          .requestFocus();
                                                    } else {
                                                      _presentCountryFocusNode
                                                          .unfocus();
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _presentCountry = value;
                                                _showResultsPresentCountr =
                                                    true;
                                              });

                                              if (value.isEmpty) {
                                                controller
                                                        .selectedCountry
                                                        .value =
                                                    null;
                                                // stateField.didChange(null);
                                              }
                                            },
                                            onTap: () {
                                              setState(() {
                                                _showResultsPresentCountr =
                                                    true;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          if (_showResultsPresentCountr)
                                            Container(
                                              width: 320,
                                              constraints: const BoxConstraints(
                                                maxHeight: 250,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                // color: Colors.white,
                                              ),
                                              child:
                                                  filteredPresentCountry.isEmpty
                                                  ? const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          12,
                                                        ),
                                                        child: Text(
                                                          'No matching countries',
                                                        ),
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          filteredPresentCountry
                                                              .length,
                                                      itemBuilder: (context, index) {
                                                        final countryModel =
                                                            filteredPresentCountry[index];
                                                        final isSelected =
                                                            controller
                                                                .presentCountryTextController
                                                                .text ==
                                                            countryModel.name;

                                                        return InkWell(
                                                          onTap: () {
                                                            FocusScope.of(
                                                              context,
                                                            ).unfocus();
                                                            controller
                                                                .selectedCountryCode
                                                                .text = countryModel
                                                                .code;
                                                            if (controller
                                                                .isSameAsPermanent) {
                                                              controller
                                                                      .selectedCountryCode
                                                                      .text =
                                                                  countryModel
                                                                      .code;
                                                              toggleSameAddress(
                                                                controller
                                                                    .isSameAsPermanent,
                                                              );
                                                              controller
                                                                      .countryConstTextController
                                                                      .text =
                                                                  countryModel
                                                                      .name;
                                                            }

                                                            controller
                                                                    .selectedCountryName =
                                                                countryModel
                                                                    .name;

                                                            print(
                                                              "selectedCountryCode${controller.selectedCountryCode.text}",
                                                            );
                                                            controller
                                                                    .selectedCountry
                                                                    .value =
                                                                countryModel;
                                                            controller
                                                                .fetchState();

                                                            setState(() {
                                                              controller
                                                                      .presentCountryTextController
                                                                      .text =
                                                                  countryModel
                                                                      .name;
                                                              _presentCountry =
                                                                  '';
                                                              _showResultsPresentCountr =
                                                                  false;
                                                              controller
                                                                      .statePresentTextController
                                                                      .text =
                                                                  '';

                                                              if (controller
                                                                  .isSameAsPermanent) {
                                                                controller
                                                                        .stateTextController
                                                                        .text =
                                                                    '';
                                                              }
                                                            });

                                                            stateField
                                                                .didChange(
                                                                  countryModel,
                                                                );
                                                          },
                                                          child: Container(
                                                            color: isSelected
                                                                ? const Color.fromARGB(
                                                                    148,
                                                                    143,
                                                                    142,
                                                                    142,
                                                                  ) // 🔹 grey highlight color
                                                                : Colors
                                                                      .transparent,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  countryModel
                                                                      .name,
                                                                  style: TextStyle(
                                                                    // fontWeight:
                                                                    //     isSelected
                                                                    //     ? FontWeight
                                                                    //           .bold
                                                                    //     : FontWeight
                                                                    //           .normal,
                                                                    // color: isSelected
                                                                    //     ? Theme.of(context).primaryColor
                                                                    //     : Colors.black,
                                                                  ),
                                                                ),
                                                                // if (isSelected)
                                                                //   Icon(
                                                                //     Icons.check,
                                                                //     color: Theme.of(context).primaryColor,
                                                                //     size: 18,
                                                                //   ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                          if (stateField.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                                left: 12,
                                              ),
                                              child: Text(
                                                stateField.errorText!,
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                }),

                                const SizedBox(height: 15),
                                Obx(() {
                                  final isDisabled = controller
                                      .isFetchingStates
                                      .value; // 🔹 watch flag

                                  return FutureBuilder<List<StateModels>>(
                                    future:
                                        statesFuture ??
                                        Future.value(<StateModels>[]),
                                    builder: (context, snapshot) {
                                      final statesList = controller.statesres;
                                      final lowerQuery =
                                          _statePresentSearchQuery
                                              .toLowerCase();

                                      final filteredStates = [
                                        ...statesList.where(
                                          (s) => s.name
                                              .toLowerCase()
                                              .startsWith(lowerQuery),
                                        ),
                                        ...statesList.where(
                                          (s) =>
                                              s.name.toLowerCase().contains(
                                                lowerQuery,
                                              ) &&
                                              !s.name.toLowerCase().startsWith(
                                                lowerQuery,
                                              ),
                                        ),
                                        ...statesList.where(
                                          (s) => !s.name.toLowerCase().contains(
                                            lowerQuery,
                                          ),
                                        ),
                                      ];

                                      if (!_didPopulateInitialstate &&
                                          controller.selectedState.value !=
                                              null &&
                                          controller
                                              .selectedState
                                              .value!
                                              .code
                                              .isNotEmpty) {
                                        _statePresentStateTextController.text =
                                            controller
                                                .selectedState
                                                .value!
                                                .name;
                                        _didPopulateInitialstate = true;
                                      }

                                      return FormField<StateModels>(
                                        initialValue:
                                            controller.selectedState.value,
                                        builder: (stateField) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextField(
                                                enabled:
                                                    !isDisabled, // 🔹 Disable when loading
                                                focusNode:
                                                    _statePresentFocusNode,
                                                controller: controller
                                                    .statePresentTextController,
                                                decoration: InputDecoration(
                                                  labelText: loc.searchState,
                                                  labelStyle: TextStyle(
  color: Theme.of(context).colorScheme.primary,
),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _showResultsPresentState
                                                          ? Icons.arrow_drop_up
                                                          : Icons
                                                                .arrow_drop_down_outlined,
                                                    ),
                                                    onPressed: () {
                                                      if (!isDisabled) {
                                                        setState(() {
                                                          _showResultsPresentState =
                                                              !_showResultsPresentState;
                                                          _showResultsPresentCountr =
                                                              false;
                                                          _showResultsContCountr =
                                                              false;
                                                          _showResults = false;

                                                          // if (_showResultsPresentState) {
                                                          //   _statePresentFocusNode
                                                          //       .requestFocus();
                                                          // } else {
                                                          //   _statePresentFocusNode
                                                          //       .unfocus();
                                                          // }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                onTap: isDisabled
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _showResultsPresentState =
                                                              true;
                                                        });
                                                      },
                                                onChanged: isDisabled
                                                    ? null
                                                    : (value) {
                                                        if (controller
                                                                .isSameAsPermanent ==
                                                            true) {
                                                          toggleSameAddress(
                                                            controller
                                                                .isSameAsPermanent,
                                                          );
                                                          controller
                                                                  .stateTextController
                                                                  .text =
                                                              value;
                                                        }

                                                        // controller
                                                        //     .fetchState(); // 🔹 API call (sets loading)

                                                        setState(() {
                                                          _statePresentSearchQuery =
                                                              value;
                                                          _showResultsPresentState =
                                                              true;

                                                          if (value.isEmpty) {
                                                            controller
                                                                    .selectedState
                                                                    .value =
                                                                null;
                                                            controller
                                                                .statePresentTextController
                                                                .clear();
                                                          }

                                                          controller
                                                                  .statePresentTextController
                                                                  .text =
                                                              value;
                                                        });
                                                      },
                                              ),
                                              const SizedBox(height: 8),

                                              // 🔹 Show dropdown only if not disabled
                                              if (!isDisabled &&
                                                  _showResultsPresentState)
                                                Container(
                                                  width: double.infinity,
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxHeight: 250,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: filteredStates.isEmpty
                                                      ? const Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            child: Text(
                                                              'No matching states',
                                                            ),
                                                          ),
                                                        )
                                                      : ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              filteredStates
                                                                  .length,
                                                          itemBuilder: (context, index) {
                                                            final stateModel =
                                                                filteredStates[index];
                                                            final isSelected =
                                                                controller
                                                                    .statePresentTextController
                                                                    .text ==
                                                                stateModel.code;

                                                            return InkWell(
                                                              onTap: () {
                                                                if (controller
                                                                        .isSameAsPermanent ==
                                                                    true) {
                                                                  toggleSameAddress(
                                                                    controller
                                                                        .isSameAsPermanent,
                                                                  );
                                                                  controller
                                                                          .stateTextController
                                                                          .text =
                                                                      stateModel
                                                                          .name;
                                                                }

                                                                setState(() {
                                                                  controller
                                                                          .statePresentTextController
                                                                          .text =
                                                                      stateModel
                                                                          .name;
                                                                  controller
                                                                          .selectedContState
                                                                          .value =
                                                                      stateModel;
                                                                  controller
                                                                          .selectedState
                                                                          .value =
                                                                      stateModel;
                                                                  stateField
                                                                      .didChange(
                                                                        stateModel,
                                                                      );
                                                                  _statePresentSearchQuery =
                                                                      '';
                                                                  _showResultsPresentState =
                                                                      false;
                                                                  _statePresentFocusNode
                                                                      .unfocus();
                                                                });
                                                              },
                                                              child: Container(
                                                                color:
                                                                    isSelected
                                                                    ? const Color.fromARGB(
                                                                        76,
                                                                        143,
                                                                        142,
                                                                        142,
                                                                      ) // 🔹 Grey highlight
                                                                    : Colors
                                                                          .transparent,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      stateModel
                                                                          .name,
                                                                      style: TextStyle(
                                                                        // fontWeight:
                                                                        //     isSelected
                                                                        //     ? FontWeight.bold
                                                                        //     : FontWeight.normal,
                                                                        // color: Colors
                                                                        //     .black,
                                                                      ),
                                                                    ),
                                                                    // if (isSelected)
                                                                    //   const Icon(
                                                                    //     Icons
                                                                    //         .check,
                                                                    //     color: Colors
                                                                    //         .grey,
                                                                    //     size:
                                                                    //         18,
                                                                    //   ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                ),
                                              if (stateField.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    stateField.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                }),

                                const SizedBox(height: 8),

                                _textField(
                                  loc.zipCode,
                                  controller.postalCode,
                                  onChanged: (value) {
                                    if (controller.isSameAsPermanent == true) {
                                      toggleSameAddress(
                                        controller.isSameAsPermanent,
                                      );
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter ZIP code';
                                    }

                                    // Allow only alphanumeric (letters + numbers)
                                    final alphanumeric = RegExp(
                                      r'^[a-zA-Z0-9]+$',
                                    );
                                    if (!alphanumeric.hasMatch(value)) {
                                      return 'Only letters and numbers are allowed';
                                    }

                                    // Disallow only letters (no digits)
                                    final onlyLetters = RegExp(r'^[a-zA-Z]+$');
                                    if (onlyLetters.hasMatch(value)) {
                                      return 'ZIP code must include at least one number';
                                    }

                                    return null; // ✅ valid
                                  },
                                ),

                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: controller.isSameAsPermanent,
                                        onChanged: toggleSameAddress,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      loc.sameAsPermanentAddress,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    loc.presentAddress,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _textField(
                                  loc.street,
                                  controller.contactStreetController,
                                  isEnabled: _disableField,
                                ),
                                _textField(
                                  loc.city,
                                  controller.contactCityController,
                                  isEnabled: _disableField,
                                  onChanged: (value) {
                                    print("Name changed to: $value");
                                    // You can add setState or controller logic here
                                  },
                                ),
                                const SizedBox(height: 8),
                                Obx(() {
                                  final countryList = controller.countries;
                                  final lowerQuery = _ContCountry.toLowerCase();

                                  final filteredCountry = [
                                    ...countryList.where(
                                      (c) => c.name.toLowerCase().startsWith(
                                        lowerQuery,
                                      ),
                                    ),
                                    ...countryList.where(
                                      (c) =>
                                          c.name.toLowerCase().contains(
                                            lowerQuery,
                                          ) &&
                                          !c.name.toLowerCase().startsWith(
                                            lowerQuery,
                                          ),
                                    ),
                                    ...countryList.where(
                                      (c) => !c.name.toLowerCase().contains(
                                        lowerQuery,
                                      ),
                                    ),
                                  ];

                                  if (!_didPopulateInitialcontcountry &&
                                      controller.selectedContCountry.value !=
                                          null &&
                                      controller
                                          .selectedContCountry
                                          .value!
                                          .name
                                          .isNotEmpty) {
                                    controller.countryConstTextController.text =
                                        controller
                                            .selectedContCountry
                                            .value!
                                            .name;
                                    _didPopulateInitialcontcountry = true;
                                  }

                                  return FormField<Country>(
                                    initialValue:
                                        controller.selectedContCountry.value,
                                    enabled: _disableField,
                                    validator: (value) {
                                      // ✅ Validation logic

                                      if (controller
                                          .countryConstTextController
                                          .text
                                          .isEmpty) {
                                        return 'Please select a country';
                                      }
                                      return null;
                                    },
                                    builder: (stateField) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 🔹 Country Field
                                          TextField(
                                            enabled: _disableField,
                                            controller: controller
                                                .countryConstTextController,
                                            focusNode: _contCountryFocusNode,
                                            autofocus: false,

                                            decoration: InputDecoration(
                                              labelText:
                                                  '${loc.searchCountry}*',
                                                  labelStyle: TextStyle(
  color: Theme.of(context).colorScheme.primary,
),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: !_disableField,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _showResultsContCountr
                                                      ? Icons.arrow_drop_up
                                                      : Icons
                                                            .arrow_drop_down_outlined,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _showResultsContCountr =
                                                        !_showResultsContCountr;
                                                    _showResultsPresentCountr =
                                                        false;
                                                    _showResultsPresentState =
                                                        false;
                                                    _showResults = false;
                                                    if (_showResultsContCountr) {
                                                      _contCountryFocusNode
                                                          .requestFocus();
                                                    } else {
                                                      _contCountryFocusNode
                                                          .unfocus();
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _ContCountry = value;
                                                _showResultsContCountr = true;

                                                if (value.isEmpty) {
                                                  controller
                                                          .selectedContCountry
                                                          .value =
                                                      null;
                                                  stateField.didChange(null);
                                                }
                                              });
                                            },
                                            onTap: () {
                                              setState(() {
                                                _showResultsContCountr = true;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          if (_showResultsContCountr)
                                            Container(
                                              width: 320,
                                              constraints: const BoxConstraints(
                                                maxHeight: 250,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                // color: Colors.white,
                                              ),
                                              child: filteredCountry.isEmpty
                                                  ? const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          12,
                                                        ),
                                                        child: Text(
                                                          'No matching countries',
                                                        ),
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: filteredCountry
                                                          .length,

                                                      itemBuilder: (context, index) {
                                                        final stateModel =
                                                            filteredCountry[index];
                                                        final isSelected =
                                                            controller
                                                                .countryConstTextController
                                                                .text ==
                                                            stateModel.name;
                                                        final countryModel =
                                                            filteredCountry[index];
                                                        return InkWell(
                                                          onTap: () {
                                                            FocusScope.of(
                                                              context,
                                                            ).unfocus();

                                                            controller
                                                                    .selectedContectCountryCode =
                                                                countryModel
                                                                    .code;

                                                            // 🔹 Trigger state API call
                                                            controller
                                                                .fetchSecondState();

                                                            // 🔹 Reset state field
                                                            controller
                                                                    .stateTextController
                                                                    .text =
                                                                "";
                                                            controller
                                                                    .selectedContState
                                                                    .value =
                                                                null;

                                                            setState(() {
                                                              controller
                                                                      .countryConstTextController
                                                                      .text =
                                                                  countryModel
                                                                      .name;
                                                              _ContCountry = '';
                                                              _showResultsContCountr =
                                                                  false;
                                                            });

                                                            controller
                                                                    .selectedContCountry
                                                                    .value =
                                                                countryModel;
                                                            stateField
                                                                .didChange(
                                                                  countryModel,
                                                                );
                                                          },
                                                          child: Container(
                                                            color: isSelected
                                                                ? const Color.fromARGB(
                                                                    76,
                                                                    143,
                                                                    142,
                                                                    142,
                                                                  ) // 🔹 Grey highlight
                                                                : Colors
                                                                      .transparent,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  countryModel
                                                                      .name,
                                                                  style: TextStyle(
                                                                    // fontWeight:
                                                                    //     isSelected
                                                                    //     ? FontWeight.bold
                                                                    //     : FontWeight.normal,
                                                                    // color: Colors
                                                                    //     .black,
                                                                  ),
                                                                ),
                                                                // if (isSelected)
                                                                //   const Icon(
                                                                //     Icons
                                                                //         .check,
                                                                //     color: Colors
                                                                //         .grey,
                                                                //     size:
                                                                //         18,
                                                                //   ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                          if (stateField.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                                left: 12,
                                              ),
                                              child: Text(
                                                stateField.errorText!,
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                }),

                                const SizedBox(height: 8),

                                // 🔹 STATE FIELD WITH LOADER + HIGHLIGHT + DISABLE LOGIC
                                Obx(() {
                                  final isLoading =
                                      controller.isFetchingStatesSecond.value;

                                  return FutureBuilder<List<StateModels>>(
                                    future:
                                        statesFuture ??
                                        Future.value(<StateModels>[]),
                                    builder: (context, snapshot) {
                                      final statesList = controller.statesconst;
                                      final lowerQuery = _stateSearchQuery
                                          .toLowerCase();

                                      final filteredStates = [
                                        ...statesList.where(
                                          (s) => s.name
                                              .toLowerCase()
                                              .startsWith(lowerQuery),
                                        ),
                                        ...statesList.where(
                                          (s) =>
                                              s.name.toLowerCase().contains(
                                                lowerQuery,
                                              ) &&
                                              !s.name.toLowerCase().startsWith(
                                                lowerQuery,
                                              ),
                                        ),
                                        ...statesList.where(
                                          (s) => !s.name.toLowerCase().contains(
                                            lowerQuery,
                                          ),
                                        ),
                                      ];

                                      if (!_didPopulateInitial &&
                                          controller
                                              .contactStateController
                                              .isNotEmpty) {
                                        controller.stateTextController.text =
                                            controller.contactStateController;
                                        _didPopulateInitial = true;
                                      }

                                      return FormField<StateModels>(
                                        enabled:
                                            !isLoading ||
                                            _disableField, // 🔹 Disable if fetching
                                        initialValue:
                                            controller.selectedContState.value,
                                        builder: (stateField) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextField(
                                                enabled:
                                                    isLoading || _disableField,
                                                autofocus: false,
                                                focusNode:
                                                    _contactStateFocusNode,
                                                controller: controller
                                                    .stateTextController,
                                                decoration: InputDecoration(
                                                  labelText: loc.searchState,
                                                  labelStyle: TextStyle(
  color: Theme.of(context).colorScheme.primary,
),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  filled: !_disableField,

                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _showResults
                                                          ? Icons.arrow_drop_up
                                                          : Icons
                                                                .arrow_drop_down_outlined,
                                                    ),
                                                    onPressed: () {
                                                      if (!isLoading) {
                                                        setState(() {
                                                          _showResults =
                                                              !_showResults;
                                                          _showResultsPresentCountr =
                                                              false;
                                                          _showResultsContCountr =
                                                              false;
                                                          _showResultsPresentState =
                                                              false;

                                                          if (_showResults) {
                                                            _contactStateFocusNode
                                                                .requestFocus();
                                                          } else {
                                                            _contactStateFocusNode
                                                                .unfocus();
                                                          }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                onChanged: isLoading
                                                    ? null
                                                    : (value) {
                                                        // controller
                                                        //     .fetchSecondState(); // Fetch if needed

                                                        setState(() {
                                                          _stateSearchQuery =
                                                              value;
                                                          _showResults = true;

                                                          if (value.isEmpty) {
                                                            controller
                                                                    .selectedState
                                                                    .value =
                                                                null;
                                                            controller
                                                                .stateTextController
                                                                .clear();
                                                          } else {
                                                            controller
                                                                    .stateTextController
                                                                    .text =
                                                                value;
                                                          }
                                                        });
                                                      },
                                                onTap: isLoading
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _showResults = true;
                                                        });
                                                      },
                                              ),
                                              const SizedBox(height: 8),
                                              if (!isLoading && _showResults)
                                                Container(
                                                  width: double.infinity,
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxHeight: 250,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    // color: Colors.white,
                                                  ),
                                                  child: filteredStates.isEmpty
                                                      ? const Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            child: Text(
                                                              'No matching states',
                                                            ),
                                                          ),
                                                        )
                                                      : ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              filteredStates
                                                                  .length,
                                                          itemBuilder: (context, index) {
                                                            final stateModel =
                                                                filteredStates[index];
                                                            final isSelected =
                                                                controller
                                                                    .selectedContState
                                                                    .value
                                                                    ?.code ==
                                                                stateModel.code;

                                                            return InkWell(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                  context,
                                                                ).unfocus();

                                                                setState(() {
                                                                  controller
                                                                          .stateTextController
                                                                          .text =
                                                                      stateModel
                                                                          .name;
                                                                  controller
                                                                          .contactStateController =
                                                                      stateModel
                                                                          .code;
                                                                  controller
                                                                          .selectedContState
                                                                          .value =
                                                                      stateModel;
                                                                  _stateSearchQuery =
                                                                      '';
                                                                  _showResults =
                                                                      false;
                                                                });

                                                                stateField
                                                                    .didChange(
                                                                      stateModel,
                                                                    );
                                                              },
                                                              child: Container(
                                                                color:
                                                                    isSelected
                                                                    ? const Color.fromARGB(
                                                                        148,
                                                                        143,
                                                                        142,
                                                                        142,
                                                                      ) // 🔹 Grey highlight
                                                                    : Colors
                                                                          .transparent,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      stateModel
                                                                          .name,
                                                                      // style: TextStyle(
                                                                      //   fontWeight:
                                                                      //       isSelected
                                                                      //       ? FontWeight.bold
                                                                      //       : FontWeight.normal,
                                                                      //   // color: Colors
                                                                      //       // .black,
                                                                      // ),
                                                                    ),
                                                                    // if (isSelected)
                                                                    //   const Icon(
                                                                    //     Icons.check,
                                                                    //     color: Colors.grey,
                                                                    //     size: 18,
                                                                    //   ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                ),
                                              if (stateField.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    stateField.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                }),

                                // _dropdown(
                                //     "State",
                                //     controller.contactStateController,
                                //     controller.stateList, (String? val) {
                                //   if (val != null) {
                                //     setState(() =>
                                //         controller.contactStateController = val);
                                //   }
                                // }),
                                _textField(
                                  loc.zipCode,
                                  controller.contactPostalController,
                                  isEnabled: _disableField,
                                  onChanged: (value) {
                                    print("ZIP code changed to: $value");
                                  },
                                  validator: (value) {
                                    // Allow empty field — it's optional
                                    if (value == null || value.trim().isEmpty) {
                                      return null;
                                    }

                                    // ✅ Allow only alphanumeric (letters + numbers)
                                    final alphanumeric = RegExp(
                                      r'^[a-zA-Z0-9]+$',
                                    );
                                    if (!alphanumeric.hasMatch(value)) {
                                      return 'Only letters and numbers are allowed';
                                    }

                                    // ❌ Disallow only letters (must contain at least one number)
                                    final onlyLetters = RegExp(r'^[a-zA-Z]+$');
                                    if (onlyLetters.hasMatch(value)) {
                                      return 'ZIP code must include at least one number';
                                    }

                                    return null; // ✅ valid input
                                  },
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        controller.stateTextController.clear();
                                        // controller.countryConstTextController.clear();
                                        controller.contactCityController
                                            .clear();
                                        controller.contactStreetController
                                            .clear();

                                        controller.stateTextController.clear();
                                        controller.contactPostalController
                                            .clear();
                                        controller.selectedTimezone.value =
                                            Timezone(
                                              code: '',
                                              name: '',
                                              id: '',
                                            );
                                        controller
                                            .selectedPaymentSetting
                                            .value = PaymentMethodModel(
                                          paymentMethodName: '',
                                          paymentMethodId: '',
                                          reimbursible: false,
                                        );
                                        controller.selectedCurrency.value =
                                            null;
                                        controller.presentCountryTextController
                                            .clear();
                                        controller.selectedLanguage = null;
                                        controller.selectedLocale.value =
                                            Locales(code: '', name: '');
                                        controller.contactStreetController
                                            .clear();
                                        controller.contactCityController
                                            .clear();
                                        controller.contactPostalController
                                            .clear();
                                        controller.countryConstTextController
                                            .clear();
                                        controller.stateTextController.clear();
                                        controller.presentCountryTextController
                                            .clear();
                                        controller.statePresentTextController
                                            .clear();
                                        controller.street.clear();
                                        controller.city.clear();
                                        controller.postalCode.clear();

                                        controller.selectedContectCountryCode =
                                            '';
                                        controller.selectedCountryCode.text =
                                            '';
                                        controller.selectedCountry.value = null;
                                        controller.selectedTimezone.value =
                                            Timezone(
                                              code: '',
                                              name: '',
                                              id: '',
                                            );
                                        controller
                                            .selectedPaymentSetting
                                            .value = PaymentMethodModel(
                                          paymentMethodName: '',
                                          paymentMethodId: '',
                                          reimbursible: false,
                                        );
                                        controller.selectedCurrency.value =
                                            null;
                                        controller.selectedLanguage = null;
                                        controller.selectedLocale.value =
                                            Locales(code: '', name: '');
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.dashboard_Main,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.gradientStart,
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: AppColors.gradientStart,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(loc.cancel),
                                    ),
                                    Obx(() {
                                      return ElevatedButton(
                                        onPressed:
                                            (controller
                                                .isGEPersonalInfoLoading
                                                .value)
                                            ? null
                                            : () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();
                                                  controller
                                                      .updateProfileDetails();
                                                }

                                                // Navigator.pop(context);
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.gradientStart,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        child:
                                            controller
                                                .isGEPersonalInfoLoading
                                                .value
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(loc.save),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Obx(() {
                            final isEnabled = controller.userPref.value;
                            print("isEnabledss${controller.userPref.value}");
                            return AbsorbPointer(
                              absorbing:
                                  !isEnabled, // disables taps when loading
                              child: Opacity(
                                opacity: isEnabled
                                    ? 1.0
                                    : 0.5, // dim UI when disabled
                                child: _buildSection(
                                  title: loc.localizationPreferences,
                                  children: [
                                    const SizedBox(height: 20),

                                    const SizedBox(height: 20),
                                    Obx(() {
                                      return SearchableMultiColumnDropdownField<
                                        Timezone
                                      >(
                                        labelText: loc.timeZone,
                                        columnHeaders: [
                                          loc.timezoneName,
                                          loc.timezoneCode,
                                          loc.timezoneId,
                                        ],
                                        items: controller.timezone,
                                        selectedValue:
                                            controller.selectedTimezone.value,
                                        searchValue: (t) => ' ${t.id}',
                                        displayText: (t) => t.name,
                                        validator: (t) => t == null
                                            ? 'Please pick a timezone'
                                            : null,
                                        onChanged: (t) {
                                          controller.selectedTimezone.value =
                                              t!;
                                        },
                                        rowBuilder: (t, searchQuery) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  // flex: 2,
                                                  child: Text(
                                                    t.name,
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  // flex: 1,
                                                  child: Text(
                                                    t.code.toString(),
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  // flex: 1,
                                                  child: Text(
                                                    t.id.toString(),
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                    const SizedBox(height: 20),
                                    Obx(() {
                                      return SearchableMultiColumnDropdownField<
                                        PaymentMethodModel
                                      >(
                                        labelText: loc.defaultPayment,
                                        columnHeaders: [
                                          loc.paymentId,
                                          loc.paymentName,
                                        ],
                                        items: controller
                                            .selectedPaymentSettinglist,
                                        selectedValue: controller
                                            .selectedPaymentSetting
                                            .value,
                                        searchValue: (t) =>
                                            '${t.paymentMethodName} ${t.paymentMethodId}',
                                        displayText: (t) => t.paymentMethodName,
                                        validator: (t) => t == null
                                            ? 'Please pick a timezone'
                                            : null,
                                        onChanged: (t) {
                                          controller
                                                  .selectedPaymentSetting
                                                  .value =
                                              t!;
                                          controller.prefPaymentMethod.text =
                                              t.paymentMethodId;
                                        },
                                        // controller: controller.prefPaymentMethod,
                                        rowBuilder: (t, searchQuery) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    t.paymentMethodId,
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    t.paymentMethodName
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                    const SizedBox(height: 20),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(horizontal: 8),
                                    //   child:
                                    Obx(
                                      () =>
                                          SearchableMultiColumnDropdownField<
                                            Currency
                                          >(
                                            labelText: loc.defaultCurrency,
                                            columnHeaders: [
                                              loc.code,
                                              loc.name,
                                              loc.symbol,
                                            ],
                                            items: controller.currencies,
                                            selectedValue: controller
                                                .selectedCurrency
                                                .value,
                                            searchValue: (c) =>
                                                '${c.code} ${c.name} ${c?.symbol ?? ''}',
                                            displayText: (c) =>
                                                '${c.code} ${c.name} ${c.symbol}',
                                            validator: (c) => c == null
                                                ? 'Please pick a currency'
                                                : null,
                                            onChanged: (c) {
                                              controller
                                                      .selectedCurrency
                                                      .value =
                                                  c;
                                            },
                                            rowBuilder: (c, searchQuery) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        c.code,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        c.name,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        c.symbol,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                        ),
                                                      ), // Safe symbol handling
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Obx(
                                    //   () =>
                                    //       SearchableMultiColumnDropdownField<Currency>(
                                    //     labelText: loc.defaultCurrency,
                                    //     columnHeaders: const ['Code', 'Name', 'Symbol'],
                                    //     items: controller.currencies,
                                    //     selectedValue:
                                    //         controller.selectedCurrency.value,
                                    //     displayText: (c) =>
                                    //         '${c.code} ${c.name} ${c.symbol}',
                                    //     searchValue: (c) =>
                                    //         '${c.code} ${c.name} ${c.symbol}',
                                    //     validator: (c) =>
                                    //         c == null ? 'Please pick a currency' : null,
                                    //     onChanged: (c) {
                                    //       controller.selectedCurrency.value = c;
                                    //     },
                                    //     rowBuilder: (c, searchQuery) {
                                    //       Widget highlight(String text) {
                                    //         final query = searchQuery.toLowerCase();
                                    //         final lower = text.toLowerCase();
                                    //         final matchIndex = lower.indexOf(query);

                                    //         if (matchIndex == -1 || query.isEmpty) {
                                    //           return Text(
                                    //             text,
                                    //             style: const TextStyle(
                                    //               fontSize: 11,
                                    //               fontFamily: 'Roboto',
                                    //             ),
                                    //           );
                                    //         }

                                    //         final end = matchIndex + query.length;
                                    //         return RichText(
                                    //           text: TextSpan(
                                    //             children: [
                                    //               TextSpan(
                                    //                 text: text.substring(0, matchIndex),
                                    //                 style: const TextStyle(
                                    //                   color: Colors.black,
                                    //                   fontSize: 11,
                                    //                   fontFamily: 'Roboto',
                                    //                 ),
                                    //               ),
                                    //               TextSpan(
                                    //                 text:
                                    //                     text.substring(matchIndex, end),
                                    //                 style: const TextStyle(
                                    //                   color: Colors.black,
                                    //                   fontWeight: FontWeight.bold,
                                    //                   fontSize: 11,
                                    //                   fontFamily: 'Roboto',
                                    //                 ),
                                    //               ),
                                    //               TextSpan(
                                    //                 text: text.substring(end),
                                    //                 style: const TextStyle(
                                    //                   color: Colors.black,
                                    //                   fontSize: 11,
                                    //                   fontFamily: 'Roboto',
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         );
                                    //       }

                                    //       return Padding(
                                    //         padding: const EdgeInsets.symmetric(
                                    //             vertical: 12, horizontal: 16),
                                    //         child: Row(
                                    //           children: [
                                    //             Expanded(child: highlight(c.code)),
                                    //             Expanded(child: highlight(c.name)),
                                    //             Expanded(
                                    //                 child: highlight(
                                    //                     cleanSymbol(c.symbol))),
                                    //           ],
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),

                                    // const SizedBox(height: 20),

                                    // LOCALE DROPDOWN
                                    Obx(
                                      () =>
                                          SearchableMultiColumnDropdownField<
                                            Locales
                                          >(
                                            labelText: loc.selectLocale,
                                            columnHeaders: [loc.code, loc.name],
                                            items: controller.localeData,
                                            selectedValue:
                                                controller.selectedLocale.value,
                                            searchValue: (locale) =>
                                                '${locale.code} ${locale.name}',
                                            displayText: (locale) =>
                                                '${locale.code} — ${locale.name}',
                                            validator: (locale) =>
                                                locale == null
                                                ? 'Please select a locale'
                                                : null,
                                            onChanged: (locale) {
                                              setState(() {
                                                controller
                                                        .selectedLocale
                                                        .value =
                                                    locale!;
                                              });
                                            },
                                            rowBuilder: (locale, searchQuery) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        locale.code,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        locale.name,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                    const SizedBox(height: 20),

                                    SearchableMultiColumnDropdownField<
                                      Language
                                    >(
                                      labelText: loc.defaultLanguage,
                                      columnHeaders: [
                                        loc.languageName,
                                        loc.languageId,
                                      ],
                                      items: controller.language,
                                      selectedValue:
                                          controller.selectedLanguage,
                                      searchValue: (lang) =>
                                          '${lang.name} ${lang.code}',
                                      displayText: (lang) => lang.name,
                                      validator: (lang) => lang == null
                                          ? loc.pleasePickLanguage
                                          : null,
                                      onChanged: (lang) {
                                        setState(() {
                                          controller.selectedLanguage = lang;
                                        });
                                      },
                                      rowBuilder: (lang, searchQuery) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  lang.name,
                                                  style: TextStyle(fontSize: 8),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  lang.code,
                                                  style: TextStyle(fontSize: 8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    FormField<MapEntry<String, String>>(
                                      builder: (state) {
                                        return MultiColumnDropdownField<
                                          MapEntry<String, String>
                                        >(
                                          state: state,
                                          labelText: loc.selectDateFormat,
                                          columnHeaders: [loc.format],
                                          items: controller
                                              .dateFormatMap
                                              .entries
                                              .toList(),
                                          dropdownHeight: 300,
                                          dropdownWidth: 300,

                                          onChanged: (entry) {
                                            setState(() {
                                              controller.selectedFormat = entry;
                                            });
                                          },
                                          rowBuilder: (entry) {
                                            final isSelected =
                                                controller
                                                    .selectedFormat
                                                    ?.key ==
                                                entry.key;

                                            return Container(
                                              color: isSelected
                                                  ? const Color.fromARGB(
                                                      144,
                                                      173,
                                                      173,
                                                      173,
                                                    )
                                                  : Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.value,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        // fontWeight: isSelected
                                                        //     ? FontWeight.bold
                                                        //     : FontWeight.normal,
                                                        // color: isSelected
                                                        //     ? Colors.black
                                                        //     : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },

                                          selectedDisplay: (entry) =>
                                              entry.value,
                                        );
                                      },
                                      initialValue: controller.selectedFormat,
                                    ),

                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Aligned in a row using Wrap
                                        SizedBox(
                                          width: double.infinity,
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: controller.emails.map((
                                              email,
                                            ) {
                                              return Chip(
                                                label: Text(email),
                                                deleteIcon: const Icon(
                                                  Icons.close,
                                                ),
                                                onDeleted: () =>
                                                    _removeEmail(email),
                                              );
                                            }).toList(),
                                          ),
                                        ),

                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                         StatefulBuilder(
  builder: (context, setLocalState) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: loc.enterEmail,
        border: OutlineInputBorder(),
        errorText: _errorText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onChanged: (val) {
        setLocalState(() {});  // only rebuilds email field
        _validateOnChange(val); // your logic stays same
      },
      onSubmitted: _addEmails,
    );
  },
),

                                            const SizedBox(height: 8),
                                            if (isTyping)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: isTyping
                                                        ? _cancelInput
                                                        : null,
                                                    child: Text(loc.cancel),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    onPressed:
                                                        isTyping &&
                                                            !hasEmailError
                                                        ? () => _addEmails(
                                                            _controller.text,
                                                          )
                                                        : null,
                                                    child: Text(loc.submit),
                                                  ),
                                                ],
                                              ),
                                            FutureBuilder<Map<String, bool>>(
                                             future: featureFuture,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const SizedBox.shrink(); // hide while loading
                                                }

                                                if (!snapshot.hasData) {
                                                  return const SizedBox.shrink(); // hide if API fails
                                                }

                                                final featureStates =
                                                    snapshot.data!;
                                                final isEnabled =
                                                    featureStates['AllowThemeSettings'] ??
                                                    false;

                                                // ❌ hide completely if disabled
                                                if (!isEnabled)
                                                  return const SizedBox.shrink();

                                                // ✅ show if enabled
                                                return ColorPickerGrid();
                                              },
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const SizedBox(height: 20),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    controller
                                                        .stateTextController
                                                        .clear();
                                                    // controller.countryConstTextController.clear();
                                                    controller
                                                        .contactCityController
                                                        .clear();
                                                    controller
                                                        .contactStreetController
                                                        .clear();

                                                    controller
                                                        .stateTextController
                                                        .clear();
                                                    controller
                                                        .contactPostalController
                                                        .clear();
                                                    controller
                                                        .selectedTimezone
                                                        .value = Timezone(
                                                      code: '',
                                                      name: '',
                                                      id: '',
                                                    );
                                                    controller
                                                            .selectedPaymentSetting
                                                            .value =
                                                        PaymentMethodModel(
                                                          paymentMethodName: '',
                                                          paymentMethodId: '',
                                                          reimbursible: false,
                                                        );
                                                    controller
                                                            .selectedCurrency
                                                            .value =
                                                        null;
                                                    controller
                                                        .presentCountryTextController
                                                        .clear();
                                                    controller
                                                            .selectedLanguage =
                                                        null;
                                                    controller
                                                        .selectedLocale
                                                        .value = Locales(
                                                      code: '',
                                                      name: '',
                                                    );
                                                    controller
                                                        .contactStreetController
                                                        .clear();
                                                    controller
                                                        .contactCityController
                                                        .clear();
                                                    controller
                                                        .contactPostalController
                                                        .clear();
                                                    controller
                                                        .countryConstTextController
                                                        .clear();
                                                    controller
                                                        .stateTextController
                                                        .clear();
                                                    controller
                                                        .presentCountryTextController
                                                        .clear();
                                                    controller
                                                        .statePresentTextController
                                                        .clear();
                                                    controller.street.clear();
                                                    controller.city.clear();
                                                    controller.postalCode
                                                        .clear();

                                                    controller
                                                            .selectedContectCountryCode =
                                                        '';
                                                    controller
                                                            .selectedCountryCode
                                                            .text =
                                                        '';
                                                    controller
                                                            .selectedCountry
                                                            .value =
                                                        null;
                                                    controller
                                                        .selectedTimezone
                                                        .value = Timezone(
                                                      code: '',
                                                      name: '',
                                                      id: '',
                                                    );
                                                    controller
                                                            .selectedPaymentSetting
                                                            .value =
                                                        PaymentMethodModel(
                                                          paymentMethodName: '',
                                                          paymentMethodId: '',
                                                          reimbursible: false,
                                                        );
                                                    controller
                                                            .selectedCurrency
                                                            .value =
                                                        null;
                                                    controller
                                                            .selectedLanguage =
                                                        null;
                                                    controller
                                                        .selectedLocale
                                                        .value = Locales(
                                                      code: '',
                                                      name: '',
                                                    );
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRoutes.dashboard_Main,
                                                    );
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.gradientStart,
                                                    backgroundColor:
                                                        Colors.white,
                                                    side: const BorderSide(
                                                      color: AppColors
                                                          .gradientStart,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(loc.cancel),
                                                ),
                                                ElevatedButton(
                                                  onPressed:
                                                      controller
                                                          .buttonLoader
                                                          .value
                                                      ? null
                                                      : () {
                                                          FocusScope.of(
                                                            context,
                                                          ).unfocus();
                                                          controller
                                                              .userPreferences(
                                                                context,
                                                              );
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.gradientStart,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  child:
                                                      controller
                                                          .buttonLoader
                                                          .value
                                                      ? const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth: 2,
                                                              ),
                                                        )
                                                      : Text(loc.save),
                                                ),
                                                const SizedBox(height: 40),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    const SizedBox(height: 20),

                                    // other dropdowns here (Payment, Currency, Locale, etc.)

                                    // 💾 Save button
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AbsorbPointer(
        absorbing: _isSectionDisabled,
        child: Card(
          elevation: 2,
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
            textColor: Colors.deepPurple,
            iconColor: Colors.deepPurple,
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

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool isEnabled = true,
    void Function(String)? onChanged,
    String? Function(String?)? validator, // ✅ updated type
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
  color: Theme.of(context).colorScheme.primary,
),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: !isEnabled,
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.text =
                "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
          }
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String? hintText,
    IconData? icon,
    String? Function(String?)? validator,
    TextStyle? style,
  }) {
    final safeSelectedValue = items.contains(selectedValue)
        ? selectedValue
        : null;
    print("Selected: $safeSelectedValue");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: safeSelectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText ?? "Select $label",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 22,
          ),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        style: style,
        validator: validator,
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void showEditPopup(BuildContext context) {
    final controller = Get.put(Controller());
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text("Upload"),
              onTap: () async {
                Navigator.pop(context);

                final success = await controller.pickImageProfile();

                if (success) {
                  controller.isImageLoading.value = true;

                  // Wait for 2 seconds before calling the API
                  await Future.delayed(const Duration(seconds: 4));
                  await _loadProfileImage();
                } else {
                  debugPrint('Image upload failed, skipping profile reload.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove"),
              onTap: () async {
                Navigator.pop(context);
                controller.isImageLoading.value = true;
                final success = await controller.deleteProfilePicture();
                if (success) {
                  print("test1");
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('profileImagePath');
                  setState(() {
                    profileImage.value = null;
                    controller.isImageLoading.value = false;
                  }); // refreshes the entire UI
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
