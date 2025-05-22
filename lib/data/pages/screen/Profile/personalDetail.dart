import 'package:digi_xpense/core/comman/widgets/multiColumnDropdown.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/comman/widgets/button.dart';
import '../../../models.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final controller = Get.put(Controller());
  @override
  void initState() {
    super.initState();
    controller.getPersonalDetails(context);
    // controller.fetchCountries();
    // controller.fetchState();
    // controller.fetchLanguageList();
    // controller.currencyDropDown();
    controller.paymentMethode();
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
                CircleAvatar(
                  radius: 60,
                  backgroundImage: controller.profileImage != null
                      ? FileImage(controller.profileImage!)
                      : null,
                  child: controller.profileImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
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
            _buildSection(
              title: "Personal Information",
              children: [
                _textField("First Name", controller.firstNameController),
                _textField("Middle Name", controller.middleNameController),
                _textField("Last Name", controller.lastNameController),
                _textField(
                    "Personal Mail ID", controller.personalEmailController),
                _dateField("Date of Birth", controller.dobController),
                _textField("Phone number", controller.phoneController),
                _dropdown(
                    "Gender", controller.gender, ["Male", "Female", "others"],
                    (String? val) {
                  if (val != null) {
                    setState(() => controller.gender = val);
                  }
                }),
              ],
            ),
            _buildSection(
              title: "Localization & Preferences",
              children: [
                // _dropdown("Default Language", controller.state,
                //     ["English", "Arabic", "France", "chinese"], (String? val) {
                //   if (val != null) {
                //     setState(() => controller.country = val);
                //   }
                // }),
           
                                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MultiColumnDropdown<Payment>(
                    labelText: 'Default Payment Method',
                    columnHeaders: const ['Payment Method ID', 'Payment Method Name'],
                    items: controller.payment,
                    initialValue: controller.selectedPayment,
                    onChanged: (val) => controller.selectedPayment = val,
                    // ${controller.selectedCurrency!.code}
                    selectedDisplay: (c) => '${c.code} - ${c.name}-',
                    rowBuilder: (c) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(c.code)),
                          Expanded(child: Text(c.name)),
                     
                        ],
                      ),
                    ),
                    validator: (c) =>
                        c == null ? 'Please select a selectedPayment' : null,
                  ),
                ),
                 const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MultiColumnDropdown<Currency>(
                    labelText: 'Default Currency',
                    columnHeaders: const ['Code', 'Name', 'Symbol'],
                    items: controller.currencies,
                    initialValue: controller.selectedCurrency,
                    onChanged: (val) => controller.selectedCurrency = val,
                    // ${controller.selectedCurrency!.code}
                    selectedDisplay: (c) => '${c.code} - ${c.name}-',
                    rowBuilder: (c) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(c.code)),
                          Expanded(child: Text(c.name)),
                          Expanded(child: Text(c.symbol)),
                        ],
                      ),
                    ),
                    validator: (c) =>
                        c == null ? 'Please select a currency' : null,
                  ),
                ),

                // _dropdown("Default Timezone", controller.state, [
                //   "Asia/kolkata",
                //   "UTC +9",
                //   "UTC +7",
                //   "UTC +8"
                // ], (String? val) {
                //   if (val != null) {
                //     setState(() => controller.country = val);
                //   }
                // }),
                // _dropdown("Default Timezone", controller.state,
                //     ["dd-mm-yyyy", "yyyy-mm-dd"], (String? val) {
                //   if (val != null) {
                //     setState(() => controller.country = val);
                //   }
                // }),
                // _textField("Locale", controller.locale),
              ],
            ),
            _buildSection(
              title: "Emails Settings",
              children: [
                _dropdown("Emails for Receipt Forwarding", controller.country,
                    ["demo@gmail.com", "demo@gmail.in"], (String? val) {
                  if (val != null) {
                    setState(() => controller.country = val);
                  }
                }),
                _textField("Phone number", controller.phoneController),
              ],
            ),
            _buildSection(
              title: "Address Details",
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Permanent Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _textField("Street", controller.street),
                _textField("City", controller.city),
                _dropdown(
                  "Country",
                  controller.selectedCountryName,
                  controller.countryNames,
                  (val) {
                    setState(() {
                      controller.selectedCountryName = val ?? '';
                      controller.selectedCountryCode = controller.countries
                          .firstWhere((c) => c.name == val)
                          .code;
                      controller.fetchState();
                      print("Selected name: ${controller.selectedCountryName}");
                      print("Send code: ${controller.selectedCountryCode}");
                    });
                  },
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
                  controller.selectedContectCountryName,
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
                          "Selected name: ${controller.selectedContectCountryName}");
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
              ],
            ),
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

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
