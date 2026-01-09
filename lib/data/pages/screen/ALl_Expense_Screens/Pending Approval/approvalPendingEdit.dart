import 'dart:async';
import 'dart:io';

import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../../l10n/app_localizations.dart';

class ApprovalViewEditExpensePage extends StatefulWidget {
  final bool isReadOnly;
  final GESpeficExpense? items;
  const ApprovalViewEditExpensePage({
    super.key,
    this.items,
    required this.isReadOnly,
  });

  @override
  State<ApprovalViewEditExpensePage> createState() =>
      _ApprovalViewEditExpensePageState();
}

class _ApprovalViewEditExpensePageState
    extends State<ApprovalViewEditExpensePage>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController employeeName = TextEditingController();
  final TextEditingController employyeID = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
  late Future<Map<String, bool>> _featureFuture;

  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  late Future<List<ExpenseHistory>> historyFuture;
  late PageController _pageController;
  String? selectedPaidTo;
  String? statusApproval;
  String? selectedPaidWith;
  bool allowMultSelect = false;
  bool _showHistory = false;
    late FocusNode _focusNode;

   int? workitemrecid;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isTyping = false;

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
    expenseIdController.text = "";
    receiptDateController.text = "";
    merhantName.text = "";
    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // calculateAmounts(widget.items!.exchRate.toString());
  controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchExpenseCategory();
      controller.fetchUnit();
      controller.fetchTaxGroup();
      controller.currencyDropDown();
      controller.fetchExchangeRate();
      controller.fetchUsers();
      controller.fetchExpenseDocImage(widget.items!.recId);
      controller.configuration();

      _loadSettings();
    });
    historyFuture = controller.fetchExpenseHistory(widget.items!.recId);
    final formatted = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.items!.receiptDate);
    controller.selectedDate = widget.items!.receiptDate;
    statusApproval = widget.items!.approvalStatus;
    receiptDateController.text = formatted;
    if (widget.items != null && widget.items!.paymentMethod != null) {
      controller.paymentMethodID = widget.items!.paymentMethod.toString();
    }
    if (widget.items!.approvalStatus == "Approved") {
      controller.isEnable.value = false;
    }
    expenseIdController.text = widget.items!.expenseId.toString();
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
    if (widget.items != null && widget.items!.paymentMethod != null) {
      controller.paidWithController.text = widget.items!.paymentMethod!;
    } else {
      controller.paidWithController.text = '';
    }

    selectedPaidWith = paidWithOptions.first;
    controller.paidAmount.text = widget.items!.totalAmountTrans.toStringAsFixed(
      2,
    );
    controller.unitAmount.text = widget.items!.totalAmountTrans.toStringAsFixed(
      2,
    );
    controller.unitRate.text = widget.items!.exchRate.toStringAsFixed(2);
    controller.cashAdvReqIds = widget.items!.cashAdvReqId;
    controller.employeeIdController.text = widget.items!.employeeName!;
    controller.employeeName.text = widget.items!.employeeId!;
        controller.justificationnotes.text = widget.items!.justificateNotes!;

    controller.amountINR.text = widget.items!.totalAmountReporting
        .toStringAsFixed(2);
    controller.expenseID = widget.items!.expenseId;
    controller.recID =
        widget.items!.recId ?? widget.items!.unprocessedRecId ?? null;
    workitemrecid = widget.items!.workitemrecid!;
    controller.isBillableCreate = widget.items!.isBillable;
    if (widget.items!.merchantId == null) {
      controller.manualPaidToController.text = widget.items!.merchantName!;
    } else {
      controller.paidToController.text = widget.items!.merchantName!;
    }
    controller.currencyDropDowncontroller.text = widget.items!.currency
        .toString();

    _initializeItemizeControllers();
    _initializeData();
    projectConfig = controller.getFieldConfig("Project Id");
    taxGroupConfig = controller.getFieldConfig("Tax Group");
    taxAmountConfig = controller.getFieldConfig("Tax Amount");
    isReimbursibleConfig = controller.getFieldConfig("is Reimbursible");
    isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
    isBillableConfig = controller.getFieldConfig("Is Billable");
    isLocationConfig = controller.getFieldConfig("Location");
  }

Future<void> _initializeControllerData() async {
  try {
    // Fetch all required data first
    await Future.wait([
      controller.fetchPaidto(),
      controller.fetchPaidwith(),
      controller.fetchProjectName(),
      controller.fetchExpenseCategory(),
      controller.fetchUnit(),
      controller.fetchTaxGroup(),
      controller.currencyDropDown(),
      controller.fetchExchangeRate(),
      controller.fetchUsers(),
      controller.fetchExpenseDocImage(widget.items!.recId),
      controller.configuration(),
    ]);

    // Wait for a microtask to ensure build is complete
    await Future.microtask(() {});
    
    // Now set the values
    final formatted = DateFormat('dd/MM/yyyy').format(widget.items!.receiptDate);
    controller.selectedDate = widget.items!.receiptDate;
    receiptDateController.text = formatted;
    employeeName.text = widget.items!.employeeName!;
    employyeID.text = widget.items!.employeeId!;
    statusApproval = widget.items!.approvalStatus;
    controller.paymentMethodID = widget.items!.paymentMethod.toString();
    expenseIdController.text = widget.items!.expenseId.toString();
    receiptDateController.text = formatted;
    controller.paidToController.text = widget.items!.merchantName.toString();
    controller.paidWithController.text = widget.items!.paymentMethod!;
    controller.referenceID.text = widget.items!.referenceNumber.toString();
    selectedPaidTo = paidToOptions.first;
    selectedPaidWith = paidWithOptions.first;
    controller.paidAmount.text = widget.items!.totalAmountTrans.toString();
    controller.unitAmount.text = widget.items!.totalAmountTrans.toString();
    controller.unitRate.text = widget.items!.exchRate.toString();
    controller.cashAdvReqIds = widget.items!.cashAdvReqId;
    controller.justificationnotes.text = widget.items!.justificateNotes!;
    controller.employeeName.text = widget.items!.employeeName!;
    controller.employeeIdController.text = widget.items!.employeeId!;
    controller.isBillableCreate = widget.items!.isBillable;
    controller.expenseID = widget.items!.expenseId;
    controller.recID = widget.items!.recId;
    workitemrecid = widget.items!.workitemrecid!;
    controller.currencyDropDowncontroller.text = widget.items!.currency.toString();
    
    print("totalAmountReporting${controller.approvalamountINR.text}");
    
    // Call setState once at the end
    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    print("Error initializing controller data: $e");
  }
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
        DateFormat('dd/MM/yyyy').parseStrict(value);
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

    if (_validateRequiredField(
          controller.employeeIdController.text,
          AppLocalizations.of(context)!.employeeId,
          true,
        ) !=
        null) {
      isValid = false;
    }

    if (_validateRequiredField(
          controller.employeeName.text,
          AppLocalizations.of(context)!.employeeName,
          true,
        ) !=
        null) {
      isValid = false;
    }

    if (!controller.isManualEntryMerchant) {
      if (_validateRequiredField(
            controller.paidToController.text,
            AppLocalizations.of(context)!.selectMerchant,
            true,
          ) !=
          null) {
        isValid = false;
      }
    } else {
      if (_validateRequiredField(
            controller.manualPaidToController.text,
            AppLocalizations.of(context)!.enterMerchantName,
            true,
          ) !=
          null) {
        isValid = false;
      }
    }

    if (_validateRequiredField(
          controller.paidWithController.text,
          AppLocalizations.of(context)!.paidWith,
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

      if (_validateNumericField(
            itemController.lineAmount.text,
            AppLocalizations.of(context)!.lineAmount,
            true,
          ) !=
          null) {
        isValid = false;
      }

      if (_validateNumericField(
            itemController.lineAmountINR.text,
            AppLocalizations.of(context)!.lineAmountInInr,
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

  Future<void> _updateAllLineItems() async {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      _calculateTotalLineAmount(itemController).toStringAsFixed(2);
      controller.calculateLineAmounts(itemController);

      final lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
      final lineAmountInINR = lineAmount * rate;

      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

      widget.items!.expenseTrans[i] = itemController.toExpenseItemUpdateModel();
    }

    setState(() {});
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        print("allowDocAttachments$allowMultSelect");
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

    controller.paidAmount.text = total.toStringAsFixed(2);

    final paid = total;
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    controller.approvalamountINR.text = (paid * rate).toStringAsFixed(2);

    return total;
  }

  void _initializeItemizeControllers() {
    itemizeControllers = widget.items!.expenseTrans.map((item) {
      final controller = Controller();

      controller.projectDropDowncontroller.text = item.projectId ?? '';
      controller.descriptionController.text = item.description ?? '';
      controller.quantity.text = item.quantity.toString();
      controller.unitPriceTrans.text = item.unitPriceTrans.toString();
      controller.lineAmount.text = item.lineAmountTrans.toString();
      controller.lineAmountINR.text = item.lineAmountReporting.toString();
      controller.taxAmount.text = item.taxAmount.toString();
      controller.taxGroupController.text = item.taxGroup!;
      controller.categoryController.text = item.expenseCategoryId;
      controller.uomId.text = item.uomId;
      controller.isReimbursite = item.isReimbursable;
      controller.isBillable.value = item.isBillable;
      controller.split = (item.accountingDistributions ?? []).map((dist) {
        return AccountingSplit(
          paidFor: dist.dimensionValueId ?? '',
          percentage: dist.allocationFactor ?? 0.0,
          amount: dist.transAmount ?? 0.0,
        );
      }).toList();
      return controller;
    }).toList();
    _itemizeCount = widget.items!.expenseTrans.length;
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
        (e) => e.paymentMethodId == widget.items!.paymentMethod,
        orElse: () => controller.paymentMethods.first,
      );
    }

    if (controller.project.isNotEmpty) {
      controller.selectedProject = controller.project.firstWhere(
        (e) => e.code == widget.items!.projectId,
        orElse: () => controller.project.first,
      );
    }
    if (controller.currencies.isNotEmpty) {
      controller.selectedCurrency.value = controller.currencies.firstWhere(
        (e) => e.code == widget.items!.currency,
        orElse: () => controller.currencies.first,
      );
    }
    setState(() {});
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        final newItem = ExpenseItemUpdate(
          description: '',
          quantity: 0,
          unitPriceTrans: 0,
          lineAmountTrans: 0,
          lineAmountReporting: 0,
          taxAmount: 0,
          isReimbursable: false,
          isBillable: false,
          projectId: controller.projectDropDowncontroller.text ?? '',
          expenseCategoryId: controller.categoryController.text ?? "",
          uomId: controller.unit.isNotEmpty ? controller.unit.first.code : '',
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
        newController.isReimbursite = newItem.isReimbursable;
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
          newController.selectedunit = controller.unit.firstWhere(
            (u) => u.code == newItem.uomId,
            orElse: () => controller.unit.first,
          );
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
      });
    }
  }

  void _removeItemize(int index) {
    if (_itemizeCount <= 1) {
      setState(() {
        showItemizeDetails = false;
      });
    } else if (index >= 0 && index < widget.items!.expenseTrans.length) {
      setState(() {
        widget.items!.expenseTrans.removeAt(index);
        itemizeControllers.removeAt(index);
        _itemizeCount--;
        if (_selectedItemizeIndex >= _itemizeCount) {
          _selectedItemizeIndex = _itemizeCount - 1;
        }
      });
    }
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
      Get.snackbar('Error', e.toString());
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
      print("Error picking or cropping image: $e");
      Fluttertoast.showToast(
        msg: "Failed to upload image",
        backgroundColor: Colors.red,
      );
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
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
    return WillPopScope(
      onWillPop: () async {
        controller.isEnable.value = false;
        controller.isLoadingGE1.value = false;
        controller.isApprovalEnable.value = false;
        controller.clearFormFields();
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            (controller.isEnable.value || controller.isApprovalEnable.value)
                ? AppLocalizations.of(context)!.editExpenseApproval
                : AppLocalizations.of(context)!.viewExpenseApproval,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            if (widget.isReadOnly && widget.items != null)
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
                  setState(() {
                    if (widget.items!.stepType == "Approval") {
                      controller.isApprovalEnable.value =
                          !controller.isApprovalEnable.value;
                    } else if (widget.items!.approvalStatus != "Cancelled") {
                      controller.isEnable.value = !controller.isEnable.value;
                    }
                  });
                },
              ),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingviewImage.value
              ? const SkeletonLoaderPage()
              : Form(
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
                                  statusApproval!,
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
                        GestureDetector(
                          onTap: !controller.isEnable.value
                              ? null
                              : () => _pickImage(ImageSource.gallery),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(() {
                              if (controller.imageFiles.isEmpty) {
                                return Center(
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.tapToUploadDocs,
                                  ),
                                );
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
                                        final file =
                                            controller.imageFiles[index];
                                        return GestureDetector(
                                          onTap: () =>
                                              _showFullImage(file, index),
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.all(8),
                                            width: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.deepPurple,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                          onTap: () =>
                                              _pickImage(ImageSource.gallery),
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
                                );
                              }
                            }),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        buildDateField(
                          AppLocalizations.of(context)!.receiptDate,
                          receiptDateController,
                          isReadOnly: !controller.isEnable.value,
                          validator: (value) => _validateDateField(
                            value!,
                            AppLocalizations.of(context)!.receiptDate,
                            true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeId} *",
                          controller: controller.employeeIdController,
                          isReadOnly: false,
                          validator: (value) => _validateRequiredField(
                            value!,
                            AppLocalizations.of(context)!.employeeId,
                            true,
                          ),
                        ),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeName} *",
                          controller: controller.employeeName,
                          isReadOnly: false,
                          validator: (value) => _validateRequiredField(
                            value!,
                            AppLocalizations.of(context)!.employeeName,
                            true,
                          ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (!controller.isManualEntryMerchant)
                              AbsorbPointer(
                                absorbing: !controller.isEnable.value,
                                child:
                                    SearchableMultiColumnDropdownField<
                                      MerchantModel
                                    >(
                                      enabled: controller.isEnable.value,
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.selectMerchant,
                                      columnHeaders: [
                                        AppLocalizations.of(
                                          context,
                                        )!.merchantName,
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
                                  value ?? '',
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
                          ],
                        ),
                        const SizedBox(height: 12),
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
                                      items: controller.cashAdvanceListDropDown,
                                      isMultiSelect: allowMultSelect ?? false,
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
                                        controller.multiSelectedItems.assignAll(
                                          items,
                                        );
                                      },
                                      columnHeaders: [
                                        AppLocalizations.of(context)!.requestId,
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
                              validator: (value) => _validateRequiredField(
                                controller.paidWithController.text,
                                AppLocalizations.of(context)!.paidWith,
                                true,
                              ),
                              onChanged: (p) {
                                loadAndAppendCashAdvanceList();
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
                          ],
                        ),
                        const SizedBox(height: 12),
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
                                  const SizedBox(height: 8),
                                  inputFields,
                                  const SizedBox(height: 16),
                                ],
                              );
                            })
                            .toList(),
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

                                  controller.approvalamountINR.text = result
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
                                            controller.paidWithController.text,
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
                                  value ?? '',
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

                                  controller.approvalamountINR.text = result
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

                                    widget.items!.expenseTrans[i] =
                                        itemController
                                            .toExpenseItemUpdateModel();
                                  }

                                  setState(() {});
                                  print("Paid Amount: $paid");
                                  print("Rate: $rate");
                                  print(
                                    "Calculated INR Amount: ${controller.approvalamountINR.text}",
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controller.approvalamountINR,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.amountInInr} *',
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
                              itemCount: widget.items!.expenseTrans.length,
                              itemBuilder: (context, index) {
                                final item = widget.items!.expenseTrans[index];
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
                                                            .items!
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
                                                  FutureBuilder<
                                                    Map<String, bool>
                                                  >(
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
                                                          'is Reimbursible',
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
                                                                  .projectDropDowncontroller
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
                                                          itemController
                                                              .projectDropDowncontroller
                                                              .text = p!
                                                              .code;
                                                          widget
                                                                  .items!
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
                                                                  .items!
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
                                                                  ?.expenseTrans[index] =
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
                                                      const SizedBox(height: 8),
                                                      inputField,
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ],
                                                  );
                                                })
                                                .toList(),
                                            // SearchableMultiColumnDropdownField<
                                            //   Project
                                            // >(
                                            //   enabled: controller.isEnable.value,
                                            //   labelText: AppLocalizations.of(
                                            //     context,
                                            //   )!.projectId,
                                            //   columnHeaders: const [
                                            //     'Project Name',
                                            //     'Project ID',
                                            //   ],
                                            //   items: controller.project,
                                            //   selectedValue:
                                            //       itemController.selectedProject,
                                            //   searchValue: (p) =>
                                            //       '${p.name} ${p.code}',
                                            //   displayText: (p) => p.code,
                                            //   validator: (value) => projectConfig.isEnabled && projectConfig.isMandatory
                                            //       ? _validateRequiredField(itemController
                                            //       .projectDropDowncontroller.text, AppLocalizations.of(context)!.projectId, true)
                                            //       : null,
                                            //   onChanged: (p) {
                                            //     setState(() {
                                            //       controller.selectedProject = p;
                                            //       itemController.selectedProject =
                                            //           p;
                                            //       controller
                                            //           .projectDropDowncontroller
                                            //           .text = p!
                                            //           .code;
                                            //       widget
                                            //               .items!
                                            //               .expenseTrans[index] =
                                            //           itemController
                                            //               .toExpenseItemUpdateModel();
                                            //     });
                                            //     controller.fetchExpenseCategory();
                                            //   },
                                            //   controller: itemController
                                            //       .projectDropDowncontroller,
                                            //   rowBuilder: (p, searchQuery) {
                                            //     return Padding(
                                            //       padding:
                                            //           const EdgeInsets.symmetric(
                                            //             vertical: 12,
                                            //             horizontal: 16,
                                            //           ),
                                            //       child: Row(
                                            //         children: [
                                            //           Expanded(
                                            //             child: Text(p.name),
                                            //           ),
                                            //           Expanded(
                                            //             child: Text(p.code),
                                            //           ),
                                            //         ],
                                            //       ),
                                            //     );
                                            //   },
                                            // ),
                                            const SizedBox(height: 12),
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
                                                    itemController.uomId.text,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.paidFor,
                                                    true,
                                                  ),
                                              onChanged: (p) {
                                                setState(() {
                                                  itemController
                                                          .selectedCategory =
                                                      p;
                                                  itemController
                                                          .selectedCategoryId =
                                                      p!.categoryId;
                                                  widget
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                  itemController
                                                          .categoryController
                                                          .text =
                                                      p.categoryId;
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
                                            const SizedBox(height: 12),
                                            _buildTextField(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.comments,
                                              controller: itemController
                                                  .descriptionController,
                                              isReadOnly:
                                                  controller.isEnable.value,
                                              onChanged: (value) {
                                                setState(() {
                                                  widget
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                            ),
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
                                              displayText: (tax) => tax.name,
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
                                                          .items!
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
                                            const SizedBox(height: 12),
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
                                                          .items!
                                                          .expenseTrans[index],
                                                    );
                                                _calculateTotalLineAmount(
                                                  itemController,
                                                ).toStringAsFixed(2);
                                                setState(() {
                                                  widget
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                            ),
                                            _buildTextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'),
                                                ),
                                              ],
                                              label:
                                                  "${AppLocalizations.of(context)!.unitAmount} *",
                                              controller:
                                                  itemController.unitPriceTrans,
                                              isReadOnly:
                                                  controller.isEnable.value,
                                              validator: (value) =>
                                                  _validateNumericField(
                                                    value!,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.unitAmount,
                                                    true,
                                                  ),
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
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                            ),
                                            _buildTextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'),
                                                ),
                                              ],
                                              label: AppLocalizations.of(
                                                context,
                                              )!.lineAmount,
                                              controller:
                                                  itemController.lineAmount,
                                              isReadOnly: false,
                                              validator: (value) =>
                                                  _validateNumericField(
                                                    value!,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.lineAmount,
                                                    true,
                                                  ),
                                              onChanged: (value) {
                                                itemController
                                                    .calculateLineAmounts(
                                                      itemController,
                                                      widget
                                                          .items!
                                                          .expenseTrans[index],
                                                    );
                                              },
                                            ),
                                            _buildTextField(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.lineAmountInInr,
                                              controller:
                                                  itemController.lineAmountINR,
                                              isReadOnly: false,
                                              validator: (value) =>
                                                  _validateNumericField(
                                                    value!,
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.lineAmountInInr,
                                                    true,
                                                  ),
                                              onChanged: (value) {
                                                setState(() {
                                                  widget
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel();
                                                });
                                              },
                                            ),

                                            // const SizedBox(height: 12),
                                            const SizedBox(height: 12),
                                            ...controller.configList
                                                .where(
                                                  (field) =>
                                                      field['IsEnabled'] ==
                                                          true &&
                                                      field['FieldName'] ==
                                                          'is Reimbursible',
                                                )
                                                .map((field) {
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
                                                                        .items!
                                                                        .expenseTrans[index] = itemController
                                                                        .toExpenseItemUpdateModel();
                                                                  });
                                                                }
                                                              : null,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 16,
                                                      ),
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
                                                                          .items!
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

                                            if (controller.isEnable.value)
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
                                                        itemController.split
                                                            .add(
                                                              AccountingSplit(
                                                                percentage:
                                                                    100.0,
                                                              ),
                                                            );
                                                      }

                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
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
                                                            bottom:
                                                                MediaQuery.of(
                                                                      context,
                                                                    )
                                                                    .viewInsets
                                                                    .bottom,
                                                            left: 16,
                                                            right: 16,
                                                            top: 24,
                                                          ),
                                                          child: SingleChildScrollView(
                                                            child: AccountingDistributionWidget(
                                                              splits:
                                                                  itemController
                                                                      .split,
                                                              lineAmount:
                                                                  lineAmount,
                                                              onChanged: (i, updatedSplit) {
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
                                                        decoration:
                                                            TextDecoration
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
                        const SizedBox(height: 10),
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
                                            child: Text(
                                              "No Data Available",
                                            ),
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
                                    print("Trackingitem: $item");
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
                            widget.items!.approvalStatus == "Rejected")
                          Obx(() {
                            return SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: AppLocalizations.of(context)!.resubmit,
                                isLoading: controller.buttonLoader.value,
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      _validateForm()) {
                                    controller.addToFinalItems(widget.items!);
                                    controller.saveinviewPageGeneralExpense(
                                      context,
                                      true,
                                      true,
                                      widget.items!.recId!,
                                    );
                                  }
                                },
                              ),
                            );
                          }),

                        if (controller.isEnable.value)
                          const SizedBox(height: 20),

                        if (controller.isEnable.value &&
                            widget.items!.stepType == "Review")
                          Row(
                            children: [
                              Obx(() {
                                final isUpdateLoading =
                                    controller.buttonLoaders['update'] ?? false;
                                final isUpdateAcceptLoading =
                                    controller.buttonLoaders['update_accept'] ??
                                    false;
                                final isRejectLoading =
                                    controller.buttonLoaders['reject'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        (isUpdateLoading ||
                                            isUpdateAcceptLoading ||
                                            isRejectLoading ||
                                            isAnyLoading)
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
                                                widget.items!,
                                              );
                                              controller
                                                  .reviewGendralExpense(
                                                    context,
                                                    false,
                                                    widget
                                                        .items!
                                                        .workitemrecid!,
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
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        3,
                                        20,
                                        117,
                                      ),
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

                              Obx(() {
                                final isUpdateLoading =
                                    controller.buttonLoaders['update'] ?? false;
                                final isUpdateAcceptLoading =
                                    controller.buttonLoaders['update_accept'] ??
                                    false;
                                final isRejectLoading =
                                    controller.buttonLoaders['reject'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        (isUpdateAcceptLoading ||
                                            isUpdateLoading ||
                                            isRejectLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                    .validate() &&
                                                _validateForm()) {
                                              controller.setButtonLoading(
                                                'update_accept',
                                                true,
                                              );
                                              controller.addToFinalItems(
                                                widget.items!,
                                              );
                                              controller
                                                  .reviewGendralExpense(
                                                    context,
                                                    true,
                                                    widget
                                                        .items!
                                                        .workitemrecid!,
                                                  )
                                                  .whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'update_accept',
                                                      false,
                                                    );
                                                  });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        3,
                                        20,
                                        117,
                                      ),
                                    ),
                                    child: isUpdateAcceptLoading
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
                                            )!.updateAndAccept,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        if (controller.isEnable.value &&
                            widget.items!.stepType == "Review")
                          const SizedBox(height: 12),
                        if (controller.isEnable.value &&
                            widget.items!.stepType == "Review")
                          Row(
                            children: [
                              Obx(() {
                                final isUpdateLoading =
                                    controller.buttonLoaders['update'] ?? false;
                                final isUpdateAcceptLoading =
                                    controller.buttonLoaders['update_accept'] ??
                                    false;
                                final isRejectLoading =
                                    controller.buttonLoaders['reject'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        (isRejectLoading ||
                                            isUpdateLoading ||
                                            isUpdateAcceptLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                    .validate() &&
                                                _validateForm()) {
                                              controller.setButtonLoading(
                                                'reject',
                                                true,
                                              );
                                              controller.addToFinalItems(
                                                widget.items!,
                                              );
                                              showActionPopup(
                                                context,
                                                "Reject",
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        238,
                                        20,
                                        20,
                                      ),
                                    ),
                                    child: isRejectLoading
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
                                            )!.reject,
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
                                    controller.closeField();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.close,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        if (controller.isApprovalEnable.value &&
                            widget.items!.stepType == "Approval")
                          Row(
                            children: [
                              Obx(() {
                                final isLoading =
                                    controller.buttonLoaders['approve'] ??
                                    false;
                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            controller.setButtonLoading(
                                              'approve',
                                              true,
                                            );
                                            showActionPopup(context, "Approve");

                                            controller.setButtonLoading(
                                              'approve',
                                              false,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        30,
                                        117,
                                        3,
                                      ),
                                    ),
                                    child: isLoading
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
                                            )!.approvals,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),

                              const SizedBox(width: 12),

                              Obx(() {
                                final isLoading =
                                    controller
                                        .buttonLoaders['reject_approval'] ??
                                    false;
                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            controller.setButtonLoading(
                                              'reject_approval',
                                              true,
                                            );
                                            showActionPopup(context, "Reject");

                                            controller.setButtonLoading(
                                              'reject_approval',
                                              false,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        238,
                                        20,
                                        20,
                                      ),
                                    ),
                                    child: isLoading
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
                                            )!.reject,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                            ],
                          ),

                        if (controller.isApprovalEnable.value &&
                            widget.items!.stepType == "Approval")
                          Row(
                            children: [
                              Obx(() {
                                final isLoading =
                                    controller.buttonLoaders['escalate'] ??
                                    false;
                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            controller.setButtonLoading(
                                              'escalate',
                                              true,
                                            );
                                            showActionPopup(
                                              context,
                                              "Escalate",
                                            );

                                            controller.setButtonLoading(
                                              'escalate',
                                              false,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        3,
                                        20,
                                        117,
                                      ),
                                    ),
                                    child: isLoading
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
                                            )!.escalate,
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
                                    controller.closeField();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.close,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        if (!controller.isEnable.value &&
                            !controller.isApprovalEnable.value)
                          ElevatedButton(
                            onPressed: () {
                              controller.chancelButton(context);
                              controller.isApprovalEnable.value = false;
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
                        'dd-MM-yyyy',
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
                    lastDate: DateTime(2101),
                  );

                  if (picked != null) {
                    controllers.text = DateFormat('dd-MM-yyyy').format(picked);
                    controller.selectedDateMileage = picked;
                    controller.fetchMileageRates();
                    controller.selectedDate = picked;
                    controller.fetchProjectName();
                  }
                },
        ),
        border: const OutlineInputBorder(),
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
                    '${AppLocalizations.of(context)!.submittedOn}${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
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
                      AppLocalizations.of(context)!.comments,
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
                            ? 'Comment is required.'
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
                          onPressed: () {
                            controller.closeField();
                            Navigator.pop(context);
                          },
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
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
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
