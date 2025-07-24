import 'dart:async';

import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
// import '../../../../service.dart';

class FormCashAdvanceRequest extends StatefulWidget {
  const FormCashAdvanceRequest({super.key});

  @override
  State<FormCashAdvanceRequest> createState() => _FormCashAdvanceRequestState();
}

class _FormCashAdvanceRequestState extends State<FormCashAdvanceRequest>
    with TickerProviderStateMixin {
  final controller = Get.put(Controller());
  final controllerItems = Get.put(Controller());
  // final _formKey = GlobalKey<FormState>();
  List<Controller> itemizeControllers = [];

  int _currentStep = 0;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  int _selectedCategoryIndex = -1;
  bool _showPaidForError = false;
  bool _showPaidWithError = false;
  bool _showQuantityError = false;
  bool _showUnitAmountError = false;
  bool _showUnitError = false;
  bool _showLocationError = false;
  bool _showProjectError = false;
  bool setQuality = true;
  bool clearField = false;
  bool _showTaxAmountError = false;
  bool showItemizeDetails = false;
  String? _paidTo;
  bool? isThereReferenceID = false;
  String? paidToError;
  final RxnString paidwithError = RxnString();
  String? selectDate;
  String? selectReferenceIDError;
  final PageController _pageController = PageController();
  Timer? _debounce;
  final List<String> _titles = ["Payment Info", "Itemize", "Expense Details"];
  @override
  void initState() {
    super.initState();
    // controller.clearFormFields();

    controller.selectedDate ??= DateTime.now();

    // controller.fetchPaidto();

    itemizeControllers.add(Controller());
    controller.configuration();
    controller.isManualEntryMerchant = false;
    _initializeUnits();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchMaxAllowedPercentage();
      controller.fetchCashAdvanceRequests();
      controller.getconfigureFieldCashAdvance();
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.getUserPref();
      controller.fetchExpenseCategory();
      controller.fetchExchangeRate();
      controller.fetchBusinessjustification();
      controller.fetchLocation();
    });
  }

  bool isFieldMandatory(String fieldName) {
    return controller.configList.any(
      (f) =>
          (f['FieldName']?.toString().trim().toLowerCase() ==
              fieldName.trim().toLowerCase()) &&
          (f['IsEnabled'].toString().toLowerCase() == 'true') &&
          (f['IsMandatory'].toString().toLowerCase() == 'true'),
    );
  }

  bool validateDropdowns() {
    bool isValid = true;

    // Validate Paid To
    if (controller.selectedjustification == null) {
      setState(() {
        paidToError = 'Please select a merchant';
      });
      isValid = false;
    } else if (controller.isManualEntryMerchant &&
        controller.manualPaidToController.text.trim().isEmpty) {
      setState(() {
        paidToError = 'Please enter a merchant name';
      });
      isValid = false;
    } else {
      // Clear error if valid
      setState(() {
        paidToError = null;
      });
    }

    // Validate Paid With
    // if (controller.paidWith == null) {
    //   print("PaidWithError");
    //   setState(() {
    //     paidwithError.value = 'Please select a Payment Method';
    //   });
    //   isValid = false;
    // } else {
    //   setState(() {
    //     paidwithError.value = null;
    //   });
    // }

    // Validate Date
    // if (controller.selectedDate == null) {
    //   setState(() {
    //     paidwithError = 'Please select a Date';
    //   });
    //   isValid = false;
    // } else {
    //   setState(() {
    //     paidwithError = null;
    //   });
    // }

    // Validate Reference ID
    if (isThereReferenceID == true && controller.referenceID.text.isEmpty) {
      setState(() {
        selectReferenceIDError = 'Please select a Reference ID';
      });
      isValid = false;
    } else {
      setState(() {
        selectReferenceIDError = null;
      });
    }

    return isValid;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != controller.selectedDate) {
      setState(() {
        controller.selectedDate = picked;
        selectDate = null;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  final List<Color> categoryColors = [
    Colors.green,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.grey.shade400,
    Colors.red.shade700,
    Colors.pink.shade200,
  ];
  Future<void> _initializeUnits() async {
    await controller.fetchUnit(); // Wait for units to be fetched
    Timer(const Duration(seconds: 5), () {
      final defaultUnit = controller.unit.firstWhere(
        (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
        orElse: () => controller.unit.first,
      );
      setState(() {
        controller.selectedunit ??= defaultUnit;
        controller.selectedunit ??= defaultUnit;
      });
    });
  }

  void _addItemize() {
    if (!showItemizeDetails) {
      print("Check$showItemizeDetails");
      setState(() {
        showItemizeDetails = true;
      });
    } else {
      if (_itemizeCount < 5) {
        setState(() {
          itemizeControllers.add(Controller());
          _itemizeCount++;
          _selectedItemizeIndex = _itemizeCount - 1;
          showItemizeDetails = true;
        });
      }
    }
  }

  void _removeItemize(int selectedItemizeIndex) {
    if (_itemizeCount < 1) {
      showItemizeDetails = false;
    }
    if (selectedItemizeIndex == 0) {
      setState(() {
        itemizeControllers.removeAt(0);
        _itemizeCount--;
      });
    }
    if (_itemizeCount > 1 &&
        _selectedItemizeIndex >= 0 &&
        _selectedItemizeIndex < itemizeControllers.length) {
      setState(() {
        itemizeControllers.removeAt(_selectedItemizeIndex);
        _itemizeCount--;

        // Adjust selected index if needed
        if (_selectedItemizeIndex >= _itemizeCount) {
          _selectedItemizeIndex = _itemizeCount - 1;
        }
      });
    }
  }

  Widget _buildStep(int index) {
    final isActive = index == _currentStep;
    final isCompleted = index < _currentStep;

    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive
              ? Colors.orange
              : isCompleted
                  ? Colors.orange
                  : Colors.grey,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _titles[index],
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted ? Colors.orange : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int segmentIndex) {
    final isCompleted = segmentIndex < _currentStep;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0), // adjust as needed
        child: Container(
          height: 2,
          width: 50,
          color: isCompleted ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        _buildStep(0),
        _buildStepLine(0),
        _buildStep(1),
        _buildStepLine(1),
        _buildStep(2),
      ],
    );
  }

  Widget _buildItemizeCircles() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _itemizeCount,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedItemizeIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected ? Colors.orange : Colors.grey,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Itemize',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool validateExpenseForm() {
    bool isValid = true;

    setState(() {
      // Reset all error states
      _showQuantityError = false;
      _showUnitAmountError = false;
      _showUnitError = false;
      _showTaxAmountError = false;
      _showPaidForError = false;
    });

    // Validate Paid For (category)
    if (controller.selectedCategoryId.isEmpty) {
      _showPaidForError = true;
      isValid = false;
    }

    // Validate Tax Amount if mandatory
    final taxAmountMandatory = controller.configList.any(
      (f) => f['FieldName'] == 'Tax Amount' && f['IsMandatory'] == true,
    );
    if (taxAmountMandatory && controller.taxAmount.text.trim().isEmpty) {
      _showTaxAmountError = true;
      isValid = false;
    }

    // Validate Itemized fields if enabled
    if (_itemizeCount > 1) {
      if (controller.quantity.text.trim().isEmpty) {
        _showQuantityError = true;
        isValid = false;
      }

      if (controller.unitAmount.text.trim().isEmpty) {
        _showUnitAmountError = true;
        isValid = false;
      }

      if (controller.selectedunit == null) {
        _showUnitError = true;
        isValid = false;
      }
    }

    return isValid;
  }

  Widget _buildItemizePage() {
    return DefaultTabController(
      length: _itemizeCount,
      initialIndex: _selectedItemizeIndex,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            tabs: List.generate(
              _itemizeCount,
              (index) => Tab(text: "Itemize ${index + 1}"),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: List.generate(
                _itemizeCount,
                (index) => Center(
                    child:
                        expenseCreateForm2(context, itemizeControllers[index])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
        // ignore: deprecated_member_use
        WillPopScope(
            onWillPop: () async {
              controller.clearFormFields();

              return true; // allow back navigation
            },
            child: Scaffold(
              appBar: AppBar(
                  title: const Text(
                "Cash Advance Request Form",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                textAlign: TextAlign.center,
              )),
              body: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProgressBar(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        expenseCreationFormStep1(context),
                        _buildItemizePage(),
                        const CreateExpensePage(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (_currentStep == 2)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                            _pageController.animateToPage(
                              _currentStep,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        label: const Text(
                          'Back',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    else
                      const SizedBox(), // Empty space if back is not shown
                  ],
                ),
              ),
            ));
  }

  Widget expenseCreateForm2(BuildContext context, Controller controller) {
    // Use the provided controller parameter consistently
    controller.selectedunit = controllerItems.selectedunit;
    controller.selectedDate = controllerItems.selectedDate;
    if (controller.requestedPercentage.text.isEmpty) {
      controller.requestedPercentage.text =
          controllerItems.requestedPercentage.text;
    }
    if (controller.currencyDropDowncontrollerCA3.text.isEmpty) {
      controller.currencyDropDowncontrollerCA3 =
          controllerItems.currencyDropDowncontroller;
    }
    if (controller.currencyDropDowncontrollerCA2.text.isEmpty) {
      controller.currencyDropDowncontrollerCA2 =
          controllerItems.currencyDropDowncontroller2;
    }
    // controller.isReimbursite.vale = true;
    // controller.isReimbursite.vale = true;
    print("selecteduni${controller.selectedunit}");
    if (setQuality) {
      if (controller.quantity.text.isEmpty) {
        controller.quantity.text = '1.00';
      }
    }
    _calculateTotalLineAmount(controller);
    _calculateTotalLineAmount2(controller);
    if (clearField) {
      controller.quantity.clear();
      controller.selectedProject = null;
      controller.paidAmount.clear();
      controller.lineAmount.clear();
      controller.selectedProject = null;
      controller.selectedTax = null;
      controller.selectedCategoryId = '';
      controller.taxAmount.clear();
      controller.unitAmount.clear();
      controller.descriptionController;
    }
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        /// 🔹 PROJECT ID SECTION
        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controllerItems.configListAdvance
                .where((field) =>
                    field['FieldName'] == 'Project Id' &&
                    field['IsEnabled'] == true)
                .map((field) {
              final String label = field['FieldName'];
              final bool isMandatory = field['IsMandatory'] ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchableMultiColumnDropdownField<Project>(
                    labelText: '$label ${isMandatory ? "*" : ""}',
                    columnHeaders: const ['Project Name', 'Project Id'],
                    // enabled: controller.isEditModePerdiem,
                    controller: controller.projectIdController,
                    items: controllerItems.project,
                    selectedValue: controller.selectedProject,
                    searchValue: (proj) => '${proj.name} ${proj.code}',
                    displayText: (proj) => proj.code,
                    onChanged: (proj) {
                      setState(() {
                        controller.selectedProject = proj;
                        if (proj != null) {
                          _showProjectError = false;
                        }
                      });
                      // Optional: Fetch categories after selecting project
                      // controller.fetchExpenseCategory();
                    },
                    rowBuilder: (proj, searchQuery) {
                      Widget highlight(String text) {
                        final lowerQuery = searchQuery.toLowerCase();
                        final lowerText = text.toLowerCase();
                        final start = lowerText.indexOf(lowerQuery);
                        if (start == -1 || searchQuery.isEmpty)
                          return Text(text);

                        final end = start + searchQuery.length;
                        return RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: text.substring(0, start),
                                style: const TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: text.substring(start, end),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: text.substring(end),
                                style: const TextStyle(color: Colors.black),
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
                            Expanded(child: highlight(proj.name)),
                            Expanded(child: highlight(proj.code)),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_showProjectError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Please select a Project',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        }),

        /// 🔹 LOCATION SECTION
        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controllerItems.configListAdvance
                .where((field) =>
                    field['FieldName'] == 'Location' &&
                    field['IsEnabled'] == true)
                .map((field) {
              final String label = field['FieldName'];
              final bool isMandatory = field['IsMandatory'] ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchableMultiColumnDropdownField<LocationModel>(
                    labelText: '$label ${isMandatory ? "*" : ""}',
                    columnHeaders: const ['Location', 'Country'],
                    // enabled: controller.isEditModePerdiem,
                    controller: controller.locationController,
                    items: controllerItems.location,
                    selectedValue: controller.selectedLocation,
                    searchValue: (loc) => loc.location,
                    displayText: (loc) => loc.location,
                    validator: (loc) => isMandatory && loc == null
                        ? 'Please select a Location'
                        : null,
                    onChanged: (loc) {
                      controller.selectedLocation = loc;
                      controller.fetchMaxAllowedPercentage();
                      field['Error'] = null; // Clear error when value selected
                    },
                    rowBuilder: (loc, searchQuery) {
                      Widget highlight(String text) {
                        final lowerQuery = searchQuery.toLowerCase();
                        final lowerText = text.toLowerCase();
                        final start = lowerText.indexOf(lowerQuery);
                        if (start == -1 || searchQuery.isEmpty) {
                          return Text(text);
                        }

                        final end = start + searchQuery.length;
                        return RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: text.substring(0, start),
                                style: const TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: text.substring(start, end),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: text.substring(end),
                                style: const TextStyle(color: Colors.black),
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
                            Expanded(child: Text(loc.location)),
                            Expanded(child: Text(loc.country)),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_showLocationError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Please select a Location',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 16),
        const Text("Paid For *"),
        const SizedBox(height: 20),
        if (_showPaidForError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Please select a category',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 20),
        Obx(() {
          final fetchCategory = (controller.expenseCategory.isNotEmpty)
              ? controller.expenseCategory
              : controllerItems.expenseCategory;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: fetchCategory.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final color = categoryColors[index % categoryColors.length];

              return _buildCategoryButton(
                index,
                item,
                item.categoryId,
                color,
                color,
                item.expenseCategoryIcon.toString(),
                controller,
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 16),
        TextField(
          controller: controller.requestedPercentage,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: "Requested Percentage %",
            enabled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (showItemizeDetails) const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (showItemizeDetails)
              SearchableMultiColumnDropdownField<Unit>(
                labelText: 'Unit *',
                columnHeaders: const ['Uom Id', 'Uom Name'],
                items: controllerItems.unit,
                selectedValue: controller.selectedunit,
                searchValue: (tax) => '${tax.code} ${tax.name}',
                displayText: (tax) => tax.name,
                onChanged: (tax) {
                  setState(() {
                    controller.selectedunit = tax;
                    _showUnitError = false;
                  });
                },
                rowBuilder: (tax, searchQuery) {
                  Widget highlight(String text) {
                    final lowerQuery = searchQuery.toLowerCase();
                    final lowerText = text.toLowerCase();
                    final start = lowerText.indexOf(lowerQuery);
                    if (start == -1 || searchQuery.isEmpty) return Text(text);

                    final end = start + searchQuery.length;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: text.substring(0, start),
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: text.substring(start, end),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: text.substring(end),
                            style: const TextStyle(color: Colors.black),
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
                        Expanded(child: highlight(tax.code)),
                        Expanded(child: highlight(tax.name)),
                      ],
                    ),
                  );
                },
              ),
            if (showItemizeDetails) const SizedBox(height: 16),
            if (showItemizeDetails)
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    controller: controller.unitAmount,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      controllerItems.fetchExchangeRate();
                      controllerItems.unitAmount.text = value;
                      setState(() {
                        controller.unitAmount.text = value;
                        _showUnitAmountError = false;
                      });
                      final qty =
                          double.tryParse(controller.quantity.text) ?? 0.0;
                      final unit =
                          double.tryParse(controller.unitAmount.text) ?? 0.0;

                      final calculatedLineAmount = qty * unit;

                      controller.paidAmountCA1.text =
                          calculatedLineAmount.toStringAsFixed(2);
                      controller.paidAmount.text =
                          calculatedLineAmount.toStringAsFixed(2);
                      if (_debounce?.isActive ?? false) _debounce!.cancel();

                      // Start a new debounce timer
                      _debounce =
                          Timer(const Duration(milliseconds: 400), () async {
                        final paidAmountText =
                            controller.paidAmountCA1.text.trim();

                        final double paidAmounts =
                            double.tryParse(paidAmountText) ?? 0.0;
                        final currency =
                            controller.currencyDropDowncontrollerCA3.text;

                        // Only proceed if currency and amount are provided
                        if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
                          // Fire API calls concurrently
                          final results = await Future.wait([
                            controller.fetchExchangeRateCA(
                                currency, paidAmountText),
                            controller.fetchMaxAllowedPercentage(),
                          ]);

                          // Process the first exchange rate response
                          final exchangeResponse1 =
                              results[0] as ExchangeRateResponse?;
                          if (exchangeResponse1 != null) {
                            controller.unitRateCA1.text =
                                exchangeResponse1.exchangeRate.toString();
                            controller.amountINRCA1.text = exchangeResponse1
                                .totalAmount
                                .toStringAsFixed(2);
                            controller.isVisible.value = true;
                          }

                          // Process max allowed percentage
                          final maxPercentage = results[1] as double?;

                          if (maxPercentage != null && maxPercentage > 0) {
                            final double calculatedPercentage =
                                (paidAmounts * maxPercentage) / 100;

                            controller.paidAmountCA2.text =
                                calculatedPercentage.toString();
                            controller.calculatedPercentage.value =
                                calculatedPercentage;
                            final percentageStr =
                                maxPercentage.toInt().toString();
                            controller.requestedPercentage.text =
                                '$percentageStr %';

                            if (calculatedPercentage > 100) {
                              Fluttertoast.showToast(
                                msg:
                                    'Paid amount exceeds maximum allowed percentage!',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                          }
                          final reqPaidAmount =
                              controller.paidAmountCA2.text.trim();
                          final reqCurrency =
                              controller.currencyDropDowncontrollerCA2.text;
                          if (reqCurrency.isNotEmpty &&
                              reqPaidAmount.isNotEmpty) {
                            final exchangeResponse =
                                await controller.fetchExchangeRateCA(
                                    reqCurrency, reqPaidAmount);

                            if (exchangeResponse != null) {
                              controller.unitRateCA2.text =
                                  exchangeResponse.exchangeRate.toString();
                              controller.amountINRCA2.text = exchangeResponse
                                  .totalAmount
                                  .toStringAsFixed(2);
                              // controller.isVisible.value = true;
                            }
                          }
                        }
                      });
                    },
                    onEditingComplete: () {
                      String text = controller.unitAmount.text;
                      double? value = double.tryParse(text);
                      if (value != null) {
                        controller.unitAmount.text = value.toStringAsFixed(2);
                        controller.paidAmount.text = value.toStringAsFixed(2);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Unit Amount *",
                      errorText: _showUnitAmountError
                          ? 'Unit Amount is required'
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),
                  if (showItemizeDetails) const SizedBox(width: 12),
                  if (showItemizeDetails)
                    Expanded(
                        child: TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: controller.quantity,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          controller.quantity.text = value;
                          _showQuantityError = false;
                          setQuality = false;
                        });
                        final qty =
                            double.tryParse(controller.quantity.text) ?? 0.0;
                        final unit =
                            double.tryParse(controller.unitAmount.text) ?? 0.0;

                        final calculatedLineAmount = qty * unit;
                        print(
                            "calculatedLineAmount: $qty x $unit = $calculatedLineAmount");
                        controller.paidAmountCA1.text =
                            calculatedLineAmount.toStringAsFixed(2);
                        controller.paidAmontIsEditable.value = false;
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        // Start a new debounce timer
                        _debounce =
                            Timer(const Duration(milliseconds: 400), () async {
                          final paidAmountText =
                              controller.paidAmountCA1.text.trim();

                          final double paidAmounts =
                              double.tryParse(paidAmountText) ?? 0.0;
                          final currency =
                              controller.currencyDropDowncontrollerCA3.text;

                          // Only proceed if currency and amount are provided
                          if (currency.isNotEmpty &&
                              paidAmountText.isNotEmpty) {
                            // Fire API calls concurrently
                            final results = await Future.wait([
                              controller.fetchExchangeRateCA(
                                  currency, paidAmountText),
                              controller.fetchMaxAllowedPercentage(),
                            ]);

                            // Process the first exchange rate response
                            final exchangeResponse1 =
                                results[0] as ExchangeRateResponse?;
                            if (exchangeResponse1 != null) {
                              controller.unitRateCA1.text =
                                  exchangeResponse1.exchangeRate.toString();
                              controller.amountINRCA1.text = exchangeResponse1
                                  .totalAmount
                                  .toStringAsFixed(2);
                              controller.isVisible.value = true;
                            }

                            // Process max allowed percentage
                            final maxPercentage = results[1] as double?;

                            if (maxPercentage != null && maxPercentage > 0) {
                              final double calculatedPercentage =
                                  (paidAmounts * maxPercentage) / 100;

                              controller.paidAmountCA2.text =
                                  calculatedPercentage.toString();
                              controller.calculatedPercentage.value =
                                  calculatedPercentage;
                              final percentageStr =
                                  maxPercentage.toInt().toString();
                              controller.requestedPercentage.text =
                                  '$percentageStr %';

                              if (calculatedPercentage > 100) {
                                Fluttertoast.showToast(
                                  msg:
                                      'Paid amount exceeds maximum allowed percentage!',
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            }
                            final reqPaidAmount =
                                controller.paidAmountCA2.text.trim();
                            final reqCurrency =
                                controller.currencyDropDowncontrollerCA2.text;
                            if (reqCurrency.isNotEmpty &&
                                reqPaidAmount.isNotEmpty) {
                              final exchangeResponse =
                                  await controller.fetchExchangeRateCA(
                                      reqCurrency, reqPaidAmount);

                              if (exchangeResponse != null) {
                                controller.unitRateCA2.text =
                                    exchangeResponse.exchangeRate.toString();
                                controller.amountINRCA2.text = exchangeResponse
                                    .totalAmount
                                    .toStringAsFixed(2);
                                // controller.isVisible.value = true;
                              }
                            }
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Quantity*",
                        errorText:
                            _showQuantityError ? 'Quantity is required' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )),
                ],
              ),
            if (controller.lineAmount.text.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      final double lineAmount =
                          double.tryParse(controller.lineAmount.text) ?? 0.0;

                      // Only initialize splits if empty
                      if (controller.split.isEmpty &&
                          controller.accountingDistributions.isNotEmpty) {
                        controller.split.assignAll(
                          controller.accountingDistributions.map((e) {
                            return AccountingSplit(
                              paidFor: e!.dimensionValueId,
                              percentage: e.allocationFactor,
                              amount: e.transAmount,
                            );
                          }).toList(),
                        );
                      } else if (controller.split.isEmpty) {
                        controller.split
                            .add(AccountingSplit(percentage: 100.0));
                      }

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 24,
                          ),
                          child: SingleChildScrollView(
                            child: AccountingDistributionWidget(
                              splits: controller.split,
                              lineAmount: lineAmount,
                              onChanged: (i, updatedSplit) {
                                if (!mounted) return;
                                controller.split[i] = updatedSplit;
                              },
                              onDistributionChanged: (newList) {
                                if (!mounted) return;
                                controller.accountingDistributions.clear();
                                controller.accountingDistributions
                                    .addAll(newList);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Account Distribution'),
                  ),
                ],
              ),
            if (showItemizeDetails) const SizedBox(height: 24),
            Card(
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Estimated Amount *',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        /// Paid Amount Field
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: controller.paidAmountCA1,
                            enabled: !showItemizeDetails,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Paid Amount',
                              isDense: true,
                              // contentPadding:
                              //     EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            onChanged: (_) async {
                              // Cancel previous debounce timer if still active
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();

                              // Start a new debounce timer
                              _debounce = Timer(
                                  const Duration(milliseconds: 400), () async {
                                final paidAmountText =
                                    controller.paidAmountCA1.text.trim();
                                controller.unitAmount.text =
                                    controller.paidAmountCA1.text;
                                final double paidAmounts =
                                    double.tryParse(paidAmountText) ?? 0.0;
                                final currency = controller
                                    .currencyDropDowncontrollerCA3.text;

                                // Only proceed if currency and amount are provided
                                if (currency.isNotEmpty &&
                                    paidAmountText.isNotEmpty) {
                                  // Fire API calls concurrently
                                  final results = await Future.wait([
                                    controller.fetchExchangeRateCA(
                                        currency, paidAmountText),
                                    controller.fetchMaxAllowedPercentage(),
                                  ]);

                                  // Process the first exchange rate response
                                  final exchangeResponse1 =
                                      results[0] as ExchangeRateResponse?;
                                  if (exchangeResponse1 != null) {
                                    controller.unitRateCA1.text =
                                        exchangeResponse1.exchangeRate
                                            .toString();
                                    controller.amountINRCA1.text =
                                        exchangeResponse1.totalAmount
                                            .toStringAsFixed(2);
                                    controller.isVisible.value = true;
                                  }

                                  // Process max allowed percentage
                                  final maxPercentage = results[1] as double?;

                                  if (maxPercentage != null &&
                                      maxPercentage > 0) {
                                    final double calculatedPercentage =
                                        (paidAmounts * maxPercentage) / 100;

                                    controller.paidAmountCA2.text =
                                        calculatedPercentage.toString();
                                    controller.calculatedPercentage.value =
                                        calculatedPercentage;

                                    final percentageStr =
                                        maxPercentage.toInt().toString();
                                    controller.requestedPercentage.text =
                                        '$percentageStr %';

                                    if (calculatedPercentage > 100) {
                                      Fluttertoast.showToast(
                                        msg:
                                            'Paid amount exceeds maximum allowed percentage!',
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                    }
                                  }
                                  final reqPaidAmount =
                                      controller.paidAmountCA2.text.trim();
                                  final reqCurrency = controller
                                      .currencyDropDowncontrollerCA2.text;
                                  if (reqCurrency.isNotEmpty &&
                                      reqPaidAmount.isNotEmpty) {
                                    final exchangeResponse =
                                        await controller.fetchExchangeRateCA(
                                            reqCurrency, reqPaidAmount);

                                    if (exchangeResponse != null) {
                                      controller.unitRateCA2.text =
                                          exchangeResponse.exchangeRate
                                              .toString();
                                      controller.amountINRCA2.text =
                                          exchangeResponse.totalAmount
                                              .toStringAsFixed(2);
                                      // controller.isVisible.value = true;
                                    }
                                  }
                                }
                              });
                            },
                            onEditingComplete: () {
                              String text = controller.paidAmountCA1.text;
                              double? value = double.tryParse(text);
                              if (value != null) {
                                controller.paidAmountCA1.text =
                                    value.toStringAsFixed(2);
                              }
                            },
                          ),
                        ),

                        /// Currency Dropdown
                        Obx(
                          () => SizedBox(
                            width: 90,
                            child: SearchableMultiColumnDropdownField<Currency>(
                              labelText: "",
                              alignLeft: -90,
                              dropdownWidth: 280,
                              columnHeaders: const ['Code', 'Name', 'Symbol'],
                              controller:
                                  controller.currencyDropDowncontrollerCA3,
                              items: controllerItems.currencies,
                              selectedValue:
                                  controller.selectedCurrencyCA1.value,
                              backgroundColor: Colors.white,
                              searchValue: (c) =>
                                  '${c.code} ${c.name} ${c.symbol}',
                              displayText: (c) => c.code,
                              inputDecoration: const InputDecoration(
                                suffixIcon:
                                    Icon(Icons.arrow_drop_down_outlined),
                                filled: true,
                                fillColor: Color(0xFFF7F7F7),
                                isDense: true,
                                // contentPadding: EdgeInsets.symmetric(
                                //     horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              validator: (c) =>
                                  c == null ? 'Please select a currency' : null,
                              onChanged: (c) async {
                                controller.selectedCurrencyCA1.value = c;
                                controller.currencyDropDowncontrollerCA3.text =
                                    c?.code ?? '';

                                final paidAmount =
                                    controller.paidAmountCA1.text.trim();
                                if (paidAmount.isNotEmpty) {
                                  final exchangeResponse =
                                      await controller.fetchExchangeRateCA(
                                    c!.code,
                                    paidAmount,
                                  );

                                  if (exchangeResponse != null) {
                                    controller.unitRateCA1.text =
                                        exchangeResponse.exchangeRate
                                            .toString();
                                    controller.amountINRCA1.text =
                                        exchangeResponse.totalAmount
                                            .toStringAsFixed(2);
                                  }
                                }
                              },
                              rowBuilder: (c, searchQuery) {
                                Widget highlight(String text) {
                                  final lowerQuery = searchQuery.toLowerCase();
                                  final lowerText = text.toLowerCase();
                                  final start = lowerText.indexOf(lowerQuery);
                                  if (start == -1 || searchQuery.isEmpty) {
                                    return Text(text,
                                        style: const TextStyle(fontSize: 12));
                                  }
                                  final end = start + searchQuery.length;
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: text.substring(0, start),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: text.substring(start, end),
                                          style: const TextStyle(
                                            color: Colors.blue,
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
                                      vertical: 6, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(child: highlight(c.code)),
                                      Expanded(child: highlight(c.name)),
                                      Expanded(child: highlight(c.symbol)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// Rate Field
                        Expanded(
                          child: TextFormField(
                            enabled: false,
                            controller: controller.unitRateCA1,
                            decoration: const InputDecoration(
                              hintText: 'Rate',
                              isDense: true,

                              // contentPadding:
                              //     EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Amount in INR
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.amountINRCA1,
                      enabled: false,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Amount in INR *',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Total Requested Amount  *',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        // Paid Amount Text Field
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: controller.paidAmountCA2,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Paid Amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            onChanged: (_) async {
                              final paidAmount =
                                  controller.paidAmountCA2.text.trim();
                              final currency =
                                  controller.currencyDropDowncontrollerCA2.text;

                              if (currency.isNotEmpty &&
                                  paidAmount.isNotEmpty) {
                                final exchangeResponse = await controller
                                    .fetchExchangeRateCA(currency, paidAmount);

                                if (exchangeResponse != null) {
                                  controller.unitRateCA2.text =
                                      exchangeResponse.exchangeRate.toString();
                                  controller.amountINRCA2.text =
                                      exchangeResponse.totalAmount
                                          .toStringAsFixed(2);
                                  controller.isVisible.value = true;
                                }
                              }
                            },
                            onEditingComplete: () {
                              String text = controller.paidAmountCA2.text;
                              double? value = double.tryParse(text);
                              if (value != null) {
                                controller.paidAmountCA2.text =
                                    value.toStringAsFixed(2);
                              }
                            },
                          ),
                        ),

                        // Currency Dropdown
                        Obx(
                          () => SizedBox(
                            width: 90,
                            child: SearchableMultiColumnDropdownField<Currency>(
                              labelText: "",
                              alignLeft: -90,
                              dropdownWidth: 280,
                              columnHeaders: const ['Code', 'Name', 'Symbol'],
                              controller:
                                  controller.currencyDropDowncontrollerCA2,
                              items: controllerItems.currencies,
                              selectedValue:
                                  controller.selectedCurrencyCA2.value,
                              backgroundColor: Colors.white,
                              searchValue: (c) =>
                                  '${c.code} ${c.name} ${c.symbol}',
                              displayText: (c) => c.code,
                              inputDecoration: const InputDecoration(
                                isDense: true,
                                suffixIcon:
                                    Icon(Icons.arrow_drop_down_outlined),
                                filled: true,
                                fillColor: Color(0xFFF7F7F7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              validator: (c) =>
                                  c == null ? 'Please select currency' : null,
                              onChanged: (c) async {
                                controller.selectedCurrencyCA2.value = c;
                                controller.currencyDropDowncontrollerCA2.text =
                                    c?.code ?? '';

                                final paidAmount =
                                    controller.paidAmountCA2.text.trim();
                                if (paidAmount.isNotEmpty) {
                                  final exchangeResponse = await controller
                                      .fetchExchangeRateCA(c!.code, paidAmount);

                                  if (exchangeResponse != null) {
                                    controller.unitRateCA2.text =
                                        exchangeResponse.exchangeRate
                                            .toString();
                                    controller.amountINRCA2.text =
                                        exchangeResponse.totalAmount
                                            .toStringAsFixed(2);
                                  }
                                }
                              },
                              rowBuilder: (c, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(c.code)),
                                      Expanded(child: Text(c.name)),
                                      Expanded(child: Text(c.symbol)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Rate Field
                        Expanded(
                          child: TextFormField(
                            controller: controller.unitRateCA2,
                            enabled: false,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Rate',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Amount in INR
                    TextFormField(
                      controller: controller.amountINRCA2,
                      enabled: false,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Amount in INR *',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descriptionController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Comments",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_itemizeCount > 1)
                  OutlinedButton.icon(
                    onPressed: () => _removeItemize(_selectedItemizeIndex),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gradientEnd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.delete,
                        color: Color.fromARGB(255, 233, 8, 8)),
                    label: const Text(
                      "Remove",
                      style: TextStyle(color: AppColors.gradientEnd),
                    ),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _addItemize,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gradientEnd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: AppColors.gradientEnd),
                  label: const Text(
                    'Itemize',
                    style: TextStyle(color: AppColors.gradientEnd),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() => SwitchListTile(
                title: const Text("Is Reimbursable",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                value: controller.isReimbursiteCreate.value,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (val) {
                  controller.isReimbursiteCreate.value = val;
                })),
            SwitchListTile(
                title: const Text("Is Billable",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                value: controller.isBillable.value,
                activeColor: Colors.blue,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (val) {
                  setState(() {
                    controller.isBillable.value = val;
                  });
                }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                          _pageController.animateToPage(
                            _currentStep,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text(
                        'Back',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  else
                    const SizedBox(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Reset error states
                      setState(() {
                        _showQuantityError = false;
                        _showUnitAmountError = false;
                        _showUnitError = false;
                        _showTaxAmountError = false;
                      });

                      bool isValid = true;

                      if (controller.selectedCategoryId.isEmpty) {
                        setState(() => _showPaidForError = true);
                        isValid = false;
                      }
                      if (_itemizeCount > 1) {
                        if (controller.quantity.text.isEmpty) {
                          setState(() => _showQuantityError = true);
                          isValid = false;
                        }

                        if (controller.unitAmount.text.isEmpty) {
                          setState(() => _showUnitAmountError = true);
                          isValid = false;
                        }

                        if (controller.selectedunit == null) {
                          setState(() => _showUnitError = true);
                          isValid = false;
                        }
                      }
                      final taxAmountMandatory = isFieldMandatory('Tax Amount');
                      // Validate other mandatory fields
                      if (controller.taxAmount.text.isEmpty &&
                          taxAmountMandatory) {
                        setState(() => _showTaxAmountError = true);
                        isValid = false;
                      }
                      // Validate Project Id if mandatory
                      final projectIdMandatory = isFieldMandatory('Project Id');

                      print("projectIdMandatory$projectIdMandatory");
                      print(
                          "projectIdMandatory${controller.selectedProject == null}");
                      if (projectIdMandatory &&
                          controller.selectedProject == null) {
                        setState(() => _showProjectError = true);
                        isValid = false;
                      } else {
                        setState(() => _showProjectError = false);
                      }

                      print('isValid$isValid');
                      print('isValid${itemizeControllers.length}');
                      if (isValid) {
                        final items = itemizeControllers
                            .map((c) => c.toCashAdvanceRequestItemize())
                            .toList();

                        for (var item in items) {
                          print(
                              "📝 CashAdvanceRequestItemize: ${jsonEncode(item.toJson())}");
                        }

                        controllerItems.finalItemsCashAdvance = items;
                        _nextStep();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.gradientEnd,
                      side: const BorderSide(color: AppColors.gradientEnd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Finish' : 'Next',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    )));
  }

  double _calculateTotalLineAmount(Controller controllers) {
    double total = 0.0;

    final currentLineAmount =
        double.tryParse(controllers.amountINRCA1.text) ?? 0.0;
    total += currentLineAmount;

    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.amountINRCA1.text) ?? 0.0;
        total += amount;
      }
    }
    controller.estimatedamountINR.text = total.toString();
    print("total$total");
    return total;
  }

  double _calculateTotalLineAmount2(Controller controllers) {
    double total = 0.0;

    final currentLineAmount =
        double.tryParse(controllers.amountINRCA2.text) ?? 0.0;
    total += currentLineAmount;

    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.amountINRCA2.text) ?? 0.0;
        total += amount;
      }
    }
    controller.requestamountINR.text = total.toString();
    print("total222$total");
    return total;
  }

  Widget _buildCategoryButton(
    int index,
    ExpenseCategory item,
    String iD,
    Color color,
    Color textColor,
    String? icon,
    Controller controllers,
  ) {
    final isSelected = controllers.selectedCategoryId == item.categoryId;

    Widget _buildIcon(String? icon) {
      const fallbackUrl =
          "https://icons.veryicon.com/png/o/commerce-shopping/icon-of-lvshan-valley-mobile-terminal/home-category.png";

      try {
        if (icon != null && icon.isNotEmpty) {
          if (icon.startsWith('data:image')) {
            // Data URI: extract base64 part
            final base64Str = icon.split(',').last;
            Uint8List bytes = base64Decode(base64Str);
            return Image.memory(
              bytes,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(icon)) {
            // Plain base64 (no prefix)
            Uint8List bytes = base64Decode(icon);
            return Image.memory(
              bytes,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else {
            // URL case
            return Image.asset(
              icon,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          }
        }
      } catch (_) {
        // Invalid base64 or broken URL
      }

      // Fallback image
      return Image.network(
        fallbackUrl,
        width: 30,
        height: 30,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 30),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
        _showPaidForError = false;
        controllers.selectedCategoryId = item.categoryId;
        controller.selectedCategoryId = item.categoryId;
        controller.fetchMaxAllowedPercentage();
        print("Tapped Category Name: ${item.categoryName}");
        print("Tapped Category ID: ${controllers.selectedCategoryId}");

        // // Optionally store or process them
        // selectedCategoryName = item.categoryName;
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(icon),
            const SizedBox(height: 8),
            Text(
              item.categoryId,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            filled: !enabled ? true : false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget expenseCreationFormStep1(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return controller.isLoadingGE2.value
            ? SkeletonLoaderPage()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  // key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: controller.cashAdvanceRequisitionID,
                        decoration: InputDecoration(
                          labelText: 'Cash Advance Requisition ID *',
                          // filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormField<DateTime>(
                        validator: (value) {
                          if (controller.selectedDate == null) {
                            return 'Please select a request date';
                          }
                          return null;
                        },
                        builder: (FormFieldState<DateTime> field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _selectDate(context);
                                  field.didChange(controller.selectedDate);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Request Date *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    errorText: field.errorText,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.selectedDate == null
                                            ? 'Select date'
                                            : DateFormat('dd/MM/yyyy').format(
                                                controller.selectedDate!),
                                        style: TextStyle(
                                          color: controller.selectedDate == null
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today,
                                          size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      Obx(() {
                        return Column(
                          children: controller.configListAdvance
                              .where((field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] == 'Refrence Id')
                              .map((field) {
                            final String label = field['FieldName'];
                            final bool isMandatory =
                                field['IsMandatory'] ?? false;
                            isThereReferenceID = field['IsMandatory'] ?? false;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                FormField<String>(
                                  validator: (value) {
                                    if (isMandatory &&
                                        (value == null || value.isEmpty)) {
                                      return 'This field is required';
                                    }
                                    return null;
                                  },
                                  builder: (FormFieldState<String> field) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: controller.referenceID,
                                          onChanged: (value) {
                                            field.didChange(value);
                                            selectReferenceIDError = null;
                                          },
                                          decoration: InputDecoration(
                                              labelText:
                                                  '$label${isMandatory ? " *" : ""}',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              errorText: field.errorText),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                if (selectReferenceIDError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 8),
                                    child: Text(
                                      selectReferenceIDError.toString(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        );
                      }),
                      // Paid To Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          SearchableMultiColumnDropdownField<
                              Businessjustification>(
                            labelText: 'Business Justification * ',
                            columnHeaders: const ['ID', 'Name'],
                            items: controller.justification,
                            selectedValue: controller.selectedjustification,
                            searchValue: (p) => '${p.id} ${p.name}',
                            displayText: (p) => p.name,
                            validator: (_) => null,
                            onChanged: (p) {
                              setState(() {
                                controller.selectedjustification = p;
                                paidToError = null;
                              });
                            },
                            rowBuilder: (p, searchQuery) {
                              Widget highlight(String text) {
                                final lowerQuery = searchQuery.toLowerCase();
                                final lowerText = text.toLowerCase();
                                final start = lowerText.indexOf(lowerQuery);

                                if (start == -1 || searchQuery.isEmpty) {
                                  return Text(text);
                                }

                                final end = start + searchQuery.length;
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: text.substring(0, start),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: text.substring(start, end),
                                        style: const TextStyle(
                                          color: Colors.black,
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
                                    Expanded(child: highlight(p.id)),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          if (paidToError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, bottom: 8),
                              child: Text(
                                paidToError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Paid With',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Paid With Radio Buttons
                      Obx(() {
                        if (controller.paidWith == null &&
                            controller.paymentMethods.isNotEmpty) {
                          controller.paidWith =
                              controller.paymentMethods.first.paymentMethodId;
                          controller.paymentMethodeID =
                              controller.paymentMethods.first.paymentMethodId;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Payment methods list
                            ...List.generate(controller.paymentMethods.length,
                                (index) {
                              final method = controller.paymentMethods[index];

                              List<Color> colors = [
                                Colors.red.shade100,
                                Colors.green.shade100,
                                Colors.blue.shade100,
                                Colors.orange.shade100,
                              ];

                              List<IconData> icons = [
                                Icons.credit_card,
                                Icons.money,
                                Icons.payment,
                                Icons.account_balance_wallet,
                              ];

                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: RadioListTile<String>(
                                  title: Row(
                                    children: [
                                      Icon(icons[index % icons.length],
                                          color: Colors.black),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          method.paymentMethodName,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: method.paymentMethodId,
                                  groupValue: controller.paidWith,
                                  onChanged: (String? value) {
                                    controller.paymentMethodeID = value;
                                    setState(() {
                                      controller.paidWith = value;
                                    });
                                    // paidwithError.value =
                                    //     null; // Clear error on selection
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  tileColor: Colors.transparent,
                                ),
                              );
                            }),

                            // Error message below the list
                            const SizedBox(height: 8),

                            // if (paidwithError.value != null)
                            //   Padding(
                            //     padding:
                            //         const EdgeInsets.only(left: 8.0, bottom: 8),
                            //     child: Text(
                            //       paidwithError.value!,
                            //       style: const TextStyle(color: Colors.red),
                            //     ),
                            //   ),
                          ],
                        );
                      }),

                      // Show validation error under Paid With (if any)

                      // const SizedBox(height: 20),

                      // // Submit Button
                      //   SizedBox(
                      //     width: double.infinity,
                      //     child: ElevatedButton(
                      //     onPressed: () {
                      //       final isValid = _formKey.currentState!.validate();
                      //       final isPaidWithValid = _paidWith != null;

                      //       setState(() {
                      //         _showPaidWithError = !isPaidWithValid;
                      //       });

                      //       if (isValid && isPaidWithValid) {
                      //         print('Form is valid. Proceed with submission.');
                      //         // Continue to API or next step...
                      //       } else {
                      //         print('Validation failed');
                      //       }
                      //     },
                      //     child: const Text('Submit'),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _currentStep--;
                                    _pageController.animateToPage(
                                      _currentStep,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black),
                                label: const Text(
                                  'Back',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            else
                              const SizedBox(), // Empty space if back is not shown

                            const Spacer(),

                            ElevatedButton(
                              onPressed: () {
                                if (validateDropdowns()) {
                                  // final isValid =
                                  //     _formKey.currentState!.validate();
                                  // final isPaidWithValid =
                                  //     controller.paidWith != null;

                                  // setState(() {
                                  //   _showPaidWithError = !isPaidWithValid;
                                  // });

                                  // if (isPaidWithValid) {
                                  //   _nextStep();
                                  // } else {
                                  //   print('Validation failed');
                                  // }
                                  _nextStep();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.gradientEnd,
                                side: const BorderSide(
                                    color: AppColors.gradientEnd),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentStep == 2 ? 'Finish' : 'Next',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  // bool controller._isVisible = false;

  final FocusNode _focusNode = FocusNode();
  final PhotoViewController _photoViewController = PhotoViewController();
  final controller = Get.put(Controller());
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      controller.isImageLoading.value = true;

      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          setState(() {
            controller.imageFiles.add(File(croppedFile.path));
          });
        }
      }
    } catch (e) {
      print("Error picking or cropping image: $e");
      Fluttertoast.showToast(
        msg: "Failed to upload image",
        backgroundColor: Colors.red,
      );
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<File?> _cropImage(File file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        )
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }

    return null;
  }

  void _zoomIn() {
    _photoViewController.scale = _photoViewController.scale! * 1.2;
  }

  void _zoomOut() {
    _photoViewController.scale = _photoViewController.scale! / 1.2;
  }

  void _deleteImage() {
    setState(() {
      controller.imageFile = null;
    });
  }

  void _showFullImage(File file, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(file),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: "zoom_in_$index",
                      onPressed: _zoomIn,
                      child: const Icon(Icons.zoom_in),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "zoom_out_$index",
                      onPressed: _zoomOut,
                      child: const Icon(Icons.zoom_out),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "edit_$index",
                      onPressed: () => _cropImage(file),
                      child: const Icon(Icons.edit),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "delete_$index",
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          controller.imageFiles.removeAt(index);
                        });
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageArea() {
    @override
    void initState() {
      super.initState();

      if (controller.paidAmount.text.isNotEmpty) {
        // final amount = double.tryParse(controller.paidAmount.text) ?? 0.0;
        // final unit = double.tryParse(controller.unitRate.text) ?? 0.0;
        // final result = amount * unit;
        // controller.amountINR.text = result.toString();
        controller.fetchExchangeRate();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.imageFiles.isEmpty) {
                return const Center(child: Text('Tap to Upload Document(s)'));
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.imageFiles.length,
                  itemBuilder: (context, index) {
                    final file = controller.imageFiles[index];
                    return GestureDetector(
                      onTap: () => _showFullImage(file, index),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (controller.paidAmount.text.isNotEmpty) {
      final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
      final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

      final result = paid * rate;

      controller.amountINR.text = result.toStringAsFixed(2);
    }
    // Listen for focus changes
    // _focusNode.addListener(() {
    //   if (!_focusNode.hasFocus) {
    //     setState(() {
    //       // Toggle visibility when focus is lost
    //       // controller.fetchExchangeRate();
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImageArea(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.estimatedamountINR,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Total Estimated Amount In INR *',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: controller.requestamountINR,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Total Request Amount In INR *',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Policy Violations',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Check Policies',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Policy Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Policy 1001',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(child: Text("Expense Amount Under Limit")),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Receipt Required Amount :Amount  in any expense\nRecorded Should have a receipt",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.close, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "if description has been made mandatory by the Admin for all expense",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "An expense that has expired is Considered a Policy",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Buttons
                Center(
                  child: Column(
                    children: [
                      Obx(() {
                        return GradientButton(
                          text: "Submit",
                          isLoading: controller.isGESubmitBTNLoading.value,
                          onPressed: () {
                            controller.saveCashAdvance(context, true, false);
                          },
                        );
                      }),
                      // SizedBox(
                      //   width: 200,
                      //   height: 48,
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       // Your action here
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       padding: EdgeInsets.zero,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(24),
                      //       ),
                      //       backgroundColor: Colors.transparent, // Important!
                      //       shadowColor: Colors.transparent,
                      //     ),
                      //     child: Ink(
                      //       decoration: BoxDecoration(
                      //         gradient: const LinearGradient(
                      //           colors: [Colors.indigo, Colors.blueAccent],
                      //         ),
                      //         borderRadius: BorderRadius.circular(24),
                      //       ),
                      //       child: Container(
                      //         alignment: Alignment.center,
                      //         child: const Text(
                      //           'Submit',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            return ElevatedButton(
                              onPressed: controller.isUploading.value
                                  ? null
                                  : () {
                                     controller.saveCashAdvance(context, false, false);
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(130, 50),
                                backgroundColor: Color.fromARGB(241, 20, 94, 2),
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
                              child: controller.isUploading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Save"),
                            );
                          }),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130, 50),
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              controller.chancelButton(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Text("Cancel",
                                  style: TextStyle(
                                      letterSpacing: 1.5, color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
