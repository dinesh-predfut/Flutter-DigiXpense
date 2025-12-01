import 'dart:async';
import 'dart:io';

import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

import '../../../../../core/comman/widgets/multiselectDropdown.dart';

class UnprocessEditExpensePage extends StatefulWidget {
  final bool isReadOnly;
  final UnprocessExpenseModels items;
  const UnprocessEditExpensePage({
    Key? key,
    required this.items,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  State<UnprocessEditExpensePage> createState() => _UnprocessEditExpensePageState();
}

class _UnprocessEditExpensePageState extends State<UnprocessEditExpensePage>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
Rxn<File> profileImage = Rxn<File>();
  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  late Future<List<ExpenseHistory>> historyFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _showHistory = false;
  bool allowMultSelect = false;
  int _currentIndex = 0;
  late PageController _pageController;
  // New state variables for itemize management
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    print("widget.isReadOnly${widget.isReadOnly}");
    expenseIdController.text = "";
    receiptDateController.text = "";
    merhantName.text = "";
    // _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );
   controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchExpenseCategory();
      controller.fetchUnit();
      controller.fetchTaxGroup();
      controller.currencyDropDown();
    // controller.fetchExchangeRate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateAmounts(widget.items!.exchRate.toString());
      controller.fetchExpenseDocImage(widget.items.recId);
   

      _loadSettings();
    });
    historyFuture = controller.fetchExpenseHistory(widget.items!.recId);
    final formatted = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.items!.receiptDate);
    controller.selectedDate = widget.items!.receiptDate;
    receiptDateController.text = formatted;
    if (widget.items != null && widget.items!.paymentMethod != null) {
      controller.paymentMethodID = widget.items!.paymentMethod.toString();
    }

    expenseIdController.text = widget.items!.expenseId.toString();
    receiptDateController.text = formatted;
    if (widget.items?.merchantId == null) {
      print("merchantIdfalse");
      controller.isManualEntryMerchant = true;
    } else {
      controller.isManualEntryMerchant = false;
      print("merchantIdtrue");
    }

    controller.paidToController.text =
        widget.items?.merchantId?.toString() ?? '';

    print('--- AccountingDistributions Added ---');
    controller.referenceID.text =
        widget.items?.referenceNumber?.toString() ?? '';
    if (widget.items != null && widget.items!.paymentMethod != null) {
      controller.paidWithController.text = widget.items!.paymentMethod!;
    } else {
      controller.paidWithController.text = ''; // or set a default value
    }

    selectedPaidWith = paidWithOptions.first;
    controller.paidAmount.text = widget.items!.totalAmountTrans.toStringAsFixed(
      2,
    );
    controller.unitAmount.text = widget.items!.totalAmountTrans.toStringAsFixed(
      2,
    );
    controller.unitRate.text = widget.items!.exchRate.toStringAsFixed(2);
    controller.cashAdvReqIds = widget.items.cashAdvReqId;
    // calculateAmounts(controller.exchangeRate.text);
    controller.amountINR.text = widget.items!.totalAmountReporting
        .toStringAsFixed(2);
    controller.expenseID = widget.items!.expenseId;
    controller.recID =
        widget.items!.recId ?? widget.items!.unprocessedRecId ?? null;

    controller.isBillableCreate = widget.items!.isBillable;
    if (widget.items!.merchantId == null) {
      controller.manualPaidToController.text = widget.items!.merchantName!;
    } else {
      controller.paidToController.text = widget.items.merchantName!;
    }
    controller.currencyDropDowncontroller.text = widget.items!.currency
        .toString();

    // Initialize itemize controllers
    _initializeItemizeControllers();

    _initializeData();
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
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        print("allowDocAttachments$allowMultSelect");
        // isLoading = false;
      });
    } else {
      // setState(() => isLoading = false);
    }
  }

  Future<void> _updateAllLineItems() async {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      _calculateTotalLineAmount(itemController).toStringAsFixed(2);
      // Recalculate base + INR amounts
      controller.calculateLineAmounts(itemController);

      final lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
      final lineAmountInINR = lineAmount * rate;

      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

      // // Sync with model
      widget.items!.expenseTrans[i] = itemController.toExpenseItemUpdateModel();
    }

    setState(() {}); // only if you rely on UI state updates
  }

  double _calculateTotalLineAmount(Controller controllers) {
    double total = 0.0;

    // add current line amount
    final currentLineAmount =
        double.tryParse(controllers.lineAmount.text) ?? 0.0;
    total += currentLineAmount;

    // add other itemized line amounts
    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
        total += amount;
      }
    }

    // update Paid Amount
    controller.paidAmount.text = total.toStringAsFixed(2);

    // calculate INR amount immediately
    final paid = total;
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    controller.amountINR.text = (paid * rate).toStringAsFixed(2);

    return total;
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();

      // Create a Set of existing IDs
      final existingIds = controller.cashAdvanceListDropDown
          .map((e) => e.cashAdvanceReqId)
          .toSet();

      // Filter only new unique items
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

  void _initializeItemizeControllers() {
    if (widget.items!.expenseTrans.isEmpty) {
      print("expenseTransCalling");
      final item = widget.items!;
      final controller = Controller();

      controller.projectDropDowncontroller.text = item.projectId ?? '';
      controller.descriptionController.text = item.description ?? '';
      controller.quantity.text = '1'; // Default or appropriate fallback
      controller.unitPriceTrans.text =
          item.totalAmountTrans?.toStringAsFixed(2) ?? '';
      controller.lineAmount.text =
          item.totalAmountTrans?.toStringAsFixed(2) ?? '';
      controller.lineAmountINR.text =
          item.totalAmountReporting?.toStringAsFixed(2) ?? '';
      controller.taxAmount.text = item.taxAmount?.toStringAsFixed(2) ?? '';
      controller.taxGroupController.text = item.taxGroup ?? '';
      controller.categoryController.text = item.expenseCategoryId ?? '';
      controller.uomId.text = ''; // Set default or fallback
      controller.isReimbursable = item.isReimbursable ?? false;
      controller.isBillableCreate = item.isBillable ?? false;
      // Handle accountingDistributions if present, just like above...
      itemizeControllers = [controller];

      _itemizeCount = 1;
      _addItemize();
      return;
    }
    itemizeControllers = widget.items!.expenseTrans.map((item) {
      final controller = Controller();
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
        controller.accountingDistributions.clear(); // clear existing
        controller.accountingDistributions.addAll(
          item.accountingDistributions.map((dist) {
            return AccountingDistribution(
              transAmount: dist.transAmount ?? 0.0,
              reportAmount: dist.reportAmount ?? 0.0,
              allocationFactor: dist.allocationFactor ?? 0.0,
              dimensionValueId: dist.dimensionValueId ?? '',
              recId: dist.recId,
              // currency: dist.currency
              // recId: dist.recId ?? 0,
            );
          }),
        );
        print('--- AccountingDistributions Added ---');
        for (var dist in controller.accountingDistributions) {
          print(
            'TransAmount: ${dist?.transAmount}, ReportAmount: ${dist?.recId}, '
            'AllocationFactor: ${dist?.allocationFactor}, DimensionValueId: ${dist?.dimensionValueId}',
          );
        }
        print('--------------------------------------');
      }
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

  void calculateAmounts(String rateStr) {
    final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
    final rate = double.tryParse(rateStr) ?? 1.0;

    // Perform calculation
    final result = paid * rate;
    controller.amountINR.text = result.toStringAsFixed(2);
    controller.isVisible.value = true;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      final unitPrice =
          double.tryParse(itemController.unitPriceTrans.text) ?? 0.0;

      // final lineAmountInINR = unitPrice * rate;
      // itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

      // Sync with the model
      widget.items!.expenseTrans[i] = itemController.toExpenseItemUpdateModel();
    }
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        // Create new ExpenseItem with default values
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
        // debugPrint("Added new item: ${newItem.toStringAsFixed(2)}");

        widget.items!.expenseTrans.add(newItem);

        // Create and initialize new controller
        final newController = Controller();

        // Initialize controller with default values
        // newController.descriptionController.text = newItem.description ?? '';
        // newController.quantity.text = newItem.quantity.toStringAsFixed(2);
        // newController.unitPriceTrans.text = newItem.unitPriceTrans.toStringAsFixed(2);
        // newController.lineAmount.text = newItem.lineAmountTrans.toStringAsFixed(2);
        // newController.lineAmountINR.text = newItem.lineAmountReporting
        //     .toStringAsFixed(2);
        // newController.taxAmount.text = newItem.taxAmount.toStringAsFixed(2);
        // newController.projectDropDowncontroller.text = newItem.projectId ?? '';
        // newController.categoryController.text = newItem.expenseCategoryId;
        // newController.uomId.text = newItem.uomId;
        // newController.taxGroupController.text = newItem.taxGroup ?? '';
        // newController.isReimbursable = newItem.isReimbursable;
        // newController.isBillableCreate = newItem.isBillable;

        // Set dropdown selections if available
        // if (controller.project.isNotEmpty) {
        //   newController.selectedProject = controller.project.firstWhere(
        //     (p) => p.code == newItem.projectId,
        //     orElse: () => controller.project.first,
        //   );
        // }

        // if (controller.expenseCategory.isNotEmpty) {
        //   newController.selectedCategory = controller.expenseCategory
        //       .firstWhere(
        //         (c) => c.categoryId == newItem.expenseCategoryId,
        //         orElse: () => controller.expenseCategory.first,
        //       );
        // }

        if (controller.unit.isNotEmpty) {
          newController.selectedunit = controller.unit.firstWhere(
            (u) => u.code == newItem.uomId,
            orElse: () => controller.unit.first,
          );
        }

        // if (controller.taxGroup.isNotEmpty) {
        //   newController.selectedTax = controller.taxGroup.firstWhere(
        //     (t) => t.taxGroupId == newItem.taxGroup,
        //     orElse: () => controller.taxGroup.first,
        //   );
        // }

        debugPrint(
          "Controller added with unit: ${newController.selectedunit?.name}",
        );

        // Add to controllers list (new reference for rebuild)
        itemizeControllers = List.from(itemizeControllers)..add(newController);

        // Update counters
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
    return WillPopScope(
      onWillPop: () async {
        if (!controller.isEnable.value) {
          controller.clearFormFields();
          return true;
        }

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
          // ✅ Run your original logic only if user confirms
          controller.clearFormFields();
          controller.isEnable.value = false;
          controller.isLoadingviewImage.value = false;

          // Optional: Conditional navigation
          // if(widget.isReadOnly){
          //   Navigator.pushNamed(context, AppRoutes.generalExpense);
          // } else {
          //   Navigator.pushNamed(context, AppRoutes.myTeamExpenseDashboard);
          // }

          Navigator.of(context).pop();
          return true; // allow back navigation
        }

        return false; // stay on the page
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
                widget.items != null &&
                widget.items!.approvalStatus != "Approved" &&
                widget.items!.approvalStatus != "Cancelled" &&
                widget.items!.approvalStatus != "Pending")
              if (widget.isReadOnly &&
                  widget.items != null &&
                  widget.items!.expenseStatus == "Draft")
                Obx(() {
                  // ✅ Now Obx only rebuilds for controller.isEnable.value
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
          return controller.isLoadingviewImage.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => {
                            if (controller.imageFiles.isEmpty)
                              {_pickImage(ImageSource.gallery)},
                          },
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width *
                                0.9, // 90% of screen width
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
                        // _buildTextField(
                        //   label:
                        //       "${AppLocalizations.of(context)!.employeeName} *",
                        //   controller: controller.employeeName,
                        //   isReadOnly: false,
                        // ),
                        //  buildTextField(
                        //   "${loc.employeeName} *",
                        //   controller.employeeName,
                        //   readOnly: true,
                        // ),
                        buildDateField(
                          '${AppLocalizations.of(context)!.receiptDate} *',
                          receiptDateController,
                          isReadOnly: !controller.isEnable.value,
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
                                          controller
                                              .paidToController
                                              .text
                                              .isEmpty
                                          ? AppLocalizations.of(
                                              context,
                                            )!.fieldRequired
                                          : null,
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
                                validator: (value) =>
                                    controller
                                        .manualPaidToController
                                        .text
                                        .isEmpty
                                    ? AppLocalizations.of(
                                        context,
                                      )!.fieldRequired
                                    : null,
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
                                      : null, // 🔥 disables the toggle button if not enabled
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
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Container(
                                // padding: const EdgeInsets.all(12),
                                // margin: const EdgeInsets.only(bottom: 16),
                                // decoration: BoxDecoration(
                                //   color: Colors.white,
                                //   border: Border.all(
                                //     color: Colors.grey.shade400,
                                //     width: 1,
                                //   ),
                                //   borderRadius: BorderRadius.circular(12),
                                //   boxShadow: [
                                //     BoxShadow(
                                //       color: Colors.black.withOpacity(0.05),
                                //       blurRadius: 6,
                                //       offset: const Offset(0, 3),
                                //     ),
                                //   ],
                                // ),
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
                                      // validator: (proj) => proj == null
                                      //     ? AppLocalizations.of(
                                      //         context,
                                      //       )!.pleaseSelectCashAdvanceField
                                      //     : null,
                                      onChanged: (item) {
                                        controller.singleSelectedItem =
                                            item; // ✅ update selected item
                                      },
                                      onMultiChanged: (items) {
                                        controller.multiSelectedItems.assignAll(
                                          items,
                                        ); // ✅ update list
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
                              validator: (_) => null,
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
                        _buildTextField(
                          label: AppLocalizations.of(context)!.referenceId,
                          controller: controller.referenceID,
                          isReadOnly: controller.isEnable.value,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                controller: controller.paidAmount,
                                onChanged: (_) {
                                  // controller.fetchExchangeRate();

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
                                  ), // Only digits and dots allowed
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
                                      validator: (c) =>
                                          controller
                                              .currencyDropDowncontroller
                                              .text
                                              .isEmpty
                                          ? AppLocalizations.of(
                                              context,
                                            )!.pleaseSelectCurrency
                                          : null,
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
                                onChanged: (val) {
                                  // Fetch exchange rate if needed
                                  // controller.fetchExchangeRate();

                                  final paid =
                                      double.tryParse(
                                        controller.paidAmount.text,
                                      ) ??
                                      0.0;
                                  final rate = double.tryParse(val) ?? 1.0;

                                  // ✅ Perform calculation
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
                                    // controller
                                    // .calculateLineAmounts(itemController);
                                    final unitPrice =
                                        double.tryParse(
                                          itemController.unitPriceTrans.text,
                                        ) ??
                                        0.0;

                                    final lineAmountInINR = unitPrice * rate;
                                    itemController.lineAmountINR.text =
                                        lineAmountInINR.toStringAsFixed(2);

                                    // Sync with the model
                                    widget.items!.expenseTrans[i] =
                                        itemController
                                            .toExpenseItemUpdateModel();
                                  }

                                  // ✅ Trigger UI update
                                  setState(() {});
                                  print("Paid Amount: $paid");
                                  print("Rate: $rate");
                                  print(
                                    "Calculated INR Amount: ${controller.amountINR.text}",
                                  );
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
                                '${AppLocalizations.of(context)!.amountInInr} *',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Modified Itemized Expenses Section
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
                                // final unitRates =
                                //     double.tryParse(controller.unitRate.text) ??
                                //         0.0;
                                // final unitRate = double.tryParse(
                                //         controller.lineAmount.text) ??
                                //     0.0;
                                // print("unitRates$unitRates");
                                // final cal = unitRates * unitRate;
                                // itemController.lineAmountINR.text =
                                //     cal.toStringAsFixed(2);
                                // _calculateTotalLineAmount(itemController)
                                //     .toStringAsFixed(2);
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
                                                    future: controller
                                                        .getAllFeatureStates(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const SizedBox.shrink(); // nothing while loading
                                                      }

                                                      if (!snapshot.hasData) {
                                                        return const SizedBox.shrink(); // hide if API fails
                                                      }

                                                      final featureStates =
                                                          snapshot.data!;
                                                      final isEnabled =
                                                          featureStates['EnableItemization'] ??
                                                          false;

                                                      // ❌ hide button completely if feature disabled
                                                      if (!isEnabled)
                                                        return const SizedBox.shrink();

                                                      // ✅ show button if enabled
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
                                            SearchableMultiColumnDropdownField<
                                              Project
                                            >(
                                              enabled:
                                                  controller.isEnable.value,
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.projectId,
                                              columnHeaders: const [
                                                'Project Name',
                                                'Project ID',
                                              ],
                                              items: controller.project,
                                              selectedValue: itemController
                                                  .selectedProject,
                                              searchValue: (p) =>
                                                  '${p.name} ${p.code}',
                                              displayText: (p) => p.code,
                                              validator: (_) => null,
                                              onChanged: (p) {
                                                setState(() {
                                                  controller.selectedProject =
                                                      p;
                                                  itemController
                                                          .selectedProject =
                                                      p; // update controller state
                                                  controller
                                                      .projectDropDowncontroller
                                                      .text = p!
                                                      .code;
                                                  widget
                                                          .items!
                                                          .expenseTrans[index] =
                                                      itemController
                                                          .toExpenseItemUpdateModel(); // sync with parent list
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
                                                        child: Text(p.name),
                                                      ),
                                                      Expanded(
                                                        child: Text(p.code),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
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
                                              validator: (_) => null,
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
                                              displayText: (tax) => tax.code,
                                              validator: (tax) =>
                                                  itemController
                                                      .uomId
                                                      .text
                                                      .isEmpty
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.pleaseSelectUnit
                                                  : null,
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
                                                ), // Allows numbers with up to 2 decimal places
                                              ],
                                              label:
                                                  "${AppLocalizations.of(context)!.quantity} *",
                                              controller:
                                                  itemController.quantity,
                                              isReadOnly:
                                                  controller.isEnable.value,
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
                                                ), // Allows numbers with up to 2 decimal places
                                              ],
                                              label:
                                                  "${AppLocalizations.of(context)!.unitAmount} *",
                                              controller:
                                                  itemController.unitPriceTrans,
                                              isReadOnly:
                                                  controller.isEnable.value,

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
                                                          .items!
                                                          .expenseTrans[index],
                                                    );
                                                // setState(() {
                                                //   itemController
                                                //       .lineAmount.text = value;
                                                //   widget.items!
                                                //           .expenseTrans[index] =
                                                //       itemController
                                                //           .toExpenseItemUpdateModel();
                                                // });
                                              },
                                            ),
                                            _buildTextField(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.lineAmountInInr,
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
                                            SearchableMultiColumnDropdownField<
                                              TaxGroupModel
                                            >(
                                              enabled:
                                                  controller.isEnable.value,
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.taxGroup,
                                              columnHeaders: [
                                                AppLocalizations.of(
                                                  context,
                                                )!.taxGroup,
                                                AppLocalizations.of(
                                                  context,
                                                )!.taxId,
                                              ],
                                              items: controller.taxGroup,
                                              selectedValue:
                                                  itemController.selectedTax,
                                              searchValue: (tax) =>
                                                  '${tax.taxGroup} ${tax.taxGroupId}',
                                              displayText: (tax) =>
                                                  tax.taxGroupId,
                                              onChanged: (tax) {
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
                                              },
                                              controller: itemController
                                                  .taxGroupController,
                                              rowBuilder: (tax, searchQuery) {
                                                return Container(
                                                  // color: Colors.grey[300],
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
                                            ),
                                            const SizedBox(height: 12),
                                            _buildTextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'),
                                                ), // Allows numbers with up to 2 decimal places
                                              ],
                                              label: AppLocalizations.of(
                                                context,
                                              )!.taxAmount,
                                              controller:
                                                  itemController.taxAmount,
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
                                            const SizedBox(height: 12),
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                switchTheme: SwitchThemeData(
                                                  thumbColor:
                                                      WidgetStateProperty.resolveWith<
                                                        Color?
                                                      >((states) {
                                                        final isSelected =
                                                            states.contains(
                                                              WidgetState
                                                                  .selected,
                                                            );
                                                        if (states.contains(
                                                          WidgetState.disabled,
                                                        )) {
                                                          // Keep same thumb color only if selected (true)
                                                          return isSelected
                                                              ? Colors.green
                                                              : null;
                                                        }
                                                        // Text thumb only if true (selected)
                                                        return isSelected
                                                            ? Colors.green
                                                            : null;
                                                      }),
                                                  trackColor:
                                                      WidgetStateProperty.resolveWith<
                                                        Color?
                                                      >((states) {
                                                        final isSelected =
                                                            states.contains(
                                                              WidgetState
                                                                  .selected,
                                                            );
                                                        if (states.contains(
                                                          WidgetState.disabled,
                                                        )) {
                                                          // Keep same track color with opacity only if selected (true)
                                                          return isSelected
                                                              ? Colors.green
                                                                // ignore: deprecated_member_use
                                                                .withOpacity(
                                                                  0.5,
                                                                )
                                                              : null;
                                                        }
                                                        // Text track only if true (selected)
                                                        return isSelected
                                                            ? Colors.green
                                                              // ignore: deprecated_member_use
                                                              .withOpacity(0.5)
                                                            : null;
                                                      }),
                                                ),
                                              ),
                                              child: SwitchListTile(
                                                title: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.isReimbursable,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                value: itemController
                                                    .isReimbursable,
                                                onChanged:
                                                    controller.isEnable.value
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
                                                                  .expenseTrans[index] =
                                                              itemController
                                                                  .toExpenseItemUpdateModel();
                                                        });
                                                      }
                                                    : null, // disabled but keeps colors as per theme
                                              ),
                                            ),

                                            Obx(
                                              () => Theme(
                                                data: Theme.of(context).copyWith(
                                                  switchTheme: SwitchThemeData(
                                                    thumbColor:
                                                        MaterialStateProperty.resolveWith<
                                                          Color?
                                                        >((states) {
                                                          if (states.contains(
                                                            MaterialState
                                                                .disabled,
                                                          )) {
                                                            return controller
                                                                    .isBillableCreate
                                                                ? Colors.blue
                                                                : Colors
                                                                      .grey
                                                                      .shade400;
                                                          }
                                                          if (states.contains(
                                                            MaterialState
                                                                .selected,
                                                          )) {
                                                            return Colors.blue;
                                                          }
                                                          return Colors
                                                              .grey
                                                              .shade400;
                                                        }),
                                                    trackColor:
                                                        MaterialStateProperty.resolveWith<
                                                          Color?
                                                        >((states) {
                                                          if (states.contains(
                                                            MaterialState
                                                                .disabled,
                                                          )) {
                                                            return controller
                                                                    .isBillableCreate
                                                                ? Colors.blue
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
                                                            return Colors.blue
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
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  value: controller
                                                      .isBillableCreate,
                                                  onChanged:
                                                      controller.isEnable.value
                                                      ? (val) {
                                                          setState(() {
                                                            widget
                                                                    .items!
                                                                    .expenseTrans[index] =
                                                                itemController
                                                                    .toExpenseItemUpdateModel();
                                                            controller
                                                                    .isBillableCreate =
                                                                val;
                                                            itemController
                                                                    .isBillableCreate =
                                                                val;
                                                          });
                                                        }
                                                      : null, // disabled but still keeps color
                                                ),
                                              ),
                                            ),
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
                        // const SizedBox(height: 10),
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
                                    child: Text('Error: ${snapshot.error}'),
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
                            widget.items!.approvalStatus == "Rejected" &&
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
                                  ), // Purple gradient replaced
                                ),
                                onPressed: (isResubmitLoading || isAnyLoading)
                                    ? null
                                    : () {
                                        controller.setButtonLoading(
                                          'resubmit',
                                          true,
                                        );
                                        controller.addToFinalItemsUnProcess(
                                          widget.items!,
                                        );
                                        if (widget.items.unprocessedRecId !=
                                            null) {
                                          controller
                                              .saveinviewPageGeneralExpense(
                                                context,
                                                true,
                                                true,
                                                widget.items!.unprocessedRecId!,
                                              )
                                              .whenComplete(() {
                                                controller.setButtonLoading(
                                                  'resubmit',
                                                  false,
                                                );
                                              });
                                        } else {
                                             controller.addToFinalItemsUnProcess(
                                                widget.items,
                                              );
                                              if (widget
                                                      .items
                                                      .unprocessedRecId !=
                                                  null) {
                                                controller
                                                    .saveinviewPageGeneralExpenseUnProcess(
                                                      context,
                                                      true,
                                                      true,
                                                      widget
                                                          .items!
                                                          .unprocessedRecId!,
                                                    )
                                                    .whenComplete(() {
                                                      controller
                                                          .setButtonLoading(
                                                            'submit',
                                                            false,
                                                          );
                                                      controller
                                                          .setButtonLoading(
                                                            'saveGE',
                                                            false,
                                                          );
                                                    });
                                              } else {
                                                 controller
                                            .addToFinalItemsUnProcess(widget.items!);
                                        controller
                                            .saveinviewPageGeneralExpense(
                                                context,
                                                true,
                                                true,
                                                widget.items!.recId!)
                                            .whenComplete(() {
                                          controller.setButtonLoading(
                                              'submit', false);
                                        });
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
                            widget.items!.approvalStatus == "Rejected" &&
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
                                            controller.setButtonLoading(
                                              'update',
                                              true,
                                            );
                                            controller.addToFinalItemsUnProcess(
                                              widget.items!,
                                            );
                                            controller
                                                .saveinviewPageGeneralExpense(
                                                  context,
                                                  false,
                                                  false,
                                                  widget.items!.recId!,
                                                )
                                                .whenComplete(() {
                                                  controller.setButtonLoading(
                                                    'update',
                                                    false,
                                                  );
                                                });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFF1E7503,
                                      ), // Green button
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
                            widget.items!.approvalStatus == "Created" &&
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
                                        if (_formKey.currentState!.validate()) {
                                          controller.setButtonLoading(
                                            'submit',
                                            true,
                                          );
                                          // controller.addToFinalItemsUnProcess(
                                          //   widget.items!,
                                          // );
                                        //   if (widget.items.unprocessedRecId !=
                                        //       null) {
                                        //     controller
                                        //         .saveinviewPageGeneralExpenseUnProcess(
                                        //           context,
                                        //           true,
                                        //           true,
                                        //           widget
                                        //               .items!
                                        //               .unprocessedRecId!,
                                        //         )
                                        //         .whenComplete(() {
                                        //           controller.setButtonLoading(
                                        //             'submit',
                                        //             false,
                                        //           );
                                        //           controller.setButtonLoading(
                                        //             'saveGE',
                                        //             false,
                                        //           );
                                        //         });
                                        //   } else {
                                        //      controller
                                        //     .addToFinalItemsUnProcess(widget.items!);
                                        // controller
                                        //     .saveinviewPageGeneralExpense(
                                        //         context,
                                        //         true,
                                        //         false,
                                        //         widget.items!.recId!)
                                        //     .whenComplete(() {
                                        //   controller.setButtonLoading(
                                        //       'submit', false);
                                        // });
                                         
                                        //     }
                                         controller
                                            .addToFinalItemsUnProcess(widget.items!);
                                       controller
                                                .saveinviewPageGeneralExpenseUnProcess(
                                                  context,
                                                  true,
                                                  true,
                                                  widget
                                                      .items!
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
                                                });}
                                          
                                          
                                        
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
                              // 🟢 Save Button
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
                                                .validate()) {
                                              controller.setButtonLoading(
                                                'saveGE',
                                                true,
                                              );
                                        //       controller.addToFinalItemsUnProcess(
                                        //         widget.items,
                                        //       );
                                        //       if (widget
                                        //               .items
                                        //               .unprocessedRecId !=
                                        //           null) {
                                        //         controller
                                        //             .saveinviewPageGeneralExpenseUnProcess(
                                        //               context,
                                        //               true,
                                        //               true,
                                        //               widget
                                        //                   .items!
                                        //                   .unprocessedRecId!,
                                        //             )
                                        //             .whenComplete(() {
                                        //               controller
                                        //                   .setButtonLoading(
                                        //                     'submit',
                                        //                     false,
                                        //                   );
                                        //               controller
                                        //                   .setButtonLoading(
                                        //                     'saveGE',
                                        //                     false,
                                        //                   );
                                        //             });
                                        //       } else {
                                        //         controller.addToFinalItemsUnProcess(
                                        //         widget.items,
                                        //       );
                                        //       if (widget
                                        //               .items
                                        //               .unprocessedRecId !=
                                        //           null) {
                                        //         controller
                                        //             .saveinviewPageGeneralExpenseUnProcess(
                                        //               context,
                                        //               true,
                                        //               true,
                                        //               widget
                                        //                   .items!
                                        //                   .unprocessedRecId!,
                                        //             )
                                        //             .whenComplete(() {
                                        //               controller
                                        //                   .setButtonLoading(
                                        //                     'submit',
                                        //                     false,
                                        //                   );
                                        //               controller
                                        //                   .setButtonLoading(
                                        //                     'saveGE',
                                        //                     false,
                                        //                   );
                                        //             });
                                        //       } else {
                                        //          controller
                                        //     .addToFinalItemsUnProcess(widget.items!);
                                        // controller
                                        //     .saveinviewPageGeneralExpense(
                                        //         context,
                                        //         false,
                                        //         false,
                                        //         widget.items!.recId!)
                                        //     .whenComplete(() {
                                        //   controller.setButtonLoading(
                                        //       'submit', false);
                                        // });
                                        //       }
                                            // }
                                             controller
                                            .addToFinalItemsUnProcess(widget.items!);
                                        // controller
                                        //     .saveinviewPageGeneralExpense(
                                        //         context,
                                        //         false,
                                        //         false,
                                        //         widget.items!.recId!)
                                        //     .whenComplete(() {
                                        //   controller.setButtonLoading(
                                        //       'submit', false);
                                        // });
                                         controller
                                                .saveinviewPageGeneralExpenseUnProcess(
                                                  context,
                                                  false,
                                                  false,
                                                  widget
                                                      .items!
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
                                          
                                          }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFF1E7503,
                                      ), // Green button
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

                              // 🟠 Cancel Button
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
                          // Add space before Submit button

                          // 🟣 Submit Button
                        ],

                        if (widget.items!.approvalStatus == "Pending" &&
                            widget.isReadOnly)
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
                                                  widget.items!.recId
                                                      .toString(),
                                                )
                                                .whenComplete(() {
                                                  controller.setButtonLoading(
                                                    'cancel',
                                                    false,
                                                  );
                                                });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFFE99797,
                                      ), // Red cancel button
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
                            child: Text(AppLocalizations.of(context)!.cancel),
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
    barrierColor: Colors.black.withOpacity(0.9), // darker transparent background
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
                onPressed: () => Navigator.pop(context),
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

  Widget buildDateField(
    String label,
    TextEditingController controllers, {
    required bool isReadOnly,
  }) {
    return TextFormField(
      controller: controllers,
      readOnly: true, // Always readonly because we use the calendar
      enabled: !isReadOnly, // Disable editing if readonly
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: isReadOnly
              ? null // Disable button if readonly
              : () async {
                  // 🟢 Use controllers.text for initialDate or fallback
                  DateTime initialDate = DateTime.now();
                  if (controllers.text.isNotEmpty) {
                    try {
                      initialDate =
                          DateFormat('dd-MM-yyyy') // Adjust your format
                              .parseStrict(controllers.text.trim());
                    } catch (e) {
                      print("Invalid date format: ${controllers.text}");
                      initialDate = DateTime.now(); // fallback
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
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
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
    TextInputType keyboardType = TextInputType.text, // default to text
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
          keyboardType: keyboardType, // set keyboard type here
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
            // backgroundColor: Colors.white,
            // collapsedBackgroundColor: Colors.white,
            // textColor: Colors.deepPurple,
            // iconColor: Colors.deepPurple,
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
