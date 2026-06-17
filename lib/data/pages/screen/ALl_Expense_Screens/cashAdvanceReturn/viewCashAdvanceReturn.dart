import 'dart:async';
import 'dart:io';

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/utils.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
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
import '../../../../../core/comman/widgets/pageLoaders.dart';
import '../../../../../l10n/app_localizations.dart';

class ViewCashAdvanseReturnForms extends StatefulWidget {
  final bool isReadOnly;
  final GESpeficExpense? items;
  const ViewCashAdvanseReturnForms({
    Key? key,
    this.items,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  State<ViewCashAdvanseReturnForms> createState() =>
      _ViewCashAdvanseReturnFormsState();
}

class _ViewCashAdvanseReturnFormsState extends State<ViewCashAdvanseReturnForms>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();

  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.find<Controller>();
  Future<List<ExpenseHistory>> historyFuture = Future.value([]); //
  late Future<Map<String, bool>> _featureFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  String? statusApproval;
  bool _showHistory = false;
  bool _isTyping = false;
  late FocusNode _focusNode;
  bool allowMultSelect = false;
  bool allowCashAd = false;
  late int workitemrecid;
  bool _showLocationError = false;
  late PageController _pageController;
  Timer? _debounce;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
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

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isTyping = _focusNode.hasFocus;
          });
        }
      });
    });

    _featureFuture = controller.getAllFeatureStates();

    print("merchantId${widget.isReadOnly}");
    expenseIdController.text = "";
    receiptDateController.text = "";
    merhantName.text = "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _pageController = PageController(
        initialPage: controller.currentIndex.value,
      );
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchCashAdvanceExpenseCategory();
      controller.configuration();
      controller.fetchUnit();
      controller.configuration();
      controller.fetchTaxGroup();
      controller.currencyDropDown();

      _initializeData();
      _loadSettings();

      if (widget.items != null) {
        controller.fetchExpenseDocImage(widget.items!.recId);
        historyFuture = controller.fetchExpenseHistory(widget.items!.recId);

        if (widget.items!.receiptDate != null) {
          final int offsetMs =
              int.tryParse(controller.selectedTimezonevalue.value!) ?? 0;
          final DateTime receiptDate = DateTime.fromMillisecondsSinceEpoch(
            widget.items!.receiptDate.millisecondsSinceEpoch + offsetMs,
            isUtc: true,
          );
          final formatted = DateFormat(
            controller.selectedFormat?.key ?? 'dd/MM/yyyy',
          ).format(receiptDate);
          controller.selectedDate = receiptDate;
          receiptDateController.text = formatted;
        }

        controller.paymentMethodID =
            widget.items!.paymentMethod?.toString() ?? "";

        if (widget.items!.workitemrecid != null) {
          workitemrecid = widget.items!.workitemrecid!;
        }

        expenseIdController.text = widget.items!.expenseId ?? '';

        controller.isManualEntryMerchant = widget.items!.merchantId == null;

        controller.paidToController.text =
            widget.items!.merchantId?.toString() ?? '';

        controller.referenceID.text =
            widget.items!.referenceNumber?.toString() ?? '';
        controller.employeeDropDownController.text =
            widget.items!.employeeName ?? '';
        controller.paidWithController.text = widget.items!.paymentMethod ?? '';
        statusApproval = widget.items!.approvalStatus;
        controller.employeeName.text = widget.items!.employeeName!;
        controller.employeeIdController.text = widget.items!.employeeId!;
        controller.paidAmount.text = widget.items!.totalAmountTrans.toString();
        controller.unitAmount.text = widget.items!.totalAmountTrans.toString();
        controller.unitRate.text = widget.items!.exchRate.toString();
        controller.cashAdvReqIds = widget.items!.cashAdvReqId;
        controller.amountINR.text = widget.items!.totalAmountReporting
            .toString();
        controller.expenseID = widget.items!.expenseId;

        controller.isBillableCreate = widget.items!.isBillable;

        if (widget.items!.merchantId == null &&
            widget.items!.merchantName != null) {
          controller.manualPaidToController.text = widget.items!.merchantName!;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          controller.loadAllCustomFieldValues(
            savedValues: widget.items!.expenseHeaderCustomFieldValues,
          );
          _initializeItemizeControllers(); // ✅ now runs AFTER customFields is populated
        });
        controller.currencyDropDowncontroller.text =
            widget.items!.currency ?? '';
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          calculateAmounts(widget.items?.exchRate?.toString() ?? "1.0");
          projectConfig = controller.getFieldConfig("Project Id");
          taxGroupConfig = controller.getFieldConfig("Tax Group");
          taxAmountConfig = controller.getFieldConfig("Tax Amount");
          isReimbursibleConfig = controller.getFieldConfig("Is Reimbursible");
          isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
          isBillableConfig = controller.getFieldConfig("Is Billable");
          isLocationConfig = controller.getFieldConfig("Location");
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    _photoViewController.dispose();
    _debounce?.cancel();

    // Dispose all controllers
    expenseIdController.dispose();
    receiptDateController.dispose();
    referenceController.dispose();
    merhantName.dispose();

    // Dispose itemize controllers
    for (var itemController in itemizeControllers) {
      // Dispose individual text controllers if they exist
      // Add dispose method to your Controller class if needed
    }

    super.dispose();
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
        return '$fieldName ${AppLocalizations.of(context)!.somethingWentWrong}';
      }
      if (numericValue < 0) {
        return '$fieldName ${AppLocalizations.of(context)!.somethingWentWrong}';
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
        return '$fieldName ${AppLocalizations.of(context)!.somethingWentWrong}';
      }
    }
    return null;
  }

  bool _validateForm() {
    bool isValid = true;

    if (_validateRequiredField(
          expenseIdController.text,
          AppLocalizations.of(context)!.expenseId,
          true,
        ) !=
        null) {
      isValid = false;
    }

    if (_validateDateField(
          receiptDateController.text,
          AppLocalizations.of(context)!.receiptDate,
          true,
        ) !=
        null) {
      isValid = false;
    }

    // if (_validateRequiredField(
    //       controller.paidWithController.text,
    //       AppLocalizations.of(context)!.paidWith,
    //       true,
    //     ) !=
    //     null) {
    //   isValid = false;
    // }
    if (_validateRequiredField(
          controller.cashAdvanceIds.text,
          AppLocalizations.of(context)!.cashAdvanceRequest,
          true,
        ) !=
        null) {
      isValid = false;
    }
    if (_validateNumericField(
          controller.paidAmount.text,
          AppLocalizations.of(context)!.paidAmount,
          true,
        ) !=
        null) {
      isValid = false;
    }

    if (_validateRequiredField(
          controller.currencyDropDowncontroller.text,
          AppLocalizations.of(context)!.currency,
          true,
        ) !=
        null) {
      isValid = false;
    }

    if (_validateNumericField(
          controller.unitRate.text,
          AppLocalizations.of(context)!.rate,
          true,
        ) !=
        null) {
      isValid = false;
    }

    if (isRefrenceIDConfig.isEnabled && isRefrenceIDConfig.isMandatory) {
      if (_validateRequiredField(
            controller.referenceID.text,
            AppLocalizations.of(context)!.referenceId,
            true,
          ) !=
          null) {
        isValid = false;
      }
    }

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];

      if (projectConfig.isEnabled && projectConfig.isMandatory) {
        if (_validateRequiredField(
              itemController.projectDropDowncontroller.text,
              AppLocalizations.of(context)!.projectId,
              true,
            ) !=
            null) {
          isValid = false;
        }
      }

      if (_validateRequiredField(
            itemController.categoryController.text,
            AppLocalizations.of(context)!.paidFor,
            true,
          ) !=
          null) {
        isValid = false;
      }

      if (_validateRequiredField(
            itemController.uomId.text,
            AppLocalizations.of(context)!.unit,
            true,
          ) !=
          null) {
        isValid = false;
      }

      if (_validateNumericField(
            itemController.quantity.text,
            AppLocalizations.of(context)!.quantity,
            true,
          ) !=
          null) {
        isValid = false;
      }

      if (_validateNumericField(
            itemController.unitPriceTrans.text,
            AppLocalizations.of(context)!.unitAmount,
            true,
          ) !=
          null) {
        isValid = false;
      }

      if (taxGroupConfig.isEnabled && taxGroupConfig.isMandatory) {
        if (_validateRequiredField(
              itemController.taxGroupController.text,
              AppLocalizations.of(context)!.taxGroup,
              true,
            ) !=
            null) {
          isValid = false;
        }
      }

      if (taxAmountConfig.isEnabled && taxAmountConfig.isMandatory) {
        if (_validateNumericField(
              itemController.taxAmount.text,
              AppLocalizations.of(context)!.taxAmount,
              true,
            ) !=
            null) {
          isValid = false;
        }
      }
    }

    return isValid;
  }

  Future<void> _initializeData() async {
    await loadAndAppendCashAdvanceList();
    initializeCashAdvanceSelection();
  }

  void initializeCashAdvanceSelection() {
    String? backendSelectedIds = controller.cashAdvReqIds;
    print("controller.cashAdvReqIds$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
      controller.cashAdvanceListDropDown,
      backendSelectedIds,
    );
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
            allowCashAd = settings.allowCashAdvAgainstExpenseReg;
            print("allowDocAttachments$allowMultSelect");
          });
        }
      });
    }
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

      print(
        "✅ Updated cashAdvanceListDropDown: ${controller.cashAdvanceListDropDown.length}",
      );
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', e.toString());
      });
    }
  }

  void _initializeItemizeControllers() {
    final mainController = Get.find<Controller>();
    if (widget.items!.expenseTrans.isEmpty) {
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
    if (widget.items?.expenseTrans != null) {
      itemizeControllers = widget.items!.expenseTrans.map((item) {
        final itemController = Controller();
        // final itemController = Controller();
        print("Mapping AccountingDistribution => item: ${item.recId}");
        itemController.recID = item.recId;
        itemController.projectDropDowncontroller.text = item.projectId ?? '';
        itemController.descriptionController.text = item.description ?? '';
        itemController.quantity.text = item.quantity?.toString() ?? '0';
        itemController.unitPriceTrans.text =
            item.unitPriceTrans?.toString() ?? '0';
        itemController.lineAmount.text =
            item.lineAmountTrans?.toString() ?? '0';
        itemController.lineAmountINR.text =
            item.lineAmountReporting?.toString() ?? '0';
        itemController.taxAmount.text = item.taxAmount?.toString() ?? '0';
        itemController.taxGroupController.text = item.taxGroup ?? '';
        itemController.categoryController.text = item.expenseCategoryId ?? '';
        itemController.uomId.text = item.uomId ?? '';
        itemController.isReimbursable = item.isReimbursable ?? false;
        itemController.isBillableCreate = item.isBillable ?? false;
        itemController.toExpenseItemUpdateModels(item.recId);
        controller.loadAllCustomFieldValues(
          savedValues: item.expenseTransCustomFieldValues,
        );
        if (item.accountingDistributions != null &&
            item.accountingDistributions!.isNotEmpty) {
          itemController.split = item.accountingDistributions!.map((dist) {
            return AccountingSplit(
              paidFor: dist.dimensionValueId ?? '',
              percentage: dist.allocationFactor ?? 0.0,
              amount: dist.transAmount ?? 0.0,
            );
          }).toList();
          // ✅ CRITICAL FIX: First, make sure customFieldsItems has all fields from main controller
          if (mainController.customFields.isNotEmpty) {
            itemController.cloneCustomFieldsFromRx(mainController.customFields);
            print(
              "Cloned ${itemController.customFieldsItems.length} fields for item ",
            );
          } else {
            print("Main controller customFields is empty for item ");
            itemController.customFieldsItems.value = [];
          }

          // ✅ NOW load ExpenseTrans custom fields (transaction level)
          if (item.expenseTransCustomFieldValues.isNotEmpty) {
            print(
              "Loading ExpenseTrans custom fields for item : ${item.expenseTransCustomFieldValues.length} fields",
            );

            for (var savedField in item.expenseTransCustomFieldValues!) {
              final savedFieldId = savedField['FieldId'];
              final savedFieldValue = savedField['FieldValue'];
              final savedFieldName = savedField['FieldName'];

              print(
                "Looking for ExpenseTrans field: $savedFieldId - $savedFieldName",
              );

              // Find matching field in customFieldsItems by FieldId
              final matchingFieldIndex = itemController.customFieldsItems
                  .indexWhere((f) => f['FieldId'] == savedFieldId);

              if (matchingFieldIndex != -1) {
                final field =
                    itemController.customFieldsItems[matchingFieldIndex];
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
                itemController.customFieldsItems.add(newField);
                print("  → Created new field: $savedFieldName");
              }
            }
          }
          if (item.expenseTransExpensecategorycustomfieldvalues != null &&
              item.expenseTransExpensecategorycustomfieldvalues!.isNotEmpty) {
            print(
              "Loading ExpenseCategories custom fields for item : ${item.expenseTransExpensecategorycustomfieldvalues!.length} fields",
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
              int matchingFieldIndex = itemController.customFieldsItems
                  .indexWhere(
                    (f) =>
                        f['FieldId'] == savedFieldId &&
                        f['ObjectName'] == 'ExpenseCategories',
                  );

              // If not found, try to find without ObjectName constraint
              if (matchingFieldIndex == -1) {
                matchingFieldIndex = itemController.customFieldsItems
                    .indexWhere((f) => f['FieldId'] == savedFieldId);
              }

              if (matchingFieldIndex != -1) {
                final field =
                    itemController.customFieldsItems[matchingFieldIndex];
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

                itemController.customFieldsItems.add(newField);
                print(
                  "  → Created new ExpenseCategories field: $savedFieldName with value: $savedFieldValue",
                );
              }
            }
          } else {
            print("No ExpenseCategories custom fields found for item ");
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
              final defaultValue =
                  categoryField['DefaultValue']?.toString() ?? '';

              // Check if this field already has a value (either saved or set)
              final existingFieldIndex = itemController.customFieldsItems
                  .indexWhere(
                    (f) =>
                        f['FieldId'] == fieldId &&
                        f['ObjectName'] == 'ExpenseCategories',
                  );

              if (existingFieldIndex != -1) {
                final field =
                    itemController.customFieldsItems[existingFieldIndex];
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
                  final options =
                      newField['Options'] as List<CustomDropdownValue>?;
                  CustomDropdownValue? matchedOption;
                  if (options != null && defaultVal.isNotEmpty) {
                    matchedOption = options.firstWhereOrNull(
                      (opt) =>
                          opt.valueName == defaultVal ||
                          opt.valueId == defaultVal,
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

                itemController.customFieldsItems.add(newField);
              }
            }
          }
          itemController.accountingDistributions.clear();
          itemController.accountingDistributions.addAll(
            item.accountingDistributions!.map((dist) {
              return AccountingDistribution(
                transAmount: dist.transAmount ?? 0.0,
                reportAmount: dist.reportAmount ?? 0.0,
                allocationFactor: dist.allocationFactor ?? 0.0,
                dimensionValueId: dist.dimensionValueId ?? '',
              );
            }),
          );
        } else {
          itemController.split = [];
          itemController.accountingDistributions.clear();
        }

        return itemController;
      }).toList();
    } else {
      itemizeControllers = [];
    }

    _itemizeCount = itemizeControllers.length;
  }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (controller.paymentMethods.isNotEmpty && widget.items != null) {
        controller.selectedPaidWith = controller.paymentMethods.firstWhere(
          (e) => e.paymentMethodId == widget.items!.paymentMethod,
          orElse: () => controller.paymentMethods.first,
        );
      }

      if (controller.project.isNotEmpty && widget.items != null) {
        controller.selectedProject = controller.project.firstWhere(
          (e) => e.code == widget.items!.projectId,
          orElse: () => controller.project.first,
        );
      }
      if (controller.currencies.isNotEmpty && widget.items != null) {
        controller.selectedCurrency.value = controller.currencies.firstWhere(
          (e) => e.code == widget.items!.currency,
          orElse: () => controller.currencies.first,
        );
      }
      setState(() {});
    });
  }

  Future<void> calculateAmounts(String rateStr) async {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
      final rate = double.tryParse(rateStr) ?? 1.0;

      final result = paid * rate;
      controller.amountINR.text = result.toStringAsFixed(2);
      controller.isVisible.value = true;

      for (int i = 0; i < itemizeControllers.length; i++) {
        final itemController = itemizeControllers[i];
        final unitPrice =
            double.tryParse(itemController.lineAmount.text) ?? 0.0;

        final lineAmountInINR = unitPrice * rate;
        itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

        if (widget.items != null && i < widget.items!.expenseTrans.length) {
          widget.items!.expenseTrans[i] = itemController
              .toExpenseItemUpdateModel();
        }
      }
    });
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final newItem = ExpenseItemUpdate(
          description: '',
          quantity: 0,
          unitPriceTrans: 0,
          lineAmountTrans: 0,
          lineAmountReporting: 0,
          taxAmount: 0,
          isReimbursable: controller.isReimbursable,
          isBillable: controller.isBillableCreate,
          projectId: controller.projectDropDowncontroller.text ?? '',
          expenseCategoryId: controller.categoryController.text ?? "",
          uomId: '',
          taxGroup: controller.taxGroup.isNotEmpty
              ? controller.taxGroup.first.taxGroupId
              : '',
          accountingDistributions: [],
        );
        debugPrint("Added new item: ${newItem.toString()}");

        widget.items!.expenseTrans.add(newItem);

        final newController = Controller();

        newController.descriptionController.text = newItem.description ?? '';
        newController.quantity.text = newItem.quantity.toString();
        newController.unitPriceTrans.text = newItem.unitPriceTrans.toString();
        newController.lineAmount.text = newItem.lineAmountTrans.toString();
        newController.lineAmountINR.text = newItem.lineAmountReporting
            .toString();
        newController.taxAmount.text = newItem.taxAmount.toString();
        newController.projectDropDowncontroller.text = newItem.projectId ?? '';
        newController.categoryController.text = newItem.expenseCategoryId;
        newController.uomId.text = newItem.uomId;
        newController.taxGroupController.text = newItem.taxGroup ?? '';
        newController.isReimbursable = newItem.isReimbursable;
        newController.isBillableCreate = newItem.isBillable;

        if (controller.project.isNotEmpty) {
          newController.selectedProject = controller.project.firstWhere(
            (p) => p.code == newItem.projectId,
            orElse: () => controller.project.first,
          );
        }

        if (controller.expenseCategory.isNotEmpty) {
          newController.selectedCategory = controller.expenseCategory
              .firstWhere(
                (c) => c.categoryId == newItem.expenseCategoryId,
                orElse: () => controller.expenseCategory.first,
              );
        }

        if (controller.unit.isNotEmpty) {
          Unit? selected;

          try {
            selected = controller.unit.firstWhere(
              (u) => u.code == newItem.uomId,
            );
          } catch (e) {
            selected = null;
          }

          selected ??= controller.unit.firstWhere(
            (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
            orElse: () => controller.unit.first,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                controller.selectedunit = selected;
              });
            }
          });
        }

        if (controller.taxGroup.isNotEmpty) {
          newController.selectedTax = controller.taxGroup.firstWhere(
            (t) => t.taxGroupId == newItem.taxGroup,
            orElse: () => controller.taxGroup.first,
          );
        }

        debugPrint(
          "Controller added with unit: ${newController.selectedunit?.name}",
        );

        itemizeControllers = List.from(itemizeControllers)..add(newController);

        _itemizeCount++;
        _selectedItemizeIndex = _itemizeCount - 1;
        showItemizeDetails = true;

        setState(() {});
      });
    }
  }

  void _removeItemize(int index) {
    if (!mounted) return;

    if (_itemizeCount <= 1) {
      setState(() {
        showItemizeDetails = false;
      });
    } else if (index >= 0 && index < widget.items!.expenseTrans.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          widget.items!.expenseTrans.removeAt(index);
          itemizeControllers.removeAt(index);
          _itemizeCount--;
          if (_selectedItemizeIndex >= _itemizeCount) {
            _selectedItemizeIndex = _itemizeCount - 1;
          }
        });
      });
    }
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
    print("paidAmount${controllers.lineAmount.text}");

    controller.paidAmount.text = total.toStringAsFixed(2);

    final paid = total;
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    controller.amountINR.text = (paid * rate).toStringAsFixed(2);

    return total;
  }

  Future<void> _updateAllLineItems() async {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      controller.calculateLineAmounts(itemController);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      controller.isImageLoading.value = true;

      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                controller.imageFiles.add(File(croppedFile.path));
              });
            }
          });
        }
      }
    } catch (e) {
      print("Error picking or cropping image: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: "Failed to upload image",
          backgroundColor: Colors.red,
        );
      });
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.grey;
    if (statusApproval != null) {
      switch (statusApproval) {
        case 'Approved':
          buttonColor = Colors.green;
          break;
        case 'Rejected':
          buttonColor = Colors.red;
          break;
        case 'Pending':
          buttonColor = Colors.orange;
          break;
        case "Created":
          buttonColor = Colors.blue;
          break;
        default:
          buttonColor = Colors.grey;
      }
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
          controller.isLoadingGE1.value = false;
          Navigator.of(context).pop();
          return true;
        }

        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            controller.isEnable.value
                ? AppLocalizations.of(context)!.editCashAdvanceReturn
                : AppLocalizations.of(context)!.viewCashAdvanceReturn,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
            softWrap: true,
            maxLines: 2,
          ),
          actions: [
            if (widget.isReadOnly &&
                    widget.items != null &&
                    widget.items!.approvalStatus != "Approved" &&
                    widget.items!.approvalStatus != "Cancelled" &&
                    widget.items!.approvalStatus != "Pending" ||
                widget.items!.stepType != null &&
                    (widget.items!.approvalStatus == "Pending" ||
                        widget.items!.approvalStatus == "Created") &&
                    PermissionHelper.canUpdate("Expense Registration"))
              IconButton(
                icon: Icon(
                  widget.items!.stepType == "Approval"
                      ? (controller.isApprovalEnable.value
                            ? Icons.remove_red_eye
                            : Icons.edit_document)
                      : (controller.isEnable.value
                            ? Icons.remove_red_eye
                            : Icons.edit_document),
                ),
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;

                    setState(() {
                      if (widget.items!.stepType == "Approval") {
                        controller.isApprovalEnable.value =
                            !controller.isApprovalEnable.value;
                      } else if (widget.items!.approvalStatus != "Cancelled") {
                        controller.isEnable.value = !controller.isEnable.value;
                      }
                    });
                  });
                },
              ),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingviewImage.value
              ? const SkeletonLoaderPage()
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.items != null)
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
                                    statusApproval ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: const Size(0, 32),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 5),
                          _buildImageSection(),
                          const SizedBox(height: 20),
                          _buildReceiptDetailsSection(),
                          const SizedBox(height: 20),
                          _buildItemizedExpensesSection(),
                          const SizedBox(height: 20),
                          _buildTrackingHistorySection(),
                          const SizedBox(height: 20),
                          _buildActionButtonsSection(),
                        ],
                      ),
                    ),
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: () {},
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() {
            if (controller.imageFiles.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.tapToUploadDocs),
              );
            } else {
              return Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: controller.imageFiles.length,
                    onPageChanged: (index) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.currentIndex.value = index;
                      });
                    },
                    itemBuilder: (_, index) {
                      final file = controller.imageFiles[index];
                      return GestureDetector(
                        onTap: () => _showFullImage(file, index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(8),
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
                  if (controller.isEnable.value)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildReceiptDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.receiptDetails,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          label: "${AppLocalizations.of(context)!.expenseId} *",
          controller: expenseIdController,
          isReadOnly: false,
          validator: (value) => _validateRequiredField(
            value!,
            AppLocalizations.of(context)!.expenseId,
            true,
          ),
        ),
        const SizedBox(height: 12),
        _buildDateField(
          AppLocalizations.of(context)!.returnDate,
          receiptDateController,
          isReadOnly: !controller.isEnable.value,
          validator: (value) => _validateDateField(
            value!,
            AppLocalizations.of(context)!.returnDate,
            true,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: "${AppLocalizations.of(context)!.employeeId} *",
          controller: controller.employeeIdController,
          isReadOnly: false,
          validator: (value) => _validateRequiredField(
            value!,
            AppLocalizations.of(context)!.employeeId,
            true,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: "${AppLocalizations.of(context)!.employeeName} *",
          controller: controller.employeeName,
          isReadOnly: false,
          validator: (value) => _validateRequiredField(
            value!,
            AppLocalizations.of(context)!.employeeName,
            true,
          ),
        ),

        const SizedBox(height: 12),
        _buildLocationField(),
        if (allowCashAd) const SizedBox(height: 12),
        if (allowCashAd) _buildCashAdvanceDropdown(),
        const SizedBox(height: 12),
        _buildPaidWithField(),
        const SizedBox(height: 12),

        ...controller.configList
            .where(
              (field) =>
                  field['IsEnabled'] == true &&
                  field['FieldName'] == 'Refrence Id',
            )
            .map((field) {
              final String label = field['FieldName'];
              final bool isMandatory = field['IsMandatory'] ?? false;

              late Widget inputFields;

              if (label == 'Refrence Id') {
                inputFields = _buildTextField(
                  label:
                      "${AppLocalizations.of(context)!.referenceId}${isMandatory ? " *" : ""}",
                  controller: controller.referenceID,
                  isReadOnly: controller.isEnable.value,
                  validator: (value) => isRefrenceIDConfig.isMandatory
                      ? _validateRequiredField(
                          controller.referenceID.text,
                          AppLocalizations.of(context)!.referenceId,
                          true,
                        )
                      : null,
                );
              } else {
                inputFields = TextField(
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
                  inputFields,
                  const SizedBox(height: 16),
                ],
              );
            })
            .toList(),
        const SizedBox(height: 12),
        _buildAmountFields(),
        const SizedBox(height: 20),
        _buildAmountINRField(),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.configListAdvance
          .where(
            (field) =>
                field['FieldName'] == 'Location' && field['IsEnabled'] == true,
          )
          .map((field) {
            final bool isMandatory = field['IsMandatory'] ?? false;

            return SearchableMultiColumnDropdownField<LocationModel>(
              labelText:
                  '${AppLocalizations.of(context)!.location} ${isMandatory ? "*" : ""}',
              columnHeaders: [
                AppLocalizations.of(context)!.location,
                AppLocalizations.of(context)!.country,
              ],
              enabled: controller.isEnable.value,
              controller: controller.locationController,
              items: controller.location,
              selectedValue: controller.selectedLocation,
              searchValue: (loc) => loc.location,
              displayText: (loc) => loc.location,
              validator: (value) => isMandatory && (value == null)
                  ? '${AppLocalizations.of(context)!.location} ${AppLocalizations.of(context)!.fieldRequired}'
                  : null,
              onChanged: (loc) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.selectedLocation = loc;
                  controller.fetchMaxAllowedPercentage();

                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  _debounce = Timer(
                    const Duration(milliseconds: 400),
                    () async {
                      final paidAmountText = controller.paidAmountCA1.text
                          .trim();
                      controller.unitAmount.text =
                          controller.paidAmountCA1.text;
                      final double paidAmounts =
                          double.tryParse(paidAmountText) ?? 0.0;
                      final currency =
                          controller.currencyDropDowncontrollerCA3.text;

                      if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
                        final results = await Future.wait([
                          controller.fetchExchangeRateCA(
                            currency,
                            paidAmountText,
                          ),
                          controller.fetchMaxAllowedPercentage(),
                        ]);

                        final exchangeResponse1 =
                            results[0] as ExchangeRateResponse?;
                        if (exchangeResponse1 != null) {
                          controller.unitRateCA1.text = exchangeResponse1
                              .exchangeRate
                              .toString();
                          controller.amountINRCA1.text = exchangeResponse1
                              .totalAmount
                              .toStringAsFixed(2);
                          controller.isVisible.value = true;
                        }

                        final maxPercentage = results[1] as double?;
                        if (maxPercentage != null && maxPercentage > 0) {
                          final double calculatedPercentage =
                              (paidAmounts * maxPercentage) / 100;
                          controller.totalRequestedAmount.text =
                              calculatedPercentage.toString();
                          controller.calculatedPercentage.value =
                              calculatedPercentage;
                          final percentageStr = maxPercentage
                              .toInt()
                              .toString();
                          controller.requestedPercentage.text =
                              '$percentageStr %';
                        }

                        final reqPaidAmount = controller
                            .totalRequestedAmount
                            .text
                            .trim();
                        final reqCurrency =
                            controller.currencyDropDowncontrollerCA2.text;
                        if (reqCurrency.isNotEmpty &&
                            reqPaidAmount.isNotEmpty) {
                          final exchangeResponse = await controller
                              .fetchExchangeRateCA(reqCurrency, reqPaidAmount);
                          if (exchangeResponse != null) {
                            controller.unitRateCA2.text = exchangeResponse
                                .exchangeRate
                                .toString();
                            controller.amountINRCA2.text = exchangeResponse
                                .totalAmount
                                .toStringAsFixed(2);
                          }
                        }
                      }
                    },
                  );
                  field['Error'] = null;
                });
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
            );
          })
          .toList(),
    );
  }

  Widget _buildCashAdvanceDropdown() {
    return MultiSelectMultiColumnDropdownField<CashAdvanceDropDownModel>(
      labelText: '${AppLocalizations.of(context)!.cashAdvanceRequest} *',
      items: controller.cashAdvanceListDropDown,
      isMultiSelect: allowMultSelect ?? false,
      selectedValue: controller.singleSelectedItem,
      selectedValues: controller.multiSelectedItems,
      controller: controller.cashAdvanceIds,
      enabled: controller.isEnable.value,
      searchValue: (proj) => proj.cashAdvanceReqId,
      displayText: (proj) => proj.cashAdvanceReqId,
      validator: (value) => _validateRequiredField(
        controller.cashAdvanceIds.text,
        AppLocalizations.of(context)!.cashAdvanceRequest,
        true,
      ),
      onChanged: (item) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.singleSelectedItem = item;
        });
      },
      onMultiChanged: (items) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.multiSelectedItems.assignAll(items);
        });
      },
      columnHeaders: [
        AppLocalizations.of(context)!.requestId,
        AppLocalizations.of(context)!.requestDate,
      ],
      rowBuilder: (proj, searchQuery) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(proj.cashAdvanceReqId)),
              Expanded(child: Text(controller.formattedDate(proj.requestDate))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaidWithField() {
    return SearchableMultiColumnDropdownField<PaymentMethodModel>(
      enabled: controller.isEnable.value,
      labelText: AppLocalizations.of(context)!.paidWith,
      columnHeaders: [
        AppLocalizations.of(context)!.paymentName,
        AppLocalizations.of(context)!.paymentId,
      ],
      items: controller.paymentMethods,
      selectedValue: controller.selectedPaidWith,
      searchValue: (p) => '${p.paymentMethodName} ${p.paymentMethodId}',
      displayText: (p) => p.paymentMethodName,

      onChanged: (p) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              controller.selectedPaidWith = p;
              controller.paymentMethodID = p!.paymentMethodId;
              controller.paidWithController.text = p.paymentMethodId;
            });
            loadAndAppendCashAdvanceList();
          }
        });
      },
      controller: controller.paidWithController,
      rowBuilder: (p, searchQuery) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(p.paymentMethodName)),
              Expanded(child: Text(p.paymentMethodId)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            enabled: false,
            controller: controller.paidAmount,
            onChanged: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
                final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
                final result = paid * rate;
                controller.amountINR.text = result.toStringAsFixed(2);
              });
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              labelText: 'Paid Amount*',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
            ),
            onEditingComplete: () {
              String text = controller.paidAmount.text;
              double? value = double.tryParse(text);
              if (value != null) {
                controller.paidAmount.text = value.toStringAsFixed(2);
              }
            },
          ),
        ),
        Expanded(
          child: Obx(
            () => SearchableMultiColumnDropdownField<Currency>(
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
              selectedValue: controller.selectedCurrency.value,
              backgroundColor: const Color.fromARGB(255, 22, 2, 92),
              searchValue: (c) => '${c.code} ${c.name} ${c.symbol}',
              displayText: (c) => c.code,
              inputDecoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_drop_down_outlined),
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
              validator: (value) => _validateRequiredField(
                controller.currencyDropDowncontroller.text,
                AppLocalizations.of(context)!.currency,
                true,
              ),
              onChanged: (c) async {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.selectedCurrency.value = c;
                });
                await controller.fetchExchangeRate();
                _updateAllLineItems();
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
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            enabled: controller.isEnable.value,
            controller: controller.unitRate,
            decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context)!.rate} *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => _validateNumericField(
              value ?? '',
              AppLocalizations.of(context)!.rate,
              true,
            ),
            onChanged: (val) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
                final rate = double.tryParse(val) ?? 1.0;
                final result = paid * rate;
                controller.amountINR.text = result.toStringAsFixed(2);
                controller.isVisible.value = true;

                for (int i = 0; i < itemizeControllers.length; i++) {
                  final itemController = itemizeControllers[i];
                  final unitPrice =
                      double.tryParse(itemController.unitPriceTrans.text) ??
                      0.0;
                  final lineAmountInINR = unitPrice * rate;
                  itemController.lineAmountINR.text = lineAmountInINR
                      .toStringAsFixed(2);
                  widget.items!.expenseTrans[i] = itemController
                      .toExpenseItemUpdateModel();
                }
                calculateAmounts(controller.unitRate.text.toString());

                if (mounted) {
                  setState(() {});
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountINRField() {
    return TextFormField(
      controller: controller.amountINR,
      enabled: false,
      decoration: InputDecoration(
        labelText:
            '${AppLocalizations.of(context)!.totalAmountIN} ${controller.organizationCurrency}',
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildItemizedExpensesSection() {
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
          itemCount: widget.items!.expenseTrans.length,
          itemBuilder: (context, index) {
            final item = widget.items!.expenseTrans[index];
            final itemController = itemizeControllers[index];

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(22),
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (controller.isEnable.value &&
                                widget.items!.expenseTrans.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItemize(index),
                                tooltip: 'Remove this item',
                              ),
                            if (controller.isEnable.value)
                              AnimatedOpacity(
                                opacity: _isTyping ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: FutureBuilder<Map<String, bool>>(
                                  future: _featureFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    }

                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    final featureStates = snapshot.data!;
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
                                      onPressed: _addItemize,
                                      tooltip: 'Add new item',
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return Column(
                            children: controller.customFields
                                .where(
                                  (field) =>
                                      field['ObjectName'] ==
                                                              'ExpenseTrans' ||
                                                          field['ObjectName'] ==
                                                              'ExpenseCategories',
                                )
                                .map((field) {
                                  final String label =
                                      field['FieldLabel'] ?? field['FieldName'];
                                  final bool isMandatory =
                                      field['IsMandatory'] ?? false;
                                  final String fieldType =
                                      field['FieldType'] ?? 'Text';

                                  Widget inputField;

                                  // List type fields - Make Reactive
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

                                    field['_controller'] ??=
                                        TextEditingController();
                                    final TextEditingController
                                    fieldController = field['_controller'];

                                    CustomDropdownValue? selectedValue =
                                        field['SelectedValue'];

                                    if (selectedValue == null &&
                                        field['DefaultValue'] != null) {
                                      final matches = options.where(
                                        (opt) =>
                                            opt.valueId ==
                                                field['DefaultValue'] ||
                                            opt.valueName ==
                                                field['DefaultValue'],
                                      );
                                      selectedValue = matches.isNotEmpty
                                          ? matches.first
                                          : null;

                                      if (selectedValue != null) {
                                        field['SelectedValue'] = selectedValue;
                                        field['EnteredValue'] =
                                            selectedValue.valueId;
                                      }
                                    }

                                    // ✅ Show selectedValue name OR fallback to raw DefaultValue string
                                    fieldController.text =
                                        selectedValue?.valueName ??
                                        field['DefaultValue']?.toString() ??
                                        '';

                                    // ✅ If no matched selectedValue but DefaultValue exists,
                                    // create a placeholder CustomDropdownValue so dropdown shows it
                                    if (selectedValue == null &&
                                        field['DefaultValue'] != null) {
                                      selectedValue = CustomDropdownValue(
                                        valueId: field['DefaultValue']
                                            .toString(),
                                        valueName: field['DefaultValue']
                                            .toString(),
                                      );
                                      // ✅ Add to options if not already present (so it renders in list too)
                                      final alreadyExists = options.any(
                                        (opt) =>
                                            opt.valueId ==
                                            selectedValue!.valueId,
                                      );
                                      if (!alreadyExists) {
                                        options = [selectedValue, ...options];
                                      }
                                      field['SelectedValue'] = selectedValue;
                                      field['EnteredValue'] =
                                          selectedValue.valueId;
                                    }

                                    inputField =
                                        SearchableMultiColumnDropdownField<
                                          CustomDropdownValue
                                        >(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          items: options,
                                          selectedValue: selectedValue,
                                          searchValue: (val) => val.valueName,
                                          enabled: controller.isEnable.value,
                                          displayText: (val) => val.valueName,
                                          controller: fieldController,
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
                                            field['EnteredValue'] =
                                                val?.valueId;
                                            field['Error'] = null;
                                            fieldController.text =
                                                val?.valueName ?? '';
                                            controller.customFields.refresh();
                                          },
                                        );
                                  }
                                  // Date and DateTime types - Make Reactive
                                  else if (fieldType == 'Date' ||
                                      fieldType == 'Date&Time') {
                                    final bool isDateTime =
                                        fieldType == 'Date&Time';

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

                                      // Create controller with current value
                                      final textEditingController =
                                          TextEditingController();
                                      if (currentDate != null) {
                                        if (isDateTime) {
                                          textEditingController.text =
                                              DateFormat(
                                                'dd/MM/yyyy hh:mm a',
                                              ).format(currentDate);
                                        } else {
                                          textEditingController.text =
                                              DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(currentDate);
                                        }
                                      }

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        readOnly: true,
                                        controller: textEditingController,
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
                                                  textEditingController.text =
                                                      DateFormat(
                                                        'dd/MM/yyyy hh:mm a',
                                                      ).format(fullDateTime);
                                                } else {
                                                  rxDateValue.value =
                                                      pickedDate;
                                                  field['EnteredValue'] =
                                                      pickedDate;
                                                  textEditingController.text =
                                                      DateFormat(
                                                        'dd/MM/yyyy',
                                                      ).format(pickedDate);
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
                                      final textEditingController =
                                          TextEditingController(
                                            text:
                                                rxValue.value?.toString() ?? '',
                                          );

                                      textEditingController.addListener(() {
                                        final value =
                                            textEditingController.text;
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
                                      });

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        controller: textEditingController,
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                        ),
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
                                      final textEditingController =
                                          TextEditingController(
                                            text:
                                                rxValue.value?.toString() ?? '',
                                          );

                                      textEditingController.addListener(() {
                                        final value =
                                            textEditingController.text;
                                        if (value.isEmpty) {
                                          if (rxValue.value != null) {
                                            rxValue.value = null;
                                            field['EnteredValue'] = null;
                                          }
                                        } else {
                                          final doubleValue = double.tryParse(
                                            value,
                                          );
                                          if (doubleValue != rxValue.value) {
                                            rxValue.value = doubleValue;
                                            field['EnteredValue'] = doubleValue;
                                          }
                                        }
                                        field['Error'] = null;
                                      });

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
                                        controller: textEditingController,
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                        ),
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
                                      final textEditingController =
                                          TextEditingController(
                                            text: rxValue.value ?? '',
                                          );

                                      textEditingController.addListener(() {
                                        final value =
                                            textEditingController.text;
                                        if (value != rxValue.value) {
                                          rxValue.value = value;
                                          field['EnteredValue'] = value;
                                        }
                                        field['Error'] = null;
                                      });

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: textEditingController,
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                          suffixIcon: const Icon(
                                            Icons.email_outlined,
                                          ),
                                        ),
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
                                  // MobileNumber type - Make Reactive
                                  // MobileNumber type - Make Reactive
                                  else if (fieldType == 'MobileNumber') {
                                    String getIsoCodeFromDialCode(
                                      String dialCode,
                                    ) {
                                      final Map<String, String> dialCodeToIso =
                                          {
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

                                    // Create unique key for this field
                                    final String mobileFieldKey =
                                        '${field['FieldId']}_${field['FieldName']}';

                                    // Initialize persistent controllers and values if not exists
                                    if (field['_phoneController'] == null) {
                                      final defaultValue =
                                          field['DefaultValue']?.toString() ??
                                          '';
                                      final existingValue =
                                          field['EnteredValue'] as String?;
                                      final initialValue =
                                          existingValue ?? defaultValue;

                                      // Parse existing phone number to extract country code and number
                                      String countryCode =
                                          '+91'; // Default India
                                      String phoneNumber = '';

                                      if (initialValue.isNotEmpty) {
                                        // Clean the phone number - remove extra plus signs
                                        String cleanedValue = initialValue
                                            .trim();

                                        // Handle cases like "++93 85555 000" (double plus)
                                        while (cleanedValue.startsWith('++')) {
                                          cleanedValue =
                                              '+' + cleanedValue.substring(2);
                                        }

                                        // Parse the phone number
                                        if (cleanedValue.startsWith('+')) {
                                          // Extract country code (everything after + until first space or digit)
                                          final RegExp regex = RegExp(
                                            r'^\+(\d+)\s*(.*)$',
                                          );
                                          final match = regex.firstMatch(
                                            cleanedValue,
                                          );
                                          if (match != null) {
                                            countryCode = '+${match.group(1)}';
                                            phoneNumber =
                                                match.group(2)?.trim() ?? '';
                                          } else {
                                            // If regex doesn't match, try to extract first digits after +
                                            final String afterPlus =
                                                cleanedValue.substring(1);
                                            final RegExp digitsOnly = RegExp(
                                              r'^\d+',
                                            );
                                            final matchDigits = digitsOnly
                                                .firstMatch(afterPlus);
                                            if (matchDigits != null) {
                                              countryCode =
                                                  '+${matchDigits.group(0)}';
                                              phoneNumber = afterPlus
                                                  .substring(
                                                    matchDigits
                                                        .group(0)!
                                                        .length,
                                                  )
                                                  .trim();
                                            } else {
                                              phoneNumber = cleanedValue;
                                            }
                                          }
                                        } else {
                                          phoneNumber = cleanedValue;
                                        }

                                        print(
                                          "Parsed phone - Country Code: $countryCode, Number: $phoneNumber",
                                        );
                                      }

                                      // Create controllers
                                      field['_countryCodeController'] =
                                          TextEditingController(
                                            text: countryCode,
                                          );
                                      field['_phoneController'] =
                                          TextEditingController(
                                            text: phoneNumber,
                                          );
                                      field['_rxStringValue'] = Rx<String?>(
                                        initialValue,
                                      );
                                      field['_focusNode'] = FocusNode();
                                      field['_selectedCountryCode'] =
                                          getIsoCodeFromDialCode(countryCode);
                                      field['EnteredValue'] = initialValue;

                                      // Update EnteredValue when phone number changes
                                      field['_phoneController'].addListener(() {
                                        final phoneVal =
                                            field['_phoneController'].text;
                                        final codeVal =
                                            field['_countryCodeController']
                                                .text;
                                        String fullNumber = '';

                                        if (phoneVal.isNotEmpty) {
                                          fullNumber = '$codeVal $phoneVal';
                                        } else if (codeVal.isNotEmpty) {
                                          fullNumber = codeVal;
                                        }

                                        if (fullNumber !=
                                            field['_rxStringValue'].value) {
                                          field['_rxStringValue'].value =
                                              fullNumber;
                                          field['EnteredValue'] = fullNumber;
                                        }
                                        field['Error'] = null;
                                      });

                                      // Update EnteredValue when country code changes
                                      field['_countryCodeController']
                                          .addListener(() {
                                            final phoneVal =
                                                field['_phoneController'].text;
                                            final codeVal =
                                                field['_countryCodeController']
                                                    .text;
                                            String fullNumber = '';

                                            if (phoneVal.isNotEmpty) {
                                              fullNumber = '$codeVal $phoneVal';
                                            } else if (codeVal.isNotEmpty) {
                                              fullNumber = codeVal;
                                            }

                                            if (fullNumber !=
                                                field['_rxStringValue'].value) {
                                              field['_rxStringValue'].value =
                                                  fullNumber;
                                              field['EnteredValue'] =
                                                  fullNumber;
                                            }
                                            field['Error'] = null;
                                          });
                                    }

                                    // Helper function to convert dial code to ISO code

                                    // Create a reactive variable for the current country code
                                    if (field['_currentCountryCode'] == null) {
                                      field['_currentCountryCode'] = Rx<String>(
                                        field['_selectedCountryCode'] ?? 'IN',
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
                                          field['_focusNode'] as FocusNode;
                                      final currentCountryCode =
                                          field['_currentCountryCode']
                                              as Rx<String>;

                                      // Get the current country code and clean it if necessary
                                      String currentDialCode =
                                          countryCodeController.text;

                                      // Handle case where country code might have extra spaces or characters
                                      if (currentDialCode.isNotEmpty &&
                                          !currentDialCode.startsWith('+')) {
                                        currentDialCode = '+$currentDialCode';
                                      }

                                      // Clean up the country code (remove any extra spaces)
                                      currentDialCode = currentDialCode.trim();

                                      // Extract just the digits for ISO lookup
                                      String cleanDialCode = currentDialCode;
                                      final dialCodeMatch = RegExp(
                                        r'^\+(\d+)',
                                      ).firstMatch(currentDialCode);
                                      if (dialCodeMatch != null) {
                                        cleanDialCode =
                                            '+${dialCodeMatch.group(1)}';
                                      }

                                      // Get the ISO code for the current dial code
                                      final isoCode = getIsoCodeFromDialCode(
                                        cleanDialCode,
                                      );

                                      // Update the stored country code if changed
                                      if (currentCountryCode.value != isoCode) {
                                        currentCountryCode.value = isoCode;
                                      }

                                      return SizedBox(
                                        child: IntlPhoneField(
                                          key: ValueKey(
                                            '${mobileFieldKey}_${currentCountryCode.value}',
                                          ),
                                          controller: phoneController,
                                          focusNode: focusNode,
                                          keyboardType: TextInputType.phone,
                                          enabled: controller.isEnable.value,
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
                                                  BorderRadius.circular(10),
                                            ),
                                            errorText: field['Error'],
                                            counterText: "",
                                          ),
                                          initialCountryCode:
                                              currentCountryCode.value,
                                          onChanged: (phone) {
                                            // Update controllers when phone number changes
                                            countryCodeController.text =
                                                '+${phone.countryCode}';
                                            phoneController.text = phone.number;

                                            // Update the stored country code
                                            final newIsoCode =
                                                getIsoCodeFromDialCode(
                                                  '+${phone.countryCode}',
                                                );
                                            if (currentCountryCode.value !=
                                                newIsoCode) {
                                              currentCountryCode.value =
                                                  newIsoCode;
                                            }

                                            // Update the full number
                                            final fullNumber =
                                                phone.number.isNotEmpty
                                                ? '+${phone.countryCode} ${phone.number}'
                                                : '+${phone.countryCode}';

                                            if (fullNumber !=
                                                field['_rxStringValue'].value) {
                                              field['_rxStringValue'].value =
                                                  fullNumber;
                                              field['EnteredValue'] =
                                                  fullNumber;
                                            }

                                            // Clear any validation errors when user starts typing
                                            field['Error'] = null;
                                          },
                                          onCountryChanged: (country) {
                                            // Update controllers when country changes
                                            countryCodeController.text =
                                                '+${country.dialCode}';

                                            // Update the stored country code
                                            final newIsoCode =
                                                getIsoCodeFromDialCode(
                                                  '+${country.dialCode}',
                                                );
                                            if (currentCountryCode.value !=
                                                newIsoCode) {
                                              currentCountryCode.value =
                                                  newIsoCode;
                                            }

                                            // Update the full number when country changes
                                            final currentNumber =
                                                phoneController.text;
                                            final fullNumber =
                                                currentNumber.isNotEmpty
                                                ? '+${country.dialCode} $currentNumber'
                                                : '+${country.dialCode}';

                                            if (fullNumber !=
                                                field['_rxStringValue'].value) {
                                              field['_rxStringValue'].value =
                                                  fullNumber;
                                              field['EnteredValue'] =
                                                  fullNumber;
                                            }

                                            // Clear validation errors when country changes
                                            field['Error'] = null;
                                          },
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9\s\-]+'),
                                            ),
                                          ],
                                          validator: (phone) {
                                            // Only validate if the field is mandatory
                                            if (isMandatory) {
                                              // Skip validation if the phone number is empty
                                              if (phone == null ||
                                                  phone.number.trim().isEmpty) {
                                                return '$label is required';
                                              }

                                              // Only validate the number part (not the country code)
                                              final cleanNumber = phone.number
                                                  .replaceAll(
                                                    RegExp(r'[\s\-]'),
                                                    '',
                                                  );

                                              // Basic length validation (6-15 digits)
                                              if (cleanNumber.length < 6 ||
                                                  cleanNumber.length > 15) {
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
                                    if (field['_rxStringValue'] == null) {
                                      field['_rxStringValue'] = Rx<String?>(
                                        field['EnteredValue'] as String?,
                                      );
                                    }

                                    inputField = Obx(() {
                                      final rxValue =
                                          field['_rxStringValue']
                                              as Rx<String?>;
                                      final textEditingController =
                                          TextEditingController(
                                            text: rxValue.value ?? '',
                                          );

                                      textEditingController.addListener(() {
                                        final value =
                                            textEditingController.text;
                                        if (value != rxValue.value) {
                                          rxValue.value = value;
                                          field['EnteredValue'] = value;
                                        }
                                        field['Error'] = null;
                                      });

                                      return TextFormField(
                                        enabled: controller.isEnable.value,
                                        keyboardType: TextInputType.text,
                                        controller: textEditingController,
                                        decoration: InputDecoration(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          border: const OutlineInputBorder(),
                                          errorText: field['Error'],
                                        ),
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
                                      vertical: 6,
                                    ),
                                    child: inputField,
                                  );
                                })
                                .toList(),
                          );
                        }),
                        ...controller.configList
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
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              Widget inputField;

                              if (label == 'Project Id') {
                                inputField = SearchableMultiColumnDropdownField<Project>(
                                  enabled: controller.isEnable.value,
                                  labelText:
                                      "${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}",
                                  columnHeaders: const [
                                    'Project Name',
                                    'Project ID',
                                  ],
                                  items: controller.project,
                                  selectedValue: itemController.selectedProject,
                                  searchValue: (p) => '${p.name} ${p.code}',
                                  displayText: (p) => p.code,
                                  validator: (value) =>
                                      projectConfig.isEnabled &&
                                          projectConfig.isMandatory
                                      ? _validateRequiredField(
                                          itemController
                                              .projectDropDowncontroller
                                              .text,
                                          AppLocalizations.of(
                                            context,
                                          )!.projectId,
                                          true,
                                        )
                                      : null,
                                  onChanged: (p) {
                                    WidgetsBinding.instance.addPostFrameCallback((
                                      _,
                                    ) {
                                      if (mounted) {
                                        setState(() {
                                          controller.selectedProject = p;
                                          itemController.selectedProject = p;
                                          controller
                                                  .projectDropDowncontroller
                                                  .text =
                                              p!.code;
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                        });
                                        controller
                                            .fetchCashAdvanceExpenseCategory();
                                      }
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
                                );
                              } else if (label == 'Tax Group') {
                                inputField =
                                    SearchableMultiColumnDropdownField<
                                      TaxGroupModel
                                    >(
                                      enabled: controller.isEnable.value,
                                      labelText:
                                          "${AppLocalizations.of(context)!.taxGroup}${isMandatory ? "*" : ""}",
                                      columnHeaders: [
                                        AppLocalizations.of(context)!.taxGroup,
                                        AppLocalizations.of(context)!.taxId,
                                      ],
                                      items: controller.taxGroup,
                                      selectedValue: itemController.selectedTax,
                                      searchValue: (tax) =>
                                          '${tax.taxGroup} ${tax.taxGroupId}',
                                      displayText: (tax) => tax.taxGroupId,
                                      validator: (value) =>
                                          taxGroupConfig.isEnabled &&
                                              taxGroupConfig.isMandatory
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
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                setState(() {
                                                  itemController.selectedTax =
                                                      tax;
                                                  widget
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                  itemController
                                                          .taxGroupController
                                                          .text =
                                                      tax!.taxGroupId;
                                                });
                                              }
                                            });
                                      },
                                      controller:
                                          itemController.taxGroupController,
                                      rowBuilder: (tax, searchQuery) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(tax.taxGroup),
                                              ),
                                              Expanded(
                                                child: Text(tax.taxGroupId),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                              } else if (label == 'Tax Amount') {
                                inputField = _buildTextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  label:
                                      "${AppLocalizations.of(context)!.taxAmount}${isMandatory ? "*" : ""}",
                                  controller: itemController.taxAmount,
                                  isReadOnly: controller.isEnable.value,
                                  validator: (value) =>
                                      taxAmountConfig.isEnabled &&
                                          taxAmountConfig.isMandatory
                                      ? _validateNumericField(
                                          value!,
                                          AppLocalizations.of(
                                            context,
                                          )!.taxAmount,
                                          true,
                                        )
                                      : null,
                                  onChanged: (value) {
                                    WidgetsBinding.instance.addPostFrameCallback(
                                      (_) {
                                        if (mounted) {
                                          setState(() {
                                            widget.items?.expenseTrans[index] =
                                                itemController
                                                    .toExpenseItemUpdateModel();
                                          });
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                inputField = TextField(
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
                                  const SizedBox(height: 8),
                                  inputField,
                                  const SizedBox(height: 16),
                                ],
                              );
                            })
                            .toList(),
                        const SizedBox(height: 12),
                        _buildCategoryDropdown(itemController, index),
                        const SizedBox(height: 12),
                        _buildDescriptionField(itemController, index),
                        const SizedBox(height: 12),
                        _buildUnitDropdown(itemController, index),
                        const SizedBox(height: 12),
                        _buildQuantityField(itemController, index),
                        const SizedBox(height: 12),
                        _buildUnitAmountField(itemController, index),
                        const SizedBox(height: 12),
                        _buildLineAmountField(itemController, index),
                        const SizedBox(height: 12),
                        _buildLineAmountINRField(itemController, index),
                        const SizedBox(height: 12),
                        if (controller.isEnable.value)
                          _buildAccountDistributionButton(
                            itemController,
                            index,
                          ),
                        const SizedBox(height: 12),
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

  Widget _buildCategoryDropdown(Controller itemController, int index) {
    return SearchableMultiColumnDropdownField<ExpenseCategory>(
      labelText: "${AppLocalizations.of(context)!.paidFor} *",
      enabled: controller.isEnable.value,
      columnHeaders: [
        AppLocalizations.of(context)!.categoryName,
        AppLocalizations.of(context)!.categoryName,
      ],
      items: controller.expenseCategory,
      selectedValue: itemController.selectedCategory,
      searchValue: (p) => '${p.categoryName} ${p.categoryId}',
      displayText: (p) => p.categoryId,
      validator: (value) => _validateRequiredField(
        itemController.categoryController.text,
        AppLocalizations.of(context)!.paidFor,
        true,
      ),
      onChanged: (p) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              itemController.selectedCategory = p;
              itemController.selectedCategoryId = p!.categoryId;
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
              itemController.categoryController.text = p.categoryId;
            });
          }
        });
      },
      controller: itemController.categoryController,
      rowBuilder: (p, searchQuery) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(p.categoryName)),
              Expanded(child: Text(p.categoryId)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField(Controller itemController, int index) {
    return _buildTextField(
      label: AppLocalizations.of(context)!.comments,
      controller: itemController.descriptionController,
      isReadOnly: controller.isEnable.value,
      onChanged: (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
            });
          }
        });
      },
    );
  }

  Widget _buildUnitDropdown(Controller itemController, int index) {
    return SearchableMultiColumnDropdownField<Unit>(
      labelText: '${AppLocalizations.of(context)!.unit} *',
      enabled: controller.isEnable.value,
      columnHeaders: [
        AppLocalizations.of(context)!.uomId,
        AppLocalizations.of(context)!.uomName,
      ],
      items: controller.unit,
      selectedValue: itemController.selectedunit,
      searchValue: (tax) => '${tax.code} ${tax.name}',
      displayText: (tax) => tax.name,
      validator: (value) => _validateRequiredField(
        itemController.uomId.text,
        AppLocalizations.of(context)!.unit,
        true,
      ),
      onChanged: (tax) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              itemController.selectedunit = tax;
              itemController.uomId.text = tax!.code;
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
            });
          }
        });
      },
      controller: itemController.uomId,
      rowBuilder: (tax, searchQuery) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(tax.code)),
              Expanded(child: Text(tax.name)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityField(Controller itemController, int index) {
    return _buildTextField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      label: "${AppLocalizations.of(context)!.quantity} *",
      controller: itemController.quantity,
      isReadOnly: controller.isEnable.value,
      validator: (value) => _validateNumericField(
        value!,
        AppLocalizations.of(context)!.quantity,
        true,
      ),
      onChanged: (value) async {
        await Future.delayed(Duration.zero);
        await controller.fetchExchangeRate();
        // await calculateAmounts(controller.unitRate.text.toString());

        _updateAllLineItems();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              final total = _calculateTotalLineAmount(itemController);
              controller.paidAmount.text = total.toStringAsFixed(2);
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
            });
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              final total = _calculateTotalLineAmount(itemController);
              controller.paidAmount.text = total.toStringAsFixed(2);
            });
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
              calculateAmounts(controller.unitRate.text.toString());
            });
          }
        });

        await calculateAmounts(controller.unitRate.text.toString());
      },
    );
  }

  Widget _buildUnitAmountField(Controller itemController, int index) {
    return _buildTextField(
      keyboardType: TextInputType.number,
      label: "${AppLocalizations.of(context)!.unitAmount} *",
      controller: itemController.unitPriceTrans,
      isReadOnly: controller.isEnable.value,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) => _validateNumericField(
        value!,
        AppLocalizations.of(context)!.unitAmount,
        true,
      ),
      onChanged: (value) async {
        await Future.delayed(Duration.zero);

        await controller.fetchExchangeRate();

        _updateAllLineItems();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              final total = _calculateTotalLineAmount(itemController);
              controller.paidAmount.text = total.toStringAsFixed(2);
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
            });
          }
        });

        // await calculateAmounts(controller.unitRate.text.toString());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              final total = _calculateTotalLineAmount(itemController);
              controller.paidAmount.text = total.toStringAsFixed(2);
            });
          }
        });
      },
    );
  }

  Widget _buildLineAmountField(Controller itemController, int index) {
    return _buildTextField(
      keyboardType: TextInputType.number,
      label: AppLocalizations.of(context)!.lineAmount,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      controller: itemController.lineAmount,
      isReadOnly: false,
      validator: (value) => _validateNumericField(
        value!,
        AppLocalizations.of(context)!.lineAmount,
        true,
      ),
      onChanged: (value) async {
        await Future.delayed(Duration.zero);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
            });
          }
        });
      },
    );
  }

  Widget _buildLineAmountINRField(Controller itemController, int index) {
    return _buildTextField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      label:
          '${AppLocalizations.of(context)!.lineAmountInInr} ${controller.organizationCurrency}',
      controller: itemController.lineAmountINR,
      isReadOnly: false,
      validator: (value) => _validateNumericField(
        value!,
        AppLocalizations.of(context)!.lineAmountInInr,
        true,
      ),
      onChanged: (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              widget.items!.expenseTrans[index] = itemController
                  .toExpenseItemUpdateModel();
            });
          }
        });
      },
    );
  }

  Widget _buildAccountDistributionButton(Controller itemController, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            final double lineAmount =
                double.tryParse(itemController.lineAmount.text) ?? 0.0;
            if (itemController.split.isEmpty &&
                itemController.accountingDistributions.isNotEmpty) {
              itemController.split.assignAll(
                itemController.accountingDistributions.map((e) {
                  return AccountingSplit(
                    paidFor: e?.dimensionValueId,
                    percentage: e!.allocationFactor,
                    amount: e?.transAmount,
                  );
                }).toList(),
              );
            } else if (itemController.split.isEmpty) {
              itemController.split.add(AccountingSplit(percentage: 100.0));
            }

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    splits: itemController.split,
                    lineAmount: lineAmount,
                    onChanged: (i, updatedSplit) {
                      if (!mounted) return;
                      itemController.split[i] = updatedSplit;
                    },
                    onDistributionChanged: (newList) {
                      if (!mounted) return;
                      itemController.accountingDistributions.clear();
                      itemController.accountingDistributions.addAll(newList);
                    },
                  ),
                ),
              ),
            );
          },
          child: Text(
            AppLocalizations.of(context)!.accountDistribution,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingHistorySection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.trackingHistory,
      children: [
        const SizedBox(height: 12),
        FutureBuilder<List<ExpenseHistory>>(
          future: historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("No Data Available Please Skip Next"));
            }

            final historyList = snapshot.data!;
            if (historyList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'The expense does not have a history. Please consider submitting it for approval.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
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
                return _buildTimelineItem(
                  item,
                  index == historyList.length - 1,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtonsSection() {
    if (widget.items!.workitemrecid == null) {
      return _buildNonWorkflowButtons();
    } else {
      return _buildWorkflowButtons();
    }
  }

  Widget _buildNonWorkflowButtons() {
    if (controller.isEnable.value &&
        widget.items!.approvalStatus == "Rejected") {
      return Column(
        children: [
          _buildResubmitButton(),
          const SizedBox(height: 20),
          _buildUpdateCancelButtons(),
        ],
      );
    } else if (controller.isEnable.value &&
        widget.items!.approvalStatus == "Created") {
      return Column(
        children: [
          _buildSubmitButton(),
          const SizedBox(height: 12),
          _buildSaveCancelButtons(),
        ],
      );
    } else if (widget.items!.approvalStatus == "Pending" &&
        widget.items!.workitemrecid == null &&
        widget.isReadOnly) {
      return _buildCloseButton();
    } else {
      return _buildCancelButton();
    }
  }

  Widget _buildWorkflowButtons() {
    if (controller.isEnable.value && widget.items!.stepType == "Review") {
      return Column(
        children: [
          _buildReviewButtons(),
          const SizedBox(height: 12),
          _buildRejectCloseButtons(),
        ],
      );
    } else if (controller.isApprovalEnable.value &&
        widget.items!.stepType == "Approval") {
      return Column(
        children: [
          _buildApprovalButtons(),
          const SizedBox(height: 12),
          _buildEscalateCloseButtons(),
        ],
      );
    } else {
      return _buildCloseButtonExpense();
    }
  }

  Widget _buildResubmitButton() {
    return Obx(() {
      final isResubmitLoading = controller.buttonLoaders['resubmit'] ?? false;
      final isAnyLoading = controller.buttonLoaders.values.any(
        (loading) => loading,
      );

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color.fromARGB(255, 29, 1, 128),
          ),
          onPressed: (isResubmitLoading || isAnyLoading)
              ? null
              : () {
                  if (_formKey.currentState!.validate() && _validateForm()) {
                    controller.setButtonLoading('resubmit', true);
                    widget.items!.expenseTrans.map((existingTrans) {
                      print("existingTrans${existingTrans.recId}");
                      return controller.toExpenseItemUpdateModels(
                        existingTrans.recId,
                      );
                    }).toList();
                    controller.lineItemControllers
                      ..clear()
                      ..addAll(itemizeControllers);
                    controller.addToFinalItems(widget.items!);
                    controller
                        .editAndUpdateCashAdvance(
                          context,
                          true,
                          true,
                          widget.items!.recId!,
                          widget.items!.expenseId,
                        )
                        .whenComplete(() {
                          controller.setButtonLoading('resubmit', false);
                        });
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
    });
  }

  Widget _buildUpdateCancelButtons() {
    return Row(
      children: [
        Obx(() {
          final isUpdateLoading = controller.buttonLoaders['update'] ?? false;
          final isAnyLoading = controller.buttonLoaders.values.any(
            (loading) => loading,
          );

          return Expanded(
            child: ElevatedButton(
              onPressed: (isUpdateLoading || isAnyLoading)
                  ? null
                  : () {
                      if (_formKey.currentState!.validate() &&
                          _validateForm()) {
                        controller.setButtonLoading('update', true);
                        controller.lineItemControllers
                          ..clear()
                          ..addAll(itemizeControllers);
                        controller
                            .saveinEditCashAdvance(
                              context,
                              false,
                              false,
                              widget.items!.recId,
                              widget.items!.expenseId,
                            )
                            .whenComplete(() {
                              controller.setButtonLoading('update', false);
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
                      AppLocalizations.of(context)!.update,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          );
        }),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.chancelButton(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isSubmitLoading = controller.buttonLoaders['submit'] ?? false;
      final isAnyLoading = controller.buttonLoaders.values.any(
        (loading) => loading,
      );

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color.fromARGB(255, 26, 2, 110),
          ),
          onPressed: (isSubmitLoading || isAnyLoading)
              ? null
              : () async {
                  if (_formKey.currentState!.validate() && _validateForm()) {
                    controller.setButtonLoading('submit', true);
                    controller.lineItemControllers
                      ..clear()
                      ..addAll(itemizeControllers);
                    widget.items!.expenseTrans.map((existingTrans) {
                      print("existingTrans${existingTrans.recId}");
                      return controller.toExpenseItemUpdateModels(
                        existingTrans.recId,
                      );
                    }).toList();
                    controller.lineItemControllers
                      ..clear()
                      ..addAll(itemizeControllers);
                    controller.addToFinalItems(widget.items!);
                    controller
                        .editAndUpdateCashAdvance(
                          context,
                          true,
                          false,
                          widget.items!.recId!,
                          widget.items!.expenseId,
                        )
                        .whenComplete(() {
                          controller.setButtonLoading('submit', false);
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
    });
  }

  Widget _buildSaveCancelButtons() {
    return Row(
      children: [
        Obx(() {
          final isSaveLoading = controller.buttonLoaders['saveGE'] ?? false;
          final isSubmitLoading = controller.buttonLoaders['submit'] ?? false;
          final isAnyLoading = controller.buttonLoaders.values.any(
            (loading) => loading,
          );

          return Expanded(
            child: ElevatedButton(
              onPressed: (isSaveLoading || isSubmitLoading || isAnyLoading)
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate() &&
                          _validateForm()) {
                        controller.setButtonLoading('saveGE', true);
                        controller.lineItemControllers
                          ..clear()
                          ..addAll(itemizeControllers);
                        controller.addToFinalItems(widget.items!);
                        controller
                            .editAndUpdateCashAdvance(
                              context,
                              false,
                              false,
                              widget.items!.recId!,
                              widget.items!.expenseId,
                            )
                            .whenComplete(() {
                              controller.setButtonLoading('saveGE', false);
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
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          );
        }),
        const SizedBox(width: 12),
        Obx(() {
          final isAnyLoading = controller.buttonLoaders.values.any(
            (loading) => loading,
          );
          return Expanded(
            child: ElevatedButton(
              onPressed: isAnyLoading
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.cashAdvanceRequestDashboard,
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() {
          final isLoading = controller.buttonLoaders['cancel'] ?? false;
          return Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      controller.setButtonLoading('cancel', true);
                      controller
                          .cancelExpense(
                            context,
                            widget.items!.recId.toString(),
                          )
                          .whenComplete(() {
                            controller.setButtonLoading('cancel', false);
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
                  : const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          );
        }),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              controller.chancelButton(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButtonExpense() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              controller.chancelButton(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () => controller.chancelButton(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
      child: Text(AppLocalizations.of(context)!.close),
    );
  }

  Widget _buildReviewButtons() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final isLoadingAccept =
                controller.buttonLoaders['update_accept'] ?? false;

            final isAnyLoading = controller.buttonLoaders.values.any(
              (v) => v == true,
            );

            return ElevatedButton(
              onPressed: (isLoadingAccept || isAnyLoading)
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate() &&
                          _validateForm()) {
                        controller.setButtonLoading('update_accept', true);
                        controller.lineItemControllers
                          ..clear()
                          ..addAll(itemizeControllers);
                        controller.toExpenseItemUpdateModel();
                        controller.addToFinalItems(widget.items!);

                        try {
                          await controller.cashadvanceregistrations(
                            context,
                            true,
                            widget.items!.recId!,
                            widget.items!.expenseId,
                            workitemrecid,
                          );
                        } finally {
                          controller.setButtonLoading('update_accept', false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 3, 20, 117),
              ),
              child: SizedBox(
                height: 20,
                child: isLoadingAccept
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Center(
                        child: Text(
                          AppLocalizations.of(context)!.updateAndAccept,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
            );
          }),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Obx(() {
            final isLoadingUpdate =
                controller.buttonLoaders['update_review'] ?? false;

            final isAnyLoading = controller.buttonLoaders.values.any(
              (v) => v == true,
            );

            return ElevatedButton(
              onPressed: (isLoadingUpdate || isAnyLoading)
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate() &&
                          _validateForm()) {
                        controller.setButtonLoading('update_review', true);
                        controller.lineItemControllers
                          ..clear()
                          ..addAll(itemizeControllers);
                        controller.toExpenseItemUpdateModel();
                        controller.addToFinalItems(widget.items!);

                        try {
                          await controller.cashadvanceregistrations(
                            context,
                            false,
                            widget.items!.recId!,
                            widget.items!.expenseId,
                            workitemrecid,
                          );
                        } finally {
                          controller.setButtonLoading('update_review', false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 3, 20, 117),
              ),
              child: SizedBox(
                height: 20,
                child: isLoadingUpdate
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Center(
                        child: Text(
                          AppLocalizations.of(context)!.update,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRejectCloseButtons() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final isLoadingReject =
                controller.buttonLoaders['reject_review'] ?? false;
            final isAnyLoading = controller.buttonLoaders.values.any(
              (loading) => loading == true,
            );

            return ElevatedButton(
              onPressed: (isLoadingReject || isAnyLoading)
                  ? null
                  : () async {
                      controller.setButtonLoading('reject_review', true);
                      try {
                        showActionPopup(context, "Reject");
                      } finally {
                        controller.setButtonLoading('reject_review', false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 238, 20, 20),
              ),
              child: isLoadingReject
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Text(
                      AppLocalizations.of(context)!.reject,
                      style: const TextStyle(color: Colors.white),
                    ),
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final isLoadingClose =
                controller.buttonLoaders['close_review'] ?? false;
            final isAnyLoading = controller.buttonLoaders.values.any(
              (loading) => loading == true,
            );

            return ElevatedButton(
              onPressed: (isLoadingClose || isAnyLoading)
                  ? null
                  : () async {
                      controller.setButtonLoading('close_review', true);
                      try {
                        controller.chancelButton(context);
                      } finally {
                        controller.setButtonLoading('close_review', false);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: isLoadingClose
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Text(AppLocalizations.of(context)!.close),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildApprovalButtons() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final isLoading = controller.buttonLoaders['approve'] ?? false;
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      controller.setButtonLoading('approve', true);
                      try {
                        showActionPopup(context, "Approve");
                      } finally {
                        controller.setButtonLoading('approve', false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 117, 3),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Text(
                      AppLocalizations.of(context)!.approve,
                      style: const TextStyle(color: Colors.white),
                    ),
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final isLoading =
                controller.buttonLoaders['reject_approval'] ?? false;
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      controller.setButtonLoading('reject_approval', true);
                      try {
                        showActionPopup(context, "Reject");
                      } finally {
                        controller.setButtonLoading('reject_approval', false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 238, 20, 20),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Text(
                      AppLocalizations.of(context)!.reject,
                      style: const TextStyle(color: Colors.white),
                    ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEscalateCloseButtons() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final isLoading = controller.buttonLoaders['escalate'] ?? false;
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      controller.setButtonLoading('escalate', true);
                      try {
                        showActionPopup(context, "Escalate");
                      } finally {
                        controller.setButtonLoading('escalate', false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 3, 20, 117),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Text(
                      AppLocalizations.of(context)!.escalate,
                      style: const TextStyle(color: Colors.white),
                    ),
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final isLoading =
                controller.buttonLoaders['close_approval'] ?? false;
            return ElevatedButton(
              onPressed: (isLoading)
                  ? null
                  : () async {
                      controller.setButtonLoading('close_approval', true);
                      try {
                        controller.chancelButton(context);
                      } finally {
                        controller.setButtonLoading('close_approval', false);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Text(AppLocalizations.of(context)!.close),
            );
          }),
        ),
      ],
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${AppLocalizations.of(context)!.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${AppLocalizations.of(context)!.user} *',
                          columnHeaders: [
                            AppLocalizations.of(context)!.userName,
                            AppLocalizations.of(context)!.userId,
                          ],
                          items: controller.userList,
                          selectedValue: controller.selectedUser.value,
                          searchValue: (user) =>
                              '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.userIdController.text =
                                  user?.userId ?? '';
                              controller.selectedUser.value = user;
                            });
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(user.userName)),
                                  Expanded(child: Text(user.userId)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.teal,
                            width: 2,
                          ),
                        ),
                        errorText: isCommentError
                            ? AppLocalizations.of(context)!.commentRequired
                            : null,
                      ),
                      onChanged: (value) {
                        if (isCommentError && value.trim().isNotEmpty) {
                          setState(() => isCommentError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();
                            if (status != "Approve" && comment.isEmpty) {
                              setState(() => isCommentError = true);
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) =>
                                  const Center(child: SkeletonLoaderPage()),
                            );

                            final success = await controller.postApprovalAction(
                              context,
                              workitemrecid: [workitemrecid!],
                              decision: status,
                              comment: commentController.text,
                            );

                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.approvalDashboard,
                              );
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit action'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      return File(croppedFile.path);
    }
    return null;
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
                    controller.closeField();
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
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  controller.imageFiles[index] = croppedFile;
                                });
                                Navigator.pop(context);
                                _showFullImage(croppedFile, index);
                              }
                            });
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                controller.imageFiles.removeAt(index);
                              });
                            }
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
                      print("Invalid date format: ${controllers.text}");
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
                    controller.fetchCashAdvanceExpenseCategory();
                    controller.fetchProjectName();
                    controller.selectedDate = picked;
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.blue, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.eventType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.notes,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(item.createdDate)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
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
    return TextFormField(
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
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
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
        iconColor: Colors.deepPurple,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: children,
      ),
    );
  }
}
