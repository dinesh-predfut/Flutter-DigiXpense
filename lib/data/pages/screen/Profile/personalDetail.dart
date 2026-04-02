import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:diginexa/core/comman/widgets/multiColumnDropdown.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/main.dart';
import 'package:diginexa/theme/settheme.dart';
import 'package:diginexa/theme/theme.dart' show ThemeNotifier;
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
import 'package:diginexa/l10n/app_localizations.dart'; // import 'package:flutter_chips_input/flutter_chips_input.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final controller = Get.find<Controller>();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
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
      _errorText = invalid ? "Please Enter Valid Email" : null;
      isTyping = value.trim().isNotEmpty;
    });
  }

  String getIsoCodeFromDialCode(String dialCode) {
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

    return dialCodeToIso[dialCode] ?? 'IN';
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

    /// Same Address Toggle
    if (controller.isSameAsPermanent) {
      toggleSameAddress(true);
    }

    /// Focus Listeners
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

    /// Load Feature States
    featureFuture = controller.getAllFeatureStates();

    /// Run after first UI frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllData();
      _loadProfileImage();
    });
  }

  Future<void> _loadProfileImage() async {
    controller.isImageLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null && File(path).existsSync()) {
      profileImage.value = File(path);
      setState(() {});
      controller.isImageLoading.value = false;
    } else {
      controller.isImageLoading.value = false;
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

                            return GestureDetector(
                              onTap: () {
                                if (file != null) {
                                  showFullImage(context, file);
                                }
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: file != null
                                    ? FileImage(file)
                                    : null,
                                child: file == null
                                    ? const Icon(Icons.person, size: 60)
                                    : null,
                              ),
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
                                // Obx(() {
                                //   return 
                                  SizedBox(
                                    child: IntlPhoneField(
                                      key: ValueKey(
                                        controller.countryCodeController.text,
                                      ), // 🔥 forces rebuild
                                      controller: controller.phoneController,
                                      keyboardType: TextInputType.phone,

                                      decoration: InputDecoration(
                                        labelText: loc.phoneNumber,
                                        labelStyle: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        counterText: "",
                                      ),

                                      // ✅ Dynamic country code from API
                                      initialCountryCode:
                                          getIsoCodeFromDialCode(
                                            controller
                                                    .countryCodeController
                                                    .text
                                                    .isNotEmpty
                                                ? controller
                                                      .countryCodeController
                                                      .text
                                                : '+91', // fallback
                                          ),

                                      onChanged: (phone) {
                                        controller.countryCodeController.text =
                                            phone.countryCode;
                                        controller.phoneController.text =
                                            phone.number; // keep synced
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

                                        // ✅ Better validation
                                        if (phone.number.length < 6) {
                                          isButtonDisabled.value = false;
                                          return '${loc.invalidPhoneNumber} ${phone.countryCode}';
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
                                        return loc.fieldRequired;
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
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
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
                                                  ? Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          12,
                                                        ),
                                                        child: Text(
                                                          loc.noMatchingStates,
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
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
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
                                                      ? Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            child: Text(
                                                              loc.noMatchingStates,
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
                                      return loc.fieldRequired;
                                    }

                                    // Allow only alphanumeric (letters + numbers)
                                    final alphanumeric = RegExp(
                                      r'^[a-zA-Z0-9]+$',
                                    );
                                    if (!alphanumeric.hasMatch(value)) {
                                      return loc.onlyLettersAndNumbers;
                                    }

                                    // Disallow only letters (no digits)
                                    final onlyLetters = RegExp(r'^[a-zA-Z]+$');
                                    if (onlyLetters.hasMatch(value)) {
                                      return loc.zipMustIncludeNumber;
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
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          controller
                                              .countryConstTextController
                                              .text = controller
                                              .selectedContCountry
                                              .value!
                                              .name;

                                          _didPopulateInitialcontcountry = true;
                                        });
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
                                        return loc.fieldRequired;
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
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
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
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
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
                                                      ? Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            child: Text(
                                                              loc.noMatchingStates,
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
                                      return loc.onlyLettersAndNumbers;
                                    }

                                    // ❌ Disallow only letters (must contain at least one number)
                                    final onlyLetters = RegExp(r'^[a-zA-Z]+$');
                                    if (onlyLetters.hasMatch(value)) {
                                      return loc.zipMustIncludeNumber;
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

                            return AbsorbPointer(
                              absorbing:
                                  !isEnabled, // disables taps when loading
                              child: Opacity(
                                opacity: isEnabled
                                    ? 1.0
                                    : 0.5, // dim UI when disabled
                                child: Form(
                                  key: _formKey2,
                                  child: _buildSection(
                                    title: loc.localizationPreferences,
                                    children: [
                                      // ✅ TIMEZONE
                                      FormField<Timezone>(
                                        validator: (_) {
                                          final currency =
                                              controller.selectedTimezone.value;
                                          if (currency.code.isEmpty) {
                                            return loc.fieldRequired;
                                          }
                                          return null;
                                        },
                                        builder: (state) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(
                                                () => SearchableMultiColumnDropdownField<Timezone>(
                                                  labelText:
                                                      '${loc.timeZone} *',
                                                  columnHeaders: [
                                                    loc.timezoneName,
                                                    loc.timezoneCode,
                                                    loc.timezoneId,
                                                  ],
                                                  items: controller.timezone,
                                                  selectedValue: controller
                                                      .selectedTimezone
                                                      .value,
                                                  searchValue: (t) =>
                                                      ' ${t.id}',
                                                  displayText: (t) =>
                                                      '${t.id}, ${t.name}',
                                                  // controller: controller
                                                  //     .timezoneController,
                                                  onChanged: (t) {
                                                    if (t != null) {
                                                      // When a value is selected
                                                      controller
                                                              .selectedTimezone
                                                              .value =
                                                          t;
                                                      controller
                                                          .timezoneController
                                                          .text = t
                                                          .id;
                                                      state.didChange(t);
                                                    } else {
                                                      // When value is cleared
                                                      controller
                                                          .selectedTimezone
                                                          .value = Timezone(
                                                        code: '',
                                                        name: '',
                                                        id: '',
                                                      );
                                                      controller
                                                              .timezoneController
                                                              .text =
                                                          '';
                                                      state.didChange(null);
                                                    }

                                                    // Force validation to run immediately
                                                    state.validate();
                                                  },
                                                  rowBuilder: (t, searchQuery) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                            horizontal: 16,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              t.name,
                                                              style: TextStyle(
                                                                fontSize: 8,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              t.code.toString(),
                                                              style: TextStyle(
                                                                fontSize: 8,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
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
                                                ),
                                              ),
                                              if (state.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    state.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // ✅ PAYMENT METHOD
                                      FormField<PaymentMethodModel>(
                                        // validator: (_) =>
                                        //     controller
                                        //         .selectedPaymentSetting
                                        //         .value
                                        //         .paymentMethodId
                                        //         .isEmpty
                                        //     ? loc.fieldRequired
                                        //     : null,
                                        builder: (state) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(
                                                () => SearchableMultiColumnDropdownField<PaymentMethodModel>(
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
                                                  displayText: (t) =>
                                                      t.paymentMethodName,
                                                  onChanged: (t) {
                                                    if (t != null) {
                                                      controller
                                                              .selectedPaymentSetting
                                                              .value =
                                                          t!;
                                                      controller
                                                              .prefPaymentMethod
                                                              .text =
                                                          t.paymentMethodId;
                                                      state.didChange(t);
                                                    } else {
                                                      // When value is cleared
                                                      controller
                                                              .selectedPaymentSetting
                                                              .value =
                                                          PaymentMethodModel(
                                                            paymentMethodId: '',
                                                            paymentMethodName:
                                                                '',
                                                            reimbursible: false,
                                                          );
                                                      controller
                                                              .prefPaymentMethod
                                                              .text =
                                                          '';
                                                      state.didChange(null);
                                                    }
                                                    controller
                                                            .selectedPaymentSetting
                                                            .value =
                                                        t!;
                                                    controller
                                                            .prefPaymentMethod
                                                            .text =
                                                        t.paymentMethodId;
                                                    state.didChange(t);
                                                  },
                                                  rowBuilder: (t, searchQuery) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
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
                                                              t.paymentMethodName,
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
                                              if (state.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    state.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // ✅ CURRENCY
                                      FormField<Currency>(
                                        validator: (_) {
                                          final currency =
                                              controller.selectedCurrency.value;
                                          if (currency == null ||
                                              currency.code.isEmpty) {
                                            return loc.fieldRequired;
                                          }
                                          return null;
                                        },
                                        builder: (state) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(
                                                () => SearchableMultiColumnDropdownField<Currency>(
                                                  labelText:
                                                      '${loc.defaultCurrency} *',
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
                                                  displayText: (c) => c.code,
                                                  onChanged: (c) {
                                                    if (c != null) {
                                                      controller
                                                              .selectedCurrency
                                                              .value =
                                                          c;
                                                      state.didChange(c);
                                                    } else {
                                                      controller
                                                              .selectedCurrency
                                                              .value =
                                                          null;
                                                      state.didChange(null);
                                                    }
                                                    state.validate();
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
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              if (state.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    state.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // ✅ LOCALE
                                      FormField<Locales>(
                                        validator: (_) {
                                          if (controller
                                              .selectedLocale
                                              .value
                                              .code
                                              .isEmpty) {
                                            return loc.fieldRequired;
                                          }
                                          return null;
                                        },
                                        builder: (state) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(
                                                () => SearchableMultiColumnDropdownField<Locales>(
                                                  labelText:
                                                      '${loc.selectLocale} *',
                                                  columnHeaders: [
                                                    loc.code,
                                                    loc.name,
                                                  ],
                                                  items: controller.localeData,
                                                  selectedValue: controller
                                                      .selectedLocale
                                                      .value,
                                                  searchValue: (locale) =>
                                                      '${locale.code} ${locale.name}',
                                                  displayText: (locale) =>
                                                      '${locale.code} — ${locale.name}',
                                                  onChanged: (locale) {
                                                    if (locale != null) {
                                                      controller
                                                              .selectedLocale
                                                              .value =
                                                          locale;
                                                      state.didChange(locale);
                                                    } else {
                                                      controller
                                                          .selectedLocale
                                                          .value = Locales(
                                                        code: '',
                                                        name: '',
                                                      );
                                                      state.didChange(null);
                                                    }
                                                    state.validate();
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
                                              if (state.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    state.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      // ✅ LANGUAGE
                                      FormField<Language>(
                                        validator: (_) =>
                                            controller.selectedLanguage == null
                                            ? loc.fieldRequired
                                            : null,
                                        builder: (state) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SearchableMultiColumnDropdownField<
                                                Language
                                              >(
                                                labelText:
                                                    '${loc.defaultLanguage} *',
                                                columnHeaders: [
                                                  loc.languageName,
                                                  loc.languageId,
                                                ],
                                                items: controller.language,
                                                selectedValue:
                                                    controller.selectedLanguage,
                                                searchValue: (lang) =>
                                                    '${lang.name} ${lang.code}',
                                                displayText: (lang) =>
                                                    lang.name,
                                                onChanged: (lang) {
                                                  if (lang != null) {
                                                    controller
                                                            .selectedLanguage =
                                                        lang;
                                                    state.didChange(lang);
                                                  } else {
                                                    controller
                                                            .selectedLanguage =
                                                        null;
                                                    state.didChange(null);
                                                  }
                                                  state.validate();
                                                },
                                                rowBuilder: (lang, searchQuery) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 16,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            lang.name,
                                                            style: TextStyle(
                                                              fontSize: 8,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            lang.code,
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
                                              if (state.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    state.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      FormField<MapEntry<String, String>>(
                                        initialValue: controller.selectedFormat,
                                        validator: (_) {
                                          if (controller.selectedFormat ==
                                                  null ||
                                              controller
                                                  .selectedFormat!
                                                  .key
                                                  .isEmpty) {
                                            return loc.fieldRequired;
                                          }
                                          return null;
                                        },
                                        builder: (state) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MultiColumnDropdownField<
                                                MapEntry<String, String>
                                              >(
                                                state: state,
                                                labelText:
                                                    '${loc.selectDateFormat} *',
                                                columnHeaders: [
                                                  loc.format,
                                                  loc.example,
                                                ],
                                                items: controller
                                                    .dateFormatMap
                                                    .entries
                                                    .toList(),
                                                dropdownHeight: 300,
                                                dropdownWidth: 300,
                                                onChanged: (entry) {
                                                  if (entry != null) {
                                                    controller.selectedFormat =
                                                        entry;
                                                    state.didChange(entry);
                                                  } else {
                                                    controller.selectedFormat =
                                                        null;
                                                    state.didChange(null);
                                                  }
                                                  state.validate();
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
                                                            entry.key,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            entry.value,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                selectedDisplay: (entry) =>
                                                    entry.key,
                                              ),
                                              if (state.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        left: 12,
                                                      ),
                                                  child: Text(
                                                    state.errorText!,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                loc.emailsForReceiptForwarding,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              StatefulBuilder(
                                                builder: (context, setLocalState) {
                                                  return TextField(
                                                    controller: _controller,
                                                    decoration: InputDecoration(
                                                      labelText: loc.enterEmail,
                                                      border:
                                                          OutlineInputBorder(),
                                                      errorText: _errorText,
                                                      labelStyle: TextStyle(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                      ),
                                                    ),
                                                    onChanged: (val) {
                                                      setLocalState(
                                                        () {},
                                                      ); // only rebuilds email field
                                                      _validateOnChange(
                                                        val,
                                                      ); // your logic stays same
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
                                              SizedBox(
                                                width: double.infinity,
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: controller.emails
                                                      .map((email) {
                                                        return Chip(
                                                          label: Text(email),
                                                          deleteIcon:
                                                              const Icon(
                                                                Icons.close,
                                                              ),
                                                          onDeleted: () =>
                                                              _removeEmail(
                                                                email,
                                                              ),
                                                        );
                                                      })
                                                      .toList(),
                                                ),
                                              ),
                                              FutureBuilder<Map<String, bool>>(
                                                future: featureFuture,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                            paymentMethodName:
                                                                '',
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
                                                            paymentMethodName:
                                                                '',
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
                                                        AppRoutes
                                                            .dashboard_Main,
                                                      );
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: AppColors
                                                          .gradientStart,
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
                                                            if (_formKey2
                                                                .currentState!
                                                                .validate()) {
                                                              FocusScope.of(
                                                                context,
                                                              ).unfocus();
                                                              controller
                                                                  .userPreferences(
                                                                    context,
                                                                  );
                                                            }

                                                            // Navigator.pop(context);
                                                          },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors
                                                          .gradientStart,
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
                                                      textStyle:
                                                          const TextStyle(
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
                                                                  strokeWidth:
                                                                      2,
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
                              ),
                            );
                          }),

                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                        ],
                      ),
                      Obx(
                        () => ListTile(
                          leading: controller.isLogoutLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.logout, color: Colors.red),

                          title: Text(
                            controller.isLogoutLoading.value
                                ? "Logging out..."
                                : loc.logout,
                            style: const TextStyle(color: Colors.red),
                          ),

                          // ✅ Disable second click
                          onTap: controller.isLogoutLoading.value
                              ? null
                              : () {
                                  _showLogoutConfirmation(context, () async {
                                    controller.isLogoutLoading.value = true;

                                    try {
                                      await controller.logout();

                                      final prefs =
                                          await SharedPreferences.getInstance();

                                      await prefs.remove('token');
                                      await prefs.remove('employeeId');
                                      await prefs.remove('userId');
                                      await prefs.remove('refresh_token');
                                      await prefs.remove('userName');
                                      await prefs.remove('profileImagePath');

                                      prefs.setString('last_route', 'Login');

                                      final themeNotifier =
                                          Provider.of<ThemeNotifier>(
                                            context,
                                            listen: false,
                                          );

                                      await themeNotifier.clearTheme();

                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.signin,
                                        (route) => false,
                                      );
                                    } finally {
                                      controller.isLogoutLoading.value = false;
                                    }
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    VoidCallback onLogout,
  ) async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
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
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
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

  void showFullImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(imageFile),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditPopup(BuildContext context) {
    final controller = Get.find<Controller>();
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
