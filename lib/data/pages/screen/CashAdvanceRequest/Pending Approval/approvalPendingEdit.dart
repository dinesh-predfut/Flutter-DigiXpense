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

import '../../../../../l10n/app_localizations.dart';

class ApprovalViewEditExpensePage extends StatefulWidget {
  final bool isReadOnly;
  final GESpeficExpense? items;
  const ApprovalViewEditExpensePage({
    Key? key,
    this.items,
    required this.isReadOnly,
  }) : super(key: key);

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

  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  Future<List<ExpenseHistory>>? historyFuture;
  int _currentIndex = 0;
  late PageController _pageController;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _showHistory = false;
  late int workitemrecid;
  // New state variables for itemize management
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];

  @override
  void initState() async {
    super.initState();
    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );
    expenseIdController.text = "";
    receiptDateController.text = "";
    employeeName.text = "";
    employyeID.text = "";
    merhantName.text = "";
    controller.fetchPaidto();
    controller.fetchPaidwith();
    controller.fetchProjectName();
    controller.fetchExpenseCategory();
    controller.fetchUnit();
    controller.fetchTaxGroup();
    controller.currencyDropDown();
    await controller.fetchExchangeRate();
    controller.fetchUsers();
    controller.fetchExpenseDocImage(widget.items!.recId);
    initializeCashAdvanceSelection();
    historyFuture = controller.fetchExpenseHistory(widget.items!.recId);
    final formatted = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.items!.receiptDate);
    controller.selectedDate = widget.items!.receiptDate;
    receiptDateController.text = formatted;
    employeeName.text = widget.items!.employeeName!;
    employyeID.text = widget.items!.employeeId!;
    controller.paymentMethodID = widget.items!.paymentMethod.toString();
    expenseIdController.text = widget.items!.expenseId.toString();
    receiptDateController.text = formatted;
    controller.paidToController.text = widget.items!.merchantName.toString();
    controller.paidWithController.text = widget.items!.paymentMethod!;
    referenceController.text = widget.items!.referenceNumber.toString();
    selectedPaidTo = paidToOptions.first;
    selectedPaidWith = paidWithOptions.first;
    controller.paidAmount.text = widget.items!.totalAmountTrans.toString();
    controller.unitAmount.text = widget.items!.totalAmountTrans.toString();
    controller.unitRate.text = widget.items!.exchRate.toString();
    controller.amountINR.text = widget.items!.totalAmountReporting.toString();
    controller.expenseID = widget.items!.expenseId;
    controller.recID = widget.items!.recId;
    workitemrecid = widget.items!.workitemrecid!;
    controller.currencyDropDowncontroller.text = widget.items!.currency
        .toString();

    // Initialize itemize controllers
    _initializeItemizeControllers();
  }

  void initializeCashAdvanceSelection() {
    String? backendSelectedIds = controller.cashAdvReqIds;
    print("controller.cashAdvReqIds$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
      controller.cashAdvanceListDropDown,
      backendSelectedIds,
    );
  }

  void _initializeItemizeControllers() {
    itemizeControllers = widget.items!.expenseTrans.map((item) {
      final controller = Controller();
      controller.projectDropDowncontroller.text = item.projectId ?? '';
      controller.descriptionController.text = item.description ?? '';
      controller.quantity.text = item.quantity.toString();
      controller.unitAmountView.text = item.unitPriceTrans.toString();
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
        // Create new ExpenseItem with default values
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

        // Create and initialize new controller
        final newController = Controller();

        // Initialize controller with default values
        newController.descriptionController.text = newItem.description ?? '';
        newController.quantity.text = newItem.quantity.toString();
        newController.unitAmountView.text = newItem.unitPriceTrans.toString();
        newController.lineAmount.text = newItem.lineAmountTrans.toString();
        newController.lineAmountINR.text = newItem.lineAmountReporting
            .toString();
        newController.taxAmount.text = newItem.taxAmount.toString();
        newController.projectDropDowncontroller.text = newItem.projectId ?? '';
        newController.categoryController.text = newItem.expenseCategoryId;
        newController.uomId.text = newItem.uomId;
        newController.taxGroupController.text = newItem.taxGroup ?? '';
        newController.isReimbursite = newItem.isReimbursable;
        newController.isBillable.value = newItem.isBillable;

        // Set dropdown selections if available
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
        controller.isEnable.value = false;
        controller.isLoadingGE1.value = false;
        controller.isApprovalEnable.value = false;
        Navigator.pushNamed(context, AppRoutes.approvalDashboard);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            (controller.isEnable.value || controller.isApprovalEnable.value)
                ? 'Edit Expense Approval'
                : 'View Expense Approval',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            if (widget.isReadOnly &&
                widget.items != null &&
                widget.items!.approvalStatus != "Cancelled" &&
                widget.items!.stepType != "Approval")
              IconButton(
                icon: const Icon(Icons.edit_document),
                onPressed: () {
                  setState(() {
                    controller.isEnable.value = true;
                  });
                },
              ),
            if (widget.isReadOnly &&
                widget.items != null &&
                widget.items!.stepType == "Approval")
              IconButton(
                icon: const Icon(Icons.edit_document),
                onPressed: () {
                  setState(() {
                    controller.isApprovalEnable.value = true;
                  });
                },
              ),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingviewImage.value
              ? const SkeletonLoaderPage()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: !controller.isEnable.value
                            ? null
                            : () => _pickImage(ImageSource.gallery),
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
                              return const Center(
                                child: Text('Tap to Upload Document(s)'),
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
                                      final file = controller.imageFiles[index];
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
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
                                  Positioned(
                                    top: 40,
                                    right: 20,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        controller.closeField();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
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
                      const Text(
                        "Receipt Details",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: "Expense ID *",
                        controller: expenseIdController,
                        isReadOnly: false,
                      ),
                      buildDateField(
                        "Receipt Date",
                        receiptDateController,
                        isReadOnly: !controller.isEnable.value, // pass manually
                      ),
                      _buildTextField(
                        label: "Employee Name",
                        controller: employeeName,
                        isReadOnly: false,
                      ),
                      _buildTextField(
                        label: "Employee",
                        controller: employyeID,
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
                                              !controller.isManualEntryMerchant;
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
                                      ? 'Select from Merchant List'
                                      : "Can't find merchant? Enter manually",
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // 👇 Conditional UI
                          if (!controller.isManualEntryMerchant)
                            AbsorbPointer(
                              absorbing: !controller
                                  .isEnable
                                  .value, // 🔥 disables dropdown
                              child:
                                  SearchableMultiColumnDropdownField<
                                    MerchantModel
                                  >(
                                    labelText: 'Select Merchant',
                                    columnHeaders: const [
                                      'Merchant Name',
                                      'Merchant ID',
                                    ],
                                    items: controller.paidTo,
                                    enabled: controller.isEnable.value,
                                    selectedValue: controller.selectedPaidto,
                                    searchValue: (p) =>
                                        '${p.merchantNames} ${p.merchantId}',
                                    displayText: (p) => p.merchantNames,
                                    validator: (_) => null,
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
                                            Expanded(child: Text(p.merchantId)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                            )
                          else
                            TextFormField(
                              controller: controller.manualPaidToController,
                              enabled: controller
                                  .isEnable
                                  .value, // 🔥 disables text field
                              decoration: InputDecoration(
                                labelText: 'Enter Merchant Name',
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
                      SearchableMultiColumnDropdownField<LocationModel>(
                        labelText: 'Cash Advance Request',
                        items: controller.location,
                        selectedValue: controller.selectedLocation,
                        enabled: controller.isEnable.value,
                        controller: controller.locationController,
                        searchValue: (proj) => '${proj.location}',
                        displayText: (proj) => proj.location,
                        validator: (proj) =>
                            proj == null ? 'Please select a Location' : null,
                        onChanged: (proj) {
                          controller.selectedLocation = proj;
                          controller.fetchPerDiemRates();
                        },
                        columnHeaders: const ['Request ID', 'Request Date'],
                        rowBuilder: (proj, searchQuery) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                // Expanded(child: Text(proj.location)),
                                // Expanded(child: Text(proj.country)),
                              ],
                            ),
                          );
                        },
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
                            labelText: 'Paid With',
                            columnHeaders: const ['Payment Name', 'Payment ID'],
                            items: controller.paymentMethods,
                            selectedValue: controller.selectedPaidWith,
                            searchValue: (p) =>
                                '${p.paymentMethodName} ${p.paymentMethodId}',
                            displayText: (p) => p.paymentMethodName,
                            validator: (_) => null,
                            onChanged: (p) {
                              setState(() {
                                controller.selectedPaidWith = p;
                                controller.paymentMethodeID =
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
                                    Expanded(child: Text(p.paymentMethodName)),
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
                        label: "Reference",
                        controller: referenceController,
                        isReadOnly: controller.isEnable.value,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              enabled: false,
                              controller: controller.paidAmount,
                              onChanged: (_) {
                                controller.fetchExchangeRate();

                                final paid =
                                    double.tryParse(
                                      controller.paidAmount.text,
                                    ) ??
                                    0.0;
                                final rate =
                                    double.tryParse(controller.unitRate.text) ??
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
                              decoration: const InputDecoration(
                                labelText: 'Paid Amount *',
                                border: OutlineInputBorder(
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
                                  SearchableMultiColumnDropdownField<Currency>(
                                    enabled: controller.isEnable.value,
                                    alignLeft: -90,
                                    dropdownWidth: 280,
                                    labelText: "",
                                    columnHeaders: const [
                                      'Code',
                                      'Name',
                                      'Symbol',
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
                                    validator: (c) => c == null
                                        ? 'Please pick a currency'
                                        : null,
                                    onChanged: (c) {
                                      controller.selectedCurrency.value = c;
                                      controller.fetchExchangeRate();
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
                                labelText: 'Rate *',
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
                                  final itemController = itemizeControllers[i];
                                  final unitPrice =
                                      double.tryParse(
                                        itemController.unitPriceTrans.text,
                                      ) ??
                                      0.0;

                                  final lineAmountInINR = unitPrice * rate;
                                  itemController.lineAmountINR.text =
                                      lineAmountInINR.toStringAsFixed(2);

                                  // Sync with the model
                                  widget.items!.expenseTrans[i] = itemController
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
                          labelText: 'Amount in INR *',
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Itemized Expenses",
                                style: TextStyle(
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
                              final itemController = itemizeControllers[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Item ${index + 1}",
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
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.green,
                                                  ),
                                                  onPressed: _addItemize,
                                                  tooltip: 'Add new item',
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
                                            enabled: controller.isEnable.value,
                                            labelText: 'Project',
                                            columnHeaders: const [
                                              'Project Name',
                                              'Project ID',
                                            ],
                                            items: controller.project,
                                            selectedValue:
                                                itemController.selectedProject,
                                            searchValue: (p) =>
                                                '${p.name} ${p.code}',
                                            displayText: (p) => p.code,
                                            validator: (_) => null,
                                            onChanged: (p) {
                                              setState(() {
                                                controller.selectedProject = p;
                                                itemController.selectedProject =
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
                                              controller.fetchExpenseCategory();
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
                                            labelText: 'Paid For',
                                            enabled: controller.isEnable.value,
                                            columnHeaders: const [
                                              'Category Name',
                                              'Category ID',
                                            ],
                                            items: controller.expenseCategory,
                                            selectedValue:
                                                itemController.selectedCategory,
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
                                                      child: Text(p.categoryId),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _buildTextField(
                                            label: "Comments",
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
                                            labelText: 'Unit *',
                                            enabled: controller.isEnable.value,
                                            columnHeaders: const [
                                              'Uom Id',
                                              'Uom Name',
                                            ],
                                            items: controller.unit,
                                            selectedValue:
                                                itemController.selectedunit,
                                            searchValue: (tax) =>
                                                '${tax.code} ${tax.name}',
                                            displayText: (tax) => tax.name,
                                            validator: (tax) => tax == null
                                                ? 'Please select a Unit'
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
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ), // Allows numbers with up to 2 decimal places
                                            ],
                                            label: "Quantity *",
                                            controller: itemController.quantity,
                                            isReadOnly:
                                                controller.isEnable.value,
                                            onChanged: (value) {
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
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ), // Allows numbers with up to 2 decimal places
                                            ],
                                            label: "Unit Amount *",
                                            controller:
                                                itemController.unitPriceTrans,
                                            isReadOnly:
                                                controller.isEnable.value,
                                            // inputFormatters: [
                                            //   FilteringTextInputFormatter.digitsOnly,
                                            //   LengthLimitingTextInputFormatter(
                                            //       10), // Max 10 digits
                                            // ],
                                            onChanged: (value) {
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
                                            label: "Line Amount",
                                            controller:
                                                itemController.lineAmount,
                                            isReadOnly: false,
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
                                          _buildTextField(
                                            label: "Line Amount in INR",
                                            controller:
                                                itemController.lineAmountINR,
                                            isReadOnly: false,
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
                                            TaxGroupModel
                                          >(
                                            enabled: controller.isEnable.value,
                                            labelText: "Tax Group",
                                            columnHeaders: const [
                                              'Tax Group',
                                              'Tax ID',
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
                                                      child: Text(tax.taxGroup),
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
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ), // Allows numbers with up to 2 decimal places
                                            ],
                                            label: "Tax Amount",
                                            controller:
                                                itemController.taxAmount,
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
                                          const SizedBox(height: 12),
                                          const SizedBox(height: 12),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              switchTheme: SwitchThemeData(
                                                thumbColor:
                                                    MaterialStateProperty.resolveWith<
                                                      Color?
                                                    >((states) {
                                                      if (states.contains(
                                                        MaterialState.disabled,
                                                      )) {
                                                        // ✅ Keep same thumb color even when disabled
                                                        return Colors.green;
                                                      }
                                                      if (states.contains(
                                                        MaterialState.selected,
                                                      )) {
                                                        return Colors.green;
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
                                                        MaterialState.disabled,
                                                      )) {
                                                        // ✅ Keep same track color even when disabled
                                                        return Colors.green
                                                            .withOpacity(0.5);
                                                      }
                                                      if (states.contains(
                                                        MaterialState.selected,
                                                      )) {
                                                        return Colors.green
                                                            .withOpacity(0.5);
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
                                                )!.isReimbursable,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              value:
                                                  itemController.isReimbursable,
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
                                                  : null, // disabled but keeps color
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
                                                              .withOpacity(0.5);
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
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                value:
                                                    controller.isBillableCreate,
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
                                                            onDistributionChanged:
                                                                (newList) {
                                                                  if (!mounted)
                                                                    return;
                                                                  item.accountingDistributions
                                                                      .clear();
                                                                  item.accountingDistributions
                                                                      .addAll(
                                                                        newList,
                                                                      );
                                                                },
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Accounting Distribution',
                                                    style: TextStyle(
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
                      const SizedBox(height: 10),
                      _buildSection(
                        title: "Tracking History",
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
                                return Center(child: Text("No Data Available"));
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
                              text: "Resubmit",
                              isLoading: controller.buttonLoader.value,
                              onPressed: () {
                                controller.addToFinalItems(widget.items!);
                                controller.saveinviewPageGeneralExpense(
                                  context,
                                  true,
                                  true,
                                  widget.items!.recId!,
                                );
                              },
                            ),
                          );
                        }),

                      if (controller.isEnable.value) const SizedBox(height: 20),

                      // 🔵 Update Button
                      // Obx(() {
                      //   final isUpdateLoading =
                      //       controller.buttonLoaders['update'] ?? false;
                      //   final isUpdateAcceptLoading =
                      //       controller.buttonLoaders['update_accept'] ?? false;
                      //   final isAnyLoading = controller.buttonLoaders.values
                      //       .any((loading) => loading);

                      //   return Expanded(
                      //     child: ElevatedButton(
                      //       onPressed: (isUpdateLoading ||
                      //               isUpdateAcceptLoading ||
                      //               isAnyLoading)
                      //           ? null
                      //           : () {
                      //               controller.setButtonLoading('update', true);
                      //               controller.addToFinalItems(widget.items!);
                      //               controller
                      //                   .reviewGendralExpense(context, false,
                      //                       widget.items!.workitemrecid)
                      //                   .whenComplete(() {
                      //                 controller.setButtonLoading(
                      //                     'update', false);
                      //               });
                      //             },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor:
                      //             const Color.fromARGB(255, 3, 20, 117),
                      //       ),
                      //       child: isUpdateLoading
                      //           ? const SizedBox(
                      //               height: 20,
                      //               width: 20,
                      //               child: CircularProgressIndicator(
                      //                 color: Colors.white,
                      //                 strokeWidth: 2,
                      //               ),
                      //             )
                      //           : const Text(
                      //               "Update",
                      //               style: TextStyle(color: Colors.white),
                      //             ),
                      //     ),
                      //   );
                      // }),

                      // const SizedBox(width: 12),

                      // 🟢 Update & Accept Button
                      // if (controller.isEnable.value &&
                      //     widget.items!.stepType == "Review")
                      // 🟦 Update & Accept Row
                      if (controller.isEnable.value &&
                          widget.items!.stepType == "Review")
                        Row(
                          children: [
                            // 🔵 Update Button
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
                                                widget.items!.workitemrecid!,
                                              )
                                              .whenComplete(() {
                                                controller.setButtonLoading(
                                                  'update',
                                                  false,
                                                );
                                              });
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
                                      : const Text(
                                          "Update",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }),

                            const SizedBox(width: 12),

                            // 🟢 Update & Accept Button
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
                                                widget.items!.workitemrecid!,
                                              )
                                              .whenComplete(() {
                                                controller.setButtonLoading(
                                                  'update_accept',
                                                  false,
                                                );
                                              });
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
                                      : const Text(
                                          "Update & Accept",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      if (controller.isEnable.value &&
                          widget.items!.stepType == "Review")
                        const SizedBox(height: 12), // space between rows
                      //  if (controller.isEnable.value &&
                      //       widget.items!.stepType == "Review")
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
                                          controller.setButtonLoading(
                                            'reject',
                                            true,
                                          );
                                          controller.addToFinalItems(
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
                                                  'reject',
                                                  false,
                                                );
                                              });
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
                                      : const Text(
                                          "Reject",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text("Close"),
                              ),
                            ),
                          ],
                        ),

                      if (controller.isApprovalEnable.value &&
                          widget.items!.stepType == "Approval")
                        Row(
                          children: [
                            // ✅ Approve Button
                            Obx(() {
                              final isLoading =
                                  controller.buttonLoaders['approve'] ?? false;
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
                                      : const Text(
                                          "Approve",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }),

                            const SizedBox(width: 12),

                            // 🔴 Reject Button
                            Obx(() {
                              final isLoading =
                                  controller.buttonLoaders['reject_approval'] ??
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
                                      : const Text(
                                          "Reject",
                                          style: TextStyle(color: Colors.white),
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
                            // 🔵 Escalate Button
                            Obx(() {
                              final isLoading =
                                  controller.buttonLoaders['escalate'] ?? false;
                              return Expanded(
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          controller.setButtonLoading(
                                            'escalate',
                                            true,
                                          );
                                          showActionPopup(context, "Escalate");

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
                                      : const Text(
                                          "Escalate",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }),

                            const SizedBox(width: 12),

                            // ⚪ Close Button
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
                          child: const Text("Cancel"),
                        ),
                      const SizedBox(height: 30),
                    ],
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

  // ... (keep all your existing helper methods below)
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
                    'Submitted on ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
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
                    const Text(
                      "Action",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      const Text(
                        'Select User *',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: 'User *',
                          columnHeaders: const ['User Name', 'User ID'],
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
                    const Text('Comment', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter your comment here',
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
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();
                            if (status != "Approve" && comment.isEmpty) {
                              setState(() => isCommentError = true);
                              return;
                            }

                            // Show full-page loading indicator
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

                            // Hide the loading indicator
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

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required bool isReadOnly,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onChanged: isReadOnly ? null : onChanged,
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCollapsibleItem(
    String title,
    bool expanded,
    VoidCallback toggle,
    Widget child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggle,
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        if (expanded)
          Padding(padding: const EdgeInsets.only(top: 10), child: child),
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
