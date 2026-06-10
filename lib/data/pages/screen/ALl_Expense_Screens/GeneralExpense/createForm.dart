// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/core/utils.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/l10n/app_localizations.dart';
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
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../service.dart';

class ExpenseCreationForm extends StatefulWidget {
  const ExpenseCreationForm({super.key});

  @override
  State<ExpenseCreationForm> createState() => _ExpenseCreationFormState();
}

class _ExpenseCreationFormState extends State<ExpenseCreationForm>
    with TickerProviderStateMixin {
  final controller = Get.find<Controller>();
  final controllerItems = Get.find<Controller>();
  // final _formKey = GlobalKey<FormState>();
  List<Controller> itemizeControllers = [];
  FocusNode selectMerchantFocusNode = FocusNode();
  late Future<Map<String, bool>> _featureFuture;
  int _currentStep = 0;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  int _selectedCategoryIndex = -1;
  // bool controller.showPaidForError.value = false;
  bool _showPaidWithError = false;
  // bool controller.showQuantityError.value = false;
  // bool controller.showUnitAmountError.value = false;
  bool _showUnitError = false;
  // bool controller.showProjectError.value = false;
  bool setQuality = true;
  bool clearField = false;
  bool allowMultSelect = false;
  bool allowCashAd = false;
  bool _showTaxAmountError = false;
  bool showItemizeDetails = false;
  bool _isTyping = false;
  late FocusNode _focusNode;
  String? _paidTo;
  bool? isThereReferenceID = false;
  String? paidToError;
  String? employeeError;
  String? expenseIdError;
  final RxnString paidwithError = RxnString();
  String? selectDate;
  String? selectReferenceIDError;
  final PageController _pageController = PageController();
  final Map<String, TextEditingController> fieldControllers = {};
  // final List<String> _titles = ["Payment Info", "Itemize", "Expense Details"];
  @override
  void initState() {
    super.initState();
    // controller.clearFormFields();
    _focusNode = FocusNode();
    // final now = DateTime.now().add(Duration(days: 1));
    // /// Convert using timezone method
    // final fromMs = toStartOfDayUtc(now);
    // controller.selectedDate ??= DateTime.fromMillisecondsSinceEpoch(
    //   fromMs,
    //   // isUtc: true,
    // );
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    final newController = Controller();
    if (controller.customFields.isNotEmpty) {
      newController.cloneCustomFieldsFromRx(controller.customFields);
    }
    itemizeControllers.add(newController);
    // controller.fetchPaidto();
    controller.split.clear();
    controller.accountingDistributions.clear();
    controller.isManualEntryMerchant = false;
    _loadSettings();

    _featureFuture = controller.getAllFeatureStates();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initializeUnits();
      await controller.fetchEmployeesID();
      // controller.employeeDropDownController.text = Params.employeeId;

      controller.loadSequenceModules();
      controller.configuration();
      controller.loadAllCustomFieldValues();
      controller.clearFormFields();
      // Safe to update observables here
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.getUserPref(context);

      controller.fetchExpenseCategory();
      loadAndAppendCashAdvanceList();
      controller.fetchExchangeRate();
    });
          print("Selected Timezone: ${controller.selectedTimezonevalue.value}");

  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // In your Controller class
  void updateItemizedAmounts(double rate) {
    for (var item in itemizeControllers) {
      final lineAmount = double.tryParse(item.lineAmount.text) ?? 0.0;
      final inrAmount = lineAmount * rate;
      item.lineAmountINR.text = inrAmount.toStringAsFixed(2);
    }
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
      allowCashAd = settings.allowCashAdvAgainstExpenseReg;
      print("allowDocAttachments$allowMultSelect");
      // isLoading = false;
    } else {
      // setState(() => isLoading = false);
    }
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();
      controller.cashAdvanceListDropDown.addAll(newItems); // ✅ Append here
      print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    } catch (e) {
      // Get.snackbar('Error', e.toString());
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

  bool _validateCurrentItemizeForm() {
    final currentController = itemizeControllers[_selectedItemizeIndex];
    bool isValid = true;

    // Reset all error states
    setState(() {
      currentController.showQuantityError.value = false;
      currentController.showUnitAmountError.value = false;
      _showUnitError = false;
      currentController.showTaxAmountError.value = false;
      currentController.showProjectError.value = false;
      currentController.showPaidForError.value = false;
      currentController.enableNextBtn.value = false;
      currentController.showTaxGroupError.value = false;
    });

    // 1. Validate Category (Paid For)
    if (currentController.selectedCategoryId.isEmpty) {
      setState(() => currentController.showPaidForError.value = true);
      isValid = false;
    }

    // 2. Validate Quantity
    if (currentController.quantity.text.isEmpty) {
      setState(() => currentController.showQuantityError.value = true);
      isValid = false;
    }

    // // 3. Validate Unit Amount
    // if (currentController.unitAmount.text.isEmpty) {
    //   setState(() => currentController.showUnitAmountError.value = true);
    //   isValid = false;
    // }
    if (currentController.unitAmount.text.isEmpty) {
      currentController.showUnitAmountError.value = true;
      currentController.unitAmountErrorText.value = AppLocalizations.of(
        context,
      )!.fieldRequired;
      isValid = false;
    } else {
      final value = double.tryParse(currentController.lineAmountINR.text);

      if (value == null || value <= 0) {
        currentController.showUnitAmountError.value = true;
        currentController.unitAmountErrorText.value = AppLocalizations.of(
          context,
        )!.enterValidAmount;
        isValid = false;
      } else {
        final min = currentController.minExpenseAmount.value;
        final max = currentController.maxExpenseAmount.value;
        final receiptLimit = controller.receiptRequiredLimit.value;
        controller.isReceiptRequired.value = receiptLimit < value;
        // if (receiptLimit > 0 && value >= receiptLimit) {
        //   controller.isReceiptRequired.value = true;
        // } else {
        //   controller.isReceiptRequired.value = false;
        // }
        if (value < min) {
          currentController.showUnitAmountError.value = true;
          currentController.unitAmountErrorText.value = AppLocalizations.of(
            context,
          )!.reportedAmountNotWithinRange;
          isValid = false;
        } else if (value > max && max != 0.0) {
          currentController.showUnitAmountError.value = true;
          currentController.unitAmountErrorText.value = AppLocalizations.of(
            context,
          )!.reportedAmountNotWithinRange;

          isValid = false;
        } else {
          // ✅ VALID
          currentController.showUnitAmountError.value = false;
          currentController.unitAmountErrorText.value = "";
        }
      }
    }
    // 4. Validate Unit
    if (currentController.selectedunit == null) {
      setState(() => _showUnitError = true);
      isValid = false;
    }

    // 5. Validate Tax Amount if mandatory
    final taxAmountMandatory = isFieldMandatory('Tax Amount');
    if (currentController.taxAmount.text.isEmpty && taxAmountMandatory) {
      setState(() => currentController.showTaxAmountError.value = true);
      isValid = false;
    }
    final taxGroupMandatory = isFieldMandatory('Tax Group');
    if (currentController.selectedTax == null && taxGroupMandatory) {
      setState(() => currentController.showTaxGroupError.value = true);
      isValid = false;
    }
    // 6. Validate Project if mandatory
    final projectIdMandatory = isFieldMandatory('Project Id');
    if (projectIdMandatory && currentController.selectedProject == null) {
      setState(() => currentController.showProjectError.value = true);
      isValid = false;
    }
    currentController.enableNextBtn.value = isValid;

    return isValid;
  }

  bool validateDropdowns() {
    final loc = AppLocalizations.of(context)!;
    bool isValid = true;

    // Validate Paid To
    if (!controller.isManualEntryMerchant &&
        controller.selectedPaidto == null) {
      setState(() {
        paidToError = loc.pleaseSelectMerchant;
      });
      isValid = false;
    } else if (controller.isManualEntryMerchant &&
        controller.manualPaidToController.text.trim().isEmpty) {
      setState(() {
        paidToError = loc.pleaseEnterMerchantName;
      });
      isValid = false;
    } else if (controller.employeeDropDownController.text.trim().isEmpty) {
      setState(() {
        employeeError = loc.fieldRequired;
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
    final hideField = controller.hasModule("Expense");

    if (!hideField) {
      if (controller.expenseIdController.text.trim().isEmpty) {
        setState(() {
          expenseIdError = loc.fieldRequired; // 🔥 create this variable
        });
        isValid = false;
      } else {
        setState(() {
          expenseIdError = null;
        });
      }
    }
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
        controller.selectedProject = null;
        for (var c in itemizeControllers) {
          c.expenseCategory.value = [];
        }
      });
      loadAndAppendCashAdvanceList();
      controller.fetchExpenseCategory();
      controller.fetchProjectName();
    }
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
      print("controller.unit${controller.selectedunit}");
      if (controller.selectedunit == null) {
        final defaultUnit = controller.unit.firstWhere(
          (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
          orElse: () => controller.unit.first,
        );
        setState(() {
          controller.selectedunit ??= defaultUnit;
          controller.selectedunit ??= defaultUnit;
        });
      }
    });
  }

  void _addItemize() {
    if (!showItemizeDetails) {
      print("Check$showItemizeDetails");
      setState(() {
        showItemizeDetails = true;
      });
    } else {
      if (_validateCurrentItemizeForm()) {
        if (_itemizeCount < 5) {
          setState(() {
            final newController = Controller();

            // ✅ IMPORTANT: Clone custom fields from the current controller
            final currentController = itemizeControllers[_selectedItemizeIndex];

            // Clone ExpenseTrans custom fields
            if (currentController.customFields.isNotEmpty) {
              newController.cloneCustomFieldsFromRx(
                currentController.customFields,
             
              );
            }

            // ✅ CRITICAL: Clone ExpenseCategories custom fields with their values
            if (currentController.customFieldsItems.isNotEmpty) {
              final clonedCategoryFields = currentController.customFieldsItems
                  .where((f) => f['ObjectName'] == 'ExpenseCategories')
                  .map((field) {
                    final Map<String, dynamic> cloned =
                        Map<String, dynamic>.from(field);
                    // Preserve all values
                    cloned['EnteredValue'] = field['EnteredValue'];
                    cloned['SelectedValue'] = field['SelectedValue'];
                    cloned['_rxStringValue'] = field['_rxStringValue'];
                    cloned['_rxCheckboxValue'] = field['_rxCheckboxValue'];
                    cloned['_rxDateValue'] = field['_rxDateValue'];
                    cloned['_rxIntValue'] = field['_rxIntValue'];
                    cloned['_rxDoubleValue'] = field['_rxDoubleValue'];
                    cloned['_rxSelectedValue'] = field['_rxSelectedValue'];
                    return cloned;
                  })
                  .toList();

              newController.customFieldsItems.addAll(clonedCategoryFields);
            }

            // Also clone the selected category ID
            newController.selectedCategoryId =
                currentController.selectedCategoryId;

            itemizeControllers.add(newController);
            _itemizeCount++;
            _selectedItemizeIndex = _itemizeCount - 1;
            showItemizeDetails = true;
          });
        }
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

  bool validateExpenseForm() {
    bool isValid = true;
    final controller = itemizeControllers[_selectedItemizeIndex];

    setState(() {
      // Reset all error states
      controller.showQuantityError.value = false;
      controller.showUnitAmountError.value = false;
      _showUnitError = false;
      controller.showTaxAmountError.value = false;
      controller.showPaidForError.value = false;
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
      controller.showTaxAmountError.value = true;
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
    final loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: _itemizeCount,
      initialIndex: _selectedItemizeIndex,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.secondary,
            isScrollable: true,
            onTap: (index) {
              if (_validateCurrentItemizeForm()) {
                setState(() {
                  _selectedItemizeIndex = index;
                });
              }
            },
            tabs: List.generate(
              _itemizeCount,
              (index) => Tab(text: "${loc.itemize} ${index + 1}"),
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

  /// Navigates to the invalid itemize tab and triggers its error UI
  void _navigateToInvalidItemize(int invalidIndex) {
    setState(() {
      _selectedItemizeIndex = invalidIndex; // ← switches the active tab
    });

    // Small delay to let the page rebuild before showing errors
    Future.delayed(const Duration(milliseconds: 100), () {
      final c = itemizeControllers[invalidIndex];

      // Trigger all error flags on the invalid page
      setState(() {
        if (c.selectedCategoryId.isEmpty) {
          c.showPaidForError.value = true;
        }
        if (c.quantity.text.isEmpty) {
          c.showQuantityError.value = true;
        }
        if (c.unitAmount.text.isEmpty) {
          c.showUnitAmountError.value = true;
          c.unitAmountErrorText.value = "Amount is required";
        }
        if (c.selectedunit == null) {
          _showUnitError = true;
        }
        if (isFieldMandatory('Tax Amount') && c.taxAmount.text.isEmpty) {
          c.showTaxAmountError.value = true;
        }
        if (isFieldMandatory('Project Id') && c.selectedProject == null) {
          c.showProjectError.value = true;
        }
      });

      Fluttertoast.showToast(
        msg: "Please fill all required fields in item ${invalidIndex + 1}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  /// Validates ALL itemize pages, returns index of first invalid one or -1
  int _getFirstInvalidItemizeIndex() {
    for (int i = 0; i < itemizeControllers.length; i++) {
      final c = itemizeControllers[i];

      // Check category
      if (c.selectedCategoryId.isEmpty) return i;

      // Check quantity
      if (c.quantity.text.isEmpty) return i;

      // Check unit amount
      if (c.unitAmount.text.isEmpty) return i;

      final value = double.tryParse(c.lineAmountINR.text);
      if (value == null || value <= 0) return i;

      // Check min/max range
      final min = c.minExpenseAmount.value;
      final max = c.maxExpenseAmount.value;
      if (value < min) return i;
      if (value > max && max != 0.0) return i;

      // Check unit
      if (c.selectedunit == null) return i;

      // Check tax amount if mandatory
      if (isFieldMandatory('Tax Amount') && c.taxAmount.text.isEmpty) return i;

      // Check project if mandatory
      if (isFieldMandatory('Project Id') && c.selectedProject == null) return i;
    }
    return -1; // ✅ All valid
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog
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
          controller.clearFormFields(); // ✅ Clear data only if user confirms
          controller.clearFormFieldsPerdiem();
          return true; // allow back navigation
        }

        return false; // stay on page
      },
      child: Scaffold(
        appBar: AppBar(title: Text(loc.generalExpenseForm)),
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
                  CreateExpensePage(backButton),
                ],
              ),
            ),
          ],
        ),
        // bottomNavigationBar: Row(
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
        //           label: Text(loc.back),
        //         ),
        //       if (_currentStep > 0)
        //         const SizedBox(height: 100)
        //       else
        //         const SizedBox(), // Empty space if back is not shown
        //     ],
        //   ),
      ),
    );
  }

  Widget expenseCreateForm2(BuildContext context, Controller controller) {
    final loc = AppLocalizations.of(context)!;
    if (controllerItems.unitRate.text != null) {
      final qty =
          double.tryParse(controllerItems.unitRate.text.toString()) ?? 0.0;
      final unit = double.tryParse(controller.unitAmount.text) ?? 0.0;
      final quantity = double.tryParse(controller.quantity.text) ?? 0.0;
      final calculatedLineAmount = qty * unit * quantity;
      controller.lineAmountINR.text = calculatedLineAmount.toStringAsFixed(2);
      print("lineAmountINR${controller.lineAmountINR.text}");
      print(
        "controllerItems.paidWithCashAdvance.value${controllerItems.paidWithCashAdvance.value}",
      );
    }
    final currentCustomFields = controller.customFieldsItems;

    // If this controller doesn't have its own custom fields yet,
    // initialize them from the master
    if (currentCustomFields.isEmpty && controller.customFields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.cloneCustomFieldsFromRx(controller.customFields);
      });
    }
    // if (controllerItems.paidWithCashAdvance.value == null ||
    //     controllerItems.paidWithCashAdvance.value!.isEmpty) {
    //   controller.isReimbursiteCreate.value = true;
    //   controllerItems.isReimbursableEnabled.value = true;
    // } else {
    //   controller.isReimbursiteCreate.value = false;
    //   // controllerItems.isReimbursableEnabled.value = false;
    // }

    // Use the provided controller parameter consistently
    controller.selectedunit ??= controllerItems.selectedunit;
    controller.selectedDate = controllerItems.selectedDate;
    // controller.isReimbursite.vale = true;
    print("selecteduni${controller.selectedunit}");
    if (setQuality) {
      if (controller.quantity.text.isEmpty) {
        controller.quantity.text = '1.00';
      }
    }
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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...controllerItems.configList
                  .where(
                    (field) =>
                        field['IsEnabled'] == true &&
                        field['FieldName'] != 'Location' &&
                        field['FieldName'] != 'Refrence Id' &&
                        field['FieldName'] != 'Is Billable' &&
                        field['FieldName'] != 'Is Reimbursible',
                  )
                  .map((field) {
                    final String label = field['FieldName'];
                    final bool isMandatory = field['IsMandatory'] ?? false;

                    Widget inputField;

                    if (label == 'Project Id') {
                      inputField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchableMultiColumnDropdownField<Project>(
                            labelText:
                                '${loc.projectId} ${isMandatory ? "*" : ""}',
                            columnHeaders: [loc.projectName, loc.projectId],
                            items: controllerItems.project,

                            controller: controller.projectDropDowncontroller,
                            selectedValue: controller.selectedProject,
                            searchValue: (proj) => '${proj.name} ${proj.code}',
                            displayText: (proj) => proj.code,
                            validator: (tax) =>
                                isMandatory &&
                                    controller
                                        .projectDropDowncontroller
                                        .text
                                        .isEmpty
                                ? loc.pleaseSelectProject
                                : null,
                            onChanged: (proj) {
                              if (proj == null) {
                                controller.fetchExpenseCategory();
                              }
                              setState(() {
                                controller.selectedProject = proj;
                                controllerItems.selectedProject = proj;
                                controller.projectDropDowncontroller.text =
                                    proj!.code;
                                // Clear validation error when a project is selected
                                if (proj != null) {
                                  controller.showProjectError.value = false;
                                }
                              });
                              controller.fetchExpenseCategory();
                            },
                            rowBuilder: (proj, searchQuery) {
                              // 🔍 Check if current row matches search query
                              bool isMatch = false;
                              if (searchQuery.isNotEmpty) {
                                final searchableText =
                                    '${proj.name} ${proj.code}'.toLowerCase();
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
                                    //  Expanded(
                                    //   // flex: 4,
                                    //   child: SingleChildScrollView(
                                    //     scrollDirection: Axis.horizontal,
                                    //     child: Text(
                                    //       '',
                                    //       style: const TextStyle(fontSize: 10),
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      // flex: 4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          proj.name,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      // flex: 3,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          proj.code,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (controller
                              .showProjectError
                              .value) // 👈 Show error below dropdown
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                loc.pleaseSelectProject,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    } else if (label == 'Tax Group') {
                      inputField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchableMultiColumnDropdownField<TaxGroupModel>(
                            labelText:
                                '${loc.taxGroup} ${isMandatory ? "*" : ""}',
                            columnHeaders: [loc.taxGroup, 'Tax ID'],
                            controller: controller.taxGroupController,
                            items: controllerItems.taxGroup,
                            selectedValue: controller.selectedTax,
                            searchValue: (tax) =>
                                '${tax.taxGroup} ${tax.taxGroupId}',
                            displayText: (tax) => tax.taxGroupId,
                            validator: (tax) =>
                                isMandatory &&
                                    controller.taxGroupController.text.isEmpty
                                ? 'Please select a Tax Group'
                                : null,
                            onChanged: (tax) {
                              setState(() {
                                controller.selectedTax = tax;
                                controller.taxGroupController.text =
                                    tax!.taxGroup;
                                controllerItems.selectedTax = tax;
                                if (tax != null) {
                                  controller.showTaxGroupError.value = false;
                                }
                              });
                            },
                            rowBuilder: (tax, searchQuery) {
                              // 🔍 Check if current row matches search query
                              bool isMatch = false;
                              if (searchQuery.isNotEmpty) {
                                final searchableText =
                                    '${tax.taxGroup} ${tax.taxGroupId}'
                                        .toLowerCase();
                                isMatch = searchableText.contains(
                                  searchQuery.toLowerCase(),
                                );
                              }

                              return Container(
                                // padding: const EdgeInsets.symmetric(
                                //   vertical: 12,
                                //   horizontal: 16,
                                // ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tax.taxGroup,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tax.taxGroupId,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (controller
                              .showTaxGroupError
                              .value) // 👈 Show error below dropdown
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                loc.pleaseSelectTaxGroup,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    } else if (label == 'Tax Amount') {
                      inputField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],
                            controller: controller.taxAmount,
                            onChanged: (tax) {
                              setState(() {
                                controller.taxAmount.text = tax;
                                controllerItems.taxAmount.text = tax;
                                // Clear error once the user starts typing
                                if (tax.isNotEmpty) {
                                  controller.showTaxAmountError.value = false;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          if (controller
                              .showTaxAmountError
                              .value) // 👈 Show error only when flag is true
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                loc.taxAmountRequired,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    } else {
                      inputField = TextField(
                        decoration: InputDecoration(
                          labelText: '$label${isMandatory ? " *" : ""}',
                          border: const OutlineInputBorder(),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        inputField,
                        const SizedBox(height: 16),
                        // const SizedBox(height: 20),
                      ],
                    );
                  })
                  .toList(),
          Obx(() {
  return Column(
    children: currentCustomFields.asMap().entries.map((entry) {
      final index = entry.key;
      final field = entry.value;

      final objectName = field['ObjectName'] ?? field['FR'] ?? '';
      final expenseType = field['ExpenseType'];

      final shouldShow =
          (objectName == 'ExpenseTrans' &&
              (expenseType == 'General Expenses' ||
                  expenseType == null)) ||
          (objectName == 'ExpenseCategories');

      if (!shouldShow) {
        return const SizedBox.shrink();
      }

      final String label = field['FieldLabel'] ?? field['FieldName'];
      final bool isMandatory = field['IsMandatory'] ?? false;
      final String fieldType = field['FieldType'];

      /// UNIQUE KEY FOR EVERY FIELD
      final String fieldKey =
          '${controller.hashCode}_${field['FieldName']}_${field['LineId'] ?? index}_${field['RecId'] ?? index}';

      Widget inputField;

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

        // Update controller text without triggering rebuild
        final newText = selectedValue?.valueName ?? 
                       field['DefaultValue']?.toString() ?? '';
        if (fieldController.text != newText) {
          fieldController.text = newText;
        }

        // If no matched selectedValue but DefaultValue exists
        if (selectedValue == null && field['DefaultValue'] != null) {
          selectedValue = CustomDropdownValue(
            valueId: field['DefaultValue'].toString(),
            valueName: field['DefaultValue'].toString(),
          );
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
          key: ValueKey('dropdown_$fieldKey'),
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
      // Date and DateTime types - Make Reactive
      else if (fieldType == 'Date' || fieldType == 'Date&Time') {
        final bool isDateTime = fieldType == 'Date&Time';

        // Create Rx value if not exists
        if (field['_rxDateValue'] == null) {
          field['_rxDateValue'] = Rx<DateTime?>(
            field['EnteredValue'] as DateTime?,
          );
        }

        // Create stable controller
        field['_dateController'] ??= TextEditingController();
        final dateController = field['_dateController'] as TextEditingController;

        inputField = Obx(() {
          final rxDateValue = field['_rxDateValue'] as Rx<DateTime?>;
          final currentDate = rxDateValue.value;

          // Update controller only if value changed
          String newText = '';
          if (currentDate != null) {
            if (isDateTime) {
              newText = DateFormat('dd/MM/yyyy hh:mm a').format(currentDate);
            } else {
              newText = DateFormat('dd/MM/yyyy').format(currentDate);
            }
          }
          if (dateController.text != newText) {
            dateController.text = newText;
          }

          return TextFormField(
            key: ValueKey('date_$fieldKey'),
            readOnly: true,
            controller: dateController,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: const OutlineInputBorder(),
              errorText: field['Error'],
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? currentDate = rxDateValue.value ?? DateTime.now();

              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate == null) return;

              if (isDateTime) {
                TimeOfDay initialTime = TimeOfDay.now();
                if (rxDateValue.value != null) {
                  initialTime = TimeOfDay.fromDateTime(rxDateValue.value!);
                }

                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );

                if (pickedTime == null) return;

                final fullDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                rxDateValue.value = fullDateTime;
                field['EnteredValue'] = fullDateTime;
              } else {
                rxDateValue.value = pickedDate;
                field['EnteredValue'] = pickedDate;
              }

              field['Error'] = null;
            },
            validator: (value) {
              if (isMandatory && rxDateValue.value == null) {
                return '$label is required';
              }
              return null;
            },
          );
        });
      }
      // LongInteger (Integer) type - Make Reactive
      else if (fieldType == 'LongInteger') {
        if (field['_rxIntValue'] == null) {
          field['_rxIntValue'] = Rx<int?>(
            field['EnteredValue'] as int?,
          );
        }

        // Create stable controller
        field['_intController'] ??= TextEditingController();
        final intController = field['_intController'] as TextEditingController;

        inputField = Obx(() {
          final rxValue = field['_rxIntValue'] as Rx<int?>;
          
          // Update controller without triggering rebuild
          final newText = rxValue.value?.toString() ?? '';
          if (intController.text != newText) {
            intController.text = newText;
          }

          // Remove old listener and add new one
          intController.removeListener(_getIntListener(field, rxValue, intController));
          intController.addListener(_getIntListener(field, rxValue, intController));

          return TextFormField(
            key: ValueKey('int_$fieldKey'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            controller: intController,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: const OutlineInputBorder(),
              errorText: field['Error'],
            ),
            validator: (value) {
              if (isMandatory && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              return null;
            },
          );
        });
      }
      // Decimal type - Make Reactive
      else if (fieldType == 'Decimal') {
        if (field['_rxDoubleValue'] == null) {
          field['_rxDoubleValue'] = Rx<double?>(
            field['EnteredValue'] as double?,
          );
        }

        // Create stable controller
        field['_doubleController'] ??= TextEditingController();
        final doubleController = field['_doubleController'] as TextEditingController;

        inputField = Obx(() {
          final rxValue = field['_rxDoubleValue'] as Rx<double?>;
          
          // Update controller without triggering rebuild
          final newText = rxValue.value?.toString() ?? '';
          if (doubleController.text != newText) {
            doubleController.text = newText;
          }

          // Remove old listener and add new one
          doubleController.removeListener(_getDoubleListener(field, rxValue, doubleController));
          doubleController.addListener(_getDoubleListener(field, rxValue, doubleController));

          return TextFormField(
            key: ValueKey('double_$fieldKey'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            controller: doubleController,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: const OutlineInputBorder(),
              errorText: field['Error'],
            ),
            validator: (value) {
              if (isMandatory && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              return null;
            },
          );
        });
      }
      // Email type - Make Reactive
      else if (fieldType == 'Email') {
        if (field['_rxStringValue'] == null) {
          field['_rxStringValue'] = Rx<String?>(
            field['EnteredValue'] as String?,
          );
        }

        // Create stable controller
        field['_emailController'] ??= TextEditingController();
        final emailController = field['_emailController'] as TextEditingController;

        inputField = Obx(() {
          final rxValue = field['_rxStringValue'] as Rx<String?>;
          
          // Update controller without triggering rebuild
          final newText = rxValue.value ?? '';
          if (emailController.text != newText) {
            emailController.text = newText;
          }

          // Remove old listener and add new one
          emailController.removeListener(_getStringListener(field, rxValue, emailController));
          emailController.addListener(_getStringListener(field, rxValue, emailController));

          return TextFormField(
            key: ValueKey('email_$fieldKey'),
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: const OutlineInputBorder(),
              errorText: field['Error'],
              suffixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (isMandatory && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              if (value != null && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Enter a valid email address';
                }
              }
              return null;
            },
          );
        });
      }
      // MobileNumber type - Make Reactive
      else if (fieldType == 'MobileNumber') {
        // Initialize persistent controllers and values if not exists
        if (field['_phoneController'] == null) {
          final defaultValue = field['DefaultValue']?.toString() ?? '';
          final existingValue = field['EnteredValue'] as String?;
          final initialValue = existingValue ?? defaultValue;

          // Parse existing phone number to extract country code and number
          String countryCode = '+91'; // Default India
          String phoneNumber = '';

          if (initialValue.isNotEmpty) {
            if (initialValue.startsWith('+')) {
              final RegExp regex = RegExp(r'^\+(\d+)\s*(.*)$');
              final match = regex.firstMatch(initialValue);
              if (match != null) {
                countryCode = '+${match.group(1)}';
                phoneNumber = match.group(2) ?? '';
              } else {
                phoneNumber = initialValue;
              }
            } else {
              phoneNumber = initialValue;
            }
          }

          // Create controllers
          field['_countryCodeController'] = TextEditingController(text: countryCode);
          field['_phoneController'] = TextEditingController(text: phoneNumber);
          field['_rxStringValue'] = Rx<String?>(initialValue);
          field['_focusNode'] = FocusNode();
          field['EnteredValue'] = initialValue;

          // Update EnteredValue when phone number changes
          field['_phoneController'].addListener(() {
            final phoneVal = field['_phoneController'].text;
            final codeVal = field['_countryCodeController'].text;
            final fullNumber = phoneVal.isNotEmpty ? '$codeVal $phoneVal' : '';

            if (fullNumber != field['_rxStringValue'].value) {
              field['_rxStringValue'].value = fullNumber;
              field['EnteredValue'] = fullNumber;
            }
            field['Error'] = null;
          });

          // Update EnteredValue when country code changes
          field['_countryCodeController'].addListener(() {
            final phoneVal = field['_phoneController'].text;
            final codeVal = field['_countryCodeController'].text;
            final fullNumber = phoneVal.isNotEmpty ? '$codeVal $phoneVal' : '';

            if (fullNumber != field['_rxStringValue'].value) {
              field['_rxStringValue'].value = fullNumber;
              field['EnteredValue'] = fullNumber;
            }
            field['Error'] = null;
          });
        }

        final phoneController = field['_phoneController'] as TextEditingController;
        final countryCodeController = field['_countryCodeController'] as TextEditingController;
        final focusNode = field['_focusNode'] as FocusNode;

        inputField = SizedBox(
          child: IntlPhoneField(
            key: ValueKey('phone_$fieldKey'),
            controller: phoneController,
            focusNode: focusNode,
            initialCountryCode: field['_selectedCountryCode'] ?? 'IN',
            onChanged: (phone) {
              countryCodeController.text = '+${phone.countryCode}';
              phoneController.text = phone.number;
            },
            onCountryChanged: (country) {
              countryCodeController.text = '+${country.dialCode}';
              field['_selectedCountryCode'] = country.code;
            },
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              errorText: field['Error'],
              counterText: "",
            ),
          ),
        );
      }
      // Default Text type - Make Reactive
      else {
        if (field['_rxStringValue'] == null) {
          field['_rxStringValue'] = Rx<String?>(
            field['EnteredValue'] as String?,
          );
        }

        // Create stable controller
        field['_textController'] ??= TextEditingController();
        final textController = field['_textController'] as TextEditingController;

        inputField = Obx(() {
          final rxValue = field['_rxStringValue'] as Rx<String?>;
          
          // Update controller without triggering rebuild
          final newText = rxValue.value ?? '';
          if (textController.text != newText) {
            textController.text = newText;
          }

          // Remove old listener and add new one
          textController.removeListener(_getStringListener(field, rxValue, textController));
          textController.addListener(_getStringListener(field, rxValue, textController));

          return TextFormField(
            key: ValueKey('text_$fieldKey'),
            enabled: controller.isEnable.value,
            keyboardType: TextInputType.text,
            controller: textController,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: const OutlineInputBorder(),
              errorText: field['Error'],
            ),
            validator: (value) {
              if (isMandatory && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              return null;
            },
          );
        });
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: inputField,
      );
    }).toList(),
  );
}),
              const SizedBox(height: 8),
              Text("${loc.paidFor} *"),
              const SizedBox(height: 20),
              if (controller.showPaidForError.value)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${loc.pleaseSelectCategory} ',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              Obx(() {
                final fetchCategory = (controller.expenseCategory.isNotEmpty)
                    ? controller.expenseCategory
                    : controllerItems.expenseCategory;
                if (fetchCategory.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noDataFound,
                      style: TextStyle(
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
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  if (showItemizeDetails)
                    SearchableMultiColumnDropdownField<Unit>(
                      labelText: '${loc.unit} *',
                      columnHeaders: [loc.uomId, loc.unitAmount],
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
                  const SizedBox(height: 16),
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
                              controllerItems.fetchExchangeRate();
                              controllerItems.unitAmount.text = value;
                              setState(() {
                                controller.unitAmount.text = value;
                                controller.showUnitAmountError.value = false;
                              });
                              final qty =
                                  double.tryParse(controller.quantity.text) ??
                                  0.0;
                              final unit =
                                  double.tryParse(controller.unitAmount.text) ??
                                  0.0;

                              final calculatedLineAmount = qty * unit;

                              controller.paidAmount.text = calculatedLineAmount
                                  .toStringAsFixed(2);
                              controllerItems.paidAmontIsEditable.value = false;
                              controller.lineAmount.text = calculatedLineAmount
                                  .toStringAsFixed(2);
                              controller.lineAmountINR.text =
                                  calculatedLineAmount.toStringAsFixed(2);
                            },
                            // onEditingComplete: () {
                            //   String text = controller.unitAmount.text;
                            //   double? value = double.tryParse(text);
                            //   if (value != null) {
                            //     controller.unitAmount.text = value.toStringAsFixed(2);
                            //     controller.paidAmount.text = value.toStringAsFixed(2);
                            //   }
                            // },
                            decoration: InputDecoration(
                              labelText: "${loc.unitAmount} *",
                              errorText: controller.showUnitAmountError.value
                                  ? ""
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // enabledBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        if (showItemizeDetails) const SizedBox(width: 12),
                        if (showItemizeDetails)
                          Expanded(
                            child: TextField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
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

                                final calculatedLineAmount = qty * unit;
                                print(
                                  "calculatedLineAmount: $qty x $unit = $calculatedLineAmount",
                                );

                                final unitRate =
                                    double.tryParse(
                                      controllerItems.unitRate.text.toString(),
                                    ) ??
                                    0.0;
                                final unitAmount = calculatedLineAmount;
                                final calculatedLineAmountWithRate =
                                    unitRate * unitAmount;
                                print(
                                  "calculatedLineAmount:${unitRate}.${unitAmount}",
                                );
                                controller.lineAmountINR.text =
                                    calculatedLineAmountWithRate
                                        .toStringAsFixed(2);

                                controller.paidAmount.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.paidAmontIsEditable.value = false;
                                controller.lineAmount.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.lineAmountINR.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                              },
                              decoration: InputDecoration(
                                labelText: "${loc.quantity}*",
                                errorText: controller.showQuantityError.value
                                    ? loc.quantityRequired
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // enabledBorder: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (showItemizeDetails)
                    Obx(
                      () => controller.showUnitAmountError.value
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                controller.unitAmountErrorText.value,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 8,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  if (showItemizeDetails) const SizedBox(height: 16),
                  if (showItemizeDetails)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            "${loc.lineAmount} *",
                            controller.lineAmount,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextInput(
                            "${loc.lineAmountInInr} ${controllerItems.organizationCurrency} *",
                            controller.lineAmountINR,
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  if (controller.lineAmount.text.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final double lineAmount =
                                double.tryParse(controller.lineAmount.text) ??
                                0.0;

                            // CRITICAL: Clear existing data properly
                            controller.split.clear();

                            // IMPORTANT: Remove duplicates from accountingDistributions
                            // This prevents the duplicate EMP001 issue
                            final uniqueDistributions =
                                <AccountingDistribution>[];
                            final seenDimensionValues = <String>{};

                            for (var dist
                                in controller.accountingDistributions) {
                              if (dist != null &&
                                  dist.dimensionValueId.isNotEmpty) {
                                // Split the dimensionValueId string and check for duplicates
                                final values = dist.dimensionValueId.split(',');
                                final uniqueValues = values.toSet().toList();
                                final cleanedValueId = uniqueValues.join(',');

                                if (!seenDimensionValues.contains(
                                  cleanedValueId,
                                )) {
                                  seenDimensionValues.add(cleanedValueId);
                                  uniqueDistributions.add(
                                    AccountingDistribution(
                                      transAmount: dist.transAmount,
                                      reportAmount: dist.reportAmount,
                                      allocationFactor: dist.allocationFactor,
                                      dimensionValueId: cleanedValueId,
                                    ),
                                  );
                                }
                              }
                            }

                            controller.accountingDistributions.clear();
                            controller.accountingDistributions.addAll(
                              uniqueDistributions,
                            );

                            if (controller.accountingDistributions.isNotEmpty) {
                              controller.split.assignAll(
                                controller.accountingDistributions.map((e) {
                                  return AccountingSplit(
                                    paidFor: e!.dimensionValueId,
                                    percentage: e.allocationFactor,
                                    amount: e.transAmount,
                                  );
                                }).toList(),
                              );
                            } else {
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
                                    splits: controller.split
                                        .map(
                                          (s) => AccountingSplit(
                                            paidFor: s.paidFor,
                                            percentage: s.percentage,
                                            amount: s.amount,
                                          ),
                                        )
                                        .toList(),
                                    lineAmount: lineAmount,
                                    isEnable: true,
                                    onChanged: (i, updatedSplit) {
                                      if (!mounted) return;
                                      controller.split[i] = updatedSplit;
                                    },
                                    onDistributionChanged: (newList) {
                                      if (!mounted) return;
                                      controller.accountingDistributions
                                          .clear();
                                      controller.accountingDistributions.addAll(
                                        newList,
                                      );

                                      controller.split.clear();
                                      controller.split.assignAll(
                                        newList.map(
                                          (e) => AccountingSplit(
                                            paidFor: e.dimensionValueId,
                                            percentage: e.allocationFactor,
                                            amount: e.transAmount,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(loc.accountDistribution),
                        ),
                      ],
                    ),
                  if (showItemizeDetails) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.totalAmount,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _calculateTotalLineAmount(
                              controller,
                            ).toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.comments,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 2),
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
                            loc.remove,
                            style: const TextStyle(
                              color: AppColors.gradientEnd,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      FutureBuilder<Map<String, bool>>(
                        future: _featureFuture,
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

                          if (!isEnabled) return const SizedBox.shrink();

                          return OutlinedButton.icon(
                            onPressed: () {
                              // Validate current form before adding new itemize
                              if (validateDropdowns()) {
                                _addItemize();
                              } else {
                                // Optional: Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loc.pleaseFillAllRequiredFields,
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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
                            label: Text(loc.itemize),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...controllerItems.configList
                      .where(
                        (field) =>
                            field['IsEnabled'] == true &&
                            field['FieldName'] != 'Location' &&
                            field['FieldName'] != 'Refrence Id' &&
                            field['FieldName'] != 'Tax Group' &&
                            field['FieldName'] != 'Tax Amount' &&
                            field['FieldName'] != 'Project Id',
                      )
                      .map((field) {
                        final String label = field['FieldName'];
                        final bool isMandatory = field['IsMandatory'] ?? false;

                        Widget inputField;

                        if (label == 'Is Billable') {
                          inputField = Obx(
                            () => SwitchListTile(
                              title: Text(
                                loc.isBillable,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: controllerItems.isBillable.value,
                              activeThumbColor: Colors.blue,
                              inactiveThumbColor: Colors.grey.shade400,
                              inactiveTrackColor: Colors.grey.shade300,
                              onChanged: (val) {
                                controller.isBillable.value = val;
                                controllerItems.isBillable.value = val;
                              },
                            ),
                          );
                        } else if (label == 'Is Reimbursible') {
                          inputField = Obx(() {
                            // ✅ Force value to false if not enabled
                            if (!controllerItems.isReimbursableEnabled.value &&
                                controller.isReimbursiteCreate.value) {
                              controller.isReimbursiteCreate.value = false;
                              controllerItems.isReimbursiteCreate.value = false;
                            }

                            return SwitchListTile(
                              title: Text(
                                loc.isReimbursable,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: controller.isReimbursiteCreate.value,
                              activeThumbColor: Colors.green,
                              inactiveThumbColor: Colors.grey.shade400,
                              inactiveTrackColor: Colors.grey.shade300,

                              onChanged:
                                  controllerItems.isReimbursableEnabled.value
                                  ? (val) {
                                      controller.isReimbursiteCreate.value =
                                          val;
                                      controllerItems
                                              .isReimbursiteCreate
                                              .value =
                                          val;
                                    }
                                  : null, // ✅ disabled when false
                            );
                          });
                        } else {
                          inputField = TextField(
                            decoration: InputDecoration(
                              labelText: '$label${isMandatory ? " *" : ""}',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const SizedBox(height: 8),
                            inputField,
                            // const SizedBox(height: 16),
                            // const SizedBox(height: 20),
                          ],
                        );
                      })
                      .toList(),

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
                            label: Text(loc.back),
                          )
                        else
                          const SizedBox(),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (showItemizeDetails) {
                              if (_validateCurrentItemizeForm()) {
                                // ✅ Step 1: Validate current page first
                                setState(() {
                                  controller.showQuantityError.value = false;
                                  controller.showUnitAmountError.value = false;
                                  _showUnitError = false;
                                  controller.showTaxAmountError.value = false;
                                });

                                bool isValid = true;

                                if (controller.selectedCategoryId.isEmpty) {
                                  setState(
                                    () => controller.showPaidForError.value =
                                        true,
                                  );
                                  isValid = false;
                                }

                                if (controller.quantity.text.isEmpty) {
                                  setState(
                                    () => controller.showQuantityError.value =
                                        true,
                                  );
                                  isValid = false;
                                }

                                if (controller.unitAmount.text.isEmpty) {
                                  controller.showUnitAmountError.value = true;
                                  controller.unitAmountErrorText.value =
                                      "Amount is required";
                                  isValid = false;
                                } else {
                                  final value = double.tryParse(
                                    controller.lineAmountINR.text,
                                  );
                                  if (value == null || value <= 0) {
                                    controller.showUnitAmountError.value = true;
                                    controller.unitAmountErrorText.value =
                                        "Enter valid amount";
                                    isValid = false;
                                  } else {
                                    final min =
                                        controller.minExpenseAmount.value;
                                    final max =
                                        controller.maxExpenseAmount.value;
                                    final receiptLimit = controllerItems
                                        .receiptRequiredLimit
                                        .value;
                                    controllerItems.isReceiptRequired.value =
                                        receiptLimit < value;

                                    if (value < min) {
                                      controller.showUnitAmountError.value =
                                          true;
                                      controller.unitAmountErrorText.value =
                                          AppLocalizations.of(
                                            context,
                                          )!.reportedAmountNotWithinRange;
                                      isValid = false;
                                    } else if (value > max && max != 0.0) {
                                      controller.showUnitAmountError.value =
                                          true;
                                      controller.unitAmountErrorText.value =
                                          AppLocalizations.of(
                                            context,
                                          )!.reportedAmountNotWithinRange;
                                      isValid = false;
                                    } else {
                                      controller.showUnitAmountError.value =
                                          false;
                                      controller.unitAmountErrorText.value = "";
                                    }
                                  }
                                }

                                if (controller.selectedunit == null) {
                                  setState(() => _showUnitError = true);
                                  isValid = false;
                                }

                                final taxAmountMandatory = isFieldMandatory(
                                  'Tax Amount',
                                );
                                if (controller.taxAmount.text.isEmpty &&
                                    taxAmountMandatory) {
                                  setState(
                                    () => controller.showTaxAmountError.value =
                                        true,
                                  );
                                  isValid = false;
                                }

                                final projectIdMandatory = isFieldMandatory(
                                  'Project Id',
                                );
                                if (projectIdMandatory &&
                                    controller.selectedProject == null) {
                                  setState(
                                    () => controller.showProjectError.value =
                                        true,
                                  );
                                  isValid = false;
                                } else {
                                  setState(
                                    () => controller.showProjectError.value =
                                        false,
                                  );
                                }

                                // ✅ Current page invalid → stop here
                                if (!isValid) return;

                                // ✅ Step 2: NOW validate ALL other itemize pages
                                final invalidIndex =
                                    _getFirstInvalidItemizeIndex();

                                if (invalidIndex != -1 &&
                                    invalidIndex != _selectedItemizeIndex) {
                                  // ❌ Another page has invalid fields → navigate to it
                                  _navigateToInvalidItemize(invalidIndex);
                                  return;
                                }

                                // ✅ Step 3: All pages valid → proceed
                                controllerItems.descriptionController.text =
                                    controller.descriptionController.text;

                                controllerItems.finalItems = itemizeControllers
                                    .map((c) => c.toExpenseItemModel())
                                    .toList();
                                _nextStep();
                                FocusScope.of(context).unfocus();
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Please check all Fields",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            } else {
                              // non-itemize path unchanged
                              if (validateExpenseForm()) {
                                setState(() {
                                  controller.showQuantityError.value = false;
                                  controller.showUnitAmountError.value = false;
                                  _showUnitError = false;
                                  controller.showTaxAmountError.value = false;
                                });

                                bool isValid = true;

                                if (controller.selectedCategoryId.isEmpty) {
                                  setState(
                                    () => controller.showPaidForError.value =
                                        true,
                                  );
                                  isValid = false;
                                }

                                if (_itemizeCount >= 1) {
                                  print(
                                    "controller.unitAmount.text${_itemizeCount}",
                                  );

                                  if (controller.quantity.text.isEmpty) {
                                    setState(
                                      () => controller.showQuantityError.value =
                                          true,
                                    );
                                    isValid = false;
                                  }
                                  if (showItemizeDetails) {
                                    if (controller.unitAmount.text.isEmpty) {
                                      controller.showUnitAmountError.value =
                                          true;
                                      controller.unitAmountErrorText.value =
                                          "Amount is required";
                                      isValid = false;
                                    } else {
                                      final value = double.tryParse(
                                        controller.lineAmountINR.text,
                                      );

                                      if (value == null || value <= 0) {
                                        controller.showUnitAmountError.value =
                                            true;
                                        controller.unitAmountErrorText.value =
                                            "Enter valid amount";
                                        isValid = false;
                                      } else {
                                        final min =
                                            controller.minExpenseAmount.value;
                                        final max =
                                            controller.maxExpenseAmount.value;

                                        if (value < min) {
                                          controller.showUnitAmountError.value =
                                              true;
                                          controller.unitAmountErrorText.value =
                                              "Amount should be ≥ $min";
                                          isValid = false;
                                        } else if (value > max && max != 0.0) {
                                          controller.showUnitAmountError.value =
                                              true;
                                          controller.unitAmountErrorText.value =
                                              "Amount should be ≤ $max";
                                          isValid = false;
                                        } else {
                                          // ✅ VALID
                                          controller.showUnitAmountError.value =
                                              false;
                                          controller.unitAmountErrorText.value =
                                              "";
                                        }
                                      }
                                    }
                                    if (controller.selectedunit == null) {
                                      setState(() => _showUnitError = true);
                                      isValid = false;
                                    }
                                  }
                                  final taxAmountMandatory = isFieldMandatory(
                                    'Tax Amount',
                                  );
                                  // Validate other mandatory fields
                                  if (controller.taxAmount.text.isEmpty &&
                                      taxAmountMandatory) {
                                    setState(
                                      () =>
                                          controller.showTaxAmountError.value =
                                              true,
                                    );
                                    isValid = false;
                                  }
                                }

                                // Validate Project Id if mandatory
                                final projectIdMandatory = isFieldMandatory(
                                  'Project Id',
                                );
                                controllerItems.descriptionController.text =
                                    controller.descriptionController.text;
                                print(
                                  "descriptionController${controller.descriptionController.text}",
                                );
                                print("projectIdMandatory$projectIdMandatory");
                                print(
                                  "projectIdMandatory${controller.selectedProject == null}",
                                );
                                if (projectIdMandatory &&
                                    controller.selectedProject == null) {
                                  setState(
                                    () => controller.showProjectError.value =
                                        true,
                                  );
                                  isValid = false;
                                } else {
                                  setState(
                                    () => controller.showProjectError.value =
                                        false,
                                  );
                                }

                                if (controller.itemisationMandatory.value &&
                                    !showItemizeDetails) {
                                  Fluttertoast.showToast(
                                    msg: "Itemize is required",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return;
                                }
                                print('isValid$isValid');
                                print('isValid${itemizeControllers.length}');
                                if (isValid) {
                                  if (showItemizeDetails) {
                                    controllerItems.finalItems =
                                        itemizeControllers
                                            .map((c) => c.toExpenseItemModel())
                                            .toList();
                                    _nextStep();
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    _nextStep();
                                    FocusScope.of(context).unfocus();
                                  }
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Please check all Field",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
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
                            _currentStep == 2 ? loc.finish : loc.next,
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
        double.tryParse(controllers.lineAmount.text) ?? 0.0;
    total += currentLineAmount;

    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
        total += amount;
      }
    }
    controller.paidAmount.text = total.toString();
    print("totaltotal$total");
    return total;
  }
// Helper method for String fields
VoidCallback _getStringListener(
  Map<String, dynamic> field,
  Rx<String?> rxValue,
  TextEditingController controller,
) {
  return () {
    final value = controller.text;
    if (value != rxValue.value) {
      rxValue.value = value;
      field['EnteredValue'] = value;
      field['Error'] = null;
    }
  };
}

// Helper method for Integer fields
VoidCallback _getIntListener(
  Map<String, dynamic> field,
  Rx<int?> rxValue,
  TextEditingController controller,
) {
  return () {
    final value = controller.text;
    if (value.isEmpty) {
      if (rxValue.value != null) {
        rxValue.value = null;
        field['EnteredValue'] = null;
      }
    } else {
      final intValue = int.tryParse(value);
      if (intValue != rxValue.value) {
        rxValue.value = intValue;
        field['EnteredValue'] = intValue;
      }
    }
    field['Error'] = null;
  };
}

// Helper method for Double fields
VoidCallback _getDoubleListener(
  Map<String, dynamic> field,
  Rx<double?> rxValue,
  TextEditingController controller,
) {
  return () {
    final value = controller.text;
    if (value.isEmpty) {
      if (rxValue.value != null) {
        rxValue.value = null;
        field['EnteredValue'] = null;
      }
    } else {
      final doubleValue = double.tryParse(value);
      if (doubleValue != rxValue.value) {
        rxValue.value = doubleValue;
        field['EnteredValue'] = doubleValue;
      }
    }
    field['Error'] = null;
  };
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

    // 🔒 Static cache for base64-decoded images
    final Map<String, Uint8List> _base64Cache = {};

    Widget _buildIcon(String? icon) {
      const fallbackUrl =
          "https://icons.veryicon.com/png/o/commerce-shopping/icon-of-lvshan-valley-mobile-terminal/home-category.png";

      try {
        if (icon != null && icon.isNotEmpty) {
          if (icon.startsWith('data:image')) {
            final base64Str = icon.split(',').last;
            if (!_base64Cache.containsKey(base64Str)) {
              _base64Cache[base64Str] = base64Decode(base64Str);
            }
            return Image.memory(
              _base64Cache[base64Str]!,
              width: 30,
              height: 30,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(icon)) {
            if (!_base64Cache.containsKey(icon)) {
              _base64Cache[icon] = base64Decode(icon);
            }
            return Image.memory(
              _base64Cache[icon]!,
              width: 30,
              height: 30,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else {
            return Image.asset(
              icon,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          }
        }
      } catch (_) {}

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
        controllers.showPaidForError.value = false;
        controllers.selectedCategoryId = item.categoryId;
        controller.selectedCategoryId = item.categoryId;
        controller.categoryController.text = item.categoryId;

        // ✅ FIX: Load custom fields with DefaultValue for this specific controller
        if (item.customFields != null && item.customFields!.isNotEmpty) {
          final categoryFields = item.customFields!.map((f) {
            final Map<String, dynamic> field = Map<String, dynamic>.from(f);
            field['ObjectName'] = 'ExpenseCategories';
            field['ExpenseType'] = 'General Expenses';

            // ✅ CRITICAL: Set Default Value properly
            final defaultVal = field['DefaultValue']?.toString() ?? '';

            // Store the actual entered value separately
            field['EnteredValue'] = defaultVal;

            // For dropdown/list types, store selected value separately
            if (field['FieldType'] == 'List' ||
                field['FieldType'] == 'CustomList' ||
                field['FieldType'] == 'SystemList') {
              // Find the matching option from Options list
              final options = field['Options'] as List<CustomDropdownValue>?;
              CustomDropdownValue? matchedOption;
              if (options != null && defaultVal.isNotEmpty) {
                matchedOption = options.firstWhere(
                  (opt) =>
                      opt.valueName == defaultVal || opt.valueId == defaultVal,
                  // orElse: () => null,
                );
              }
              field['SelectedValue'] = matchedOption;
            }

            field['_rxStringValue'] = Rx<String?>(defaultVal);
            field['Error'] = null;
            return field;
          }).toList();

          // ✅ Remove old category fields and add new ones for THIS controller only
          controllers.customFieldsItems.removeWhere(
            (f) => f['ObjectName'] == 'ExpenseCategories',
          );
          controllers.customFieldsItems.addAll(categoryFields);
          controllers.customFieldsItems.refresh();
        } else {
          // ✅ Clear category fields if category has none
          controllers.customFieldsItems.removeWhere(
            (f) => f['ObjectName'] == 'ExpenseCategories',
          );
          controllers.customFieldsItems.refresh();
        }

        if (item.itemisationMandatory && showItemizeDetails == false) {
          _addItemize();
        }
        controllers.itemisationMandatory.value = item.itemisationMandatory;
        controller.minExpenseAmount.value = (item.minExpensesAmount ?? 0)
            .toDouble();
        controller.receiptRequiredLimit.value = (item.receiptRequiredLimit ?? 0)
            .toDouble();
        controller.maxExpenseAmount.value = (item.maxExpenseAmount ?? 0)
            .toDouble();
        controllers.minExpenseAmount.value = (item.minExpensesAmount ?? 0)
            .toDouble();
        controllers.maxExpenseAmount.value = (item.maxExpenseAmount ?? 0)
            .toDouble();
        controllers.receiptRequiredLimit.value =
            (item.receiptRequiredLimit ?? 0).toDouble();
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
            AnimatedOpacity(
              opacity: _isTyping ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: _buildIcon(icon),
            ),
            const SizedBox(height: 8),
            Text(
              item.categoryId,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget expenseCreationFormStep1(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Obx(() {
        return controller.isLoadingGE2.value
            ? const SkeletonLoaderPage()
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus(); // Hide keyboard
                },
                behavior:
                    HitTestBehavior.opaque, // Ensures taps outside are detected
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    // key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        FormField<DateTime>(
                          validator: (value) {
                            if (controller.selectedDate == null) {
                              return loc.pleaseSelectRequestDate;
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
                                    "Expense",
                                  );

                                  if (hideField) {
                                    return const SizedBox.shrink(); // ✅ hide
                                  }

                                  return Column(
                                    children: [
                                      TextFormField(
                                        controller:
                                            controller.expenseIdController,
                                        decoration: InputDecoration(
                                          labelText: '${loc.expenseId} *',
                                          errorText: expenseIdError,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }),

                                InkWell(
                                  onTap: () async {
                                    await _selectDate(context);
                                    field.didChange(controller.selectedDate);
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: '${loc.receiptDate} *',
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
                                              ? loc.selectDate
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
                          SearchableMultiColumnDropdownField<EmployeeId>(
                            labelText: '${loc.employeeId} *',
                            columnHeaders: [loc.employeeName, loc.employeeId],
                            items: controller.employeesID,
                            controller: controller.employeeDropDownController,
                            selectedValue: controller.selectedEmployeeID.value,
                            searchValue: (emp) =>
                                '${emp.employeeName} ${emp.employeeId}',
                            displayText: (emp) => emp.employeeId,
                            validator: (emp) =>
                                controller
                                    .employeeDropDownController
                                    .text
                                    .isEmpty
                                ? loc.fieldRequired
                                : null,
                            onChanged: (emp) {
                              if (emp == null) {
                                controller.fetchEmployees();
                              }
                              setState(() {
                                controller.selectedEmployeeID.value = emp;
                                controller.employeeName.text =
                                    emp?.employeeName ?? '';
                                controller.employeeDropDownController.text =
                                    emp!.employeeId;
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
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          emp.employeeId,
                                          style: const TextStyle(fontSize: 10),
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
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              bottom: 8,
                            ),
                            child: Text(
                              employeeError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Paid To Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${loc.paidTo} *',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        controller.isManualEntryMerchant =
                                            !controller.isManualEntryMerchant;
                                        if (controller.isManualEntryMerchant) {
                                          controller.selectedPaidto = null;
                                        } else {
                                          controller.manualPaidToController
                                              .clear();
                                          // Move focus to the Select Merchant dropdown
                                          // selectMerchantFocusNode.requestFocus();
                                        }
                                        paidToError = null;
                                      });
                                    },
                                    child: Text(
                                      controller.isManualEntryMerchant
                                          ? loc.selectFromMerchantList
                                          : loc.enterMerchantManually,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // 👇 Conditional UI
                            if (!controller.isManualEntryMerchant)
                              SearchableMultiColumnDropdownField<MerchantModel>(
                                labelText: loc.selectMerchant,
                                columnHeaders: [
                                  loc.merchantName,
                                  loc.merchantId,
                                ],
                                items: controller.paidTo,
                                selectedValue: controller.selectedPaidto,
                                searchValue: (p) =>
                                    '${p.merchantNames} ${p.merchantId}',
                                displayText: (p) => p.merchantNames,
                                validator: (_) => null,
                                onChanged: (p) {
                                  setState(() {
                                    controller.selectedPaidto = p;
                                    paidToError = null;
                                  });
                                },
                                rowBuilder: (p, searchQuery) {
                                  // 🔍 Determine if this row matches the search query
                                  bool isMatch = false;
                                  if (searchQuery.isNotEmpty) {
                                    final searchableText =
                                        '${p.merchantNames} ${p.merchantId}'
                                            .toLowerCase();
                                    isMatch = searchableText.contains(
                                      searchQuery.toLowerCase(),
                                    );
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p.merchantNames,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            p.merchantId,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              TextFormField(
                                controller: controller.manualPaidToController,
                                decoration: InputDecoration(
                                  labelText: loc.enterMerchantName,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    paidToError = null;
                                  });
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
                                      field['ObjectName'] == 'ExpenseHeader' &&
                                      field['ExpenseType'] ==
                                          'General Expenses',
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
                                                      child: Text(
                                                        val.valueName,
                                                      ),
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
                                                    field['EnteredValue'] !=
                                                        null
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
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      initialValue:
                                          field['EnteredValue']?.toString() ??
                                          '',
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
                                          field['EnteredValue']?.toString() ??
                                          '',
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
                        // Reference ID Field
                        Obx(() {
                          return Column(
                            children: controller.configList
                                .where(
                                  (field) =>
                                      field['IsEnabled'] == true &&
                                      field['FieldName'] == 'Refrence Id',
                                )
                                .map((field) {
                                  final String label = loc.referenceId;
                                  final bool isMandatory =
                                      field['IsMandatory'] ?? false;
                                  isThereReferenceID =
                                      field['IsMandatory'] ?? false;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      FormField<String>(
                                        validator: (value) {
                                          if (isMandatory &&
                                              (value == null ||
                                                  value.isEmpty)) {
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
                                                  // field.didChange(value);
                                                  selectReferenceIDError = null;
                                                },
                                                decoration: InputDecoration(
                                                  labelText:
                                                      '$label${isMandatory ? " *" : ""}',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
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
                        if (allowCashAd) const SizedBox(height: 14),
                        if (allowCashAd)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MultiSelectMultiColumnDropdownField<
                                CashAdvanceDropDownModel
                              >(
                                labelText: loc.cashAdvanceRequest,
                                controller: controller.cashAdvanceIds,
                                items: controller.cashAdvanceListDropDown,
                                isMultiSelect: allowMultSelect ?? false,
                                selectedValue: controller.singleSelectedItem,
                                selectedValues: controller.multiSelectedItems,
                                dropdownMaxHeight: 300,
                                // selectedValue: controller.selectedLocation,
                                // enabled: controller.isEditModePerdiem,
                                // controller: controller.locationController,
                                // ignore: unnecessary_string_interpolations
                                searchValue: (proj) =>
                                    '${proj.cashAdvanceReqId}',
                                displayText: (proj) => proj.cashAdvanceReqId,
                                validator: (proj) => proj == null
                                    ? loc.pleaseSelectCashAdvanceField
                                    : null,
                                onChanged: (item) {
                                  controller.singleSelectedItem = item;
                                },
                                onMultiChanged: (items) {
                                  controller.multiSelectedItems.assignAll(
                                    items,
                                  );
                                },
                                columnHeaders: [loc.requestId, loc.requestDate],
                                rowBuilder: (proj, searchQuery) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(proj.cashAdvanceReqId),
                                        ),
                                        Expanded(
                                          child: Text(
                                            controller.formattedDate(
                                              proj.requestDate,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // if (selectReferenceIDError != null)
                              //   Padding(
                              //     padding: const EdgeInsets.only(
                              //       left: 8.0,
                              //       bottom: 8,
                              //     ),
                              //     child: Text(
                              //       selectReferenceIDError.toString(),
                              //       style: const TextStyle(color: Colors.red),
                              //     ),
                              //   ),
                            ],
                          ),
                        const SizedBox(height: 14),
                        Text(
                          loc.paidWith,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),

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
                              ...List.generate(
                                controller.paymentMethods.length,
                                (index) {
                                  final method =
                                      controller.paymentMethods[index];
                                  final defaultMethod = controller
                                      .paymentMethods
                                      .firstWhereOrNull(
                                        (method) =>
                                            method.paymentMethodId ==
                                            controller
                                                .paidWithCashAdvance
                                                .value,
                                      );

                                  if (defaultMethod != null) {
                                    controller
                                            .paymentMethodeIDCashAdvance
                                            .value =
                                        defaultMethod.paymentMethodId;
                                    controller.isReimbursableEnabled.value =
                                        defaultMethod.reimbursible;
                                    controllerItems.isReimbursiteCreate.value =
                                        defaultMethod.reimbursible;
                                  }
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
                                      // ignore: deprecated_member_use
                                      groupValue:
                                          controller.paidWithCashAdvance.value,

                                      onChanged: (value) {
                                        if (controller
                                                .paidWithCashAdvance
                                                .value ==
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
                                          controller
                                                  .isReimbursableEnabled
                                                  .value =
                                              method.reimbursible;
                                          controllerItems
                                                  .isReimbursiteCreate
                                                  .value =
                                              method.reimbursible;
                                          ;
                                        }
                                      },

                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              /// ✅ CLEAR BUTTON
                              if (controllerItems.paidWithCashAdvance.value ==
                                      null ||
                                  controllerItems
                                      .paidWithCashAdvance
                                      .value!
                                      .isEmpty)
                                ElevatedButton(
                                  onPressed: () {
                                    controller.paidWithCashAdvance.value = null;
                                    controller
                                            .paymentMethodeIDCashAdvance
                                            .value =
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
                                  icon: const Icon(Icons.arrow_back),
                                  label: Text(loc.back),
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
                                    FocusScope.of(context).unfocus();
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
                                  _currentStep == 2 ? loc.finish : loc.next,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
      }),
    );
  }
}

class CreateExpensePage extends StatefulWidget {
  final VoidCallback backButton;
  CreateExpensePage(this.backButton, {super.key});

  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  // bool controller._isVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitAttempted = false;
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
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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
      // controller.imageFiles.add(croppedImage);

      // ✅ Check feature states before deciding what to do next
      final featureStates = await controller.getAllFeatureStates();

      return croppedImage;
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

  void _showFilePreview(File file, int index) {
    final path = file.path.toLowerCase();
    final isImage = controller.isImage(path);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              /// ✅ FILE PREVIEW
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: isImage
                      /// IMAGE ZOOM VIEW
                      ? PhotoView(
                          imageProvider: FileImage(file),
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        )
                      /// PDF / DOC / EXCEL VIEW
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.isPdf(path)
                                  ? Icons.picture_as_pdf
                                  : controller.isExcel(path)
                                  ? Icons.table_chart
                                  : Icons.insert_drive_file,
                              size: 90,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              file.path.split('/').last,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),

              /// ✅ CLOSE BUTTON
              Positioned(
                top: 30,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              /// ✅ ACTION BUTTONS
              if (controller.isEnable.value)
                Positioned(
                  top: 90,
                  right: 20,
                  child: Column(
                    children: [
                      /// ✅ OPEN FILE
                      FloatingActionButton.small(
                        heroTag: "open_$index",
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.open_in_new),
                        onPressed: () {
                          Navigator.pop(context);
                          controller.openFile(context, file, index);
                        },
                      ),

                      const SizedBox(height: 12),

                      if (isImage)
                        FloatingActionButton.small(
                          heroTag: "edit_$index",
                          backgroundColor: Colors.deepPurple,
                          child: const Icon(Icons.edit),
                          onPressed: () async {
                            final cropped = await _cropImage(file);

                            if (cropped != null) {
                              controller.imageFiles[index] = cropped;

                              Navigator.pop(context);

                              _showFilePreview(cropped, index);
                            }
                          },
                        ),

                      const SizedBox(height: 12),

                      /// ✅ DELETE
                      FloatingActionButton.small(
                        heroTag: "delete_$index",
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.delete),
                        onPressed: () {
                          Navigator.pop(context);

                          controller.imageFiles.removeAt(index);
                        },
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Add form key for validation
            child: Column(
              children: [
                _buildImageArea(),
                const SizedBox(height: 20),

                // Upload & Capture Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(loc.upload),
                      onPressed: _pickFile,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(loc.capture),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paid Amount + Currency + Rate
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.paidAmount,
                            enabled: controller.paidAmontIsEditable.value,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],

                            decoration: InputDecoration(
                              labelText: '${loc.paidAmount} *',
                              errorStyle: const TextStyle(height: 0),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            validator: (value) {
                              controller.paidAmountError.value = ''; // reset

                              if (value == null || value.trim().isEmpty) {
                                controller.paidAmountError.value =
                                    loc.paidAmountRequired;
                                return '';
                              }

                              final parsed = double.tryParse(
                                controller.amountINR.text,
                              );
                              if (parsed == null || parsed <= 0) {
                                controller.paidAmountError.value =
                                    loc.enterValidAmount;
                                return '';
                              }
                              print("itemizw${controller.finalItems.length}");
                              final min = controller.minExpenseAmount.value;
                              final max = controller.maxExpenseAmount.value;
                              final receiptLimit =
                                  controller.receiptRequiredLimit.value;

                              if (parsed < min &&
                                  controller.finalItems.length <= 1) {
                                controller.paidAmountError.value =
                                    AppLocalizations.of(
                                      context,
                                    )!.reportedAmountNotWithinRange;
                                return '';
                              }

                              if (parsed > max &&
                                  controller.finalItems.length <= 1 &&
                                  max != 0.0) {
                                controller.paidAmountError.value =
                                    AppLocalizations.of(
                                      context,
                                    )!.reportedAmountNotWithinRange;
                                ;
                                return '';
                              }
                              controller.isReceiptRequired.value =
                                  receiptLimit < parsed;
                              print("isReceiptRequired${receiptLimit}");
                              return null;
                            },
                            onChanged: (_) {
                              final paid =
                                  double.tryParse(controller.paidAmount.text) ??
                                  0.0;
                              final rate = double.tryParse(
                                controller.unitRate.text,
                              );
                              if (rate != null) {
                                final result = paid * rate;
                                controller.amountINR.text = result
                                    .toStringAsFixed(2);
                                controller.isVisible.value = true;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            return SearchableMultiColumnDropdownField<Currency>(
                              alignLeft: -110,
                              dropdownWidth: 400,
                              labelText: "${loc.currency} *",
                              columnHeaders: [
                                '${loc.code} ',
                                '${loc.name} ',
                                '${loc.symbol} ',
                              ],
                              items: controller.currencies,
                              selectedValue: controller.selectedCurrency.value,
                              backgroundColor: const Color.fromARGB(
                                255,
                                22,
                                2,
                                92,
                              ),
                              searchValue: (c) =>
                                  '${c.code} ${c.name} ${c.symbol}',
                              displayText: (c) => c.code,
                              inputDecoration: const InputDecoration(
                                suffixIcon: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    Icons.arrow_drop_down_outlined,
                                    size: 20,
                                  ),
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minHeight: 55,
                                  minWidth: 30,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 18,
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(55, 5, 23, 128),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0),
                                    bottomLeft: Radius.circular(0),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              validator: (c) =>
                                  c == null ? loc.pleaseSelectCurrency : null,
                              onChanged: (c) {
                                controller.selectedCurrency.value = c;
                                controller.currencyDropDowncontroller.text =
                                    c!.code;
                                controller.fetchExchangeRate();
                              },
                              controller: controller.currencyDropDowncontroller,
                              rowBuilder: (c, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(c.code)),
                                      Expanded(child: Text(c.name)),
                                      Expanded(child: Text(c.symbol)),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: controller.unitRate,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: '${loc.rate} *',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc.rateRequired;
                              }
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return loc.enterValidRate;
                              }
                              return null;
                            },
                            onChanged: (val) {
                              final paid =
                                  double.tryParse(controller.paidAmount.text) ??
                                  0.0;
                              final rate = double.tryParse(val) ?? 1.0;
                              controller.rate = rate.toInt();
                              final result = paid * rate;
                              controller.amountINR.text = result
                                  .toStringAsFixed(2);
                              controller.isVisible.value = true;
                            },
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.paidAmountError.value.isEmpty) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(left: 0, top: 6),
                        child: Text(
                          controller.paidAmountError.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 8,
                          ),
                        ),
                      );
                    }),
                    // Account Distribution Button
                    Obx(() {
                      return Column(
                        children: [
                          if (controller.isVisible.value &&
                              controller.paidAmontIsEditable.value)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    final double lineAmount =
                                        double.tryParse(
                                          controller.paidAmount.text,
                                        ) ??
                                        0.0;
                                    if (controller.split.isEmpty &&
                                        controller
                                            .accountingDistributions
                                            .isNotEmpty) {
                                      controller.split.assignAll(
                                        controller.accountingDistributions.map((
                                          e,
                                        ) {
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
                                    print(lineAmount);
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
                                              controller.split[i] =
                                                  updatedSplit;
                                            },
                                            onDistributionChanged: (newList) {
                                              if (!mounted) return;

                                              // 🔥 Print each item in newList for debugging
                                              for (var dist in newList) {
                                                print("onDistributionChanged:");
                                                print(
                                                  "  TransAmount: ${dist.transAmount}",
                                                );
                                                print(
                                                  "  ReportAmount: ${dist.reportAmount}",
                                                );
                                                print(
                                                  "  AllocationFactor: ${dist.allocationFactor}",
                                                );
                                                print(
                                                  "  DimensionValueId: ${dist.dimensionValueId}",
                                                );
                                              }

                                              controller.accountingDistributions
                                                  .clear();
                                              controller.accountingDistributions
                                                  .addAll(newList);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(loc.accountDistribution),
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),
                        ],
                      );
                    }),

                    // Amount in INR (readonly)
                    TextFormField(
                      controller: controller.amountINR,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText:
                            '${loc.amountInInr} ${controller.organizationCurrency} *',
                        filled: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Policy Violations
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       loc.policyViolations,
                    //       style: const TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //     Text(
                    //       loc.checkPolicies,
                    //       style: const TextStyle(color: Colors.blue),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 12),
                    // _buildPolicyCard(),
                    // const SizedBox(height: 40),

                    // Buttons: Submit, Save, Cancel
                    Center(
                      child: Column(
                        children: [
                          // 🚨 Submit Button
                          Obx(() {
                            bool isSubmitLoading =
                                controller.buttonLoaders['submit'] ?? false;
                            bool isSaveLoading =
                                controller.buttonLoaders['save'] ?? false;
                            bool isCancelLoading =
                                controller.buttonLoaders['cancel'] ?? false;
                            bool isAnyLoading = controller.buttonLoaders.values
                                .any((loading) => loading);

                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                    (isSubmitLoading ||
                                        isSaveLoading ||
                                        isCancelLoading ||
                                        isAnyLoading)
                                    ? null
                                    : () async {
                                        _isSubmitAttempted = true;
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          if (controller
                                                  .isReceiptRequired
                                                  .value &&
                                              controller.imageFiles.isEmpty) {
                                            Fluttertoast.showToast(
                                              msg: "Receipt is required",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );

                                            return; // 🚨 STOP SUBMIT
                                          }

                                          controller.setButtonLoading(
                                            'submit',
                                            true,
                                          );
                                          try {
                                            await controller.saveGeneralExpense(
                                              context,
                                              true,
                                              false,
                                            );
                                          } finally {
                                            controller.setButtonLoading(
                                              'submit',
                                              false,
                                            );
                                          }
                                        } else {
                                          setState(
                                            () {},
                                          ); // Refresh UI for inline errors
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    26,
                                    2,
                                    110,
                                  ),
                                ),
                                child: isSubmitLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        loc.submit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          // 💾 Save & Cancel Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Obx(() {
                                  bool isSubmitLoading =
                                      controller.buttonLoaders['submit'] ??
                                      false;
                                  bool isSaveLoading =
                                      controller.buttonLoaders['save'] ?? false;
                                  bool isCancelLoading =
                                      controller.buttonLoaders['cancel'] ??
                                      false;
                                  bool isAnyLoading = controller
                                      .buttonLoaders
                                      .values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                    onPressed:
                                        (isSubmitLoading ||
                                            isSaveLoading ||
                                            isCancelLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () async {
                                            _isSubmitAttempted = true;
                                            if (_formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              if (controller
                                                      .isReceiptRequired
                                                      .value &&
                                                  controller
                                                      .imageFiles
                                                      .isEmpty) {
                                                Fluttertoast.showToast(
                                                  msg: "Receipt is required",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );

                                                return; // 🚨 STOP SUBMIT
                                              }
                                              controller.setButtonLoading(
                                                'save',
                                                true,
                                              );
                                              try {
                                                await controller
                                                    .saveGeneralExpense(
                                                      context,
                                                      false,
                                                      false,
                                                    );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'save',
                                                  false,
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please fill all required fields.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                              setState(
                                                () {},
                                              ); // Refresh UI for inline errors
                                            }
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
                                    ),
                                    child: isSaveLoading
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
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Obx(() {
                                  bool isSubmitLoading =
                                      controller.buttonLoaders['submit'] ??
                                      false;
                                  bool isSaveLoading =
                                      controller.buttonLoaders['save'] ?? false;
                                  bool isCancelLoading =
                                      controller.buttonLoaders['cancel'] ??
                                      false;
                                  bool isAnyLoading = controller
                                      .buttonLoaders
                                      .values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                    onPressed:
                                        (isSubmitLoading ||
                                            isSaveLoading ||
                                            isCancelLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () async {
                                            controller.setButtonLoading(
                                              'cancel',
                                              true,
                                            );
                                            try {
                                              controller.chancelButton(context);
                                            } finally {
                                              controller.setButtonLoading(
                                                'cancel',
                                                false,
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(130, 50),
                                      backgroundColor: Colors.grey,
                                    ),
                                    child: isCancelLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            loc.cancel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  );
                                }),
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
                      label: Text(loc.back),
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

  Widget _buildPolicyCard() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.policy1001,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(loc.expenseAmountUnderLimit)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(loc.receiptRequiredAmount)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.close, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.descriptionMandatory,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(loc.expiredPolicy)),
            ],
          ),
        ],
      ),
    );
  }
}
