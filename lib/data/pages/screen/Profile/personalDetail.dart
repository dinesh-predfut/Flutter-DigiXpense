import 'dart:async';
import 'dart:ffi';

import 'package:digi_xpense/core/comman/widgets/multiColumnDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:provider/provider.dart';
import '../../../../core/comman/widgets/button.dart';
import '../../../../core/comman/widgets/dateSelector.dart';
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
  FocusNode _contactStateFocusNode = FocusNode();
  FocusNode _contCountryFocusNode = FocusNode();
  final TextEditingController textcontroller = TextEditingController();
  final TextEditingController _statePresentStateTextController =
      TextEditingController();

  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> filteredOptions = [];
  List<Map<String, dynamic>> filteredStateOptions = [];
  FocusNode _statePresentFocusNode = FocusNode();
  Future<List<StateModels>>? statesFuture;
  Future<List<Country>>? constCountryFuture;
  String _stateSearchQuery = '';
  String _statePresentSearchQuery = '';
  RxBool isButtonDisabled = false.obs;
  bool isTyping = false;
  String _ContCountry = '';
  String _presentCountry = '';
  bool _showResults = false;
  bool _showResultsContCountr = false;
  bool _disableField = true;
  bool _showResultsPresentCountr = false;
  bool _showResultsPresentState = false;
  bool showDropdown = false;
  bool _didPopulateInitialstate = false;
  bool _didPopulateInitialCoun = false;
  bool _didPopulateInitial = false;
  bool _didPopulateInitialcountry = false;
  bool _didPopulateInitialcontcountry = false;
  bool hasEmailError = false;
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

  String cleanSymbol(String symbol) {
    // Detect corrupted ₹ based on UTF-8 misinterpretation
    if (symbol.codeUnits.toString() == '[226, 130, 161]') {
      print("Corrupted symbol found → Replacing with ₹");
      return '₹';
    }
    return symbol;
  }

  void _addEmails(String value) {
    _validateOnChange(value);

    if (!hasEmailError) {
      final newEmails = value
          .split(',')
          .map((e) => e.trim())
          .where((e) =>
              e.isNotEmpty &&
              _emailRegex.hasMatch(e) &&
              !controller.emails.contains(e))
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
    if (controller.profileImage.value == null) {
      controller.getProfilePicture();
    }

    // if (controller.contactStreetController.text.isEmpty &&
    //     controller.selectedContCountry.value == null &&
    //     controller.selectedContCountry.value == null) {
    controller.fetchCountries();
    controller.fetchTimeZoneList();
    controller.localeDropdown();
    controller.getPersonalDetails(context);

    controller.fetchLanguageList();
    controller.currencyDropDown();
    // }
    Timer(const Duration(seconds: 3), () {
      controller.getUserPref();
      if (controller.isSameAsPermanent) {
        setState(() {
          _disableField = false;
        });
      }
    });
    // controller.fetchState();
    controller.paymentMethode();

    // if (controller.selectedContCountry != null) {
    //   statesFuture = controller.fetchState();
    // }

    print("controller.country${controller.language}");
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
      print("isSameAsPermanent$value");
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
        controller.selectedContectCountryCode = controller.selectedCountryCode;
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

  @override
  void dispose() {
    _focusNode.dispose();
    textcontroller.dispose();
    _presentCountryFocusNode.dispose();
    _statePresentFocusNode.dispose();
    _contCountryFocusNode.dispose();
    _contactStateFocusNode.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.personalDetails)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Obx(() => CircleAvatar(
                      radius: 60,
                      backgroundImage: controller.isImageLoading.value
                          ? null
                          : controller.profileImage.value != null
                              ? FileImage(controller.profileImage.value!)
                              : null,
                      child: controller.isImageLoading.value
                          ? const CircularProgressIndicator()
                          : controller.profileImage.value == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                    )),
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
                      child: const Icon(Icons.edit,
                          color: Color.fromARGB(255, 1, 63, 114)),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.firstNameController.text.trim(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Center(
              child: Text(controller.personalEmailController.text,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        _buildSection(
                          title: loc.personalInformation,
                          children: [
                            _textField(
                                loc.firstName, controller.firstNameController,
                                isEnabled: false),
                            const SizedBox(height: 8),
                            _textField(
                                loc.middleName, controller.middleNameController,
                                isEnabled: false),
                            const SizedBox(height: 8),
                            _textField(
                                loc.lastName, controller.lastNameController,
                                isEnabled: false),
                            const SizedBox(height: 8),
                            _textField(loc.personalMailId,
                                controller.personalEmailController,
                                isEnabled: false),
                            const SizedBox(height: 8),
                            // _dateField("Date of Birth", controller.dobController),
                            // const SizedBox(height: 20),
                            SizedBox(
                                child: IntlPhoneField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: loc.phoneNumber,
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

                                final isValid =
                                    await PhoneNumberUtil.isValidPhoneNumber(
                                  phoneNumber: phone.completeNumber,
                                  isoCode: phone.countryISOCode,
                                );

                                if (isValid!) {
                                  isButtonDisabled.value = false;
                                  return 'Invalid phone number for ${phone.countryCode}';
                                }

                                return null;
                              },
                            )),

                            const SizedBox(height: 8),
                            _textField(loc.gender, controller.gender,
                                isEnabled: false),
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
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            _textField(
                              loc.street,
                              controller.street,
                              onChanged: (value) {
                                if (controller.isSameAsPermanent == true) {
                                  toggleSameAddress(
                                      controller.isSameAsPermanent);
                                }
                              },
                            ),
                            _textField(
                              loc.city,
                              controller.city,
                              onChanged: (value) {
                                if (controller.isSameAsPermanent == true) {
                                  toggleSameAddress(
                                      controller.isSameAsPermanent);
                                }
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Obx(() {
                              final countryList = controller.countries;
                              final lowerQuery = _presentCountry.toLowerCase();

                              final filteredPresentCountry = [
                                ...countryList.where((c) => c.name
                                    .toLowerCase()
                                    .startsWith(lowerQuery)),
                                ...countryList.where((c) =>
                                    c.name.toLowerCase().contains(lowerQuery) &&
                                    !c.name
                                        .toLowerCase()
                                        .startsWith(lowerQuery)),
                                ...countryList.where((c) =>
                                    !c.name.toLowerCase().contains(lowerQuery)),
                              ];

                              if (!_didPopulateInitialcountry &&
                                  controller.selectedCountry.value != null &&
                                  controller
                                      .selectedCountry.value!.code.isNotEmpty) {
                                controller.presentCountryTextController.text =
                                    controller.selectedCountry.value!.name;
                                _didPopulateInitialcountry = true;
                              }

                              return FormField<Country>(
                                initialValue: controller.selectedCountry.value,
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
                                          labelText: '${loc.searchCountry}*',
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
                                                _showResultsContCountr = false;
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
                                            _showResultsPresentCountr = true;
                                          });

                                          if (value.isEmpty) {
                                            controller.selectedCountry.value =
                                                null;
                                            stateField.didChange(null);
                                          }
                                        },
                                        onTap: () {
                                          setState(() {
                                            _showResultsPresentCountr = true;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      if (_showResultsPresentCountr)
                                        Container(
                                          width: 320,
                                          constraints: const BoxConstraints(
                                              maxHeight: 250),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Colors.white,
                                          ),
                                          child: filteredPresentCountry.isEmpty
                                              ? const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: Text(
                                                        'No matching countries'),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      filteredPresentCountry
                                                          .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final countryModel =
                                                        filteredPresentCountry[
                                                            index];
                                                    return InkWell(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();

                                                        if (controller
                                                            .isSameAsPermanent) {
                                                          toggleSameAddress(
                                                              controller
                                                                  .isSameAsPermanent);
                                                          controller
                                                                  .countryConstTextController
                                                                  .text =
                                                              countryModel.name;
                                                        }

                                                        controller
                                                                .selectedCountryName =
                                                            countryModel.name;
                                                        controller
                                                                .selectedCountryCode =
                                                            countryModel.code;
                                                        controller
                                                                .selectedCountry
                                                                .value =
                                                            countryModel;
                                                        controller.fetchState();

                                                        setState(() {
                                                          controller
                                                                  .presentCountryTextController
                                                                  .text =
                                                              countryModel.name;
                                                          _presentCountry = '';
                                                          _showResultsPresentCountr =
                                                              false;
                                                          controller
                                                              .statePresentTextController
                                                              .text = '';

                                                          if (controller
                                                              .isSameAsPermanent) {
                                                            controller
                                                                .stateTextController
                                                                .text = '';
                                                          }
                                                        });

                                                        stateField.didChange(
                                                            countryModel);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        child: Text(
                                                            countryModel.name),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      if (stateField.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, left: 12),
                                          child: Text(
                                            stateField.errorText!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              );
                            }),
                            const SizedBox(
                              height: 15,
                            ),
                            FutureBuilder<List<StateModels>>(
                              future:
                                  statesFuture ?? Future.value(<StateModels>[]),
                              builder: (context, snapshot) {
                                final statesList = controller.statesres;
                                final lowerQuery =
                                    _statePresentSearchQuery.toLowerCase();

                                final filteredStates = [
                                  ...statesList.where((s) => s.name
                                      .toLowerCase()
                                      .startsWith(lowerQuery)),
                                  ...statesList.where((s) =>
                                      s.name
                                          .toLowerCase()
                                          .contains(lowerQuery) &&
                                      !s.name
                                          .toLowerCase()
                                          .startsWith(lowerQuery)),
                                  ...statesList.where((s) => !s.name
                                      .toLowerCase()
                                      .contains(lowerQuery)),
                                ];

                                if (!_didPopulateInitialstate &&
                                    controller.selectedState.value != null &&
                                    controller
                                        .selectedState.value!.code.isNotEmpty) {
                                  _statePresentStateTextController.text =
                                      controller.selectedState.value!.name;
                                  _didPopulateInitialstate = true;
                                }

                                return FormField<StateModels>(
                                  initialValue: controller.selectedState.value,
                                  builder: (stateField) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          focusNode: _statePresentFocusNode,
                                          controller: controller
                                              .statePresentTextController,
                                          decoration: InputDecoration(
                                            labelText: loc.searchState,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _showResultsPresentState
                                                    ? Icons.arrow_drop_up
                                                    : Icons
                                                        .arrow_drop_down_outlined,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _showResultsPresentState =
                                                      !_showResultsPresentState;
                                                  _showResultsPresentCountr =
                                                      false;
                                                  _showResultsContCountr =
                                                      false;

                                                  _showResults = false;
                                                  if (_showResultsPresentState) {
                                                    _statePresentFocusNode
                                                        .requestFocus();
                                                  } else {
                                                    _statePresentFocusNode
                                                        .unfocus();
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _showResultsPresentState = true;
                                            });
                                          },
                                          onChanged: (value) {
                                            if (controller.isSameAsPermanent ==
                                                true) {
                                              toggleSameAddress(
                                                  controller.isSameAsPermanent);
                                              controller.stateTextController
                                                  .text = value;
                                            }

                                            controller.fetchState();

                                            setState(() {
                                              _statePresentSearchQuery = value;
                                              _showResultsPresentState = true;

                                              if (value.isEmpty) {
                                                controller.selectedState.value =
                                                    null;
                                                controller
                                                    .statePresentTextController
                                                    .clear();
                                              }

                                              controller
                                                  .statePresentTextController
                                                  .text = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        if (_showResultsPresentState)
                                          Container(
                                            width: double.infinity,
                                            constraints: const BoxConstraints(
                                                maxHeight: 250),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: filteredStates.isEmpty
                                                ? const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      child: Text(
                                                          'No matching states'),
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        filteredStates.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final stateModel =
                                                          filteredStates[index];
                                                      return InkWell(
                                                        onTap: () {
                                                          if (controller
                                                                  .isSameAsPermanent ==
                                                              true) {
                                                            toggleSameAddress(
                                                                controller
                                                                    .isSameAsPermanent);
                                                            controller
                                                                    .stateTextController
                                                                    .text =
                                                                stateModel.name;
                                                          }

                                                          setState(() {
                                                            controller
                                                                    .statePresentTextController
                                                                    .text =
                                                                stateModel.name;
                                                            controller
                                                                .selectedContState
                                                                .value = stateModel;
                                                            controller
                                                                    .selectedState
                                                                    .value =
                                                                stateModel;
                                                            stateField
                                                                .didChange(
                                                                    stateModel);
                                                            _statePresentSearchQuery =
                                                                '';
                                                            _showResultsPresentState =
                                                                false;
                                                            _statePresentFocusNode
                                                                .unfocus();
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Text(
                                                              stateModel.name),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        if (stateField.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, left: 12),
                                            child: Text(
                                              stateField.errorText!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _textField(
                              loc.zipCode,
                              controller.postalCode,
                              onChanged: (value) {
                                if (controller.isSameAsPermanent == true) {
                                  toggleSameAddress(
                                      controller.isSameAsPermanent);
                                }
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
                                loc.permanentAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                                ...countryList.where((c) => c.name
                                    .toLowerCase()
                                    .startsWith(lowerQuery)),
                                ...countryList.where((c) =>
                                    c.name.toLowerCase().contains(lowerQuery) &&
                                    !c.name
                                        .toLowerCase()
                                        .startsWith(lowerQuery)),
                                ...countryList.where((c) =>
                                    !c.name.toLowerCase().contains(lowerQuery)),
                              ];

                              if (!_didPopulateInitialcontcountry &&
                                  controller.selectedContCountry.value !=
                                      null &&
                                  controller.selectedContCountry.value!.name
                                      .isNotEmpty) {
                                controller.countryConstTextController.text =
                                    controller.selectedContCountry.value!.name;
                                _didPopulateInitialcontcountry = true;
                              }

                              return FormField<Country>(
                                initialValue:
                                    controller.selectedContCountry.value,
                                enabled: _disableField,
                                builder: (stateField) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        enabled: _disableField,
                                        controller: controller
                                            .countryConstTextController,
                                        focusNode: _contCountryFocusNode,
                                        autofocus: false,
                                        decoration: InputDecoration(
                                          labelText: '${loc.searchCountry}*',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          fillColor: _disableField
                                              ? null
                                              : Colors.grey.shade200,
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
                                              controller.selectedContCountry
                                                  .value = null;
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
                                              maxHeight: 250),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Colors.white,
                                          ),
                                          child: filteredCountry.isEmpty
                                              ? const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: Text(
                                                        'No matching countries'),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      filteredCountry.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final countryModel =
                                                        filteredCountry[index];
                                                    return InkWell(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();

                                                        controller
                                                                .selectedContectCountryCode =
                                                            countryModel.code;
                                                        controller
                                                            .fetchSecondState();
                                                        controller
                                                            .stateTextController
                                                            .text = "";

                                                        setState(() {
                                                          controller
                                                                  .countryConstTextController
                                                                  .text =
                                                              countryModel.name;
                                                          _ContCountry = '';
                                                          _showResultsContCountr =
                                                              false;
                                                        });

                                                        controller
                                                            .selectedContCountry
                                                            .value = countryModel;
                                                        stateField.didChange(
                                                            countryModel);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        child: Text(
                                                            countryModel.name),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      if (stateField.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, left: 12),
                                          child: Text(
                                            stateField.errorText!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              );
                            }),
                            const SizedBox(
                              height: 8,
                            ),

                            FutureBuilder<List<StateModels>>(
                              future:
                                  statesFuture ?? Future.value(<StateModels>[]),
                              builder: (context, snapshot) {
                                final statesList = controller.statesconst;
                                final lowerQuery =
                                    _stateSearchQuery.toLowerCase();

                                final filteredStates = [
                                  ...statesList.where((s) => s.name
                                      .toLowerCase()
                                      .startsWith(lowerQuery)),
                                  ...statesList.where((s) =>
                                      s.name
                                          .toLowerCase()
                                          .contains(lowerQuery) &&
                                      !s.name
                                          .toLowerCase()
                                          .startsWith(lowerQuery)),
                                  ...statesList.where((s) => !s.name
                                      .toLowerCase()
                                      .contains(lowerQuery)),
                                ];

                                // Populate initial field only once
                                if (!_didPopulateInitial &&
                                    controller
                                        .contactStateController.isNotEmpty) {
                                  controller.stateTextController.text =
                                      controller.contactStateController;
                                  _didPopulateInitial = true;
                                }

                                return FormField<StateModels>(
                                  enabled: _disableField,
                                  initialValue:
                                      controller.selectedContState.value,
                                  builder: (stateField) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          enabled: _disableField,
                                          autofocus: false,
                                          focusNode: _contactStateFocusNode,
                                          controller:
                                              controller.stateTextController,
                                          decoration: InputDecoration(
                                            labelText: loc.searchState,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fillColor: _disableField
                                                ? null
                                                : Colors.grey.shade200,
                                            filled: !_disableField,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _showResults
                                                    ? Icons.arrow_drop_up
                                                    : Icons
                                                        .arrow_drop_down_outlined,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _showResults = !_showResults;
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
                                              },
                                            ),
                                          ),
                                          onChanged: (value) {
                                            controller.fetchSecondState();

                                            setState(() {
                                              _stateSearchQuery = value;
                                              _showResults = true;

                                              if (value.isEmpty) {
                                                controller.selectedState.value =
                                                    null;
                                                controller.stateTextController
                                                    .clear();
                                              } else {
                                                controller.stateTextController
                                                    .text = value;
                                              }
                                            });
                                          },
                                          onTap: () {
                                            setState(() {
                                              _showResults = true;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        if (_showResults)
                                          Container(
                                            width: double.infinity,
                                            constraints: const BoxConstraints(
                                                maxHeight: 250),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.white,
                                            ),
                                            child: filteredStates.isEmpty
                                                ? const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      child: Text(
                                                          'No matching states'),
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        filteredStates.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final stateModel =
                                                          filteredStates[index];
                                                      return InkWell(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();

                                                          setState(() {
                                                            controller
                                                                    .stateTextController
                                                                    .text =
                                                                stateModel.name;
                                                            controller
                                                                    .contactStateController =
                                                                stateModel.code;
                                                            controller
                                                                .selectedContState
                                                                .value = stateModel;
                                                            _stateSearchQuery =
                                                                '';
                                                            _showResults =
                                                                false;
                                                          });

                                                          stateField.didChange(
                                                              stateModel);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                          child: Text(
                                                              stateModel.name),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        if (stateField.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, left: 12),
                                            child: Text(
                                              stateField.errorText!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
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
                                print("Name changed to: $value");
                                // You can add setState or controller logic here
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    // Cancel logic
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.gradientStart,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: AppColors.gradientStart),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(loc.cancel),
                                ),
                                Obx(() {
                                  return ElevatedButton(
                                    onPressed: (controller
                                            .isGEPersonalInfoLoading.value)
                                        ? null
                                        : () {
                                            controller.updateProfileDetails();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.gradientStart,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    child: controller
                                            .isGEPersonalInfoLoading.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(loc.save),
                                  );
                                })
                              ],
                            )
                          ],
                        ),
                        _buildSection(
                          title: loc.localizationPreferences,
                          children: [
                            const SizedBox(height: 20),
                            Obx(() {
                              return SearchableMultiColumnDropdownField<
                                  Timezone>(
                                labelText: loc.timeZone,
                                columnHeaders: const [
                                  'TimezoneName',
                                  'TimezoneCode',
                                  'TimezoneId'
                                ],
                                items: controller.timezone,
                                selectedValue:
                                    controller.selectedTimezone.value,
                                searchValue: (t) =>
                                    '${t.name} ${t.code} ${t.id}',
                                displayText: (t) => t.name,
                                validator: (t) =>
                                    t == null ? 'Please pick a timezone' : null,
                                onChanged: (t) {
                                  controller.selectedTimezone.value = t!;
                                },
                                rowBuilder: (t, searchQuery) {
                                  Widget highlight(String text) {
                                    final query = searchQuery.toLowerCase();
                                    final lowerText = text.toLowerCase();
                                    final startIndex = lowerText.indexOf(query);

                                    if (startIndex == -1 || query.isEmpty) {
                                      return Text(text,
                                          style: const TextStyle(fontSize: 10));
                                    }

                                    final endIndex = startIndex + query.length;
                                    return RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.black),
                                        children: [
                                          TextSpan(
                                              text: text.substring(
                                                  0, startIndex)),
                                          TextSpan(
                                            text: text.substring(
                                                startIndex, endIndex),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                              text: text.substring(endIndex)),
                                        ],
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Row(
                                      children: [
                                        Expanded(child: highlight(t.name)),
                                        Expanded(
                                            child:
                                                highlight(t.code.toString())),
                                        Expanded(
                                            child: highlight(t.id.toString())),
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
                            Obx(() =>
                                SearchableMultiColumnDropdownField<Payment>(
                                  labelText: loc.defaultPayment,
                                  columnHeaders: const [
                                    'PaymentMethodName',
                                    'PaymentMethodId'
                                  ],
                                  items: controller.payment,
                                  selectedValue:
                                      controller.selectedPayment.value,
                                  searchValue: (p) => '${p.name} ${p.code}',
                                  displayText: (p) => p.name,
                                  validator: (p) => p == null
                                      ? 'Please select a payment method'
                                      : null,
                                  onChanged: (p) {
                                    setState(() =>
                                        controller.selectedPayment.value = p!);
                                  },
                                  rowBuilder: (p, searchQuery) {
                                    Widget highlight(String text) {
                                      final query = searchQuery.toLowerCase();
                                      final lower = text.toLowerCase();
                                      final matchIndex = lower.indexOf(query);

                                      if (matchIndex == -1 || query.isEmpty)
                                        return Text(text);

                                      final end = matchIndex + query.length;
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  text.substring(0, matchIndex),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: text.substring(
                                                  matchIndex, end),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: text.substring(end),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: highlight(p.name)),
                                          Expanded(child: highlight(p.code)),
                                        ],
                                      ),
                                    );
                                  },
                                )),
                            const SizedBox(height: 20),

                            Obx(
                              () =>
                                  SearchableMultiColumnDropdownField<Currency>(
                                labelText: loc.defaultCurrency,
                                columnHeaders: const ['Code', 'Name', 'Symbol'],
                                items: controller.currencies,
                                selectedValue:
                                    controller.selectedCurrency.value,
                                searchValue: (c) =>
                                    '${c.code} ${c.name} ${cleanSymbol(c.symbol)}', // 🔧 Fix display
                                displayText: (c) =>
                                    '${c.code} ${c.name} ${cleanSymbol(c.symbol)}', // 🔧 Fix display
                                validator: (c) =>
                                    c == null ? 'Please pick a currency' : null,
                                onChanged: (c) {
                                  controller.selectedCurrency.value = c;
                                },
                                rowBuilder: (c, searchQuery) {
                                  Widget highlight(String text) {
                                    final query = searchQuery.toLowerCase();
                                    final lower = text.toLowerCase();
                                    final matchIndex = lower.indexOf(query);

                                    if (matchIndex == -1 || query.isEmpty) {
                                      return Text(
                                        text,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Roboto',
                                        ),
                                      );
                                    }

                                    final end = matchIndex + query.length;
                                    return RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: text.substring(0, matchIndex),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                text.substring(matchIndex, end),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          TextSpan(
                                            text: text.substring(end),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Row(
                                      children: [
                                        Expanded(child: highlight(c.code)),
                                        Expanded(child: highlight(c.name)),
                                        Expanded(
                                            child: highlight(
                                                cleanSymbol(c.symbol))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

// LOCALE DROPDOWN
                            Obx(() =>
                                SearchableMultiColumnDropdownField<Locales>(
                                  labelText: loc.selectLocale,
                                  columnHeaders: const ["Code", "Name"],
                                  items: controller.localeData,
                                  selectedValue:
                                      controller.selectedLocale.value,
                                  searchValue: (locale) =>
                                      '${locale.code} ${locale.name}',
                                  displayText: (locale) =>
                                      '${locale.code} — ${locale.name}',
                                  validator: (locale) => locale == null
                                      ? 'Please select a locale'
                                      : null,
                                  onChanged: (locale) {
                                    setState(() {
                                      controller.selectedLocale.value = locale!;
                                    });
                                  },
                                  rowBuilder: (locale, searchQuery) {
                                    Widget highlight(String text) {
                                      final query = searchQuery.toLowerCase();
                                      final lower = text.toLowerCase();
                                      final matchIndex = lower.indexOf(query);

                                      if (matchIndex == -1 || query.isEmpty) {
                                        return Text(text,
                                            style:
                                                const TextStyle(fontSize: 10));
                                      }

                                      final end = matchIndex + query.length;
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  text.substring(0, matchIndex),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                            TextSpan(
                                              text: text.substring(
                                                  matchIndex, end),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            TextSpan(
                                              text: text.substring(end),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: highlight(locale.code)),
                                          Expanded(
                                              child: highlight(locale.name)),
                                        ],
                                      ),
                                    );
                                  },
                                )),
                            const SizedBox(height: 20),

                            SearchableMultiColumnDropdownField<Language>(
                              labelText: loc.defaultLanguage,
                              columnHeaders: const [
                                'LanguageName',
                                'LanguageId'
                              ],
                              items: controller.language,
                              selectedValue: controller.selectedLanguage,
                              searchValue: (lang) =>
                                  '${lang.name} ${lang.code}',
                              displayText: (lang) => lang.name,
                              validator: (lang) => lang == null
                                  ? 'Please pick a language'
                                  : null,
                              onChanged: (lang) {
                                setState(() {
                                  controller.selectedLanguage = lang;
                                  final localeCode = controller
                                      .getLocaleCodeFromId(lang!.code);
                                  Provider.of<LocaleNotifier>(context,
                                          listen: false)
                                      .setLocale(Locale(localeCode));
                                });
                              },
                              rowBuilder: (lang, searchQuery) {
                                Widget highlight(String text) {
                                  final query = searchQuery.toLowerCase();
                                  final lower = text.toLowerCase();
                                  final matchIndex = lower.indexOf(query);

                                  if (matchIndex == -1 || query.isEmpty) {
                                    return Text(text);
                                  }

                                  final end = matchIndex + query.length;
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: text.substring(0, matchIndex),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: text.substring(matchIndex, end),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: text.substring(end),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(child: highlight(lang.name)),
                                      Expanded(child: highlight(lang.code)),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            FormField<MapEntry<String, String>>(
                              builder: (state) {
                                return MultiColumnDropdownField<
                                    MapEntry<String, String>>(
                                  state: state,
                                  labelText: loc.selectDateFormat,
                                  columnHeaders: const ['Format'],
                                  items:
                                      controller.dateFormatMap.entries.toList(),
                                  dropdownHeight: 300,
                                  dropdownWidth: 340,
                                  onChanged: (entry) {
                                    setState(() =>
                                        controller.selectedFormat = entry);
                                  },
                                  rowBuilder: (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    child: Row(
                                      children: [
                                        // Expanded(child: Text(entry.key)),
                                        Expanded(child: Text(entry.value)),
                                      ],
                                    ),
                                  ),
                                  selectedDisplay: (entry) => '${entry.value}',
                                );
                              },
                              initialValue: controller.selectedFormat,
                            ),
                            const SizedBox(height: 20),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Aligned in a row using Wrap

                                  SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: controller.emails.map((email) {
                                        return Chip(
                                          label: Text(email),
                                          deleteIcon: const Icon(Icons.close),
                                          onDeleted: () => _removeEmail(email),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _controller,
                                        decoration: InputDecoration(
                                          labelText: 'Enter email(s)',
                                          border: OutlineInputBorder(),
                                          errorText: _errorText,
                                        ),
                                        onChanged: _validateOnChange,
                                        onSubmitted: _addEmails,
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
                                              child: const Text("Cancel"),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed:
                                                  isTyping && !hasEmailError
                                                      ? () => _addEmails(
                                                          _controller.text)
                                                      : null,
                                              child: const Text("Submit"),
                                            ),
                                          ],
                                        ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const SizedBox(height: 20),
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.gradientStart,
                                              backgroundColor: Colors.white,
                                              side: const BorderSide(
                                                  color:
                                                      AppColors.gradientStart),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(loc.cancel),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                controller.buttonLoader.value
                                                    ? null
                                                    : () {
                                                        controller
                                                            .userPreferences();
                                                      },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.gradientStart,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            child: controller.buttonLoader.value
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
                                          ),
                                          const SizedBox(height: 40),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    );
            }),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          textColor: Colors.deepPurple,
          iconColor: Colors.deepPurple,
          collapsedIconColor: Colors.grey,
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: children,
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool isEnabled = true,
    void Function(String)? onChanged, // <-- Added parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: TextField(
        controller: controller,
        enabled: isEnabled,
        onChanged: onChanged, // <-- Set onChanged here
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: isEnabled ? null : Colors.grey.shade200,
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
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text =
                "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
          }
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
    final safeSelectedValue =
        items.contains(selectedValue) ? selectedValue : null;
    print("Selected: $safeSelectedValue");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: safeSelectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText ?? "Select $label",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        style: style,
        validator: validator,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text("Upload"),
              onTap: () {
                Navigator.pop(context);
                // uploadImage();
                controller.pickImageProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove"),
              onTap: () {
                Navigator.pop(context);
                controller.deleteProfilePicture();
              },
            ),
          ],
        ),
      ),
    );
  }
}
