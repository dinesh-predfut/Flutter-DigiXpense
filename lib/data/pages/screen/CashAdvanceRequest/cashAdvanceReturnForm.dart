import 'dart:async';

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/loaderbutton.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/utils.dart' show toStartOfDayUtc;
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/main.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
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
import 'package:shared_preferences/shared_preferences.dart';
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
  final Controller controller = Get.find();
  final controllerItems = Get.find<Controller>();
  final Controller controllerFitch = Get.find();
  final _formKey = GlobalKey<FormState>();
  List<Controller> itemizeControllers = [];
  late FocusNode paidAmountFocusNode;
  bool allowDocAttachments = false;
  int _currentStep = 0;
  RxBool showField = true.obs;
  int _itemizeCount = 1;
  bool _isCalling = false;
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
  String? cashAdvanceError;
  String? employeeError;
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

    print('controller.selectedDate ${controller.selectedDate}');
    paidAmountFocusNode = FocusNode();
    paidAmountFocusNode.addListener(() async {
      if (!paidAmountFocusNode.hasFocus) {
        if (controllerItems.paidAmountCA1.text.trim().isNotEmpty) {
          await calculateAndFetchExchangeSafe();
        }
      }
    });
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

    // controller.fetchPaidto();

    controller.isManualEntryMerchant = false;
    _loadSettings();

    // itemizeControllers.add(Controller());
    final newController = Controller();
    if (controller.customFields.isNotEmpty) {
      newController.cloneCustomFieldsFromRx(controller.customFields);
    }
    itemizeControllers.add(newController);
    //  controller.loadSequenceModules();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.isLoadingCAForm.value = true;

      controller.fetchEmployeesID();
      loadSequenceAndUpdateUI();

      controller.configuration();
      controller.fetchPaidto();

      await _initializeUnits();
      await controller.fetchMaxAllowedPercentage();

      controller.fetchCashAdvanceRequests();
      controller.getconfigureFieldCashAdvance();

      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.loadSequenceModules();
      controller.currencyDropDown();
      await controller.getUserPref(context);
      await controller.fetchExpenseCategory();
      // await loadTimezoneValue();

      final now = DateTime.now();

      /// Convert using timezone method
      final fromMs = toStartOfDayUtc(now);
      controller.selectedDate ??= DateTime.fromMillisecondsSinceEpoch(fromMs);
      // print('checktimeXoje${controller.selectedDate}');
      controller.fetchBusinessjustification();
      controller.fetchLocation();
      controller.isLoadingCAForm.value = false;
    });
  }

  Future<void> loadTimezoneValue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timezoneValue = prefs.getString('defaultTimeZone');

    controller.selectedTimezonevalue.value = timezoneValue!;
    print(
      "controller.selectedTimezonevalue.value${controller.selectedTimezonevalue.value}",
    );
  }

  final FocusNode percentageFocusNode = FocusNode();
  Future<void> calculateAndFetchExchangeSafe() async {
    if (_isCalling) return;

    _isCalling = true;
    // await calculateAndFetchExchange();
    _isCalling = false;
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

  Future<void> calculatePercentage(
    String value,
    Controller controller,
    int index,
  ) async {
    final percentage = double.tryParse(value) ?? 0.0;

    final maxPercentage =
        double.tryParse(controller.allowedPercentage.text) ?? 0.0;

    setState(() {
      _showPercentageError = percentage > maxPercentage || percentage <= 0;
    });

    if (_showPercentageError) return;

    final paidAmount = double.tryParse(controller.amountINRCA1.text) ?? 0.0;

    if (paidAmount > 0 && percentage > 0) {
      /// ✅ STEP 1: Calculate requested amount
      final requestedAmount = (paidAmount * percentage) / 100;

      controller.totalRequestedAmount.text = requestedAmount.toStringAsFixed(2);

      /// ✅ STEP 2: Get exchange rate only
      final reqCurrency = controller.currencyDropDowncontrollerCA2.text.trim();

      if (reqCurrency.isNotEmpty) {
        final exchangeRate = await controller.fetchExchangeRatecalculatedCA2(
          reqCurrency,
        );

        if (exchangeRate != null) {
          /// ✅ Store rate
          controller.unitRateCA2.text = exchangeRate.toString();

          /// ✅ STEP 3: Manual conversion (IMPORTANT CHANGE)
          controller.amountINRCA2.text = (requestedAmount * exchangeRate)
              .toStringAsFixed(2);
        }
      }
    } else {
      controller.totalRequestedAmount.text = '0.00';
      controller.amountINRCA2.text = '0.00';
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

  bool isFieldMandatoryAdvance(String fieldName) {
    return controller.configListAdvance.any(
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
        paidToError = AppLocalizations.of(context)!.fieldRequired;
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
    final hideCashAdvanceField = controller.hasModule("CashAdvance");

    if (!hideCashAdvanceField) {
      if (controller.cashAdvanceRequisitionID.text.trim().isEmpty) {
        setState(() {
          cashAdvanceError = AppLocalizations.of(context)!.fieldRequired;
        });
        isValid = false;
      } else {
        setState(() {
          cashAdvanceError = null;
        });
      }
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
        selectReferenceIDError = AppLocalizations.of(context)!.fieldRequired;
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
        controller.selectedProject = null;
        for (var c in itemizeControllers) {
          c.expenseCategory.value = [];
          c.categoryController.clear();
          c.projectDropDowncontroller.clear();
        }
      });

      controller.fetchCashAdvanceExpenseCategory();
      controller.fetchProjectName();
      controller.selectedDate = picked;
    }
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
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
          // ✅ Create new controller - DO NOT clone from current
          final newController = Controller();

          // ✅ ONLY clone cashadvancetrans fields from master (these are transaction-level fields)
          final transFields = controllerItems.customFields
              .where((f) => f['ObjectName'] == 'cashadvancetrans')
              .map((f) => Map<String, dynamic>.from(f))
              .toList();
          if (transFields.isNotEmpty) {
            newController.customFieldsItems.addAll(transFields);
          }

          // ✅ CRITICAL: Remove any ExpenseCategories that might have been added
          newController.customFieldsItems.removeWhere(
            (f) => f['ObjectName'] == 'ExpenseCategories',
          );

          // ✅ Reset all category-related state to EMPTY
          newController.selectedCategoryId = '';
          newController.showPaidForError.value = false;

          // ✅ Reset all amount fields to empty
          newController.paidAmountCA1.text = '';
          newController.totalRequestedAmount.text = '';
          newController.amountINRCA1.text = '';
          newController.amountINRCA2.text = '';
          newController.unitAmount.text = '';
          newController.quantity.text = '1.00';

          // ✅ Reset percentage to default (100)
          newController.requestedPercentage.text = '100';

          // ✅ Reset currency selections to master defaults
          newController.currencyDropDowncontrollerCA3.text =
              controllerItems.currencyDropDowncontroller.text;
          newController.currencyDropDowncontrollerCA2.text =
              controllerItems.currencyDropDowncontroller2.text;
          newController.selectedCurrencyCA1.value =
              controllerItems.selectedCurrencyCA1.value;
          newController.selectedCurrencyCA2.value =
              controllerItems.selectedCurrencyCA2.value;

          // ✅ Reset unit selection
          newController.selectedunit = controllerItems.selectedunit;

          // ✅ Reset project and location
          newController.selectedProject = null;
          newController.selectedLocation = null;

          // ✅ Add new controller
          itemizeControllers.add(newController);
          _itemizeCount++;
          _selectedItemizeIndex = _itemizeCount - 1;
          showItemizeDetails = true;

          // Force refresh
          newController.customFieldsItems.refresh();
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
    // ─────────────────────────────────────────────
    // VALIDATION HELPER — single source of truth
    // ─────────────────────────────────────────────
    String? _validateCustomFieldValue(
      Map<String, dynamic> field,
      dynamic value,
    ) {
      final String fieldType = field['FieldType'] ?? '';
      final String label = field['FieldLabel'] ?? field['FieldName'];

      if (value == null) return null;

      switch (fieldType) {
        case 'Percentage':
          double percentage;
          if (value is num) {
            percentage = value.toDouble();
          } else if (value is String) {
            percentage = double.tryParse(value) ?? -1;
          } else {
            return null;
          }

          if (percentage < 0 || percentage > 100) {
            return '$label must be between 0 and 100';
          }
          break;

        case 'Email':
          final email = value.toString();
          final emailRegex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          );
          if (!emailRegex.hasMatch(email)) {
            return 'Enter a valid email address for $label';
          }
          break;

        case 'MobileNumber':
          final phone = value.toString();
          final phoneRegex = RegExp(r'^[\+]?[0-9]{1,4}[\s\-]?[0-9]{6,12}$');
          if (!phoneRegex.hasMatch(phone.trim())) {
            return 'Enter a valid mobile number for $label';
          }
          break;

        case 'URL':
          final url = value.toString();
          final urlRegex = RegExp(
            r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
            caseSensitive: false,
          );
          if (!urlRegex.hasMatch(url)) {
            return 'Enter a valid URL for $label';
          }
          break;

        case 'Decimal':
        case 'Amount':
          double amount;
          if (value is num) {
            amount = value.toDouble();
          } else if (value is String) {
            amount = double.tryParse(value) ?? -1;
          } else {
            return null;
          }

          if (amount < 0) {
            return '$label cannot be negative';
          }
          break;

        case 'LongInteger':
          int intValue;
          if (value is int) {
            intValue = value;
          } else if (value is String) {
            intValue = int.tryParse(value) ?? -1;
          } else {
            return null;
          }

          if (intValue < 0) {
            return '$label cannot be negative';
          }
          break;
      }

      return null;
    }

    // NEW: Custom fields validation method
    bool _validateCustomFields() {
  bool isValid = true;

  // Get all cash advance transaction fields
  final customFields = controller.customFieldsItems
      .where((field) => field['ObjectName'] == 'cashadvancetrans')
      .toList();

  for (var field in customFields) {
    final bool isMandatory = field['IsMandatory'] ?? false;
    final String fieldType = field['FieldType'] ?? '';
    final String label = field['FieldLabel'] ?? field['FieldName'];
    dynamic enteredValue = field['EnteredValue'];

    // Check if value is provided based on field type
    bool hasValue = false;

    switch (fieldType) {
      case 'Checkbox':
        hasValue = enteredValue == true;
        break;

      case 'List':
      case 'CustomList':
      case 'SystemList':
        hasValue = enteredValue != null && enteredValue.toString().isNotEmpty;
        if (!hasValue && field['SelectedValue'] != null) {
          hasValue = true;
        }
        break;

      case 'Date':
      case 'Date&Time':
        hasValue = enteredValue != null;
        break;

      case 'LongInteger':
      case 'Decimal':
      case 'Percentage':
      case 'Amount':
        if (enteredValue != null) {
          if (enteredValue is num) {
            hasValue = enteredValue > 0;
          } else if (enteredValue is String) {
            final parsed = double.tryParse(enteredValue);
            hasValue = parsed != null && parsed > 0;
          }
        }
        break;

      case 'Email':
      case 'MobileNumber':
      case 'URL':
      default:
        hasValue = enteredValue != null && enteredValue.toString().trim().isNotEmpty;
        break;
    }

    if (isMandatory && !hasValue) {
      field['Error'] = '$label is required';
      isValid = false;
      continue; // Skip further validation for this field if no value
    }

    // Additional validation based on field type (only if has value)
    if (hasValue) {
      switch (fieldType) {
        case 'Email':
          final email = enteredValue.toString();
          final emailRegex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          );
          if (!emailRegex.hasMatch(email)) {
            field['Error'] = 'Enter a valid email address for $label';
            isValid = false;
          } else {
            field['Error'] = null;
          }
          break;

        case 'MobileNumber':
          final phone = enteredValue.toString();
          final phoneRegex = RegExp(r'^[\+]?[0-9]{1,4}[\s\-]?[0-9]{6,12}$');
          if (!phoneRegex.hasMatch(phone.trim())) {
            field['Error'] = 'Enter a valid mobile number for $label';
            isValid = false;
          } else {
            field['Error'] = null;
          }
          break;

        case 'URL':
          final url = enteredValue.toString();
          final urlRegex = RegExp(
            r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
            caseSensitive: false,
          );
          if (!urlRegex.hasMatch(url)) {
            field['Error'] = 'Enter a valid URL for $label';
            isValid = false;
          } else {
            field['Error'] = null;
          }
          break;

        case 'Percentage':
          double percentage;
          if (enteredValue is num) {
            percentage = enteredValue.toDouble();
          } else if (enteredValue is String) {
            percentage = double.tryParse(enteredValue) ?? -1;
          } else {
            break;
          }
          if (percentage < 0 || percentage > 100) {
            field['Error'] = '$label must be between 0 and 100';
            isValid = false;
          } else {
            field['Error'] = null;
          }
          break;

        case 'Decimal':
        case 'Amount':
          double amount;
          if (enteredValue is num) {
            amount = enteredValue.toDouble();
          } else if (enteredValue is String) {
            amount = double.tryParse(enteredValue) ?? -1;
          } else {
            break;
          }
          if (amount < 0) {
            field['Error'] = '$label cannot be negative';
            isValid = false;
          } else {
            field['Error'] = null;
          }
          break;

        case 'LongInteger':
          int intValue;
          if (enteredValue is int) {
            intValue = enteredValue;
          } else if (enteredValue is String) {
            intValue = int.tryParse(enteredValue) ?? -1;
          } else {
            break;
          }
          if (intValue < 0) {
            field['Error'] = '$label cannot be negative';
            isValid = false;
          } else {
            field['Error'] = null;
          }
          break;

        default:
          field['Error'] = null;
          break;
      }
    }
  }

  // Refresh the UI to show errors
  controller.customFields.refresh();

  return isValid;
}
    // Helper method for field-specific validation

    bool _validateForm({required bool isItemizeButton}) {
      // ── Reset ALL error flags first ──
      setState(() {
        controller.showQuantityError.value = false;
        controller.showUnitAmountError.value = false;
        controller.showPaidForError.value = false;
        controller.showProjectError.value = false;
        _showUnitError = false;
        _showTaxAmountError = false;
        _showRequestedAmountError = false;
        _showPaidAmountError = false;
        _showPercentageError = false;
        _showLocationError = false;
      });

      bool isValid = true;

      // ── 1. Project Id (if mandatory) ──
      final projectIdMandatory = isFieldMandatoryAdvance('Project Id');
      if (projectIdMandatory && controller.selectedProject == null) {
        setState(() => controller.showProjectError.value = true);
        isValid = false;
      }

      // ── 2. Location (if mandatory) ──
      final locationMandatory = isFieldMandatoryAdvance('Location');
      if (locationMandatory && controller.selectedLocation == null) {
        setState(() => _showLocationError = true);
        isValid = false;
      }

      // ── 3. Total Estimated Amount INR (CA1) ──
      final amountCA1 =
          double.tryParse(controller.amountINRCA1.text.trim()) ?? 0.0;
      if (amountCA1 <= 0) {
        Fluttertoast.showToast(
          msg: "Total estimated amount must be greater than 0",
          backgroundColor: Colors.red,
        );
        isValid = false;
      }

      // ── 4. Total Requested Amount INR (CA2) ──
      final amountCA2 =
          double.tryParse(controller.amountINRCA2.text.trim()) ?? 0.0;
      if (amountCA2 <= 0) {
        Fluttertoast.showToast(
          msg: "Total requested amount must be greater than 0",
          backgroundColor: Colors.red,
        );
        isValid = false;
      }

      // ── 5. Paid Amount (CA1 raw) ──
      final paidAmountText = controller.paidAmountCA1.text.trim();
      final paidAmount = double.tryParse(paidAmountText) ?? 0.0;
      if (paidAmountText.isEmpty || paidAmount <= 0) {
        setState(() => _showPaidAmountError = true);
        isValid = false;
      }

      // ── 6. Total Requested Amount field ──
      final requestedAmountText = controller.totalRequestedAmount.text.trim();
      final requestedAmount = double.tryParse(requestedAmountText) ?? 0.0;
      if (requestedAmountText.isEmpty || requestedAmount <= 0) {
        setState(() => _showRequestedAmountError = true);
        isValid = false;
      }

      // ── 7. Requested Percentage ──
      final percentageText = controller.requestedPercentage.text.trim();
      final percentage =
          double.tryParse(percentageText.replaceAll('%', '').trim()) ?? 0.0;
      if (percentageText.isEmpty || percentage <= 0 || percentage > 100) {
        setState(() => _showPercentageError = true);
        isValid = false;
      }
      print('unitAmountText$_itemizeCount');

      // ── 8. Itemize-specific fields (only when itemizeCount > 1) ──
      if (showItemizeDetails) {
        if (controller.quantity.text.trim().isEmpty) {
          setState(() => controller.showQuantityError.value = true);
          isValid = false;
        }

        final unitAmountText = controller.unitAmount.text.trim();
        print('unitAmountText$unitAmountText');
        if (controller.unitAmount.text.trim().isEmpty ||
            (double.tryParse(unitAmountText) ?? 0.0) <= 0) {
          setState(() => controller.showUnitAmountError.value = true);
          isValid = false;
        }
      }

      // ── 9. Validate Custom Fields (NEW) ──
      final customFieldsValid = _validateCustomFields();
      if (!customFieldsValid) {
        isValid = false;
      }

      return isValid;
    }

    // ─────────────────────────────────────────────
    // VALIDATES ALL itemize pages
    // Returns index of first invalid one, or -1
    // ─────────────────────────────────────────────
    int _getFirstInvalidItemizeIndex() {
      for (int i = 0; i < itemizeControllers.length; i++) {
        final c = itemizeControllers[i];

        final paidAmount = double.tryParse(c.paidAmountCA1.text.trim()) ?? 0.0;
        if (paidAmount <= 0) return i;

        final requestedAmount =
            double.tryParse(c.totalRequestedAmount.text.trim()) ?? 0.0;
        if (requestedAmount <= 0) return i;

        final percentage =
            double.tryParse(
              c.requestedPercentage.text.replaceAll('%', '').trim(),
            ) ??
            0.0;
        if (percentage <= 0 || percentage > 100) return i;

        final amountINR1 = double.tryParse(c.amountINRCA1.text.trim()) ?? 0.0;
        if (amountINR1 <= 0) return i;

        final amountINR2 = double.tryParse(c.amountINRCA2.text.trim()) ?? 0.0;
        if (amountINR2 <= 0) return i;

        if (_itemizeCount > 1) {
          if (c.quantity.text.isEmpty) return i;
          if (c.unitAmount.text.isEmpty) return i;
          if (c.selectedunit == null) return i;
        }
      }
      return -1;
    }

    // ─────────────────────────────────────────────
    // EXCHANGE CALCULATION
    // ─────────────────────────────────────────────
    Future<void> calculateAndFetchExchange() async {
      try {
        final unitText = controller.unitAmount.text.trim();
        final qtyText = controller.quantity.text.trim();

        final double lineAmount = unitText.isEmpty
            ? (double.tryParse(controller.paidAmountCA1.text.trim()) ?? 0.0)
            : (double.tryParse(unitText) ?? 0.0);
        final double qty = double.tryParse(qtyText) ?? 0.0;

        if (lineAmount <= 0) {
          controller.showUnitAmountError.value = true;
          return;
        }

        // STEP 1: Line Total
        final calculatedLineAmount = qty > 0 ? qty * lineAmount : lineAmount;
        controller.amountINRCA1.text = calculatedLineAmount.toStringAsFixed(2);
        controller.paidAmount.text = calculatedLineAmount.toStringAsFixed(2);
        controller.paidAmountCA1.text = calculatedLineAmount.toStringAsFixed(2);

        // STEP 2: Requested %
        final requestedPercentage =
            double.tryParse(
              controller.requestedPercentage.text.replaceAll('%', '').trim(),
            ) ??
            0.0;
        double calculatedRequestedAmount = 0.0;
        if (requestedPercentage > 0) {
          calculatedRequestedAmount =
              (calculatedLineAmount * requestedPercentage) / 100;
        }
        controller.calculatedPercentage.value = calculatedRequestedAmount;

        // STEP 3: Exchange Rate CA1
        final currency1 = controller.currencyDropDowncontrollerCA3.text.trim();
        if (currency1.isNotEmpty) {
          final exchangeRate1 = await controller.fetchExchangeRatecalculated(
            currency1,
            calculatedLineAmount,
          );

          if (exchangeRate1 != null) {
            controller.unitRateCA1.text = exchangeRate1.toStringAsFixed(2);
            controller.amountINRCA1.text =
                (calculatedLineAmount * exchangeRate1).toStringAsFixed(2);
            controller.amountINRCA2.text =
                (calculatedLineAmount * exchangeRate1).toStringAsFixed(2);

            final double requestedAmount =
                ((calculatedLineAmount * exchangeRate1) * requestedPercentage) /
                100;
            controller.isVisible.value = true;

            // STEP 4: Exchange Rate CA2
            final currency2 = controller.currencyDropDowncontrollerCA2.text
                .trim();
            if (currency2.isNotEmpty) {
              final exchangeResponse = await controller.fetchExchangeRateCA(
                currency2,
                requestedAmount.toString(),
              );
              if (exchangeResponse != null) {
                controller.unitRateCA2.text = exchangeResponse.exchangeRate
                    .toStringAsFixed(2);
                controller.amountINRCA2.text = exchangeResponse.totalAmount
                    .toStringAsFixed(2);
                controller.totalRequestedAmount.text = exchangeResponse
                    .totalAmount
                    .toStringAsFixed(2);
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Calculation Error: $e");
      }
    }

    // ─────────────────────────────────────────────
    // INIT SYNC FROM controllerItems
    // ─────────────────────────────────────────────
    final theme = Theme.of(context);

    controller.selectedunit = controllerItems.selectedunit;
    controller.selectedDate = controllerItems.selectedDate;

    if (controller.requestedPercentage.text.isEmpty) {
      controller.requestedPercentage.text =
          controllerItems.requestedPercentage.text;
    }
    if (controller.currencyDropDowncontrollerCA3.text.isEmpty) {
      controller.currencyDropDowncontrollerCA3.text =
          controllerItems.currencyDropDowncontroller.text;
      controller.selectedCurrencyCA1.value =
          controllerItems.selectedCurrencyCA1.value;
    }
    if (controller.currencyDropDowncontrollerCA2.text.isEmpty) {
      controller.currencyDropDowncontrollerCA2.text =
          controllerItems.currencyDropDowncontroller2.text;
      controller.selectedCurrencyCA2.value =
          controllerItems.selectedCurrencyCA2.value;
    }

    if (setQuality && controller.quantity.text.isEmpty) {
      controller.quantity.text = '1.00';
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

      if (!controller.customFieldsItems.any(
        (f) => f['ObjectName'] == 'cashadvancetrans',
      )) {
        final transFields = controllerItems.customFields
            .where((f) => f['ObjectName'] == 'cashadvancetrans')
            .map((f) => Map<String, dynamic>.from(f))
            .toList();
        if (transFields.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.customFieldsItems.addAll(transFields);
            controller.customFieldsItems.refresh();
          });
        }
      }
    }
    // ─────────────────────────────────────────────
    // WIDGET TREE
    // ─────────────────────────────────────────────
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              // ── CUSTOM FIELDS ──
              Obx(() {
                return Column(
                  children: controller.customFieldsItems
                      .where((field) {
                        if (field['ObjectName'] == 'cashadvancetrans') {
                          return true;
                        }
                        if (field['ObjectName'] == 'ExpenseCategories') {
                          return controller.selectedCategoryId.isNotEmpty;
                        }
                        return false;
                      })
                      .map((field) {
                        final String label =
                            field['FieldLabel'] ?? field['FieldName'];
                        final bool isMandatory = field['IsMandatory'] ?? false;

                        // Populate default value if exists and not already set
                        if (field['DefaultValue'] != null &&
                            (field['EnteredValue'] == null ||
                                (field['EnteredValue'] is String &&
                                    field['EnteredValue'].isEmpty))) {
                          field['EnteredValue'] = field['DefaultValue'];
                        }

                        Widget inputField;

                        // Bug #76: Handle SystemList along with List and CustomList
                        if (field['FieldType'] == 'List' ||
    field['FieldType'] == 'CustomList' ||
    field['FieldType'] == 'SystemList') {
  
  List<CustomDropdownValue> options = [];
  if (field['Options'] != null && field['Options'] is List) {
    options = List<CustomDropdownValue>.from(field['Options']);
  }

  field['_controller'] ??= TextEditingController();
  final TextEditingController fieldController = field['_controller'];

  CustomDropdownValue? selectedValue = field['SelectedValue'];

  if (selectedValue == null && field['DefaultValue'] != null) {
    final matches = options.where(
      (opt) =>
          opt.valueId == field['DefaultValue'] ||
          opt.valueName == field['DefaultValue'],
    );
    selectedValue = matches.isNotEmpty ? matches.first : null;

    if (selectedValue != null) {
      field['SelectedValue'] = selectedValue;
      field['EnteredValue'] = selectedValue.valueId;
    }
  }

  // ✅ Show selectedValue name OR fallback to raw DefaultValue string
  fieldController.text = selectedValue?.valueName ?? 
                         field['DefaultValue']?.toString() ?? '';

  // ✅ If no matched selectedValue but DefaultValue exists,
  // create a placeholder CustomDropdownValue so dropdown shows it
  if (selectedValue == null && field['DefaultValue'] != null) {
    selectedValue = CustomDropdownValue(
      valueId: field['DefaultValue'].toString(),
      valueName: field['DefaultValue'].toString(),
    );
    // ✅ Add to options if not already present (so it renders in list too)
    final alreadyExists = options.any(
      (opt) => opt.valueId == selectedValue!.valueId,
    );
    if (!alreadyExists) {
      options = [selectedValue, ...options];
    }
    field['SelectedValue'] = selectedValue;
    field['EnteredValue'] = selectedValue.valueId;
  }

  inputField = SearchableMultiColumnDropdownField<CustomDropdownValue>(
    labelText: '$label${isMandatory ? " *" : ""}',
    items: options,
    selectedValue: selectedValue,
    searchValue: (val) => val.valueName,
    displayText: (val) => val.valueName,
    controller: fieldController,
    columnHeaders: const ['Value ID', 'Value Name'],
    rowBuilder: (val, searchQuery) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text(val.valueId)),
          Expanded(child: Text(val.valueName)),
        ],
      ),
    ),
    onChanged: (val) {
      field['SelectedValue'] = val;
      field['EnteredValue'] = val?.valueId;
      field['Error'] = null;
      fieldController.text = val?.valueName ?? '';
      controller.customFields.refresh();
    },
  );
}
                        // Bug #79 & #84: Fix Date and DateTime rendering with proper type handling
                        else if (field['FieldType'] == 'Date' ||
                            field['FieldType'] == 'Date&Time') {
                          final bool isDateTime =
                              field['FieldType'] == 'Date&Time';
                          DateTime? currentValue;

                          // Safely handle EnteredValue - could be String, DateTime, or null
                          if (field['EnteredValue'] != null) {
                            if (field['EnteredValue'] is DateTime) {
                              currentValue = field['EnteredValue'];
                            } else if (field['EnteredValue'] is String) {
                              try {
                                // Try to parse string as DateTime
                                currentValue = DateTime.parse(
                                  field['EnteredValue'],
                                );
                              } catch (e) {
                                // If parsing fails, try to create from formatted string
                                try {
                                  // Try common date formats
                                  List<String> dateFormats = [
                                    'dd/MM/yyyy',
                                    'MM/dd/yyyy',
                                    'yyyy-MM-dd',
                                    'dd-MM-yyyy',
                                  ];
                                  for (var format in dateFormats) {
                                    try {
                                      currentValue = DateFormat(
                                        format,
                                      ).parse(field['EnteredValue']);
                                      break;
                                    } catch (_) {}
                                  }
                                } catch (_) {
                                  currentValue = null;
                                }
                              }
                            }
                          }

                          // Handle Default Value if EnteredValue is null
                          if (currentValue == null &&
                              field['DefaultValue'] != null) {
                            if (field['DefaultValue'] is DateTime) {
                              currentValue = field['DefaultValue'];
                            } else if (field['DefaultValue'] is String) {
                              try {
                                // Try to parse default value string
                                currentValue = DateTime.parse(
                                  field['DefaultValue'],
                                );
                              } catch (e) {
                                try {
                                  // Try common date formats
                                  List<String> dateFormats = [
                                    'dd/MM/yyyy',
                                    'MM/dd/yyyy',
                                    'yyyy-MM-dd',
                                    'dd-MM-yyyy',
                                  ];
                                  for (var format in dateFormats) {
                                    try {
                                      currentValue = DateFormat(
                                        format,
                                      ).parse(field['DefaultValue']);
                                      break;
                                    } catch (_) {}
                                  }
                                } catch (_) {
                                  currentValue = null;
                                }
                              }
                            }
                          }

                          // Store the DateTime object back
                          if (currentValue != null) {
                            field['EnteredValue'] = currentValue;
                          }

                          // Get user's date format preference
                          String getUserDateFormat() {
                            // This should come from your user settings
                            // For now, return default or get from shared preferences
                            return 'dd/MM/yyyy';
                          }

                          String formatDateValue(DateTime date) {
                            String dateFormat = getUserDateFormat();
                            switch (dateFormat) {
                              case 'MM/dd/yyyy':
                                return DateFormat('MM/dd/yyyy').format(date);
                              case 'yyyy-MM-dd':
                                return DateFormat('yyyy-MM-dd').format(date);
                              case 'dd-MM-yyyy':
                                return DateFormat('dd-MM-yyyy').format(date);
                              default:
                                return DateFormat('dd/MM/yyyy').format(date);
                            }
                          }

                          String formatDateTimeValue(DateTime dateTime) {
                            String dateFormat = getUserDateFormat();
                            switch (dateFormat) {
                              case 'MM/dd/yyyy':
                                return DateFormat(
                                  'MM/dd/yyyy hh:mm a',
                                ).format(dateTime);
                              case 'yyyy-MM-dd':
                                return DateFormat(
                                  'yyyy-MM-dd hh:mm a',
                                ).format(dateTime);
                              case 'dd-MM-yyyy':
                                return DateFormat(
                                  'dd-MM-yyyy hh:mm a',
                                ).format(dateTime);
                              default:
                                return DateFormat(
                                  'dd/MM/yyyy hh:mm a',
                                ).format(dateTime);
                            }
                          }

                          inputField = TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: currentValue != null
                                  ? isDateTime
                                        ? formatDateTimeValue(currentValue)
                                        : formatDateValue(currentValue)
                                  : '',
                            ),
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: currentValue ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate == null) return;

                              if (isDateTime) {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                      context: context,
                                      initialTime: currentValue != null
                                          ? TimeOfDay.fromDateTime(
                                              currentValue!,
                                            )
                                          : TimeOfDay.now(),
                                    );
                                if (pickedTime == null) return;
                                currentValue = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              } else {
                                currentValue = pickedDate;
                              }
                              field['EnteredValue'] = currentValue;
                              field['Error'] = null;
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  field['EnteredValue'] == null) {
                                return '$label is required';
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #87: Fix LongInteger validation
                        else if (field['FieldType'] == 'LongInteger') {
                          inputField = TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^-?\d*'),
                              ), // Allow negative numbers
                            ],
                            initialValue:
                                field['EnteredValue']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                field['EnteredValue'] = null;
                              } else {
                                try {
                                  field['EnteredValue'] = int.parse(value);
                                  field['Error'] = null;
                                } catch (e) {
                                  field['Error'] =
                                      'Please enter a valid whole number';
                                }
                              }
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^-?\d+$').hasMatch(value)) {
                                  return 'Please enter a valid integer (whole number)';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #82: Fix Decimal validation
                        else if (field['FieldType'] == 'Decimal') {
                          inputField = TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^-?\d*\.?\d*'),
                              ),
                            ],
                            initialValue:
                                field['EnteredValue']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                field['EnteredValue'] = null;
                              } else {
                                try {
                                  field['EnteredValue'] = double.parse(value);
                                  field['Error'] = null;
                                } catch (e) {
                                  field['Error'] =
                                      'Please enter a valid decimal number';
                                }
                              }
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^-?\d*\.?\d+$').hasMatch(value)) {
                                  return 'Please enter a valid decimal number';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #77: Fix Email validation
                        else if (field['FieldType'] == 'Email') {
                          inputField = TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            initialValue: field['EnteredValue'] ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                              suffixIcon: const Icon(Icons.email_outlined),
                            ),
                            onChanged: (value) {
                              field['EnteredValue'] = value;
                              field['Error'] = null;
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                // More comprehensive email regex
                                final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Enter a valid email address (e.g., user@example.com)';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #78: Fix Mobile Number validation
                        else if (field['FieldType'] == 'MobileNumber') {
                          inputField = TextFormField(
                            keyboardType: TextInputType.phone,
                            initialValue: field['EnteredValue'] ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                              suffixIcon: const Icon(Icons.phone_outlined),
                            ),
                            onChanged: (value) {
                              field['EnteredValue'] = value;
                              field['Error'] = null;
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                // Validate mobile number with country code
                                final phoneRegex = RegExp(
                                  r'^[\+]?[0-9]{1,4}[\s\-]?[0-9]{6,12}$',
                                );
                                if (!phoneRegex.hasMatch(value.trim())) {
                                  return 'Enter a valid mobile number with country code (e.g., +91 9876543210)';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #83: Fix URL validation
                        else if (field['FieldType'] == 'URL') {
                          inputField = TextFormField(
                            keyboardType: TextInputType.url,
                            initialValue: field['EnteredValue'] ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                              suffixIcon: const Icon(Icons.link_outlined),
                            ),
                            onChanged: (value) {
                              field['EnteredValue'] = value;
                              field['Error'] = null;
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                final urlRegex = RegExp(
                                  r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
                                  caseSensitive: false,
                                );
                                if (!urlRegex.hasMatch(value)) {
                                  return 'Enter a valid URL (e.g., https://example.com)';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #85: Add Percentage field
                        else if (field['FieldType'] == 'Percentage') {
                          inputField = TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            initialValue:
                                field['EnteredValue']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                              suffixText: '%',
                              suffixStyle: const TextStyle(fontSize: 16),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                field['EnteredValue'] = null;
                              } else {
                                try {
                                  double percentage = double.parse(value);
                                  if (percentage >= 0 && percentage <= 100) {
                                    field['EnteredValue'] = percentage;
                                    field['Error'] = null;
                                  } else {
                                    field['Error'] =
                                        'Percentage must be between 0 and 100';
                                  }
                                } catch (e) {
                                  field['Error'] =
                                      'Please enter a valid percentage';
                                }
                              }
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                try {
                                  double percentage = double.parse(value);
                                  if (percentage < 0 || percentage > 100) {
                                    return 'Percentage must be between 0 and 100';
                                  }
                                } catch (e) {
                                  return 'Please enter a valid percentage number';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Bug #80: Fix Amount field
                        else if (field['FieldType'] == 'Amount') {
                          inputField = TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            initialValue:
                                field['EnteredValue']?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                              prefixText: '\$ ',
                              prefixStyle: const TextStyle(fontSize: 16),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                field['EnteredValue'] = null;
                              } else {
                                try {
                                  field['EnteredValue'] = double.parse(value);
                                  field['Error'] = null;
                                } catch (e) {
                                  field['Error'] =
                                      'Please enter a valid amount';
                                }
                              }
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^\d*\.?\d+$').hasMatch(value)) {
                                  return 'Please enter a valid amount';
                                }
                              }
                              return null;
                            },
                          );
                        }
                        // Default text field
                        else {
                          inputField = TextFormField(
                            keyboardType: TextInputType.text,
                            initialValue: field['EnteredValue'] ?? '',
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                              errorText: field['Error'],
                            ),
                            onChanged: (value) {
                              field['EnteredValue'] = value;
                              field['Error'] = null;
                              controller.customFields.refresh();
                            },
                            validator: (value) {
                              if (isMandatory &&
                                  (value == null || value.trim().isEmpty)) {
                                return '$label is required';
                              }
                              return null;
                            },
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: inputField,
                        );
                      })
                      .toList(),
                );
              }),

              const SizedBox(height: 6),
              // ── CUSTOM FIELDS ──
              // Obx(() {
              //   // ✅ Use the passed 'controller' parameter (item-specific), NOT controllerItems
              //   final customFieldsToShow = controller.customFieldsItems
              //       .where(
              //         (field) =>
              //             // field['ObjectName'] == 'cashadvancetrans' ||
              //             field['ObjectName'] == 'ExpenseCategories',
              //       )
              //       .toList();

              //   if (customFieldsToShow.isEmpty) {
              //     return const SizedBox.shrink();
              //   }

              //   return Column(
              //     children: customFieldsToShow.map((field) {
              //       final String label = field['FieldLabel'] ?? field['FieldName'];
              //       final bool isMandatory = field['IsMandatory'] ?? false;
              //       final String fieldType = field['FieldType'] ?? 'Text';

              //       Widget inputField;

              //       // List type fields
              //       if (fieldType == 'List' ||
              //           fieldType == 'CustomList' ||
              //           fieldType == 'SystemList') {
              //         if (field['_rxSelectedValue'] == null) {
              //           final defaultValue = field['DefaultValue']?.toString() ?? '';
              //           final options = (field['Options'] as List<CustomDropdownValue>?) ?? [];

              //           CustomDropdownValue? matchedOption;
              //           if (defaultValue.isNotEmpty && options.isNotEmpty) {
              //             matchedOption = options.firstWhere(
              //               (opt) => opt.valueName == defaultValue || opt.valueId == defaultValue,
              //               // orElse: () => null,
              //             );
              //           }

              //           field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(matchedOption);
              //           field['SelectedValue'] = matchedOption;
              //         }

              //         inputField = Obx(() {
              //           final rxValue = field['_rxSelectedValue'] as Rx<CustomDropdownValue?>;
              //           return SearchableMultiColumnDropdownField<CustomDropdownValue>(
              //             labelText: '$label${isMandatory ? " *" : ""}',
              //             items: (field['Options'] as List<CustomDropdownValue>?) ?? [],
              //             selectedValue: rxValue.value,
              //             searchValue: (val) => val.valueName,
              //             displayText: (val) => val.valueName,
              //             columnHeaders: const ['Value ID', 'Value Name'],
              //             rowBuilder: (val, searchQuery) => Padding(
              //               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              //               child: Row(
              //                 children: [
              //                   Expanded(child: Text(val.valueId)),
              //                   Expanded(child: Text(val.valueName)),
              //                 ],
              //               ),
              //             ),
              //             onChanged: (val) {
              //               rxValue.value = val;
              //               field['SelectedValue'] = val;
              //               field['EnteredValue'] = val?.valueId ?? '';
              //               field['Error'] = null;
              //               controller.customFieldsItems.refresh();
              //             },
              //           );
              //         });
              //       }
              //       // Checkbox type
              //       else if (fieldType == 'Checkbox') {
              //         if (field['_rxCheckboxValue'] == null) {
              //           field['_rxCheckboxValue'] = Rx<bool>(field['EnteredValue'] ?? false);
              //         }

              //         inputField = Obx(() {
              //           final rxValue = field['_rxCheckboxValue'] as Rx<bool>;
              //           return CheckboxListTile(
              //             title: Text('$label${isMandatory ? " *" : ""}'),
              //             value: rxValue.value,
              //             controlAffinity: ListTileControlAffinity.leading,
              //             contentPadding: EdgeInsets.zero,
              //             onChanged: (bool? val) {
              //               rxValue.value = val ?? false;
              //               field['EnteredValue'] = val ?? false;
              //               controller.customFieldsItems.refresh();
              //             },
              //           );
              //         });
              //       }
              //       // Date and DateTime types
              //       else if (fieldType == 'Date' || fieldType == 'Date&Time') {
              //         final bool isDateTime = fieldType == 'Date&Time';

              //         if (field['_rxDateValue'] == null) {
              //           field['_rxDateValue'] = Rx<DateTime?>(field['EnteredValue'] as DateTime?);
              //         }

              //         inputField = Obx(() {
              //           final rxDateValue = field['_rxDateValue'] as Rx<DateTime?>;
              //           final textController = TextEditingController();
              //           if (rxDateValue.value != null) {
              //             textController.text = isDateTime
              //                 ? DateFormat('dd/MM/yyyy hh:mm a').format(rxDateValue.value!)
              //                 : DateFormat('dd/MM/yyyy').format(rxDateValue.value!);
              //           }

              //           return TextFormField(
              //             readOnly: true,
              //             controller: textController,
              //             decoration: InputDecoration(
              //               labelText: '$label${isMandatory ? " *" : ""}',
              //               border: const OutlineInputBorder(),
              //               errorText: field['Error'],
              //               suffixIcon: const Icon(Icons.calendar_today),
              //             ),
              //             onTap: () async {
              //               final DateTime? pickedDate = await showDatePicker(
              //                 context: context,
              //                 initialDate: rxDateValue.value ?? DateTime.now(),
              //                 firstDate: DateTime(2000),
              //                 lastDate: DateTime(2100),
              //               );
              //               if (pickedDate == null) return;

              //               if (isDateTime) {
              //                 final TimeOfDay? pickedTime = await showTimePicker(
              //                   context: context,
              //                   initialTime: rxDateValue.value != null
              //                       ? TimeOfDay.fromDateTime(rxDateValue.value!)
              //                       : TimeOfDay.now(),
              //                 );
              //                 if (pickedTime == null) return;
              //                 final fullDateTime = DateTime(
              //                   pickedDate.year, pickedDate.month, pickedDate.day,
              //                   pickedTime.hour, pickedTime.minute,
              //                 );
              //                 rxDateValue.value = fullDateTime;
              //                 field['EnteredValue'] = fullDateTime;
              //               } else {
              //                 rxDateValue.value = pickedDate;
              //                 field['EnteredValue'] = pickedDate;
              //               }
              //               controller.customFieldsItems.refresh();
              //             },
              //             validator: (value) {
              //               if (isMandatory && rxDateValue.value == null) {
              //                 return '$label is required';
              //               }
              //               return null;
              //             },
              //           );
              //         });
              //       }
              //       // Email type with persistent controller
              //       else if (fieldType == 'Email') {
              //         if (field['_controller'] == null) {
              //           final defaultValue = field['DefaultValue']?.toString() ?? '';
              //           final existingValue = field['EnteredValue'] as String?;
              //           final initialValue = existingValue ?? defaultValue;

              //           field['_controller'] = TextEditingController(text: initialValue);
              //           field['_rxStringValue'] = Rx<String?>(initialValue);
              //           field['_focusNode'] = FocusNode();
              //           field['EnteredValue'] = initialValue;

              //           field['_controller'].addListener(() {
              //             final value = field['_controller'].text;
              //             if (value != field['_rxStringValue'].value) {
              //               field['_rxStringValue'].value = value;
              //               field['EnteredValue'] = value;
              //             }
              //           });
              //         }

              //         inputField =  TextFormField(
              //             controller: field['_controller'],
              //             focusNode: field['_focusNode'],
              //             keyboardType: TextInputType.emailAddress,
              //             decoration: InputDecoration(
              //               labelText: '$label${isMandatory ? " *" : ""}',
              //               border: const OutlineInputBorder(),
              //               errorText: field['Error'],
              //               suffixIcon: const Icon(Icons.email_outlined),
              //             ),
              //             validator: (value) {
              //               if (isMandatory && (value == null || value.trim().isEmpty)) {
              //                 return '$label is required';
              //               }
              //               if (value != null && value.isNotEmpty) {
              //                 final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              //                 if (!emailRegex.hasMatch(value)) {
              //                   return 'Enter a valid email address';
              //                 }
              //               }
              //               return null;
              //             },
              //           );
              //         // });
              //       }
              //       // MobileNumber type
              //       else if (fieldType == 'MobileNumber') {
              //         if (field['_controller'] == null) {
              //           final defaultValue = field['DefaultValue']?.toString() ?? '';
              //           final existingValue = field['EnteredValue'] as String?;
              //           final initialValue = existingValue ?? defaultValue;

              //           field['_controller'] = TextEditingController(text: initialValue);
              //           field['_rxStringValue'] = Rx<String?>(initialValue);
              //           field['_focusNode'] = FocusNode();
              //           field['EnteredValue'] = initialValue;

              //           field['_controller'].addListener(() {
              //             final value = field['_controller'].text;
              //             if (value != field['_rxStringValue'].value) {
              //               field['_rxStringValue'].value = value;
              //               field['EnteredValue'] = value;
              //             }
              //           });
              //         }

              //         inputField = Obx(() {
              //           return TextFormField(
              //             controller: field['_controller'],
              //             focusNode: field['_focusNode'],
              //             keyboardType: TextInputType.phone,
              //             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]+'))],
              //             decoration: InputDecoration(
              //               labelText: '$label${isMandatory ? " *" : ""}',
              //               border: const OutlineInputBorder(),
              //               errorText: field['Error'],
              //               suffixIcon: const Icon(Icons.phone_outlined),
              //             ),
              //             validator: (value) {
              //               if (isMandatory && (value == null || value.trim().isEmpty)) {
              //                 return '$label is required';
              //               }
              //               if (value != null && value.isNotEmpty) {
              //                 final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '');
              //                 if (cleanNumber.length < 6 || cleanNumber.length > 15) {
              //                   return 'Enter a valid mobile number (6-15 digits)';
              //                 }
              //               }
              //               return null;
              //             },
              //           );
              //         });
              //       }
              //       // Numeric types
              //       else if (fieldType == 'LongInteger') {
              //         if (field['_rxIntValue'] == null) {
              //           field['_rxIntValue'] = Rx<int?>(field['EnteredValue'] as int?);
              //         }

              //         inputField = Obx(() {
              //           final rxValue = field['_rxIntValue'] as Rx<int?>;
              //           final textController = TextEditingController(text: rxValue.value?.toString() ?? '');
              //           textController.addListener(() {
              //             final value = textController.text;
              //             if (value.isEmpty) {
              //               rxValue.value = null;
              //               field['EnteredValue'] = null;
              //             } else {
              //               final intVal = int.tryParse(value);
              //               if (intVal != rxValue.value) {
              //                 rxValue.value = intVal;
              //                 field['EnteredValue'] = intVal;
              //               }
              //             }
              //           });
              //           return TextFormField(
              //             controller: textController,
              //             keyboardType: TextInputType.number,
              //             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //             decoration: InputDecoration(
              //               labelText: '$label${isMandatory ? " *" : ""}',
              //               border: const OutlineInputBorder(),
              //               errorText: field['Error'],
              //             ),
              //             validator: (value) {
              //               if (isMandatory && (value == null || value.trim().isEmpty)) {
              //                 return '$label is required';
              //               }
              //               return null;
              //             },
              //           );
              //         });
              //       }
              //       else if (fieldType == 'Decimal') {
              //         if (field['_rxDoubleValue'] == null) {
              //           field['_rxDoubleValue'] = Rx<double?>(field['EnteredValue'] as double?);
              //         }

              //         inputField = Obx(() {
              //           final rxValue = field['_rxDoubleValue'] as Rx<double?>;
              //           final textController = TextEditingController(text: rxValue.value?.toString() ?? '');
              //           textController.addListener(() {
              //             final value = textController.text;
              //             if (value.isEmpty) {
              //               rxValue.value = null;
              //               field['EnteredValue'] = null;
              //             } else {
              //               final doubleVal = double.tryParse(value);
              //               if (doubleVal != rxValue.value) {
              //                 rxValue.value = doubleVal;
              //                 field['EnteredValue'] = doubleVal;
              //               }
              //             }
              //           });
              //           return TextFormField(
              //             controller: textController,
              //             keyboardType: const TextInputType.numberWithOptions(decimal: true),
              //             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
              //             decoration: InputDecoration(
              //               labelText: '$label${isMandatory ? " *" : ""}',
              //               border: const OutlineInputBorder(),
              //               errorText: field['Error'],
              //             ),
              //             validator: (value) {
              //               if (isMandatory && (value == null || value.trim().isEmpty)) {
              //                 return '$label is required';
              //               }
              //               return null;
              //             },
              //           );
              //         });
              //       }
              //       else {
              //         // Default Text type
              //         if (field['_controller'] == null) {
              //           final defaultValue = field['DefaultValue']?.toString() ?? '';
              //           final existingValue = field['EnteredValue'] as String?;
              //           final initialValue = existingValue ?? defaultValue;

              //           field['_controller'] = TextEditingController(text: initialValue);
              //           field['_rxStringValue'] = Rx<String?>(initialValue);
              //           field['_focusNode'] = FocusNode();
              //           field['EnteredValue'] = initialValue;

              //           field['_controller'].addListener(() {
              //             final value = field['_controller'].text;
              //             if (value != field['_rxStringValue'].value) {
              //               field['_rxStringValue'].value = value;
              //               field['EnteredValue'] = value;
              //             }
              //           });
              //         }

              //         inputField = Obx(() {
              //           return TextFormField(
              //             controller: field['_controller'],
              //             focusNode: field['_focusNode'],
              //             keyboardType: TextInputType.text,
              //             decoration: InputDecoration(
              //               labelText: '$label${isMandatory ? " *" : ""}',
              //               border: const OutlineInputBorder(),
              //               errorText: field['Error'],
              //             ),
              //             validator: (value) {
              //               if (isMandatory && (value == null || value.trim().isEmpty)) {
              //                 return '$label is required';
              //               }
              //               return null;
              //             },
              //           );
              //         });
              //       }

              //       return Padding(
              //         padding: const EdgeInsets.symmetric(vertical: 8),
              //         child: inputField,
              //       );
              //     }).toList(),
              //   );
              // }),
              const SizedBox(height: 6),
              // ── PROJECT ID ──
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
                              },
                              rowBuilder: (proj, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(proj.name)),
                                      Expanded(child: Text(proj.code)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // ── FIX: error widget was present, kept ──
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

              // ── LOCATION ──
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
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                calculateAndFetchExchange();
                                field['Error'] = null;
                                // Clear location error on selection
                                setState(() => _showLocationError = false);
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
              Text("${AppLocalizations.of(context)!.paidFor}"),
              const SizedBox(height: 1),
              const SizedBox(height: 20),

              // ── CATEGORY GRID ──
              Obx(() {
                final fetchCategory = controller.expenseCategory.isNotEmpty
                    ? controller.expenseCategory
                    : controllerItems.expenseCategory;

                if (fetchCategory.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noDataFound,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

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

              // ── REQUESTED PERCENTAGE ──
              TextField(
                controller: controller.requestedPercentage,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context)!.requestedPercentage} * (%)",
                  suffix: const Text("% "),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSubmitted: (value) {
                  calculatePercentage(value, controller, 0);
                },
                onChanged: (val) {
                  controller.validatePercentage(
                    val,
                    controller.allowedPercentage.text,
                    controller,
                  );
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(seconds: 2), () async {
                    await calculatePercentage(
                      controller.requestedPercentage.text,
                      controller,
                      0,
                    );
                  });
                  calculateAndFetchExchange();
                },
                onEditingComplete: () {
                  calculatePercentage(
                    controller.requestedPercentage.text,
                    controller,
                    0,
                  );
                  FocusScope.of(context).unfocus();
                },
              ),
              Obx(
                () => controller.percentageError.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Percentage cannot exceed ${controller.allowedPercentage.text}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              // ── FIX: show _showPercentageError in UI ──
              if (_showPercentageError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Percentage must be between 1 and 100',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              if (showItemizeDetails) const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── UNIT DROPDOWN ──
                  if (showItemizeDetails)
                    SearchableMultiColumnDropdownField<Unit>(
                      labelText: '${AppLocalizations.of(context)!.unit} *',
                      columnHeaders: const ['Uom Id', 'Uom Name'],
                      items: controllerItems.unit,
                      selectedValue: controller.selectedunit,
                      searchValue: (tax) => '${tax.code} ${tax.name}',
                      displayText: (tax) => tax.name,
                      onChanged: (tax) {
                        setState(() {
                          controller.selectedunit = tax;
                          _showUnitError = false; // clear on change
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
                  // ── FIX: unit error now shows in UI ──
                  if (showItemizeDetails && _showUnitError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Please select a Unit',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  if (showItemizeDetails) const SizedBox(height: 16),

                  // ── UNIT AMOUNT + QUANTITY ROW ──
                  if (showItemizeDetails)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.unitAmount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) async {
                              FocusScope.of(context).unfocus();
                              await calculateAndFetchExchange();
                            },
                            onEditingComplete: () async {
                              FocusScope.of(context).unfocus();
                              await calculateAndFetchExchange();
                            },
                            onChanged: (value) {
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();
                              _debounce = Timer(
                                const Duration(seconds: 2),
                                () async {
                                  await calculateAndFetchExchange();
                                },
                              );
                              // clear error on type
                              if (controller.showUnitAmountError.value) {
                                setState(() {
                                  controller.showUnitAmountError.value = false;
                                  _showRequestedAmountError = false;
                                  _showPaidAmountError = false;
                                });
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            controller: controller.quantity,
                            onChanged: (value) {
                              setState(() {
                                controller.showQuantityError.value = false;
                                setQuality = false;
                              });
                              calculateAndFetchExchange();
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
                            ),
                          ),
                        ),
                      ],
                    ),

                  // ── ACCOUNT DISTRIBUTION BUTTON ──
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

                  // ── AMOUNTS CARD ──
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
                          // ─── Total Estimated Amount ───
                          Text(
                            '${AppLocalizations.of(context)!.totalEstimatedAmountIn} *',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller.paidAmountCA1,
                                  enabled: !showItemizeDetails,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) async {
                                    FocusScope.of(context).unfocus();
                                    await calculateAndFetchExchange();
                                  },
                                  onEditingComplete: () async {
                                    FocusScope.of(context).unfocus();
                                    await calculateAndFetchExchange();
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      setState(
                                        () => _showPaidAmountError = false,
                                      );
                                      if (_debounce?.isActive ?? false)
                                        _debounce!.cancel();
                                      _debounce = Timer(
                                        const Duration(seconds: 3),
                                        () async {
                                          await calculateAndFetchExchange();
                                        },
                                      );
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.totalEstimatedAmountIn,
                                    isDense: true,
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                        alignLeft: -110,
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
                                          calculateAndFetchExchange();
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
                              Expanded(
                                child: TextFormField(
                                  enabled: false,
                                  controller: controller.unitRateCA1,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.rate,
                                    isDense: true,
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ── FIX: paid amount error now shows in UI ──
                          if (_showPaidAmountError)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Please enter a valid amount',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),
                          TextFormField(
                            controller: controller.amountINRCA1,
                            enabled: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText:
                                  '${AppLocalizations.of(context)!.lineEstimatedAmountInINR} ${controllerFitch.organizationCurrency}',
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // ─── Total Requested Amount ───
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.totalRequestedAmount,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller.totalRequestedAmount,
                                  enabled: false,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.totalRequestedAmount,
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onChanged: (_) async {
                                    calculateAndFetchExchange();
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
                                        alignLeft: -110,
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
                                          calculateAndFetchExchange();
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
                              Expanded(
                                child: TextFormField(
                                  controller: controller.unitRateCA2,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.rate,
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ── FIX: requested amount error in UI ──
                          if (_showRequestedAmountError)
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

                          const SizedBox(height: 10),
                          // ── FIX: this should show amountINRCA2, not CA1 again ──
                          TextFormField(
                            controller: controller.amountINRCA1,
                            enabled: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText:
                                  '${AppLocalizations.of(context)!.totalRequestedAmountInINR} ${controllerFitch.organizationCurrency}',
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

                  // ── COMMENTS ──
                  TextField(
                    controller: controller.descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.comments,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── REMOVE / ITEMIZE BUTTONS ──
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          if (!snapshot.hasData) return const SizedBox.shrink();

                          return OutlinedButton.icon(
                            // ────────────────────────────────────────
                            // ITEMIZE BUTTON — FIXED onPressed
                            // ────────────────────────────────────────
                            onPressed: () {
                              final isValid = _validateForm(
                                isItemizeButton: true,
                              );

                              debugPrint(
                                '✅ Itemize Validation Result: $isValid',
                              );
                              debugPrint('📊 Itemize Count: $_itemizeCount');

                              if (!isValid) return;

                              try {
                                final items = itemizeControllers
                                    .map((c) => c.toCashAdvanceRequestItemize())
                                    .toList();

                                for (var i = 0; i < items.length; i++) {
                                  debugPrint(
                                    "📝 Item $i: ${jsonEncode(items[i].toJson())}",
                                  );
                                }
                                controller.unitAmount.text =
                                    controller.paidAmountCA1.text;
                                controllerItems.finalItemsCashAdvanceNew =
                                    items;
                                _addItemize();
                              } catch (e, stackTrace) {
                                debugPrint("❌ EXACT ERROR: $e");
                                debugPrint("❌ STACK TRACE: $stackTrace");
                                rethrow;
                              }
                            },
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
                            label: Text(AppLocalizations.of(context)!.itemize),
                          );
                        },
                      ),
                    ],
                  ),

                  // ── BACK / NEXT BUTTONS ──
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

                        // ────────────────────────────────────────
                        // NEXT / FINISH BUTTON — FIXED onPressed
                        // ────────────────────────────────────────
                        ElevatedButton(
                          onPressed: () async {
                            if (_validateForm(isItemizeButton: false)) {
                              try {
                                final invalidIndex =
                                    _getFirstInvalidItemizeIndex();
                                if (invalidIndex != -1) {
                                  setState(
                                    () => _selectedItemizeIndex = invalidIndex,
                                  );
                                  Fluttertoast.showToast(
                                    msg:
                                        "Please fill all required fields in item ${invalidIndex + 1}",
                                    backgroundColor: Colors.red,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  return;
                                }

                                final items = itemizeControllers
                                    .map((c) => c.toCashAdvanceRequestItemize())
                                    .toList();

                                for (var i = 0; i < items.length; i++) {
                                  debugPrint(
                                    "📝 Item $i: ${jsonEncode(items[i].toJson())}",
                                  );
                                }

                                controllerItems.finalItemsCashAdvanceNew =
                                    items;
                                await calculateAndFetchExchange();
                                _nextStep();
                              } catch (e) {
                                debugPrint(
                                  '❌ Error converting to CashAdvanceRequestItemize: $e',
                                );
                              }
                            } else {
                              // Show error message
                              Fluttertoast.showToast(
                                msg: "Please fix all validation errors",
                                backgroundColor: Colors.red,
                              );
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
        // If same category, do nothing
        if (controller.selectedCategoryId == item.categoryId) {
          return;
        }

        setState(() {
          _selectedCategoryIndex = index;
        });

        // ✅ Clear existing category fields for THIS controller
        controller.customFieldsItems.removeWhere(
          (f) => f['ObjectName'] == 'ExpenseCategories',
        );

        // ✅ Set new category ID
        controller.selectedCategoryId = item.categoryId;
        controller.showPaidForError.value = false;

        // ✅ Fetch fresh data from API for this specific category
        // This will get the DEFAULT values from the API
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

          // ✅ Load category custom fields with FRESH DEFAULT values from API
          if (item.customFields != null && item.customFields!.isNotEmpty) {
            final categoryFields = item.customFields!.map((f) {
              final Map<String, dynamic> field = Map<String, dynamic>.from(f);
              field['ObjectName'] = 'ExpenseCategories';
              field['ExpenseType'] = 'General Expenses';

              // ✅ Use DefaultValue from API, NOT from previous selections
              final defaultVal = field['DefaultValue']?.toString() ?? '';

              // Store the actual entered value separately
              field['EnteredValue'] = defaultVal;

              // For dropdown/list types, find matching option from API
              if (field['FieldType'] == 'List' ||
                  field['FieldType'] == 'CustomList' ||
                  field['FieldType'] == 'SystemList') {
                final options = field['Options'] as List<CustomDropdownValue>?;
                CustomDropdownValue? matchedOption;
                if (options != null && defaultVal.isNotEmpty) {
                  matchedOption = options.firstWhere(
                    (opt) =>
                        opt.valueName == defaultVal ||
                        opt.valueId == defaultVal,
                    // orElse: () => null,
                  );
                }
                field['SelectedValue'] = matchedOption;

                // ✅ Initialize Rx with default value
                if (field['_rxSelectedValue'] == null) {
                  field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(
                    matchedOption,
                  );
                } else {
                  (field['_rxSelectedValue'] as Rx<CustomDropdownValue?>)
                          .value =
                      matchedOption;
                }
              } else {
                // ✅ For text fields, initialize controller with default value
                if (field['_controller'] == null) {
                  field['_controller'] = TextEditingController(
                    text: defaultVal,
                  );
                  field['_focusNode'] = FocusNode();
                } else {
                  field['_controller'].text = defaultVal;
                }
                field['_rxStringValue'] = Rx<String?>(defaultVal);
              }

              field['Error'] = null;
              return field;
            }).toList();

            controller.customFieldsItems.addAll(categoryFields);
          }

          controller.customFieldsItems.refresh();

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
            if (item.itemisationMandatory && showItemizeDetails == false) {
              _addItemize();
            }
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
        return controller.isLoadingCAForm.value
            ? const SkeletonLoaderPage()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  // key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 16),
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
                              Obx(() {
                                if (controller.isSequenceLoading.value) {
                                  return const SizedBox(); // or loader
                                }

                                final hideField = controller.hasModule(
                                  "CashAdvance",
                                );

                                if (hideField) {
                                  return const SizedBox.shrink(); // ✅ hide
                                }

                                return Column(
                                  children: [
                                    TextFormField(
                                      controller:
                                          controller.cashAdvanceRequisitionID,
                                      decoration: InputDecoration(
                                        labelText:
                                            '${AppLocalizations.of(context)!.cashAdvanceRequisitionId} *',
                                        errorText: cashAdvanceError,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }),

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
                                    labelText:
                                        '${AppLocalizations.of(context)!.requestDate} * ',
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
                                            ? AppLocalizations.of(
                                                context,
                                              )!.selectDate
                                            : DateFormat(
                                                controller
                                                        .selectedFormat
                                                        ?.key ??
                                                    'dd-MM-yyyy',
                                              ).format(
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
                      if (PermissionHelper.canRead("User Delegates") == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchableMultiColumnDropdownField<EmployeeId>(
                              labelText:
                                  '${AppLocalizations.of(context)!.employeeId} *',
                              columnHeaders: [
                                AppLocalizations.of(context)!.employeeName,
                                AppLocalizations.of(context)!.employeeId,
                              ],
                              items: controller.employeesID,
                              controller: controller.employeeDropDownController,
                              selectedValue:
                                  controller.selectedEmployeeID.value,
                              searchValue: (emp) =>
                                  '${emp.employeeName} ${emp.employeeId}',
                              displayText: (emp) => emp.employeeId,
                              validator: (emp) =>
                                  controller
                                      .employeeDropDownController
                                      .text
                                      .isEmpty
                                  ? AppLocalizations.of(context)!.fieldRequired
                                  : null,
                              onChanged: (emp) {
                                if (emp == null) {
                                  controller.fetchEmployees();
                                }
                                setState(() {
                                  controller.selectedEmployeeID.value = emp;
                                  controller.employeeDropDownController.text =
                                      emp!.employeeId;
                                  controller.employeeName.text =
                                      emp?.employeeName ?? '';
                                });
                              },
                              rowBuilder: (emp, searchQuery) {
                                bool isMatch = false;
                                if (searchQuery.isNotEmpty) {
                                  final searchableText =
                                      '${emp.employeeName} ${emp.employeeId}'
                                          .toLowerCase();
                                  isMatch = searchableText.contains(
                                    searchQuery.toLowerCase(),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            emp.employeeName,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            emp.employeeId,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),

                            if (employeeError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  employeeError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      if (employeeError != null) const SizedBox(height: 8),
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
                            labelText:
                                '${AppLocalizations.of(context)!.businessJustification} * ',
                            columnHeaders: [
                              AppLocalizations.of(context)!.id,
                              AppLocalizations.of(context)!.name,
                            ],
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
                                    const SizedBox(width: 8),
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
                      const SizedBox(height: 6),
                      Obx(() {
                        return Column(
                          children: controller.customFields
                              .where(
                                (field) =>
                                    field['ObjectName'] == 'cashadvanceheader',
                              )
                              .map((field) {
                                final String label =
                                    field['FieldLabel'] ?? field['FieldName'];
                                final bool isMandatory =
                                    field['IsMandatory'] ?? false;

                                Widget inputField;

                                if (field['FieldType'] == 'List' ||
                                    field['FieldType'] == 'CustomList' ||
                                    field['FieldType'] == 'SystemList') {
                                  // ── Dropdown / Searchable List ──
                                  inputField =
                                      SearchableMultiColumnDropdownField<
                                        CustomDropdownValue
                                      >(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        items:
                                            (field['Options']
                                                as List<
                                                  CustomDropdownValue
                                                >?) ??
                                            [],
                                        selectedValue: field['SelectedValue'],
                                        searchValue: (val) => val.valueName,
                                        // enabled: controller.isEditModePerdiem,
                                        displayText: (val) => val.valueName,
                                        columnHeaders: const [
                                          'Value ID',
                                          'Value Name',
                                        ],
                                        rowBuilder: (val, searchQuery) =>
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 16,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(val.valueId),
                                                  ),
                                                  Expanded(
                                                    child: Text(val.valueName),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        onChanged: (val) {
                                          field['SelectedValue'] = val;
                                          field['Error'] = null;
                                          controller.customFields.refresh();
                                        },
                                      );
                                } else if (field['FieldType'] == 'Checkbox') {
                                  // ── Checkbox ──
                                  inputField = CheckboxListTile(
                                    title: Text(
                                      '$label${isMandatory ? " *" : ""}',
                                    ),
                                    value: field['EnteredValue'] ?? false,
                                    // enabled: controller.isEditModePerdiem,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (bool? val) {
                                      field['EnteredValue'] = val ?? false;
                                      controller.customFields.refresh();
                                    },
                                  );
                                } else if (field['FieldType'] == 'Date' ||
                                    field['FieldType'] == 'Date&Time') {
                                  // ── Date / Date&Time ──
                                  final bool isDateTime =
                                      field['FieldType'] == 'Date&Time';

                                  inputField = TextFormField(
                                    // enabled: controller.isEditModePerdiem,
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: field['EnteredValue'] != null
                                          ? isDateTime
                                                ? DateFormat(
                                                    'dd/MM/yyyy hh:mm a',
                                                  ).format(
                                                    field['EnteredValue'],
                                                  )
                                                : DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).format(
                                                    field['EnteredValue'],
                                                  )
                                          : '',
                                    ),
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                      errorText: field['Error'],
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                    ),
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate:
                                                field['EnteredValue'] ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                      if (pickedDate == null) return;

                                      if (isDateTime) {
                                        final TimeOfDay? pickedTime =
                                            await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  field['EnteredValue'] != null
                                                  ? TimeOfDay.fromDateTime(
                                                      field['EnteredValue'],
                                                    )
                                                  : TimeOfDay.now(),
                                            );

                                        if (pickedTime == null) return;

                                        field['EnteredValue'] = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                      } else {
                                        field['EnteredValue'] = pickedDate;
                                      }

                                      controller.customFields.refresh();
                                    },
                                    validator: (value) {
                                      if (isMandatory &&
                                          field['EnteredValue'] == null) {
                                        return '$label is required';
                                      }
                                      return null;
                                    },
                                  );
                                } else if (field['FieldType'] ==
                                    'LongInteger') {
                                  // ── Integer Number ──
                                  inputField = TextFormField(
                                    // enabled: controller.isEditModePerdiem,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    initialValue:
                                        field['EnteredValue']?.toString() ?? '',
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                      errorText: field['Error'],
                                    ),
                                    onChanged: (value) {
                                      field['EnteredValue'] = int.tryParse(
                                        value,
                                      );
                                    },
                                    validator: (value) {
                                      if (isMandatory &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return '$label is required';
                                      }
                                      return null;
                                    },
                                  );
                                } else if (field['FieldType'] == 'Decimal') {
                                  // ── Decimal Number ──
                                  inputField = TextFormField(
                                    // enabled: controller.isEditModePerdiem,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d*'),
                                      ),
                                    ],
                                    initialValue:
                                        field['EnteredValue']?.toString() ?? '',
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                      errorText: field['Error'],
                                    ),
                                    onChanged: (value) {
                                      field['EnteredValue'] = double.tryParse(
                                        value,
                                      );
                                    },
                                    validator: (value) {
                                      if (isMandatory &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return '$label is required';
                                      }
                                      return null;
                                    },
                                  );
                                } else if (field['FieldType'] == 'Email') {
                                  // ── Email ──
                                  inputField = TextFormField(
                                    // enabled: controller.isEditModePerdiem,
                                    keyboardType: TextInputType.emailAddress,
                                    initialValue: field['EnteredValue'] ?? '',
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                      errorText: field['Error'],
                                      suffixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      field['EnteredValue'] = value;
                                    },
                                    validator: (value) {
                                      if (isMandatory &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return '$label is required';
                                      }
                                      if (value != null && value.isNotEmpty) {
                                        final emailRegex = RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        );
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Enter a valid email address';
                                        }
                                      }
                                      return null;
                                    },
                                  );
                                } else if (field['FieldType'] ==
                                    'MobileNumber') {
                                  // ── Mobile Number ──
                                  inputField = TextFormField(
                                    // enabled: controller.isEditModePerdiem,
                                    keyboardType: TextInputType.phone,
                                    initialValue: field['EnteredValue'] ?? '',
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                      errorText: field['Error'],
                                      suffixIcon: const Icon(
                                        Icons.phone_outlined,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      field['EnteredValue'] = value;
                                    },
                                    validator: (value) {
                                      if (isMandatory &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return '$label is required';
                                      }
                                      if (value != null && value.isNotEmpty) {
                                        final phoneRegex = RegExp(
                                          r'^\+?[\d\s\-]{7,15}$',
                                        );
                                        if (!phoneRegex.hasMatch(value)) {
                                          return 'Enter a valid mobile number';
                                        }
                                      }
                                      return null;
                                    },
                                  );
                                } else {
                                  // ── Default Text ──
                                  inputField = TextFormField(
                                    // enabled: controller.isEditModePerdiem,
                                    keyboardType: TextInputType.text,
                                    initialValue: field['EnteredValue'] ?? '',
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                      errorText: field['Error'],
                                    ),
                                    onChanged: (value) {
                                      field['EnteredValue'] = value;
                                    },
                                    validator: (value) {
                                      if (isMandatory &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return '$label is required';
                                      }
                                      return null;
                                    },
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: inputField,
                                );
                              })
                              .toList(),
                        );
                      }),
                      const SizedBox(height: 6),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.paidWith,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Paid With Radio Buttons
                      Obx(() {
                        /// ✅ SHOW LOADER
                        if (controller.isPaymentMethodsLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        /// ✅ SHOW EMPTY STATE
                        if (controller.paymentMethods.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.noDataFound,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }

                        /// ✅ SHOW LIST
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                      Icon(icons[index % icons.length]),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(method.paymentMethodId),
                                      ),
                                    ],
                                  ),
                                  value: method.paymentMethodId,
                                  groupValue:
                                      controller.paidWithCashAdvance.value,

                                  /// ❌ REMOVE setState — GetX handles it
                                  onChanged: (value) {
                                    if (controller.paidWithCashAdvance.value ==
                                        value) {
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
                                  },

                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              );
                            }),

                            const SizedBox(height: 8),

                            /// ✅ CLEAR BUTTON
                            if (controller.paidWithCashAdvance.value != null)
                              ElevatedButton(
                                onPressed: () {
                                  controller.paidWithCashAdvance.value = null;
                                  controller.paymentMethodeIDCashAdvance.value =
                                      null;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(60, 30),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.clear,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
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
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  final PhotoViewController _photoViewController = PhotoViewController();
  final controller = Get.find<Controller>();
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

  Future<void> _pickFile() async {
    print("PickSomethink");
    try {
      controller.isImageLoading.value = true;

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: controller.allowedExtensions,
      );

      if (result == null) return;

      for (final pickedFile in result.files) {
        if (pickedFile.path == null) continue;

        File file = File(pickedFile.path!);
        final ext = pickedFile.extension?.toLowerCase();

        /// ✅ IMAGE FLOW
        if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
          final croppedFile = await _cropImage(file);

          if (croppedFile != null) {
            final croppedImage = File(croppedFile.path);

            await _processSelectedFile(croppedImage);
          }
        }
        /// ✅ PDF / EXCEL / DOC FLOW
        else {
          await _processSelectedFile(file);
        }
      }
    } catch (e) {
      debugPrint("❌ File pick error: $e");
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<void> _processSelectedFile(File file) async {
    // ✅ Check feature states
    final featureStates = await controller.getAllFeatureStates();
    setState(() {
      controller.imageFiles.add(file);
    });
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
        Obx(() {
          return GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),

              /// ✅ EMPTY VIEW
              child: controller.imageFiles.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.tapToUploadDocs,
                      ),
                    )
                  /// ✅ FILE PREVIEW VIEW
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: controller.imageFiles.length,
                          onPageChanged: (index) {
                            controller.currentIndex.value = index;
                          },

                          itemBuilder: (_, index) {
                            final file = controller.imageFiles[index];
                            final path = file.path;

                            return GestureDetector(
                              onTap: () => controller.openFilewhileCreate(
                                context,
                                file,
                                index,
                              ),

                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(8),
                                ),

                                /// ✅ IMAGE
                                child: controller.isImage(path)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    /// ✅ PDF
                                    : controller.isPdf(path)
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.picture_as_pdf,
                                            size: 70,
                                            color: Colors.red,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              file.path.split('/').last,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      )
                                    /// ✅ EXCEL
                                    : controller.isExcel(path)
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.table_chart,
                                            size: 70,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            file.path.split('/').last,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    /// ✅ OTHER FILE
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file,
                                            size: 70,
                                          ),
                                          Text(
                                            file.path.split('/').last,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),

                        /// ✅ PAGE COUNT
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

                        /// ✅ ADD BUTTON
                        if (controller.isEnable.value)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: _pickFile,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          );
        }),
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
          child: Form(
            key: _formKey, // Add form key for validation
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
                        onPressed: _pickFile,
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
                        labelText:
                            '${AppLocalizations.of(context)!.totalEstimatedAmountInInr} ${controller.organizationCurrency}',
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
                        labelText:
                            '${AppLocalizations.of(context)!.totalRequestedAmountInINR} ${controller.organizationCurrency}',
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
                    Center(
                      child: Column(
                        children: [
                          // 🚨 Submit Button
                          Obx(() {
                            final isLoading =
                                controller.buttonLoaders['submit'] ?? false;

                            return CustomLoaderButton(
                              text: AppLocalizations.of(context)!.submit,
                              width: 300,
                              backgroundColor: AppColors.gradientEnd,
                              isLoading: isLoading,
                              disabled:
                                  controller.anyButtonLoading && !isLoading,
                              onPressed: () async {
                                if (!(_formKey.currentState?.validate() ??
                                    false))
                                  return;

                                controller.setButtonLoading('submit', true);
                                try {
                                  await controller.saveCashAdvance(
                                    context,
                                    true,
                                    false,
                                    null,
                                    null,
                                  );
                                } finally {
                                  controller.setButtonLoading('submit', false);
                                }
                              },
                            );
                          }),

                          const SizedBox(height: 20),

                          // 💾 Save & Cancel Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final isLoading =
                                      controller.buttonLoaders['save'] ?? false;

                                  return CustomLoaderButton(
                                    text: AppLocalizations.of(context)!.save,
                                    backgroundColor: const Color.fromARGB(
                                      241,
                                      20,
                                      94,
                                      2,
                                    ),
                                    isLoading: isLoading,
                                    disabled:
                                        controller.anyButtonLoading &&
                                        !isLoading,
                                    onPressed: () async {
                                      if (!(_formKey.currentState?.validate() ??
                                          false))
                                        return;

                                      controller.setButtonLoading('save', true);
                                      controller.isPageLoading.value = true;

                                      try {
                                        await controller.saveCashAdvance(
                                          context,
                                          false,
                                          false,
                                          null,
                                          null,
                                        );
                                      } finally {
                                        controller.setButtonLoading(
                                          'save',
                                          false,
                                        );
                                        controller.isPageLoading.value = false;
                                      }
                                    },
                                  );
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Obx(() {
                                  final isLoading =
                                      controller.buttonLoaders['cancel'] ??
                                      false;

                                  return CustomLoaderButton(
                                    text: AppLocalizations.of(context)!.cancel,
                                    backgroundColor: Colors.grey,
                                    isLoading: isLoading,
                                    disabled:
                                        controller.anyButtonLoading &&
                                        !isLoading,
                                    onPressed: () async {
                                      controller.setButtonLoading(
                                        'cancel',
                                        true,
                                      );
                                      controller.isPageLoading.value = true;

                                      try {
                                        controller.chancelButtonCA(context);
                                      } finally {
                                        controller.setButtonLoading(
                                          'cancel',
                                          false,
                                        );
                                        controller.isPageLoading.value = false;
                                      }
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Buttons

                    // Center(
                    //   child: Column(
                    //     children: [
                    //       Obx(() {
                    //         return GradientButton(
                    //           text: AppLocalizations.of(context)!.submit,
                    //           isLoading: controller.isGESubmitBTNLoading.value,
                    //           onPressed: () {
                    //             controller.saveCashAdvance(
                    //               context,
                    //               true,
                    //               false,
                    //               null,
                    //               null,
                    //             );
                    //           },
                    //         );
                    //       }),
                    //       // SizedBox(
                    //       //   width: 200,
                    //       //   height: 48,
                    //       //   child: ElevatedButton(
                    //       //     onPressed: () {
                    //       //       // Your action here
                    //       //     },
                    //       //     style: ElevatedButton.styleFrom(
                    //       //       padding: EdgeInsets.zero,
                    //       //       shape: RoundedRectangleBorder(
                    //       //         borderRadius: BorderRadius.circular(24),
                    //       //       ),
                    //       //       backgroundColor: Colors.transparent, // Important!
                    //       //       shadowColor: Colors.transparent,
                    //       //     ),
                    //       //     child: Ink(
                    //       //       decoration: BoxDecoration(
                    //       //         gradient: const LinearGradient(
                    //       //           colors: [Colors.indigo, Colors.blueAccent],
                    //       //         ),
                    //       //         borderRadius: BorderRadius.circular(24),
                    //       //       ),
                    //       //       child: Container(
                    //       //         alignment: Alignment.center,
                    //       //         child: const Text(
                    //       //           'Submit',
                    //       //           style: TextStyle(
                    //       //             color: Colors.white,
                    //       //             fontWeight: FontWeight.bold,
                    //       //           ),
                    //       //         ),
                    //       //       ),
                    //       //     ),
                    //       //   ),
                    //       // ),
                    //       const SizedBox(height: 20),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Obx(() {
                    //             return ElevatedButton(
                    //               onPressed: controller.isUploading.value
                    //                   ? null
                    //                   : () {
                    //                       controller.saveCashAdvance(
                    //                         context,
                    //                         false,
                    //                         false,
                    //                         null,
                    //                         null,
                    //                       );
                    //                     },
                    //               style: ElevatedButton.styleFrom(
                    //                 minimumSize: const Size(130, 50),
                    //                 backgroundColor: const Color.fromARGB(
                    //                   241,
                    //                   20,
                    //                   94,
                    //                   2,
                    //                 ),
                    //                 foregroundColor: Colors.white,
                    //                 padding: const EdgeInsets.symmetric(
                    //                   horizontal: 24,
                    //                   vertical: 12,
                    //                 ),
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //                 textStyle: const TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w500,
                    //                 ),
                    //               ),
                    //               child: controller.isUploading.value
                    //                   ? const SizedBox(
                    //                       width: 20,
                    //                       height: 20,
                    //                       child: CircularProgressIndicator(
                    //                         color: Colors.white,
                    //                         strokeWidth: 2,
                    //                       ),
                    //                     )
                    //                   : Text(AppLocalizations.of(context)!.save),
                    //             );
                    //           }),
                    //           const SizedBox(width: 10),
                    //           ElevatedButton(
                    //             style: ElevatedButton.styleFrom(
                    //               minimumSize: const Size(130, 50),
                    //               backgroundColor: Colors.grey,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //             ),
                    //             onPressed: () {
                    //               controller.chancelButton(context);
                    //             },
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(
                    //                 horizontal: 24,
                    //                 vertical: 12,
                    //               ),
                    //               child: Text(
                    //                 AppLocalizations.of(context)!.cancel,
                    //                 style: const TextStyle(
                    //                   letterSpacing: 1.5,
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
      ),
    );
  }
}
