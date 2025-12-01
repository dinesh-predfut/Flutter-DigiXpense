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
import 'package:flutter/services.dart';
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

import '../../../../l10n/app_localizations.dart';
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
  bool allowDocAttachments = false;
  int _currentStep = 0;
  RxBool showField = true.obs;
  int _itemizeCount = 1;
  late FocusNode _focusNode;
  bool _isTyping = false;
  int _selectedItemizeIndex = 0;
  int _selectedCategoryIndex = -1;
  bool _showExpenseIdError = false;
  // bool controller.showPaidForError.value = false;
  bool _showRequestedAmountError = false;
  bool _showPaidAmountError = false;
  // bool controller.showQuantityError.value = false;
  // bool controller.showUnitAmountError.value = false;
  bool _showPercentageError = false;
  bool _showUnitError = false;
  bool _showLocationError = false;
  // bool controller.showProjectError.value = false;
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
  // final List<String> _titles = ["Payment Info", "Itemize", "Expense Details"];
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    controller.selectedDate ??= DateTime.now();
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    // controller.clearFormFields();
    // controllerItems.requestedPercentage.text="100";
    if (controllerItems.requestedPercentage.text.isEmpty) {
      controllerItems.requestedPercentage.text = "100";
    }
    controller.selectedDate ??= DateTime.now();

    // controller.fetchPaidto();

    itemizeControllers.add(Controller());
    controller.configuration();
    controller.isManualEntryMerchant = false;
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadSequenceAndUpdateUI();
          _initializeUnits();
controller.fetchPaidto();
      await controller.fetchMaxAllowedPercentage();
      controller.fetchCashAdvanceRequests();
      controller.getconfigureFieldCashAdvance();
      
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.getUserPref(context);
      controller.fetchExpenseCategory();

      controller.fetchBusinessjustification();
      controller.fetchLocation();
    });
  }

  void loadSequenceAndUpdateUI() async {
    final sequence = await controller.fetchCashAdvanceSequence();

    if (sequence != null &&
        sequence.nextNumber != null &&
        sequence.nextNumber!.isNotEmpty) {
      showField.value = false;
    } else {
      showField.value = true; // show the field
    }
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowDocAttachments = settings.allowDocAttachments;
        print("allowDocAttachments$allowDocAttachments");
        // isLoading = false;
      });
    } else {
      // setState(() => isLoading = false);
    }
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
        paidToError = 'Please select a Business Justification';
        isValid = false;
      });
    } else if (showField.value) {
      if (controller.expenseIdController.text.trim().isEmpty) {
        setState(() {
          _showExpenseIdError = true;
        });
      }
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
      lastDate: DateTime.now(),
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
    print("its Called CAS");
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
      print("selectedunitt${controller.selectedunit}");
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
    final List<String> _titles = [
      AppLocalizations.of(context)!.paymentInfo,
      AppLocalizations.of(context)!.itemize,
      AppLocalizations.of(context)!.expenseDetails,
    ];
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
                  Text(
                    AppLocalizations.of(context)!.itemize,
                    style: const TextStyle(fontSize: 12),
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
      controller.showQuantityError.value = false;
      controller.showUnitAmountError.value = false;
      _showUnitError = false;
      _showTaxAmountError = false;
      controller.showPaidForError.value = false;
      _showRequestedAmountError = false;
    });

    // Validate Paid For (category)
    if (controller.selectedCategoryId.isEmpty) {
      controller.showPaidForError.value = true;
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
        controller.showQuantityError.value = true;
        isValid = false;
      }

      if (controller.unitAmount.text.trim().isEmpty) {
        controller.showUnitAmountError.value = true;
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
            labelColor: Theme.of(context).colorScheme.secondary,
            onTap: (index) {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            tabs: List.generate(
              _itemizeCount,
              (index) => Tab(
                text: "${AppLocalizations.of(context)!.itemize} ${index + 1}",
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: List.generate(
                _itemizeCount,
                (index) => Center(
                  child: expenseCreateForm2(context, itemizeControllers[index]),
                ),
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

  void backButton() {
    print("Its BAck");
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.clearFormFields();
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitForm),
            content: Text(AppLocalizations.of(context)!.exitWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirm exit
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          controller.clearFormFields();
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          return true; // allow back navigation
        }

        return false; // cancel back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.cashAdvanceRequestForm,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
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
                  CreateExpensePage(
                    allowDocAttachments: allowDocAttachments,
                    backButton: backButton,
                  ),
                ],
              ),
            ),
          ],
        ),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     children: [
        //       if (_currentStep == 2)
        //         OutlinedButton.icon(
        //           onPressed: () {
        //             setState(() {
        //               _currentStep--;
        //               _pageController.animateToPage(
        //                 _currentStep,
        //                 duration: const Duration(milliseconds: 300),
        //                 curve: Curves.easeInOut,
        //               );
        //             });
        //           },
        //           style: OutlinedButton.styleFrom(
        //             side: const BorderSide(color: Colors.grey),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //           ),
        //           icon: const Icon(Icons.arrow_back),
        //           label: Text(AppLocalizations.of(context)!.back),
        //         ),
        //       if (_currentStep == 2)
        //         const SizedBox(height: 100)
        //       else
        //         const SizedBox(), // Empty space if back is not shown
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget expenseCreateForm2(BuildContext context, Controller controller) {
    final theme = Theme.of(context);
    print(
      "controllerItems.requestedPercentage.text${controllerItems.selectedunit}",
    );
    print("selecteduni${controller.selectedunit}");
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 PROJECT ID SECTION
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controllerItems.configListAdvance
                      .where(
                        (field) =>
                            field['FieldName'] == 'Project Id' &&
                            field['IsEnabled'] == true,
                      )
                      .map((field) {
                        final String label = field['FieldName'];
                        final bool isMandatory = field['IsMandatory'] ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchableMultiColumnDropdownField<Project>(
                              labelText:
                                  '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}',
                              columnHeaders: [
                                AppLocalizations.of(context)!.projectName,
                                AppLocalizations.of(context)!.projectId,
                              ],
                              // enabled: controller.isEditModePerdiem,
                              controller: controller.projectIdController,
                              items: controllerItems.project,
                              selectedValue: controller.selectedProject,
                              searchValue: (proj) =>
                                  '${proj.name} ${proj.code}',
                              displayText: (proj) => proj.code,
                              onChanged: (proj) {
                                setState(() {
                                  controller.selectedProject = proj;
                                  if (proj != null) {
                                    controller.showProjectError.value = false;
                                  }
                                });
                                // Optional: Fetch categories after selecting project
                                // controller.fetchExpenseCategory();
                              },
                              rowBuilder: (proj, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(proj.name)),
                                      Expanded(child: Text(proj.code)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (controller.showProjectError.value)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Please select a Project',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        );
                      })
                      .toList(),
                );
              }),

              /// 🔹 LOCATION SECTION
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controllerItems.configListAdvance
                      .where(
                        (field) =>
                            field['FieldName'] == 'Location' &&
                            field['IsEnabled'] == true,
                      )
                      .map((field) {
                        final String label = field['FieldName'];
                        final bool isMandatory = field['IsMandatory'] ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchableMultiColumnDropdownField<LocationModel>(
                              labelText:
                                  '${AppLocalizations.of(context)!.location} ${isMandatory ? "*" : ""}',
                              columnHeaders: [
                                AppLocalizations.of(context)!.location,
                                AppLocalizations.of(context)!.country,
                              ],
                              // enabled: controller.isEditModePerdiem,
                              controller: controller.locationController,
                              items: controllerItems.location,
                              selectedValue: controller.selectedLocation,
                              searchValue: (loc) => loc.location,
                              displayText: (loc) => loc.location,
                              validator: (loc) => isMandatory && loc == null
                                  ? AppLocalizations.of(
                                      context,
                                    )!.pleaseSelectLocation
                                  : null,
                              onChanged: (loc) {
                                controller.selectedLocation = loc;
                                controller.fetchMaxAllowedPercentage();
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();

                                // Start a new debounce timer
                                _debounce = Timer(
                                  const Duration(milliseconds: 400),
                                  () async {
                                    final paidAmountText = controller
                                        .paidAmountCA1
                                        .text
                                        .trim();
                                    controller.unitAmount.text =
                                        controller.paidAmountCA1.text;
                                    final double paidAmounts =
                                        double.tryParse(paidAmountText) ?? 0.0;
                                    final currency = controller
                                        .currencyDropDowncontrollerCA3
                                        .text;

                                    // Only proceed if currency and amount are provided
                                    if (currency.isNotEmpty &&
                                        paidAmountText.isNotEmpty) {
                                      // Fire API calls concurrently
                                      final results = await Future.wait([
                                        controller.fetchExchangeRateCA(
                                          currency,
                                          paidAmountText,
                                        ),
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
                                      final maxPercentage =
                                          results[1] as double?;

                                      if (maxPercentage != null &&
                                          maxPercentage > 0) {
                                        final double calculatedPercentage =
                                            (paidAmounts * maxPercentage) / 100;

                                        controller.totalRequestedAmount.text =
                                            calculatedPercentage.toString();
                                        controller.calculatedPercentage.value =
                                            calculatedPercentage;

                                        // final percentageStr = maxPercentage
                                        //     .toInt()
                                        //     .toString();
                                        // controller.requestedPercentage.text =
                                        //     '$percentageStr %';
                                      }
                                      final reqPaidAmount = controller
                                          .totalRequestedAmount
                                          .text
                                          .trim();
                                      final reqCurrency = controller
                                          .currencyDropDowncontrollerCA2
                                          .text;
                                      if (reqCurrency.isNotEmpty &&
                                          reqPaidAmount.isNotEmpty) {
                                        final exchangeResponse =
                                            await controller
                                                .fetchExchangeRateCA(
                                                  reqCurrency,
                                                  reqPaidAmount,
                                                );

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
                                  },
                                );
                                field['Error'] =
                                    null; // Clear error when value selected
                              },
                              rowBuilder: (loc, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.pleaseSelectLocation,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        );
                      })
                      .toList(),
                );
              }),

              const SizedBox(height: 6),
              Text("${AppLocalizations.of(context)!.paidFor} *"),
              const SizedBox(height: 1),
              if (controller.showPaidForError.value)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    AppLocalizations.of(context)!.pleaseSelectCategory,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context)!.requestedPercentage} %",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) async {
                  final percentage = double.tryParse(value) ?? 0.0;
                  final paidAmount =
                      double.tryParse(controller.paidAmountCA1.text) ?? 0.0;

                  if (paidAmount > 0 && percentage > 0) {
                    // Step 1: Calculate requested amount (foreign currency)
                    final requestedAmount = (paidAmount * percentage) / 100;
                    controller.totalRequestedAmount.text = requestedAmount
                        .toStringAsFixed(2);

                    // Step 2: Update INR value (CA2)
                    final reqCurrency =
                        controller.currencyDropDowncontrollerCA2.text;
                    if (reqCurrency.isNotEmpty) {
                      final exchangeResponse = await controller
                          .fetchExchangeRateCA(
                            reqCurrency,
                            requestedAmount.toString(),
                          );
                      if (exchangeResponse != null) {
                        controller.unitRateCA2.text = exchangeResponse
                            .exchangeRate
                            .toString();
                        controller.amountINRCA2.text = exchangeResponse
                            .totalAmount
                            .toStringAsFixed(2);
                      }
                    }
                  } else {
                    controller.amountINRCA2.text = '0.00';
                  }
                },
              ),

              if (_showPercentageError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Please enter a valid percentage between 1-100',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(tax.code)),
                              Expanded(child: Text(tax.name)),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],

                            controller: controller.unitAmount,
                            onChanged: (value) {
                              // controllerItems.unitAmount.text = value;

                              setState(() {
                                controller.unitAmount.text = value;
                                controller.showUnitAmountError.value = false;
                              });

                              // Step 1: Calculate line total
                              final qty =
                                  double.tryParse(controller.quantity.text) ??
                                  0.0;
                              final unit =
                                  double.tryParse(controller.unitAmount.text) ??
                                  0.0;
                              final calculatedLineAmount = qty * unit;

                              controller.paidAmountCA1.text =
                                  calculatedLineAmount.toStringAsFixed(2);
                              controller.paidAmount.text = calculatedLineAmount
                                  .toStringAsFixed(2);

                              // Step 2: Debounce to avoid frequent API calls
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();

                              _debounce = Timer(
                                const Duration(milliseconds: 400),
                                () async {
                                  final paidAmountText = controller
                                      .paidAmountCA1
                                      .text
                                      .trim();
                                  final double paidAmounts =
                                      double.tryParse(paidAmountText) ?? 0.0;
                                  final currency = controller
                                      .currencyDropDowncontrollerCA3
                                      .text;

                                  // ✅ Only proceed if we have currency + amount
                                  if (currency.isNotEmpty &&
                                      paidAmountText.isNotEmpty) {
                                    // Fire API call for Exchange Rate
                                    final results = await Future.wait([
                                      controller.fetchExchangeRateCA(
                                        currency,
                                        paidAmountText,
                                      ),
                                    ]);

                                    // Step 3: Process exchange rate for CA1
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

                                    // ✅ Step 4: Use requestedPercentage instead of maxPercentage
                                    final requestedPercentageText = controller
                                        .requestedPercentage
                                        .text
                                        .trim();
                                    final double requestedPercentage =
                                        double.tryParse(
                                          requestedPercentageText
                                              .replaceAll('%', '')
                                              .trim(),
                                        ) ??
                                        0.0;

                                    if (requestedPercentage > 0 &&
                                        paidAmounts > 0) {
                                      // Calculate requested amount (foreign currency)
                                      final double calculatedRequestedAmount =
                                          (paidAmounts * requestedPercentage) /
                                          100;

                                      controller.totalRequestedAmount.text =
                                          calculatedRequestedAmount
                                              .toStringAsFixed(2);
                                      controller.calculatedPercentage.value =
                                          calculatedRequestedAmount;
                                    } else {
                                      controller.totalRequestedAmount.text =
                                          '0.00';
                                    }

                                    // ✅ Step 5: Convert requested amount to INR (CA2)
                                    final reqPaidAmount = controller
                                        .totalRequestedAmount
                                        .text
                                        .trim();
                                    final reqCurrency = controller
                                        .currencyDropDowncontrollerCA2
                                        .text;

                                    if (reqCurrency.isNotEmpty &&
                                        reqPaidAmount.isNotEmpty) {
                                      final exchangeResponse = await controller
                                          .fetchExchangeRateCA(
                                            reqCurrency,
                                            reqPaidAmount,
                                          );

                                      if (exchangeResponse != null) {
                                        controller.unitRateCA2.text =
                                            exchangeResponse.exchangeRate
                                                .toString();
                                        controller.amountINRCA2.text =
                                            exchangeResponse.totalAmount
                                                .toStringAsFixed(2);
                                      }
                                    }
                                  }
                                },
                              );
                            },

                            onEditingComplete: () {
                              String text = controller.unitAmount.text;
                               FocusScope.of(context).unfocus();
                              double? value = double.tryParse(text);
                              if (text.isEmpty || value == null ) {
                                setState(() {
                                  controller.showUnitAmountError.value = true;
                                });
                                return;
                              }
                            },
                            decoration: InputDecoration(
                              labelText:
                                  "${AppLocalizations.of(context)!.unitEstimatedAmount}*",
                              errorText: controller.showUnitAmountError.value
                                  ? AppLocalizations.of(
                                      context,
                                    )!.unitAmountIsRequired
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // enabledBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              // focusedBorder: OutlineInputBorder(
                              //   borderSide: const BorderSide(width: 2),
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                            ),
                          ),
                        ),
                        if (showItemizeDetails) const SizedBox(width: 12),
                        if (showItemizeDetails)
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ), // Allows numbers with up to 2 decimal places
                              ],
                              controller: controller.quantity,
                              onChanged: (value) {
                                setState(() {
                                  controller.quantity.text = value;
                                  controller.showQuantityError.value = false;
                                  setQuality = false;
                                });

                                final qty =
                                    double.tryParse(controller.quantity.text) ??
                                    0.0;
                                final unit =
                                    double.tryParse(
                                      controller.unitAmount.text,
                                    ) ??
                                    0.0;

                                // Step 1️⃣: Calculate base line total
                                final calculatedLineAmount = qty * unit;
                                print(
                                  "calculatedLineAmount: $qty x $unit = $calculatedLineAmount",
                                );

                                controller.paidAmountCA1.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.paidAmontIsEditable.value = false;

                                // Step 2️⃣: Debounce to avoid multiple API calls
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();

                                _debounce = Timer(
                                  const Duration(milliseconds: 400),
                                  () async {
                                    final paidAmountText = controller
                                        .paidAmountCA1
                                        .text
                                        .trim();
                                    final double paidAmounts =
                                        double.tryParse(paidAmountText) ?? 0.0;
                                    final currency = controller
                                        .currencyDropDowncontrollerCA3
                                        .text;

                                    // Proceed only if valid
                                    if (currency.isNotEmpty &&
                                        paidAmountText.isNotEmpty) {
                                      // Step 3️⃣: Fetch exchange rate for CA1
                                      final results = await Future.wait([
                                        controller.fetchExchangeRateCA(
                                          currency,
                                          paidAmountText,
                                        ),
                                      ]);

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

                                      // Step 4️⃣: Read requested percentage instead of maxPercentage
                                      final requestedPercentageText = controller
                                          .requestedPercentage
                                          .text
                                          .trim();
                                      final double requestedPercentage =
                                          double.tryParse(
                                            requestedPercentageText
                                                .replaceAll('%', '')
                                                .trim(),
                                          ) ??
                                          0.0;

                                      if (requestedPercentage > 0 &&
                                          paidAmounts > 0) {
                                        // Calculate requested amount (in same currency)
                                        final double calculatedRequestedAmount =
                                            (paidAmounts *
                                                requestedPercentage) /
                                            100;

                                        controller.totalRequestedAmount.text =
                                            calculatedRequestedAmount
                                                .toStringAsFixed(2);
                                        controller.calculatedPercentage.value =
                                            calculatedRequestedAmount;
                                      } else {
                                        controller.totalRequestedAmount.text =
                                            '0.00';
                                      }

                                      // Step 5️⃣: Convert requested amount to INR (CA2)
                                      final reqPaidAmount = controller
                                          .totalRequestedAmount
                                          .text
                                          .trim();
                                      final reqCurrency = controller
                                          .currencyDropDowncontrollerCA2
                                          .text;

                                      if (reqCurrency.isNotEmpty &&
                                          reqPaidAmount.isNotEmpty) {
                                        final exchangeResponse =
                                            await controller
                                                .fetchExchangeRateCA(
                                                  reqCurrency,
                                                  reqPaidAmount,
                                                );

                                        if (exchangeResponse != null) {
                                          controller.unitRateCA2.text =
                                              exchangeResponse.exchangeRate
                                                  .toString();
                                          controller.amountINRCA2.text =
                                              exchangeResponse.totalAmount
                                                  .toStringAsFixed(2);
                                        }
                                      }
                                    }
                                  },
                                );
                              },

                              decoration: InputDecoration(
                                labelText:
                                    "${AppLocalizations.of(context)!.quantity}*",
                                errorText: controller.showQuantityError.value
                                    ? AppLocalizations.of(
                                        context,
                                      )!.quantityRequired
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // enabledBorder: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                // focusedBorder: OutlineInputBorder(
                                //   borderSide: const BorderSide(width: 2),
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    //  if (controller.showUnitAmountError.value)
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 4),
                    //           child: Text(
                    //             AppLocalizations.of(context)!.fieldRequired,
                    //             style: const TextStyle(
                    //               color: Colors.red,
                    //               fontSize: 12,
                    //             ),
                    //           ),
                    //         ),
                  // if (controller.lineAmount.text.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          final double lineAmount =
                              double.tryParse(
                                controller.totalRequestedAmount.text,
                              ) ??
                              0.0;

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
                            controller.split.add(
                              AccountingSplit(percentage: 100.0),
                            );
                          }

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
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
                                    controller.accountingDistributions.addAll(
                                      newList,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.accountDistribution,
                        ),
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
                          Text(
                            '${AppLocalizations.of(context)!.totalEstimatedAmountIn} *',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
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
                                  textInputAction: TextInputAction
                                      .done, // 👉 Enter key becomes DONE
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(
                                      context,
                                    ).unfocus(); // 👉 Keyboard closes on Enter
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ), // Allows numbers with up to 2 decimal places
                                  ],
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.totalEstimatedAmountIn,
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
                                    // Cancel any active debounce
                                    if (_debounce?.isActive ?? false)
                                      _debounce!.cancel();

                                    // Start new debounce
                                    _debounce = Timer(
                                      const Duration(milliseconds: 400),
                                      () async {
                                        final paidAmountText = controller
                                            .paidAmountCA1
                                            .text
                                            .trim();
                                        controller.unitAmount.text =
                                            controller.paidAmountCA1.text;

                                        final double paidAmounts =
                                            double.tryParse(paidAmountText) ??
                                            0.0;
                                        final currency = controller
                                            .currencyDropDowncontrollerCA3
                                            .text;

                                        // ✅ Only proceed if currency and amount are provided
                                        if (currency.isNotEmpty &&
                                            paidAmountText.isNotEmpty) {
                                          // Step 1: Fetch exchange rate for CA1
                                          final results = await Future.wait([
                                            controller.fetchExchangeRateCA(
                                              currency,
                                              paidAmountText,
                                            ),
                                          ]);

                                          final exchangeResponse1 =
                                              results[0]
                                                  as ExchangeRateResponse?;
                                          if (exchangeResponse1 != null) {
                                            controller.unitRateCA1.text =
                                                exchangeResponse1.exchangeRate
                                                    .toString();
                                            controller.amountINRCA1.text =
                                                exchangeResponse1.totalAmount
                                                    .toStringAsFixed(2);
                                            controller.isVisible.value = true;
                                          }

                                          // ✅ Step 2: Use requested percentage (user-entered or prefilled)
                                          final requestedPercentageText =
                                              controller
                                                  .requestedPercentage
                                                  .text
                                                  .trim();
                                          final double requestedPercentage =
                                              double.tryParse(
                                                requestedPercentageText
                                                    .replaceAll('%', '')
                                                    .trim(),
                                              ) ??
                                              0.0;

                                          if (requestedPercentage > 0 &&
                                              paidAmounts > 0) {
                                            // Calculate requested amount in original currency
                                            final double
                                            calculatedRequestedAmount =
                                                (paidAmounts *
                                                    requestedPercentage) /
                                                100;

                                            controller
                                                    .totalRequestedAmount
                                                    .text =
                                                calculatedRequestedAmount
                                                    .toStringAsFixed(2);
                                            controller
                                                    .calculatedPercentage
                                                    .value =
                                                calculatedRequestedAmount;
                                          } else {
                                            controller
                                                    .totalRequestedAmount
                                                    .text =
                                                '0.00';
                                          }

                                          // ✅ Step 3: Convert total requested amount to INR (CA2)
                                          final reqPaidAmount = controller
                                              .totalRequestedAmount
                                              .text
                                              .trim();
                                          final reqCurrency = controller
                                              .currencyDropDowncontrollerCA2
                                              .text;

                                          if (reqCurrency.isNotEmpty &&
                                              reqPaidAmount.isNotEmpty) {
                                            final exchangeResponse =
                                                await controller
                                                    .fetchExchangeRateCA(
                                                      reqCurrency,
                                                      reqPaidAmount,
                                                    );

                                            if (exchangeResponse != null) {
                                              controller.unitRateCA2.text =
                                                  exchangeResponse.exchangeRate
                                                      .toString();
                                              controller.amountINRCA2.text =
                                                  exchangeResponse.totalAmount
                                                      .toStringAsFixed(2);
                                            }
                                          }
                                        }
                                      },
                                    );
                                  },

                                  onEditingComplete: () {
                                    String text = controller.paidAmountCA1.text;
                                    double? value = double.tryParse(text);
                                    if (value != null) {
                                      controller.paidAmountCA1.text = value
                                          .toStringAsFixed(2);
                                    }
                                  },
                                ),
                              ),

                              /// Currency Dropdown
                              Obx(
                                () => SizedBox(
                                  width: 90,
                                  child:
                                      SearchableMultiColumnDropdownField<
                                        Currency
                                      >(
                                        // enabled: !showItemizeDetails,
                                        labelText: AppLocalizations.of(
                                          context,
                                        )!.currency,
                                        alignLeft: -210,
                                        dropdownWidth: 200,
                                        columnHeaders: [
                                          AppLocalizations.of(context)!.code,
                                          AppLocalizations.of(context)!.name,
                                          AppLocalizations.of(context)!.symbol,
                                        ],
                                        controller: controller
                                            .currencyDropDowncontrollerCA3,
                                        items: controllerItems.currencies,
                                        selectedValue: controller
                                            .selectedCurrencyCA1
                                            .value,
                                        backgroundColor: Colors.white,
                                        searchValue: (c) =>
                                            '${c.code} ${c.name} ${c.symbol}',
                                        displayText: (c) => c.code,
                                        inputDecoration: const InputDecoration(
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                          ),
                                          filled: true,

                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        validator: (c) => c == null
                                            ? AppLocalizations.of(
                                                context,
                                              )!.pleaseSelectCurrency
                                            : null,
                                        onChanged: (c) async {
                                          controller.selectedCurrencyCA1.value =
                                              c;
                                          controller
                                                  .currencyDropDowncontrollerCA3
                                                  .text =
                                              c?.code ?? '';

                                          final paidAmount = controller
                                              .paidAmountCA1
                                              .text
                                              .trim();
                                          if (paidAmount.isNotEmpty) {
                                            final exchangeResponse =
                                                await controller
                                                    .fetchExchangeRateCA(
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
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 14,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    c.code,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    c.name,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    c.symbol,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
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
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.rate,
                                    isDense: true,

                                    // contentPadding:
                                    //     EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!showItemizeDetails &&_showRequestedAmountError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                AppLocalizations.of(context)!.fieldRequired,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          // Amount in INR
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: controller.amountINRCA1,
                            enabled: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: AppLocalizations.of(
                                context,
                              )!.totalEstimatedAmountInInr,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // After your requested amount card section, add:
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.totalRequestedAmount,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              // Paid Amount Text Field
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller.totalRequestedAmount,
                                  enabled: false,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ), // Allows numbers with up to 2 decimal places
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.totalRequestedAmount,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onChanged: (_) async {
                                    final paidAmount = controller
                                        .totalRequestedAmount
                                        .text
                                        .trim();
                                    final currency = controller
                                        .currencyDropDowncontrollerCA2
                                        .text;

                                    if (currency.isNotEmpty &&
                                        paidAmount.isNotEmpty) {
                                      final exchangeResponse = await controller
                                          .fetchExchangeRateCA(
                                            currency,
                                            paidAmount,
                                          );

                                      if (exchangeResponse != null) {
                                        controller.unitRateCA2.text =
                                            exchangeResponse.exchangeRate
                                                .toString();
                                        controller.amountINRCA2.text =
                                            exchangeResponse.totalAmount
                                                .toStringAsFixed(2);
                                        controller.isVisible.value = true;
                                      }
                                    }
                                  },
                                  onEditingComplete: () {
                                    String text =
                                        controller.totalRequestedAmount.text;
                                    double? value = double.tryParse(text);
                                    if (value != null) {
                                      controller.totalRequestedAmount.text =
                                          value.toStringAsFixed(2);
                                    }
                                  },
                                ),
                              ),

                              // Currency Dropdown
                              Obx(
                                () => SizedBox(
                                  width: 90,
                                  child:
                                      SearchableMultiColumnDropdownField<
                                        Currency
                                      >(
                                        labelText: AppLocalizations.of(
                                          context,
                                        )!.currency,
                                        alignLeft: -210,
                                        dropdownWidth: 200,
                                        columnHeaders: [
                                          AppLocalizations.of(context)!.code,
                                          AppLocalizations.of(context)!.name,
                                          AppLocalizations.of(context)!.symbol,
                                        ],

                                        controller: controller
                                            .currencyDropDowncontrollerCA2,
                                        items: controllerItems.currencies,
                                        selectedValue: controller
                                            .selectedCurrencyCA2
                                            .value,
                                        backgroundColor: Colors.white,
                                        searchValue: (c) =>
                                            '${c.code} ${c.name} ${c.symbol}',
                                        displayText: (c) => c.code,
                                        inputDecoration: const InputDecoration(
                                          isDense: true,
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                        ),

                                        validator: (c) => c == null
                                            ? AppLocalizations.of(
                                                context,
                                              )!.pleaseSelectCurrency
                                            : null,
                                        onChanged: (c) async {
                                          controller.selectedCurrencyCA2.value =
                                              c;
                                          controller
                                                  .currencyDropDowncontrollerCA2
                                                  .text =
                                              c?.code ?? '';

                                          final paidAmount = controller
                                              .totalRequestedAmount
                                              .text
                                              .trim();
                                          if (paidAmount.isNotEmpty) {
                                            final exchangeResponse =
                                                await controller
                                                    .fetchExchangeRateCA(
                                                      c!.code,
                                                      paidAmount,
                                                    );

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
                                              vertical: 10,
                                              horizontal: 14,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    c.code,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    c.name,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    c.symbol,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
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
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.rate,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
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
                              labelText:
                                  '${AppLocalizations.of(context)!.totalRequestedAmount} (${controller.currencyDropDowncontrollerCA2.text})',
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.comments,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: const BorderSide(width: 2),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_itemizeCount > 1)
                        OutlinedButton.icon(
                          onPressed: () =>
                              _removeItemize(_selectedItemizeIndex),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.gradientEnd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 233, 8, 8),
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.remove,
                            style: const TextStyle(
                              color: AppColors.gradientEnd,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      FutureBuilder<Map<String, bool>>(
                        future: controller.getAllFeatureStates(),
                        builder: (context, snapshot) {
                          final theme = Theme.of(context);
                          final loc = AppLocalizations.of(context)!;

                          // While waiting for API → show nothing (or a small placeholder if needed)
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }

                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final featureStates = snapshot.data!;
                          final isEnabled =
                              featureStates['EnableItemization'] ?? false;

                          // ❌ Hide button completely if feature disabled
                          if (!isEnabled) return const SizedBox.shrink();

                          // ✅ Show button only when feature is enabled
                          return OutlinedButton.icon(
                            onPressed: () {
  // Reset error states
  setState(() {
    controller.showQuantityError.value = false;
    controller.showUnitAmountError.value = false;
    _showUnitError = false;
    _showTaxAmountError = false;
    _showRequestedAmountError = false;
    _showPaidAmountError = false;
    _showPercentageError = false;
    controller.showPaidForError.value = false;
    controller.showProjectError.value = false;
  });

  bool isValid = true;

  // 1. Validate Project Id if mandatory
  final projectIdMandatory = isFieldMandatory('Project Id');
  if (projectIdMandatory && controller.selectedProject == null) {
    setState(() => controller.showProjectError.value = true);
    isValid = false;
  }

  // 2. Validate Category
  if (controller.selectedCategoryId.isEmpty) {
    setState(() => controller.showPaidForError.value = true);
    isValid = false;
  }

  // 3. Validate Paid Amount (CA1)
  final paidAmountText = controller.paidAmountCA1.text.trim();
  final paidAmount = double.tryParse(paidAmountText) ?? 0.0;
  if (paidAmountText.isEmpty || paidAmount <= 0) {
    setState(() => _showPaidAmountError = true);
    isValid = false;
  }

  // 4. Validate Requested Amount (CA2)
  final requestedAmountText = controller.totalRequestedAmount.text.trim();
  final requestedAmount = double.tryParse(requestedAmountText) ?? 0.0;
  if (requestedAmountText.isEmpty || requestedAmount <= 0) {
    setState(() => _showRequestedAmountError = true);
    isValid = false;
  }

  // 5. Validate Percentage
  final percentageText = controller.requestedPercentage.text.trim();
  final percentage = double.tryParse(percentageText.replaceAll('%', '')) ?? 0.0;
  if (percentageText.isEmpty || percentage <= 0 || percentage > 100) {
    setState(() => _showPercentageError = true);
    isValid = false;
  }

  // 6. Validate itemized fields only if itemization is active
  if (_itemizeCount > 1) {
    if (controller.quantity.text.isEmpty) {
      setState(() => controller.showQuantityError.value = true);
      isValid = false;
    }

    if (controller.unitAmount.text.isEmpty) {
      setState(() => controller.showUnitAmountError.value = true);
      isValid = false;
    }

    if (controller.selectedunit == null) {
      setState(() => _showUnitError = true);
      isValid = false;
    }
  }

  print('✅ Validation Result: $isValid');
  print('📊 Itemize Count: $_itemizeCount');

  if (isValid) {
    try {
      final items = itemizeControllers
          .map((c) => c.toCashAdvanceRequestItemize())
          .toList();

      // Debug: Print each item
      for (var i = 0; i < items.length; i++) {
        print("📝 Item $i: ${jsonEncode(items[i].toJson())}");
      }

      controllerItems.finalItemsCashAdvanceNew = items;
      _addItemize();
    } catch (e) {
      print('❌ Error converting to CashAdvanceRequestItemize: $e');
    }
  }
},
                            // onPressed: _addItemize,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: theme.colorScheme.onPrimary,
                              side: BorderSide(
                                color: theme.colorScheme.onPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(loc.itemize),
                          );
                        },
                      ),
                    ],
                  ),
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
                            icon: const Icon(Icons.arrow_back),
                            label: Text(AppLocalizations.of(context)!.back),
                          )
                        else
                          const SizedBox(),
                        const Spacer(),
                        ElevatedButton(
                        onPressed: () {
  // Reset error states
  setState(() {
    controller.showQuantityError.value = false;
    controller.showUnitAmountError.value = false;
    _showUnitError = false;
    _showTaxAmountError = false;
    _showRequestedAmountError = false;
    _showPaidAmountError = false;
    _showPercentageError = false;
    controller.showPaidForError.value = false;
    controller.showProjectError.value = false;
  });

  bool isValid = true;

  // 1. Validate Project Id if mandatory
  final projectIdMandatory = isFieldMandatory('Project Id');
  if (projectIdMandatory && controller.selectedProject == null) {
    setState(() => controller.showProjectError.value = true);
    isValid = false;
  }

  // 2. Validate Category
  if (controller.selectedCategoryId.isEmpty) {
    setState(() => controller.showPaidForError.value = true);
    isValid = false;
  }

  // 3. Validate Paid Amount (CA1)
  final paidAmountText = controller.paidAmountCA1.text.trim();
  final paidAmount = double.tryParse(paidAmountText) ?? 0.0;
  if (paidAmountText.isEmpty || paidAmount <= 0) {
    setState(() => _showPaidAmountError = true);
    isValid = false;
  }

  // 4. Validate Requested Amount (CA2)
  final requestedAmountText = controller.totalRequestedAmount.text.trim();
  final requestedAmount = double.tryParse(requestedAmountText) ?? 0.0;
  if (requestedAmountText.isEmpty || requestedAmount <= 0) {
    setState(() => _showRequestedAmountError = true);
    isValid = false;
  }

  // 5. Validate Percentage
  final percentageText = controller.requestedPercentage.text.trim();
  final percentage = double.tryParse(percentageText.replaceAll('%', '')) ?? 0.0;
  if (percentageText.isEmpty || percentage <= 0 || percentage > 100) {
    setState(() => _showPercentageError = true);
    isValid = false;
  }

  // 6. Validate itemized fields only if itemization is active
  if (_itemizeCount > 1) {
    if (controller.quantity.text.isEmpty) {
      setState(() => controller.showQuantityError.value = true);
      isValid = false;
    }

    if (controller.unitAmount.text.isEmpty) {
      setState(() => controller.showUnitAmountError.value = true);
      isValid = false;
    }

    if (controller.selectedunit == null) {
      setState(() => _showUnitError = true);
      isValid = false;
    }
  }

  print('✅ Validation Result: $isValid');
  print('📊 Itemize Count: $_itemizeCount');

  if (isValid) {
    try {
      final items = itemizeControllers
          .map((c) => c.toCashAdvanceRequestItemize())
          .toList();

      // Debug: Print each item
      for (var i = 0; i < items.length; i++) {
        print("📝 Item $i: ${jsonEncode(items[i].toJson())}");
      }

      controllerItems.finalItemsCashAdvanceNew = items;
      _nextStep();
    } catch (e) {
      print('❌ Error converting to CashAdvanceRequestItemize: $e');
    }
  }
},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.gradientEnd,
                            side: const BorderSide(
                              color: AppColors.gradientEnd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _currentStep == 2
                                ? AppLocalizations.of(context)!.finish
                                : AppLocalizations.of(context)!.next,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
    Controller controller,
  ) {
    final isSelected = controller.selectedCategoryId == item.categoryId;

    // Shared fallback image
    const String fallbackUrl =
        "https://icons.veryicon.com/png/o/commerce-shopping/icon-of-lvshan-valley-mobile-terminal/home-category.png";

    Widget _buildIcon(String? icon) {
      try {
        if (icon != null && icon.isNotEmpty) {
          if (icon.startsWith('data:image')) {
            // Data URI: extract base64 part safely
            final parts = icon.split(',');
            if (parts.length > 1) {
              final base64Str = parts.last;
              final bytes = base64Decode(base64Str);
              return Image.memory(
                bytes,
                width: 30,
                height: 30,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 30),
              );
            }
          } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(icon)) {
            // Plain base64 (no prefix)
            final bytes = base64Decode(icon);
            return Image.memory(
              bytes,
              width: 30,
              height: 30,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else if (icon.startsWith('http') || icon.startsWith('https')) {
            // URL image
            return Image.network(
              icon,
              width: 30,
              height: 30,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else {
            // Local asset image
            return Image.asset(
              icon,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Icon decode failed: $e');
      }

      // Fallback image
      return Image.network(
        fallbackUrl,
        width: 30,
        height: 30,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 30),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
        controller.showPaidForError.value = false;
        controller.selectedCategoryId = item.categoryId;
        controller.fetchMaxAllowedPercentage();

        if (_debounce?.isActive ?? false) _debounce!.cancel();

        _debounce = Timer(const Duration(milliseconds: 400), () async {
          final paidAmountText = controller.paidAmountCA1.text.trim();
          controller.unitAmount.text = controller.paidAmountCA1.text;
          final double paidAmounts = double.tryParse(paidAmountText) ?? 0.0;
          final currency = controller.currencyDropDowncontrollerCA3.text;

          final results = await Future.wait([
            controller.fetchExchangeRateCA(currency, paidAmountText),
            controller.fetchMaxAllowedPercentage(),
          ]);

          final exchangeResponse1 = results[0] as ExchangeRateResponse?;
          if (exchangeResponse1 != null) {
            controller.unitRateCA1.text = exchangeResponse1.exchangeRate
                .toString();
            controller.amountINRCA1.text = exchangeResponse1.totalAmount
                .toStringAsFixed(2);
            controller.isVisible.value = true;
          }

          final maxPercentage = results[1] as double?;
          if (maxPercentage != null && maxPercentage > 0) {
            final double calculatedPercentage =
                (paidAmounts * maxPercentage) / 100;
            controller.totalRequestedAmount.text = calculatedPercentage
                .toString();
            controller.calculatedPercentage.value = calculatedPercentage;
            controller.requestedPercentage.text = maxPercentage
                .toInt()
                .toString();
          }

          final reqPaidAmount = controller.totalRequestedAmount.text.trim();
          final reqCurrency = controller.currencyDropDowncontrollerCA2.text;

          if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
            final exchangeResponse = await controller.fetchExchangeRateCA(
              reqCurrency,
              reqPaidAmount,
            );

            if (exchangeResponse != null) {
              controller.unitRateCA2.text = exchangeResponse.exchangeRate
                  .toString();
              controller.amountINRCA2.text = exchangeResponse.totalAmount
                  .toStringAsFixed(2);
            }
          }
        });

        print("Tapped Category Name: ${item.categoryName}");
        print("Tapped Category ID: ${controller.selectedCategoryId}");
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(
                  width: 3,
                  color: const Color.fromARGB(255, 150, 13, 3),
                )
              : null,
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'),
            ), // Allows numbers with up to 2 decimal places
          ],
          decoration: InputDecoration(
            labelText: label,
            filled: !enabled ? true : false,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            // enabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: const BorderSide(width: 2),
            //   borderRadius: BorderRadius.circular(10),
            // ),
          ),
        ),
      ],
    );
  }

  Widget expenseCreationFormStep1(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return controller.isLoadingGE2.value
            ? const SkeletonLoaderPage()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  // key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              // Obx(() {
                              //   return showField.value
                              //       ? _buildTextField(
                              //           label:
                              //               "${AppLocalizations.of(context)!.cashAdvanceRequisitionId} *",
                              //           controller:
                              //               controller.expenseIdController,
                              //           isReadOnly: true,
                              //           showError: _showExpenseIdError,
                              //           onChanged: (value) {
                              //             if (value.isNotEmpty &&
                              //                 _showExpenseIdError) {
                              //               setState(
                              //                 () => _showExpenseIdError = false,
                              //               );
                              //             }
                              //           },
                              //         )
                              //       : const SizedBox.shrink(); // hides the field
                              // }),
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
                                                controller.selectedDate!,
                                              ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                      ),
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
                              .where(
                                (field) =>
                                    field['IsEnabled'] == true &&
                                    field['FieldName'] == 'Refrence Id',
                              )
                              .map((field) {
                                final String label = field['FieldName'];
                                final bool isMandatory =
                                    field['IsMandatory'] ?? false;
                                isThereReferenceID =
                                    field['IsMandatory'] ?? false;
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
                                              controller:
                                                  controller.referenceID,
                                              onChanged: (value) {
                                                field.didChange(value);
                                                selectReferenceIDError = null;
                                              },
                                              decoration: InputDecoration(
                                                labelText:
                                                    '${AppLocalizations.of(context)!.referenceId}${isMandatory ? " *" : ""}',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                errorText: field.errorText,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if (selectReferenceIDError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          selectReferenceIDError.toString(),
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              })
                              .toList(),
                        );
                      }),
                      // Paid To Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          SearchableMultiColumnDropdownField<
                            Businessjustification
                          >(
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
                                controller.justificationController.text =
                                    p!.merchantId;
                                paidToError = null;
                              });
                            },
                            controller: controller.justificationController,
                            rowBuilder: (p, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.merchantId,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        p.name,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          if (paidToError != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                bottom: 8,
                              ),
                              child: Text(
                                paidToError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        'Paid With',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Paid With Radio Buttons
                      Obx(() {
                        // if (controller.paidWith == null &&
                        //     controller.paymentMethods.isNotEmpty) {
                        //   controller.paidWith =
                        //       controller.paymentMethods.first.paymentMethodId;
                        //   controller.paymentMethodeID =
                        //       controller.paymentMethods.first.paymentMethodId;
                        // }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Payment methods list
                            ...List.generate(controller.paymentMethods.length, (
                              index,
                            ) {
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
                                      Icon(
                                        icons[index % icons.length],
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          method.paymentMethodName,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: method.paymentMethodId,
                                  groupValue:
                                      controller.paidWithCashAdvance.value,
                                  onChanged: (String? value) {
                                    // print(value);
                                    // loadAndAppendCashAdvanceList();
                                    setState(() {
                                      if (controller
                                              .paidWithCashAdvance
                                              .value ==
                                          value) {
                                        // Unselect if same item clicked
                                        controller.paidWithCashAdvance.value =
                                            null;
                                        controller
                                                .paymentMethodeIDCashAdvance
                                                .value =
                                            null;
                                      } else {
                                        controller.paidWithCashAdvance.value =
                                            value;
                                        controller
                                                .paymentMethodeIDCashAdvance
                                                .value =
                                            value;
                                      }
                                    });
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
                            // Small red button to clear selection
                            if (controller.paidWithCashAdvance.value != null &&
                                controller
                                    .paidWithCashAdvance
                                    .value!
                                    .isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.paidWithCashAdvance.value = "";
                                    controller
                                            .paymentMethodeIDCashAdvance
                                            .value =
                                        "";
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size(
                                      60,
                                      30,
                                    ), // Small size
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.clear,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
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
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
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
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                label: Text(AppLocalizations.of(context)!.back),
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
                                  color: AppColors.gradientEnd,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentStep == 2
                                    ? AppLocalizations.of(context)!.finish
                                    : AppLocalizations.of(context)!.next,
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

Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  required bool isReadOnly,
  bool showError = false,
  String? errorMessage,
  void Function(String)? onChanged,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        enabled: isReadOnly,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          errorText: showError
              ? errorMessage ?? 'This field is required'
              : null,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}

class CreateExpensePage extends StatefulWidget {
  final bool allowDocAttachments;
  final VoidCallback backButton;
  const CreateExpensePage({
    super.key,
    required this.allowDocAttachments,
    required this.backButton,
  });

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
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // optional
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: false),
      ],
    );

    if (croppedFile != null) {
      final croppedImage = File(croppedFile.path);
      return croppedImage;
      // ignore: use_build_context_synchronously
      // await controller.sendUploadedFileToServer(context, croppedImage);
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
      barrierColor: Colors.black.withOpacity(
        0.9,
      ), // darker transparent background
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // remove white box background
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Full image view
              PhotoView.customChild(
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 9.0,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Image.file(file, fit: BoxFit.contain),
              ),

              // Close button (top-left)
              Positioned(
                top: 30,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                   onPressed: () {
                            // controller.closeField();
                            Navigator.pop(context);
                          },
                ),
              ),

              // Floating edit & delete buttons (top-right)
              Positioned(
                top: 80,
                right: 20,
                child: Column(
                  children: [
                    if (controller.isEnable.value)
                      FloatingActionButton.small(
                        heroTag: "edit_$index",
                        onPressed: () async {
                          final croppedFile = await _cropImage(file);
                          if (croppedFile != null) {
                            setState(() {
                              controller.imageFiles[index] = croppedFile;
                            });
                            Navigator.pop(context);
                            _showFullImage(croppedFile, index);
                          }
                        },
                        backgroundColor: Colors.deepPurple,
                        child: const Icon(Icons.edit),
                      ),
                    const SizedBox(height: 12),
                    if (controller.isEnable.value)
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
    final loc = AppLocalizations.of(context)!;

    final PageController _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );
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
          onTap: () => {
            if (controller.imageFiles.isEmpty)
              {_pickImage(ImageSource.gallery)},
          },
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            height:
                MediaQuery.of(context).size.height *
                0.3, // 30% of screen height
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // border color
                width: 2, // border thickness
              ),
              borderRadius: BorderRadius.circular(
                12,
              ), // optional rounded corners
            ),
            child: Obx(() {
              if (controller.imageFiles.isEmpty) {
                return Center(child: Text(loc.tapToUploadDocs));
              } else {
                return Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: controller.imageFiles.length,
                      onPageChanged: (index) {
                        controller.currentIndex.value = index;
                      },
                      itemBuilder: (_, index) {
                        final file = controller.imageFiles[index];
                        return GestureDetector(
                          onTap: () => _showFullImage(file, index),
                          child: Container(
                            alignment: Alignment.center,
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
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${controller.currentIndex.value + 1}/${controller.imageFiles.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: 40,
                    //   right: 20,
                    //   child: IconButton(
                    //     icon: const Icon(Icons.close,
                    //         color: Colors.white),
                    //     onPressed: () =>
                    //         Navigator.pop(context),
                    //   ),
                    // ),
                    // Positioned(
                    //   bottom: 16,
                    //   right: 16,
                    //   child: GestureDetector(
                    //     onTap: () => _pickImage(ImageSource.gallery),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.deepPurple,
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: Colors.white, width: 2),
                    //       ),
                    //       padding: const EdgeInsets.all(8),
                    //       child: const Icon(
                    //         Icons.add,
                    //         color: Colors.white,
                    //         size: 28,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
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
              if (widget.allowDocAttachments) _buildImageArea(),
              if (widget.allowDocAttachments) const SizedBox(height: 20),
              if (widget.allowDocAttachments)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(AppLocalizations.of(context)!.upload),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.capture),
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       AppLocalizations.of(context)!.policyViolations,
                  //       style: const TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //     Text(
                  //       AppLocalizations.of(context)!.checkPolicies,
                  //       style: const TextStyle(color: Colors.blue),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 12),

                  // // Policy Card
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         AppLocalizations.of(context)!.policy1001,
                  //         style: const TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Row(
                  //         children: [
                  //           const Icon(Icons.check, color: Colors.green),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               AppLocalizations.of(
                  //                 context,
                  //               )!.expenseAmountUnderLimit,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 6),
                  //       Row(
                  //         children: [
                  //           const Icon(Icons.check, color: Colors.green),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               AppLocalizations.of(
                  //                 context,
                  //               )!.receiptRequiredAmount,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 6),
                  //       Row(
                  //         children: [
                  //           const Icon(Icons.close, color: Colors.red),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               AppLocalizations.of(
                  //                 context,
                  //               )!.descriptionMandatory,
                  //               style: const TextStyle(color: Colors.red),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 6),
                  //       Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.error_outline,
                  //             color: Colors.orange,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               AppLocalizations.of(context)!.expiredPolicy,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),

                  // Buttons
                  Center(
                    child: Column(
                      children: [
                        Obx(() {
                          return GradientButton(
                            text: AppLocalizations.of(context)!.submit,
                            isLoading: controller.isGESubmitBTNLoading.value,
                            onPressed: () {
                              controller.saveCashAdvance(
                                context,
                                true,
                                false,
                                null,
                                null,
                              );
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
                                        controller.saveCashAdvance(
                                          context,
                                          false,
                                          false,
                                          null,
                                          null,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(130, 50),
                                  backgroundColor: const Color.fromARGB(
                                    241,
                                    20,
                                    94,
                                    2,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
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
                                    : Text(AppLocalizations.of(context)!.save),
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: const TextStyle(
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: widget.backButton,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppLocalizations.of(context)!.back),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
