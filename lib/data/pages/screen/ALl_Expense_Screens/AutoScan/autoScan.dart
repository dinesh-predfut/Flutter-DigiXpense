import 'dart:convert' show base64Decode;
import 'dart:async';
import 'dart:io';

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/core/utils.dart'
    show todayInOrgTimezone, toStartOfDayUtc, formatDate;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart' show OpenFilex;
import 'package:photo_view/photo_view.dart';

import '../../../../../l10n/app_localizations.dart';

class AutoScanExpensePage extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic>? apiResponse;

  const AutoScanExpensePage({
    Key? key,
    required this.imageFile,
    this.apiResponse,
  }) : super(key: key);

  @override
  State<AutoScanExpensePage> createState() => _AutoScanExpensePageState();
}

class _AutoScanExpensePageState extends State<AutoScanExpensePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> expenseTrans;
  late final Controller controller;
  final Map<String, TextEditingController> fieldControllers = {};

  bool _isItemized = false;
  bool _isSubmitAttempted = false;
  bool _isReimbursable = true;
  bool _isBillable = false;
  late Future<Map<String, bool>> _featureFuture;

  String? selectedIcon;

  late PageController _pageController;
  bool allowMultSelect = false;
  bool allowCashAd = false;
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController merchantController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController cashAdvanceController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController totalInINRController = TextEditingController();
  late GESpeficExpense expense;

  // Itemize controllers list
  List<Controller> itemizeControllers = [];
  int _itemizeCount = 1;

  late FocusNode _focusNode;
  bool _isTyping = false;

  final PhotoViewController _photoViewController = PhotoViewController();

  // Config flags
  late final projectConfig;
  late final taxGroupConfig;
  late final taxAmountConfig;
  late final isReimbursibleConfig;
  late final isRefrenceIDConfig;
  late final isBillableConfig;
  late final isLocationConfig;

  @override
  void initState() {
    super.initState();
    controller = Get.find<Controller>();
    _focusNode = FocusNode();
    final todayOrg = todayInOrgTimezone();

    // Convert to UTC milliseconds
    final fromMs = toStartOfDayUtc(todayOrg);

    // Store as UTC DateTime (always keep isUtc: true)
    controller.selectedDate ??= DateTime.fromMillisecondsSinceEpoch(
      fromMs,
      isUtc: true, // IMPORTANT: Keep this as true
    );

    receiptDateController.text = formatDate(controller.selectedDate!);
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    _featureFuture = controller.getAllFeatureStates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newController = Controller();

      if (controller.customFields.isNotEmpty) {
        newController.cloneCustomFieldsFromRx(controller.customFields);
      }
    });
    // Initialize config
    projectConfig = controller.getFieldConfig("Project Id");
    taxGroupConfig = controller.getFieldConfig("Tax Group");
    taxAmountConfig = controller.getFieldConfig("Tax Amount");
    isReimbursibleConfig = controller.getFieldConfig("Is Reimbursible");
    isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
    isBillableConfig = controller.getFieldConfig("Is Billable");
    isLocationConfig = controller.getFieldConfig("Location");

    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );
    controller.fetchAndStoreFeatures(Params.userToken, context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.isLoadingOCR.value = true;
      controller.isEnable.value = true;
      await _initializeFormFromApiResponse();
      await controller.loadSequenceModules();
      await controller.configuration();
      controller.loadAllCustomFieldValues();
await controller.fetchExchangeRate();
      controller.currencyDropDown();
      // controller.selectedDate ??= DateTime.now();
      await controller.fetchPaidto();
      await controller.fetchPaidwith();
      await controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.fetchExpenseCategory();
      loadAndAppendCashAdvanceList();
      _loadSettings();
      if (widget.apiResponse == null) {
        controller.getUserPref(context);
      }

      controller.fetchPaidwith();
      _initializeUnits();
      controller.isLoadingOCR.value = false;
    });

    if (widget.apiResponse != null) {
      expense = GESpeficExpense.fromJson(widget.apiResponse!);
      controller.addToFinalItems(expense);
      expenseTrans = List<Map<String, dynamic>>.from(
        widget.apiResponse!['ExpenseTrans'] ?? [],
      );
      _isItemized =
          expenseTrans.length > 1 ||
          (expenseTrans.isNotEmpty && expenseTrans[0]['Description'] != null);
   
      receiptDateController.text = DateFormat(
        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
      ).format(DateTime.now());
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

  void _loadCategoryCustomFields(
    ExpenseCategory category,
    Controller targetController,
  ) {
    if (category.customFields != null && category.customFields!.isNotEmpty) {
      targetController.customFieldsItems.removeWhere(
        (field) => field['ObjectName'] == 'ExpenseCategories',
      );

      for (var categoryField in category.customFields!) {
        final Map<String, dynamic> field = Map<String, dynamic>.from(
          categoryField,
        );
        field['ObjectName'] = 'ExpenseCategories';
        field['ExpenseType'] = 'General Expenses';

        final defaultVal = field['DefaultValue']?.toString() ?? '';
        field['EnteredValue'] = defaultVal;

        final fieldType = field['FieldType'];

        if (fieldType == 'List' ||
            fieldType == 'CustomList' ||
            fieldType == 'SystemList') {
          final options = field['Options'] as List<CustomDropdownValue>?;
          CustomDropdownValue? matchedOption;
          if (options != null && defaultVal.isNotEmpty) {
            matchedOption = options.firstWhereOrNull(
              (opt) => opt.valueName == defaultVal || opt.valueId == defaultVal,
            );
          }
          field['SelectedValue'] = matchedOption;
          field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(matchedOption);
        } else if (fieldType == 'Checkbox') {
          final boolValue = defaultVal.toLowerCase() == 'true';
          field['_rxCheckboxValue'] = Rx<bool>(boolValue);
        } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
          DateTime? dateValue;
          if (defaultVal.isNotEmpty) {
            try {
              dateValue = DateTime.parse(defaultVal);
            } catch (e) {
              print("Error parsing date: $e");
            }
          }
          field['_rxDateValue'] = Rx<DateTime?>(dateValue);
        } else if (fieldType == 'LongInteger') {
          field['_rxIntValue'] = Rx<int?>(int.tryParse(defaultVal));
        } else if (fieldType == 'Decimal') {
          field['_rxDoubleValue'] = Rx<double?>(double.tryParse(defaultVal));
        } else if (fieldType == 'Email') {
          field['_rxStringValue'] = Rx<String?>(defaultVal);
          field['_controller'] = TextEditingController(text: defaultVal);
          field['_focusNode'] = FocusNode();
        } else if (fieldType == 'MobileNumber') {
          field['_rxStringValue'] = Rx<String?>(defaultVal);
          field['_controller'] = TextEditingController(text: defaultVal);
          field['_focusNode'] = FocusNode();
        } else {
          field['_rxStringValue'] = Rx<String?>(defaultVal);
          field['_controller'] = TextEditingController(text: defaultVal);
          field['_focusNode'] = FocusNode();
        }

        field['Error'] = null;
        targetController.customFieldsItems.add(field);
      }
    }
    targetController.customFieldsItems.refresh();
  }

  void _initializeItemizeControllers() {
    itemizeControllers.clear();
    final mainController = Get.find<Controller>();
    if (expenseTrans.isEmpty) {
      _itemizeCount = 0;
      return;
    }

    for (int index = 0; index < expenseTrans.length; index++) {
      final item = expenseTrans[index];
      final newController = Controller();

      // Set basic fields
      newController.categoryController.text = item['ExpenseCategory'] ?? '';
      newController.descriptionController.text = item['Description'] ?? '';
      newController.quantity.text = (item['Quantity'] ?? 1).toStringAsFixed(2);
      newController.unitPriceTrans.text = (item['UnitPriceTrans'] ?? 0)
          .toStringAsFixed(2);
      newController.uomId.text = item['UomId'] ?? '';
      newController.taxAmount.text = (item['TaxAmount'] ?? 0).toStringAsFixed(
        2,
      );
      newController.isReimbursable = item['IsReimbursable'] ?? true;
      newController.isBillableCreate = item['IsBillable'] ?? false;

      newController.calculateLineAmounts(newController);

      // Load category custom fields
      final matchingCategory = controller.expenseCategory.firstWhereOrNull(
        (c) => c.categoryId == item['ExpenseCategory'],
      );
      if (matchingCategory != null) {
        _loadCategoryCustomFields(matchingCategory, newController);
      }

      itemizeControllers.add(newController);
    }

    _itemizeCount = expenseTrans.length;
  }

void _addItemize() {
  if (_itemizeCount < 5) {
    setState(() {
      // Create a new controller
      final newController = Controller();
      
      // Set default values similar to ExpenseItemUpdate
      newController.descriptionController.text = '';
      newController.quantity.text = '1.00';
      newController.unitPriceTrans.text = '0.00';
      newController.lineAmount.text = '0.00';
      newController.lineAmountINR.text = '0.00';
      newController.taxAmount.text = '0.00';
      newController.isReimbursable = false;
      newController.isBillableCreate = controller.isBillableCreate;
      newController.projectDropDowncontroller.text = '';
       newController.selectedCategory = _itemizeCount == 1? controller.selectedCategory : null;
        newController.categoryController.text = _itemizeCount == 1? controller.categoryController.text : '';
        newController.selectedCategoryId = _itemizeCount == 1? controller.selectedCategoryId : '';
      // Set default expense category if available
      // if (controller.expenseCategory.isNotEmpty) {
      //   final defaultCategory = controller.expenseCategory;
      //   newController.selectedCategory = defaultCategory;
      //   newController.categoryController.text = defaultCategory.categoryId;
      //   newController.selectedCategoryId = defaultCategory.categoryId;
        
      //   // Load category custom fields
      //   _loadCategoryCustomFields(defaultCategory, newController);
      // }
      
      // Set default unit if available
      if (controller.unit.isNotEmpty) {
        final defaultUnit = controller.unit.firstWhere(
          (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
          orElse: () => controller.unit.first,
        );
        newController.selectedunit = defaultUnit;
        newController.uomId.text = defaultUnit.code;
      }
      
      // Set default tax group if available
      if (controller.taxGroup.isNotEmpty) {
        final defaultTax = controller.taxGroup.first;
        newController.selectedTax = defaultTax;
        newController.taxGroupController.text = defaultTax.taxGroupId;
      }
      
      // Copy project selection from first item if it exists and has a project
      if (itemizeControllers.isNotEmpty) {
        final firstItem = itemizeControllers.first;
        if (firstItem.selectedProject != null) {
          newController.selectedProject = firstItem.selectedProject;
          newController.projectDropDowncontroller.text = 
              firstItem.projectDropDowncontroller.text;
        }
      }
      
      // Add the new controller to the list
      itemizeControllers.add(newController);
      _itemizeCount++;
      
      // Update line amounts
      _updateAllLineItems();
    });
  } else {
    // Show a toast or snackbar when max limit reached
    Fluttertoast.showToast(
      msg: 'Maximum 5 items allowed',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

  void _removeItemize(int index) {
    if (_itemizeCount > 1) {
      setState(() {
        itemizeControllers.removeAt(index);
        _itemizeCount--;
      });
    }
  }

  void _updateAllLineItems() {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    double total = 0.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      itemController.calculateLineAmounts(itemController);

      final lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
      final lineAmountInINR = lineAmount * rate;
      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);
      total += lineAmount;
    }

    controller.paidAmount.text = total.toStringAsFixed(2);
    controller.amountINR.text = (total * rate).toStringAsFixed(2);
  }

  String? _validateRequiredField(
    String value,
    String fieldName,
    bool isMandatory,
  ) {
    if (isMandatory && (value.isEmpty || value.trim().isEmpty)) {
      return '$fieldName ${AppLocalizations.of(context)!.fieldRequired}';
    }
    return null;
  }

  String? _validateNumericField(
    String value,
    String fieldName,
    bool isMandatory,
  ) {
    if (isMandatory && value.isEmpty) {
      return '$fieldName ${AppLocalizations.of(context)!.fieldRequired}';
    }
    if (value.isNotEmpty) {
      final numericValue = double.tryParse(value);
      if (numericValue == null) {
        return '$fieldName ${AppLocalizations.of(context)!.requestError}';
      }
      if (numericValue < 0) {
        return '$fieldName ${AppLocalizations.of(context)!.requestError}';
      }
    }
    return null;
  }

  bool _validateForm() {
    String? firstError;

    void check(String? error) {
      if (error != null && firstError == null) {
        firstError = error;
      }
    }

    if (!controller.isManualEntryMerchant) {
      check(
        _validateRequiredField(
          controller.paidToController.text,
          AppLocalizations.of(context)!.selectMerchant,
          true,
        ),
      );
    } else {
      check(
        _validateRequiredField(
          controller.manualPaidToController.text,
          AppLocalizations.of(context)!.enterMerchantName,
          true,
        ),
      );
    }

    check(
      _validateNumericField(
        controller.paidAmount.text,
        AppLocalizations.of(context)!.paidAmount,
        true,
      ),
    );

    check(
      _validateRequiredField(
        controller.currencyDropDowncontroller.text,
        AppLocalizations.of(context)!.currency,
        true,
      ),
    );

    check(
      _validateNumericField(
        controller.unitRate.text,
        AppLocalizations.of(context)!.rate,
        true,
      ),
    );

    if (isRefrenceIDConfig.isEnabled && isRefrenceIDConfig.isMandatory) {
      check(
        _validateRequiredField(
          referenceController.text,
          AppLocalizations.of(context)!.referenceId,
          true,
        ),
      );
    }

    for (int i = 0; i < itemizeControllers.length; i++) {
      final item = itemizeControllers[i];

      if (projectConfig.isEnabled && projectConfig.isMandatory) {
        check(
          _validateRequiredField(
            item.projectDropDowncontroller.text,
            "Item ${i + 1} Project",
            true,
          ),
        );
      }

      check(
        _validateRequiredField(
          item.categoryController.text,
          "Item ${i + 1} Category",
          true,
        ),
      );

      check(
        _validateRequiredField(item.uomId.text, "Item ${i + 1} Unit", true),
      );

      check(
        _validateNumericField(
          item.quantity.text,
          "Item ${i + 1} Quantity",
          true,
        ),
      );

      check(
        _validateNumericField(
          item.unitPriceTrans.text,
          "Item ${i + 1} Unit Amount",
          true,
        ),
      );

      if (taxGroupConfig.isEnabled && taxGroupConfig.isMandatory) {
        check(
          _validateRequiredField(
            item.taxGroupController.text,
            "Item ${i + 1} Tax Group",
            true,
          ),
        );
      }

      if (taxAmountConfig.isEnabled && taxAmountConfig.isMandatory) {
        check(
          _validateNumericField(
            item.taxAmount.text,
            "Item ${i + 1} Tax Amount",
            true,
          ),
        );
      }
    }

    if (firstError != null) {
      print("Validation Error: $firstError");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firstError!), backgroundColor: Colors.red),
      );
      return false;
    }

    return true;
  }

  Future<void> _submitForm(bool value) async {
    if (!_validateForm()) {
      return;
    }

    controller.taxAmount.text = taxAmountController.text;
    // controller.descriptionController.text = descriptionController.text;
    controller.rememberMe = _isReimbursable;
    controller.isBillable.value = _isBillable;
    controller.referenceID.text = referenceController.text;
    controller.receiptDateController.text = receiptDateController.text;

    controller.finalItems.clear();

    // Build ExpenseTrans array for backend
    List<Map<String, dynamic>> expenseTransList = [];

    for (int i = 0; i < itemizeControllers.length; i++) {
      final item = itemizeControllers[i];

      // Collect custom fields for this item's ExpenseTrans
      List<Map<String, dynamic>> itemCustomFieldValues = [];
      for (var field in item.customFieldsItems) {
        final fieldId = field['FieldId'];
        final enteredValue = field['EnteredValue'];
        if (fieldId != null &&
            enteredValue != null &&
            enteredValue.toString().isNotEmpty) {
          if (field['ObjectName'] == 'ExpenseTrans') {
            itemCustomFieldValues.add({
              'FieldId': fieldId.toString(),
              'FieldValue': enteredValue.toString(),
            });
          }
        }
      }

      // Also collect ExpenseTrans fields from main controller
      for (var field in controller.customFieldsItems) {
        final fieldId = field['FieldId'];
        final enteredValue = field['EnteredValue'];
        if (fieldId != null &&
            enteredValue != null &&
            enteredValue.toString().isNotEmpty &&
            field['ObjectName'] == 'ExpenseTrans') {
          itemCustomFieldValues.add({
            'FieldId': fieldId.toString(),
            'FieldValue': enteredValue.toString(),
          });
        }
      }

      // Collect ExpenseCategories custom fields
      List<Map<String, dynamic>> expenseCategoryCustomFields = [];
      for (var field in item.customFieldsItems) {
        final fieldId = field['FieldId'];
        final enteredValue = field['EnteredValue'];
        if (fieldId != null &&
            enteredValue != null &&
            enteredValue.toString().isNotEmpty &&
            field['ObjectName'] == 'ExpenseCategories') {
          expenseCategoryCustomFields.add({
            'FieldId': fieldId.toString(),
            'FieldValue': enteredValue.toString(),
          });
        }
      }

      // Build the ExpenseTrans object
      Map<String, dynamic> expenseTrans = {
        'ExpenseCategoryId': item.categoryController.text.trim(),
        'Quantity': double.tryParse(item.quantity.text) ?? 0,
        'UomId': item.uomId.text.trim(),
        'UnitPriceTrans': double.tryParse(item.unitPriceTrans.text) ?? 0,
        'TaxAmount': double.tryParse(item.taxAmount.text) ?? 0,
        'TaxGroup': (item.selectedTax?.taxGroupId?.isNotEmpty ?? false)
            ? item.selectedTax!.taxGroupId
            : null,
        'LineAmountTrans': double.tryParse(item.lineAmount.text) ?? 0,
        'LineAmountReporting': double.tryParse(item.lineAmountINR.text) ?? 0,
        'ProjectId': item.projectDropDowncontroller.text.trim().isEmpty
            ? null
            : item.projectDropDowncontroller.text.trim(),
        'Description': item.descriptionController.text.trim(),
        'IsReimbursable': item.isReimbursable,
        'IsBillable': item.isBillableCreate,
        'AccountingDistributions': item.accountingDistributions
            .whereType<AccountingDistribution>()
            .toList(),
        'ExpenseTransCustomFieldValues': itemCustomFieldValues,
        'ExpenseTransExpensecategorycustomfieldvalues':
            expenseCategoryCustomFields,
      };

      // Remove null values to keep the object clean
      expenseTrans.removeWhere((key, value) => value == null);

      expenseTransList.add(expenseTrans);

      // Build ExpenseItem for finalItems (backward compatibility)
      // Build ExpenseTrans custom fields for this item
      final expenseTransCustomFields = item.customFieldsItems
          .where(
            (field) =>
                field['ObjectName'] == 'ExpenseTrans' &&
                (field['ExpenseType'] == 'General Expenses' ||
                    field['ExpenseType'] == null),
          )
          .map((field) {
            dynamic fieldValue;

            if (field['FieldType'] == 'List' ||
                field['FieldType'] == 'CustomList' ||
                field['FieldType'] == 'SystemList') {
              fieldValue =
                  field['SelectedValue']?.valueId ??
                  field['EnteredValue']?.toString() ??
                  '';
            } else if (field['FieldType'] == 'Checkbox') {
              fieldValue =
                  field['EnteredValue'] ??
                  (field['_rxCheckboxValue'] as Rx<bool>?)?.value ??
                  false;
            } else if (field['FieldType'] == 'Date') {
              fieldValue = field['EnteredValue'] != null
                  ? DateFormat('dd/MM/yyyy').format(field['EnteredValue'])
                  : '';
            } else if (field['FieldType'] == 'Date&Time') {
              fieldValue = field['EnteredValue'] != null
                  ? DateFormat(
                      'dd/MM/yyyy hh:mm a',
                    ).format(field['EnteredValue'])
                  : '';
            } else {
              fieldValue =
                  field['EnteredValue']?.toString() ??
                  (field['_rxStringValue'] as Rx<String?>?)?.value ??
                  '';
            }

            return {
              "CustomFieldEntity": field['CustomFieldEntity'] ?? 'ExpenseTrans',
              "FieldId": field['FieldId'] ?? '',
              "FieldValue": fieldValue,
              "FieldName": field['FieldName'] ?? '',
              "FieldType": field['FieldType'] ?? '',
            };
          })
          .toList();

      // Build category-level custom fields (ExpenseCategories)
      final expenseTransCategoryCustomFields = item.customFieldsItems
          .where((field) => field['ObjectName'] == 'ExpenseCategories')
          .map((field) {
            dynamic fieldValue;

            if (field['FieldType'] == 'List' ||
                field['FieldType'] == 'CustomList' ||
                field['FieldType'] == 'SystemList') {
              fieldValue =
                  field['SelectedValue']?.valueId ??
                  field['EnteredValue']?.toString() ??
                  field['DefaultValue']?.toString() ??
                  '';
            } else if (field['FieldType'] == 'Checkbox') {
              fieldValue =
                  field['EnteredValue'] ??
                  (field['_rxCheckboxValue'] as Rx<bool>?)?.value ??
                  false;
            } else if (field['FieldType'] == 'Date') {
              fieldValue = field['EnteredValue'] != null
                  ? DateFormat('dd/MM/yyyy').format(field['EnteredValue'])
                  : '';
            } else if (field['FieldType'] == 'Date&Time') {
              fieldValue = field['EnteredValue'] != null
                  ? DateFormat(
                      'dd/MM/yyyy hh:mm a',
                    ).format(field['EnteredValue'])
                  : '';
            } else {
              fieldValue =
                  field['EnteredValue']?.toString() ??
                  (field['_rxStringValue'] as Rx<String?>?)?.value ??
                  '';
            }

            return {
              "CustomFieldEntity": "ExpenseCategories",
              "FieldId": field['FieldId'] ?? '',
              "FieldValue": fieldValue,
              "FieldName": field['FieldName'] ?? '',
              "FieldType": field['FieldType'] ?? '',
            };
          })
          .toList();

      // Create and add ExpenseItem
      controller.finalItems.add(
        ExpenseItem(
          expenseCategoryId: item.categoryController.text.trim(),
          quantity: double.tryParse(item.quantity.text) ?? 1.00,
          uomId: item.selectedunit?.code ?? '',
          unitPriceTrans: double.tryParse(item.unitPriceTrans.text) ?? 0,
          taxAmount: double.tryParse(item.taxAmount.text) ?? 0,
          taxGroup: item.selectedTax?.taxGroupId,
          lineAmountTrans: double.tryParse(item.lineAmount.text) ?? 0,
          lineAmountReporting: double.tryParse(item.lineAmountINR.text) ?? 0,
          projectId: item.projectDropDowncontroller.text.trim().isEmpty
              ? null
              : item.projectDropDowncontroller.text.trim(),
          description: item.descriptionController.text.trim(),
          isReimbursable: item.isReimbursable,
          isBillable: item.isBillableCreate,
          accountingDistributions: item.accountingDistributions
              .whereType<AccountingDistribution>()
              .toList(),
          expenseTransCustomFieldValues: expenseTransCustomFields,
          expenseTransExpensecategorycustomfieldvalues:
              expenseTransCategoryCustomFields,
        ),
      );
    }

    // Collect header custom fields
    List<Map<String, dynamic>> headerCustomFieldValues = [];
    for (var field in controller.customFieldsItems) {
      if (field['ObjectName'] == 'ExpenseHeader') {
        final fieldId = field['FieldId'];
        final enteredValue = field['EnteredValue'];
        if (fieldId != null &&
            enteredValue != null &&
            enteredValue.toString().isNotEmpty) {
          headerCustomFieldValues.add({
            'FieldId': fieldId.toString(),
            'FieldValue': enteredValue.toString(),
          });
        }
      }
    }

    // Set the expenseTransList in the controller before saving
    controller.expenseTransListForSubmit = expenseTransList;

    print("✅ Built ${expenseTransList.length} expense transactions");
    print("✅ Built ${controller.finalItems.length} final items");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imageFile.existsSync()) {
        controller.imageFiles.add(widget.imageFile);
      }
    });

    await controller.saveGeneralExpense(context, value, false);
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

        if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
          final croppedFile = await _cropImage(file);
          if (croppedFile != null) {
            final croppedImage = File(croppedFile.path);
            final compressedImage = await _compressImage(croppedImage);
            await _processSelectedFile(compressedImage ?? croppedImage);
          }
        } else {
          await _processSelectedFile(file);
        }
      }
    } catch (e) {
      debugPrint("❌ File pick error: $e");
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) return null;
      return File(compressedFile.path);
    } catch (e) {
      debugPrint('❌ Compression error: $e');
      return null;
    }
  }

  Future<void> _processSelectedFile(File file) async {
    final featureStates = await controller.getAllFeatureStates();

    if (controller.digiScanEnable!) {
      await controller.sendUploadedFileToServer(context, file);
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.autoScan,
        arguments: {'imageFile': file, 'apiResponse': {}},
      );
    }
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
            allowCashAd = settings.allowCashAdvAgainstExpenseReg;
          });
        }
      });
    }
  }

  Future<void> _initializeUnits() async {
    await controller.fetchUnit();

    final defaultUnit = controller.unit.firstWhere(
      (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
      orElse: () => controller.unit.first,
    );

    setState(() {
      controller.selectedunit ??= defaultUnit;
    });
  }

  void _showDuplicateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.duplicateReceiptDetected),
        content: Text(AppLocalizations.of(context)!.duplicateReceiptWarning),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.dashboard_Main);
              controller.isDuplicated = false;
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.continueText),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeFormFromApiResponse() async {
    final receiptTimestamp = widget.apiResponse?['ReceiptDate'];
    final date = (receiptTimestamp != null && receiptTimestamp != 0)
        ? DateTime.fromMillisecondsSinceEpoch(receiptTimestamp, isUtc: true)
        : DateTime.now();

    receiptDateController.text = DateFormat(
      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
    ).format(date);

    controller.selectedDate = date;
    controller.isManualEntryMerchant = true;
    controller.manualPaidToController.text =
        widget.apiResponse!['Merchant'] ?? '';
    referenceController.text = widget.apiResponse!['ReferenceNumber'] ?? '';
    controller.paidAmount.text = (widget.apiResponse!['TotalAmountTrans'] ?? 0)
        .toStringAsFixed(2);
    taxAmountController.text = (widget.apiResponse!['TaxAmount'] ?? 0)
        .toStringAsFixed(2);
    controller.descriptionController.text = widget.apiResponse!['Description'] ?? '';
    controller.paidWithController.text =
        widget.apiResponse!['PaymentMethodId'] ?? '';
    controller.currencyDropDowncontroller.text =
        widget.apiResponse!['Currency'] ?? '';

    commentsController.text = widget.apiResponse!['Comments'] ?? '';
    controller.isAlcohol = widget.apiResponse!['IsAlcohol'] ?? false;
    controller.isTobacco = widget.apiResponse!['IsTobacco'] ?? false;
    controller.isDuplicated = widget.apiResponse!['IsDuplicated'] ?? false;
    controller.categoryController.text =
        widget.apiResponse!['ExpenseCategoryId'] ?? '';

    if (controller.isDuplicated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDuplicateDialog(context);
      });
    }

    // Load header custom fields
    final savedCustomFields =
        widget.apiResponse?['ExpenseHeaderCustomFieldValues'] as List?;
    if (savedCustomFields != null && savedCustomFields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadAllCustomFieldValues(
          savedValues: savedCustomFields.cast<Map<String, dynamic>>(),
        );
      });
    }

    _initializeItemizeControllers();
    waitForDropdownDataAndSetValues();
  }

  Future<void> waitForDropdownDataAndSetValues() async {
    int retries = 0;
    while ((controller.paymentMethods.isEmpty ||
            controller.expenseCategory.isEmpty) &&
        retries < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }

    if (controller.paymentMethods.isNotEmpty) {
      controller.selectedPaidWith = controller.paymentMethods.firstWhere(
        (e) => e.paymentMethodId == controller.paidWithController.text,
        orElse: () => controller.paymentMethods.first,
      );
      controller.isReimbursableEnabled.value =
          controller.selectedPaidWith!.reimbursible;
    }
    if (controller.expenseCategory.isNotEmpty) {
      controller.selectedCategory = controller.expenseCategory.firstWhere(
        (c) => c.categoryId == controller.categoryController.text,
        orElse: () => controller.expenseCategory.first,
      );

      if (controller.selectedCategory != null) {
        controller.itemisationMandatory.value =
            controller.selectedCategory!.itemisationMandatory;
        controller.minExpenseAmount.value =
            (controller.selectedCategory!.minExpensesAmount ?? 0).toDouble();
        controller.maxExpenseAmount.value =
            (controller.selectedCategory!.maxExpenseAmount ?? 0).toDouble();
        controller.receiptRequiredLimit.value =
            (controller.selectedCategory!.receiptRequiredLimit ?? 0).toDouble();
      }
    }

    setState(() {});
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
        IOSUiSettings(
          title: AppLocalizations.of(context)!.cropImage,
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      final croppedImage = File(croppedFile.path);
      return croppedImage;
    }

    return null;
  }

  bool _isImage(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }

  bool _isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  bool _isExcel(String path) {
    return path.toLowerCase().endsWith('.xls') ||
        path.toLowerCase().endsWith('.xlsx');
  }

  void _openFile(File file) {
    OpenFilex.open(file.path);
  }

  // UI Helpers
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isReadOnly,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: isReadOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controllers, {
    required bool isReadOnly,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controllers,
      readOnly: true,
      enabled: !isReadOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: isReadOnly
              ? null
              : () async {
                  DateTime initialDate = DateTime.now();
                  if (controllers.text.isNotEmpty) {
                    try {
                      initialDate = DateFormat(
                        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                      ).parseStrict(controllers.text.trim());
                    } catch (e) {
                      initialDate = DateTime.now();
                    }
                  }

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    controllers.text = DateFormat(
                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                    ).format(picked);
                    controller.selectedDate = picked;
                  }
                },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFileViewer() {
    return Obx(() {
      return Stack(
        children: [
          Obx(() {
            return GestureDetector(
              onTap: () {
                if (controller.imageFiles.isEmpty) {
                  _pickFile();
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: controller.imageFiles.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.tapToUploadDocs,
                        ),
                      )
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
                                onTap: () => _openFile(file),
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.deepPurple,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _isImage(path)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : _isPdf(path)
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
                                      : _isExcel(path)
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
                          // if (controller.isEnable.value)
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
          if (controller.isImageLoading.value)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildStatusBadges() {
    return Row(
      children: [
        if (controller.isAlcohol)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Image.asset('assets/alcohol.png', height: 24, width: 24),
          ),
        if (controller.isAlcohol) const SizedBox(width: 10),
        Obx(() {
          final iconPath = controller.selectedIcon.value;
          final showIcon = iconPath.isNotEmpty;
          return Row(
            children: [
              if (showIcon)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: _buildCategoryIcon(iconPath),
                ),
            ],
          );
        }),
        if (controller.isTobacco) const SizedBox(width: 10),
        if (controller.isTobacco)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Image.asset('assets/Tobacco.jpg', height: 24, width: 24),
          ),
        const SizedBox(width: 10),
        if (controller.isDuplicated)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Image.asset(
              'assets/duplicateIcons.png',
              height: 24,
              width: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryIcon(String iconPath) {
    if (iconPath.startsWith('data:image')) {
      try {
        final base64Data = iconPath.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(bytes, height: 24, width: 24, fit: BoxFit.contain);
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.redAccent);
      }
    } else {
      return const Icon(Icons.broken_image, color: Colors.redAccent);
    }
  }

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

  Widget _buildItemizeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.itemize} ${AppLocalizations.of(context)!.expense}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemizeControllers.length,
          itemBuilder: (context, index) {
            final itemController = itemizeControllers[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.item} ${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            if (itemizeControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItemize(index),
                                tooltip: 'Remove this item',
                              ),
                            // if (controller.isEnable.value)
                            FutureBuilder<Map<String, bool>>(
                              future: _featureFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                final isEnabled =
                                    snapshot.data!['EnableItemization'] ??
                                    false;

                                print("EnableItemization$isEnabled");
                                if (!isEnabled) {
                                  return const SizedBox.shrink();
                                }
                                return IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                                  onPressed: _addItemize,
                                  tooltip: 'Add new item',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Dropdown
                        SearchableMultiColumnDropdownField<ExpenseCategory>(
                          labelText: AppLocalizations.of(context)!.paidFor,
                          // enabled: controller.isEnable.value,
                          columnHeaders: [
                            AppLocalizations.of(context)!.categoryName,
                            AppLocalizations.of(context)!.categoryId,
                          ],
                          items: controller.expenseCategory,
                          selectedValue: itemController.selectedCategory,
                          searchValue: (p) =>
                              '${p.categoryName} ${p.categoryId}',
                          displayText: (p) => p.categoryId,
                          validator: (value) => _validateRequiredField(
                            itemController.categoryController.text,
                            AppLocalizations.of(context)!.paidFor,
                            true,
                          ),
                          onChanged: (p) {
                            if (p == null) return;

                            setState(() {
                              // Update basic category info
                              itemController.selectedCategory = p;
                              itemController.selectedCategoryId = p.categoryId;
                              itemController.categoryController.text =
                                  p.categoryId;
                              itemController.itemisationMandatory.value =
                                  p.itemisationMandatory;
                              itemController.minExpenseAmount.value =
                                  (p.minExpensesAmount ?? 0).toDouble();
                              itemController.receiptRequiredLimit.value =
                                  (p.receiptRequiredLimit ?? 0).toDouble();
                              itemController.maxExpenseAmount.value =
                                  (p.maxExpenseAmount ?? 0).toDouble();

                              // Remove existing ExpenseCategories custom fields
                              itemController.customFieldsItems.removeWhere(
                                (field) =>
                                    field['ObjectName'] == 'ExpenseCategories',
                              );

                              // Add new custom fields from the selected category
                              if (p.customFields != null &&
                                  p.customFields!.isNotEmpty) {
                                for (var categoryField in p.customFields!) {
                                  final Map<String, dynamic> field =
                                      Map<String, dynamic>.from(categoryField);

                                  field['ObjectName'] = 'ExpenseCategories';
                                  field['ExpenseType'] = 'General Expenses';

                                  final defaultVal =
                                      field['DefaultValue']?.toString() ?? '';
                                  field['EnteredValue'] = defaultVal;

                                  final fieldType = field['FieldType'];

                                  // Initialize based on field type
                                  if (fieldType == 'List' ||
                                      fieldType == 'CustomList' ||
                                      fieldType == 'SystemList') {
                                    final options =
                                        field['Options']
                                            as List<CustomDropdownValue>?;
                                    CustomDropdownValue? matchedOption;
                                    if (options != null &&
                                        defaultVal.isNotEmpty) {
                                      matchedOption = options.firstWhereOrNull(
                                        (opt) =>
                                            opt.valueName == defaultVal ||
                                            opt.valueId == defaultVal,
                                      );
                                    }
                                    field['SelectedValue'] = matchedOption;
                                    field['_rxSelectedValue'] =
                                        Rx<CustomDropdownValue?>(matchedOption);
                                  } else if (fieldType == 'Checkbox') {
                                    final boolValue =
                                        defaultVal.toLowerCase() == 'true';
                                    field['_rxCheckboxValue'] = Rx<bool>(
                                      boolValue,
                                    );
                                  } else if (fieldType == 'Date' ||
                                      fieldType == 'Date&Time') {
                                    DateTime? dateValue;
                                    if (defaultVal.isNotEmpty) {
                                      try {
                                        dateValue = DateTime.parse(defaultVal);
                                      } catch (e) {
                                        print("Error parsing date: $e");
                                      }
                                    }
                                    field['_rxDateValue'] = Rx<DateTime?>(
                                      dateValue,
                                    );
                                  } else if (fieldType == 'LongInteger') {
                                    field['_rxIntValue'] = Rx<int?>(
                                      int.tryParse(defaultVal),
                                    );
                                  } else if (fieldType == 'Decimal') {
                                    field['_rxDoubleValue'] = Rx<double?>(
                                      double.tryParse(defaultVal),
                                    );
                                  } else if (fieldType == 'Email') {
                                    field['_rxStringValue'] = Rx<String?>(
                                      defaultVal,
                                    );
                                    field['_controller'] =
                                        TextEditingController(text: defaultVal);
                                    field['_focusNode'] = FocusNode();
                                  } else if (fieldType == 'MobileNumber') {
                                    // Initialize mobile number field
                                    field['_rxStringValue'] = Rx<String?>(
                                      defaultVal,
                                    );
                                    field['_controller'] =
                                        TextEditingController(text: defaultVal);
                                    field['_focusNode'] = FocusNode();
                                  } else {
                                    field['_rxStringValue'] = Rx<String?>(
                                      defaultVal,
                                    );
                                    field['_controller'] =
                                        TextEditingController(text: defaultVal);
                                    field['_focusNode'] = FocusNode();
                                  }

                                  field['Error'] = null;
                                  itemController.customFieldsItems.add(field);
                                }
                              }

                              itemController.customFieldsItems.refresh();
                            });
                          },
                          controller: itemController.categoryController,
                          rowBuilder: (p, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(p.categoryName)),
                                  Expanded(child: Text(p.categoryId)),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        // Project field (if enabled)
                        if (projectConfig.isEnabled)
                          SearchableMultiColumnDropdownField<Project>(
                            // enabled: controller.isEnable.value,
                            labelText:
                                "${AppLocalizations.of(context)!.projectId} ${projectConfig.isMandatory ? "*" : ""}",
                            columnHeaders: const ['Project Name', 'Project ID'],
                            items: controller.project,
                            selectedValue: itemController.selectedProject,
                            searchValue: (p) => '${p.name} ${p.code}',
                            displayText: (p) => p.code,
                            onChanged: (p) {
                              setState(() {
                                itemController.selectedProject = p;
                                itemController.projectDropDowncontroller.text =
                                    p!.code;
                              });
                            },
                            controller:
                                itemController.projectDropDowncontroller,
                            rowBuilder: (p, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(p.name)),
                                    Expanded(child: Text(p.code)),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 8),

                        // Tax Group field (if enabled)
                        if (taxGroupConfig.isEnabled)
                          SearchableMultiColumnDropdownField<TaxGroupModel>(
                            // enabled: controller.isEnable.value,
                            labelText:
                                "${AppLocalizations.of(context)!.taxGroup} ${taxGroupConfig.isMandatory ? "*" : ""}",
                            columnHeaders: [
                              AppLocalizations.of(context)!.taxGroup,
                              AppLocalizations.of(context)!.taxId,
                            ],
                            items: controller.taxGroup,
                            selectedValue: itemController.selectedTax,
                            searchValue: (tax) =>
                                '${tax.taxGroup} ${tax.taxGroupId}',
                            displayText: (tax) => tax.taxGroupId,
                            onChanged: (tax) {
                              setState(() {
                                itemController.selectedTax = tax;
                                itemController.taxGroupController.text =
                                    tax!.taxGroupId;
                              });
                            },
                            controller: itemController.taxGroupController,
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
                        const SizedBox(height: 8),

                        // Tax Amount field (if enabled)
                        if (taxAmountConfig.isEnabled)
                          _buildTextField(
                            isReadOnly: controller.isEnable.value,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            label:
                                "${AppLocalizations.of(context)!.taxAmount} ${taxAmountConfig.isMandatory ? "*" : ""}",
                            controller: itemController.taxAmount,
                            // isReadOnly: controller.isEnable.value,
                            onChanged: (value) => _updateAllLineItems(),
                          ),
                        const SizedBox(height: 8),

                        // CUSTOM FIELDS SECTION - COMBINED ExpenseTrans AND ExpenseCategories
                        // CUSTOM FIELDS SECTION - COMBINED ExpenseTrans AND ExpenseCategories
                        // Use a ListView.builder with unique keys to prevent focus issues
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Get ExpenseTrans fields from main controller
                            ...controller.customFields
                                .where(
                                  (field) =>
                                      field['ObjectName'] == 'ExpenseTrans' &&
                                      (field['ExpenseType'] ==
                                              'General Expenses' ||
                                          field['ExpenseType'] == null),
                                )
                                .map(
                                  (field) => _buildCustomField(
                                    field: field,
                                    isCategoryField: false,
                                    itemController: itemController,
                                    fieldKeyPrefix:
                                        'trans_${itemController.hashCode}',
                                  ),
                                )
                                .toList(),

                            // Get ExpenseCategories fields from item controller
                            ...itemController.customFieldsItems
                                .where(
                                  (field) =>
                                      field['ObjectName'] ==
                                      'ExpenseCategories',
                                )
                                .map(
                                  (field) => _buildCustomField(
                                    field: field,
                                    isCategoryField: true,
                                    itemController: itemController,
                                    fieldKeyPrefix:
                                        'category_${itemController.hashCode}',
                                  ),
                                )
                                .toList(),
                          ],
                        ),

                        // Unit Dropdown
                        SearchableMultiColumnDropdownField<Unit>(
                          labelText: '${AppLocalizations.of(context)!.unit} *',
                          // enabled: controller.isEnable.value,
                          columnHeaders: [
                            AppLocalizations.of(context)!.uomId,
                            AppLocalizations.of(context)!.uomName,
                          ],
                          items: controller.unit,
                          selectedValue: itemController.selectedunit,
                          searchValue: (tax) => '${tax.code} ${tax.name}',
                          displayText: (tax) => tax.code,
                          validator: (value) => _validateRequiredField(
                            itemController.uomId.text,
                            AppLocalizations.of(context)!.unit,
                            true,
                          ),
                          onChanged: (tax) {
                            setState(() {
                              itemController.selectedunit = tax;
                              itemController.uomId.text = tax!.code;
                            });
                          },
                          controller: itemController.uomId,
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
                        const SizedBox(height: 8),

                        // Quantity
                        _buildTextField(
                          isReadOnly: controller.isEnable.value,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          label: "${AppLocalizations.of(context)!.quantity} *",
                          controller: itemController.quantity,
                          // isReadOnly: controller.isEnable.value,
                          validator: (value) => _validateNumericField(
                            value!,
                            AppLocalizations.of(context)!.quantity,
                            true,
                          ),
                          onChanged: (value) {
                            _updateAllLineItems();
                          },
                        ),
                        const SizedBox(height: 8),

                        // Unit Amount
                        _buildTextField(
                          isReadOnly: controller.isEnable.value,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          label:
                              "${AppLocalizations.of(context)!.unitAmount} *",
                          controller: itemController.unitPriceTrans,
                          // isReadOnly: controller.isEnable.value,
                          validator: (value) => _validateNumericField(
                            value!,
                            AppLocalizations.of(context)!.unitAmount,
                            true,
                          ),
                          onChanged: (value) {
                            _updateAllLineItems();
                          },
                        ),
                        const SizedBox(height: 8),

                        // Line Amount
                        _buildTextField(
                          label: AppLocalizations.of(context)!.lineAmount,
                          controller: itemController.lineAmount,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 8),

                        // Line Amount in INR
                        _buildTextField(
                          label:
                              '${AppLocalizations.of(context)!.lineAmountInInr} ${controller.organizationCurrency}',
                          controller: itemController.lineAmountINR,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 8),

                        // Description
                        TextFormField(
                          controller: commentsController,
                          // enabled: controller.isEnable.value,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.comments,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),

                        // Is Reimbursable Switch
                        if (isReimbursibleConfig.isEnabled)
                          Obx(() {
                            final selectedPaymentMethod = controller
                                .paymentMethods
                                .firstWhereOrNull(
                                  (p) =>
                                      p.paymentMethodId ==
                                      controller.paidWithCashAdvance.value,
                                );

                            final isPaymentMethodNonReimbursable =
                                selectedPaymentMethod?.reimbursible == false;

                            final isSwitchEnabled =
                                controller.isReimbursableEnabled.value &&
                                !isPaymentMethodNonReimbursable;

                            if (isPaymentMethodNonReimbursable &&
                                itemController.isReimbursable) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && itemController.isReimbursable) {
                                  setState(() {
                                    itemController.isReimbursable = false;
                                  });
                                }
                              });
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SwitchListTile(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.isReimbursable,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: itemController.isReimbursable,
                                  activeThumbColor: Colors.green,
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade300,
                                  onChanged: isSwitchEnabled
                                      ? (val) {
                                          setState(() {
                                            itemController.isReimbursable = val;
                                          });
                                        }
                                      : null,
                                ),
                                if (!isSwitchEnabled &&
                                    isPaymentMethodNonReimbursable)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 0,
                                    ),
                                    child: Text(
                                      'Item is not reimbursable with selected payment method',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),

                        // Is Billable Switch
                        if (isBillableConfig.isEnabled)
                          // final isSwitchEnabled = controller.isEnable.value;
                          SwitchListTile(
                            title: Text(
                              AppLocalizations.of(context)!.isBillable,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: itemController.isBillableCreate,
                            activeThumbColor: Colors.blue,
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade300,
                            onChanged: (val) {
                              setState(() {
                                itemController.isBillableCreate = val;
                              });
                            },
                          ),
                        // }),

                        // Account Distribution
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                final double lineAmount =
                                    double.tryParse(
                                      itemController.lineAmount.text,
                                    ) ??
                                    0.0;
                                if (itemController.split.isEmpty) {
                                  itemController.split.add(
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
                                        splits: itemController.split,
                                        // isEnable: controller.isEnable.value,
                                        lineAmount: lineAmount,
                                        onChanged: (i, updatedSplit) {
                                          if (mounted) {
                                            itemController.split[i] =
                                                updatedSplit;
                                          }
                                        },
                                        onDistributionChanged: (newList) {
                                          if (mounted) {
                                            itemController
                                                .accountingDistributions
                                                .clear();
                                            itemController
                                                .accountingDistributions
                                                .addAll(newList);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.accountDistribution,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomField({
    required Map<String, dynamic> field,
    required bool isCategoryField,
    required Controller itemController,
    required String fieldKeyPrefix,
  }) {
    final String label = field['FieldLabel'] ?? field['FieldName'];
    final bool isMandatory = field['IsMandatory'] ?? false;
    final String fieldType = field['FieldType'];

    final String fieldKey =
        '${fieldKeyPrefix}_${field['FieldName']}_${field['LineId'] ?? 0}_${field['RecId'] ?? 0}';

    // For text-based fields
    if (fieldType == 'Text' || fieldType == null || fieldType == '') {
      if (field['_textController'] == null) {
        final defaultValue = field['DefaultValue']?.toString() ?? '';
        final existingValue = field['EnteredValue'] as String?;
        final initialValue = existingValue ?? defaultValue;

        field['_textController'] = TextEditingController(text: initialValue);
        field['_rxStringValue'] = Rx<String?>(initialValue);
        field['_focusNode'] = FocusNode();

        (field['_textController'] as TextEditingController).addListener(() {
          final value =
              (field['_textController'] as TextEditingController).text;
          if (value != (field['_rxStringValue'] as Rx<String?>).value) {
            (field['_rxStringValue'] as Rx<String?>).value = value;
            field['EnteredValue'] = value;
            field['Error'] = null;
          }
        });
      }

      final controller = field['_textController'] as TextEditingController;
      final focusNode = field['_focusNode'] as FocusNode;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          key: ValueKey('text_$fieldKey'),
          controller: controller,
          focusNode: focusNode,
          // enabled: this.controller.isEnable.value,
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
          onChanged: (value) {
            field['EnteredValue'] = value;
            field['Error'] = null;
          },
        ),
      );
    }
    // For dropdown fields
    else if (fieldType == 'List' ||
        fieldType == 'CustomList' ||
        fieldType == 'SystemList') {
      List<CustomDropdownValue> options = [];
      if (field['Options'] != null && field['Options'] is List) {
        options = List<CustomDropdownValue>.from(field['Options']);
      }

      if (field['_controller'] == null) {
        field['_controller'] = TextEditingController();
      }
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

      fieldController.text =
          selectedValue?.valueName ?? field['DefaultValue']?.toString() ?? '';

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

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SearchableMultiColumnDropdownField<CustomDropdownValue>(
          key: ValueKey('dropdown_$fieldKey'),
          labelText: '$label${isMandatory ? " *" : ""}',
          items: options,
          selectedValue: selectedValue,
          searchValue: (val) => val.valueName,
          // enabled: this.controller.isEnable.value,
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

            if (isCategoryField) {
              itemController.customFieldsItems.refresh();
            } else {
              this.controller.customFields.refresh();
            }
          },
        ),
      );
    }
    // For Date fields
    else if (fieldType == 'Date' || fieldType == 'Date&Time') {
      final bool isDateTime = fieldType == 'Date&Time';

      if (field['_rxDateValue'] == null) {
        field['_rxDateValue'] = Rx<DateTime?>(
          field['EnteredValue'] as DateTime?,
        );
      }

      // Create stable controller that persists
      if (field['_dateController'] == null) {
        field['_dateController'] = TextEditingController();
        field['_dateFocusNode'] = FocusNode();
      }

      final dateController = field['_dateController'] as TextEditingController;
      final dateFocusNode = field['_dateFocusNode'] as FocusNode;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Obx(() {
          final currentDate = (field['_rxDateValue'] as Rx<DateTime?>).value;

          // Update controller text without triggering listener
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
            controller: dateController,
            focusNode: dateFocusNode,
            // enabled: this.controller.isEnable.value,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: const OutlineInputBorder(),
              errorText: field['Error'],
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? currentDate =
                  (field['_rxDateValue'] as Rx<DateTime?>).value ??
                  DateTime.now();

              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate == null) return;

              if (isDateTime) {
                TimeOfDay initialTime = TimeOfDay.now();
                if ((field['_rxDateValue'] as Rx<DateTime?>).value != null) {
                  initialTime = TimeOfDay.fromDateTime(
                    (field['_rxDateValue'] as Rx<DateTime?>).value!,
                  );
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

                (field['_rxDateValue'] as Rx<DateTime?>).value = fullDateTime;
                field['EnteredValue'] = fullDateTime;
                dateController.text = DateFormat(
                  'dd/MM/yyyy hh:mm a',
                ).format(fullDateTime);
              } else {
                (field['_rxDateValue'] as Rx<DateTime?>).value = pickedDate;
                field['EnteredValue'] = pickedDate;
                dateController.text = DateFormat(
                  'dd/MM/yyyy',
                ).format(pickedDate);
              }

              field['Error'] = null;
            },
            validator: (value) {
              if (isMandatory &&
                  (field['_rxDateValue'] as Rx<DateTime?>).value == null) {
                return '$label is required';
              }
              return null;
            },
          );
        }),
      );
    }
    // For numeric fields (LongInteger, Decimal)
    else if (fieldType == 'LongInteger' || fieldType == 'Decimal') {
      final bool isDecimal = fieldType == 'Decimal';

      if (field['_rxNumericValue'] == null) {
        field['_rxNumericValue'] = Rx<num?>(field['EnteredValue'] as num?);
      }

      if (field['_numericController'] == null) {
        final initialValue =
            (field['_rxNumericValue'] as Rx<num?>).value?.toString() ?? '';
        field['_numericController'] = TextEditingController(text: initialValue);
        field['_numericFocusNode'] = FocusNode();

        (field['_numericController'] as TextEditingController).addListener(() {
          final value =
              (field['_numericController'] as TextEditingController).text;
          if (value.isEmpty) {
            if ((field['_rxNumericValue'] as Rx<num?>).value != null) {
              (field['_rxNumericValue'] as Rx<num?>).value = null;
              field['EnteredValue'] = null;
            }
          } else {
            final numValue = isDecimal
                ? double.tryParse(value)
                : int.tryParse(value);
            if (numValue != null &&
                numValue != (field['_rxNumericValue'] as Rx<num?>).value) {
              (field['_rxNumericValue'] as Rx<num?>).value = numValue;
              field['EnteredValue'] = numValue;
            }
          }
          field['Error'] = null;
        });
      }

      final controller = field['_numericController'] as TextEditingController;
      final focusNode = field['_numericFocusNode'] as FocusNode;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          key: ValueKey('numeric_$fieldKey'),
          controller: controller,
          focusNode: focusNode,
          // enabled: this.controller.isEnable.value,
          keyboardType: isDecimal
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          inputFormatters: isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))]
              : [FilteringTextInputFormatter.digitsOnly],
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
        ),
      );
    }
    // For Email fields
    else if (fieldType == 'Email') {
      if (field['_emailController'] == null) {
        final defaultValue = field['DefaultValue']?.toString() ?? '';
        final existingValue = field['EnteredValue'] as String?;
        final initialValue = existingValue ?? defaultValue;

        field['_emailController'] = TextEditingController(text: initialValue);
        field['_rxStringValue'] = Rx<String?>(initialValue);
        field['_emailFocusNode'] = FocusNode();

        (field['_emailController'] as TextEditingController).addListener(() {
          final value =
              (field['_emailController'] as TextEditingController).text;
          if (value != (field['_rxStringValue'] as Rx<String?>).value) {
            (field['_rxStringValue'] as Rx<String?>).value = value;
            field['EnteredValue'] = value;
          }
          field['Error'] = null;
        });
      }

      final controller = field['_emailController'] as TextEditingController;
      final focusNode = field['_emailFocusNode'] as FocusNode;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          key: ValueKey('email_$fieldKey'),
          controller: controller,
          focusNode: focusNode,
          // enabled: this.controller.isEnable.value,
          keyboardType: TextInputType.emailAddress,
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
        ),
      );
    }
    // For MobileNumber fields
    else if (fieldType == 'MobileNumber') {
      String getIsoCodeFromDialCode(String dialCode) {
        final Map<String, String> dialCodeToIso = {
          '+93': 'AF',
          '+355': 'AL',
          '+213': 'DZ',
          '+1': 'US',
          '+376': 'AD',
          '+244': 'AO',
          '+54': 'AR',
          '+374': 'AM',
          '+61': 'AU',
          '+43': 'AT',
          '+994': 'AZ',
          '+973': 'BH',
          '+880': 'BD',
          '+375': 'BY',
          '+32': 'BE',
          '+501': 'BZ',
          '+229': 'BJ',
          '+975': 'BT',
          '+591': 'BO',
          '+387': 'BA',
          '+267': 'BW',
          '+55': 'BR',
          '+673': 'BN',
          '+359': 'BG',
          '+226': 'BF',
          '+257': 'BI',
          '+855': 'KH',
          '+237': 'CM',
          '+1': 'CA',
          '+238': 'CV',
          '+236': 'CF',
          '+235': 'TD',
          '+56': 'CL',
          '+86': 'CN',
          '+57': 'CO',
          '+269': 'KM',
          '+243': 'CD',
          '+242': 'CG',
          '+506': 'CR',
          '+385': 'HR',
          '+53': 'CU',
          '+357': 'CY',
          '+420': 'CZ',
          '+45': 'DK',
          '+253': 'DJ',
          '+1': 'DO',
          '+593': 'EC',
          '+20': 'EG',
          '+503': 'SV',
          '+240': 'GQ',
          '+291': 'ER',
          '+372': 'EE',
          '+251': 'ET',
          '+679': 'FJ',
          '+358': 'FI',
          '+33': 'FR',
          '+241': 'GA',
          '+220': 'GM',
          '+995': 'GE',
          '+49': 'DE',
          '+233': 'GH',
          '+30': 'GR',
          '+299': 'GL',
          '+502': 'GT',
          '+224': 'GN',
          '+245': 'GW',
          '+592': 'GY',
          '+509': 'HT',
          '+504': 'HN',
          '+36': 'HU',
          '+354': 'IS',
          '+91': 'IN',
          '+62': 'ID',
          '+98': 'IR',
          '+964': 'IQ',
          '+353': 'IE',
          '+972': 'IL',
          '+39': 'IT',
          '+1': 'JM',
          '+81': 'JP',
          '+962': 'JO',
          '+7': 'KZ',
          '+254': 'KE',
          '+686': 'KI',
          '+850': 'KP',
          '+82': 'KR',
          '+965': 'KW',
          '+996': 'KG',
          '+856': 'LA',
          '+371': 'LV',
          '+961': 'LB',
          '+266': 'LS',
          '+231': 'LR',
          '+218': 'LY',
          '+423': 'LI',
          '+370': 'LT',
          '+352': 'LU',
          '+261': 'MG',
          '+265': 'MW',
          '+60': 'MY',
          '+960': 'MV',
          '+223': 'ML',
          '+356': 'MT',
          '+692': 'MH',
          '+222': 'MR',
          '+230': 'MU',
          '+52': 'MX',
          '+691': 'FM',
          '+373': 'MD',
          '+377': 'MC',
          '+976': 'MN',
          '+382': 'ME',
          '+212': 'MA',
          '+258': 'MZ',
          '+95': 'MM',
          '+264': 'NA',
          '+674': 'NR',
          '+977': 'NP',
          '+31': 'NL',
          '+64': 'NZ',
          '+505': 'NI',
          '+227': 'NE',
          '+234': 'NG',
          '+389': 'MK',
          '+47': 'NO',
          '+968': 'OM',
          '+92': 'PK',
          '+680': 'PW',
          '+970': 'PS',
          '+507': 'PA',
          '+675': 'PG',
          '+595': 'PY',
          '+51': 'PE',
          '+63': 'PH',
          '+48': 'PL',
          '+351': 'PT',
          '+1': 'PR',
          '+974': 'QA',
          '+40': 'RO',
          '+7': 'RU',
          '+250': 'RW',
          '+685': 'WS',
          '+378': 'SM',
          '+239': 'ST',
          '+966': 'SA',
          '+221': 'SN',
          '+381': 'RS',
          '+248': 'SC',
          '+232': 'SL',
          '+65': 'SG',
          '+421': 'SK',
          '+386': 'SI',
          '+677': 'SB',
          '+252': 'SO',
          '+27': 'ZA',
          '+211': 'SS',
          '+34': 'ES',
          '+94': 'LK',
          '+249': 'SD',
          '+597': 'SR',
          '+46': 'SE',
          '+41': 'CH',
          '+963': 'SY',
          '+886': 'TW',
          '+992': 'TJ',
          '+255': 'TZ',
          '+66': 'TH',
          '+670': 'TL',
          '+228': 'TG',
          '+676': 'TO',
          '+216': 'TN',
          '+90': 'TR',
          '+993': 'TM',
          '+688': 'TV',
          '+256': 'UG',
          '+380': 'UA',
          '+971': 'AE',
          '+44': 'GB',
          '+1': 'US',
          '+598': 'UY',
          '+998': 'UZ',
          '+678': 'VU',
          '+58': 'VE',
          '+84': 'VN',
          '+967': 'YE',
          '+260': 'ZM',
          '+263': 'ZW',
        };
        return dialCodeToIso[dialCode] ?? 'IN';
      }

      final String mobileFieldKey = '${field['FieldId']}_${field['FieldName']}';

      // Initialize persistent controllers and values if not exists
      if (field['_phoneController'] == null) {
        final defaultValue = field['DefaultValue']?.toString() ?? '';
        final existingValue = field['EnteredValue'] as String?;
        final initialValue = existingValue ?? defaultValue;

        String countryCode = '+91';
        String phoneNumber = '';

        if (initialValue.isNotEmpty) {
          String cleanedValue = initialValue.trim();
          while (cleanedValue.startsWith('++')) {
            cleanedValue = '+' + cleanedValue.substring(2);
          }

          if (cleanedValue.startsWith('+')) {
            final RegExp regex = RegExp(r'^\+(\d+)\s*(.*)$');
            final match = regex.firstMatch(cleanedValue);
            if (match != null) {
              countryCode = '+${match.group(1)}';
              phoneNumber = match.group(2)?.trim() ?? '';
            } else {
              final String afterPlus = cleanedValue.substring(1);
              final RegExp digitsOnly = RegExp(r'^\d+');
              final matchDigits = digitsOnly.firstMatch(afterPlus);
              if (matchDigits != null) {
                countryCode = '+${matchDigits.group(0)}';
                phoneNumber = afterPlus
                    .substring(matchDigits.group(0)!.length)
                    .trim();
              } else {
                phoneNumber = cleanedValue;
              }
            }
          } else {
            phoneNumber = cleanedValue;
          }
        }

        field['_countryCodeController'] = TextEditingController(
          text: countryCode,
        );
        field['_phoneController'] = TextEditingController(text: phoneNumber);
        field['_rxStringValue'] = Rx<String?>(initialValue);
        field['_focusNode'] = FocusNode();
        field['_selectedCountryCode'] = getIsoCodeFromDialCode(countryCode);
        field['_currentCountryCode'] = Rx<String>(
          field['_selectedCountryCode'] ?? 'IN',
        );
        field['EnteredValue'] = initialValue;

        // Update EnteredValue when phone number changes
        field['_phoneController'].addListener(() {
          final phoneVal = field['_phoneController'].text;
          final codeVal = field['_countryCodeController'].text;
          String fullNumber = '';

          if (phoneVal.isNotEmpty) {
            fullNumber = '$codeVal $phoneVal';
          } else if (codeVal.isNotEmpty) {
            fullNumber = codeVal;
          }

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
          String fullNumber = '';

          if (phoneVal.isNotEmpty) {
            fullNumber = '$codeVal $phoneVal';
          } else if (codeVal.isNotEmpty) {
            fullNumber = codeVal;
          }

          if (fullNumber != field['_rxStringValue'].value) {
            field['_rxStringValue'].value = fullNumber;
            field['EnteredValue'] = fullNumber;
          }
          field['Error'] = null;
        });
      }

      // Use Obx instead of ValueListenableBuilder
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Obx(() {
          final phoneController =
              field['_phoneController'] as TextEditingController;
          final countryCodeController =
              field['_countryCodeController'] as TextEditingController;
          final focusNode = field['_focusNode'] as FocusNode;
          final currentCountryCode = field['_currentCountryCode'] as Rx<String>;

          String currentDialCode = countryCodeController.text;
          if (currentDialCode.isNotEmpty && !currentDialCode.startsWith('+')) {
            currentDialCode = '+$currentDialCode';
          }
          currentDialCode = currentDialCode.trim();

          String cleanDialCode = currentDialCode;
          final dialCodeMatch = RegExp(r'^\+(\d+)').firstMatch(currentDialCode);
          if (dialCodeMatch != null) {
            cleanDialCode = '+${dialCodeMatch.group(1)}';
          }

          final isoCode = getIsoCodeFromDialCode(cleanDialCode);

          // Update the stored country code if changed
          if (currentCountryCode.value != isoCode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (currentCountryCode.value != isoCode) {
                currentCountryCode.value = isoCode;
              }
            });
          }

          return IntlPhoneField(
            key: ValueKey('${mobileFieldKey}_${currentCountryCode.value}'),
            controller: phoneController,
            focusNode: focusNode,
            keyboardType: TextInputType.phone,
            // enabled: this.controller.isEnable.value,
            decoration: InputDecoration(
              labelText: '$label${isMandatory ? " *" : ""}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              errorText: field['Error'],
              counterText: "",
            ),
            initialCountryCode: currentCountryCode.value,
            onChanged: (phone) {
              countryCodeController.text = '+${phone.countryCode}';
              phoneController.text = phone.number;

              final newIsoCode = getIsoCodeFromDialCode(
                '+${phone.countryCode}',
              );
              if (currentCountryCode.value != newIsoCode) {
                currentCountryCode.value = newIsoCode;
              }

              final fullNumber = phone.number.isNotEmpty
                  ? '+${phone.countryCode} ${phone.number}'
                  : '+${phone.countryCode}';

              if (fullNumber != field['_rxStringValue'].value) {
                field['_rxStringValue'].value = fullNumber;
                field['EnteredValue'] = fullNumber;
              }

              field['Error'] = null;
            },
            onCountryChanged: (country) {
              countryCodeController.text = '+${country.dialCode}';

              final newIsoCode = getIsoCodeFromDialCode('+${country.dialCode}');
              if (currentCountryCode.value != newIsoCode) {
                currentCountryCode.value = newIsoCode;
              }

              final currentNumber = phoneController.text;
              final fullNumber = currentNumber.isNotEmpty
                  ? '+${country.dialCode} $currentNumber'
                  : '+${country.dialCode}';

              if (fullNumber != field['_rxStringValue'].value) {
                field['_rxStringValue'].value = fullNumber;
                field['EnteredValue'] = fullNumber;
              }

              field['Error'] = null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]+')),
            ],
            validator: (phone) {
              if (isMandatory) {
                if (phone == null || phone.number.trim().isEmpty) {
                  return '$label is required';
                }

                final cleanNumber = phone.number.replaceAll(
                  RegExp(r'[\s\-]'),
                  '',
                );
                if (cleanNumber.length < 6 || cleanNumber.length > 15) {
                  return 'Enter a valid mobile number (6-15 digits)';
                }
              }
              return null;
            },
          );
        }),
      );
    }
    // For Checkbox fields
    else if (fieldType == 'Checkbox') {
      if (field['_rxCheckboxValue'] == null) {
        final defaultValue =
            field['DefaultValue']?.toString().toLowerCase() == 'true';
        final existingValue = field['EnteredValue'] as bool?;
        final initialValue = existingValue ?? defaultValue;

        field['_rxCheckboxValue'] = Rx<bool>(initialValue);
        field['EnteredValue'] = initialValue;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Obx(() {
          final rxValue = field['_rxCheckboxValue'] as Rx<bool>;
          return Row(
            children: [
              Checkbox(
                value: rxValue.value,
                onChanged: (val) {
                  rxValue.value = val ?? false;
                  field['EnteredValue'] = val ?? false;
                  field['Error'] = null;
                },
              ),
              Expanded(
                child: Text(
                  '$label${isMandatory ? " *" : ""}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        }),
      );
    }

    // Return an empty container for unknown field types
    debugPrint('Unsupported field type: $fieldType for field: $label');
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  controller.closeField();
                  Navigator.pushNamed(context, AppRoutes.dashboard_Main);
                },
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          controller.clearFormFields();
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.expenseReport),
        ),
        body: Obx(() {
          return controller.isLoadingOCR.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFileViewer(),
                        const SizedBox(height: 20),
                        _buildStatusBadges(),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.receiptDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Expense ID
                        Obx(() {
                          if (controller.isSequenceLoading.value)
                            return const SizedBox();
                          final hideField = controller.hasModule("Expense");
                          if (hideField) return const SizedBox.shrink();
                          return _buildTextField(
                            label:
                                '${AppLocalizations.of(context)!.expenseId} *',
                            controller: controller.expenseIdController,
                            isReadOnly: true,
                          );
                        }),

                        // Receipt Date
                        _buildDateField(
                          '${AppLocalizations.of(context)!.receiptDate} *',
                          receiptDateController,
                          isReadOnly: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Paid To
                        Text(
                          '${AppLocalizations.of(context)!.paidTo} *',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            if (!controller.isManualEntryMerchant)
                              SearchableMultiColumnDropdownField<MerchantModel>(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.selectMerchant,
                                columnHeaders: [
                                  AppLocalizations.of(context)!.merchantName,
                                  AppLocalizations.of(context)!.merchantId,
                                ],
                                items: controller.paidTo,
                                selectedValue: controller.selectedPaidto,
                                searchValue: (p) =>
                                    '${p.merchantNames} ${p.merchantId}',
                                displayText: (p) => p.merchantNames,
                                validator: (value) {
                                  if (controller
                                      .paidToController
                                      .text
                                      .isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.fieldRequired;
                                  }
                                  return null;
                                },
                                onChanged: (p) {
                                  setState(() {
                                    controller.selectedPaidto = p;
                                    controller.paidToController.text =
                                        p!.merchantNames;
                                  });
                                },
                                controller: controller.paidToController,
                                rowBuilder: (p, searchQuery) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(p.merchantNames)),
                                        Expanded(child: Text(p.merchantId)),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              TextFormField(
                                controller: controller.manualPaidToController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.enterMerchantName,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterMerchantName;
                                  }
                                  return null;
                                },
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
                                      controller.manualPaidToController.clear();
                                    }
                                  });
                                },
                                child: Text(
                                  controller.isManualEntryMerchant
                                      ? AppLocalizations.of(
                                          context,
                                        )!.selectFromMerchantList
                                      : AppLocalizations.of(
                                          context,
                                        )!.enterMerchantManually,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Cash Advance
                        if (allowCashAd)
                          Column(
                            children: [
                              MultiSelectMultiColumnDropdownField<
                                CashAdvanceDropDownModel
                              >(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.cashAdvanceRequest,
                                items: controller.cashAdvanceListDropDown,
                                isMultiSelect: allowMultSelect,
                                dropdownMaxHeight: 300,
                                selectedValue: controller.singleSelectedItem,
                                selectedValues: controller.multiSelectedItems,
                                controller: controller.cashAdvanceIds,
                                // enabled: controller.isEnable.value,
                                searchValue: (proj) => proj.cashAdvanceReqId,
                                displayText: (proj) => proj.cashAdvanceReqId,
                                onChanged: (item) {
                                  controller.singleSelectedItem = item;
                                },
                                onMultiChanged: (items) {
                                  controller.multiSelectedItems.assignAll(
                                    items,
                                  );
                                },
                                columnHeaders: [
                                  AppLocalizations.of(context)!.requestId,
                                  AppLocalizations.of(context)!.requestDate,
                                ],
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
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Paid With
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            SearchableMultiColumnDropdownField<
                              PaymentMethodModel
                            >(
                              // enabled: controller.isEnable.value,
                              labelText: AppLocalizations.of(context)!.paidWith,
                              columnHeaders: [
                                AppLocalizations.of(context)!.paymentName,
                                AppLocalizations.of(context)!.paymentId,
                              ],
                              items: controller.paymentMethods,
                              selectedValue: controller.selectedPaidWith,
                              searchValue: (p) =>
                                  '${p.paymentMethodName} ${p.paymentMethodId}',
                              displayText: (p) => p.paymentMethodName,
                              // validator: (value) => _validateRequiredField(
                              //   controller.paidWithController.text,
                              //   AppLocalizations.of(context)!.paidWith,
                              //   false,
                              // ),
                              onChanged: (p) {
                                loadAndAppendCashAdvanceList();
                                setState(() {
                                  controller.selectedPaidWith = p;
                                  controller.paymentMethodID =
                                      p!.paymentMethodId;
                                  controller.paidWithController.text =
                                      p.paymentMethodId;
                                  controller.isReimbursableEnabled.value =
                                      p.reimbursible;
                                });
                              },
                              controller: controller.paidWithController,
                              rowBuilder: (p, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(p.paymentMethodName),
                                      ),
                                      Expanded(child: Text(p.paymentMethodId)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if ( itemizeControllers.isEmpty)
                          SearchableMultiColumnDropdownField<ExpenseCategory>(
                            labelText: AppLocalizations.of(context)!.paidFor,
                            // enabled: controller.isEnable.value,
                            columnHeaders: [
                              AppLocalizations.of(context)!.categoryName,
                              AppLocalizations.of(context)!.categoryId,
                            ],
                            items: controller.expenseCategory,
                            selectedValue: controller.selectedCategory,
                            searchValue: (p) =>
                                '${p.categoryName} ${p.categoryId}',
                            displayText: (p) => p.categoryId,
                            validator: (value) => _validateRequiredField(
                              controller.categoryController.text,
                              AppLocalizations.of(context)!.paidFor,
                              true,
                            ),
                            onChanged: (p) {
                              if (p == null) return;

                              setState(() {
                                // Update basic category info
                                controller.selectedCategory = p;
                                controller.selectedCategoryId = p.categoryId;
                                controller.categoryController.text =
                                    p.categoryId;
                                controller.itemisationMandatory.value =
                                    p.itemisationMandatory;
                                controller.minExpenseAmount.value =
                                    (p.minExpensesAmount ?? 0).toDouble();
                                controller.receiptRequiredLimit.value =
                                    (p.receiptRequiredLimit ?? 0).toDouble();
                                controller.maxExpenseAmount.value =
                                    (p.maxExpenseAmount ?? 0).toDouble();

                                // Remove existing ExpenseCategories custom fields
                                controller.customFields.removeWhere(
                                  (field) =>
                                      field['ObjectName'] ==
                                      'ExpenseCategories',
                                );

                                // Add new custom fields from the selected category
                                if (p.customFields != null &&
                                    p.customFields!.isNotEmpty) {
                                  for (var categoryField in p.customFields!) {
                                    final Map<String, dynamic> field =
                                        Map<String, dynamic>.from(
                                          categoryField,
                                        );

                                    field['ObjectName'] = 'ExpenseCategories';
                                    field['ExpenseType'] = 'General Expenses';

                                    final defaultVal =
                                        field['DefaultValue']?.toString() ?? '';
                                    field['EnteredValue'] = defaultVal;

                                    final fieldType = field['FieldType'];

                                    // Initialize based on field type
                                    if (fieldType == 'List' ||
                                        fieldType == 'CustomList' ||
                                        fieldType == 'SystemList') {
                                      final options =
                                          field['Options']
                                              as List<CustomDropdownValue>?;
                                      CustomDropdownValue? matchedOption;
                                      if (options != null &&
                                          defaultVal.isNotEmpty) {
                                        matchedOption = options
                                            .firstWhereOrNull(
                                              (opt) =>
                                                  opt.valueName == defaultVal ||
                                                  opt.valueId == defaultVal,
                                            );
                                      }
                                      field['SelectedValue'] = matchedOption;
                                      field['_rxSelectedValue'] =
                                          Rx<CustomDropdownValue?>(
                                            matchedOption,
                                          );
                                    } else if (fieldType == 'Checkbox') {
                                      final boolValue =
                                          defaultVal.toLowerCase() == 'true';
                                      field['_rxCheckboxValue'] = Rx<bool>(
                                        boolValue,
                                      );
                                    } else if (fieldType == 'Date' ||
                                        fieldType == 'Date&Time') {
                                      DateTime? dateValue;
                                      if (defaultVal.isNotEmpty) {
                                        try {
                                          dateValue = DateTime.parse(
                                            defaultVal,
                                          );
                                        } catch (e) {
                                          print("Error parsing date: $e");
                                        }
                                      }
                                      field['_rxDateValue'] = Rx<DateTime?>(
                                        dateValue,
                                      );
                                    } else if (fieldType == 'LongInteger') {
                                      field['_rxIntValue'] = Rx<int?>(
                                        int.tryParse(defaultVal),
                                      );
                                    } else if (fieldType == 'Decimal') {
                                      field['_rxDoubleValue'] = Rx<double?>(
                                        double.tryParse(defaultVal),
                                      );
                                    } else if (fieldType == 'Email') {
                                      field['_rxStringValue'] = Rx<String?>(
                                        defaultVal,
                                      );
                                      field['_controller'] =
                                          TextEditingController(
                                            text: defaultVal,
                                          );
                                      field['_focusNode'] = FocusNode();
                                    } else if (fieldType == 'MobileNumber') {
                                      // Initialize mobile number field
                                      field['_rxStringValue'] = Rx<String?>(
                                        defaultVal,
                                      );
                                      field['_controller'] =
                                          TextEditingController(
                                            text: defaultVal,
                                          );
                                      field['_focusNode'] = FocusNode();
                                    } else {
                                      field['_rxStringValue'] = Rx<String?>(
                                        defaultVal,
                                      );
                                      field['_controller'] =
                                          TextEditingController(
                                            text: defaultVal,
                                          );
                                      field['_focusNode'] = FocusNode();
                                    }

                                    field['Error'] = null;
                                    controller.customFields.add(field);
                                  }
                                }

                                controller.customFieldsItems.refresh();
                              });
                            },
                            controller: controller.categoryController,
                            rowBuilder: (p, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(p.categoryName)),
                                    Expanded(child: Text(p.categoryId)),
                                  ],
                                ),
                              );
                            },
                          ),
                         if ( itemizeControllers.isEmpty) const SizedBox(height: 8),

                        // Reference ID field
                        if (isRefrenceIDConfig.isEnabled)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.referenceId}${isRefrenceIDConfig.isMandatory ? " *" : ""}",
                            controller: referenceController,
                            isReadOnly: true,
                          ),

                        // Header Custom Fields
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
                        // Amount / Currency / Rate row
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                controller: controller.paidAmount,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context)!.paidAmount} *',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Obx(
                                () =>
                                    SearchableMultiColumnDropdownField<
                                      Currency
                                    >(
                                      alignLeft: -90,
                                      dropdownWidth: 280,
                                      labelText: "",
                                      columnHeaders: [
                                        AppLocalizations.of(context)!.code,
                                        AppLocalizations.of(context)!.name,
                                        AppLocalizations.of(context)!.symbol,
                                      ],
                                      items: controller.currencies,
                                      selectedValue:
                                          controller.selectedCurrency.value,
                                      searchValue: (c) =>
                                          '${c.code} ${c.name} ${c.symbol}',
                                      displayText: (c) => c.code,
                                      inputDecoration: const InputDecoration(
                                        suffixIcon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                        ),
                                        filled: true,
                                        fillColor: Color.fromARGB(
                                          55,
                                          5,
                                          23,
                                          128,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      onChanged: (c) {
                                        controller.selectedCurrency.value = c;
                                        controller.fetchExchangeRate();
                                        controller
                                                .currencyDropDowncontroller
                                                .text =
                                            c!.code;
                                      },
                                      controller:
                                          controller.currencyDropDowncontroller,
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
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: controller.unitRate,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.rate,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidNumber;
                                  }
                                  if (double.tryParse(value) == null) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidNumber;
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  _updateAllLineItems();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Total in INR
                        TextFormField(
                          controller: controller.amountINR,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.totalAmountIN} ${controller.organizationCurrency}',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                         if ( itemizeControllers.isEmpty)
                          TextFormField(
                            controller: controller.descriptionController,
                            // enabled: controller.isEnable.value,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.comments,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            maxLines: 2,
                          ),
                          if ( itemizeControllers.isEmpty)
                         FutureBuilder<Map<String, bool>>(
  future: _featureFuture,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const SizedBox.shrink();
    }
    final isEnabled = snapshot.data!['EnableItemization'] ?? false;

    print("EnableItemization$isEnabled");
    if (!isEnabled) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: _addItemize,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              AppLocalizations.of(context)!.addItem,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  },
),
                        const SizedBox(height: 20),

                        // Itemize Fields
                        if (_isItemized || itemizeControllers.isNotEmpty)
                          _buildItemizeFields(),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Center(
                          child: Column(
                            children: [
                              Obx(() {
                                final isSubmitLoading =
                                    controller.buttonLoaders['submit'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((l) => l);
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
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
                                    onPressed: (isSubmitLoading || isAnyLoading)
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              controller.setButtonLoading(
                                                'submit',
                                                true,
                                              );

                                              try {
                                                await _submitForm(true);
                                              } catch (e) {
                                                // handle error if needed
                                                print("Submit error: $e");
                                              } finally {
                                                // always stop loader after success/error
                                                controller.setButtonLoading(
                                                  'submit',
                                                  false,
                                                );
                                              }
                                            }
                                          },
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
                                            AppLocalizations.of(
                                              context,
                                            )!.submit,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Obx(() {
                                    final isSaveLoading =
                                        controller.buttonLoaders['saveGE'] ??
                                        false;
                                    final isSubmitLoading =
                                        controller.buttonLoaders['submit'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((l) => l);
                                    return Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            (isSaveLoading ||
                                                isSubmitLoading ||
                                                isAnyLoading)
                                            ? null
                                            : () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  controller.setButtonLoading(
                                                    'saveGE',
                                                    true,
                                                  );

                                                  try {
                                                    await _submitForm(false);
                                                  } catch (e) {
                                                    print("Save error: $e");
                                                  } finally {
                                                    controller.setButtonLoading(
                                                      'saveGE',
                                                      false,
                                                    );
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1E7503,
                                          ),
                                        ),
                                        child: isSaveLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.save,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 12),
                                  Obx(() {
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((l) => l);
                                    return Expanded(
                                      child: ElevatedButton(
                                        onPressed: isAnyLoading
                                            ? null
                                            : () {
                                                controller.chancelButton(
                                                  context,
                                                );
                                                controller.closeField();
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );
  }
}
