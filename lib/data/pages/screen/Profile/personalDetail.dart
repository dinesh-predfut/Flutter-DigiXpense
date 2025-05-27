import 'package:digi_xpense/core/comman/widgets/multiColumnDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../core/comman/widgets/button.dart';
import '../../../../core/comman/widgets/dateSelector.dart';
import '../../../models.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> options = [
    {"id": 101, "name": "Apple"},
    {"id": 102, "name": "Banana"},
    {"id": 103, "name": "Orange"},
    {"id": 104, "name": "Mango"},
  ];
  String? _selectedItem;

  final List<Map<String, String>> data = [
    {'id': '1', 'name': 'Apple'},
    {'id': '2', 'name': 'Banana'},
    {'id': '3', 'name': 'Cherry'},
    {'id': '4', 'name': 'Date'},
    {'id': '5', 'name': 'Elderberry'},
  ];
  List<Map<String, dynamic>> filteredOptions = [];
  bool showDropdown = false;

  final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  void _addEmails(String input) {
    final newEmails = input
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
  }

  void _removeEmail(String email) {
    setState(() => controller.emails.remove(email));
  }

  @override
  void initState() {
    super.initState();
    controller.getPersonalDetails(context);
    controller.getUserPref();
    Future.delayed(const Duration(seconds: 2), () {
      controller.fetchCountries();
      controller.fetchState();
      controller.fetchLanguageList();
      controller.currencyDropDown();
      controller.paymentMethode();
      controller.fetchTimeZoneList();
      controller.localeDropdown();
      filteredOptions = options;
      print("controller.country${controller.selectedFormat}");
      print('This is delayed by 2 seconds');
    });
  }

  void toggleSameAddress(bool value) {
    setState(() {
      controller.isSameAsPermanent = value;
      print("isSameAsPermanent$value");
      if (value) {
        controller.contactStreetController.text = controller.street.text;
        controller.contactCityController.text = controller.city.text;
        controller.contactStateController = controller.state;
        controller.contactPostalController.text = controller.postalCode.text;
        controller.selectedContectCountryName = controller.selectedCountryName;
      } else {
        controller.contactStreetController.clear();
        controller.contactCityController.clear();
        controller.contactStateController = "";
        controller.contactPostalController.clear();
        controller.contactCountryController = "";
      }
    });
  }

  void _filterOptions(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredOptions = options
          .where((option) =>
              option['name'].toLowerCase().contains(q) ||
              option['id'].toString().contains(q))
          .toList();
      showDropdown = filteredOptions.isNotEmpty;
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
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Details")),
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
                  right: MediaQuery.of(context).size.width / 2 - 190,
                  child: GestureDetector(
                    onTap: controller.pickImageProfile,
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
              "Hellow".trim(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Center(
              child: Text('rose@gmail.com | +01 234 567 89',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
            const SizedBox(height: 20),
                 Obx(() {
      return controller.isLoading.value
          ? const CircularProgressIndicator()
          : 
          Column(
            children: [
_buildSection(
              title: "Personal Information",
              children: [
                _textField("First Name", controller.firstNameController,
                    isEnabled: false),
                const SizedBox(height: 20),
                _textField("Middle Name", controller.middleNameController,
                    isEnabled: false),
                const SizedBox(height: 20),
                _textField("Last Name", controller.lastNameController,
                    isEnabled: false),
                const SizedBox(height: 20),
                _textField(
                    "Personal Mail ID", controller.personalEmailController,
                    isEnabled: false),
                const SizedBox(height: 20),
                // _dateField("Date of Birth", controller.dobController),
                // const SizedBox(height: 20),
                SizedBox(
                    width: 320, // set your desired width here
                    child: IntlPhoneField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counterText: "",
                      ),
                      initialCountryCode: 'IN',
                      disableLengthCheck: true, // we’ll do our own check
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
                        if (phone == null || phone.number.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (phone.number.length != 10) {
                          return 'Phone number must be 10 digits';
                        }

                        return null;
                      },
                    )),
                const SizedBox(height: 20),
                _textField("Gender", controller.gender, isEnabled: false),
                const SizedBox(height: 20),
                // _dropdown(
                //     "Gender", controller.gender, ["Male", "Female", "others"],
                //     (String? val) {
                //   if (val != null) {
                //     setState(() => controller.gender = val);
                //   }
                // }),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Permanent Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _textField("Street", controller.street),
                _textField("City", controller.city),
                _dropdown("Country", controller.selectedCountryCode,
                    controller.countryNames, (String? val) {
                  if (val != null) {
                    setState(() => controller.country = val);

                    setState(() => controller.selectedCountryCode = controller
                        .countries
                        .firstWhere((c) => c.name == val)
                        .code);
                  }
                }
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
                    ),
                _dropdown("State", controller.state, controller.stateList,
                    (String? val) {
                  if (val != null) {
                    setState(() => controller.state = val);
                  }
                }),
                _textField("Zip Code", controller.postalCode),
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
                    const Text(
                      "Same As Permanent Address",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Present Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _textField("Street", controller.contactStreetController),
                _textField("City", controller.contactCityController),
                _dropdown(
                  "Country",
                  controller.selectedContectCountryCode,
                  controller.countryNames,
                  (val) {
                    if (val != null) {
                      setState(() => controller.contactCountryController = val);
                    }
                    setState(() {
                      controller.selectedContectCountryName = val ?? '';
                      controller.selectedContectCountryCode = controller
                          .countries
                          .firstWhere((c) => c.name == val)
                          .code;
                      controller.fetchState();
                      print(
                          "Selected name: ${controller.selectedContectCountryCode}");
                      print(
                          "Send code: ${controller.selectedContectCountryCode}");
                    });
                  },
                ),
                _dropdown("State", controller.contactStateController,
                    controller.stateList, (String? val) {
                  if (val != null) {
                    setState(() => controller.contactStateController = val);
                  }
                }),
                _textField("Zip Code", controller.contactPostalController),
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
                        side: const BorderSide(color: AppColors.gradientStart),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
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
                            : const Text('Submit'),
                      );
                    })
                  ],
                )
              ],
            ),
            _buildSection(
              title: "Localization & Preferences",
              children: [
                const SizedBox(height: 20),

                FormField<Timezone>(
                  initialValue: controller.selectedTimezone,
                  validator: (p) => p == null ? 'Please pick someone' : null,
                  builder: (fieldState) {
                    return MultiColumnDropdownField<Timezone>(
                      state: fieldState,
                      labelText: 'Time Zone',
                      columnHeaders: const [
                        'TimezoneName',
                        'TimezoneCode',
                        'TimezoneId'
                      ],
                      items: controller.timezone,
                      dropdownHeight: 200,
                      // build each row in the dropdown list:
                      rowBuilder: (person) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(person.name)),
                            Expanded(child: Text(person.code.toString())),
                            Expanded(child: Text(person.id.toString())),
                          ],
                        ),
                      ),
                      // what happens when user taps an item
                      onChanged: (person) {
                        setState(() {
                          controller.selectedTimezone = person;
                        });
                      },
                      // how to display the selected value in the field
                      selectedDisplay: (person) => person.name.toString(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 8),
                //   child:
                FormField<Payment>(
                  initialValue: controller.selectedPayment,
                  validator: (p) => p == null ? 'Please pick someone' : null,
                  builder: (fieldState) {
                    return MultiColumnDropdownField<Payment>(
                      state: fieldState,
                      labelText: 'Default Payment',
                      columnHeaders: const [
                        'PaymentMethodName',
                        'PaymentMethodId'
                      ],
                      //       'Payment Method Name'],
                      items: controller.payment,
                      dropdownHeight: 200,
                      // build each row in the dropdown list:
                      rowBuilder: (person) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(person.name)),
                            Expanded(child: Text(person.code.toString())),
                          ],
                        ),
                      ),
                      // what happens when user taps an item
                      onChanged: (person) {
                        setState(() {
                          controller.selectedPayment = person;
                        });
                      },
                      // how to display the selected value in the field
                      selectedDisplay: (person) => person.name.toString(),
                    );
                  },
                ),

                const SizedBox(height: 20),

                FormField<Currency>(
                  initialValue: controller.selectedCurrency,
                  validator: (p) => p == null ? 'Please pick a currency' : null,
                  builder: (fieldState) {
                    return MultiColumnDropdownField<Currency>(
                      state: fieldState,
                      labelText: 'Default Currency',
                      columnHeaders: const ['Code', 'Name', 'Symbol'],
                      items: controller.currencies,
                      dropdownHeight: 200,
                      rowBuilder: (c) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(c.name)),
                            Expanded(child: Text(c.code)),
                            Expanded(child: Text(c.symbol)),
                          ],
                        ),
                      ),
                      onChanged: (c) =>
                          setState(() => controller.selectedCurrency = c),
                      selectedDisplay: (c) => c.name,
                    );
                  },
                ),

                const SizedBox(height: 20),
                FormField<Locale>(
                  builder: (state) {
                    return MultiColumnSearchDropdownField<Locale>(
                      state: state,
                      labelText: "Select Locale",
                      columnHeaders: const ["Code", "Name"],
                      dropdownHeight: 250,
                      onSearch: (query) async {
                        final filtered = controller.localeData.where((locale) {
                          final q = query.toLowerCase();
                          return locale.code.toLowerCase().contains(q) ||
                              locale.name.toLowerCase().contains(q);
                        }).toList();
                        return Future.value(filtered);
                      },
                      rowBuilder: (locale) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text(locale.code)),
                              Expanded(child: Text(locale.name)),
                            ],
                          ),
                        );
                      },
                      selectedDisplay: (locale) =>
                          '${locale.code} — ${locale.name}',
                      onChanged: (locale) {
                        setState(() {
                          controller.selectedLocale = locale;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                FormField<Language>(
                  initialValue: controller.selectedLanguage,
                  validator: (p) => p == null ? 'Please pick someone' : null,
                  builder: (fieldState) {
                    return MultiColumnDropdownField<Language>(
                      state: fieldState,
                      labelText: 'Default Language',
                      columnHeaders: const ['LanguageName', "LanguageID"],
                      items: controller.language,
                      dropdownHeight: 200,
                      // build each row in the dropdown list:
                      rowBuilder: (person) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(person.name)),
                            Expanded(child: Text(person.code.toString())),
                          ],
                        ),
                      ),
                      // what happens when user taps an item
                      onChanged: (person) {
                        setState(() {
                          controller.selectedLanguage = person;
                        });
                      },
                      // how to display the selected value in the field
                      selectedDisplay: (person) => person.name.toString(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                FormField<MapEntry<String, String>>(
                  builder: (state) {
                    return MultiColumnDropdownField<MapEntry<String, String>>(
                      state: state,
                      labelText: 'Select Date Format',
                      columnHeaders: const ['Format'],
                      items: controller.dateFormatMap.entries.toList(),
                      dropdownHeight: 300,
                      onChanged: (entry) {
                        setState(() => controller.selectedFormat = entry);
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
                        side: const BorderSide(color: AppColors.gradientStart),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
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
                            : const Text('Submit'),
                      );
                    })
                  ],
                )
              ],
            ),
            _buildSection(
              title: "Emails Settings",
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Aligned in a row using Wrap

                      Container(
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
                          labelText: "Enter ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: _controller.text.isNotEmpty &&
                                  _controller.text.split(',').any((e) =>
                                      e.trim().isNotEmpty &&
                                      !_emailRegex.hasMatch(e.trim()))
                              ? "One or more emails are invalid"
                              : null,
                        ),
                        onSubmitted: _addEmails,
                        onEditingComplete: () {
                          _addEmails(_controller.text);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
            ],
          );
            
                 
  })],
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

  Widget _textField(String label, TextEditingController controller,
      {bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    ValueChanged<String?> onChanged,
  ) {
    final safeSelectedValue =
        items.contains(selectedValue) ? selectedValue : null;
    print("check$safeSelectedValue");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: safeSelectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        ),
        isExpanded: true,
        hint: Text("Select $label"),
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
}
