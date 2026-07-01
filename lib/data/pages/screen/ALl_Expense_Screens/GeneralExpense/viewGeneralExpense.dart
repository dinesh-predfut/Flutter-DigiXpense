import 'dart:async';
import 'dart:io';
import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart'
    show PermissionHelper;
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../../core/comman/widgets/multiselectDropdown.dart';

class ViewEditExpensePage extends StatefulWidget {
  final bool isReadOnly;
  final GESpeficExpense items;
  const ViewEditExpensePage({
    Key? key,
    required this.items,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  State<ViewEditExpensePage> createState() => _ViewEditExpensePageState();
}

class _ViewEditExpensePageState extends State<ViewEditExpensePage>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
  final Map<String, TextEditingController> fieldControllers = {};
  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.find<Controller>();
  late Future<List<ExpenseHistory>> historyFuture;
  String? selectedPaidTo;
  String? statusApproval;
  String? selectedPaidWith;
  bool showProject = false;
  bool showTaxGroup = false;
  bool showTaxAmount = false;
  bool showLocation = false;
  bool showReferenceID = false;
  bool showReimbursible = false;
  bool isBillable = false;
  bool allowCashAd = false;
  bool _showHistory = false;
  bool allowMultSelect = false;
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isTyping = false;
  late FocusNode _focusNode;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
  late Future<Map<String, bool>> _featureFuture;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

    // print("widget.isReadOnly${widget.isReadOnly}");
    _focusNode = FocusNode();
    controller.selectedDate ??= DateTime.now();
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    _featureFuture = controller.getAllFeatureStates();

    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );
    historyFuture = controller.fetchExpenseHistory(widget.items.recId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.items.approvalStatus != "Pending") {
        controller.isEnable.value = false;
      }
      expenseIdController.text = "";
      receiptDateController.text = "";
      merhantName.text = "";
      calculateAmounts(widget.items.exchRate.toString());
      controller.fetchExpenseDocImage(widget.items.recId);
      controller.fetchPaidto();
      controller.fetchPaidwith();
      // controller.loadAllCustomFieldValues();
      controller.fetchProjectName();
      await controller.fetchExpenseCategory();
      controller.configuration();
      controller.fetchUnit();
      controller.fetchTaxGroup();
      controller.currencyDropDown();

      _loadSettings();
      final int offsetMs =
          int.tryParse(controller.selectedTimezonevalue.value!) ?? 0;
      final DateTime receiptDate = DateTime.fromMillisecondsSinceEpoch(
        widget.items.receiptDate.millisecondsSinceEpoch + offsetMs,
        isUtc: true,
      );
      final formatted = DateFormat(
        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
      ).format(receiptDate);
      controller.selectedDate = receiptDate;
      statusApproval = widget.items.approvalStatus;
      receiptDateController.text = formatted;
      if (widget.items != null && widget.items.paymentMethod != null) {
        controller.paymentMethodID = widget.items.paymentMethod.toString();
      }
      if (widget.items.approvalStatus == "Approved") {
        controller.isEnable.value = false;
      }
      expenseIdController.text = widget.items.expenseId.toString();
      receiptDateController.text = formatted;
      if (widget.items?.merchantId == null) {
        //  // print("merchantIdfalse");
        controller.isManualEntryMerchant = true;
      } else {
        controller.isManualEntryMerchant = false;
        //  // print("merchantIdtrue");
      }

      controller.paidToController.text =
          widget.items?.merchantId?.toString() ?? '';

      //  // print('--- AccountingDistributions Added ---');
      controller.referenceID.text =
          widget.items?.referenceNumber?.toString() ?? '';
      if (widget.items != null && widget.items.paymentMethod != null) {
        controller.paidWithController.text = widget.items.paymentMethod!;
      } else {
        controller.paidWithController.text = '';
      }

      selectedPaidWith = paidWithOptions.first;
      controller.paidAmount.text = widget.items.totalAmountTrans
          .toStringAsFixed(2);
      controller.unitAmount.text = widget.items.totalAmountTrans
          .toStringAsFixed(2);
      controller.employeeName.text = widget.items!.employeeName!;
      controller.employeeDropDownController.text = widget.items!.employeeId!;
      controller.unitRate.text = widget.items.exchRate.toStringAsFixed(2);
      controller.cashAdvReqIds = widget.items.cashAdvReqId;
      controller.amountINR.text = widget.items.totalAmountReporting
          .toStringAsFixed(2);
      controller.expenseID = widget.items.expenseId;
      controller.recID =
          widget.items.recId ?? widget.items.unprocessedRecId ?? null;
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final savedCustomFields =
          args?['savedCustomFieldValues'] as List<dynamic>?;
      print("savedCustomFields${widget.items.expenseHeaderCustomFieldValues}");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        controller.loadAllCustomFieldValues(
          savedValues: widget.items.expenseHeaderCustomFieldValues,
        );
        _initializeItemizeControllers(); // ✅ now runs AFTER customFields is populated
      });
      controller.isBillableCreate = widget.items.isBillable;
      if (widget.items.merchantId == null) {
        controller.manualPaidToController.text = widget.items.merchantName!;
      } else {
        controller.paidToController.text = widget.items.merchantName!;
      }
      controller.currencyDropDowncontroller.text = widget.items.currency
          .toString();

      _initializeData();
    });
    projectConfig = controller.getFieldConfig("Project Id");
    taxGroupConfig = controller.getFieldConfig("Tax Group");
    taxAmountConfig = controller.getFieldConfig("Tax Amount");
    isReimbursibleConfig = controller.getFieldConfig("Is Reimbursible");
    isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
    isBillableConfig = controller.getFieldConfig("Is Billable");
    isLocationConfig = controller.getFieldConfig("Location");
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

  String? _validateDateField(String value, String fieldName, bool isMandatory) {
    if (isMandatory && value.isEmpty) {
      return '$fieldName ${AppLocalizations.of(context)!.fieldRequired}';
    }
    if (value.isNotEmpty) {
      try {
        DateFormat(
          controller.selectedFormat?.key ?? 'dd/MM/yyyy',
        ).parseStrict(value);
      } catch (e) {
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

    // check(_validateRequiredField(
    //   controller.paidWithController.text,
    //   AppLocalizations.of(context)!.paidWith,
    //   true,
    // ));

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
          controller.referenceID.text,
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

      // check(
      //   _validateNumericField(
      //     item.unitPriceTrans.text,
      //     "Item ${i + 1} Unit Amount",
      //     true,
      //   ),
      // );

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

    /// ✅ SHOW ERROR
    if (firstError != null) {
      print("Validation Error${firstError!}");
      return false;
    }

    return true;
  }

  Future<void> _initializeData() async {
    await loadAndAppendCashAdvanceList();
    initializeCashAdvanceSelection();
  }

  void initializeCashAdvanceSelection() {
    String? backendSelectedIds = controller.cashAdvReqIds;
    //  // print("controller.cashAdvReqIds$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
      controller.cashAdvanceListDropDown,
      backendSelectedIds,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        allowCashAd = settings.allowCashAdvAgainstExpenseReg;
        //  // print("allowDocAttachments$allowMultSelect");
      });
    }
  }

  Future<void> _updateAllLineItems() async {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      _calculateTotalLineAmount(itemController).toStringAsFixed(2);
      controller.calculateLineAmounts(itemController);

      final lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
      final lineAmountInINR = lineAmount * rate;

      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

      widget.items.expenseTrans[i] = itemController.toExpenseItemUpdateModel();
    }

    setState(() {});
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

    controller.paidAmount.text = total.toStringAsFixed(2);

    final paid = total;
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    controller.amountINR.text = (paid * rate).toStringAsFixed(2);

    return total;
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();

      final existingIds = controller.cashAdvanceListDropDown
          .map((e) => e.cashAdvanceReqId)
          .toSet();

      final uniqueNewItems = newItems.where(
        (item) => !existingIds.contains(item.cashAdvanceReqId),
      );

      controller.cashAdvanceListDropDown.addAll(uniqueNewItems);

      //  // print(
      //   "✅ Updated cashAdvanceListDropDown: ${controller.cashAdvanceListDropDown.length}",
      // );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _initializeItemizeControllers() {
    final mainController = Get.find<Controller>();

    print(
      "Main controller customFields length: ${mainController.customFields.length}",
    );
    print(
      "Main controller customFieldsItems length: ${mainController.customFieldsItems.length}",
    );

    if (widget.items.expenseTrans.isEmpty) {
      final newController = Controller();
      if (mainController.customFields.isNotEmpty) {
        newController.cloneCustomFieldsFromRx(mainController.customFields);
        print(
          "Cloned ${newController.customFieldsItems.length} fields for empty transaction",
        );
      }
      itemizeControllers = [newController];
      _itemizeCount = 1;
      return;
    }

    itemizeControllers = [];

    for (int index = 0; index < widget.items.expenseTrans.length; index++) {
      final item = widget.items.expenseTrans[index];
      final newController = Controller();

      // Set basic fields
      newController.recIDItem = item.recId;
      newController.projectDropDowncontroller.text = item.projectId ?? '';
      newController.descriptionController.text = item.description ?? '';
      newController.quantity.text = item.quantity.toStringAsFixed(2);
      newController.unitPriceTrans.text = item.unitPriceTrans.toStringAsFixed(
        2,
      );
      newController.lineAmount.text = item.lineAmountTrans.toStringAsFixed(2);
      newController.lineAmountINR.text = item.lineAmountReporting
          .toStringAsFixed(2);
      newController.taxAmount.text = item.taxAmount.toStringAsFixed(2);
      newController.taxGroupController.text = item.taxGroup ?? '';
      newController.categoryController.text = item.expenseCategoryId;
      newController.uomId.text = item.uomId;
      newController.isReimbursable = item.isReimbursable;
      newController.isBillableCreate = item.isBillable;

      // ✅ CRITICAL FIX: First, make sure customFieldsItems has all fields from main controller
      if (mainController.customFields.isNotEmpty) {
        newController.cloneCustomFieldsFromRx(mainController.customFields);
        print(
          "Cloned ${newController.customFieldsItems.length} fields for item $index",
        );
      } else {
        print("Main controller customFields is empty for item $index");
        newController.customFieldsItems.value = [];
      }

      // ✅ NOW load ExpenseTrans custom fields (transaction level)
      if (item.expenseTransCustomFieldValues != null &&
          item.expenseTransCustomFieldValues!.isNotEmpty) {
        print(
          "Loading ExpenseTrans custom fields for item $index: ${item.expenseTransCustomFieldValues!.length} fields",
        );

        for (var savedField in item.expenseTransCustomFieldValues!) {
          final savedFieldId = savedField['FieldId'];
          final savedFieldValue = savedField['FieldValue'];
          final savedFieldName = savedField['FieldName'];

          print(
            "Looking for ExpenseTrans field: $savedFieldId - $savedFieldName",
          );

          // Find matching field in customFieldsItems by FieldId
          final matchingFieldIndex = newController.customFieldsItems.indexWhere(
            (f) => f['FieldId'] == savedFieldId,
          );

          if (matchingFieldIndex != -1) {
            final field = newController.customFieldsItems[matchingFieldIndex];
            final fieldType = field['FieldType'];

            print(
              "✅ Found matching ExpenseTrans field: ${field['FieldName']} (${field['FieldId']})",
            );
            print("  → Setting value: $savedFieldValue");

            _setFieldValue(field, savedFieldValue, fieldType);
          } else {
            print(
              "⚠️ Could not find matching ExpenseTrans field for saved field: $savedFieldId - $savedFieldName",
            );

            // ✅ If field doesn't exist, create it dynamically
            final newField = {
              'FieldId': savedFieldId,
              'FieldName': savedFieldName,
              'FieldValue': savedFieldValue,
              'FieldType': 'Text', // Default type
              'ObjectName': 'ExpenseTrans',
              'EnteredValue': savedFieldValue?.toString() ?? '',
            };
            newController.customFieldsItems.add(newField);
            print("  → Created new field: $savedFieldName");
          }
        }
      }

      // ✅ CRITICAL FIX: Load ExpenseCategories custom fields (category level)
      if (item.expenseTransExpensecategorycustomfieldvalues != null &&
          item.expenseTransExpensecategorycustomfieldvalues!.isNotEmpty) {
        print(
          "Loading ExpenseCategories custom fields for item $index: ${item.expenseTransExpensecategorycustomfieldvalues!.length} fields",
        );

        for (var savedField
            in item.expenseTransExpensecategorycustomfieldvalues!) {
          final savedFieldId = savedField['FieldId'];
          final savedFieldValue = savedField['FieldValue'];
          final savedFieldName = savedField['FieldName'];

          print(
            "Looking for ExpenseCategories field: $savedFieldId - $savedFieldName",
          );

          // First, try to find existing field in customFieldsItems
          int matchingFieldIndex = newController.customFieldsItems.indexWhere(
            (f) =>
                f['FieldId'] == savedFieldId &&
                f['ObjectName'] == 'ExpenseCategories',
          );

          // If not found, try to find without ObjectName constraint
          if (matchingFieldIndex == -1) {
            matchingFieldIndex = newController.customFieldsItems.indexWhere(
              (f) => f['FieldId'] == savedFieldId,
            );
          }

          if (matchingFieldIndex != -1) {
            final field = newController.customFieldsItems[matchingFieldIndex];
            // Ensure ObjectName is set correctly
            field['ObjectName'] = 'ExpenseCategories';
            final fieldType = field['FieldType'] ?? 'Text';

            print(
              "✅ Found matching ExpenseCategories field: ${field['FieldName']} (${field['FieldId']})",
            );
            print("  → Setting value: $savedFieldValue");
            print("  → FieldType: $fieldType");

            _setFieldValue(field, savedFieldValue, fieldType);
          } else {
            // ✅ If field doesn't exist in customFieldsItems, create it from scratch
            print(
              "⚠️ Could not find matching ExpenseCategories field, creating new one",
            );

            // Find the category to get field type and options
            final matchingCategory = controller.expenseCategory
                .firstWhereOrNull(
                  (cat) => cat.categoryId == item.expenseCategoryId,
                );

            String fieldType = 'Text';
            List<CustomDropdownValue>? options;

            if (matchingCategory != null &&
                matchingCategory.customFields != null) {
              final categoryField = matchingCategory.customFields!
                  .firstWhereOrNull((cf) => cf['FieldId'] == savedFieldId);
              if (categoryField != null) {
                fieldType = categoryField['FieldType'] ?? 'Text';
                options =
                    categoryField['Options'] as List<CustomDropdownValue>?;
                print("  → Found category field type: $fieldType");
              }
            }

            final newField = {
              'FieldId': savedFieldId,
              'FieldName': savedFieldName,
              'FieldLabel': savedFieldName,
              'FieldType': fieldType,
              'ObjectName': 'ExpenseCategories',
              'ExpenseType': 'General Expenses',
              'EnteredValue': savedFieldValue?.toString() ?? '',
              'Options': options ?? [],
              'Error': null,
            };

            // Initialize Rx based on field type
            if (fieldType == 'List' ||
                fieldType == 'CustomList' ||
                fieldType == 'SystemList') {
              CustomDropdownValue? matchedOption;
              if (options != null &&
                  options.isNotEmpty &&
                  savedFieldValue != null) {
                matchedOption = options.firstWhereOrNull(
                  (opt) =>
                      opt.valueName == savedFieldValue ||
                      opt.valueId == savedFieldValue,
                );
              }
              newField['SelectedValue'] = matchedOption;
              newField['_rxSelectedValue'] = Rx<CustomDropdownValue?>(
                matchedOption,
              );
            } else if (fieldType == 'Checkbox') {
              final boolValue =
                  savedFieldValue == 'true' ||
                  savedFieldValue == 'True' ||
                  savedFieldValue == '1';
              newField['_rxCheckboxValue'] = Rx<bool>(boolValue);
            } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
              newField['_rxDateValue'] = Rx<DateTime?>(null);
            } else if (fieldType == 'LongInteger') {
              newField['_rxIntValue'] = Rx<int?>(
                int.tryParse(savedFieldValue?.toString() ?? ''),
              );
            } else if (fieldType == 'Decimal') {
              newField['_rxDoubleValue'] = Rx<double?>(
                double.tryParse(savedFieldValue?.toString() ?? ''),
              );
            } else {
              newField['_rxStringValue'] = Rx<String?>(
                savedFieldValue?.toString() ?? '',
              );
            }

            newController.customFieldsItems.add(newField);
            print(
              "  → Created new ExpenseCategories field: $savedFieldName with value: $savedFieldValue",
            );
          }
        }
      } else {
        print("No ExpenseCategories custom fields found for item $index");
      }

      // Also load default category custom fields from the category itself
      final matchingCategory = controller.expenseCategory.firstWhereOrNull(
        (cat) => cat.categoryId == item.expenseCategoryId,
      );

      if (matchingCategory != null &&
          matchingCategory.customFields != null &&
          matchingCategory.customFields!.isNotEmpty) {
        print(
          "Checking default ExpenseCategories custom fields from category: ${matchingCategory.categoryId}",
        );

        for (var categoryField in matchingCategory.customFields!) {
          final fieldId = categoryField['FieldId'];
          final defaultValue = categoryField['DefaultValue']?.toString() ?? '';

          // Check if this field already has a value (either saved or set)
          final existingFieldIndex = newController.customFieldsItems.indexWhere(
            (f) =>
                f['FieldId'] == fieldId &&
                f['ObjectName'] == 'ExpenseCategories',
          );

          if (existingFieldIndex != -1) {
            final field = newController.customFieldsItems[existingFieldIndex];
            final currentValue = field['EnteredValue'];
            // Only set default if no saved value exists
            if (currentValue == null ||
                currentValue == '' ||
                currentValue.toString().isEmpty) {
              print(
                "  → Setting default value for ${field['FieldName']}: $defaultValue",
              );
              _setFieldValue(field, defaultValue, field['FieldType']);
            }
          } else {
            // Create new field from category if it doesn't exist
            print(
              "  → Creating new field from category: ${categoryField['FieldName']}",
            );
            final newField = Map<String, dynamic>.from(categoryField);
            newField['ObjectName'] = 'ExpenseCategories';
            newField['ExpenseType'] = 'General Expenses';

            // Set default value
            final defaultVal = newField['DefaultValue']?.toString() ?? '';
            newField['EnteredValue'] = defaultVal;

            // Initialize Rx based on field type
            final fieldType = newField['FieldType'];
            if (fieldType == 'List' ||
                fieldType == 'CustomList' ||
                fieldType == 'SystemList') {
              final options = newField['Options'] as List<CustomDropdownValue>?;
              CustomDropdownValue? matchedOption;
              if (options != null && defaultVal.isNotEmpty) {
                matchedOption = options.firstWhereOrNull(
                  (opt) =>
                      opt.valueName == defaultVal || opt.valueId == defaultVal,
                );
              }
              newField['SelectedValue'] = matchedOption;
              newField['_rxSelectedValue'] = Rx<CustomDropdownValue?>(
                matchedOption,
              );
            } else if (fieldType == 'Checkbox') {
              final boolValue = defaultVal.toLowerCase() == 'true';
              newField['_rxCheckboxValue'] = Rx<bool>(boolValue);
            } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
              newField['_rxDateValue'] = Rx<DateTime?>(null);
            } else if (fieldType == 'LongInteger') {
              newField['_rxIntValue'] = Rx<int?>(int.tryParse(defaultVal));
            } else if (fieldType == 'Decimal') {
              newField['_rxDoubleValue'] = Rx<double?>(
                double.tryParse(defaultVal),
              );
            } else {
              newField['_rxStringValue'] = Rx<String?>(defaultVal);
            }

            newController.customFieldsItems.add(newField);
          }
        }
      }

      // Load accounting distributions
      if (item.accountingDistributions != null &&
          item.accountingDistributions!.isNotEmpty) {
        newController.split = item.accountingDistributions!.map((dist) {
          return AccountingSplit(
            paidFor: dist.dimensionValueId ?? '',
            percentage: dist.allocationFactor ?? 0.0,
            amount: dist.transAmount ?? 0.0,
          );
        }).toList();

        newController.accountingDistributions.clear();
        newController.accountingDistributions.addAll(
          item.accountingDistributions!.map((dist) {
            return AccountingDistribution(
              transAmount: dist.transAmount ?? 0.0,
              reportAmount: dist.reportAmount ?? 0.0,
              allocationFactor: dist.allocationFactor ?? 0.0,
              dimensionValueId: dist.dimensionValueId ?? '',
              recId: dist.recId,
            );
          }),
        );
      }

      // Force refresh after loading all fields
      newController.customFieldsItems.refresh();
      itemizeControllers.add(newController);

      print(
        "Final customFieldsItems count for item $index: ${newController.customFieldsItems.length}",
      );
      print(
        "ExpenseCategories fields: ${newController.customFieldsItems.where((f) => f['ObjectName'] == 'ExpenseCategories').length}",
      );
    }

    _itemizeCount = widget.items.expenseTrans.length;
    print("Total itemize controllers created: ${itemizeControllers.length}");
  }

  // Helper method to set field value based on type
  void _setFieldValue(
    Map<String, dynamic> field,
    dynamic savedFieldValue,
    String fieldType,
  ) {
    if (fieldType == 'List' ||
        fieldType == 'CustomList' ||
        fieldType == 'SystemList') {
      final options = field['Options'] as List<CustomDropdownValue>?;
      CustomDropdownValue? matchedOption;

      if (options != null && options.isNotEmpty && savedFieldValue != null) {
        matchedOption = options.firstWhereOrNull(
          (opt) =>
              opt.valueName == savedFieldValue ||
              opt.valueId == savedFieldValue,
        );
      }

      field['EnteredValue'] = savedFieldValue?.toString() ?? '';
      field['SelectedValue'] = matchedOption;

      if (field['_rxSelectedValue'] == null) {
        field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(matchedOption);
      } else {
        (field['_rxSelectedValue'] as Rx<CustomDropdownValue?>).value =
            matchedOption;
      }
    } else if (fieldType == 'Checkbox') {
      final boolValue =
          savedFieldValue == 'true' ||
          savedFieldValue == 'True' ||
          savedFieldValue == '1' ||
          savedFieldValue == true;
      field['EnteredValue'] = boolValue;

      if (field['_rxCheckboxValue'] == null) {
        field['_rxCheckboxValue'] = Rx<bool>(boolValue);
      } else {
        (field['_rxCheckboxValue'] as Rx<bool>).value = boolValue;
      }
    } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
      DateTime? parsedDate = _parseDateTime(
        savedFieldValue,
        fieldType == 'Date&Time',
      );
      field['EnteredValue'] = parsedDate;

      if (field['_rxDateValue'] == null) {
        field['_rxDateValue'] = Rx<DateTime?>(parsedDate);
      } else {
        (field['_rxDateValue'] as Rx<DateTime?>).value = parsedDate;
      }
    } else if (fieldType == 'LongInteger') {
      final intValue = int.tryParse(savedFieldValue?.toString() ?? '');
      field['EnteredValue'] = intValue;

      if (field['_rxIntValue'] == null) {
        field['_rxIntValue'] = Rx<int?>(intValue);
      } else {
        (field['_rxIntValue'] as Rx<int?>).value = intValue;
      }

      // Also update controller if exists
      if (field['_controller'] != null) {
        field['_controller'].text = intValue?.toString() ?? '';
      }
    } else if (fieldType == 'Decimal') {
      final doubleValue = double.tryParse(savedFieldValue?.toString() ?? '');
      field['EnteredValue'] = doubleValue;

      if (field['_rxDoubleValue'] == null) {
        field['_rxDoubleValue'] = Rx<double?>(doubleValue);
      } else {
        (field['_rxDoubleValue'] as Rx<double?>).value = doubleValue;
      }

      // Update controller if exists
      if (field['_controller'] != null) {
        field['_controller'].text = doubleValue?.toString() ?? '';
      }
    } else {
      final stringValue = savedFieldValue?.toString() ?? '';
      field['EnteredValue'] = stringValue;

      if (field['_rxStringValue'] == null) {
        field['_rxStringValue'] = Rx<String?>(stringValue);
      } else {
        (field['_rxStringValue'] as Rx<String?>).value = stringValue;
      }

      // Update controller if exists
      if (field['_controller'] != null) {
        field['_controller'].text = stringValue;
      }
    }

    field['Error'] = null;
  }

  // Helper method to parse DateTime
  DateTime? _parseDateTime(dynamic value, bool isDateTime) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String && value.isNotEmpty) {
      try {
        if (value.contains('/')) {
          final parts = value.split(' ');
          final dateParts = parts[0].split('/');
          if (dateParts.length == 3) {
            if (isDateTime && parts.length >= 2) {
              final timeParts = parts[1].split(':');
              final isPM = parts.length > 2 && parts[2].toUpperCase() == 'PM';
              int hour = int.parse(timeParts[0]);
              if (isPM && hour != 12) hour += 12;
              if (!isPM && hour == 12) hour = 0;
              return DateTime(
                int.parse(dateParts[2]),
                int.parse(dateParts[1]),
                int.parse(dateParts[0]),
                hour,
                int.parse(timeParts[1]),
              );
            } else {
              return DateTime(
                int.parse(dateParts[2]),
                int.parse(dateParts[1]),
                int.parse(dateParts[0]),
              );
            }
          }
        } else {
          final millis = int.tryParse(value);
          if (millis != null) {
            return DateTime.fromMillisecondsSinceEpoch(millis);
          }
          return DateTime.parse(value);
        }
      } catch (e) {
        print("Error parsing date: $e");
      }
    }
    return null;
  }

  Future<void> waitForDropdownDataAndSetValues() async {
    int retries = 0;
    while ((controller.paymentMethods.isEmpty ||
            controller.expenseCategory.isEmpty) &&
        retries < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }
    if (controller.categoryController.text.isNotEmpty) {
      final matchingCategory = controller.expenseCategory.firstWhere(
        (e) => e.categoryId == controller.categoryController.text,
        orElse: () => controller.expenseCategory.first,
      );
      controller.selectedCategory = matchingCategory;

      controller.categoryController.text =
          controller.selectedCategory!.categoryId;
      controller.itemisationMandatory.value =
          controller.selectedCategory!.itemisationMandatory;
      controller.minExpenseAmount.value =
          (controller.selectedCategory!.minExpensesAmount ?? 0).toDouble();
      controller.receiptRequiredLimit.value =
          (controller.selectedCategory!.receiptRequiredLimit ?? 0).toDouble();
      controller.maxExpenseAmount.value =
          (controller.selectedCategory!.maxExpenseAmount ?? 0).toDouble();
    }
    if (controller.paymentMethods.isNotEmpty) {
      controller.selectedPaidWith = controller.paymentMethods.firstWhere(
        (e) => e.paymentMethodId == widget.items.paymentMethod,
        orElse: () => controller.paymentMethods.first,
      );
      controller.isReimbursableEnabled.value =
          controller.selectedPaidWith!.reimbursible;
    }

    if (controller.project.isNotEmpty) {
      controller.selectedProject = controller.project.firstWhere(
        (e) => e.code == widget.items.projectId,
        orElse: () => controller.project.first,
      );
    }

    if (controller.currencies.isNotEmpty) {
      controller.selectedCurrency.value = controller.currencies.firstWhere(
        (e) => e.code == widget.items.currency,
        orElse: () => controller.currencies.first,
      );
    }
    setState(() {});
  }

  void calculateAmounts(String rateStr) {
    final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
    final rate = double.tryParse(rateStr) ?? 1.0;

    final result = paid * rate;
    controller.amountINR.text = result.toStringAsFixed(2);
    controller.isVisible.value = true;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      final unitPrice =
          double.tryParse(itemController.unitPriceTrans.text) ?? 0.0;

      widget.items.expenseTrans[i] = itemController.toExpenseItemUpdateModel();
    }
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        final newItem = ExpenseItemUpdate(
          description: '',
          quantity: 1.00,
          unitPriceTrans: 0,
          lineAmountTrans: 0,
          lineAmountReporting: 0,
          taxAmount: 0,
          isReimbursable: false,
          isBillable: controller.isBillableCreate,
          projectId: '',
          expenseCategoryId: "",
          uomId: controller.unit.isNotEmpty ? controller.unit.first.name : '',
          taxGroup: '',
          accountingDistributions: [],
        );

        widget.items.expenseTrans.add(newItem);

        final newController = Controller();

        if (controller.unit.isNotEmpty) {
          newController.selectedunit = controller.unit.firstWhere(
            (u) => u.code == newItem.uomId,
            orElse: () => controller.unit.first,
          );
        }
        final currentController = itemizeControllers[_selectedItemizeIndex];

        // Clone ExpenseTrans custom fields
        if (currentController.customFields.isNotEmpty) {
          newController.cloneCustomFieldsFromRx(currentController.customFields);
        }

        // ✅ CRITICAL: Clone ExpenseCategories custom fields with their values
        if (currentController.customFieldsItems.isNotEmpty) {
          final clonedCategoryFields = currentController.customFieldsItems
              .where((f) => f['ObjectName'] == 'ExpenseCategories')
              .map((field) {
                final Map<String, dynamic> cloned = Map<String, dynamic>.from(
                  field,
                );
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

        debugPrint(
          "Controller added with unit: ${newController.selectedunit?.name}",
        );

        itemizeControllers = List.from(itemizeControllers)..add(newController);

        _itemizeCount++;
        _selectedItemizeIndex = _itemizeCount - 1;
        showItemizeDetails = true;
      });
    }
  }

  void _removeItemize(int index) {
    if (_itemizeCount <= 1) {
      setState(() {
        showItemizeDetails = false;
      });
    } else if (index >= 0 && index < widget.items.expenseTrans.length) {
      setState(() {
        widget.items.expenseTrans.removeAt(index);
        itemizeControllers.removeAt(index);
        _itemizeCount--;
        if (_selectedItemizeIndex >= _itemizeCount) {
          _selectedItemizeIndex = _itemizeCount - 1;
        }
      });
    }
  }

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
      // print("Error picking or cropping image: $e");
      Fluttertoast.showToast(
        msg: "Failed to upload image",
        backgroundColor: Colors.red,
      );
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<void> _pickFile() async {
    print("ExtensionsExtensions${controller.allowedExtensions}");
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

  Color getStatusColor(String? status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return WillPopScope(
      onWillPop: () async {
        if (!controller.isEnable.value) {
          controller.clearFormFields();
          return true;
        }

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
          controller.clearFormFields();
          controller.isEnable.value = false;
          controller.isLoadingviewImage.value = false;

          Navigator.of(context).pop();
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              controller.isEnable.value
                  ? '${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!.expense}'
                  : '${AppLocalizations.of(context)!.view} ${AppLocalizations.of(context)!.expense}',
            ),
          ),
          actions: [
            if (widget.isReadOnly &&
                widget.items.approvalStatus != "Approved" &&
                widget.items.approvalStatus != "Cancelled" &&
                widget.items.approvalStatus != "Pending" &&
                PermissionHelper.canUpdate("Expense Registration"))
              Obx(() {
                return IconButton(
                  icon: Icon(
                    controller.isEnable.value
                        ? Icons.remove_red_eye
                        : Icons.edit_document,
                  ),
                  onPressed: () {
                    controller.isEnable.value = !controller.isEnable.value;
                  },
                );
              }),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingLogin.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                debugPrint("Status: $statusApproval");
                              },
                              icon: const Icon(
                                Icons.donut_large,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                statusApproval ?? "",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: getStatusColor(statusApproval),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Obx(() {
                          return Stack(
                            children: [
                              Obx(() {
                                return GestureDetector(
                                  onTap: () {
                                    if (controller.imageFiles.isEmpty &&
                                        controller.isEnable.value &&
                                        !controller.isLoadingviewImage.value) {
                                      _pickFile();
                                    }
                                  },

                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    /// ✅ EMPTY VIEW
                                    child: controller.imageFiles.isEmpty
                                        ? Center(
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.tapToUploadDocs,
                                            ),
                                          )
                                        /// ✅ FILE PREVIEW VIEW
                                        : Stack(
                                            children: [
                                              PageView.builder(
                                                controller: _pageController,
                                                itemCount: controller
                                                    .imageFiles
                                                    .length,
                                                onPageChanged: (index) {
                                                  controller
                                                          .currentIndex
                                                          .value =
                                                      index;
                                                },

                                                itemBuilder: (_, index) {
                                                  final file = controller
                                                      .imageFiles[index];
                                                  final path = file.path;

                                                  return GestureDetector(
                                                    onTap: () =>
                                                        controller.openFile(
                                                          context,
                                                          file,
                                                          index,
                                                        ),

                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              Colors.deepPurple,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),

                                                      /// ✅ IMAGE
                                                      child:
                                                          controller.isImage(
                                                            path,
                                                          )
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: Image.file(
                                                                file,
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                              ),
                                                            )
                                                          /// ✅ PDF
                                                          : controller.isPdf(
                                                              path,
                                                            )
                                                          ? Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  size: 70,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        8,
                                                                      ),
                                                                  child: Text(
                                                                    file.path
                                                                        .split(
                                                                          '/',
                                                                        )
                                                                        .last,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          /// ✅ EXCEL
                                                          : controller.isExcel(
                                                              path,
                                                            )
                                                          ? Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .table_chart,
                                                                  size: 70,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                Text(
                                                                  file.path
                                                                      .split(
                                                                        '/',
                                                                      )
                                                                      .last,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ],
                                                            )
                                                          /// ✅ OTHER FILE
                                                          : Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .insert_drive_file,
                                                                  size: 70,
                                                                ),
                                                                Text(
                                                                  file.path
                                                                      .split(
                                                                        '/',
                                                                      )
                                                                      .last,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
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
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 16,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
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
                                                        color:
                                                            Colors.deepPurple,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
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

                              // 🔥 CIRCULAR LOADER OVERLAY
                              if (controller.isLoadingviewImage.value)
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
                        }),

                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.receiptDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (controller.justificationnotes.text.isNotEmpty)
                          SizedBox(height: 10),
                        if (controller.justificationnotes.text.isNotEmpty)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.justification} *",
                            controller: controller.justificationnotes,
                            isReadOnly: false,
                          ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: "${AppLocalizations.of(context)!.expenseId} *",
                          controller: expenseIdController,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeId} *",
                          controller: controller.employeeDropDownController,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeName} *",
                          controller: controller.employeeName,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 16),
                        buildDateField(
                          '${AppLocalizations.of(context)!.receiptDate} *',
                          receiptDateController,
                          isReadOnly: !controller.isEnable.value,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${AppLocalizations.of(context)!.paidTo} *',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            if (!controller.isManualEntryMerchant)
                              AbsorbPointer(
                                absorbing: !controller.isEnable.value,
                                child:
                                    SearchableMultiColumnDropdownField<
                                      MerchantModel
                                    >(
                                      enabled: controller.isEnable.value,
                                      labelText:
                                          '${AppLocalizations.of(context)!.selectMerchant} *',
                                      columnHeaders: [
                                        "${AppLocalizations.of(context)!.merchantName}",
                                        AppLocalizations.of(
                                          context,
                                        )!.merchantId,
                                      ],
                                      items: controller.paidTo,
                                      selectedValue: controller.selectedPaidto,
                                      searchValue: (p) =>
                                          '${p.merchantNames} ${p.merchantId}',
                                      displayText: (p) => p.merchantNames,
                                      validator: (value) =>
                                          _validateRequiredField(
                                            controller.paidToController.text,
                                            AppLocalizations.of(
                                              context,
                                            )!.selectMerchant,
                                            true,
                                          ),
                                      onChanged: (p) {
                                        setState(() {
                                          controller.selectedPaidto = p;
                                          controller.paidToController.text =
                                              p!.merchantId;
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
                                              Expanded(
                                                child: Text(p.merchantNames),
                                              ),
                                              Expanded(
                                                child: Text(p.merchantId),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                              )
                            else
                              TextFormField(
                                controller: controller.manualPaidToController,
                                enabled: controller.isEnable.value,
                                validator: (value) => _validateRequiredField(
                                  controller.manualPaidToController.text,
                                  AppLocalizations.of(
                                    context,
                                  )!.enterMerchantName,
                                  true,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.enterMerchantName,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                            if (controller.isEnable.value)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: controller.isEnable.value
                                      ? () {
                                          setState(() {
                                            controller.isManualEntryMerchant =
                                                !controller
                                                    .isManualEntryMerchant;
                                            if (controller
                                                .isManualEntryMerchant) {
                                              controller.selectedPaidto = null;
                                            } else {
                                              controller.manualPaidToController
                                                  .clear();
                                            }
                                          });
                                        }
                                      : null,
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
                        if (allowCashAd) const SizedBox(height: 12),
                        if (allowCashAd)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Container(
                                  child:
                                      MultiSelectMultiColumnDropdownField<
                                        CashAdvanceDropDownModel
                                      >(
                                        labelText: AppLocalizations.of(
                                          context,
                                        )!.cashAdvanceRequest,
                                        items:
                                            controller.cashAdvanceListDropDown,
                                        isMultiSelect: allowMultSelect ?? false,
                                        dropdownMaxHeight: 300,
                                        selectedValue:
                                            controller.singleSelectedItem,
                                        selectedValues:
                                            controller.multiSelectedItems,
                                        controller: controller.cashAdvanceIds,
                                        enabled: controller.isEnable.value,
                                        searchValue: (proj) =>
                                            proj.cashAdvanceReqId,
                                        displayText: (proj) =>
                                            proj.cashAdvanceReqId,
                                        onChanged: (item) {
                                          controller.singleSelectedItem = item;
                                        },
                                        onMultiChanged: (items) {
                                          controller.multiSelectedItems
                                              .assignAll(items);
                                        },
                                        columnHeaders: [
                                          AppLocalizations.of(
                                            context,
                                          )!.requestId,
                                          AppLocalizations.of(
                                            context,
                                          )!.requestDate,
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
                                                  child: Text(
                                                    proj.cashAdvanceReqId,
                                                  ),
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
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            SearchableMultiColumnDropdownField<
                              PaymentMethodModel
                            >(
                              enabled: controller.isEnable.value,
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
                        const SizedBox(height: 6),

                        // Add this in your State class or controller
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
                                  final String fieldKey = field['FieldName'];
                                  final String fieldType =
                                      field['FieldType'] ?? 'Text';
                                  final bool isDateTime =
                                      fieldType == 'Date&Time';

                                  // Create controller if it doesn't exist
                                  if (!fieldControllers.containsKey(fieldKey)) {
                                    fieldControllers[fieldKey] =
                                        TextEditingController();
                                  }

                                  Widget inputField;
// Percentage type - Make Reactive
 if (fieldType == 'Percentage') {
  if (field['_rxDoubleValue'] == null) {
    field['_rxDoubleValue'] = Rx<double?>(
      field['EnteredValue'] as double?,
    );
  }

  inputField = Obx(() {
    final rxValue = field['_rxDoubleValue'] as Rx<double?>;

    final newText = rxValue.value?.toString() ?? '';
    if (fieldControllers[fieldKey]!.text != newText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fieldControllers[fieldKey]!.text = newText;
      });
    }

    return TextFormField(
      enabled: controller.isEnable.value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      controller: fieldControllers[fieldKey],
      decoration: InputDecoration(
        labelText: '$label${isMandatory ? " *" : ""}',
        border: const OutlineInputBorder(),
        errorText: field['Error'],
        suffixText: '%',
      ),
      onChanged: (value) {
        final doubleValue = double.tryParse(value);
        rxValue.value = doubleValue;
        field['EnteredValue'] = doubleValue;
        field['Error'] = null;
      },
      validator: (value) {
        if (isMandatory && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (value != null && value.isNotEmpty) {
          final p = double.tryParse(value);
          if (p == null || p < 0 || p > 100) {
            return 'Enter a value between 0 and 100';
          }
        }
        return null;
      },
    );
  });
}
                                  // List type fields - Make Reactive
                                  if (fieldType == 'List' ||
                                      fieldType == 'CustomList' ||
                                      fieldType == 'SystemList') {
                                    // Create Rx value if not exists
                                    if (field['_rxSelectedValue'] == null) {
                                      field['_rxSelectedValue'] =
                                          Rx<CustomDropdownValue?>(
                                            field['SelectedValue']
                                                as CustomDropdownValue?,
                                          );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxSelectedValue']
                                              as Rx<CustomDropdownValue?>;
                                      return SearchableMultiColumnDropdownField<
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
                                        selectedValue: rxValue.value,
                                        searchValue: (val) => val.valueName,
                                        enabled: controller.isEnable.value,
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
                                          rxValue.value = val;
                                          field['SelectedValue'] = val;
                                          field['Error'] = null;
                                        },
                                      );
                                    });
                                  }
                                  // Checkbox type - Make Reactive
                                  else if (fieldType == 'Checkbox') {
                                    if (field['_rxCheckboxValue'] == null) {
                                      field['_rxCheckboxValue'] = Rx<bool>(
                                        field['EnteredValue'] ?? false,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxCheckboxValue'] as Rx<bool>;
                                      return CheckboxListTile(
                                        title: Text(
                                          '$label${isMandatory ? " *" : ""}',
                                        ),
                                        value: rxValue.value,
                                        enabled: controller.isEnable.value,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: controller.isEnable.value
                                            ? (bool? val) {
                                                rxValue.value = val ?? false;
                                                field['EnteredValue'] =
                                                    val ?? false;
                                              }
                                            : null,
                                      );
                                    });
                                  }
                                  // Date and DateTime types - Make Reactive
                                  else if (fieldType == 'Date' ||
                                      fieldType == 'Date&Time') {
                                    // Create Rx value if not exists
                                    if (field['_rxDateValue'] == null) {
                                      field['_rxDateValue'] = Rx<DateTime?>(
                                        field['EnteredValue'] as DateTime?,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxDateValue =
                                          field['_rxDateValue']
                                              as Rx<DateTime?>;
                                      final currentDate = rxDateValue.value;

                                      // Update controller text based on Rx value
                                      if (currentDate != null) {
                                        if (isDateTime) {
                                          fieldControllers[fieldKey]!.text =
                                              DateFormat(
                                                'dd/MM/yyyy hh:mm a',
                                              ).format(currentDate);
                                        } else {
                                          fieldControllers[fieldKey]!.text =
                                              DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(currentDate);
                                        }
                                      } else {
                                        fieldControllers[fieldKey]!.text = '';
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        readOnly: true,
                                        controller: fieldControllers[fieldKey],
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                          suffixIcon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                        onTap: controller.isEnable.value
                                            ? () async {
                                                DateTime? currentDate =
                                                    rxDateValue.value ??
                                                    DateTime.now();

                                                final DateTime? pickedDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate: currentDate,
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                    );

                                                if (pickedDate == null) return;

                                                if (isDateTime) {
                                                  TimeOfDay initialTime =
                                                      TimeOfDay.now();
                                                  if (rxDateValue.value !=
                                                      null) {
                                                    initialTime =
                                                        TimeOfDay.fromDateTime(
                                                          rxDateValue.value!,
                                                        );
                                                  }

                                                  final TimeOfDay? pickedTime =
                                                      await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            initialTime,
                                                      );

                                                  if (pickedTime == null)
                                                    return;

                                                  final fullDateTime = DateTime(
                                                    pickedDate.year,
                                                    pickedDate.month,
                                                    pickedDate.day,
                                                    pickedTime.hour,
                                                    pickedTime.minute,
                                                  );

                                                  rxDateValue.value =
                                                      fullDateTime;
                                                  field['EnteredValue'] =
                                                      fullDateTime;
                                                } else {
                                                  rxDateValue.value =
                                                      pickedDate;
                                                  field['EnteredValue'] =
                                                      pickedDate;
                                                }

                                                field['Error'] = null;
                                              }
                                            : null,
                                        validator: (value) {
                                          if (isMandatory &&
                                              rxDateValue.value == null) {
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

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxIntValue'] as Rx<int?>;

                                      // Update controller without triggering rebuild during build
                                      final newText =
                                          rxValue.value?.toString() ?? '';
                                      if (fieldControllers[fieldKey]!.text !=
                                          newText) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              fieldControllers[fieldKey]!.text =
                                                  newText;
                                            });
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        controller: fieldControllers[fieldKey],
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                        ),
                                        onChanged: (value) {
                                          final intValue = int.tryParse(value);
                                          rxValue.value = intValue;
                                          field['EnteredValue'] = intValue;
                                          field['Error'] = null;
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
                                    });
                                  }
                                  // Decimal type - Make Reactive
                                  else if (fieldType == 'Decimal') {
                                    if (field['_rxDoubleValue'] == null) {
                                      field['_rxDoubleValue'] = Rx<double?>(
                                        field['EnteredValue'] as double?,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxDoubleValue']
                                              as Rx<double?>;

                                      // Update controller without triggering rebuild during build
                                      final newText =
                                          rxValue.value?.toString() ?? '';
                                      if (fieldControllers[fieldKey]!.text !=
                                          newText) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              fieldControllers[fieldKey]!.text =
                                                  newText;
                                            });
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d*'),
                                          ),
                                        ],
                                        controller: fieldControllers[fieldKey],
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                        ),
                                        onChanged: (value) {
                                          final doubleValue = double.tryParse(
                                            value,
                                          );
                                          rxValue.value = doubleValue;
                                          field['EnteredValue'] = doubleValue;
                                          field['Error'] = null;
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
                                    });
                                  }
                                  // Email type - Make Reactive
                                  else if (fieldType == 'Email') {
                                    if (field['_rxStringValue'] == null) {
                                      field['_rxStringValue'] = Rx<String?>(
                                        field['EnteredValue'] as String?,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxStringValue']
                                              as Rx<String?>;

                                      // Update controller without triggering rebuild during build
                                      final newText = rxValue.value ?? '';
                                      if (fieldControllers[fieldKey]!.text !=
                                          newText) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              fieldControllers[fieldKey]!.text =
                                                  newText;
                                            });
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: fieldControllers[fieldKey],
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
                                          rxValue.value = value;
                                          field['EnteredValue'] = value;
                                          field['Error'] = null;
                                        },
                                        validator: (value) {
                                          if (isMandatory &&
                                              (value == null ||
                                                  value.trim().isEmpty)) {
                                            return '$label is required';
                                          }
                                          if (value != null &&
                                              value.isNotEmpty) {
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
                                  
                                  // MobileNumber type - Make Reactive
                                  else if (fieldType == 'MobileNumber') {
                                    if (field['_rxStringValue'] == null) {
                                      field['_rxStringValue'] = Rx<String?>(
                                        field['EnteredValue'] as String?,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxStringValue']
                                              as Rx<String?>;

                                      // Update controller without triggering rebuild during build
                                      final newText = rxValue.value ?? '';
                                      if (fieldControllers[fieldKey]!.text !=
                                          newText) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              fieldControllers[fieldKey]!.text =
                                                  newText;
                                            });
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType: TextInputType.phone,
                                        controller: fieldControllers[fieldKey],
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
                                          rxValue.value = value;
                                          field['EnteredValue'] = value;
                                          field['Error'] = null;
                                        },
                                        validator: (value) {
                                          if (isMandatory &&
                                              (value == null ||
                                                  value.trim().isEmpty)) {
                                            return '$label is required';
                                          }
                                          if (value != null &&
                                              value.isNotEmpty) {
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
                                    });
                                  }
                                  // Default Text type - Make Reactive
                                  else {
                                    if (field['_rxStringValue'] == null) {
                                      field['_rxStringValue'] = Rx<String?>(
                                        field['EnteredValue'] as String?,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxStringValue']
                                              as Rx<String?>;

                                      // Update controller without triggering rebuild during build
                                      final newText = rxValue.value ?? '';
                                      if (fieldControllers[fieldKey]!.text !=
                                          newText) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              fieldControllers[fieldKey]!.text =
                                                  newText;
                                            });
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType: TextInputType.text,
                                        controller: fieldControllers[fieldKey],
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                        ),
                                        onChanged: (value) {
                                          rxValue.value = value;
                                          field['EnteredValue'] = value;
                                          field['Error'] = null;
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
                                    });
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
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] == 'Refrence Id',
                            )
                            .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              late Widget inputFields;

                              if (label == 'Refrence Id') {
                                inputFields = _buildTextField(
                                  label:
                                      "${AppLocalizations.of(context)!.referenceId}${isMandatory ? " *" : ""}",
                                  controller: controller.referenceID,
                                  isReadOnly: controller.isEnable.value,
                                  validator: (value) =>
                                      isRefrenceIDConfig.isMandatory
                                      ? _validateRequiredField(
                                          controller.referenceID.text,
                                          AppLocalizations.of(
                                            context,
                                          )!.referenceId,
                                          true,
                                        )
                                      : null,
                                );
                              } else {
                                inputFields = TextField(
                                  decoration: InputDecoration(
                                    labelText:
                                        '$label${isMandatory ? " *" : ""}',
                                    border: const OutlineInputBorder(),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const SizedBox(height: 8),
                                  inputFields,
                                  const SizedBox(height: 16),
                                ],
                              );
                            })
                            .toList(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                controller: controller.paidAmount,
                                onChanged: (_) {
                                  final paid =
                                      double.tryParse(
                                        controller.paidAmount.text,
                                      ) ??
                                      0.0;
                                  final rate =
                                      double.tryParse(
                                        controller.unitRate.text,
                                      ) ??
                                      1.0;

                                  final result = paid * rate;

                                  controller.amountINR.text = result
                                      .toStringAsFixed(2);
                                },
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
                                onEditingComplete: () {
                                  String text = controller.paidAmount.text;
                                  double? value = double.tryParse(text);
                                  if (value != null) {
                                    controller.paidAmount.text = value
                                        .toStringAsFixed(2);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: Obx(
                                () =>
                                    SearchableMultiColumnDropdownField<
                                      Currency
                                    >(
                                      enabled: controller.isEnable.value,
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
                                      validator: (value) =>
                                          _validateRequiredField(
                                            controller
                                                .currencyDropDowncontroller
                                                .text,
                                            AppLocalizations.of(
                                              context,
                                            )!.currency,
                                            true,
                                          ),
                                      onChanged: (c) async {
                                        controller.selectedCurrency.value = c;
                                        controller.fetchExchangeRate().then((
                                          _,
                                        ) {
                                          _updateAllLineItems();
                                        });
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
                                enabled: controller.isEnable.value,
                                controller: controller.unitRate,
                                decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context)!.rate}*',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) => _validateNumericField(
                                  value.toString(),
                                  AppLocalizations.of(context)!.rate,
                                  true,
                                ),
                                onChanged: (val) {
                                  final paid =
                                      double.tryParse(
                                        controller.paidAmount.text,
                                      ) ??
                                      0.0;
                                  final rate = double.tryParse(val) ?? 1.0;

                                  final result = paid * rate;

                                  controller.amountINR.text = result
                                      .toStringAsFixed(2);
                                  controller.isVisible.value = true;
                                  for (
                                    int i = 0;
                                    i < itemizeControllers.length;
                                    i++
                                  ) {
                                    final itemController =
                                        itemizeControllers[i];
                                    final unitPrice =
                                        double.tryParse(
                                          itemController.unitPriceTrans.text,
                                        ) ??
                                        0.0;

                                    final lineAmountInINR = unitPrice * rate;
                                    itemController.lineAmountINR.text =
                                        lineAmountInINR.toStringAsFixed(2);

                                    widget.items.expenseTrans[i] =
                                        itemController
                                            .toExpenseItemUpdateModel();
                                  }

                                  setState(() {});
                                  // print("Paid Amount: $paid");
                                  // print("Rate: $rate");
                                  // print(
                                  //         "Calculated INR Amount: ${controller.amountINR.text}",
                                  // );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controller.amountINR,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.totalAmountIN} '
                                '${controller.organizationCurrency} *',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.itemize} ${AppLocalizations.of(context)!.expense}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.items.expenseTrans.length,
                              itemBuilder: (context, index) {
                                final item = widget.items.expenseTrans[index];
                                final itemController =
                                    itemizeControllers[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${AppLocalizations.of(context)!.item} ${index + 1}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (controller.isEnable.value &&
                                                    widget
                                                            .items
                                                            .expenseTrans
                                                            .length >
                                                        1)
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () =>
                                                        _removeItemize(index),
                                                    tooltip: 'Remove this item',
                                                  ),
                                                if (controller.isEnable.value)
                                                  AnimatedOpacity(
                                                    opacity: _isTyping
                                                        ? 0.0
                                                        : 1.0,
                                                    duration: const Duration(
                                                      milliseconds: 250,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                    child: FutureBuilder<Map<String, bool>>(
                                                      future: _featureFuture,
                                                      builder: (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const SizedBox.shrink();
                                                        }

                                                        if (!snapshot.hasData) {
                                                          return const SizedBox.shrink();
                                                        }

                                                        final featureStates =
                                                            snapshot.data!;
                                                        final isEnabled =
                                                            featureStates['EnableItemization'] ??
                                                            false;

                                                        if (!isEnabled)
                                                          return const SizedBox.shrink();

                                                        return IconButton(
                                                          icon: const Icon(
                                                            Icons.add,
                                                            color: Colors.green,
                                                          ),
                                                          onPressed:
                                                              _addItemize,
                                                          tooltip:
                                                              'Add new item',
                                                        );
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...controller.configList
                                                .where(
                                                  (field) =>
                                                      field['IsEnabled'] ==
                                                          true &&
                                                      field['FieldName'] !=
                                                          'Location' &&
                                                      field['FieldName'] !=
                                                          'Refrence Id' &&
                                                      field['FieldName'] !=
                                                          'Is Billable' &&
                                                      field['FieldName'] !=
                                                          'Is Reimbursible',
                                                )
                                                .map((field) {
                                                  final String label =
                                                      field['FieldName'];
                                                  final bool isMandatory =
                                                      field['IsMandatory'] ??
                                                      false;

                                                  Widget inputField;

                                                  if (label == 'Project Id') {
                                                    inputField = SearchableMultiColumnDropdownField<Project>(
                                                      enabled: controller
                                                          .isEnable
                                                          .value,
                                                      labelText:
                                                          "${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}",
                                                      columnHeaders: const [
                                                        'Project Name',
                                                        'Project ID',
                                                      ],
                                                      items: controller.project,
                                                      selectedValue:
                                                          itemController
                                                              .selectedProject,
                                                      searchValue: (p) =>
                                                          '${p.name} ${p.code}',
                                                      displayText: (p) =>
                                                          p.code,
                                                      validator: (value) =>
                                                          projectConfig
                                                                  .isEnabled &&
                                                              projectConfig
                                                                  .isMandatory
                                                          ? _validateRequiredField(
                                                              itemController
                                                                  .taxGroupController
                                                                  .text,
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.projectId,
                                                              true,
                                                            )
                                                          : null,
                                                      onChanged: (p) {
                                                        setState(() {
                                                          controller
                                                                  .selectedProject =
                                                              p;
                                                          itemController
                                                                  .selectedProject =
                                                              p;
                                                          controller
                                                              .projectDropDowncontroller
                                                              .text = p!
                                                              .code;
                                                          widget
                                                                  .items
                                                                  .expenseTrans[index] =
                                                              itemController
                                                                  .toExpenseItemUpdateModel();
                                                        });
                                                        controller
                                                            .fetchExpenseCategory();
                                                      },
                                                      controller: itemController
                                                          .projectDropDowncontroller,
                                                      rowBuilder: (p, searchQuery) {
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
                                                                  p.name,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  p.code,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } else if (label ==
                                                      'Tax Group') {
                                                    inputField = SearchableMultiColumnDropdownField<TaxGroupModel>(
                                                      enabled: controller
                                                          .isEnable
                                                          .value,
                                                      labelText:
                                                          "${AppLocalizations.of(context)!.taxGroup}${isMandatory ? "*" : ""}",
                                                      columnHeaders: [
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.taxGroup,
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.taxId,
                                                      ],
                                                      items:
                                                          controller.taxGroup,
                                                      selectedValue:
                                                          itemController
                                                              .selectedTax,
                                                      searchValue: (tax) =>
                                                          '${tax.taxGroup} ${tax.taxGroupId}',
                                                      displayText: (tax) =>
                                                          tax.taxGroupId,
                                                      validator: (value) =>
                                                          taxGroupConfig
                                                                  .isEnabled &&
                                                              taxGroupConfig
                                                                  .isMandatory
                                                          ? _validateRequiredField(
                                                              itemController
                                                                  .taxGroupController
                                                                  .text,
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.taxGroup,
                                                              true,
                                                            )
                                                          : null,
                                                      onChanged: (tax) {
                                                        setState(() {
                                                          itemController
                                                                  .selectedTax =
                                                              tax;
                                                          widget
                                                                  .items
                                                                  .expenseTrans[index] =
                                                              itemController
                                                                  .toExpenseItemUpdateModel();
                                                          itemController
                                                              .taxGroupController
                                                              .text = tax!
                                                              .taxGroupId;
                                                        });
                                                      },
                                                      controller: itemController
                                                          .taxGroupController,
                                                      rowBuilder: (tax, searchQuery) {
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 12,
                                                                horizontal: 16,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  tax.taxGroup,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  tax.taxGroupId,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } else if (label ==
                                                      'Tax Amount') {
                                                    inputField = _buildTextField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.allow(
                                                          RegExp(
                                                            r'^\d*\.?\d{0,2}',
                                                          ),
                                                        ),
                                                      ],
                                                      label:
                                                          "${AppLocalizations.of(context)!.taxAmount}${isMandatory ? "*" : ""}",
                                                      controller: itemController
                                                          .taxAmount,
                                                      isReadOnly: controller
                                                          .isEnable
                                                          .value,
                                                      validator: (value) =>
                                                          taxAmountConfig
                                                                  .isEnabled &&
                                                              taxAmountConfig
                                                                  .isMandatory
                                                          ? _validateNumericField(
                                                              value!,
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.taxAmount,
                                                              true,
                                                            )
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          widget
                                                                  .items
                                                                  .expenseTrans[index] =
                                                              itemController
                                                                  .toExpenseItemUpdateModel();
                                                        });
                                                      },
                                                    );
                                                  } else {
                                                    inputField = TextField(
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            '$label${isMandatory ? " *" : ""}',
                                                        border:
                                                            const OutlineInputBorder(),
                                                      ),
                                                    );
                                                  }

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // const SizedBox(height: 8),
                                                      inputField,
                                                      const SizedBox(height: 8),
                                                    ],
                                                  );
                                                })
                                                .toList(),
                                            Obx(() {
                                              print(
                                                'ontroller.customFieldsItems${controller.customFieldsItems}',
                                              );
                                              return Column(
                                                children: itemController
                                                    .customFieldsItems
                                                    .where(
                                                      (field) =>
                                                          field['ObjectName'] ==
                                                              'ExpenseTrans' ||
                                                          field['ObjectName'] ==
                                                              'ExpenseCategories',
                                                    )
                                                    .map((field) {
                                                      final String label =
                                                          field['FieldLabel'] ??
                                                          field['FieldName'];
                                                      final bool isMandatory =
                                                          field['IsMandatory'] ??
                                                          false;
                                                      final String fieldType =
                                                          field['FieldType'] ??
                                                          'Text';

                                                      Widget inputField;

                                                      // List type fields - Make Reactive
                                                      if (field['FieldType'] ==
                                                              'List' ||
                                                          field['FieldType'] ==
                                                              'CustomList' ||
                                                          field['FieldType'] ==
                                                              'SystemList') {
                                                        List<
                                                          CustomDropdownValue
                                                        >
                                                        options = [];
                                                        if (field['Options'] !=
                                                                null &&
                                                            field['Options']
                                                                is List) {
                                                          options =
                                                              List<
                                                                CustomDropdownValue
                                                              >.from(
                                                                field['Options'],
                                                              );
                                                        }

                                                        field['_controller'] ??=
                                                            TextEditingController();
                                                        final TextEditingController
                                                        fieldController =
                                                            field['_controller'];

                                                        CustomDropdownValue?
                                                        selectedValue =
                                                            field['SelectedValue'];

                                                        if (selectedValue ==
                                                                null &&
                                                            field['DefaultValue'] !=
                                                                null) {
                                                          final matches = options.where(
                                                            (opt) =>
                                                                opt.valueId ==
                                                                    field['DefaultValue'] ||
                                                                opt.valueName ==
                                                                    field['DefaultValue'],
                                                          );
                                                          selectedValue =
                                                              matches.isNotEmpty
                                                              ? matches.first
                                                              : null;

                                                          if (selectedValue !=
                                                              null) {
                                                            field['SelectedValue'] =
                                                                selectedValue;
                                                            field['EnteredValue'] =
                                                                selectedValue
                                                                    .valueId;
                                                          }
                                                        }

                                                        // ✅ Show selectedValue name OR fallback to raw DefaultValue string
                                                        fieldController.text =
                                                            selectedValue
                                                                ?.valueName ??
                                                            field['DefaultValue']
                                                                ?.toString() ??
                                                            '';

                                                        // ✅ If no matched selectedValue but DefaultValue exists,
                                                        // create a placeholder CustomDropdownValue so dropdown shows it
                                                        if (selectedValue ==
                                                                null &&
                                                            field['DefaultValue'] !=
                                                                null) {
                                                          selectedValue = CustomDropdownValue(
                                                            valueId:
                                                                field['DefaultValue']
                                                                    .toString(),
                                                            valueName:
                                                                field['DefaultValue']
                                                                    .toString(),
                                                          );
                                                          // ✅ Add to options if not already present (so it renders in list too)
                                                          final alreadyExists =
                                                              options.any(
                                                                (opt) =>
                                                                    opt.valueId ==
                                                                    selectedValue!
                                                                        .valueId,
                                                              );
                                                          if (!alreadyExists) {
                                                            options = [
                                                              selectedValue,
                                                              ...options,
                                                            ];
                                                          }
                                                          field['SelectedValue'] =
                                                              selectedValue;
                                                          field['EnteredValue'] =
                                                              selectedValue
                                                                  .valueId;
                                                        }

                                                        inputField = SearchableMultiColumnDropdownField<CustomDropdownValue>(
                                                          labelText:
                                                              '$label${isMandatory ? " *" : ""}',
                                                          items: options,
                                                          selectedValue:
                                                              selectedValue,
                                                          searchValue: (val) =>
                                                              val.valueName,
                                                          enabled: controller
                                                              .isEnable
                                                              .value,
                                                          displayText: (val) =>
                                                              val.valueName,
                                                          controller:
                                                              fieldController,
                                                          columnHeaders: const [
                                                            'Value ID',
                                                            'Value Name',
                                                          ],
                                                          rowBuilder:
                                                              (
                                                                val,
                                                                searchQuery,
                                                              ) => Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          16,
                                                                    ),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        val.valueId,
                                                                      ),
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
                                                            field['SelectedValue'] =
                                                                val;
                                                            field['EnteredValue'] =
                                                                val?.valueId;
                                                            field['Error'] =
                                                                null;
                                                            fieldController
                                                                    .text =
                                                                val?.valueName ??
                                                                '';
                                                            controller
                                                                .customFields
                                                                .refresh();
                                                          },
                                                        );
                                                      }
                                                      
                                                      // Date and DateTime types - Make Reactive
                                                      else if (fieldType ==
                                                              'Date' ||
                                                          fieldType ==
                                                              'Date&Time') {
                                                        final bool isDateTime =
                                                            fieldType ==
                                                            'Date&Time';

                                                        // Create Rx value if not exists
                                                        if (field['_rxDateValue'] ==
                                                            null) {
                                                          field['_rxDateValue'] =
                                                              Rx<DateTime?>(
                                                                field['EnteredValue']
                                                                    as DateTime?,
                                                              );
                                                        }

                                                        inputField = Obx(() {
                                                          final rxDateValue =
                                                              field['_rxDateValue']
                                                                  as Rx<
                                                                    DateTime?
                                                                  >;
                                                          final currentDate =
                                                              rxDateValue.value;

                                                          // Create controller with current value
                                                          final textEditingController =
                                                              TextEditingController();
                                                          if (currentDate !=
                                                              null) {
                                                            if (isDateTime) {
                                                              textEditingController
                                                                      .text =
                                                                  DateFormat(
                                                                    'dd/MM/yyyy hh:mm a',
                                                                  ).format(
                                                                    currentDate,
                                                                  );
                                                            } else {
                                                              textEditingController
                                                                      .text =
                                                                  DateFormat(
                                                                    'dd/MM/yyyy',
                                                                  ).format(
                                                                    currentDate,
                                                                  );
                                                            }
                                                          }

                                                          return TextFormField(
                                                            enabled: controller
                                                                .isEnable
                                                                .value,
                                                            readOnly: true,
                                                            controller:
                                                                textEditingController,
                                                            decoration: InputDecoration(
                                                              labelText:
                                                                  '$label${isMandatory ? " *" : ""}',
                                                              border:
                                                                  const OutlineInputBorder(),
                                                              errorText:
                                                                  field['Error'],
                                                              suffixIcon:
                                                                  const Icon(
                                                                    Icons
                                                                        .calendar_today,
                                                                  ),
                                                            ),
                                                            onTap:
                                                                controller
                                                                    .isEnable
                                                                    .value
                                                                ? () async {
                                                                    DateTime?
                                                                    currentDate =
                                                                        rxDateValue
                                                                            .value ??
                                                                        DateTime.now();

                                                                    final DateTime?
                                                                    pickedDate = await showDatePicker(
                                                                      context:
                                                                          context,
                                                                      initialDate:
                                                                          currentDate,
                                                                      firstDate:
                                                                          DateTime(
                                                                            2000,
                                                                          ),
                                                                      lastDate:
                                                                          DateTime(
                                                                            2100,
                                                                          ),
                                                                    );

                                                                    if (pickedDate ==
                                                                        null)
                                                                      return;

                                                                    if (isDateTime) {
                                                                      TimeOfDay
                                                                      initialTime =
                                                                          TimeOfDay.now();
                                                                      if (rxDateValue
                                                                              .value !=
                                                                          null) {
                                                                        initialTime = TimeOfDay.fromDateTime(
                                                                          rxDateValue
                                                                              .value!,
                                                                        );
                                                                      }

                                                                      final TimeOfDay?
                                                                      pickedTime = await showTimePicker(
                                                                        context:
                                                                            context,
                                                                        initialTime:
                                                                            initialTime,
                                                                      );

                                                                      if (pickedTime ==
                                                                          null)
                                                                        return;

                                                                      final fullDateTime = DateTime(
                                                                        pickedDate
                                                                            .year,
                                                                        pickedDate
                                                                            .month,
                                                                        pickedDate
                                                                            .day,
                                                                        pickedTime
                                                                            .hour,
                                                                        pickedTime
                                                                            .minute,
                                                                      );

                                                                      rxDateValue
                                                                              .value =
                                                                          fullDateTime;
                                                                      field['EnteredValue'] =
                                                                          fullDateTime;
                                                                      textEditingController
                                                                              .text =
                                                                          DateFormat(
                                                                            'dd/MM/yyyy hh:mm a',
                                                                          ).format(
                                                                            fullDateTime,
                                                                          );
                                                                    } else {
                                                                      rxDateValue
                                                                              .value =
                                                                          pickedDate;
                                                                      field['EnteredValue'] =
                                                                          pickedDate;
                                                                      textEditingController
                                                                              .text =
                                                                          DateFormat(
                                                                            'dd/MM/yyyy',
                                                                          ).format(
                                                                            pickedDate,
                                                                          );
                                                                    }

                                                                    field['Error'] =
                                                                        null;
                                                                  }
                                                                : null,
                                                            validator: (value) {
                                                              if (isMandatory &&
                                                                  rxDateValue
                                                                          .value ==
                                                                      null) {
                                                                return '$label is required';
                                                              }
                                                              return null;
                                                            },
                                                          );
                                                        });
                                                      }
                                                      // Percentage type - Make Reactive
else if (fieldType == 'Percentage') {
  if (field['_rxDoubleValue'] == null) {
    field['_rxDoubleValue'] = Rx<double?>(
      field['EnteredValue'] as double?,
    );
  }

  inputField = Obx(() {
    final rxValue = field['_rxDoubleValue'] as Rx<double?>;
    final textEditingController = TextEditingController(
      text: rxValue.value?.toString() ?? '',
    );

    textEditingController.addListener(() {
      final value = textEditingController.text;
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
    });

    return TextFormField(
      enabled: controller.isEnable.value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: '$label${isMandatory ? " *" : ""}',
        border: const OutlineInputBorder(),
        errorText: field['Error'],
        suffixText: '%',
      ),
      validator: (value) {
        if (isMandatory && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (value != null && value.isNotEmpty) {
          final p = double.tryParse(value);
          if (p == null || p < 0 || p > 100) {
            return 'Enter a value between 0 and 100';
          }
        }
        return null;
      },
    );
  });
}
                                                      // LongInteger (Integer) type - Make Reactive
                                                      else if (fieldType ==
                                                          'LongInteger') {
                                                        if (field['_rxIntValue'] ==
                                                            null) {
                                                          field['_rxIntValue'] =
                                                              Rx<int?>(
                                                                field['EnteredValue']
                                                                    as int?,
                                                              );
                                                        }

                                                        inputField = Obx(() {
                                                          final rxValue =
                                                              field['_rxIntValue']
                                                                  as Rx<int?>;
                                                          final textEditingController =
                                                              TextEditingController(
                                                                text:
                                                                    rxValue
                                                                        .value
                                                                        ?.toString() ??
                                                                    '',
                                                              );

                                                          textEditingController.addListener(() {
                                                            final value =
                                                                textEditingController
                                                                    .text;
                                                            if (value.isEmpty) {
                                                              if (rxValue
                                                                      .value !=
                                                                  null) {
                                                                rxValue.value =
                                                                    null;
                                                                field['EnteredValue'] =
                                                                    null;
                                                              }
                                                            } else {
                                                              final intValue =
                                                                  int.tryParse(
                                                                    value,
                                                                  );
                                                              if (intValue !=
                                                                  rxValue
                                                                      .value) {
                                                                rxValue.value =
                                                                    intValue;
                                                                field['EnteredValue'] =
                                                                    intValue;
                                                              }
                                                            }
                                                            field['Error'] =
                                                                null;
                                                          });

                                                          return TextFormField(
                                                            enabled: controller
                                                                .isEnable
                                                                .value,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly,
                                                            ],
                                                            controller:
                                                                textEditingController,
                                                            decoration: InputDecoration(
                                                              labelText:
                                                                  '$label${isMandatory ? " *" : ""}',
                                                              border:
                                                                  const OutlineInputBorder(),
                                                              errorText:
                                                                  field['Error'],
                                                            ),
                                                            validator: (value) {
                                                              if (isMandatory &&
                                                                  (value ==
                                                                          null ||
                                                                      value
                                                                          .trim()
                                                                          .isEmpty)) {
                                                                return '$label is required';
                                                              }
                                                              return null;
                                                            },
                                                          );
                                                        });
                                                      }
                                                      // Decimal type - Make Reactive
                                                      else if (fieldType ==
                                                          'Decimal') {
                                                        if (field['_rxDoubleValue'] ==
                                                            null) {
                                                          field['_rxDoubleValue'] =
                                                              Rx<double?>(
                                                                field['EnteredValue']
                                                                    as double?,
                                                              );
                                                        }

                                                        inputField = Obx(() {
                                                          final rxValue =
                                                              field['_rxDoubleValue']
                                                                  as Rx<
                                                                    double?
                                                                  >;
                                                          final textEditingController =
                                                              TextEditingController(
                                                                text:
                                                                    rxValue
                                                                        .value
                                                                        ?.toString() ??
                                                                    '',
                                                              );

                                                          textEditingController.addListener(() {
                                                            final value =
                                                                textEditingController
                                                                    .text;
                                                            if (value.isEmpty) {
                                                              if (rxValue
                                                                      .value !=
                                                                  null) {
                                                                rxValue.value =
                                                                    null;
                                                                field['EnteredValue'] =
                                                                    null;
                                                              }
                                                            } else {
                                                              final doubleValue =
                                                                  double.tryParse(
                                                                    value,
                                                                  );
                                                              if (doubleValue !=
                                                                  rxValue
                                                                      .value) {
                                                                rxValue.value =
                                                                    doubleValue;
                                                                field['EnteredValue'] =
                                                                    doubleValue;
                                                              }
                                                            }
                                                            field['Error'] =
                                                                null;
                                                          });

                                                          return TextFormField(
                                                            enabled: controller
                                                                .isEnable
                                                                .value,
                                                            keyboardType:
                                                                const TextInputType.numberWithOptions(
                                                                  decimal: true,
                                                                ),
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter.allow(
                                                                RegExp(
                                                                  r'^\d+\.?\d*',
                                                                ),
                                                              ),
                                                            ],
                                                            controller:
                                                                textEditingController,
                                                            decoration: InputDecoration(
                                                              labelText:
                                                                  '$label${isMandatory ? " *" : ""}',
                                                              border:
                                                                  const OutlineInputBorder(),
                                                              errorText:
                                                                  field['Error'],
                                                            ),
                                                            validator: (value) {
                                                              if (isMandatory &&
                                                                  (value ==
                                                                          null ||
                                                                      value
                                                                          .trim()
                                                                          .isEmpty)) {
                                                                return '$label is required';
                                                              }
                                                              return null;
                                                            },
                                                          );
                                                        });
                                                      }
                                                      // Email type - Make Reactive
                                                      else if (fieldType ==
                                                          'Email') {
                                                        if (field['_rxStringValue'] ==
                                                            null) {
                                                          field['_rxStringValue'] =
                                                              Rx<String?>(
                                                                field['EnteredValue']
                                                                    as String?,
                                                              );
                                                        }

                                                        inputField = Obx(() {
                                                          final rxValue =
                                                              field['_rxStringValue']
                                                                  as Rx<
                                                                    String?
                                                                  >;
                                                          final textEditingController =
                                                              TextEditingController(
                                                                text:
                                                                    rxValue
                                                                        .value ??
                                                                    '',
                                                              );

                                                          textEditingController
                                                              .addListener(() {
                                                                final value =
                                                                    textEditingController
                                                                        .text;
                                                                if (value !=
                                                                    rxValue
                                                                        .value) {
                                                                  rxValue.value =
                                                                      value;
                                                                  field['EnteredValue'] =
                                                                      value;
                                                                }
                                                                field['Error'] =
                                                                    null;
                                                              });

                                                          return TextFormField(
                                                            enabled: controller
                                                                .isEnable
                                                                .value,
                                                            keyboardType:
                                                                TextInputType
                                                                    .emailAddress,
                                                            controller:
                                                                textEditingController,
                                                            decoration: InputDecoration(
                                                              labelText:
                                                                  '$label${isMandatory ? " *" : ""}',
                                                              border:
                                                                  const OutlineInputBorder(),
                                                              errorText:
                                                                  field['Error'],
                                                              suffixIcon:
                                                                  const Icon(
                                                                    Icons
                                                                        .email_outlined,
                                                                  ),
                                                            ),
                                                            validator: (value) {
                                                              if (isMandatory &&
                                                                  (value ==
                                                                          null ||
                                                                      value
                                                                          .trim()
                                                                          .isEmpty)) {
                                                                return '$label is required';
                                                              }
                                                              if (value !=
                                                                      null &&
                                                                  value
                                                                      .isNotEmpty) {
                                                                final emailRegex =
                                                                    RegExp(
                                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                                    );
                                                                if (!emailRegex
                                                                    .hasMatch(
                                                                      value,
                                                                    )) {
                                                                  return 'Enter a valid email address';
                                                                }
                                                              }
                                                              return null;
                                                            },
                                                          );
                                                        });
                                                      }
                                                      // MobileNumber type - Make Reactive
                                                      // MobileNumber type - Make Reactive
                                                      // MobileNumber type - Make Reactive
                                                      else if (fieldType ==
                                                          'MobileNumber') {
                                                        String
                                                        getIsoCodeFromDialCode(
                                                          String dialCode,
                                                        ) {
                                                          final Map<
                                                            String,
                                                            String
                                                          >
                                                          dialCodeToIso = {
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
                                                          return dialCodeToIso[dialCode] ??
                                                              'IN';
                                                        }

                                                        // Create unique key for this field
                                                        final String
                                                        mobileFieldKey =
                                                            '${field['FieldId']}_${field['FieldName']}';

                                                        // Initialize persistent controllers and values if not exists
                                                        if (field['_phoneController'] ==
                                                            null) {
                                                          final defaultValue =
                                                              field['DefaultValue']
                                                                  ?.toString() ??
                                                              '';
                                                          final existingValue =
                                                              field['EnteredValue']
                                                                  as String?;
                                                          final initialValue =
                                                              existingValue ??
                                                              defaultValue;

                                                          // Parse existing phone number to extract country code and number
                                                          String countryCode =
                                                              '+91'; // Default India
                                                          String phoneNumber =
                                                              '';

                                                          if (initialValue
                                                              .isNotEmpty) {
                                                            // Clean the phone number - remove extra plus signs
                                                            String
                                                            cleanedValue =
                                                                initialValue
                                                                    .trim();

                                                            // Handle cases like "++93 85555 000" (double plus)
                                                            while (cleanedValue
                                                                .startsWith(
                                                                  '++',
                                                                )) {
                                                              cleanedValue =
                                                                  '+' +
                                                                  cleanedValue
                                                                      .substring(
                                                                        2,
                                                                      );
                                                            }

                                                            // Parse the phone number
                                                            if (cleanedValue
                                                                .startsWith(
                                                                  '+',
                                                                )) {
                                                              // Extract country code (everything after + until first space or digit)
                                                              final RegExp
                                                              regex = RegExp(
                                                                r'^\+(\d+)\s*(.*)$',
                                                              );
                                                              final match = regex
                                                                  .firstMatch(
                                                                    cleanedValue,
                                                                  );
                                                              if (match !=
                                                                  null) {
                                                                countryCode =
                                                                    '+${match.group(1)}';
                                                                phoneNumber =
                                                                    match
                                                                        .group(
                                                                          2,
                                                                        )
                                                                        ?.trim() ??
                                                                    '';
                                                              } else {
                                                                // If regex doesn't match, try to extract first digits after +
                                                                final String
                                                                afterPlus =
                                                                    cleanedValue
                                                                        .substring(
                                                                          1,
                                                                        );
                                                                final RegExp
                                                                digitsOnly =
                                                                    RegExp(
                                                                      r'^\d+',
                                                                    );
                                                                final matchDigits =
                                                                    digitsOnly
                                                                        .firstMatch(
                                                                          afterPlus,
                                                                        );
                                                                if (matchDigits !=
                                                                    null) {
                                                                  countryCode =
                                                                      '+${matchDigits.group(0)}';
                                                                  phoneNumber = afterPlus
                                                                      .substring(
                                                                        matchDigits
                                                                            .group(
                                                                              0,
                                                                            )!
                                                                            .length,
                                                                      )
                                                                      .trim();
                                                                } else {
                                                                  phoneNumber =
                                                                      cleanedValue;
                                                                }
                                                              }
                                                            } else {
                                                              phoneNumber =
                                                                  cleanedValue;
                                                            }

                                                            print(
                                                              "Parsed phone - Country Code: $countryCode, Number: $phoneNumber",
                                                            );
                                                          }

                                                          // Create controllers
                                                          field['_countryCodeController'] =
                                                              TextEditingController(
                                                                text:
                                                                    countryCode,
                                                              );
                                                          field['_phoneController'] =
                                                              TextEditingController(
                                                                text:
                                                                    phoneNumber,
                                                              );
                                                          field['_rxStringValue'] =
                                                              Rx<String?>(
                                                                initialValue,
                                                              );
                                                          field['_focusNode'] =
                                                              FocusNode();
                                                          field['_selectedCountryCode'] =
                                                              getIsoCodeFromDialCode(
                                                                countryCode,
                                                              );
                                                          field['EnteredValue'] =
                                                              initialValue;

                                                          // Update EnteredValue when phone number changes
                                                          field['_phoneController'].addListener(() {
                                                            final phoneVal =
                                                                field['_phoneController']
                                                                    .text;
                                                            final codeVal =
                                                                field['_countryCodeController']
                                                                    .text;
                                                            String fullNumber =
                                                                '';

                                                            if (phoneVal
                                                                .isNotEmpty) {
                                                              fullNumber =
                                                                  '$codeVal $phoneVal';
                                                            } else if (codeVal
                                                                .isNotEmpty) {
                                                              fullNumber =
                                                                  codeVal;
                                                            }

                                                            if (fullNumber !=
                                                                field['_rxStringValue']
                                                                    .value) {
                                                              field['_rxStringValue']
                                                                      .value =
                                                                  fullNumber;
                                                              field['EnteredValue'] =
                                                                  fullNumber;
                                                            }
                                                            field['Error'] =
                                                                null;
                                                          });

                                                          // Update EnteredValue when country code changes
                                                          field['_countryCodeController'].addListener(() {
                                                            final phoneVal =
                                                                field['_phoneController']
                                                                    .text;
                                                            final codeVal =
                                                                field['_countryCodeController']
                                                                    .text;
                                                            String fullNumber =
                                                                '';

                                                            if (phoneVal
                                                                .isNotEmpty) {
                                                              fullNumber =
                                                                  '$codeVal $phoneVal';
                                                            } else if (codeVal
                                                                .isNotEmpty) {
                                                              fullNumber =
                                                                  codeVal;
                                                            }

                                                            if (fullNumber !=
                                                                field['_rxStringValue']
                                                                    .value) {
                                                              field['_rxStringValue']
                                                                      .value =
                                                                  fullNumber;
                                                              field['EnteredValue'] =
                                                                  fullNumber;
                                                            }
                                                            field['Error'] =
                                                                null;
                                                          });
                                                        }

                                                        // Helper function to convert dial code to ISO code

                                                        // Create a reactive variable for the current country code
                                                        if (field['_currentCountryCode'] ==
                                                            null) {
                                                          field['_currentCountryCode'] =
                                                              Rx<String>(
                                                                field['_selectedCountryCode'] ??
                                                                    'IN',
                                                              );
                                                        }

                                                        inputField = Obx(() {
                                                          final phoneController =
                                                              field['_phoneController']
                                                                  as TextEditingController;
                                                          final countryCodeController =
                                                              field['_countryCodeController']
                                                                  as TextEditingController;
                                                          final focusNode =
                                                              field['_focusNode']
                                                                  as FocusNode;
                                                          final currentCountryCode =
                                                              field['_currentCountryCode']
                                                                  as Rx<String>;

                                                          // Get the current country code and clean it if necessary
                                                          String
                                                          currentDialCode =
                                                              countryCodeController
                                                                  .text;

                                                          // Handle case where country code might have extra spaces or characters
                                                          if (currentDialCode
                                                                  .isNotEmpty &&
                                                              !currentDialCode
                                                                  .startsWith(
                                                                    '+',
                                                                  )) {
                                                            currentDialCode =
                                                                '+$currentDialCode';
                                                          }

                                                          // Clean up the country code (remove any extra spaces)
                                                          currentDialCode =
                                                              currentDialCode
                                                                  .trim();

                                                          // Extract just the digits for ISO lookup
                                                          String cleanDialCode =
                                                              currentDialCode;
                                                          final dialCodeMatch =
                                                              RegExp(
                                                                r'^\+(\d+)',
                                                              ).firstMatch(
                                                                currentDialCode,
                                                              );
                                                          if (dialCodeMatch !=
                                                              null) {
                                                            cleanDialCode =
                                                                '+${dialCodeMatch.group(1)}';
                                                          }

                                                          // Get the ISO code for the current dial code
                                                          final isoCode =
                                                              getIsoCodeFromDialCode(
                                                                cleanDialCode,
                                                              );

                                                          // Update the stored country code if changed
                                                          if (currentCountryCode
                                                                  .value !=
                                                              isoCode) {
                                                            currentCountryCode
                                                                    .value =
                                                                isoCode;
                                                          }

                                                          return SizedBox(
                                                            child: IntlPhoneField(
                                                              key: ValueKey(
                                                                '${mobileFieldKey}_${currentCountryCode.value}',
                                                              ),
                                                              controller:
                                                                  phoneController,
                                                              focusNode:
                                                                  focusNode,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .phone,
                                                              enabled:
                                                                  controller
                                                                      .isEnable
                                                                      .value,
                                                              decoration: InputDecoration(
                                                                labelText:
                                                                    '$label${isMandatory ? " *" : ""}',
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
                                                                errorText:
                                                                    field['Error'],
                                                                counterText: "",
                                                              ),
                                                              initialCountryCode:
                                                                  currentCountryCode
                                                                      .value,
                                                              onChanged: (phone) {
                                                                // Update controllers when phone number changes
                                                                countryCodeController
                                                                        .text =
                                                                    '+${phone.countryCode}';
                                                                phoneController
                                                                        .text =
                                                                    phone
                                                                        .number;

                                                                // Update the stored country code
                                                                final newIsoCode =
                                                                    getIsoCodeFromDialCode(
                                                                      '+${phone.countryCode}',
                                                                    );
                                                                if (currentCountryCode
                                                                        .value !=
                                                                    newIsoCode) {
                                                                  currentCountryCode
                                                                          .value =
                                                                      newIsoCode;
                                                                }

                                                                // Update the full number
                                                                final fullNumber =
                                                                    phone
                                                                        .number
                                                                        .isNotEmpty
                                                                    ? '+${phone.countryCode} ${phone.number}'
                                                                    : '+${phone.countryCode}';

                                                                if (fullNumber !=
                                                                    field['_rxStringValue']
                                                                        .value) {
                                                                  field['_rxStringValue']
                                                                          .value =
                                                                      fullNumber;
                                                                  field['EnteredValue'] =
                                                                      fullNumber;
                                                                }

                                                                // Clear any validation errors when user starts typing
                                                                field['Error'] =
                                                                    null;
                                                              },
                                                              onCountryChanged: (country) {
                                                                // Update controllers when country changes
                                                                countryCodeController
                                                                        .text =
                                                                    '+${country.dialCode}';

                                                                // Update the stored country code
                                                                final newIsoCode =
                                                                    getIsoCodeFromDialCode(
                                                                      '+${country.dialCode}',
                                                                    );
                                                                if (currentCountryCode
                                                                        .value !=
                                                                    newIsoCode) {
                                                                  currentCountryCode
                                                                          .value =
                                                                      newIsoCode;
                                                                }

                                                                // Update the full number when country changes
                                                                final currentNumber =
                                                                    phoneController
                                                                        .text;
                                                                final fullNumber =
                                                                    currentNumber
                                                                        .isNotEmpty
                                                                    ? '+${country.dialCode} $currentNumber'
                                                                    : '+${country.dialCode}';

                                                                if (fullNumber !=
                                                                    field['_rxStringValue']
                                                                        .value) {
                                                                  field['_rxStringValue']
                                                                          .value =
                                                                      fullNumber;
                                                                  field['EnteredValue'] =
                                                                      fullNumber;
                                                                }

                                                                // Clear validation errors when country changes
                                                                field['Error'] =
                                                                    null;
                                                              },
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter.allow(
                                                                  RegExp(
                                                                    r'[0-9\s\-]+',
                                                                  ),
                                                                ),
                                                              ],
                                                              validator: (phone) {
                                                                // Only validate if the field is mandatory
                                                                if (isMandatory) {
                                                                  // Skip validation if the phone number is empty
                                                                  if (phone ==
                                                                          null ||
                                                                      phone
                                                                          .number
                                                                          .trim()
                                                                          .isEmpty) {
                                                                    return '$label is required';
                                                                  }

                                                                  // Only validate the number part (not the country code)
                                                                  final cleanNumber = phone
                                                                      .number
                                                                      .replaceAll(
                                                                        RegExp(
                                                                          r'[\s\-]',
                                                                        ),
                                                                        '',
                                                                      );

                                                                  // Basic length validation (6-15 digits)
                                                                  if (cleanNumber
                                                                              .length <
                                                                          6 ||
                                                                      cleanNumber
                                                                              .length >
                                                                          15) {
                                                                    return 'Enter a valid mobile number (6-15 digits)';
                                                                  }
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          );
                                                        });
                                                      }
                                                      // Default Text type - Make Reactive
                                                      else {
                                                        if (field['_rxStringValue'] ==
                                                            null) {
                                                          field['_rxStringValue'] =
                                                              Rx<String?>(
                                                                field['EnteredValue']
                                                                    as String?,
                                                              );
                                                        }

                                                        // Create stable controller
                                                        field['_textController'] ??=
                                                            TextEditingController();
                                                        final textController =
                                                            field['_textController']
                                                                as TextEditingController;

                                                        inputField = Obx(() {
                                                          final rxValue =
                                                              field['_rxStringValue']
                                                                  as Rx<
                                                                    String?
                                                                  >;

                                                          // Update controller without triggering rebuild
                                                          final newText =
                                                              rxValue.value ??
                                                              '';
                                                          if (textController
                                                                  .text !=
                                                              newText) {
                                                            textController
                                                                    .text =
                                                                newText;
                                                          }

                                                          // Remove old listener and add new one
                                                          textController
                                                              .removeListener(
                                                                _getStringListener(
                                                                  field,
                                                                  rxValue,
                                                                  textController,
                                                                ),
                                                              );
                                                          textController
                                                              .addListener(
                                                                _getStringListener(
                                                                  field,
                                                                  rxValue,
                                                                  textController,
                                                                ),
                                                              );

                                                          return TextFormField(
                                                            // key: ValueKey('text_$fieldKey'),
                                                            // enabled: controller.isEnable.value,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            controller:
                                                                textController,
                                                            decoration: InputDecoration(
                                                              labelText:
                                                                  '$label${isMandatory ? " *" : ""}',
                                                              border:
                                                                  const OutlineInputBorder(),
                                                              errorText:
                                                                  field['Error'],
                                                            ),
                                                            validator: (value) {
                                                              if (isMandatory &&
                                                                  (value ==
                                                                          null ||
                                                                      value
                                                                          .trim()
                                                                          .isEmpty)) {
                                                                return '$label is required';
                                                              }
                                                              return null;
                                                            },
                                                          );
                                                        });
                                                      }

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6,
                                                            ),
                                                        child: inputField,
                                                      );
                                                    })
                                                    .toList(),
                                              );
                                            }),
                                            SizedBox(height: 8),
                                            SearchableMultiColumnDropdownField<
                                              ExpenseCategory
                                            >(
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.paidFor,
                                              enabled:
                                                  controller.isEnable.value,
                                              columnHeaders: [
                                                AppLocalizations.of(
                                                  context,
                                                )!.categoryName,
                                                AppLocalizations.of(
                                                  context,
                                                )!.categoryId,
                                              ],
                                              items: controller.expenseCategory,
                                              selectedValue: itemController
                                                  .selectedCategory,
                                              searchValue: (p) =>
                                                  '${p.categoryName} ${p.categoryId}',
                                              displayText: (p) => p.categoryId,
                                              validator: (value) =>
                                                  _validateRequiredField(
                                                    itemController
                                                        .categoryController
                                                        .text,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.paidFor,
                                                    true,
                                                  ),
                                              onChanged: (p) {
                                                if (p == null) return;

                                                setState(() {
                                                  // Update basic category info
                                                  itemController
                                                          .selectedCategory =
                                                      p;
                                                  itemController
                                                          .selectedCategoryId =
                                                      p.categoryId;
                                                  widget
                                                          .items
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                  itemController
                                                          .categoryController
                                                          .text =
                                                      p.categoryId;
                                                  itemController
                                                          .itemisationMandatory
                                                          .value =
                                                      p.itemisationMandatory;
                                                  itemController
                                                          .minExpenseAmount
                                                          .value =
                                                      (p.minExpensesAmount ?? 0)
                                                          .toDouble();
                                                  itemController
                                                          .receiptRequiredLimit
                                                          .value =
                                                      (p.receiptRequiredLimit ??
                                                              0)
                                                          .toDouble();
                                                  itemController
                                                          .maxExpenseAmount
                                                          .value =
                                                      (p.maxExpenseAmount ?? 0)
                                                          .toDouble();

                                                  // ✅ CRITICAL: Load custom fields from the selected category
                                                  // Remove existing ExpenseCategories custom fields
                                                  itemController
                                                      .customFieldsItems
                                                      .removeWhere(
                                                        (field) =>
                                                            field['ObjectName'] ==
                                                            'ExpenseCategories',
                                                      );

                                                  // Add new custom fields from the selected category
                                                  if (p.customFields != null &&
                                                      p
                                                          .customFields!
                                                          .isNotEmpty) {
                                                    print(
                                                      "Loading ${p.customFields!.length} custom fields for category: ${p.categoryId}",
                                                    );

                                                    for (var categoryField
                                                        in p.customFields!) {
                                                      final Map<String, dynamic>
                                                      field =
                                                          Map<
                                                            String,
                                                            dynamic
                                                          >.from(categoryField);

                                                      // Set required properties
                                                      field['ObjectName'] =
                                                          'ExpenseCategories';
                                                      field['ExpenseType'] =
                                                          'General Expenses';

                                                      // Get default value
                                                      final defaultVal =
                                                          field['DefaultValue']
                                                              ?.toString() ??
                                                          '';
                                                      print(
                                                        "  Field: ${field['FieldName']}, DefaultValue: '$defaultVal', Type: ${field['FieldType']}",
                                                      );

                                                      // Store entered value
                                                      field['EnteredValue'] =
                                                          defaultVal;

                                                      // Initialize Rx based on field type
                                                      final fieldType =
                                                          field['FieldType'];

                                                      if (fieldType == 'List' ||
                                                          fieldType ==
                                                              'CustomList' ||
                                                          fieldType ==
                                                              'SystemList') {
                                                        final options =
                                                            field['Options']
                                                                as List<
                                                                  CustomDropdownValue
                                                                >?;
                                                        CustomDropdownValue?
                                                        matchedOption;
                                                        if (options != null &&
                                                            defaultVal
                                                                .isNotEmpty) {
                                                          matchedOption = options
                                                              .firstWhereOrNull(
                                                                (opt) =>
                                                                    opt.valueName ==
                                                                        defaultVal ||
                                                                    opt.valueId ==
                                                                        defaultVal,
                                                              );
                                                        }
                                                        field['SelectedValue'] =
                                                            matchedOption;
                                                        field['_rxSelectedValue'] =
                                                            Rx<
                                                              CustomDropdownValue?
                                                            >(matchedOption);
                                                      } else if (fieldType ==
                                                          'Checkbox') {
                                                        final boolValue =
                                                            defaultVal
                                                                .toLowerCase() ==
                                                            'true';
                                                        field['_rxCheckboxValue'] =
                                                            Rx<bool>(boolValue);
                                                      } else if (fieldType ==
                                                              'Date' ||
                                                          fieldType ==
                                                              'Date&Time') {
                                                        DateTime? dateValue;
                                                        if (defaultVal
                                                            .isNotEmpty) {
                                                          try {
                                                            dateValue =
                                                                DateTime.parse(
                                                                  defaultVal,
                                                                );
                                                          } catch (e) {
                                                            print(
                                                              "Error parsing date: $e",
                                                            );
                                                          }
                                                        }
                                                        field['_rxDateValue'] =
                                                            Rx<DateTime?>(
                                                              dateValue,
                                                            );
                                                      } else if (fieldType ==
                                                          'LongInteger') {
                                                        field['_rxIntValue'] =
                                                            Rx<int?>(
                                                              int.tryParse(
                                                                defaultVal,
                                                              ),
                                                            );
                                                      } else if (fieldType ==
                                                          'Decimal') {
                                                        field['_rxDoubleValue'] =
                                                            Rx<double?>(
                                                              double.tryParse(
                                                                defaultVal,
                                                              ),
                                                            );
                                                      } else if (fieldType ==
                                                          'Email') {
                                                        field['_rxStringValue'] =
                                                            Rx<String?>(
                                                              defaultVal,
                                                            );
                                                        // Also create controller for better focus handling
                                                        field['_controller'] =
                                                            TextEditingController(
                                                              text: defaultVal,
                                                            );
                                                        field['_focusNode'] =
                                                            FocusNode();
                                                      } else if (fieldType ==
                                                          'MobileNumber') {
                                                        field['_rxStringValue'] =
                                                            Rx<String?>(
                                                              defaultVal,
                                                            );
                                                        field['_controller'] =
                                                            TextEditingController(
                                                              text: defaultVal,
                                                            );
                                                        field['_focusNode'] =
                                                            FocusNode();
                                                      } else {
                                                        // Default Text type
                                                        field['_rxStringValue'] =
                                                            Rx<String?>(
                                                              defaultVal,
                                                            );
                                                        field['_controller'] =
                                                            TextEditingController(
                                                              text: defaultVal,
                                                            );
                                                        field['_focusNode'] =
                                                            FocusNode();
                                                      }

                                                      field['Error'] = null;
                                                      itemController
                                                          .customFieldsItems
                                                          .add(field);
                                                    }
                                                  } else {
                                                    print(
                                                      "No custom fields for category: ${p.categoryId}",
                                                    );
                                                  }

                                                  // Refresh to update UI
                                                  itemController
                                                      .customFieldsItems
                                                      .refresh();
                                                });
                                              },
                                              controller: itemController
                                                  .categoryController,
                                              rowBuilder: (p, searchQuery) {
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
                                                          p.categoryName,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          p.categoryId,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            SearchableMultiColumnDropdownField<
                                              Unit
                                            >( 
                                              labelText:
                                                  '${AppLocalizations.of(context)!.unit} *',
                                              enabled:
                                                  controller.isEnable.value,
                                              columnHeaders: [
                                                AppLocalizations.of(
                                                  context,
                                                )!.uomId,
                                                AppLocalizations.of(
                                                  context,
                                                )!.uomName,
                                              ],
                                              items: controller.unit,
                                              selectedValue:
                                                  itemController.selectedunit,
                                              searchValue: (tax) =>
                                                  '${tax.code} ${tax.name}',
                                              displayText: (tax) => tax.code,
                                              validator: (value) =>
                                                  _validateRequiredField(
                                                    itemController.uomId.text,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.unit,
                                                    true,
                                                  ),
                                              onChanged: (tax) {
                                                setState(() {
                                                  itemController.selectedunit =
                                                      tax;
                                                  itemController.uomId.text =
                                                      tax!.code;
                                                  widget
                                                          .items
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                              controller: itemController.uomId,
                                              rowBuilder: (tax, searchQuery) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(tax.code),
                                                      ),
                                                      Expanded(
                                                        child: Text(tax.name),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            _buildTextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'),
                                                ),
                                              ],
                                              label:
                                                  "${AppLocalizations.of(context)!.quantity} *",
                                              controller:
                                                  itemController.quantity,
                                              isReadOnly:
                                                  controller.isEnable.value,
                                              validator: (value) =>
                                                  _validateNumericField(
                                                    value!,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.quantity,
                                                    true,
                                                  ),
                                              onChanged: (value) {
                                                controller
                                                    .fetchExchangeRate()
                                                    .then((_) {
                                                      _updateAllLineItems();
                                                    });
                                                itemController
                                                    .calculateLineAmounts(
                                                      itemController,
                                                      widget
                                                          .items
                                                          .expenseTrans[index],
                                                    );
                                                _calculateTotalLineAmount(
                                                  itemController,
                                                ).toStringAsFixed(2);
                                                setState(() {
                                                  widget
                                                          .items
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Obx(() {
                                              final error = itemController
                                                  .paidAmountError
                                                  .value;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize
                                                    .min, // 🔥 IMPORTANT (removes extra space)
                                                children: [
                                                  _buildTextFieldUnitAmount(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(
                                                        RegExp(
                                                          r'^\d*\.?\d{0,2}',
                                                        ),
                                                      ),
                                                    ],
                                                    label:
                                                        "${AppLocalizations.of(context)!.unitAmount} *",
                                                    controller: itemController
                                                        .unitPriceTrans,
                                                    isReadOnly: controller
                                                        .isEnable
                                                        .value,

                                                    // ❌ DO NOT USE errorText here
                                                    validator: (value) {
                                                      final basicValidation =
                                                          _validateNumericField(
                                                            value!,
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.unitAmount,
                                                            true,
                                                          );

                                                      if (basicValidation !=
                                                          null)
                                                        return basicValidation;

                                                      final parsed =
                                                          double.tryParse(
                                                            itemController
                                                                .lineAmountINR
                                                                .text,
                                                          ) ??
                                                          0.0;

                                                      final min = itemController
                                                          .minExpenseAmount
                                                          .value;
                                                      final max = itemController
                                                          .maxExpenseAmount
                                                          .value;
                                                      final receiptLimit =
                                                          itemController
                                                              .receiptRequiredLimit
                                                              .value;

                                                      if (parsed < min &&
                                                          itemController
                                                                  .finalItems
                                                                  .length <=
                                                              1) {
                                                        itemController
                                                                .paidAmountError
                                                                .value =
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.reportedAmountNotWithinRange;
                                                        return '';
                                                      }

                                                      if (parsed > max &&
                                                          itemController
                                                                  .finalItems
                                                                  .length <=
                                                              1 &&
                                                          max != 0.0) {
                                                        itemController
                                                                .paidAmountError
                                                                .value =
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.reportedAmountNotWithinRange;
                                                        return '';
                                                      }

                                                      if (receiptLimit > 0 &&
                                                          parsed >=
                                                              receiptLimit) {
                                                        itemController
                                                                .isReceiptRequired
                                                                .value =
                                                            true;
                                                      } else {
                                                        itemController
                                                                .isReceiptRequired
                                                                .value =
                                                            false;
                                                      }

                                                      itemController
                                                              .paidAmountError
                                                              .value =
                                                          ''; // ✅ clear error
                                                      return null;
                                                    },
                                                    onChanged: (value) async {
                                                      controller
                                                          .fetchExchangeRate()
                                                          .then((_) {
                                                            _updateAllLineItems();
                                                          });

                                                      itemController
                                                          .calculateLineAmounts(
                                                            itemController,
                                                          );

                                                      setState(() {
                                                        widget
                                                                .items
                                                                .expenseTrans[index] =
                                                            itemController
                                                                .toExpenseItemUpdateModel();
                                                      });
                                                    },
                                                  ),

                                                  /// ✅ ONLY SHOW ERROR WHEN EXISTS (no extra space)
                                                  if (error.isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        error,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            }),
                                            const SizedBox(height: 8),
                                            // const SizedBox(height: 8),
                                            _buildTextField(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.lineAmount,
                                              controller:
                                                  itemController.lineAmount,
                                              isReadOnly: false,
                                              onChanged: (value) {
                                                itemController
                                                    .calculateLineAmounts(
                                                      itemController,
                                                      widget
                                                          .items
                                                          .expenseTrans[index],
                                                    );
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            _buildTextField(
                                              label: 
                                                  '${AppLocalizations.of(context)!.lineAmountInInr} '
                                                  '${controller.organizationCurrency}',
                                              controller:
                                                  itemController.lineAmountINR,
                                              isReadOnly: false,
                                              onChanged: (value) {
                                                setState(() {
                                                  widget
                                                          .items
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            ...controller.configList
                                                .where(
                                                  (field) =>
                                                      field['IsEnabled'] ==
                                                          true &&
                                                      field['FieldName'] ==
                                                          'Is Reimbursible',
                                                )
                                                .map((field) {
                                                  if (!controller
                                                          .isReimbursableEnabled
                                                          .value &&
                                                      itemController
                                                          .isReimbursiteCreate
                                                          .value) {
                                                    itemController
                                                            .isReimbursable =
                                                        false;
                                                    controller
                                                            .isReimbursiteCreate
                                                            .value =
                                                        false;
                                                  }
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 8),

                                                      Theme(
                                                        data: Theme.of(context).copyWith(
                                                          switchTheme: SwitchThemeData(
                                                            thumbColor: WidgetStateProperty.resolveWith<Color?>((
                                                              states,
                                                            ) {
                                                              final selected =
                                                                  states.contains(
                                                                    WidgetState
                                                                        .selected,
                                                                  );
                                                              if (states.contains(
                                                                WidgetState
                                                                    .disabled,
                                                              )) {
                                                                return selected
                                                                    ? Colors
                                                                          .green
                                                                    : null;
                                                              }
                                                              return selected
                                                                  ? Colors.green
                                                                  : null;
                                                            }),
                                                            trackColor: WidgetStateProperty.resolveWith<Color?>((
                                                              states,
                                                            ) {
                                                              final selected =
                                                                  states.contains(
                                                                    WidgetState
                                                                        .selected,
                                                                  );
                                                              if (states.contains(
                                                                WidgetState
                                                                    .disabled,
                                                              )) {
                                                                return selected
                                                                    ? Colors
                                                                          .green
                                                                          .withOpacity(
                                                                            0.5,
                                                                          )
                                                                    : null;
                                                              }
                                                              return selected
                                                                  ? Colors.green
                                                                        .withOpacity(
                                                                          0.5,
                                                                        )
                                                                  : null;
                                                            }),
                                                          ),
                                                        ),
                                                        child: SwitchListTile(
                                                          title: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.isReimbursable,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          value: itemController
                                                              .isReimbursable,
                                                          onChanged:
                                                              controller
                                                                      .isEnable
                                                                      .value &&
                                                                  controller
                                                                      .isReimbursableEnabled
                                                                      .value
                                                              ? (val) {
                                                                  setState(() {
                                                                    itemController
                                                                            .isReimbursable =
                                                                        val;
                                                                    controller
                                                                            .isReimbursite =
                                                                        val;
                                                                    widget
                                                                        .items
                                                                        .expenseTrans[index] = itemController
                                                                        .toExpenseItemUpdateModel();
                                                                  });
                                                                }
                                                              : null,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 8),
                                                    ],
                                                  );
                                                })
                                                .toList(),

                                            ...controller.configList
                                                .where(
                                                  (field) =>
                                                      field['IsEnabled'] ==
                                                          true &&
                                                      field['FieldName'] ==
                                                          'Is Billable',
                                                )
                                                .map((field) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 8),

                                                      Obx(
                                                        () => Theme(
                                                          data: Theme.of(context).copyWith(
                                                            switchTheme: SwitchThemeData(
                                                              thumbColor: MaterialStateProperty.resolveWith<Color?>((
                                                                states,
                                                              ) {
                                                                if (states.contains(
                                                                  MaterialState
                                                                      .disabled,
                                                                )) {
                                                                  return controller
                                                                          .isBillableCreate
                                                                      ? Colors
                                                                            .blue
                                                                      : Colors
                                                                            .grey
                                                                            .shade400;
                                                                }
                                                                if (states.contains(
                                                                  MaterialState
                                                                      .selected,
                                                                )) {
                                                                  return Colors
                                                                      .blue;
                                                                }
                                                                return Colors
                                                                    .grey
                                                                    .shade400;
                                                              }),
                                                              trackColor: MaterialStateProperty.resolveWith<Color?>((
                                                                states,
                                                              ) {
                                                                if (states.contains(
                                                                  MaterialState
                                                                      .disabled,
                                                                )) {
                                                                  return controller
                                                                          .isBillableCreate
                                                                      ? Colors
                                                                            .blue
                                                                            .withOpacity(
                                                                              0.5,
                                                                            )
                                                                      : Colors
                                                                            .grey
                                                                            .shade300;
                                                                }
                                                                if (states.contains(
                                                                  MaterialState
                                                                      .selected,
                                                                )) {
                                                                  return Colors
                                                                      .blue
                                                                      .withOpacity(
                                                                        0.5,
                                                                      );
                                                                }
                                                                return Colors
                                                                    .grey
                                                                    .shade300;
                                                              }),
                                                            ),
                                                          ),
                                                          child: SwitchListTile(
                                                            title: Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.isBillable,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            value: controller
                                                                .isBillableCreate,
                                                            onChanged:
                                                                controller
                                                                    .isEnable
                                                                    .value
                                                                ? (val) {
                                                                    setState(() {
                                                                      controller
                                                                              .isBillableCreate =
                                                                          val;
                                                                      itemController
                                                                              .isBillableCreate =
                                                                          val;
                                                                      widget
                                                                          .items
                                                                          .expenseTrans[index] = itemController
                                                                          .toExpenseItemUpdateModel();
                                                                    });
                                                                  }
                                                                : null,
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ],
                                                  );
                                                })
                                                .toList(),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    final double lineAmount =
                                                        double.tryParse(
                                                          itemController
                                                              .lineAmount
                                                              .text,
                                                        ) ??
                                                        0.0;
                                                    if (itemController
                                                            .split
                                                            .isEmpty &&
                                                        item
                                                            .accountingDistributions
                                                            .isNotEmpty) {
                                                      itemController.split.assignAll(
                                                        item.accountingDistributions.map((
                                                          e,
                                                        ) {
                                                          return AccountingSplit(
                                                            paidFor: e
                                                                .dimensionValueId,
                                                            percentage: e
                                                                .allocationFactor,
                                                            amount:
                                                                e.transAmount,
                                                          );
                                                        }).toList(),
                                                      );
                                                    } else if (itemController
                                                        .split
                                                        .isEmpty) {
                                                      itemController.split.add(
                                                        AccountingSplit(
                                                          percentage: 100.0,
                                                        ),
                                                      );
                                                    }

                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
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
                                                            splits:
                                                                itemController
                                                                    .split,
                                                            isEnable: controller
                                                                .isEnable
                                                                .value,
                                                            lineAmount:
                                                                lineAmount,
                                                            onChanged:
                                                                (
                                                                  i,
                                                                  updatedSplit,
                                                                ) {
                                                                  if (!mounted)
                                                                    return;

                                                                  itemController
                                                                          .split[i] =
                                                                      updatedSplit;
                                                                },
                                                            onDistributionChanged: (newList) {
                                                              if (!mounted)
                                                                return;
                                                              item.accountingDistributions
                                                                  .clear();
                                                              item.accountingDistributions
                                                                  .addAll(
                                                                    newList,
                                                                  );
                                                              itemController
                                                                  .toExpenseItemUpdateModel();
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
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                        ),
                        _buildSection(
                          title: AppLocalizations.of(context)!.trackingHistory,
                          children: [
                            const SizedBox(height: 12),
                            FutureBuilder<List<ExpenseHistory>>(
                              future: historyFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("No Data Available"),
                                  );
                                }

                                final historyList = snapshot.data!;
                                if (historyList.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.noHistoryMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: historyList.length,
                                  itemBuilder: (context, index) {
                                    final item = historyList[index];
                                    // print("Trackingitem: $item");
                                    return _buildTimelineItem(
                                      item,
                                      index == historyList.length - 1,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (controller.isEnable.value &&
                            widget.items.approvalStatus == "Rejected" &&
                            widget.isReadOnly)
                          Obx(() {
                            final isResubmitLoading =
                                controller.buttonLoaders['resubmit'] ?? false;
                            final isAnyLoading = controller.buttonLoaders.values
                                .any((loading) => loading);

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
                                    29,
                                    1,
                                    128,
                                  ),
                                ),
                                onPressed: (isResubmitLoading || isAnyLoading)
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate() &&
                                            _validateForm()) {
                                          controller.setButtonLoading(
                                            'resubmit',
                                            true,
                                          );
                                          controller.lineItemControllers
                                            ..clear()
                                            ..addAll(itemizeControllers);
                                          controller.addToFinalItems(
                                            widget.items,
                                          );
                                          if (widget.items.unprocessedRecId !=
                                              null) {
                                            controller
                                                .saveinviewPageGeneralExpense(
                                                  context,
                                                  true,
                                                  true,
                                                  widget
                                                      .items
                                                      .unprocessedRecId!,
                                                )
                                                .whenComplete(() {
                                                  controller.setButtonLoading(
                                                    'resubmit',
                                                    false,
                                                  );
                                                });
                                          } else {
                                            controller.lineItemControllers
                                              ..clear()
                                              ..addAll(itemizeControllers);
                                            controller.addToFinalItems(
                                              widget.items,
                                            );
                                            if (widget.items.unprocessedRecId !=
                                                null) {
                                              controller
                                                  .saveinviewPageGeneralExpenseUnProcess(
                                                    context,
                                                    true,
                                                    true,
                                                    widget
                                                        .items
                                                        .unprocessedRecId!,
                                                  )
                                                  .whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'submit',
                                                      false,
                                                    );
                                                    controller.setButtonLoading(
                                                      'saveGE',
                                                      false,
                                                    );
                                                  });
                                            } else {
                                              controller.lineItemControllers
                                                ..clear()
                                                ..addAll(itemizeControllers);
                                              controller.addToFinalItems(
                                                widget.items,
                                              );
                                              controller
                                                  .saveinviewPageGeneralExpense(
                                                    context,
                                                    true,
                                                    true,
                                                    widget.items.recId!,
                                                  )
                                                  .whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'submit',
                                                      false,
                                                    );
                                                  });
                                            }
                                          }
                                        }
                                      },
                                child: isResubmitLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.resubmit,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          }),

                        if (controller.isEnable.value)
                          const SizedBox(height: 20),

                        if (controller.isEnable.value &&
                            widget.items.approvalStatus == "Rejected" &&
                            widget.isReadOnly)
                          Row(
                            children: [
                              Obx(() {
                                final isUpdateLoading =
                                    controller.buttonLoaders['update'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: (isUpdateLoading || isAnyLoading)
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                    .validate() &&
                                                _validateForm()) {
                                              controller.setButtonLoading(
                                                'update',
                                                true,
                                              );
                                              controller.addToFinalItems(
                                                widget.items,
                                              );
                                              controller
                                                  .saveinviewPageGeneralExpense(
                                                    context,
                                                    false,
                                                    false,
                                                    widget.items.recId!,
                                                  )
                                                  .whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'update',
                                                      false,
                                                    );
                                                  });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E7503),
                                    ),
                                    child: isUpdateLoading
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
                                            )!.update,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.chancelButton(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (controller.isEnable.value &&
                            widget.items.approvalStatus == "Created" &&
                            widget.isReadOnly) ...[
                          Obx(() {
                            final isSubmitLoading =
                                controller.buttonLoaders['submit'] ?? false;
                            final isAnyLoading = controller.buttonLoaders.values
                                .any((loading) => loading);

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
                                    : () {
                                        if (_formKey.currentState!.validate() &&
                                            _validateForm()) {
                                          controller.setButtonLoading(
                                            'submit',
                                            true,
                                          );
                                          controller.lineItemControllers
                                            ..clear()
                                            ..addAll(itemizeControllers);
                                          controller.addToFinalItems(
                                            widget.items,
                                          );
                                          controller
                                              .saveinviewPageGeneralExpense(
                                                context,
                                                true,
                                                false,
                                                widget.items.recId!,
                                              )
                                              .whenComplete(() {
                                                controller.setButtonLoading(
                                                  'submit',
                                                  false,
                                                );
                                              });
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
                                        AppLocalizations.of(context)!.submit,
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
                                    controller.buttonLoaders['saveGE'] ?? false;
                                final isSubmitLoading =
                                    controller.buttonLoaders['submit'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        (isSaveLoading ||
                                            isSubmitLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                    .validate() &&
                                                _validateForm()) {
                                              controller.setButtonLoading(
                                                'saveGE',
                                                true,
                                              );
                                              controller.lineItemControllers
                                                ..clear()
                                                ..addAll(itemizeControllers);
                                              controller.addToFinalItems(
                                                widget.items,
                                              );
                                              controller
                                                  .saveinviewPageGeneralExpense(
                                                    context,
                                                    false,
                                                    false,
                                                    widget.items.recId!,
                                                  )
                                                  .whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'submit',
                                                      false,
                                                    );
                                                  });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E7503),
                                    ),
                                    child: isSaveLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!.save,
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
                                    .any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isAnyLoading
                                        ? null
                                        : () {
                                            controller.chancelButton(context);
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

                        if (widget.isReadOnly &&
                            widget.items.approvalStatus == "Pending")
                          Row(
                            children: [ 
                              Obx(() {
                                final isLoading =
                                    controller.buttonLoaders['cancel'] ?? false;
                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            controller.setButtonLoading(
                                              'cancel',
                                              true,
                                            );
                                            controller
                                                .cancelExpense(
                                                  context,
                                                  widget.items.recId.toString(),
                                                )
                                                .whenComplete(() {
                                                  controller.setButtonLoading(
                                                    'cancel',
                                                    false,
                                                  );
                                                });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE99797),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.red,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "Cancel",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.chancelButton(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text("Close"),
                                ),
                              ),
                            ],
                          )
                        else if (!controller.isEnable.value)
                          ElevatedButton(
                            onPressed: () {
                              controller.chancelButton(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: Text(AppLocalizations.of(context)!.close),
                          ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );
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
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PhotoView.customChild(
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 9.0,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Image.file(file, fit: BoxFit.contain),
              ),

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

  Widget buildDateField(
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
                      // print("Invalid date format: ${controllers.text}");
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
                    controller.fetchExpenseCategory();
                    controller.fetchProjectName();
                    controller.selectedDate = picked;
                    controller.fetchProjectName();
                  }
                },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue),
            if (!isLast)
              Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.eventType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(item.notes),
                  const SizedBox(height: 6),
                  Text(
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(item.createdDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        // const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextFieldUnitAmount({
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
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
}
