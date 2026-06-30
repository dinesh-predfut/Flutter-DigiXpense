import 'dart:async';

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/utils.dart' show todayInOrgTimezone, toStartOfDayUtc;
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
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
import '../../../../../l10n/app_localizations.dart';
import '../../../../service.dart';

class CashAdvanceReturnForm extends StatefulWidget {
  const CashAdvanceReturnForm({super.key});

  @override
  State<CashAdvanceReturnForm> createState() => _CashAdvanceReturnFormState();
}

class _CashAdvanceReturnFormState extends State<CashAdvanceReturnForm>
    with TickerProviderStateMixin {
  final controller = Get.find<Controller>();
  final Map<String, TextEditingController> fieldControllers = {};
  final controllerItems = Get.find<Controller>();
  // final _formKey = GlobalKey<FormState>();
  List<Controller> itemizeControllers = [];
  RxList<CashAdvanceDropDownModel> cashAdvanceList =
      <CashAdvanceDropDownModel>[].obs;
  bool _isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    return RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(value);
  }

  int _currentStep = 0;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  int _selectedCategoryIndex = -1;
  // bool _controller.showPaidForError.value = false;
  bool _showPaidWithError = false;
  //  bool cashAdvanceField = false;
  // bool controller.showQuantityError.value = false;
  // bool controller.showUnitAmountError.value = false;
  bool _showUnitError = false;
  String? employeeError;
  // bool _showProjectError = false;
  // bool controller.setQuality.value = true;
  bool allowMultSelect = false;
  late Future<Map<String, bool>> _featureFuture;
  String? expenseIdError;
  bool _isTyping = false;
  late FocusNode _focusNode;
  bool clearField = false;
  bool _showTaxAmountError = false;
  bool showItemizeDetails = false;
  String? _paidTo;
  bool? isThereReferenceID = false;
  String? paidToError;
  final RxnString paidwithError = RxnString();
  final RxnString cashAdvanceField = RxnString();
  String? selectDate;
  String? selectReferenceIDError;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
final todayOrg = todayInOrgTimezone();

    // Convert to UTC milliseconds
    final fromMs = toStartOfDayUtc(todayOrg);

    // Store as UTC DateTime (always keep isUtc: true)
    controller.selectedDate ??= DateTime.fromMillisecondsSinceEpoch(
      fromMs,
      isUtc: true, // IMPORTANT: Keep this as true
    );    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    _featureFuture = controller.getAllFeatureStates();
    controller.isManualEntryMerchant = false;

    // ✅ Use cloned controller for first itemize (same as ExpenseCreationForm)
    final firstController = Controller();
    itemizeControllers.add(firstController);
    bool _validateCustomFieldFormats({
      required List fields,
      required dynamic controller,
      required bool isItemize,
    }) {
      bool isValid = true;

      for (final field in fields) {
        final fieldType = field['FieldType'];
        final value = field['EnteredValue']?.toString() ?? '';

        if (fieldType == 'Email' && value.isNotEmpty) {
          if (!_isValidEmail(value)) {
            field['Error'] = 'Enter a valid email address';
            isValid = false;
          }
        }

        if (fieldType == 'MobileNumber' && value.isNotEmpty) {
          if (!_isValidPhone(value)) {
            field['Error'] = 'Enter a valid mobile number';
            isValid = false;
          }
        }
      }

      if (isItemize) {
        (controller as Controller).customFieldsItems.refresh();
      } else {
        (controller as Controller).customFields.refresh();
      }

      return isValid;
    }

    bool _validateCustomFields({
      required String objectName,
      String? expenseType,
    }) {
      bool isValid = true;

      final fields = controller.customFields.where((field) {
        if (field['ObjectName'] != objectName) return false;
        if (expenseType != null && field['ExpenseType'] != expenseType) {
          return false;
        }
        return true;
      }).toList();

      for (final field in fields) {
        final isMandatory = field['IsMandatory'] ?? false;
        final fieldType = field['FieldType'];
        final value = field['EnteredValue']?.toString() ?? '';

        // ── Mandatory check ──
        if (isMandatory) {
          bool isEmpty = false;

          if (fieldType == 'List' ||
              fieldType == 'CustomList' ||
              fieldType == 'SystemList') {
            isEmpty = field['SelectedValue'] == null;
          } else if (fieldType == 'Checkbox') {
            isEmpty = false;
          } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
            isEmpty = field['EnteredValue'] == null;
          } else {
            isEmpty = value.trim().isEmpty;
          }

          if (isEmpty) {
            field['Error'] =
                '${field['FieldLabel'] ?? field['FieldName']} is required';
            isValid = false;
            continue; // skip format check if empty
          }
        }

        // ── Format check (runs even if not mandatory, when value exists) ──
        if (fieldType == 'Email' && value.isNotEmpty) {
          if (!_isValidEmail(value)) {
            field['Error'] = 'Enter a valid email address';
            isValid = false;
            continue;
          }
        }

        if (fieldType == 'MobileNumber' && value.isNotEmpty) {
          if (!_isValidPhone(value)) {
            field['Error'] = 'Enter a valid mobile number';
            isValid = false;
            continue;
          }
        }

        // ── All passed ──
        field['Error'] = null;
      }

      controller.customFields.refresh();
      return isValid;
    }

    int _getFirstInvalidItemizeIndex() {
      for (int i = 0; i < itemizeControllers.length; i++) {
        final c = itemizeControllers[i];

        if (c.selectedCategoryId.isEmpty) return i;
        if (c.quantity.text.isEmpty) return i;
        if (c.unitAmount.text.isEmpty) return i;

        final value = double.tryParse(c.lineAmountINR.text);
        if (value == null || value <= 0) return i;

        final min = c.minExpenseAmount.value;
        final max = c.maxExpenseAmount.value;
        if (value < min) return i;
        if (value > max && max != 0.0) return i;

        if (c.selectedunit == null) return i;

        if (isFieldMandatory('Tax Amount') && c.taxAmount.text.isEmpty)
          return i;
        if (isFieldMandatory('Project Id') && c.selectedProject == null)
          return i;

        // ✅ Check mandatory + format custom fields
        final hasInvalidCustomField = c.customFieldsItems
            .where(
              (field) =>
                  field['ObjectName'] == 'ExpenseTrans' &&
                  (field['ExpenseType'] == 'General Expenses' ||
                      field['ExpenseType'] == null),
            )
            .any((field) {
              final isMandatory = field['IsMandatory'] ?? false;
              final fieldType = field['FieldType'];
              final value = field['EnteredValue']?.toString() ?? '';

              // Mandatory empty check
              if (isMandatory) {
                if (fieldType == 'List' ||
                    fieldType == 'CustomList' ||
                    fieldType == 'SystemList') {
                  if (field['SelectedValue'] == null) return true;
                } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
                  if (field['EnteredValue'] == null) return true;
                } else if (fieldType != 'Checkbox') {
                  if (value.trim().isEmpty) return true;
                }
              }

              // Format check
              if (fieldType == 'Email' && value.isNotEmpty) {
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value))
                  return true;
              }
              if (fieldType == 'MobileNumber' && value.isNotEmpty) {
                if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(value))
                  return true;
              }

              return false;
            });

        if (hasInvalidCustomField) return i;
      }
      return -1;
    }

    bool _validateHeaderCustomFields() {
      bool isValid = true;

      final fields = controller.customFields
          .where(
            (field) =>
                field['ObjectName'] == 'ExpenseHeader' &&
                field['ExpenseType'] == 'CashAdvanceReturn',
          )
          .toList();

      for (final field in fields) {
        final isMandatory = field['IsMandatory'] ?? false;
        final fieldType = field['FieldType'];
        final value = field['EnteredValue']?.toString() ?? '';

        if (isMandatory) {
          bool isEmpty = false;
          if (fieldType == 'List' ||
              fieldType == 'CustomList' ||
              fieldType == 'SystemList') {
            isEmpty = field['SelectedValue'] == null;
          } else if (fieldType == 'Checkbox') {
            isEmpty = false;
          } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
            isEmpty = field['EnteredValue'] == null;
          } else {
            isEmpty = value.trim().isEmpty;
          }
          if (isEmpty) {
            field['Error'] =
                '${field['FieldLabel'] ?? field['FieldName']} is required';
            isValid = false;
            continue;
          }
        }

        // Format checks
        if (fieldType == 'Email' && value.isNotEmpty) {
          if (!_isValidEmail(value)) {
            field['Error'] = 'Enter a valid email address';
            isValid = false;
            continue;
          }
        }
        if (fieldType == 'MobileNumber' && value.isNotEmpty) {
          if (!_isValidPhone(value)) {
            field['Error'] = 'Enter a valid mobile number (7-15 digits)';
            isValid = false;
            continue;
          }
        }

        field['Error'] = null;
      }

      controller.customFields.refresh();
      return isValid;
    }

    bool _validateItemizeCustomFields(Controller itemizeController) {
      bool isValid = true;

      final fields = itemizeController.customFieldsItems
          .where((field) => field['ObjectName'] == 'ExpenseTrans')
          .toList();

      for (final field in fields) {
        final isMandatory = field['IsMandatory'] ?? false;
        final fieldType = field['FieldType'];
        final value = field['EnteredValue']?.toString() ?? '';

        // ── Mandatory check ──
        if (isMandatory) {
          bool isEmpty = false;

          if (fieldType == 'List' ||
              fieldType == 'CustomList' ||
              fieldType == 'SystemList') {
            isEmpty = field['SelectedValue'] == null;
          } else if (fieldType == 'Checkbox') {
            isEmpty = false;
          } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
            isEmpty = field['EnteredValue'] == null;
          } else {
            isEmpty = value.trim().isEmpty;
          }

          if (isEmpty) {
            field['Error'] =
                '${field['FieldLabel'] ?? field['FieldName']} is required';
            isValid = false;
            continue;
          }
        }

        // ── Format check ──
        if (fieldType == 'Email' && value.isNotEmpty) {
          if (!_isValidEmail(value)) {
            field['Error'] = 'Enter a valid email address';
            isValid = false;
            continue;
          }
        }

        if (fieldType == 'MobileNumber' && value.isNotEmpty) {
          if (!_isValidPhone(value)) {
            field['Error'] = 'Enter a valid mobile number';
            isValid = false;
            continue;
          }
        }

        // ── All passed ──
        field['Error'] = null;
      }

      itemizeController.customFieldsItems.refresh();
      return isValid;
    }

    bool _validateAllBeforeSubmit() {
      // Step 1 validation
      final step1Valid = validateDropdowns();
      if (!step1Valid) {
        setState(() => _currentStep = 0);
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        Fluttertoast.showToast(
          msg: "Please fill all required fields in Payment Info",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }

      // Header custom fields validation
      final headerValid = _validateHeaderCustomFields();
      if (!headerValid) {
        setState(() => _currentStep = 0);
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        Fluttertoast.showToast(
          msg: "Please fill all required fields in Payment Info",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }

      // Step 2: validate all itemize tabs
      bool allItemizeValid = true;
      for (int i = 0; i < itemizeControllers.length; i++) {
        final c = itemizeControllers[i];

        if (c.selectedCategoryId.isEmpty) {
          c.showPaidForError.value = true;
          allItemizeValid = false;
        }
        if (c.quantity.text.trim().isEmpty) {
          c.showQuantityError.value = true;
          allItemizeValid = false;
        }
        if (c.unitAmount.text.trim().isEmpty) {
          c.showUnitAmountError.value = true;
          allItemizeValid = false;
        }
        if (c.selectedunit == null) {
          allItemizeValid = false;
        }
        if (isFieldMandatory('Tax Amount') && c.taxAmount.text.trim().isEmpty) {
          c.showTaxAmountError.value = true;
          allItemizeValid = false;
        }
        if (isFieldMandatory('Tax Group') && c.selectedTax == null) {
          c.showTaxGroupError.value = true;
          allItemizeValid = false;
        }
        if (isFieldMandatory('Project Id') && c.selectedProject == null) {
          c.showProjectError.value = true;
          allItemizeValid = false;
        }

        final customValid = _validateItemizeCustomFields(c);
        if (!customValid) allItemizeValid = false;
      }

      if (!allItemizeValid) {
        final invalidIndex = _getFirstInvalidItemizeIndex();
        if (invalidIndex != -1) {
          setState(() {
            _currentStep = 1;
            _selectedItemizeIndex = invalidIndex;
          });
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          Future.delayed(const Duration(milliseconds: 150), () {
            Fluttertoast.showToast(
              msg:
                  "Please fill all required fields in item ${invalidIndex + 1}",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          });
        }
        return false;
      }

      return true;
    }

    bool _validateCurrentItemizeForm() {
      final currentController = itemizeControllers[_selectedItemizeIndex];
      bool isValid = true;

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

      if (currentController.selectedCategoryId.isEmpty) {
        setState(() => currentController.showPaidForError.value = true);
        isValid = false;
      }

      if (currentController.quantity.text.isEmpty) {
        setState(() => currentController.showQuantityError.value = true);
        isValid = false;
      }

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
            currentController.showUnitAmountError.value = false;
            currentController.unitAmountErrorText.value = '';
          }
        }
      }

      if (currentController.selectedunit == null) {
        setState(() => _showUnitError = true);
        isValid = false;
      }

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

      final projectIdMandatory = isFieldMandatory('Project Id');
      if (projectIdMandatory && currentController.selectedProject == null) {
        setState(() => currentController.showProjectError.value = true);
        isValid = false;
      }

      // ✅ Validate custom fields for this itemize tab
      final customValid = _validateItemizeCustomFields(currentController);
      if (!customValid) isValid = false;

      currentController.enableNextBtn.value = isValid;
      return isValid;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initializeUnits();
      controller.isLoadingGE2.value = true;
      controller.configuration();
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchEmployeesID();
      controller.loadAllCustomFieldValues();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.getUserPref(context);
      controller.fetchCashAdvanceExpenseCategory();
      _loadSettings();
      loadAndAppendCashAdvanceList();
      controller.isLoadingGE2.value = false;

      // ✅ After custom fields are loaded, clone into first controller
      if (controller.customFields.isNotEmpty) {
        itemizeControllers[0].cloneCustomFieldsFromRx(controller.customFields);
      }
    });
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();
      controller.cashAdvanceListDropDown.addAll(newItems); // ✅ Append here
      print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        print("allowDocAttachments$allowMultSelect");
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

    if (allowMultSelect == true) {
      if (controller.multiSelectedItems.isEmpty) {
        cashAdvanceField.value = AppLocalizations.of(
          context,
        )!.pleaseSelectCashAdvanceField;
        isValid = false;
      } else {
        cashAdvanceField.value = null;
      }
    } else {
      if (controller.singleSelectedItem == null) {
        cashAdvanceField.value = AppLocalizations.of(
          context,
        )!.pleaseSelectCashAdvanceField;
        isValid = false;
      } else {
        cashAdvanceField.value = null;
      }
    }

    paidwithError.value = null;

    setState(() {});
    final hideField = controller.hasModule("Expense");

    if (!hideField) {
      if (controller.expenseIdController.text.trim().isEmpty) {
        setState(() {
          expenseIdError = AppLocalizations.of(
            context,
          )!.fieldRequired; // 🔥 create this variable
        });
        isValid = false;
      } else {
        setState(() {
          expenseIdError = null;
        });
      }
    }
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

        controller.selectedProject = null;
        for (var c in itemizeControllers) {
          c.expenseCategory.value = [];
          c.categoryController.clear();
          c.projectDropDowncontroller.clear();
        }
      });
      loadAndAppendCashAdvanceList();
      controller.fetchCashAdvanceExpenseCategory();
      controller.fetchProjectName();
      controller.selectedDate = picked;
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
      setState(() {
        showItemizeDetails = true;
      });
    } else {
      if (_validateCurrentItemizeForm()) {
        if (_itemizeCount < 5) {
          setState(() {
            final newController = Controller();
            // ✅ Clone custom fields from master controller
            if (controllerItems.customFields.isNotEmpty) {
              newController.cloneCustomFieldsFromRx(
                controllerItems.customFields,
              );
            }
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
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.secondary,
            onTap: (index) {
              setState(() {
                _selectedItemizeIndex = index;
              });
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

    // 3. Validate Unit Amount
    if (currentController.unitAmount.text.isEmpty) {
      setState(() => currentController.showUnitAmountError.value = true);
      isValid = false;
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
    if (currentController.taxGroupController.text.isEmpty &&
        taxGroupMandatory) {
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

      // // Check min/max range
      // final min = c.minExpenseAmount.value;
      // final max = c.maxExpenseAmount.value;
      // if (value < min) return i;
      // if (value > max && max != 0.0) return i;

      // Check unit
      if (c.selectedunit == null) return i;

      // Check tax amount if mandatory
      if (isFieldMandatory('Tax Amount') && c.taxAmount.text.isEmpty) return i;

      // Check project if mandatory
      if (isFieldMandatory('Project Id') && c.selectedProject == null) return i;
    }
    return -1; // ✅ All valid
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

  bool _validateItemizeCustomFields(Controller itemizeController) {
    bool isValid = true;

    final fields = itemizeController.customFieldsItems
        .where(
          (field) =>
              field['ObjectName'] == 'ExpenseTrans'
        )
        .toList();

    for (final field in fields) {
      final isMandatory = field['IsMandatory'] ?? false;
      final fieldType = field['FieldType'];
      final value = field['EnteredValue']?.toString() ?? '';

      // ── Mandatory check ──
      if (isMandatory) {
        bool isEmpty = false;

        if (fieldType == 'List' ||
            fieldType == 'CustomList' ||
            fieldType == 'SystemList') {
          isEmpty = field['SelectedValue'] == null;
        } else if (fieldType == 'Checkbox') {
          isEmpty = false; // always has a value
        } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
          isEmpty = field['EnteredValue'] == null;
        } else {
          isEmpty = value.trim().isEmpty;
        }

        if (isEmpty) {
          field['Error'] =
              '${field['FieldLabel'] ?? field['FieldName']} is required';
          isValid = false;
          continue; // skip format check when empty
        }
      }

      // ── Format check (runs even when not mandatory if value exists) ──
      if (fieldType == 'Email' && value.isNotEmpty) {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          field['Error'] = 'Enter a valid email';
          isValid = false;
          continue;
        }
      }

      // if (fieldType == 'MobileNumber' && value.isNotEmpty) {
      //   if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(value)) {
      //     field['Error'] = 'Enter a valid mobile number (7-15 digits)';
      //     isValid = false;
      //     continue;
      //   }
      // }

      // ── All passed ──
      field['Error'] = null;
    }

    itemizeController.customFieldsItems.refresh();
    return isValid;
  }

  bool _validateAllBeforeSubmit() {
    bool isValid = true;

    // ── 1. Validate all itemize tabs ──
    for (int i = 0; i < itemizeControllers.length; i++) {
      final c = itemizeControllers[i];

      // Category
      if (c.selectedCategoryId.isEmpty) {
        c.showPaidForError.value = true;
        isValid = false;
      }

      // Quantity
      if (c.quantity.text.trim().isEmpty) {
        c.showQuantityError.value = true;
        isValid = false;
      }

      // Unit amount
      if (c.unitAmount.text.trim().isEmpty) {
        c.showUnitAmountError.value = true;
        c.unitAmountErrorText.value = AppLocalizations.of(
          context,
        )!.fieldRequired;
        isValid = false;
      } else {
        final value = double.tryParse(c.lineAmountINR.text);
        if (value == null || value <= 0) {
          c.showUnitAmountError.value = true;
          c.unitAmountErrorText.value = AppLocalizations.of(
            context,
          )!.enterValidAmount;
          isValid = false;
        } else {
          final min = c.minExpenseAmount.value;
          final max = c.maxExpenseAmount.value;
          if (value < min) {
            c.showUnitAmountError.value = true;
            c.unitAmountErrorText.value = AppLocalizations.of(
              context,
            )!.reportedAmountNotWithinRange;
            isValid = false;
          } else if (value > max && max != 0.0) {
            c.showUnitAmountError.value = true;
            c.unitAmountErrorText.value = AppLocalizations.of(
              context,
            )!.reportedAmountNotWithinRange;
            isValid = false;
          }
        }
      }

      // Unit
      if (c.selectedunit == null) {
        isValid = false;
      }

      // Tax amount if mandatory
      if (isFieldMandatory('Tax Amount') && c.taxAmount.text.trim().isEmpty) {
        c.showTaxAmountError.value = true;
        isValid = false;
      }

      // Tax group if mandatory
      if (isFieldMandatory('Tax Group') && c.selectedTax == null) {
        c.showTaxGroupError.value = true;
        isValid = false;
      }

      // Project if mandatory
      if (isFieldMandatory('Project Id') && c.selectedProject == null) {
        c.showProjectError.value = true;
        isValid = false;
      }

      // ── Custom fields for this itemize tab ──
      final customValid = _validateItemizeCustomFields(c);
      if (!customValid) isValid = false;
    }

    // ── 2. Validate header-level custom fields (ExpenseHeader) ──
    final headerCustomValid = _validateHeaderCustomFields();
    if (!headerCustomValid) isValid = false;

    // ── 3. If any itemize tab is invalid, navigate to first invalid one ──
    if (!isValid) {
      final invalidIndex = _getFirstInvalidItemizeIndex();
      if (invalidIndex != -1) {
        // Navigate back to itemize step
        setState(() {
          _currentStep = 1;
          _selectedItemizeIndex = invalidIndex;
        });
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        Future.delayed(const Duration(milliseconds: 150), () {
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
    }

    return isValid;
  }

  /// Validates ExpenseHeader custom fields (Step 1 fields)
  bool _validateHeaderCustomFields() {
    bool isValid = true;

    final fields = controllerItems.customFields
        .where(
          (field) =>
              field['ObjectName'] == 'ExpenseHeader' &&
              field['ExpenseType'] == 'General Expenses',
        )
        .toList();

    for (final field in fields) {
      final isMandatory = field['IsMandatory'] ?? false;
      final fieldType = field['FieldType'];
      final value = field['EnteredValue']?.toString() ?? '';

      if (isMandatory) {
        bool isEmpty = false;

        if (fieldType == 'List' ||
            fieldType == 'CustomList' ||
            fieldType == 'SystemList') {
          isEmpty = field['SelectedValue'] == null;
        } else if (fieldType == 'Checkbox') {
          isEmpty = false;
        } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
          isEmpty = field['EnteredValue'] == null;
        } else {
          isEmpty = value.trim().isEmpty;
        }

        if (isEmpty) {
          field['Error'] =
              '${field['FieldLabel'] ?? field['FieldName']} is required';
          isValid = false;
          continue;
        }
      }

      // Format checks
      if (fieldType == 'Email' && value.isNotEmpty) {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          field['Error'] = 'Enter a valid email';
          isValid = false;
          continue;
        }
      }

      if (fieldType == 'MobileNumber' && value.isNotEmpty) {
        if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(value)) {
          field['Error'] = 'Enter a valid mobile number (7-15 digits)';
          isValid = false;
          continue;
        }
      }

      field['Error'] = null;
    }

    controllerItems.customFields.refresh();

    // If header fields invalid, navigate back to step 1
    if (!isValid) {
      setState(() => _currentStep = 0);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      Fluttertoast.showToast(
        msg: "Please fill all required fields in Payment Info",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return isValid;
  }

  Future<bool> _showDistributionWarning() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Warning"),
            content: const Text(
              "Changing the  Date will clear all Account Distribution data. Do you want to continue?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Continue"),
              ),
            ],
          ),
        ) ??
        false;
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitForm),
            content: Text(AppLocalizations.of(context)!.exitWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          Navigator.pushNamed(context, AppRoutes.generalExpense);
          controller.clearFormFields();
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.cashAdvanceReturnForm,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    backButton: backButton,
                    onValidateBeforeSubmit: _validateAllBeforeSubmit,
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
        //           label: Text(loc.back),
        //         ),
        //       if (_currentStep > 0)
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
    final loc = AppLocalizations.of(context)!;
    if (controllerItems.unitRate.text != null) {
      final qty =
          double.tryParse(controllerItems.unitRate.text.toString()) ?? 0.0;
      final unit = double.tryParse(controller.unitAmount.text) ?? 0.0;
      final quantity = double.tryParse(controller.quantity.text) ?? 0.0;
      final calculatedLineAmount = qty * unit * quantity;
      controller.lineAmountINR.text = calculatedLineAmount.toStringAsFixed(2);
      print("lineAmountINR${controller.lineAmountINR.text}");
    }
    // Use the provided controller parameter consistently
    controller.selectedunit ??= controllerItems.selectedunit;
    controller.selectedDate = controllerItems.selectedDate;
    // controller.isReimbursite.vale = true;
    print("selecteduni${controllerItems.selectedunit}");
    if (controller.setQuality.value) {
      if (controller.quantity.text.isEmpty) {
        controller.quantity.text = '1.00';
      }
    }
    final currentCustomFields = controller.customFieldsItems;

    // If this controller doesn't have its own custom fields yet,
    // initialize them from the master
    if (currentCustomFields.isEmpty && controller.customFields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.cloneCustomFieldsFromRx(controller.customFields);
      });
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
                            columnHeaders: const ['Project Name', 'Project Id'],
                            items: controllerItems.project,
                            selectedValue: controller.selectedProject,
                            searchValue: (proj) => '${proj.name} ${proj.code}',
                            displayText: (proj) => proj.code,
                            onChanged: (proj) {
                              setState(() {
                                controller.selectedProject = proj;
                                controllerItems.selectedProject = proj;
                                // Clear validation error when a project is selected
                                if (proj != null) {
                                  controller.showProjectError.value = false;
                                }
                              });
                              controller.fetchCashAdvanceExpenseCategory();
                            },
                            rowBuilder: (proj, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(child: Text(proj.name)),
                                    Expanded(child: Text(proj.code)),
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
                            columnHeaders: const ['Tax Group', 'Tax ID'],
                            items: controllerItems.taxGroup,
                            selectedValue: controller.selectedTax,
                            controller: controller.taxGroupController,
                            searchValue: (tax) =>
                                '${tax.taxGroup} ${tax.taxGroupId}',
                            displayText: (tax) => tax.taxGroupId,
                            validator: (tax) =>
                                isMandatory &&
                                    controller.taxGroupController.text.isEmpty
                                ? '${loc.pleaseSelectTaxGroup} '
                                : null,
                            onChanged: (tax) {
                              setState(() {
                                controller.selectedTax = tax;
                                controllerItems.selectedTax = tax;
                                if (tax != null) {
                                  controller.showTaxGroupError.value = false;
                                }
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
                                    Expanded(child: Text(tax.taxGroup)),
                                    Expanded(child: Text(tax.taxGroupId)),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (controller.showTaxGroupError.value)
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
                                // Clear error once the user starts typing
                                if (tax.isNotEmpty) {
                                  controller.showTaxAmountError.value = false;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText:
                                  '${loc.taxAmount}${isMandatory ? " *" : ""}',
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
                                '${loc.taxAmountRequired} ',
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
                        const SizedBox(height: 8),
                        // const SizedBox(height: 20),
                      ],
                    );
                  })
                  .toList(),
              const SizedBox(height: 8),
              Obx(() {
                return Column(
                  children: currentCustomFields.asMap().entries.map((entry) {
                    final index = entry.key;
                    final field = entry.value;

                    if (!(field['ObjectName'] == 'ExpenseTrans' &&
                        (field['ExpenseType'] == 'General Expenses' ||
                            field['ExpenseType'] == null))) {
                      return const SizedBox.shrink();
                    }

                    final String label =
                        field['FieldLabel'] ?? field['FieldName'];
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
                      if (field['Options'] != null &&
                          field['Options'] is List) {
                        options = List<CustomDropdownValue>.from(
                          field['Options'],
                        );
                      }

                      field['_controller'] ??= TextEditingController();
                      final TextEditingController fieldController =
                          field['_controller'];

                      CustomDropdownValue? selectedValue =
                          field['SelectedValue'];

                      if (selectedValue == null &&
                          field['DefaultValue'] != null) {
                        final matches = options.where(
                          (opt) =>
                              opt.valueId == field['DefaultValue'] ||
                              opt.valueName == field['DefaultValue'],
                        );
                        selectedValue = matches.isNotEmpty
                            ? matches.first
                            : null;

                        if (selectedValue != null) {
                          field['SelectedValue'] = selectedValue;
                          field['EnteredValue'] = selectedValue.valueId;
                        }
                      }

                      // Update controller text without triggering rebuild
                      final newText =
                          selectedValue?.valueName ??
                          field['DefaultValue']?.toString() ??
                          '';
                      if (fieldController.text != newText) {
                        fieldController.text = newText;
                      }

                      // If no matched selectedValue but DefaultValue exists
                      if (selectedValue == null &&
                          field['DefaultValue'] != null) {
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

                      inputField =
                          SearchableMultiColumnDropdownField<
                            CustomDropdownValue
                          >(
                            key: ValueKey('dropdown_$fieldKey'),
                            labelText: '$label${isMandatory ? " *" : ""}',
                            items: options,
                            selectedValue: selectedValue,
                            searchValue: (val) => val.valueName,
                            displayText: (val) => val.valueName,
                            controller: fieldController,
                            columnHeaders: const ['Value ID', 'Value Name'],
                            rowBuilder: (val, searchQuery) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      val.valueId,
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      val.valueName,
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
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
                      final dateController =
                          field['_dateController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxDateValue =
                            field['_rxDateValue'] as Rx<DateTime?>;
                        final currentDate = rxDateValue.value;

                        // Update controller only if value changed
                        String newText = '';
                        if (currentDate != null) {
                          if (isDateTime) {
                            newText = DateFormat(
                              'dd/MM/yyyy hh:mm a',
                            ).format(currentDate);
                          } else {
                            newText = DateFormat(
                              'dd/MM/yyyy',
                            ).format(currentDate);
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
                            DateTime? currentDate =
                                rxDateValue.value ?? DateTime.now();

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
                                initialTime = TimeOfDay.fromDateTime(
                                  rxDateValue.value!,
                                );
                              }

                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
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
                      final intController =
                          field['_intController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxIntValue'] as Rx<int?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value?.toString() ?? '';
                        if (intController.text != newText) {
                          intController.text = newText;
                        }

                        // Remove old listener and add new one
                        intController.removeListener(
                          _getIntListener(field, rxValue, intController),
                        );
                        intController.addListener(
                          _getIntListener(field, rxValue, intController),
                        );

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
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
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
                      final doubleController =
                          field['_doubleController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxDoubleValue'] as Rx<double?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value?.toString() ?? '';
                        if (doubleController.text != newText) {
                          doubleController.text = newText;
                        }

                        // Remove old listener and add new one
                        doubleController.removeListener(
                          _getDoubleListener(field, rxValue, doubleController),
                        );
                        doubleController.addListener(
                          _getDoubleListener(field, rxValue, doubleController),
                        );

                        return TextFormField(
                          key: ValueKey('double_$fieldKey'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*'),
                            ),
                          ],
                          controller: doubleController,
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: const OutlineInputBorder(),
                            errorText: field['Error'],
                          ),
                          validator: (value) {
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
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
                      final emailController =
                          field['_emailController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxStringValue'] as Rx<String?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value ?? '';
                        if (emailController.text != newText) {
                          emailController.text = newText;
                        }

                        // Remove old listener and add new one
                        emailController.removeListener(
                          _getStringListener(field, rxValue, emailController),
                        );
                        emailController.addListener(
                          _getStringListener(field, rxValue, emailController),
                        );

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
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
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
                      });
                    }
               else if (fieldType == 'MobileNumber') {
                      // Initialize persistent controllers and values if not exists
                      if (field['_phoneController'] == null) {
                        final defaultValue =
                            field['DefaultValue']?.toString() ?? '';
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
                        field['_countryCodeController'] = TextEditingController(
                          text: countryCode,
                        );
                        field['_phoneController'] = TextEditingController(
                          text: phoneNumber,
                        );
                        field['_rxStringValue'] = Rx<String?>(initialValue);
                        field['_focusNode'] = FocusNode();
                        field['EnteredValue'] = initialValue;

                        // Update EnteredValue when phone number changes
                        field['_phoneController'].addListener(() {
                          final phoneVal = field['_phoneController'].text;
                          final codeVal = field['_countryCodeController'].text;
                          final fullNumber = phoneVal.isNotEmpty
                              ? '$codeVal $phoneVal'
                              : '';

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
                          final fullNumber = phoneVal.isNotEmpty
                              ? '$codeVal $phoneVal'
                              : '';

                          if (fullNumber != field['_rxStringValue'].value) {
                            field['_rxStringValue'].value = fullNumber;
                            field['EnteredValue'] = fullNumber;
                          }
                          field['Error'] = null;
                        });
                      }

                      final phoneController =
                          field['_phoneController'] as TextEditingController;
                      final countryCodeController =
                          field['_countryCodeController']
                              as TextEditingController;
                      final focusNode = field['_focusNode'] as FocusNode;

                      inputField = SizedBox(
                        child: IntlPhoneField(
                          key: ValueKey('phone_$fieldKey'),
                          controller: phoneController,
                          focusNode: focusNode,
                          initialCountryCode:
                              field['_selectedCountryCode'] ?? 'IN',
                          onChanged: (phone) {
                            countryCodeController.text =
                                '+${phone.countryCode}';
                            phoneController.text = phone.number;
                          },
                          onCountryChanged: (country) {
                            countryCodeController.text = '+${country.dialCode}';
                            field['_selectedCountryCode'] = country.code;
                          },
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: field['Error'],
                            counterText: "",
                          ),
                        ),
                      );
                    }
                                  // Default Text type - Make Reactive
                    // Default Text type - Make Reactive
else {
  // Initialize Rx value safely
  if (!field.containsKey('_rxStringValue') || field['_rxStringValue'] == null) {
    field['_rxStringValue'] = Rx<String?>(field['EnteredValue'] as String?);
  }

  // Get the Rx value safely
  final rxValue = field['_rxStringValue'] as Rx<String?>?;
  
  if (rxValue == null) {
    // Fallback if somehow still null
    field['_rxStringValue'] = Rx<String?>(field['EnteredValue'] as String?);
    final newRxValue = field['_rxStringValue'] as Rx<String?>;
    
    inputField = Obx(() {
      final currentRxValue = field['_rxStringValue'] as Rx<String?>?;
      final currentText = currentRxValue?.value ?? '';
      
      // Update controller without triggering rebuild during build
      if (fieldControllers[fieldKey]!.text != currentText) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fieldControllers.containsKey(fieldKey)) {
            fieldControllers[fieldKey]!.text = currentText;
          }
        });
      }

      return TextFormField(
        enabled: controller.isEnable.value,
        keyboardType: TextInputType.text,
        controller: fieldControllers[fieldKey],
        decoration: InputDecoration(
          labelText: '$label${isMandatory ? " *" : ""}',
          border: const OutlineInputBorder(),
          errorText: field['Error'],
        ),
        onChanged: (value) {
          currentRxValue?.value = value;
          field['EnteredValue'] = value;
          field['Error'] = null;
        },
        validator: (value) {
          if (isMandatory && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      );
    });
  } // Default Text type - Make Reactive
else {
  // Initialize Rx value
  if (!field.containsKey('_rxStringValue') || field['_rxStringValue'] == null) {
    field['_rxStringValue'] = Rx<String?>(field['EnteredValue'] as String?);
  }
  final rxValue = field['_rxStringValue'] as Rx<String?>;
  
  // Initialize controller if missing
  final controller = fieldControllers.putIfAbsent(
    fieldKey, 
    () => TextEditingController(text: field['EnteredValue'] as String? ?? '')
  );
  
  inputField = Obx(() {
    final currentText = rxValue.value ?? '';
    
    // Update controller text if different
    if (controller.text != currentText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.text = currentText;
      });
    }

    return TextFormField(
      // enabled: controller.isEnable.value,
      keyboardType: TextInputType.text,
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label${isMandatory ? " *" : ""}',
        border: const OutlineInputBorder(),
        errorText: field['Error'],
      ),
      onChanged: (value) {
        rxValue.value = value;
        field['EnteredValue'] = value;
        field['Error'] = null;
      },
      validator: (value) {
        if (isMandatory && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  });
}
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

                // 👉 Handle empty state
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
                      labelText: '${loc.unit}  *',
                      columnHeaders: ['${loc.uomId} ', loc.uomName],
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
                            onEditingComplete: () {
                              String text = controller.unitAmount.text;
                              double? value = double.tryParse(text);
                              if (value != null) {
                                controller.unitAmount.text = value
                                    .toStringAsFixed(2);
                                controller.paidAmount.text = value
                                    .toStringAsFixed(2);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "${loc.unitAmount}  *",
                              errorText: controller.showUnitAmountError.value
                                  ? loc.unitAmountRequired
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                              controller: controller.quantity,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ), // Allows numbers with up to 2 decimal places
                              ],
                              onChanged: (value) {
                                setState(() {
                                  controller.quantity.text = value;
                                  controller.showQuantityError.value = false;
                                  controller.setQuality.value = false;
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
                                controller.paidAmount.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.paidAmontIsEditable.value = false;
                                controller.lineAmount.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.lineAmountINR.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                              },
                              decoration: InputDecoration(
                                labelText: "${loc.quantity} *",
                                errorText: controller.showQuantityError.value
                                    ? '${loc.quantityRequired} '
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (showItemizeDetails) const SizedBox(height: 16),
                  if (showItemizeDetails)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            "${loc.lineAmount}  *",
                            controller.lineAmount,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextInput(
                            '${AppLocalizations.of(context)!.lineAmountInInr} ${controller.organizationCurrency} *',
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
                                      controller.accountingDistributions
                                          .clear();
                                      controller.accountingDistributions.addAll(
                                        newList,
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
                            // ignore: prefer_const_constructors
                            style: TextStyle(
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
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
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

                          // ❌ Hide button completely if feature disabled
                          if (!isEnabled) return const SizedBox.shrink();

                          // ✅ Show button only when feature is enabled
                          return OutlinedButton.icon(
                            onPressed: () {
                              // Validate current form before adding new itemize
                              if (validateDropdowns() ) {
                                _addItemize();
                              } else {
                                // Optional: Show error message
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text(
                                //       loc.pleaseFillAllRequiredFields,
                                //     ),
                                //     backgroundColor: Colors.red,
                                //   ),
                                // );
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            label: Text(loc.back),
                          )
                        else
                          const SizedBox(),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (showItemizeDetails) {
                              if (_validateCurrentItemizeForm() &&
                                  _validateAllBeforeSubmit()) {
                                final invalidIndex =
                                    _getFirstInvalidItemizeIndex();

                                if (invalidIndex != -1 &&
                                    invalidIndex != _selectedItemizeIndex) {
                                  // ❌ Another page has invalid fields → navigate to it
                                  _navigateToInvalidItemize(invalidIndex);
                                  return;
                                }
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
                                      setState(
                                        () =>
                                            controller
                                                    .showUnitAmountError
                                                    .value =
                                                true,
                                      );
                                      isValid = false;
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
                            } else {
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
                                      setState(
                                        () =>
                                            controller
                                                    .showUnitAmountError
                                                    .value =
                                                true,
                                      );
                                      isValid = false;
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

                                print('isValid$isValid');
                                print('isValid${itemizeControllers.length}');
                                if (isValid) {
                                  if (showItemizeDetails) {
                                    final invalidIndex =
                                        _getFirstInvalidItemizeIndex();

                                    if (invalidIndex != -1 &&
                                        invalidIndex != _selectedItemizeIndex) {
                                      // ❌ Another page has invalid fields → navigate to it
                                      _navigateToInvalidItemize(invalidIndex);
                                      return;
                                    }
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
                            _currentStep == 2
                                ? '${loc.finish} '
                                : '${loc.next} ',
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
    print("total$total");
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

    // ✅ Static cache (prevents re-decoding flicker)
    final Map<String, Uint8List> _base64Cache = {};

    Widget _buildIcon(String? icon) {
      const fallbackUrl =
          "https://icons.veryicon.com/png/o/commerce-shopping/icon-of-lvshan-valley-mobile-terminal/home-category.png";

      try {
        if (icon != null && icon.isNotEmpty) {
          if (icon.startsWith('data:image')) {
            // Base64 with prefix
            final base64Str = icon.split(',').last;
            if (!_base64Cache.containsKey(base64Str)) {
              _base64Cache[base64Str] = base64Decode(base64Str);
            }
            return Image.memory(
              _base64Cache[base64Str]!,
              width: 30,
              height: 30,
              gaplessPlayback: true, // prevents blinking
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(icon)) {
            // Plain Base64 (no prefix)
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
            // ✅ URL or asset
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

      // ✅ Fallback if icon is null or invalid
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

        if (item.itemisationMandatory && showItemizeDetails == false) {
          _addItemize();
        }
        print("Tapped Category Name: ${item.categoryName}");
        print("Tapped Category ID: ${controllers.selectedCategoryId}");
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(
                  color: const Color.fromARGB(255, 163, 11, 11),
                  width: 3,
                )
              : null,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 👇 Use this if you want to hide icons while typing
            AnimatedOpacity(
              opacity: _isTyping ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: _buildIcon(icon),
            ),
            const SizedBox(height: 8),
            Text(
              item.categoryId,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
    final loc = AppLocalizations.of(context)!;
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
                      Obx(() {
                        if (controller.isSequenceLoading.value) {
                          return const SizedBox(); // or loader
                        }

                        final hideField = controller.hasModule("Expense");

                        if (hideField) {
                          return const SizedBox.shrink(); // ✅ hide
                        }

                        return Column(
                          children: [
                            TextFormField(
                              controller: controller.expenseIdController,
                              decoration: InputDecoration(
                                labelText: '${loc.requestId} *',
                                errorText: expenseIdError,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),

                      FormField<DateTime>(
                        validator: (value) {
                          if (controller.selectedDate == null) {
                            return '${loc.selectDateFormat} ';
                          }
                          return null;
                        },
                        builder: (FormFieldState<DateTime> field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {

                                  // Show warning only if Account Distribution has data
  if (controller.accountingDistributions.isNotEmpty ||
      controller.split.isNotEmpty) {
    final proceed = await _showDistributionWarning();

    if (!proceed) return;
  }
   final oldDate = controller.selectedDate;
                                  await _selectDate(context);
                                  // Clear only if the date actually changed
  if (oldDate != null &&
      controller.selectedDate != null &&
      oldDate != controller.selectedDate) {
    controller.accountingDistributions.clear();
    controller.split.clear();
  }
                                  field.didChange(controller.selectedDate);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: '${loc.requestDate} *',
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
                                            ? '${loc.selectDate} '
                                            : DateFormat(
                                                controller
                                                        .selectedFormat
                                                        ?.key ??
                                                    'dd/MM/yyyy',
                                              ).format(
                                                controller.selectedDate!,
                                              ),
                                        style: TextStyle(
                                          color: controller.selectedDate == null
                                              ? Colors.grey
                                              : Colors.black,
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
                      const SizedBox(height: 6),
                      if (PermissionHelper.canRead("User Delegates") == true)
                        const SizedBox(height: 6),
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
                      // const SizedBox(height: 6),

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
                                                    '$label${isMandatory ? " *" : ""}',
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

                      // const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Obx(
                          //   () =>
                          MultiSelectMultiColumnDropdownField<
                            CashAdvanceDropDownModel
                          >(
                            labelText: '${loc.cashAdvanceRequest} *',
                            controller: controller.cashAdvanceIds,
                            items: controller.cashAdvanceListDropDown,
                            isMultiSelect: allowMultSelect ?? false,
                            selectedValue: controller.singleSelectedItem,
                            selectedValues: controller.multiSelectedItems,

                            // enabled: controller.isEnable.value,
                            searchValue: (proj) => proj.cashAdvanceReqId,
                            displayText: (proj) => proj.cashAdvanceReqId,
                            validator: (proj) {
                              if (allowMultSelect == true) {
                                return controller.multiSelectedItems.isEmpty
                                    ? loc.pleaseSelectCashAdvanceField
                                    : null;
                              } else {
                                return controller.singleSelectedItem == null
                                    ? loc.pleaseSelectCashAdvanceField
                                    : null;
                              }
                            },
                            onChanged: (item) {
                              controller.singleSelectedItem = item;
                              cashAdvanceField.value = null;
                            },
                            onMultiChanged: (items) {
                              controller.multiSelectedItems.assignAll(items);
                              cashAdvanceField.value = null;
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
                          // ),
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
                          if (cashAdvanceField.value != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                bottom: 8,
                              ),
                              child: Text(
                                cashAdvanceField.value!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Obx(() {
                        return Column(
                          children: controller.customFields
                              .where(
                                (field) =>
                                    field['ObjectName'] == 'ExpenseHeader' &&
                                    field['ExpenseType'] == 'CashAdvanceReturn',
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
                                    //  enabled: controller.isEditModePerdiem,
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
                      const SizedBox(height: 7),
                      Text(
                        '${loc.paidWith}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
              );
      }),
    );
  }
}

class CreateExpensePage extends StatefulWidget {
  final VoidCallback backButton;
  const CreateExpensePage({
    super.key,
    required this.backButton,
    required onValidateBeforeSubmit,
  });

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

  // void _showFullImage(File file, int index) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.black,
  //         child: Stack(
  //           children: [
  //             PhotoView(
  //               imageProvider: FileImage(file),
  //               backgroundDecoration: const BoxDecoration(color: Colors.black),
  //               minScale: PhotoViewComputedScale.contained,
  //               maxScale: PhotoViewComputedScale.covered * 3.0,
  //             ),
  //             Positioned(
  //               top: 10,
  //               right: 10,
  //               child: Column(
  //                 children: [
  //                   // FloatingActionButton.small(
  //                   //   heroTag: "zoom_in_$index",
  //                   //   onPressed: _zoomIn,
  //                   //   child: const Icon(Icons.zoom_in),
  //                   //   backgroundColor: Colors.deepPurple,
  //                   // ),
  //                   // const SizedBox(height: 8),
  //                   // FloatingActionButton.small(
  //                   //   heroTag: "zoom_out_$index",
  //                   //   onPressed: _zoomOut,
  //                   //   child: const Icon(Icons.zoom_out),
  //                   //   backgroundColor: Colors.deepPurple,
  //                   // ),
  //                   const SizedBox(height: 8),
  //                   FloatingActionButton.small(
  //                     heroTag: "edit_$index",
  //                     onPressed: () => _cropImage(file),
  //                     child: const Icon(Icons.edit),
  //                     backgroundColor: Colors.deepPurple,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   FloatingActionButton.small(
  //                     heroTag: "delete_$index",
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       setState(() {
  //                         controller.imageFiles.removeAt(index);
  //                       });
  //                     },
  //                     backgroundColor: Colors.red,
  //                     child: const Icon(Icons.delete),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

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
                                RegExp(r'^\d*\.?\d*'),
                              ), // Only digits and dots allowed
                            ],
                            decoration: InputDecoration(
                              labelText: '${loc.paidAmount}  *',
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
                              if (controller.paidAmount.text.isEmpty) {
                                return loc.paidAmountRequired;
                              }

                              final parsed = double.tryParse(
                                controller.paidAmount.text,
                              );

                              if (parsed == null || parsed <= 0) {
                                return loc.enterValidAmount;
                              }

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
                              columnHeaders: [loc.code, loc.name, loc.symbol],
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
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
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
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.code,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          c.symbol,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],
                            controller: controller.unitRate,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: '${loc.rate}  *',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '${loc.rateRequired} ';
                              }
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid rate';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              final paid =
                                  double.tryParse(controller.paidAmount.text) ??
                                  0.0;
                              final rate = double.tryParse(val) ?? 1.0;
                              final result = paid * rate;
                              controller.amountINR.text = result
                                  .toStringAsFixed(2);
                              controller.isVisible.value = true;
                            },
                          ),
                        ),
                      ],
                    ),

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
                            '${AppLocalizations.of(context)!.totalAmountIN} ${controller.organizationCurrency}',
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
                              width: 300,
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
                                          controller.setButtonLoading(
                                            'submit',
                                            true,
                                          );
                                          controller.finalItems.clear();

                                          // for (final item in itemizeControllers) {
                                          //   controller.finalItems.add(
                                          //     item.toExpenseItemModel(),
                                          //   );
                                          // }

                                          print(
                                            "finalItems count = ${controller.finalItems.length}",
                                          );
                                          try {
                                            await controller
                                                .createcashAdvanceReturn(
                                                  context,
                                                  true,
                                                  false,
                                                  0,
                                                  null,
                                                );
                                          } finally {
                                            controller.setButtonLoading(
                                              'submit',
                                              false,
                                            );
                                          }
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
                                              controller.setButtonLoading(
                                                'save',
                                                true,
                                              );
                                              try {
                                                await controller
                                                    .createcashAdvanceReturn(
                                                      context,
                                                      false,
                                                      false,
                                                      0,
                                                      null,
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
                                        : Text(
                                            AppLocalizations.of(context)!.save,
                                          ),
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
                                            AppLocalizations.of(
                                              context,
                                            )!.cancel,
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
