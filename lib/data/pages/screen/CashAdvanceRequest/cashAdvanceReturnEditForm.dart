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
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../core/comman/widgets/pageLoaders.dart';
import '../../../../l10n/app_localizations.dart';

class ViewCashAdvanseReturnForm extends StatefulWidget {
  final CashAdvanceRequestHeader? items;
  final bool isReadOnly;

  const ViewCashAdvanseReturnForm({
    Key? key,
    this.items,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  State<ViewCashAdvanseReturnForm> createState() =>
      _ViewCashAdvanseReturnFormState();
}

class _ViewCashAdvanseReturnFormState extends State<ViewCashAdvanseReturnForm>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────
  // FIELDS
  // ─────────────────────────────────────────────────────────────
  final FocusNode percentageFocusNode = FocusNode();
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
  final Map<String, TextEditingController> fieldControllers = {};
  final Map<String, TextEditingController> itemizeFieldControllers = {};

  String? paidToError;
  bool isLoading = true;
  late Future<Map<String, bool>> _featureFuture;
  bool _showUnitAmountError = false;
  bool _showLocationError = false;
  int _currentIndex = 0;
  late PageController _pageController;

  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];

  late Controller controller;
  Future<List<ExpenseHistory>>? historyFuture;

  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _isEditingExisting = false;
  bool _showHistory = false;
  Timer? _debounce;
  int _itemizeCount = 1;
  bool allowDocAttachments = false;

  late final projectConfig;
  late final taxGroupConfig;
  late final taxAmountConfig;
  late final isReimbursibleConfig;
  late final isRefrenceIDConfig;
  late final isBillableConfig;
  late final isLocationConfig;

  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
  late int workitemrecid;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<int, GlobalKey<FormState>> _itemizeFormKeys = {};

  // ─────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    controller = Get.put(Controller());
    expenseIdController.text = "";
    requestDateController.text = "";
    merhantName.text = "";
    _featureFuture = controller.getAllFeatureStates();
    projectConfig = controller.getFieldConfig("Project Id");
    taxGroupConfig = controller.getFieldConfig("Tax Group");
    taxAmountConfig = controller.getFieldConfig("Tax Amount");
    isReimbursibleConfig = controller.getFieldConfig("Is Reimbursible");
    isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
    isBillableConfig = controller.getFieldConfig("Is Billable");
    isLocationConfig = controller.getFieldConfig("Location");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pageController = PageController(
        initialPage: controller.currentIndex.value,
      );
      _loadSettings();
      controller.getconfigureFieldCashAdvance();
      controller.fetchLocation();
      controller.fetchPaidto();
      controller.fetchCashAdvanceExpenseCategory();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.fetchBusinessjustification();
      controller.fetchExpenseDocImage(widget.items!.recId);

      // ✅ Load header custom fields
      final allTransSavedValues = widget.items!.cshCashAdvReqTrans
          .expand((trans) => trans.cshTransCustomFieldValues ?? [])
          .toList();

      await controller.loadAllCustomFieldValues(
        savedValues: [
          ...widget.items!.cshHeaderCustomFieldValues,
          ...allTransSavedValues,
        ],
      );

      _initializeItemizeControllers(controller);

      historyFuture = controller.cashadvanceTracking(widget.items!.recId);
      setState(() => isLoading = true);

      final timestamp = widget.items!.requestDate;
      final int offsetMs =
          int.tryParse(controller.selectedTimezonevalue.value!) ?? 0;
      final DateTime receiptDate = DateTime.fromMillisecondsSinceEpoch(
        timestamp + offsetMs,
        isUtc: true,
      );
      final formatted = DateFormat(
        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
      ).format(receiptDate);
      controller.selectedDate = receiptDate;
      requestDateController.text = formatted;

      if (widget.items != null &&
          widget.items!.prefferedPaymentMethod != null) {
        controller.paymentMethodID = widget.items!.prefferedPaymentMethod
            .toString();
      }
      controller.employeeName.text = widget.items!.employeeName!;
      controller.employeeDropDownController.text = widget.items!.employeeId!;
      expenseIdController.text = widget.items!.requisitionId.toString();
      controller.justificationController.text =
          widget.items!.businessJustification;
      controller.referenceID.text = widget.items?.referenceId?.toString() ?? '';

      if (widget.items != null &&
          widget.items!.prefferedPaymentMethod != null) {
        controller.paidWithController.text =
            widget.items!.prefferedPaymentMethod!;
      } else {
        controller.paidWithController.text = '';
      }
      if (widget.items!.stepType == "Approval") {
        controller.isEnable.value = false;
        controller.isApprovalEnable.value = true;
        
      }
      selectedPaidTo = paidToOptions.first;
      selectedPaidWith = paidWithOptions.first;
      controller.locationController.text = widget.items!.location ?? '';
      controller.estimatedamountINR.text = widget
          .items!
          .totalEstimatedAmountInReporting
          .toString();
      controller.requestamountINR.text = widget
          .items!
          .totalRequestedAmountInReporting
          .toString();
      controller.requestedPercentage.text =
          widget.items?.percentage?.toString() ?? '100';
      controller.unitRate.text = widget.items!.totalEstimatedAmountInReporting
          .toString();

      if (widget.items?.workitemrecid != null) {
        workitemrecid = widget.items!.workitemrecid!;
      }

      calculateAmounts(controller.exchangeRate.toString());
      controller.amountINR.text = widget.items!.totalEstimatedAmountInReporting
          .toString();
      controller.expenseID = widget.items!.referenceId;
      controller.recID = widget.items!.recId;

      _initializeItemizeControllers(controller);
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ COMMON CALCULATION FUNCTION
  // ─────────────────────────────────────────────────────────────
  Future<void> _recalculate(Controller itemController, int index) async {
    try {
      final double qty =
          double.tryParse(itemController.quantity.text.trim()) ?? 0.0;

      final double unitAmount =
          double.tryParse(itemController.unitAmount.text.trim()) ?? 0.0;

      if (unitAmount <= 0) return;

      final double lineAmount = qty > 0 ? qty * unitAmount : unitAmount;

      itemController.totalunitEstimatedAmount.text = lineAmount.toStringAsFixed(
        2,
      );

      itemController.paidAmount.text = lineAmount.toStringAsFixed(2);

      final double percentage =
          double.tryParse(
            itemController.requestedPercentage.text.replaceAll('%', '').trim(),
          ) ??
          0.0;

      final String currency1 = itemController.currencyDropDowncontrollerCA3.text
          .trim();

      double exchangeRate1 = 1.0;

      if (currency1.isNotEmpty) {
        final rate = await itemController.fetchExchangeRatecalculated(
          currency1,
          lineAmount,
        );

        if (rate != null) {
          exchangeRate1 = rate;
          itemController.unitRateCA1.text = exchangeRate1.toStringAsFixed(2);
          itemController.isVisible.value = true;
        }
      }

      final double amountINRCA1 = lineAmount * exchangeRate1;
      itemController.amountINRCA1.text = amountINRCA1.toStringAsFixed(2);

      final double amountINRCA2 = (amountINRCA1 * percentage) / 100;
      itemController.amountINRCA2.text = amountINRCA2.toStringAsFixed(2);

      final String currency2 = itemController.currencyDropDowncontrollerCA2.text
          .trim();

      double exchangeRate2 = 1.0;

      if (currency2.isNotEmpty) {
        final exchangeResponse = await itemController.fetchExchangeRateCA(
          currency2,
          amountINRCA2.toString(),
        );

        if (exchangeResponse != null) {
          exchangeRate2 = exchangeResponse.exchangeRate;
          itemController.unitRateCA2.text = exchangeRate2.toStringAsFixed(2);
        }
      }

      final double totalRequestedAmount =
          (amountINRCA1 * exchangeRate2 * percentage) / 100;
      itemController.totalRequestedAmount.text = totalRequestedAmount
          .toStringAsFixed(2);
      itemController.calculatedPercentage.value = amountINRCA2;

      _syncControllerToModel(index);
      _updateHeaderTotals(itemController);
    } catch (e) {
      debugPrint('❌ _recalculate error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ PERCENTAGE-ONLY RECALCULATION
  // ─────────────────────────────────────────────────────────────
  Future<void> _recalculateFromPercentage(
    Controller itemController,
    int index,
    String percentageText,
  ) async {
    try {
      final double percentage = double.tryParse(percentageText) ?? 0.0;
      final double allowedPercentage =
          double.tryParse(itemController.allowedPercentage.text) ?? 0.0;

      if (percentage > allowedPercentage) {
        itemController.percentageError.value = true;
        return;
      }
      itemController.percentageError.value = false;
      if (percentage <= 0) return;

      final double baseAmountINR =
          double.tryParse(itemController.amountINRCA1.text) ?? 0.0;
      if (baseAmountINR <= 0) {
        await _recalculate(itemController, index);
        return;
      }

      final double requestedAmount = (baseAmountINR * percentage) / 100;
      itemController.calculatedPercentage.value = requestedAmount;

      final String currency2 = itemController.currencyDropDowncontrollerCA2.text
          .trim();
      if (currency2.isNotEmpty) {
        final ExchangeRateResponse? exchangeResponse2 = await itemController
            .fetchExchangeRateCA(currency2, requestedAmount.toString());
        if (exchangeResponse2 != null) {
          itemController.unitRateCA2.text = exchangeResponse2.exchangeRate
              .toString();
          itemController.totalRequestedAmount.text = exchangeResponse2
              .totalAmount
              .toStringAsFixed(2);
          itemController.amountINRCA2.text = requestedAmount.toStringAsFixed(2);
        }
      }

      _syncControllerToModel(index);
      _updateHeaderTotals(itemController);
    } catch (e) {
      debugPrint('❌ _recalculateFromPercentage error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER TOTALS
  // ─────────────────────────────────────────────────────────────
  void _updateHeaderTotals(Controller changedController) {
    double totalEstimated = 0.0;
    double totalRequested = 0.0;

    for (final c in itemizeControllers) {
      totalEstimated += double.tryParse(c.amountINRCA1.text) ?? 0.0;
      totalRequested += double.tryParse(c.amountINRCA2.text) ?? 0.0;
    }

    controller.estimatedamountINR.text = totalEstimated.toStringAsFixed(2);
    controller.requestamountINR.text = totalRequested.toStringAsFixed(2);
  }

  // ─────────────────────────────────────────────────────────────
  // LEGACY HELPERS
  // ─────────────────────────────────────────────────────────────
  double _calculateTotalLineAmount(Controller controllers) {
    double total = 0.0;
    total += double.tryParse(controllers.amountINRCA1.text) ?? 0.0;
    for (var c in itemizeControllers) {
      if (c != controllers)
        total += double.tryParse(c.amountINRCA1.text) ?? 0.0;
    }
    controller.estimatedamountINR.text = total.toStringAsFixed(2);
    return total;
  }

  double _calculateTotalLineAmount2(Controller controllers) {
    double total = 0.0;
    total += double.tryParse(controllers.amountINRCA2.text) ?? 0.0;
    for (var c in itemizeControllers) {
      if (c != controllers)
        total += double.tryParse(c.amountINRCA2.text) ?? 0.0;
    }
    controller.requestamountINR.text = total.toStringAsFixed(2);
    return total;
  }

  // ─────────────────────────────────────────────────────────────
  // SETTINGS
  // ─────────────────────────────────────────────────────────────
  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() => allowDocAttachments = settings.allowDocAttachments);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ INITIALIZE ITEMIZE CONTROLLERS WITH CUSTOM FIELDS
  // ─────────────────────────────────────────────────────────────
  void _initializeItemizeControllers(Controller controllers) {
    final mainController = Get.find<Controller>();

    if (widget.items!.cshCashAdvReqTrans.isEmpty) {
      final newController = Controller();
      if (mainController.customFields.isNotEmpty) {
        newController.cloneCustomFieldsFromRx(mainController.customFields);
        print(
          "Cloned ${newController.customFieldsItems.length} fields for empty transaction",
        );
      } else {
        print("No custom fields to clone for empty transaction");
      }
      itemizeControllers = [newController];
      _itemizeCount = 1;
      return;
    }

    itemizeControllers = widget.items!.cshCashAdvReqTrans.asMap().entries.map((
      entry,
    ) {
      final int idx = entry.key;
      final item = entry.value;
      final itemCtrl = Controller();

      // Set basic fields
      itemCtrl.amountINRCA1.text = item.lineEstimatedAmountInReporting
          .toString();
      itemCtrl.amountINRCA2.text = item.lineRequestedAdvanceInReporting
          .toString();
      itemCtrl.totalRequestedAmount.text = item.lineAdvanceRequested.toString();
      itemCtrl.projectDropDowncontroller.text = item.projectId ?? '';
      itemCtrl.descriptionController.text = item.description ?? '';
      itemCtrl.quantity.text = item.quantity?.toString() ?? '0';
      itemCtrl.unitPriceTrans.text =
          item.unitEstimatedAmount?.toString() ?? '0';
      itemCtrl.lineAmount.text = item.unitEstimatedAmount?.toString() ?? '0';
      itemCtrl.lineAmountINR.text = item.unitEstimatedAmount?.toString() ?? '0';
      itemCtrl.taxAmount.text = item.taxAmount?.toString() ?? '0';
      itemCtrl.unitRateCA2.text =
          item.lineRequestedExchangerate?.toString() ?? '0';
      itemCtrl.unitRateCA1.text =
          item.lineEstimatedExchangerate?.toString() ?? '0';
      itemCtrl.categoryController.text = item.expenseCategoryId ?? '';
      itemCtrl.selectedCategoryId = item.expenseCategoryId ?? '';
      itemCtrl.uomId.text = item.uomId ?? '';
      itemCtrl.locationController.text = item.location ?? '';
      itemCtrl.unitAmount.text = item.unitEstimatedAmount?.toString() ?? '0';
      itemCtrl.totalunitEstimatedAmount.text =
          item.lineEstimatedAmount?.toString() ?? '0';
      itemCtrl.currencyDropDowncontrollerCA3.text =
          item.lineEstimatedCurrency ?? '';
      itemCtrl.currencyDropDowncontrollerCA2.text =
          item.lineRequestedCurrency ?? '';

      // ✅ CRITICAL FIX: First, make sure customFieldsItems has all fields from main controller
      if (mainController.customFields.isNotEmpty) {
        itemCtrl.cloneCustomFieldsFromRx(mainController.customFields);
        print(
          "Cloned ${itemCtrl.customFieldsItems.length} fields for item $idx",
        );
      } else {
        print("Main controller customFields is empty for item $idx");
        itemCtrl.customFieldsItems.value = [];
      }

      // ✅ NOW load ExpenseTrans custom fields (transaction level)
      if (item.cshTransCustomFieldValues != null &&
          item.cshTransCustomFieldValues!.isNotEmpty) {
        print(
          "Loading ExpenseTrans custom fields for item $idx: ${item.cshTransCustomFieldValues?.length} fields",
        );

        for (var savedField in item.cshTransCustomFieldValues!) {
          // Instead of using dot notation, use bracket notation with the correct keys
          final savedFieldId =
              savedField['FieldId']; // or 'fieldId' - check your map structure
          final savedFieldValue = savedField['FieldValue']; // or 'fieldValue'
          final savedFieldName = savedField['FieldName']; // or 'fieldName'

          print(
            "Looking for ExpenseTrans field: $savedFieldId - $savedFieldName",
          );

          // Find matching field in customFieldsItems by FieldId
          final matchingFieldIndex = itemCtrl.customFieldsItems.indexWhere(
            (f) => f['FieldId'] == savedFieldId,
          );

          if (matchingFieldIndex != -1) {
            final field = itemCtrl.customFieldsItems[matchingFieldIndex];
            final fieldType = field['FieldType'] ?? 'Text';

            // ✅ Ensure ObjectName is set for transaction fields
            field['ObjectName'] = 'cashadvancetrans';

            print(
              "✅ Found matching ExpenseTrans field: ${field['FieldName']} (${field['FieldId']})",
            );
            print("  → Setting value: $savedFieldValue");

            _setFieldValue(field, savedFieldValue, fieldType);
          } else {
            print(
              "⚠️ Could not find matching ExpenseTrans field for saved field: $savedFieldId - $savedFieldName",
            );

            // ✅ If field doesn't exist, create it dynamically with proper structure
            final newField = {
              'FieldId': savedFieldId,
              'FieldName': savedFieldName,
              'FieldLabel': savedFieldName,
              'FieldValue': savedFieldValue,
              'FieldType': _detectFieldTypeFromValue(
                savedFieldValue,
              ), // Auto-detect type
              'ObjectName': 'cashadvancetrans',
              'EnteredValue': savedFieldValue?.toString() ?? '',
              'IsMandatory': false,
              'IsEnabled': true,
            };

            // Initialize reactive values based on field type
            _initializeFieldReactiveValue(newField, savedFieldValue);

            itemCtrl.customFieldsItems.add(newField);
            print(
              "  → Created new field: $savedFieldName with type: ${newField['FieldType']}",
            );
          }
        }
      }

      // Load accounting distributions
      if (item.accountingDistributions != null) {
        itemCtrl.split = (item.accountingDistributions ?? []).map((dist) {
          return AccountingSplit(
            paidFor: dist.dimensionValueId ?? '',
            percentage: dist.allocationFactor ?? 0.0,
            amount: dist.transAmount ?? 0.0,
          );
        }).toList();
      }

      if (itemCtrl.location.isNotEmpty) {
        itemCtrl.selectedLocation = itemCtrl.location.firstWhere(
          (e) => e.city == item.location,
          orElse: () => itemCtrl.location.first,
        );
      }

      if (item.accountingDistributions != null) {
        itemCtrl.accountingDistributions.clear();
        itemCtrl.accountingDistributions.addAll(
          item.accountingDistributions!.map((dist) {
            return AccountingDistribution(
              transAmount: dist.transAmount ?? 0.0,
              reportAmount: dist.reportAmount ?? 0.0,
              allocationFactor: dist.allocationFactor ?? 0.0,
              dimensionValueId: dist.dimensionValueId ?? '',
            );
          }),
        );
      }

      return itemCtrl;
    }).toList();

    _itemizeCount = widget.items!.cshCashAdvReqTrans.length;
    for (int i = 0; i < itemizeControllers.length; i++) {
      _itemizeFormKeys[i] = GlobalKey<FormState>();
    }

    // Also initialize async data for each item
    for (int i = 0; i < itemizeControllers.length; i++) {
      _initializeControllerAsyncData(
        itemizeControllers[i],
        widget.items!.cshCashAdvReqTrans[i],
      );
    }

    setState(() => isLoading = false);
  }

  // ✅ Helper method to detect field type from value
  String _detectFieldTypeFromValue(dynamic value) {
    if (value == null) return 'Text';

    // Check if it's a number
    if (value is num) {
      if (value is int) return 'LongInteger';
      return 'Decimal';
    }

    if (value is bool) return 'Checkbox';

    if (value is String) {
      // Check if it's a date
      if (value.contains(RegExp(r'\d{4}-\d{2}-\d{2}'))) {
        if (value.contains(':')) {
          return 'Date&Time';
        }
        return 'Date';
      }
      // Check if it's a number string
      if (RegExp(r'^\d+$').hasMatch(value)) return 'LongInteger';
      if (RegExp(r'^\d+\.\d+$').hasMatch(value)) return 'Decimal';
    }

    return 'Text';
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

  // ✅ Helper method to initialize reactive values for custom fields
  void _initializeFieldReactiveValue(
    Map<String, dynamic> field,
    dynamic savedFieldValue,
  ) {
    final String fieldType = field['FieldType'] ?? 'Text';
    final dynamic defaultValue = field['DefaultValue'];
    final dynamic valueToUse = savedFieldValue ?? defaultValue;

    if (fieldType == 'List' ||
        fieldType == 'CustomList' ||
        fieldType == 'SystemList') {
      final options = field['Options'] as List<CustomDropdownValue>? ?? [];
      CustomDropdownValue? matchedOption;

      if (valueToUse != null && options.isNotEmpty) {
        matchedOption = options.firstWhereOrNull(
          (opt) =>
              opt.valueId == valueToUse.toString() ||
              opt.valueName == valueToUse.toString(),
        );
      }

      field['SelectedValue'] = matchedOption;
      field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(matchedOption);
      field['EnteredValue'] =
          matchedOption?.valueId ?? valueToUse?.toString() ?? '';
    } else if (fieldType == 'Checkbox') {
      final boolValue =
          valueToUse == true ||
          valueToUse == 'true' ||
          valueToUse == 'True' ||
          valueToUse == '1';
      field['_rxCheckboxValue'] = Rx<bool>(boolValue);
      field['EnteredValue'] = boolValue;
    } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
      DateTime? parsedDate = _parseDateTimeValue(valueToUse);
      field['_rxDateValue'] = Rx<DateTime?>(parsedDate);
      field['EnteredValue'] = parsedDate;
    } else if (fieldType == 'LongInteger') {
      final intValue = int.tryParse(valueToUse?.toString() ?? '');
      field['_rxIntValue'] = Rx<int?>(intValue);
      field['EnteredValue'] = intValue;
    } else if (fieldType == 'Decimal') {
      final doubleValue = double.tryParse(valueToUse?.toString() ?? '');
      field['_rxDoubleValue'] = Rx<double?>(doubleValue);
      field['EnteredValue'] = doubleValue;
    } else if (fieldType == 'Email') {
      final stringValue = valueToUse?.toString() ?? '';
      field['_rxStringValue'] = Rx<String?>(stringValue);
      field['EnteredValue'] = stringValue;
      field['_controller'] = TextEditingController(text: stringValue);
    } else if (fieldType == 'MobileNumber') {
      final stringValue = valueToUse?.toString() ?? '';
      field['_rxStringValue'] = Rx<String?>(stringValue);
      field['EnteredValue'] = stringValue;
      field['_controller'] = TextEditingController(text: stringValue);
    } else {
      final stringValue = valueToUse?.toString() ?? '';
      field['_rxStringValue'] = Rx<String?>(stringValue);
      field['EnteredValue'] = stringValue;
      field['_controller'] = TextEditingController(text: stringValue);
    }
  }

  // Helper to parse DateTime
  DateTime? _parseDateTimeValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // ASYNC INIT DATA
  // ─────────────────────────────────────────────────────────────
  void _initializeControllerAsyncData(
    Controller itemCtrl,
    CashAdvanceRequestItemize item,
  ) async {
    final paidAmountText = item.lineEstimatedAmount;
    final double? paidAmounts = item.lineAdvanceRequested;
    final currency = item.lineEstimatedCurrency;

    if (currency != null && paidAmountText != null) {
      try {
        final results = await Future.wait([
          itemCtrl.fetchExchangeRateCAEstimated(
            currency,
            paidAmountText.toString(),
          ),
          itemCtrl.fetchMaxAllowedPercentage(),
        ]);

        final exchangeResponse1 = results[0] as ExchangeRateResponse?;
        final maxPercentage = item.percentage;

        if (exchangeResponse1 != null) {
          itemCtrl.unitRateCA1.text = exchangeResponse1.exchangeRate.toString();
          itemCtrl.amountINRCA1.text = exchangeResponse1.totalAmount
              .toStringAsFixed(2);
          itemCtrl.isVisible.value = true;
        }

        if (maxPercentage != null && maxPercentage > 0 && paidAmounts != null) {
          itemCtrl.totalRequestedAmount.text = item.lineAdvanceRequested
              .toString();
          itemCtrl.calculatedPercentage.value =
              (paidAmounts * maxPercentage) / 100;
          itemCtrl.requestedPercentage.text = maxPercentage.toString();
        }

        final reqPaidAmount = itemCtrl.totalRequestedAmount.text.trim();
        final reqCurrency = itemCtrl.currencyDropDowncontrollerCA2.text;
        if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
          final exchangeResponse2 = await itemCtrl.fetchExchangeRateCA(
            reqCurrency,
            reqPaidAmount,
          );
          if (exchangeResponse2 != null) {
            itemCtrl.unitRateCA2.text = exchangeResponse2.exchangeRate
                .toString();
            itemCtrl.amountINRCA2.text = exchangeResponse2.totalAmount
                .toStringAsFixed(2);
          }
        }
      } catch (e) {
        debugPrint('Error fetching async data: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LEGACY calculateAmounts
  // ─────────────────────────────────────────────────────────────
  void calculateAmounts(String rateStr) {
    final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
    final rate = double.tryParse(rateStr) ?? 1.0;
    final result = paid * rate;
    controller.amountINR.text = result.toStringAsFixed(2);
    controller.isVisible.value = true;

    for (final itemCtrl in itemizeControllers) {
      final unitPrice = double.tryParse(itemCtrl.unitPriceTrans.text) ?? 0.0;
      itemCtrl.lineAmountINR.text = (unitPrice * rate).toStringAsFixed(2);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ SYNC MODEL WITH CUSTOM FIELDS
  // ─────────────────────────────────────────────────────────────
  void _syncControllerToModel(int index) {
    final itemCtrl = itemizeControllers[index];
    final originalItem = widget.items!.cshCashAdvReqTrans[index];

    // ✅ Collect transaction custom field values as List<CustomFieldValue>
    final List<CustomFieldValue> transCustomFieldValues = [];
    for (var field in itemCtrl.customFieldsItems) {
      if (field['ObjectName'] == 'cashadvancetrans') {
        final fieldId = field['FieldId']?.toString();
        final fieldName = field['FieldName']?.toString();
        dynamic fieldValue = field['EnteredValue'];

        // Handle different field types
        final fieldType = field['FieldType'] ?? 'Text';
        if (fieldType == 'Date' && fieldValue is DateTime) {
          fieldValue = fieldValue.toIso8601String();
        } else if (fieldType == 'Date&Time' && fieldValue is DateTime) {
          fieldValue = fieldValue.toIso8601String();
        } else if (fieldType == 'Checkbox') {
          fieldValue = fieldValue == true ? 'true' : 'false';
        } else if (field['_rxSelectedValue'] != null) {
          final selectedValue =
              (field['_rxSelectedValue'] as Rx<CustomDropdownValue?>).value;
          fieldValue = selectedValue?.valueId ?? fieldValue;
        }

        transCustomFieldValues.add(
          CustomFieldValue(
            fieldId: fieldId!,
            fieldName: fieldName!,
            fieldValue: fieldValue?.toString() ?? '',
            customFieldEntity: 'cashadvancetrans',
          ),
        );
      }
    }

    // ✅ Also collect category custom fields if any

    setState(() {
      widget.items!.cshCashAdvReqTrans[index] = CashAdvanceRequestItemize(
        cashAdvReqHeader: originalItem.cashAdvReqHeader,
        recId: originalItem.recId,
        description: itemCtrl.descriptionController.text,
        quantity:
            int.tryParse(itemCtrl.quantity.text) ?? originalItem.quantity ?? 1,
        location: itemCtrl.locationController.text,
        projectId: itemCtrl.projectDropDowncontroller.text,
        expenseCategoryId: itemCtrl.selectedCategoryId,
        uomId: itemCtrl.uomId.text,
        unitEstimatedAmount: double.tryParse(itemCtrl.unitAmount.text) ?? 1,
        percentage: (double.tryParse(itemCtrl.requestedPercentage.text) ?? 1)
            .toInt(),
        lineEstimatedCurrency: itemCtrl.currencyDropDowncontrollerCA3.text,
        lineRequestedCurrency: itemCtrl.currencyDropDowncontrollerCA2.text,
        lineEstimatedAmount:
            double.tryParse(itemCtrl.totalunitEstimatedAmount.text) ?? 0.0,
        lineEstimatedAmountInReporting:
            double.tryParse(itemCtrl.amountINRCA1.text) ?? 0.0,
        lineAdvanceRequested:
            double.tryParse(itemCtrl.totalRequestedAmount.text) ?? 0.0,
        lineRequestedAdvanceInReporting:
            double.tryParse(itemCtrl.amountINRCA2.text) ?? 0.0,
        lineRequestedExchangerate:
            double.tryParse(itemCtrl.unitRateCA2.text) ?? 0.0,
        lineEstimatedExchangerate:
            double.tryParse(itemCtrl.unitRateCA1.text) ?? 0.0,
        maxAllowedPercentage:
            (double.tryParse(itemCtrl.requestedPercentage.text) ?? 1).toInt(),
        baseUnit: originalItem.baseUnit,
        baseUnitRequested: originalItem.baseUnitRequested,
        taxAmount: double.tryParse(itemCtrl.taxAmount.text) ?? 0.0,
        accountingDistributions: itemCtrl.accountingDistributions.map((dist) {
          return AccountingDistribution(
            transAmount: dist!.transAmount ?? 0.0,
            reportAmount: dist.reportAmount ?? 0.0,
            allocationFactor: dist.allocationFactor ?? 0.0,
            dimensionValueId: dist.dimensionValueId ?? 'Branch001',
          );
        }).toList(),
        // ✅ Use CustomFieldValue objects
        cshTransCustomFieldValues: transCustomFieldValues
            .map(
              (e) => {
                'FieldId': e.fieldId,
                'FieldName': e.fieldName,
                'FieldValue': e.fieldValue,

                // Add any other fields your CustomFieldValue class has
              },
            )
            .toList(),
        // cshTransCategoryCustomFieldValues: categoryCustomFieldValues,
      );
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ADD / REMOVE ITEMIZE
  // ─────────────────────────────────────────────────────────────
  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        final newItem = CashAdvanceRequestItemize(
          description: '',
          quantity: 1,
          uomId: 'Uom-004',
          percentage: 100,
          unitEstimatedAmount: 0,
          lineEstimatedCurrency: 'INR',
          lineRequestedCurrency: 'INR',
          projectId: '',
          location: '',
          lineEstimatedAmount: 0,
          lineEstimatedAmountInReporting: 0,
          lineAdvanceRequested: 0,
          lineRequestedAdvanceInReporting: 0,
          lineRequestedExchangerate: 1,
          lineEstimatedExchangerate: 1,
          maxAllowedPercentage: 100,
          baseUnit: 1,
          baseUnitRequested: 1,
          expenseCategoryId: "",
          taxAmount: 0,
          accountingDistributions: [],
          cshTransCustomFieldValues: [], // ✅ Initialize empty custom fields
        );

        widget.items!.cshCashAdvReqTrans.add(newItem);

        final newCtrl = Controller();
        newCtrl.currencyDropDowncontrollerCA3 = TextEditingController(
          text: 'INR',
        );
        newCtrl.currencyDropDowncontrollerCA2 = TextEditingController(
          text: 'INR',
        );
        newCtrl.isVisible = false.obs;
        newCtrl.calculatedPercentage = 0.0.obs;
        newCtrl.split = <AccountingSplit>[].obs;

        // ✅ Initialize empty custom fields list for new item
        newCtrl.customFieldsItems.value = [];

        if (controller.project.isNotEmpty) {
          newCtrl.selectedProject = controller.project.firstWhere(
            (p) => p.code == newItem.projectId,
            orElse: () => controller.project.first,
          );
        }
        if (controller.expenseCategory.isNotEmpty) {
          newCtrl.selectedCategory = controller.expenseCategory.firstWhere(
            (c) => c.categoryId == newItem.expenseCategoryId,
            orElse: () => controller.expenseCategory.first,
          );
        }
        if (controller.unit.isNotEmpty) {
          newCtrl.selectedunit = controller.unit.firstWhere(
            (u) => u.code == newItem.uomId,
            orElse: () => controller.unit.first,
          );
        }

        itemizeControllers = List.from(itemizeControllers)..add(newCtrl);
        _itemizeCount++;
        _selectedItemizeIndex = _itemizeCount - 1;
        showItemizeDetails = true;
        _itemizeFormKeys[_itemizeCount - 1] = GlobalKey<FormState>();
      });
    }
  }

  void _removeItemize(int index) {
    if (_itemizeCount <= 1) {
      setState(() => showItemizeDetails = false);
    } else if (index >= 0 && index < widget.items!.cshCashAdvReqTrans.length) {
      setState(() {
        widget.items!.cshCashAdvReqTrans.removeAt(index);
        itemizeControllers.removeAt(index);
        _itemizeFormKeys.remove(index);
        for (int i = index; i < _itemizeCount - 1; i++) {
          _itemizeFormKeys[i] = _itemizeFormKeys[i + 1]!;
        }
        _itemizeFormKeys.remove(_itemizeCount - 1);
        _itemizeCount--;
        if (_selectedItemizeIndex >= _itemizeCount) {
          _selectedItemizeIndex = _itemizeCount - 1;
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────────────────────
  bool _validateForm() {
    bool isValid = true;
    if (!_formKey.currentState!.validate()) isValid = false;
    for (int i = 0; i < itemizeControllers.length; i++) {
      if (_itemizeFormKeys[i]?.currentState?.validate() == false)
        isValid = false;
    }
    if (controller.justificationController.text.isEmpty) {
      setState(() => paidToError = 'Business Justification is required');
      isValid = false;
    }
    return isValid;
  }

  String? _validateRequiredField(
    String value,
    String fieldName,
    bool isMandatory,
  ) {
    if (isMandatory && (value.isEmpty || value.trim().isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateNumericField(
    String value,
    String fieldName,
    bool isMandatory,
  ) {
    if (isMandatory && value.isEmpty) return '$fieldName is required';
    if (value.isNotEmpty && double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  String? _validateDropdownField(
    String value,
    String fieldName,
    bool isMandatory,
  ) {
    if (isMandatory && value.isEmpty) return 'Please select $fieldName';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // FILE / IMAGE PICKERS
  // ─────────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      controller.isImageLoading.value = true;
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          setState(() => controller.imageFiles.add(File(croppedFile.path)));
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to upload image",
        backgroundColor: Colors.red,
      );
    } finally {
      controller.isImageLoading.value = false;
    }
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
            await _processSelectedFile(File(croppedFile.path));
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

  Future<void> _processSelectedFile(File file) async {
    await controller.getAllFeatureStates();
    setState(() => controller.imageFiles.add(file));
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
    if (croppedFile != null) return File(croppedFile.path);
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
                  onPressed: () => Navigator.pop(context),
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
                            setState(
                              () => controller.imageFiles[index] = croppedFile,
                            );
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
                          setState(() => controller.imageFiles.removeAt(index));
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

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          controller.clearFormFields();
          controller.isEnable.value = false;
          controller.isLoadingGE1.value = false;
          widget.items?.cshCashAdvReqTrans.clear();
          Navigator.pop(context);
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.cashAdvanceRequestForm,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
            softWrap: true,
            maxLines: 2,
          ),
          actions: [
            if (widget.isReadOnly && 
                    widget.items != null &&
                    widget.items!.approvalStatus != "Cancelled" &&
                    widget.items!.approvalStatus != "Approved" &&
                    widget.items!.stepType != "Approval" &&
                    widget.items!.approvalStatus != "Pending" ||
                widget.items!.stepType == "Review" &&
                    PermissionHelper.canUpdate("Cash Advance Requisition"))
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.isEnable.value
                        ? Icons.remove_red_eye
                        : Icons.edit_document,
                  ),
                  onPressed: () {
                    controller.isEnable.value = !controller.isEnable.value;
                  },
                ),
              ),
            // if (widget.items != null &&
            //     widget.items!.stepType == "Approval" &&
            //     PermissionHelper.canUpdate("Cash Advance Requisition"))
            //   Obx(
            //     () => IconButton(
            //       icon: Icon(
            //         controller.isApprovalEnable.value
            //             ? Icons.remove_red_eye
            //             : Icons.edit_document,
            //       ),
            //       onPressed: () {
            //         controller.isApprovalEnable.value =
            //             !controller.isApprovalEnable.value;
            //       },
            //     ),
            //   ),
            // const SizedBox.shrink(),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingLogin.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── DOCUMENT ATTACHMENTS ──
                        if (allowDocAttachments) const SizedBox(height: 10),
                        if (allowDocAttachments) _buildDocAttachmentArea(),

                        const SizedBox(height: 20),

                        // ── HEADER FIELDS ──
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeId} *",
                          controller: controller.employeeDropDownController,
                          isReadOnly: false,
                        ),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeName} *",
                          controller: controller.employeeName,
                          isReadOnly: false,
                        ),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.cashAdvanceRequisitionId} *",
                          controller: expenseIdController,
                          isReadOnly: false,
                          validator: (value) => _validateRequiredField(
                            value!,
                            "Cash Advance Requisition ID",
                            true,
                          ),
                        ),

                        const SizedBox(height: 6),
                        buildDateField(
                          '${AppLocalizations.of(context)!.requestDate} *',
                          requestDateController,
                          isReadOnly: !controller.isEnable.value,
                        ),
                        const SizedBox(height: 6),

                        // ── BUSINESS JUSTIFICATION ──
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            SearchableMultiColumnDropdownField<
                              Businessjustification
                            >(
                              labelText:
                                  '${AppLocalizations.of(context)!.businessJustification} * ',
                              enabled: controller.isEnable.value,
                              columnHeaders: [
                                AppLocalizations.of(context)!.id,
                                AppLocalizations.of(context)!.name,
                              ],
                              items: controller.justification,
                              selectedValue: controller.selectedjustification,
                              searchValue: (p) => '${p.id} ${p.name}',
                              displayText: (p) => p.name,
                              validator: (p) => _validateDropdownField(
                                controller.justificationController.text,
                                "Business Justification",
                                true,
                              ),
                              onChanged: (p) {
                                setState(() {
                                  controller.selectedjustification = p;
                                  controller.justificationController.text =
                                      p!.name;
                                  paidToError = null;
                                });
                              },
                              controller: controller.justificationController,
                              rowBuilder: (p, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(p.name)),
                                      Expanded(child: Text(p.id)),
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

                        // ── PAID WITH ──
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              // validator: (p) => _validateDropdownField(
                              //   controller.paidWithController.text,
                              //   "Payment Method",
                              //   true,
                              // ),
                              onChanged: (p) {
                                setState(() {
                                  controller.selectedPaidWith = p;
                                  controller.paymentMethodID =
                                      p!.paymentMethodId;
                                  controller.paidWithController.text =
                                      p.paymentMethodId;
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
                            const SizedBox(height: 4),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // ✅ HEADER CUSTOM FIELDS SECTION
                        Obx(() {
                          return Column(
                            children: controller.customFields
                                .where(
                                  (field) =>
                                      field['ObjectName'] ==
                                      'cashadvanceheader',
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

                                  if (!fieldControllers.containsKey(fieldKey)) {
                                    fieldControllers[fieldKey] =
                                        TextEditingController();
                                  }

                                  Widget inputField = _buildCustomFieldWidget(
                                    field: field,
                                    label: label,
                                    isMandatory: isMandatory,
                                    fieldKey: fieldKey,
                                    fieldType: fieldType,
                                    isDateTime: isDateTime,
                                    // isHeader: true,
                                    controller: controller,
                                    fieldControllers: fieldControllers,
                                  );

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

                        // ── REFERENCE ID (config-driven) ──
                        ...controller.configListAdvance
                            .where(
                              (field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] == 'Refrence Id',
                            )
                            .map((field) {
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    label:
                                        '${AppLocalizations.of(context)!.referenceId} ${isMandatory ? "*" : ""}',
                                    controller: controller.referenceID,
                                    isReadOnly: controller.isEnable.value,
                                    validator: (value) =>
                                        isRefrenceIDConfig.isMandatory
                                        ? _validateRequiredField(
                                            value!,
                                            "Reference ID",
                                            true,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            })
                            .toList(),

                        const SizedBox(height: 4),

                        // ── TOTAL AMOUNTS (read-only) ──
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
                        const SizedBox(height: 20),

                        // ── ITEMIZE LIST ──
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.itemize} ${AppLocalizations.of(context)!.details}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        widget.items!.cshCashAdvReqTrans.length,
                                    itemBuilder: (context, index) {
                                      final item = widget
                                          .items!
                                          .cshCashAdvReqTrans[index];
                                      final itemCtrl =
                                          itemizeControllers[index];
                                      return Form(
                                        key: _itemizeFormKeys[index],
                                        child: _buildItemizeCard(
                                          index,
                                          item,
                                          itemCtrl,
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── TRACKING HISTORY ──
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
                                  return const Center(
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
                                    return _buildTimelineItem(
                                      historyList[index],
                                      index == historyList.length - 1,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── ACTION BUTTONS ──
                        _buildActionButtons(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );
  }

  // ✅ Helper method to build custom field widgets
  Widget _buildCustomFieldWidget({
    required Map<String, dynamic> field,
    required String label,
    required bool isMandatory,
    required String fieldKey,
    required String fieldType,
    required bool isDateTime,
    required Controller controller,
    required Map<String, TextEditingController> fieldControllers,
  }) {
    // List type fields
    if (fieldType == 'List' ||
        fieldType == 'CustomList' ||
        fieldType == 'SystemList') {
      if (field['_rxSelectedValue'] == null) {
        field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(
          field['SelectedValue'] as CustomDropdownValue?,
        );
      }

      return Obx(() {
        final rxValue = field['_rxSelectedValue'] as Rx<CustomDropdownValue?>;
        return SearchableMultiColumnDropdownField<CustomDropdownValue>(
          labelText: '$label${isMandatory ? " *" : ""}',
          items: (field['Options'] as List<CustomDropdownValue>?) ?? [],
          selectedValue: rxValue.value,
          searchValue: (val) => val.valueName,
          enabled: controller.isEnable.value,
          displayText: (val) => val.valueName,
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
            rxValue.value = val;
            field['SelectedValue'] = val;
            field['EnteredValue'] = val?.valueId;
            field['Error'] = null;
          },
        );
      });
    }
    // Checkbox type
    else if (fieldType == 'Checkbox') {
      if (field['_rxCheckboxValue'] == null) {
        field['_rxCheckboxValue'] = Rx<bool>(field['EnteredValue'] ?? false);
      }

      return Obx(() {
        final rxValue = field['_rxCheckboxValue'] as Rx<bool>;
        return CheckboxListTile(
          title: Text('$label${isMandatory ? " *" : ""}'),
          value: rxValue.value,
          enabled: controller.isEnable.value,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          onChanged: controller.isEnable.value
              ? (bool? val) {
                  rxValue.value = val ?? false;
                  field['EnteredValue'] = val ?? false;
                  field['Error'] = null;
                }
              : null,
        );
      });
    }
    // Date and DateTime types
    else if (fieldType == 'Date' || fieldType == 'Date&Time') {
      if (field['_rxDateValue'] == null) {
        field['_rxDateValue'] = Rx<DateTime?>(
          field['EnteredValue'] as DateTime?,
        );
      }

      return Obx(() {
        final rxDateValue = field['_rxDateValue'] as Rx<DateTime?>;
        final currentDate = rxDateValue.value;

        if (currentDate != null) {
          if (isDateTime) {
            fieldControllers[fieldKey]!.text = DateFormat(
              'dd/MM/yyyy hh:mm a',
            ).format(currentDate);
          } else {
            fieldControllers[fieldKey]!.text = DateFormat(
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
            labelText: '$label${isMandatory ? " *" : ""}',
            border: const OutlineInputBorder(),
            errorText: field['Error'],
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: controller.isEnable.value
              ? () async {
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
                }
              : null,
          validator: (value) {
            if (isMandatory && rxDateValue.value == null) {
              return '$label is required';
            }
            return null;
          },
        );
      });
    }
    // LongInteger type
    else if (fieldType == 'LongInteger') {
      if (field['_rxIntValue'] == null) {
        field['_rxIntValue'] = Rx<int?>(field['EnteredValue'] as int?);
      }

      return Obx(() {
        final rxValue = field['_rxIntValue'] as Rx<int?>;
        final newText = rxValue.value?.toString() ?? '';
        if (fieldControllers[fieldKey]!.text != newText) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            fieldControllers[fieldKey]!.text = newText;
          });
        }

        return TextFormField(
          enabled: controller.isEnable.value,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: fieldControllers[fieldKey],
          decoration: InputDecoration(
            labelText: '$label${isMandatory ? " *" : ""}',
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
            if (isMandatory && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            return null;
          },
        );
      });
    }
    // Decimal type
    else if (fieldType == 'Decimal') {
      if (field['_rxDoubleValue'] == null) {
        field['_rxDoubleValue'] = Rx<double?>(field['EnteredValue'] as double?);
      }

      return Obx(() {
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
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          controller: fieldControllers[fieldKey],
          decoration: InputDecoration(
            labelText: '$label${isMandatory ? " *" : ""}',
            border: const OutlineInputBorder(),
            errorText: field['Error'],
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
            return null;
          },
        );
      });
    }
    // Default Text type
    else {
      if (field['_rxStringValue'] == null) {
        field['_rxStringValue'] = Rx<String?>(field['EnteredValue'] as String?);
      }

      return Obx(() {
        final rxValue = field['_rxStringValue'] as Rx<String?>;
        final newText = rxValue.value ?? '';
        if (fieldControllers[fieldKey]!.text != newText) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            fieldControllers[fieldKey]!.text = newText;
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

  // ─────────────────────────────────────────────────────────────
  // ✅ ITEMIZE CARD WIDGET WITH TRANSACTION CUSTOM FIELDS
  // ─────────────────────────────────────────────────────────────
  Widget _buildItemizeCard(
    int index,
    CashAdvanceRequestItemize item,
    Controller itemCtrl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── CARD HEADER (title + add/delete buttons) ──
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
                    if (controller.isEnable.value &&
                        widget.items!.cshCashAdvReqTrans.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItemize(index),
                        tooltip: 'Remove this item',
                      ),
                    if (controller.isEnable.value)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: _addItemize,
                        tooltip: 'Add new item',
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
                // ── CONFIG-DRIVEN FIELDS (Project Id etc.) ──
                ...controller.configListAdvance
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
                        inputField =
                            SearchableMultiColumnDropdownField<Project>(
                              enabled: controller.isEnable.value,
                              labelText: AppLocalizations.of(
                                context,
                              )!.projectId,
                              columnHeaders: [
                                AppLocalizations.of(context)!.projectName,
                                AppLocalizations.of(context)!.projectId,
                              ],
                              items: controller.project,
                              selectedValue: itemCtrl.selectedProject,
                              searchValue: (p) => '${p.name} ${p.code}',
                              displayText: (p) => p.code,
                              validator: (p) => _validateDropdownField(
                                itemCtrl.projectDropDowncontroller.text,
                                "Project",
                                isMandatory,
                              ),
                              onChanged: (p) {
                                setState(() {
                                  controller.selectedProject = p;
                                  itemCtrl.selectedProject = p;
                                  controller.projectDropDowncontroller.text =
                                      p!.code;
                                });
                                controller.fetchCashAdvanceExpenseCategory();
                                _recalculate(itemCtrl, index);
                              },
                              controller: itemCtrl.projectDropDowncontroller,
                              rowBuilder: (p, sq) => Padding(
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
                              ),
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
                        ],
                      );
                    })
                    .toList(),

                // ✅ TRANSACTION CUSTOM FIELDS SECTION (Each item has its own unique fields)
                const SizedBox(height: 12),

                // ── EXPENSE CATEGORY ──
                SearchableMultiColumnDropdownField<ExpenseCategory>(
                  labelText: AppLocalizations.of(context)!.paidFor,
                  enabled: controller.isEnable.value,
                  columnHeaders: [
                    AppLocalizations.of(context)!.categoryName,
                    AppLocalizations.of(context)!.categoryId,
                  ],
                  items: controller.expenseCategory,
                  selectedValue: itemCtrl.selectedCategory,
                  searchValue: (p) => '${p.categoryName} ${p.categoryId}',
                  displayText: (p) => p.categoryId,
                  validator: (p) => _validateDropdownField(
                    itemCtrl.categoryController.text,
                    "Expense Category",
                    false,
                  ),
                  onChanged: (p) {
                    setState(() {
                      itemCtrl.selectedCategory = p;
                      itemCtrl.selectedCategoryId = p!.categoryId;
                      itemCtrl.categoryController.text = p.categoryId;
                      controller.selectedCategoryId =
                          itemCtrl.selectedCategoryId = p.categoryId;
                    });
                    itemCtrl.fetchMaxAllowedPercentage();
                    _recalculate(itemCtrl, index);
                  },
                  controller: itemCtrl.categoryController,
                  rowBuilder: (p, sq) => Padding(
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
                  ),
                ),
                const SizedBox(height: 10),

                // ── LOCATION (config-driven) ──
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.configListAdvance
                        .where(
                          (field) =>
                              field['FieldName'] == 'Location' &&
                              field['IsEnabled'] == true,
                        )
                        .map((field) {
                          final bool isMandatory =
                              field['IsMandatory'] ?? false;
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
                                enabled: controller.isEnable.value,
                                controller: itemCtrl.locationController,
                                items: controller.location,
                                selectedValue: itemCtrl.selectedLocation,
                                searchValue: (loc) => loc.location,
                                displayText: (loc) => loc.location,
                                validator: (loc) => _validateDropdownField(
                                  itemCtrl.locationController.text,
                                  "Location",
                                  isMandatory,
                                ),
                                onChanged: (loc) {
                                  itemCtrl.locationController.text = loc!.city;
                                  controller.selectedLocation = loc;
                                  itemCtrl.fetchMaxAllowedPercentage();
                                  field['Error'] = null;

                                  if (_debounce?.isActive ?? false)
                                    _debounce!.cancel();
                                  _debounce = Timer(
                                    const Duration(milliseconds: 400),
                                    () => _recalculate(itemCtrl, index),
                                  );
                                },
                                rowBuilder: (loc, sq) => Padding(
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
                                ),
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
                              const SizedBox(height: 6),
                            ],
                          );
                        })
                        .toList(),
                  );
                }),

                // ── COMMENTS ──
                _buildTextField(
                  label: AppLocalizations.of(context)!.comments,
                  controller: itemCtrl.descriptionController,
                  isReadOnly: controller.isEnable.value,
                  onChanged: (value) {
                    _syncControllerToModel(index);
                    _updateHeaderTotals(itemCtrl);
                  },
                  validator: (value) =>
                      _validateRequiredField(value!, "Description", false),
                ),

                // ── REQUESTED PERCENTAGE ──
                TextFormField(
                  controller: itemCtrl.requestedPercentage,
                  keyboardType: TextInputType.number,
                  enabled: controller.isEnable.value,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final requiredError = _validateRequiredField(
                      value ?? '',
                      "Percentage",
                      true,
                    );
                    if (requiredError != null) return requiredError;

                    final number = double.tryParse(value!);
                    final total = double.tryParse(
                      itemCtrl.allowedPercentage.text,
                    );
                    if (number == null) return 'Enter valid number';
                    if (total == null) return 'Invalid allowed percentage';
                    if (number < 0 || number > total)
                      return 'Percentage cannot exceed $total';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText:
                        "${AppLocalizations.of(context)!.requestedPercentage} *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) {
                    itemCtrl.validatePercentage(
                      val,
                      itemCtrl.allowedPercentage.text,
                      itemCtrl,
                    );
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(seconds: 2), () async {
                      await _recalculateFromPercentage(
                        itemCtrl,
                        index,
                        itemCtrl.requestedPercentage.text,
                      );
                    });
                  },
                  onEditingComplete: () {
                    _recalculateFromPercentage(
                      itemCtrl,
                      index,
                      itemCtrl.requestedPercentage.text,
                    );
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 12),

                // ── UNIT DROPDOWN ──
                SearchableMultiColumnDropdownField<Unit>(
                  labelText: '${AppLocalizations.of(context)!.unit} *',
                  enabled: controller.isEnable.value,
                  columnHeaders: [
                    AppLocalizations.of(context)!.uomId,
                    AppLocalizations.of(context)!.uomName,
                  ],
                  items: controller.unit,
                  selectedValue: itemCtrl.selectedunit,
                  searchValue: (tax) => '${tax.code} ${tax.name}',
                  displayText: (tax) => tax.name,
                  validator: (tax) =>
                      _validateDropdownField(itemCtrl.uomId.text, "Unit", true),
                  onChanged: (tax) {
                    setState(() {
                      itemCtrl.selectedunit = tax;
                      itemCtrl.uomId.text = tax!.code;
                    });
                    _recalculate(itemCtrl, index);
                  },
                  controller: itemCtrl.uomId,
                  rowBuilder: (tax, sq) => Padding(
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
                  ),
                ),

                const SizedBox(height: 12),

                // ── QUANTITY ──
                _buildTextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  label: "${AppLocalizations.of(context)!.quantity} *",
                  controller: itemCtrl.quantity,
                  isReadOnly: controller.isEnable.value,
                  validator: (value) =>
                      _validateNumericField(value!, "Quantity", true),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 400),
                      () => _recalculate(itemCtrl, index),
                    );
                  },
                ),

                // ── UNIT ESTIMATED AMOUNT ──
                TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  controller: itemCtrl.unitAmount,
                  enabled: controller.isEnable.value,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) => _validateNumericField(
                    value!,
                    "Unit Estimated Amount",
                    true,
                  ),
                  onChanged: (value) {
                    final qty = double.tryParse(itemCtrl.quantity.text) ?? 0.0;
                    final unit = double.tryParse(value) ?? 0.0;
                    final lineAmount = qty * unit;
                    itemCtrl.totalunitEstimatedAmount.text = lineAmount
                        .toStringAsFixed(2);
                    itemCtrl.paidAmount.text = lineAmount.toStringAsFixed(2);

                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(
                      const Duration(seconds: 1),
                      () => _recalculate(itemCtrl, index),
                    );
                  },
                  onFieldSubmitted: (_) async {
                    await _recalculate(itemCtrl, index);
                  },
                  onEditingComplete: () async {
                    FocusScope.of(context).unfocus();
                    final text = itemCtrl.unitAmount.text;
                    final value = double.tryParse(text);
                    if (value != null) {
                      itemCtrl.unitAmount.text = value.toStringAsFixed(2);
                      itemCtrl.paidAmount.text = value.toStringAsFixed(2);
                    }
                    await _recalculate(itemCtrl, index);
                  },
                  decoration: InputDecoration(
                    labelText:
                        "${AppLocalizations.of(context)!.unitEstimatedAmount} *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ── AMOUNT ROWS (CA1 + CA2) ──
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CA1 — Total Estimated
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
                              controller: itemCtrl.totalunitEstimatedAmount,
                              enabled: !showItemizeDetails,
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumericField(
                                value!,
                                "Total Estimated Amount",
                                true,
                              ),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.paidAmount,
                                isDense: true,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                              ),
                              onChanged: (_) async {
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();
                                _debounce = Timer(
                                  const Duration(milliseconds: 400),
                                  () {
                                    itemCtrl.unitAmount.text =
                                        itemCtrl.totalunitEstimatedAmount.text;
                                    _recalculate(itemCtrl, index);
                                  },
                                );
                              },
                              onEditingComplete: () {
                                final text =
                                    itemCtrl.totalunitEstimatedAmount.text;
                                final value = double.tryParse(text);
                                if (value != null) {
                                  itemCtrl.totalunitEstimatedAmount.text = value
                                      .toStringAsFixed(2);
                                }
                              },
                            ),
                          ),
                          // CA1 currency dropdown
                          Obx(
                            () => SizedBox(
                              width: 90,
                              child:
                                  SearchableMultiColumnDropdownField<Currency>(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.currency,
                                    alignLeft: -90,
                                    dropdownWidth: 280,
                                    columnHeaders: [
                                      AppLocalizations.of(context)!.code,
                                      AppLocalizations.of(context)!.name,
                                      AppLocalizations.of(context)!.symbol,
                                    ],
                                    controller:
                                        itemCtrl.currencyDropDowncontrollerCA3,
                                    items: controller.currencies,
                                    selectedValue:
                                        itemCtrl.selectedCurrencyCA1.value,
                                    searchValue: (c) =>
                                        '${c.code} ${c.name} ${c.symbol}',
                                    displayText: (c) => c.code,
                                    enabled: controller.isEnable.value,
                                    validator: (c) => _validateDropdownField(
                                      itemCtrl
                                          .currencyDropDowncontrollerCA3
                                          .text,
                                      "Currency",
                                      true,
                                    ),
                                    inputDecoration: const InputDecoration(
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down_outlined,
                                      ),
                                      filled: true,
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onChanged: (c) async {
                                      itemCtrl.selectedCurrencyCA1.value = c;
                                      itemCtrl
                                              .currencyDropDowncontrollerCA3
                                              .text =
                                          c?.code ?? '';
                                      await _recalculate(itemCtrl, index);
                                    },
                                    rowBuilder: (c, sq) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text(c.code)),
                                          Expanded(child: Text(c.name)),
                                          Expanded(child: Text(c.symbol)),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              enabled: false,
                              controller: itemCtrl.unitRateCA1,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.rate,
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

                      const SizedBox(height: 10),
                      TextFormField(
                        controller: itemCtrl.amountINRCA1,
                        enabled: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText:
                              '${AppLocalizations.of(context)!.lineEstimatedAmountInINR} ${controller.organizationCurrency}',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CA2 — Total Requested
                      Text(
                        '${AppLocalizations.of(context)!.totalRequestedAmount}  *',
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
                              controller: itemCtrl.totalRequestedAmount,
                              enabled: false,
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumericField(
                                value!,
                                "Total Requested Amount",
                                true,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: AppLocalizations.of(
                                  context,
                                )!.paidAmount,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                              ),
                              onEditingComplete: () {
                                final text = itemCtrl.totalRequestedAmount.text;
                                final value = double.tryParse(text);
                                if (value != null) {
                                  itemCtrl.totalRequestedAmount.text = value
                                      .toStringAsFixed(2);
                                }
                              },
                            ),
                          ),
                          // CA2 currency dropdown
                          Obx(
                            () => SizedBox(
                              width: 90,
                              child:
                                  SearchableMultiColumnDropdownField<Currency>(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.currency,
                                    alignLeft: -90,
                                    enabled: controller.isEnable.value,
                                    dropdownWidth: 280,
                                    columnHeaders: [
                                      AppLocalizations.of(context)!.code,
                                      AppLocalizations.of(context)!.name,
                                      AppLocalizations.of(context)!.symbol,
                                    ],
                                    controller:
                                        itemCtrl.currencyDropDowncontrollerCA2,
                                    items: controller.currencies,
                                    selectedValue:
                                        itemCtrl.selectedCurrencyCA2.value,
                                    backgroundColor: Colors.white,
                                    searchValue: (c) =>
                                        '${c.code} ${c.name} ${c.symbol}',
                                    displayText: (c) => c.code,
                                    validator: (c) => _validateDropdownField(
                                      itemCtrl
                                          .currencyDropDowncontrollerCA2
                                          .text,
                                      "Currency",
                                      true,
                                    ),
                                    inputDecoration: const InputDecoration(
                                      isDense: true,
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down_outlined,
                                      ),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onChanged: (c) async {
                                      itemCtrl.selectedCurrencyCA2.value = c;
                                      controller
                                              .currencyDropDowncontrollerCA2
                                              .text =
                                          c?.code ?? '';
                                      await _recalculate(itemCtrl, index);
                                    },
                                    rowBuilder: (c, sq) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text(c.code)),
                                          Expanded(child: Text(c.name)),
                                          Expanded(child: Text(c.symbol)),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: itemCtrl.unitRateCA2,
                              enabled: false,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: AppLocalizations.of(context)!.rate,
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

                      const SizedBox(height: 10),
                      TextFormField(
                        controller: itemCtrl.amountINRCA2,
                        enabled: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText:
                              '${AppLocalizations.of(context)!.lineRequestedAmountInINR} ${controller.organizationCurrency}',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── ACCOUNT DISTRIBUTION BUTTON ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        final double lineAmount =
                            double.tryParse(itemCtrl.lineAmount.text) ?? 0.0;
                        if (itemCtrl.split.isEmpty &&
                            item.accountingDistributions!.isNotEmpty) {
                          itemCtrl.split.assignAll(
                            item.accountingDistributions!.map((e) {
                              return AccountingSplit(
                                paidFor: e.dimensionValueId,
                                percentage: e.allocationFactor,
                                amount: e.transAmount,
                              );
                            }).toList(),
                          );
                        } else if (itemCtrl.split.isEmpty) {
                          itemCtrl.split.add(
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
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 24,
                            ),
                            child: SingleChildScrollView(
                              child: AccountingDistributionWidget(
                                splits: itemCtrl.split,
                                isEnable: controller.isEnable.value,
                                lineAmount: lineAmount,
                                onChanged: (i, updatedSplit) {
                                  if (!mounted) return;
                                  itemCtrl.split[i] = updatedSplit;
                                  _syncControllerToModel(index);
                                },
                                onDistributionChanged: (newList) {
                                  if (!mounted) return;
                                  itemCtrl.accountingDistributions.clear();
                                  itemCtrl.accountingDistributions.addAll(
                                    newList,
                                  );
                                  _syncControllerToModel(index);
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
                ),
                Obx(() {
                  return Column(
                    children: itemCtrl.customFieldsItems
                        .where(
                          (field) => field['ObjectName'] == 'cashadvancetrans',
                        )
                        .map((field) {
                          final String label =
                              field['FieldLabel'] ?? field['FieldName'];
                          final bool isMandatory =
                              field['IsMandatory'] ?? false;
                          final String fieldKey =
                              'trans_${index}_${field['FieldId']}';
                          final String fieldType = field['FieldType'] ?? 'Text';
                          final bool isDateTime = fieldType == 'Date&Time';

                          // Create unique controller for this field if not exists
                          if (!itemizeFieldControllers.containsKey(fieldKey)) {
                            itemizeFieldControllers[fieldKey] =
                                TextEditingController();
                          }

                          Widget inputField = _buildCustomFieldWidget(
                            field: field,
                            label: label,
                            isMandatory: isMandatory,
                            fieldKey: fieldKey,
                            fieldType: fieldType,
                            isDateTime: isDateTime,
                            controller: controller,
                            fieldControllers: itemizeFieldControllers,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: inputField,
                          );
                        })
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    if (widget.items!.workitemrecid == null) {
      return _buildNoWorkitemButtons();
    } else {
      return _buildWorkitemButtons();
    }
  }

  Widget _buildNoWorkitemButtons() {
    return Column(
      children: [
        if (controller.isEnable.value &&
            widget.items!.approvalStatus == "Rejected")
          Obx(() {
            final isResubmitLoading =
                controller.buttonLoaders['resubmit'] ?? false;
            final isAnyLoading = controller.buttonLoaders.values.any((l) => l);
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
                        if (!_validateForm()) {
                          Fluttertoast.showToast(
                            msg: "Please fill all required fields",
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                        controller.setButtonLoading('resubmit', true);
                        controller.cashAdvanceReturnFinalItem(widget.items!);
                        controller
                            .saveinEditCashAdvance(
                              context,
                              true,
                              true,
                              widget.items!.recId,
                              widget.items!.requisitionId,
                            )
                            .whenComplete(
                              () => controller.setButtonLoading(
                                'resubmit',
                                false,
                              ),
                            );
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

        if (controller.isEnable.value) const SizedBox(height: 20),

        if (controller.isEnable.value &&
            widget.items!.approvalStatus == "Rejected")
          Row(
            children: [
              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (l) => l,
                );
                return Expanded(
                  child: ElevatedButton(
                    onPressed: (isUpdateLoading || isAnyLoading)
                        ? null
                        : () {
                            if (!_validateForm()) {
                              Fluttertoast.showToast(
                                msg: "Please fill all required fields",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            controller.setButtonLoading('update', true);
                            controller
                                .saveinEditCashAdvance(
                                  context,
                                  false,
                                  false,
                                  widget.items!.recId,
                                  widget.items!.requisitionId,
                                )
                                .whenComplete(
                                  () => controller.setButtonLoading(
                                    'update',
                                    false,
                                  ),
                                );
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
                  onPressed: () => controller.chancelButtonCA(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
            ],
          )
        else if (controller.isEnable.value &&
            widget.items!.approvalStatus == "Created") ...[
          Obx(() {
            final isSubmitLoading = controller.buttonLoaders['submit'] ?? false;
            final isAnyLoading = controller.buttonLoaders.values.any((l) => l);
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
                    : () {
                        if (!_validateForm()) {
                          Fluttertoast.showToast(
                            msg: "Please fill all required fields",
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                        controller.setButtonLoading('submit', true);
                        controller.cashAdvanceReturnFinalItem(widget.items!);
                        controller
                            .saveinEditCashAdvance(
                              context,
                              true,
                              false,
                              widget.items!.recId,
                              widget.items!.requisitionId,
                            )
                            .whenComplete(
                              () =>
                                  controller.setButtonLoading('submit', false),
                            );
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
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (l) => l,
                );
                return Expanded(
                  child: ElevatedButton(
                    onPressed: (isSaveLoading || isAnyLoading)
                        ? null
                        : () {
                            if (!_validateForm()) {
                              Fluttertoast.showToast(
                                msg: "Please fill all required fields",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            controller.setButtonLoading('saveGE', true);
                            controller.cashAdvanceReturnFinalItem(
                              widget.items!,
                            );
                            controller
                                .saveinEditCashAdvance(
                                  context,
                                  false,
                                  false,
                                  widget.items!.recId,
                                  widget.items!.requisitionId,
                                )
                                .whenComplete(
                                  () => controller.setButtonLoading(
                                    'saveGE',
                                    false,
                                  ),
                                );
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
                  (l) => l,
                );
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isAnyLoading
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            AppRoutes.cashAdvanceRequestDashboard,
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                );
              }),
            ],
          ),
        ],

        if (widget.isReadOnly && widget.items!.approvalStatus == "Pending")
          Row(
            children: [
              if (PermissionHelper.canUpdate("Cash Advance Requisition"))
                Obx(() {
                  final isLoading = controller.buttonLoaders['cancel'] ?? false;
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              controller.setButtonLoading('cancel', true);
                              controller
                                  .cancelCashadvance(
                                    context,
                                    widget.items!.recId.toString(),
                                  )
                                  .whenComplete(
                                    () => controller.setButtonLoading(
                                      'cancel',
                                      false,
                                    ),
                                  );
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
                  onPressed: () => controller.chancelButtonCA(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ],
          )
        else if (!controller.isEnable.value)
          ElevatedButton(
            onPressed: () => controller.chancelButtonCA(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(AppLocalizations.of(context)!.close),
          ),
      ],
    );
  }

  Widget _buildWorkitemButtons() {
    return Column(
      children: [
        if (controller.isEnable.value &&
            widget.items!.stepType == "Review") ...[
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['update_accept'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (l) => l == true,
                  );
                  return ElevatedButton(
                    onPressed: (isLoading || isAnyLoading)
                        ? null
                        : () async {
                            if (!_validateForm()) {
                              Fluttertoast.showToast(
                                msg: "Please fill all required fields",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            controller.setButtonLoading('update_accept', true);
                            controller.cashAdvanceReturnFinalItem(
                              widget.items!,
                            );
                            try {
                              await controller.reviewandUpdateCashAdvance(
                                context,
                                true,
                                widget.items!.recId,
                                widget.items!.requisitionId,
                                widget.items!.workitemrecid,
                              );
                            } finally {
                              controller.setButtonLoading(
                                'update_accept',
                                false,
                              );
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
                            AppLocalizations.of(context)!.updateAndAccept,
                            style: const TextStyle(color: Colors.white),
                          ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['update_review'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (l) => l == true,
                  );
                  return ElevatedButton(
                    onPressed: (isLoading || isAnyLoading)
                        ? null
                        : () async {
                            if (!_validateForm()) {
                              Fluttertoast.showToast(
                                msg: "Please fill all required fields",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            controller.setButtonLoading('update_review', true);
                            controller.cashAdvanceReturnFinalItem(
                              widget.items!,
                            );
                            try {
                              await controller.reviewandUpdateCashAdvance(
                                context,
                                false,
                                widget.items!.recId,
                                widget.items!.requisitionId,
                                widget.items!.workitemrecid,
                              );
                            } finally {
                              controller.setButtonLoading(
                                'update_review',
                                false,
                              );
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
                            AppLocalizations.of(context)!.update,
                            style: const TextStyle(color: Colors.white),
                          ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['reject_review'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (l) => l == true,
                  );
                  return ElevatedButton(
                    onPressed: (isLoading || isAnyLoading)
                        ? null
                        : () async {
                            controller.setButtonLoading('reject_review', true);
                            try {
                              showActionPopup(context, "Reject");
                            } finally {
                              controller.setButtonLoading(
                                'reject_review',
                                false,
                              );
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
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['close_review'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (l) => l == true,
                  );
                  return ElevatedButton(
                    onPressed: (isLoading || isAnyLoading)
                        ? null
                        : () async {
                            controller.setButtonLoading('close_review', true);
                            try {
                              controller.chancelButtonCA(context);
                            } finally {
                              controller.setButtonLoading(
                                'close_review',
                                false,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : Text(AppLocalizations.of(context)!.close),
                  );
                }),
              ),
            ],
          ),
        ],

        if (controller.isApprovalEnable.value &&
            widget.items!.stepType == "Approval") ...[
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['approve'] ?? false;
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
                            controller.setButtonLoading(
                              'reject_approval',
                              true,
                            );
                            try {
                              showActionPopup(context, "Reject");
                            } finally {
                              controller.setButtonLoading(
                                'reject_approval',
                                false,
                              );
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
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['escalate'] ?? false;
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            controller.setButtonLoading('close_approval', true);
                            try {
                              controller.chancelButtonCA(context);
                            } finally {
                              controller.setButtonLoading(
                                'close_approval',
                                false,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : Text(AppLocalizations.of(context)!.close),
                  );
                }),
              ),
            ],
          ),
        ],

        if (!controller.isEnable.value &&
            !controller.isApprovalEnable.value &&
            widget.items!.stepType != "Review")
          ElevatedButton(
            onPressed: () async {
              controller.setButtonLoading('close_review', true);
              try {
                controller.chancelButtonCA(context);
              } finally {
                controller.setButtonLoading('close_review', false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        if (!controller.isEnable.value && widget.items!.stepType == "Review")
          ElevatedButton(
            onPressed: () async {
              controller.setButtonLoading('close_review', true);
              try {
                controller.chancelButtonCA(context);
              } finally {
                controller.setButtonLoading('close_review', false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(AppLocalizations.of(context)!.close),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ACTION POPUP
  // ─────────────────────────────────────────────────────────────
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
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, sq) => Padding(
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ""}',
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
                        if (isCommentError && value.trim().isEmpty) {
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

                            final success = await controller
                                .postApprovalActioncashAdvance(
                                  context,
                                  workitemrecid: [workitemrecid],
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
                                AppRoutes.approvalDashboardForDashboard,
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

  // ─────────────────────────────────────────────────────────────
  // DOC ATTACHMENT AREA
  // ─────────────────────────────────────────────────────────────
  Widget _buildDocAttachmentArea() {
    return Obx(() {
      return Stack(
        children: [
          GestureDetector(
            onTap: _pickFile,
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
                          onPageChanged: (index) =>
                              controller.currentIndex.value = index,
                          itemBuilder: (_, index) {
                            final file = controller.imageFiles[index];
                            final path = file.path;
                            return GestureDetector(
                              onTap: () =>
                                  controller.openFile(context, file, index),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: controller.isImage(path)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
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
          ),
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
    });
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED SMALL WIDGETS
  // ─────────────────────────────────────────────────────────────
  Widget buildDateField(
    String label,
    TextEditingController controllers, {
    required bool isReadOnly,
  }) {
    return TextFormField(
      controller: controllers,
      readOnly: true,
      enabled: !isReadOnly,
      validator: (value) =>
          _validateRequiredField(value!, "Request Date", true),
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
                    } catch (_) {
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
        const SizedBox(height: 12),
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
            textColor: Colors.deepPurple,
            iconColor: Colors.deepPurple,
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
