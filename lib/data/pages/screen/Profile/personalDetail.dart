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
import 'package:provider/provider.dart';
import '../../../../core/comman/widgets/button.dart';
import '../../../../core/comman/widgets/dateSelector.dart';
import '../../../models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_chips_input/flutter_chips_input.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final controller = Get.put(Controller());
  final FocusNode _focusNode = FocusNode();

  final TextEditingController textcontroller = TextEditingController();
  final TextEditingController _stateTextController = TextEditingController();
  final TextEditingController _statePresentStateTextController =
      TextEditingController();
  final TextEditingController _statePresentTextController =
      TextEditingController();
  final TextEditingController _countryPresentTextController =
      TextEditingController();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> filteredOptions = [];
  List<Map<String, dynamic>> filteredStateOptions = [];

  Future<List<StateModels>>? statesFuture;
  Future<List<Country>>? constCountryFuture;
  String _stateSearchQuery = '';
  String _statePresentSearchQuery = '';

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

  final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  void _validateEmailInput(String value) {
    final emails = value.split(',');
    setState(() {
      hasEmailError = emails.any((email) =>
          email.trim().isNotEmpty && !_emailRegex.hasMatch(email.trim()));
    });
  }

  void _addEmails(String value) {
    _validateEmailInput(value);
    if (!hasEmailError) {
      // Process valid emails
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
      });
      print("Valid emails: ${value.split(',')}");
      _controller.clear(); // Clear input if valid
    }
  }

  void _removeEmail(String email) {
    setState(() => controller.emails.remove(email));
  }

  @override
  void initState() {
    super.initState();
    controller.fetchCountries();

    controller.getPersonalDetails(context);
    controller.getProfilePicture();
    controller.fetchState();
    controller.fetchCountries();
    controller.fetchLanguageList();
    controller.currencyDropDown();
    controller.paymentMethode();
    controller.fetchTimeZoneList();
    controller.getUserPref();
    controller.localeDropdown();
    if (controller.selectedContCountry != null) {
      statesFuture = controller.fetchState();
    }

    print("controller.country${controller.language}");
  }

  void toggleSameAddress(bool value) {
    setState(() {
      controller.isSameAsPermanent = value;
      print("isSameAsPermanent$value");
      if (value) {
        controller.contactStreetController.text = controller.street.text;
        controller.contactCityController.text = controller.city.text;
        controller.selectedContState = controller.selectedContState;
        controller.contactPostalController.text = controller.postalCode.text;
        controller.selectedContCountry.value = controller.selectedCountry.value;
        _statePresentTextController.text = controller.selectedCountryName;
        controller.selectedContCountry.value = controller.selectedCountry.value;
        _stateTextController.text = _statePresentStateTextController.text;
        _disableField = false;
      } else {
        controller.contactStreetController.clear();
        controller.contactCityController.clear();
        controller.contactStateController = "";
        controller.contactPostalController.clear();
        controller.contactCountryController = "";
        _statePresentTextController.text = "";
        _stateTextController.text = "";
        _disableField = true;
        // _countryPresentTextController.text = "";
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    textcontroller.dispose();
    super.dispose();
  }

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
                  right: MediaQuery.of(context).size.width / 2 - 187,
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
              child: Text(
                  '${controller.phoneController.text} | ${controller.personalEmailController.text}',
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
                                // width: 320, // set your desired width here
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
                              disableLengthCheck:
                                  true, // we’ll do our own check
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
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (phone) async {
                                if (phone == null ||
                                    phone.number.trim().isEmpty) {
                                  return loc.enterPhoneNumber;
                                }
                                if (phone.number.length != 10) {
                                  return loc.phoneNumberDigitsOnly;
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
                            _textField(loc.street, controller.street),
                            _textField(loc.city, controller.city),
                            const SizedBox(
                              height: 8,
                            ),
                            FutureBuilder<List<Country>>(
                              future: controller.fetchCountries(),
                              builder: (context, snapshot) {
                                // 1) Loading / Error / No-data states

                                // 2) We have a list of countries
                                final countryList = snapshot.data!;
                                final filteredpresentCountry = _presentCountry
                                        .isEmpty
                                    ? countryList
                                    : countryList
                                        .where((c) => c.name
                                            .toLowerCase()
                                            .contains(
                                                _presentCountry.toLowerCase()))
                                        .toList();

                                // ─── Only once, when data first arrives: copy selectedContCountry into the field
                                if (!_didPopulateInitialcountry &&
                                    controller.selectedCountry.value != null &&
                                    controller.selectedCountry.value!.code
                                        .isNotEmpty) {
                                  print("22222");
                                  _countryPresentTextController.text =
                                      controller.selectedCountry.value!.name;
                                  _didPopulateInitialcountry = true;
                                }

                                return FormField<Country>(
                                  initialValue:
                                      controller.selectedCountry.value,
                                  builder: (stateField) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── 1) Search Field ──
                                        SizedBox(
                                          // width: 320,
                                          child: TextField(
                                            controller:
                                                _countryPresentTextController,
                                            autofocus: false,
                                            decoration: InputDecoration(
                                              labelText:
                                                  '${loc.searchCountry}*',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              suffixIcon: _presentCountry
                                                      .isEmpty
                                                  ? const Icon(Icons
                                                      .arrow_drop_down_outlined)
                                                  : GestureDetector(
                                                      onTap: () {
                                                        // clear the field, hide results, clear selection
                                                        setState(() {
                                                          _countryPresentTextController
                                                              .clear();
                                                          _presentCountry = '';
                                                          _showResultsPresentCountr =
                                                              false;
                                                        });
                                                        controller
                                                            .selectedCountry
                                                            .value = null;
                                                        stateField
                                                            .didChange(null);
                                                      },
                                                      child: const Icon(
                                                          Icons.clear),
                                                    ),
                                            ),
                                            onChanged: (value) {
                                              // As soon as the user types (or erases everything):
                                              setState(() {
                                                _presentCountry = value;
                                                _showResultsPresentCountr =
                                                    value.isNotEmpty;
                                              });

                                              // If they removed all text, clear the selection
                                              if (value.isEmpty) {
                                                controller.selectedCountry
                                                    .value = null;
                                                stateField.didChange(null);
                                              }
                                            },
                                            onTap: () {
                                              // If they tap into an empty field, show full list
                                              if (_countryPresentTextController
                                                  .text.isEmpty) {
                                                setState(() {
                                                  _showResultsPresentCountr =
                                                      true;
                                                });
                                              }
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // ── 2) Filtered List ──
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
                                            child: filteredpresentCountry
                                                    .isEmpty
                                                ? const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      child: Text(
                                                          'No matching countries'),
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        filteredpresentCountry
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final countryModel =
                                                          filteredpresentCountry[
                                                              index];
                                                      return InkWell(
                                                        onTap: () {
                                                          // 1) Unfocus keyboard
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          controller
                                                                  .selectedCountryName =
                                                              countryModel.name;
                                                          controller
                                                                  .selectedCountryCode =
                                                              countryModel.code;

                                                          controller
                                                              .fetchState();
                                                          _countryPresentTextController
                                                              .text = "";
                                                          // 2) Update text & hide list
                                                          setState(() {
                                                            _countryPresentTextController
                                                                    .text =
                                                                countryModel
                                                                    .name;
                                                            _presentCountry =
                                                                '';
                                                            _showResultsPresentCountr =
                                                                false;
                                                            _statePresentStateTextController
                                                                .text = "";
                                                          });

                                                          // 3) Notify form/parent of new selection
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
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Text(
                                                              countryModel
                                                                  .name),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),

                                        // ── 3) Validation Message ──
                                        if (stateField.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, left: 12),
                                            child: Text(
                                              stateField.errorText!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .errorColor),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            // FormField<Country>(
                            //   initialValue: controller.selectedCountry.value,
                            //   builder: (state) {
                            //     return SizedBox(
                            //         width: 320, // Set your desired width here
                            //         child:
                            //             MultiColumnSearchDropdownField<Country>(
                            //           state: state,
                            //           labelText: "Select Country",
                            //           columnHeaders: const ["Country"],
                            //           dropdownHeight: 250,
                            //           //  selectedValue: selectedCountry,
                            //           onSearch: (query) async {
                            //             final filtered = controller.countries
                            //                 .where((locale) {
                            //               final q = query.toLowerCase();
                            //               return locale.code
                            //                       .toLowerCase()
                            //                       .contains(q) ||
                            //                   locale.name
                            //                       .toLowerCase()
                            //                       .contains(q);
                            //             }).toList();
                            //             return Future.value(filtered);
                            //           },
                            //           rowBuilder: (locale) {
                            //             return Padding(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 12, vertical: 6),
                            //               child: Row(
                            //                 children: [
                            //                   // Expanded(child: Text(locale.code)),
                            //                   Expanded(
                            //                       child: Text(
                            //                     locale.name,
                            //                   )),
                            //                 ],
                            //               ),
                            //             );
                            //           },
                            //           selectedDisplay: (country) =>
                            //               country.name,
                            //           onChanged: (country) {
                            //             setState(() {
                            //               controller.selectedCountryName =
                            //                   country!.toString();
                            //               controller
                            //                       .selectedContectCountryCode =
                            //                   country.code;
                            //             });
                            //             // controller.fetchState();
                            //           },
                            //         ));
                            //   },
                            // ),
                            const SizedBox(
                              height: 15,
                            ),
                            FutureBuilder<List<StateModels>>(
                                future: statesFuture ??
                                    Future.value(<StateModels>[]),
                                builder: (context, snapshot) {
                                  final statesList = controller.statesres;
                                  final filteredStates =
                                      _statePresentSearchQuery.isEmpty
                                          ? statesList
                                          : statesList.where((s) {
                                              return s.name
                                                  .toLowerCase()
                                                  .contains(
                                                      _statePresentSearchQuery
                                                          .toLowerCase());
                                            }).toList();

                                  // If there's already a selected state, populate its name once.
                                  // Doing this in build() can cause repeated text‐setting, so you may
                                  // want to move initialization into initState or guard it carefully.

                                  if (!_didPopulateInitialstate &&
                                      controller.selectedState.value != null &&
                                      controller.selectedState.value!.code
                                          .isNotEmpty) {
                                    print("22222");
                                    _statePresentStateTextController.text =
                                        controller.selectedState.value!.name;
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
                                          // ── 1. Search Field ──
                                          SizedBox(
                                            // width: 320,
                                            child: TextField(
                                              autofocus: false,
                                              controller:
                                                  _statePresentStateTextController,
                                              decoration: InputDecoration(
                                                labelText: loc.searchState,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                suffixIcon: _statePresentSearchQuery
                                                        .isEmpty
                                                    ? const Icon(Icons
                                                        .arrow_drop_down_outlined)
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _statePresentStateTextController
                                                                .clear();
                                                            _statePresentSearchQuery =
                                                                '';
                                                            _showResultsPresentState =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(
                                                            Icons.clear),
                                                      ),
                                              ),
                                              onChanged: (value) {
                                                controller.fetchState();

                                                setState(() {
                                                  setState(() {
                                                    _statePresentSearchQuery =
                                                        value;
                                                    _showResultsPresentState =
                                                        value.isNotEmpty;
                                                    print(
                                                        "print$_showResultsPresentState");
                                                  });
                                                  if (value.isEmpty) {
                                                    print("print2$value");
                                                    controller.selectedState
                                                        .value = null;
                                                    _statePresentStateTextController
                                                        .clear();
                                                  }

                                                  // _stateTextController=value;
                                                  _statePresentSearchQuery =
                                                      value;
                                                  _statePresentStateTextController
                                                      .text = value.toString();
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          // ── 2. Filtered List ──
                                          if (_showResultsPresentState)
                                            Container(
                                              width: 320,
                                              constraints: const BoxConstraints(
                                                  maxHeight: 250),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
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
                                                            filteredStates[
                                                                index];
                                                        return InkWell(
                                                          onTap: () {
                                                            // ① Unfocus the TextField so the keyboard/input disconnects

                                                            setState(() {
                                                              _statePresentStateTextController
                                                                      .text =
                                                                  stateModel
                                                                      .name
                                                                      .toString();

                                                              controller
                                                                      .contactStateController =
                                                                  stateModel
                                                                      .code
                                                                      .toString();
                                                              controller
                                                                      .selectedContState
                                                                      .value =
                                                                  stateModel;
                                                              stateField
                                                                  .didChange(
                                                                      stateModel);

                                                              // ② Update TextField text and close dropdown
                                                              _statePresentStateTextController
                                                                      .text =
                                                                  stateModel
                                                                      .name;
                                                              _statePresentSearchQuery =
                                                                  '';
                                                              _showResultsPresentState =
                                                                  false;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                            child: Text(
                                                                stateModel
                                                                    .name),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),

                                          // ── 3. Validation Message ──
                                          if (stateField.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, left: 12),
                                              child: Text(
                                                stateField.errorText!,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .errorColor),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                }),

                            // Obx(() {
                            //   return FormField<StateModels>(
                            //     initialValue: controller.selectedState.value,
                            //     builder: (stateField) {
                            //       return SizedBox(
                            //           width: 320, // Set your desired width here
                            //           // height: 20,
                            //           child: MultiColumnSearchDropdownField<
                            //               StateModels>(
                            //             state: stateField,
                            //             labelText: "Select State",
                            //             columnHeaders: const ["State"],
                            //             dropdownHeight: 250,
                            //             onSearch: (query) async {
                            //               final q = query.toLowerCase();
                            //               return controller.statesres
                            //                   .where((s) =>
                            //                       s.name
                            //                           .toLowerCase()
                            //                           .contains(q) ||
                            //                       s.name
                            //                           .toLowerCase()
                            //                           .contains(q))
                            //                   .toList();
                            //             },
                            //             rowBuilder: (locale) => Padding(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 16, vertical: 10),
                            //               child: Row(
                            //                 children: [
                            //                   Expanded(child: Text(locale.name))
                            //                 ],
                            //               ),
                            //             ),
                            //             selectedDisplay: (s) => s.name,
                            //             onChanged: (s) {
                            //               controller.selectedState.value = s;
                            //             },
                            //           ));
                            //     },
                            //   );
                            // }),
                            const SizedBox(
                              height: 15,
                            ),
                            // (String? val) {
                            //   setState(() {
                            //     controller.country = val;
                            //     controller.selectedCountryCode = controller.countries
                            //         .firstWhere((c) => c.name == val)
                            //         .code;
                            //     controller.fetchState();
                            //     print("Selected name: ${controller.selectedCountryName}");
                            //     print("Send code: ${controller.selectedCountryCode}");
                            //   });
                            // },

                            _textField(loc.zipCode, controller.postalCode),
                            const SizedBox(height: 20),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.permanentAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            _textField(
                                loc.street, controller.contactStreetController,
                                isEnabled: _disableField),
                            _textField(
                                loc.city, controller.contactCityController,
                                isEnabled: _disableField),
                            FutureBuilder<List<Country>>(
                              future: controller.fetchCountries(),
                              builder: (context, snapshot) {
                                // 1) Loading / Error / No-data states

                                // 2) We have a list of countries
                                final countryList = snapshot.data!;
                                final filteredCountry = _ContCountry.isEmpty
                                    ? countryList
                                    : countryList
                                        .where((c) => c.name
                                            .toLowerCase()
                                            .contains(
                                                _ContCountry.toLowerCase()))
                                        .toList();

                                // ─── Only once, when data first arrives: copy selectedContCountry into the field
                                if (!_didPopulateInitialcontcountry &&
                                    controller.selectedContCountry.value !=
                                        null &&
                                    controller.selectedContCountry.value!.name
                                        .isNotEmpty) {
                                  print("3333");
                                  _statePresentTextController.text = controller
                                      .selectedContCountry.value!.name;
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
                                        // ── 1) Search Field ──
                                        SizedBox(
                                          // width: 320,
                                          child: TextField(
                                            enabled: _disableField,
                                            controller:
                                                _statePresentTextController,
                                            autofocus: false,
                                            decoration: InputDecoration(
                                              labelText:
                                                  '${loc.searchCountry}*',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              fillColor: _disableField
                                                  ? null
                                                  : Colors.grey.shade200,
                                              filled: !_disableField,
                                              suffixIcon: _ContCountry.isEmpty
                                                  ? const Icon(Icons
                                                      .arrow_drop_down_outlined)
                                                  : GestureDetector(
                                                      onTap: () {
                                                        // clear the field, hide results, clear selection
                                                        setState(() {
                                                          _statePresentTextController
                                                              .clear();
                                                          _ContCountry = '';
                                                          _showResultsContCountr =
                                                              false;
                                                        });
                                                        controller
                                                            .selectedContCountry
                                                            .value = null;
                                                        stateField
                                                            .didChange(null);
                                                      },
                                                      child: const Icon(
                                                          Icons.clear),
                                                    ),
                                            ),
                                            onChanged: (value) {
                                              // As soon as the user types (or erases everything):
                                              setState(() {
                                                _ContCountry = value;
                                                _showResultsContCountr =
                                                    value.isNotEmpty;
                                              });

                                              // If they removed all text, clear the selection
                                              if (value.isEmpty) {
                                                controller.selectedContCountry
                                                    .value = null;
                                                stateField.didChange(null);
                                              }
                                            },
                                            onTap: () {
                                              // If they tap into an empty field, show full list
                                              if (_statePresentTextController
                                                  .text.isEmpty) {
                                                setState(() {
                                                  _showResultsContCountr = true;
                                                });
                                              }
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // ── 2) Filtered List ──
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
                                                      padding:
                                                          EdgeInsets.all(12),
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
                                                          filteredCountry[
                                                              index];
                                                      return InkWell(
                                                        onTap: () {
                                                          // 1) Unfocus keyboard
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          controller
                                                                  .selectedContectCountryCode =
                                                              countryModel.code;
                                                          controller
                                                              .fetchState();
                                                          _stateTextController
                                                              .text = "";
                                                          // 2) Update text & hide list
                                                          setState(() {
                                                            _statePresentTextController
                                                                    .text =
                                                                countryModel
                                                                    .name;
                                                            _ContCountry = '';
                                                            _showResultsContCountr =
                                                                false;
                                                          });

                                                          // 3) Notify form/parent of new selection
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
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Text(
                                                              countryModel
                                                                  .name),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),

                                        // ── 3) Validation Message ──
                                        if (stateField.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, left: 12),
                                            child: Text(
                                              stateField.errorText!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .errorColor),
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

                            FutureBuilder<List<StateModels>>(
                                future: statesFuture ??
                                    Future.value(<StateModels>[]),
                                builder: (context, snapshot) {
                                  final statesList = controller.statesres;
                                  final filteredStates = _stateSearchQuery
                                          .isEmpty
                                      ? statesList
                                      : statesList.where((s) {
                                          return s.name.toLowerCase().contains(
                                              _stateSearchQuery.toLowerCase());
                                        }).toList();

                                  // If there's already a selected state, populate its name once.
                                  // Doing this in build() can cause repeated text‐setting, so you may
                                  // want to move initialization into initState or guard it carefully.
                                  if (!_didPopulateInitial) {
                                    _stateTextController.text =
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
                                          // ── 1. Search Field ──
                                          SizedBox(
                                            // width: 330,
                                            child: TextField(
                                              enabled: _disableField,
                                              autofocus: false,
                                              controller: _stateTextController,
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
                                                suffixIcon: _stateSearchQuery
                                                        .isEmpty
                                                    ? const Icon(Icons
                                                        .arrow_drop_down_outlined)
                                                    : GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _stateTextController
                                                                .clear();
                                                            _stateSearchQuery =
                                                                '';
                                                            _showResults =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(
                                                            Icons.clear),
                                                      ),
                                              ),
                                              onChanged: (value) {
                                                controller.fetchState();
                                                print("print$value");
                                                setState(() {
                                                  if (value.isEmpty) {
                                                    print("print2$value");
                                                    controller.selectedState
                                                        .value = null;
                                                    _stateTextController
                                                        .clear();
                                                  }

                                                  // _stateTextController=value;
                                                  _stateSearchQuery = value;
                                                  _stateTextController.text =
                                                      value.toString();
                                                  _showResults =
                                                      value.isNotEmpty;
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          // ── 2. Filtered List ──
                                          if (_showResults)
                                            Container(
                                              width: 320,
                                              constraints: const BoxConstraints(
                                                  maxHeight: 250),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
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
                                                            filteredStates[
                                                                index];
                                                        return InkWell(
                                                          onTap: () {
                                                            // ① Unfocus the TextField so the keyboard/input disconnects

                                                            setState(() {
                                                              _stateTextController
                                                                      .text =
                                                                  stateModel
                                                                      .name
                                                                      .toString();

                                                              controller
                                                                      .contactStateController =
                                                                  stateModel
                                                                      .code
                                                                      .toString();
                                                              controller
                                                                      .selectedContState
                                                                      .value =
                                                                  stateModel;
                                                              stateField
                                                                  .didChange(
                                                                      stateModel);
                                                              // ② Update TextField text and close dropdown
                                                              _stateTextController
                                                                      .text =
                                                                  stateModel
                                                                      .name;
                                                              _stateSearchQuery =
                                                                  '';
                                                              _showResults =
                                                                  false;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                            child: Text(
                                                                stateModel
                                                                    .name),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),

                                          // ── 3. Validation Message ──
                                          if (stateField.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, left: 12),
                                              child: Text(
                                                stateField.errorText!,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .errorColor),
                                              ),
                                            ),
                                        ],
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
                                    onPressed: controller.buttonLoader.value
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
                                    child: controller.buttonLoader.value
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

                            SearchableMultiColumnDropdownField<Timezone>(
                              labelText: loc.timeZone,
                              columnHeaders: const [
                                'TimezoneName',
                                'TimezoneCode',
                                'TimezoneId'
                              ],
                              items: controller.timezone,
                              selectedValue: controller.selectedTimezone,
                              searchValue: (t) => '${t.name} ${t.code} ${t.id}',
                              displayText: (t) => t.name,
                              validator: (t) =>
                                  t == null ? 'Please pick a timezone' : null,
                              onChanged: (t) {
                                setState(() {
                                  controller.selectedTimezone = t;
                                });
                              },
                              rowBuilder: (t) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(t.name)),
                                    Expanded(child: Text(t.code.toString())),
                                    Expanded(child: Text(t.id.toString())),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 8),
                            //   child:
                            SearchableMultiColumnDropdownField<Payment>(
                              labelText: 'Default Payment',
                              columnHeaders: [
                                'PaymentMethodName',
                                'PaymentMethodId'
                              ],
                              items: controller.payment,
                              selectedValue: controller.selectedPayment,
                              searchValue: (p) => p.name,
                              displayText: (p) => p.name,
                              validator: (p) => p == null
                                  ? 'Please select a payment method'
                                  : null,
                              onChanged: (p) {
                                setState(() => controller.selectedPayment = p);
                              },
                              rowBuilder: (p) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(p.name)),
                                    Expanded(child: Text(p.code)),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // CURRENCY DROPDOWN
                            SearchableMultiColumnDropdownField<Currency>(
                              labelText: loc.defaultCurrency,
                              columnHeaders: const ['Code', 'Name', 'Symbol'],
                              items: controller.currencies,
                             selectedValue: controller.selectedCurrency,

                              searchValue: (c) =>
                                  '${c.code} ${c.name} ${c.symbol}',
                              displayText: (c) => c.name,
                              validator: (c) =>
                                  c == null ? 'Please pick a currency' : null,
                              onChanged: (c) {
                                setState(() {
                                  controller.selectedCurrency = c;
                                });
                              },
                              rowBuilder: (c) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(c.code)),
                                    Expanded(child: Text(c.name)),
                                    Expanded(child: Text(c.symbol)),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

// LOCALE DROPDOWN
                            SearchableMultiColumnDropdownField<Locales>(
                              labelText: loc.selectLocale,
                              columnHeaders: const ["Code", "Name"],
                              items: controller.localeData,
                              selectedValue: controller.selectedLocale,
                              searchValue: (locale) =>
                                  '${locale.code} ${locale.name}',
                              displayText: (locale) =>
                                  '${locale.code} — ${locale.name}',
                              validator: (locale) => locale == null
                                  ? 'Please select a locale'
                                  : null,
                              onChanged: (locale) {
                                setState(() {
                                  controller.selectedLocale = locale;
                                });
                              },
                              rowBuilder: (locale) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(locale.code)),
                                    Expanded(child: Text(locale.name)),
                                  ],
                                ),
                              ),
                            ),

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
                                  final localeCode = controller.getLocaleCodeFromId(lang!.code);
                                  // update the app locale
                                  Provider.of<LocaleNotifier>(context,
                                          listen: false)
                                      .setLocale(Locale(localeCode));
                                });
                              },
                              rowBuilder: (lang) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(lang.name)),
                                    Expanded(child: Text(lang.code)),
                                  ],
                                ),
                              ),
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
                                  TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      labelText: loc.enterEmail,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      errorText: _controller.text.isNotEmpty &&
                                              _controller.text.split(',').any(
                                                  (e) =>
                                                      e.trim().isNotEmpty &&
                                                      !_emailRegex
                                                          .hasMatch(e.trim()))
                                          ? "One or more emails are invalid"
                                          : null,
                                    ),
                                    onSubmitted: _addEmails,
                                    onEditingComplete: () {
                                      _addEmails(_controller.text);
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ]),
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
                                    onPressed: controller.buttonLoader.value
                                        ? null
                                        : () {
                                            controller.userPreferences();
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
                                    child: controller.buttonLoader.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(loc.submit),
                                  );
                                })
                              ],
                            )
                          ],
                        ),
                      
                      ],
                    );
            })
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: TextField(
        controller: controller,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // Optional: Visual cue when disabled
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
