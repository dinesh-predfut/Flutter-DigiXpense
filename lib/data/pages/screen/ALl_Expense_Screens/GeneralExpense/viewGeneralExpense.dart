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
      expenseIdController.text = "";
      receiptDateController.text = "";
      merhantName.text = "";
      calculateAmounts(widget.items.exchRate.toString());
      controller.fetchExpenseDocImage(widget.items.recId);
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      await controller.fetchExpenseCategory();
      controller.configuration();
      controller.fetchUnit();
      controller.fetchTaxGroup();
      controller.currencyDropDown();

      _loadSettings();

      final formatted = DateFormat(
        'dd-MM-yyyy',
      ).format(widget.items.receiptDate.toUtc());
      controller.selectedDate = widget.items.receiptDate;
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
      controller.employeeIdController.text = widget.items!.employeeId!;
      controller.unitRate.text = widget.items.exchRate.toStringAsFixed(2);
      controller.cashAdvReqIds = widget.items.cashAdvReqId;
      controller.amountINR.text = widget.items.totalAmountReporting
          .toStringAsFixed(2);
      controller.expenseID = widget.items.expenseId;
      controller.recID =
          widget.items.recId ?? widget.items.unprocessedRecId ?? null;

      controller.isBillableCreate = widget.items.isBillable;
      if (widget.items.merchantId == null) {
        controller.manualPaidToController.text = widget.items.merchantName!;
      } else {
        controller.paidToController.text = widget.items.merchantName!;
      }
      controller.currencyDropDowncontroller.text = widget.items.currency
          .toString();

      _initializeItemizeControllers();
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
        DateFormat('dd-MM-yyyy').parseStrict(value);
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
    if (widget.items.expenseTrans.isEmpty) {
      //  // print("expenseTransCalling");
      final item = widget.items;
      print("itemitem${item.recId}");
      // final controller = Controller();
      controller.recIDItem = item.recId;
      controller.expenseId = int.tryParse(item.expenseId);
      controller.projectDropDowncontroller.text = item.projectId ?? '';
      controller.descriptionController.text = item.description ?? '';
      controller.quantity.text = '1';
      controller.unitPriceTrans.text =
          item.totalAmountTrans?.toStringAsFixed(2) ?? '';
      controller.lineAmount.text =
          item.totalAmountTrans?.toStringAsFixed(2) ?? '';
      controller.lineAmountINR.text =
          item.totalAmountReporting?.toStringAsFixed(2) ?? '';
      controller.taxAmount.text = item.taxAmount?.toStringAsFixed(2) ?? '';
      controller.taxGroupController.text = item.taxGroup ?? '';
      controller.categoryController.text = item.expenseCategoryId ?? '';
      controller.uomId.text = '';
      controller.isReimbursable = item.isReimbursable ?? false;
      controller.isBillableCreate = item.isBillable ?? false;
      if (controller.categoryController.text.isNotEmpty) {
        final matchingCategory = controller.expenseCategory.firstWhere(
          (e) => e.categoryId == controller.categoryController.text,
          orElse: () => this.controller.expenseCategory.first,
        );
        print("matchingCategory$matchingCategory");
        controller.selectedCategory = matchingCategory;

        controller.itemisationMandatory.value =
            matchingCategory.itemisationMandatory;

        controller.minExpenseAmount.value =
            (matchingCategory.minExpensesAmount ?? 0).toDouble();

        controller.maxExpenseAmount.value =
            (matchingCategory.maxExpenseAmount ?? 0).toDouble();

        controller.receiptRequiredLimit.value =
            (matchingCategory.receiptRequiredLimit ?? 0).toDouble();
      }
      itemizeControllers = [controller];
      _itemizeCount = 1;
      _addItemize();
      return;
    }
    itemizeControllers = widget.items.expenseTrans.map((item) {
      final controller = Controller();
      controller.recIDItem = item.recId;
      controller.projectDropDowncontroller.text = item.projectId ?? '';
      controller.descriptionController.text = item.description ?? '';
      controller.quantity.text = item.quantity.toStringAsFixed(2);
      controller.unitPriceTrans.text = item.unitPriceTrans.toStringAsFixed(2);
      controller.lineAmount.text = item.lineAmountTrans.toStringAsFixed(2);
      controller.lineAmountINR.text = item.lineAmountReporting.toStringAsFixed(
        2,
      );
      controller.taxAmount.text = item.taxAmount.toStringAsFixed(2);
      controller.taxGroupController.text = item.taxGroup ?? '';
      controller.categoryController.text = item.expenseCategoryId;
      controller.uomId.text = item.uomId;
      controller.isReimbursable = item.isReimbursable;
      controller.isBillableCreate = item.isBillable;

      if (item.accountingDistributions != null) {
        controller.split = (item.accountingDistributions ?? []).map((dist) {
          return AccountingSplit(
            paidFor: dist.dimensionValueId ?? '',
            percentage: dist.allocationFactor ?? 0.0,
            amount: dist.transAmount ?? 0.0,
          );
        }).toList();
      }
      if (item.accountingDistributions != null) {
        controller.accountingDistributions.clear();
        controller.accountingDistributions.addAll(
          item.accountingDistributions.map((dist) {
            return AccountingDistribution(
              transAmount: dist.transAmount ?? 0.0,
              reportAmount: dist.reportAmount ?? 0.0,
              allocationFactor: dist.allocationFactor ?? 0.0,
              dimensionValueId: dist.dimensionValueId ?? '',
              recId: dist.recId,
            );
          }),
        );
        // print('--- AccountingDistributions Added ---');
        for (var dist in controller.accountingDistributions) {
          // print(
          //   'TransAmount: ${dist?.transAmount}, ReportAmount: ${dist?.recId}, '
          //   'AllocationFactor: ${dist?.allocationFactor}, DimensionValueId: ${dist?.dimensionValueId}',
          // );
        }
        // print('--------------------------------------');
      }

      return controller;
    }).toList();
    _itemizeCount = widget.items.expenseTrans.length;
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
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: "${AppLocalizations.of(context)!.expenseId} *",
                          controller: expenseIdController,
                          isReadOnly: false,
                        ),

                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeId} *",
                          controller: controller.employeeIdController,
                          isReadOnly: false,
                        ),
                        _buildTextField(
                          label:
                              "${AppLocalizations.of(context)!.employeeName} *",
                          controller: controller.employeeName,
                          isReadOnly: false,
                        ),
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

                        const SizedBox(height: 18),
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
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                    ],
                                                  );
                                                })
                                                .toList(),
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
                                                setState(() {
                                                  itemController
                                                          .selectedCategory =
                                                      p;
                                                  itemController
                                                          .selectedCategoryId =
                                                      p!.categoryId;
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
                                                          .items
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
                        'dd-MM-yyyy',
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
                    controllers.text = DateFormat('dd-MM-yyyy').format(picked);
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
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat('dd-MM-yyyy').format(item.createdDate)}',
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
