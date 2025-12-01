import 'dart:async';
import 'dart:io';

import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
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

import '../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../core/comman/widgets/pageLoaders.dart';
import '../../../../l10n/app_localizations.dart';

class HubApprovalViewEditCashAdvanceReturnPage extends StatefulWidget {
  final bool isReadOnly;
  final GESpeficExpense? items;
  const HubApprovalViewEditCashAdvanceReturnPage({
    Key? key,
    this.items,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  State<HubApprovalViewEditCashAdvanceReturnPage> createState() =>
      _HubApprovalViewEditCashAdvanceReturnPageState();
}

class _HubApprovalViewEditCashAdvanceReturnPageState
    extends State<HubApprovalViewEditCashAdvanceReturnPage>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController employeeName = TextEditingController();

  final TextEditingController employyeID = TextEditingController();
  final RxnString cashAdvanceField = RxnString();

  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
  final _formKey = GlobalKey<FormState>();
  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  late Future<List<ExpenseHistory>> historyFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _showHistory = false;
  late int workitemrecid;
  bool isEditable = false;
  int _currentIndex = 0;
  late PageController _pageController;
  // New state variables for itemize management
  int _itemizeCount = 1;
  Timer? _debounce;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
  bool allowMultSelect = true;
  @override
  void initState() {
    super.initState();
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
    controller.fetchExchangeRate();
    controller.fetchUsers();
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.fetchExpenseDocImage(widget.items!.recId);
    });
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
    if (widget.items!.stepType == "Approval") {
      setState(() {
        isEditable = false;
      });
    } else {
      setState(() {
        isEditable = true;
      });
    }
    workitemrecid = widget.items!.workitemrecid!;
    controller.currencyDropDowncontroller.text = widget.items!.currency
        .toString();

    // Initialize itemize controllers
    _initializeItemizeControllers();
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
    print("paidAmount${controllers.lineAmount.text}");
    // update Paid Amount
    controller.paidAmount.text = total.toStringAsFixed(2);

    // calculate INR amount immediately
    final paid = total;
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    controller.amountINR.text = (paid * rate).toStringAsFixed(2);

    return total;
  }

  Future<void> _updateAllLineItems() async {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];

      // Recalculate base + INR amounts
      _calculateTotalLineAmount(itemController);
      controller.calculateLineAmounts(itemController);

      // final lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
      // final lineAmountInINR = lineAmount * rate;

      // itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

      // // Sync with model
      // widget.items!.expenseTrans[i] = itemController.toExpenseItemUpdateModel();
    }

    setState(() {}); // only if you rely on UI state updates
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
      controller.expenseID = item.expenseId.toString();
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
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.tapToUploadDocs,
                          ),
                        );
                      } else {
                        return Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: controller.imageFiles.length,
                              onPageChanged: (index) {
                                _currentIndex = index;
                              },
                              itemBuilder: (_, index) {
                                final file = controller.imageFiles[index];
                                return GestureDetector(
                                  onTap: () => _showFullImage(file, index),
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(8),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.deepPurple,
                                      ),
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_currentIndex + 1}/${controller.imageFiles.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Positioned(
                            //   top: 40,
                            //   right: 20,
                            //   child: IconButton(
                            //     icon:
                            //         const Icon(Icons.close, color: Colors.white),
                            //     onPressed: () => Navigator.pop(context),
                            //   ),
                            // ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery),
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
                ),
                buildDateField(
                  AppLocalizations.of(context)!.returnDate,
                  receiptDateController,
                  isReadOnly: !controller.isEnable.value, // pass manually
                ),

                const SizedBox(height: 12),
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
                          final String label = field['FieldName'];
                          final bool isMandatory =
                              field['IsMandatory'] ?? false;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SearchableMultiColumnDropdownField<LocationModel>(
                                labelText: '$label ${isMandatory ? "*" : ""}',
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
                                validator: (loc) => isMandatory && loc == null
                                    ? AppLocalizations.of(context)!.selectLocale
                                    : null,
                                onChanged: (loc) {
                                  controller.selectedLocation = loc;
                                  controller.fetchMaxAllowedPercentage();
                                  if (_debounce?.isActive ?? false)
                                    _debounce!.cancel();

                                  // Start a new debounce timer
                                  _debounce = Timer(
                                    const Duration(milliseconds: 400),
                                    () async {
                                      final paidAmountText = controller
                                          .paidAmountCA1
                                          .text
                                          .trim();
                                      controller.unitAmount.text =
                                          controller.paidAmountCA1.text;
                                      final double paidAmounts =
                                          double.tryParse(paidAmountText) ??
                                          0.0;
                                      final currency = controller
                                          .currencyDropDowncontrollerCA3
                                          .text;

                                      // Only proceed if currency and amount are provided
                                      if (currency.isNotEmpty &&
                                          paidAmountText.isNotEmpty) {
                                        // Fire API calls concurrently
                                        final results = await Future.wait([
                                          controller.fetchExchangeRateCA(
                                            currency,
                                            paidAmountText,
                                          ),
                                          controller
                                              .fetchMaxAllowedPercentage(),
                                        ]);

                                        // Process the first exchange rate response
                                        final exchangeResponse1 =
                                            results[0] as ExchangeRateResponse?;
                                        if (exchangeResponse1 != null) {
                                          controller.unitRateCA1.text =
                                              exchangeResponse1.exchangeRate
                                                  .toString();
                                          controller.amountINRCA1.text =
                                              exchangeResponse1.totalAmount
                                                  .toStringAsFixed(2);
                                          controller.isVisible.value = true;
                                        }

                                        // Process max allowed percentage
                                        final maxPercentage =
                                            results[1] as double?;

                                        if (maxPercentage != null &&
                                            maxPercentage > 0) {
                                          final double calculatedPercentage =
                                              (paidAmounts * maxPercentage) /
                                              100;

                                          controller.totalRequestedAmount.text =
                                              calculatedPercentage.toString();
                                          controller
                                                  .calculatedPercentage
                                                  .value =
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
                                        final reqCurrency = controller
                                            .currencyDropDowncontrollerCA2
                                            .text;
                                        if (reqCurrency.isNotEmpty &&
                                            reqPaidAmount.isNotEmpty) {
                                          final exchangeResponse =
                                              await controller
                                                  .fetchExchangeRateCA(
                                                    reqCurrency,
                                                    reqPaidAmount,
                                                  );

                                          if (exchangeResponse != null) {
                                            controller.unitRateCA2.text =
                                                exchangeResponse.exchangeRate
                                                    .toString();
                                            controller.amountINRCA2.text =
                                                exchangeResponse.totalAmount
                                                    .toStringAsFixed(2);
                                            // controller.isVisible.value = true;
                                          }
                                        }
                                      }
                                    },
                                  );
                                  field['Error'] =
                                      null; // Clear error when value selected
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
                              ),

                              const SizedBox(height: 16),
                            ],
                          );
                        })
                        .toList(),
                  );
                }),
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
                              selectedValue: controller.singleSelectedItem,
                              selectedValues: controller.multiSelectedItems,
                              enabled: controller.isEnable.value,
                              searchValue: (proj) => proj.cashAdvanceReqId,
                              displayText: (proj) => proj.cashAdvanceReqId,
                              validator: (proj) => proj == null
                                  ? 'Please select a CashAdvance Field'
                                  : null,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    SearchableMultiColumnDropdownField<PaymentMethodModel>(
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
                        setState(() {
                          controller.selectedPaidWith = p;
                          controller.paymentMethodID = p!.paymentMethodId;
                          controller.paidWithController.text =
                              p.paymentMethodId;
                        });
                        // loadAndAppendCashAdvanceList();
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
                              double.tryParse(controller.paidAmount.text) ??
                              0.0;
                          final rate =
                              double.tryParse(controller.unitRate.text) ?? 1.0;

                          final result = paid * rate;

                          controller.amountINR.text = result.toStringAsFixed(2);
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ), // Only digits and dots allowed
                        ],
                        decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context)!.paidAmount}*',
                          // ignore: prefer_const_constructors
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
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
                            controller.paidAmount.text = value.toStringAsFixed(
                              2,
                            );
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
                          validator: (c) => c == null
                              ? AppLocalizations.of(
                                  context,
                                )!.pleaseSelectCurrency
                              : null,
                          onChanged: (c) async {
                            controller.selectedCurrency.value = c;
                            controller.fetchExchangeRate().then((_) {
                              _updateAllLineItems();
                            });
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
                        onChanged: (val) {
                          // Fetch exchange rate if needed
                          // controller.fetchExchangeRate();

                          final paid =
                              double.tryParse(controller.paidAmount.text) ??
                              0.0;
                          final rate = double.tryParse(val) ?? 1.0;

                          // ✅ Perform calculation
                          final result = paid * rate;

                          controller.amountINR.text = result.toStringAsFixed(2);
                          controller.isVisible.value = true;
                          for (int i = 0; i < itemizeControllers.length; i++) {
                            final itemController = itemizeControllers[i];
                            // controller
                            // .calculateLineAmounts(itemController);
                            final unitPrice =
                                double.tryParse(
                                  itemController.unitPriceTrans.text,
                                ) ??
                                0.0;

                            final lineAmountInINR = unitPrice * rate;
                            itemController.lineAmountINR.text = lineAmountInINR
                                .toStringAsFixed(2);

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
                    labelText: '${AppLocalizations.of(context)!.amountInInr}*',
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
                        final itemController = itemizeControllers[index];
                        // _calculateTotalLineAmount(itemController);
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
                                            widget.items!.expenseTrans.length >
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SearchableMultiColumnDropdownField<Project>(
                                      enabled: controller.isEnable.value,
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.projectId,
                                      columnHeaders: [
                                        AppLocalizations.of(
                                          context,
                                        )!.projectName,
                                        AppLocalizations.of(context)!.projectId,
                                      ],
                                      items: controller.project,
                                      selectedValue:
                                          itemController.selectedProject,
                                      searchValue: (p) => '${p.name} ${p.code}',
                                      displayText: (p) => p.code,
                                      validator: (_) => null,
                                      onChanged: (p) {
                                        setState(() {
                                          controller.selectedProject = p;
                                          itemController.selectedProject =
                                              p; // update controller state
                                          controller
                                                  .projectDropDowncontroller
                                                  .text =
                                              p!.code;
                                          widget
                                              .items!
                                              .expenseTrans[index] = itemController
                                              .toExpenseItemUpdateModel(); // sync with parent list
                                        });
                                        controller.fetchExpenseCategory();
                                      },
                                      controller: itemController
                                          .projectDropDowncontroller,
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
                                    const SizedBox(height: 12),
                                    SearchableMultiColumnDropdownField<
                                      ExpenseCategory
                                    >(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.projectId,
                                      enabled: controller.isEnable.value,
                                      columnHeaders: [
                                        AppLocalizations.of(
                                          context,
                                        )!.categoryName,
                                        AppLocalizations.of(
                                          context,
                                        )!.categoryName,
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
                                          itemController.selectedCategory = p;
                                          itemController.selectedCategoryId =
                                              p!.categoryId;
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                          itemController
                                                  .categoryController
                                                  .text =
                                              p.categoryId;
                                        });
                                      },
                                      controller:
                                          itemController.categoryController,
                                      rowBuilder: (p, searchQuery) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(p.categoryName),
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
                                      label: AppLocalizations.of(
                                        context,
                                      )!.comments,
                                      controller:
                                          itemController.descriptionController,
                                      isReadOnly: controller.isEnable.value,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                        });
                                      },
                                    ),
                                    SearchableMultiColumnDropdownField<Unit>(
                                      labelText:
                                          '${AppLocalizations.of(context)!.unit} *',
                                      enabled: controller.isEnable.value,
                                      columnHeaders: [
                                        AppLocalizations.of(context)!.uomId,
                                        AppLocalizations.of(context)!.uomName,
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
                                          itemController.selectedunit = tax;
                                          itemController.uomId.text = tax!.code;
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
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
                                    const SizedBox(height: 12),
                                    _buildTextField(
                                      label:
                                          "${AppLocalizations.of(context)!.quantity} *",
                                      controller: itemController.quantity,
                                      isReadOnly: controller.isEnable.value,
                                      onChanged: (value) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              controller
                                                  .fetchExchangeRate()
                                                  .then((_) {
                                                    _updateAllLineItems();
                                                  });
                                            });

                                        setState(() {
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                        });
                                      },
                                    ),
                                    _buildTextField(
                                      label:
                                          "${AppLocalizations.of(context)!.unitAmount} *",
                                      controller: itemController.unitPriceTrans,
                                      isReadOnly: controller.isEnable.value,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(
                                          10,
                                        ), // Max 10 digits
                                      ],
                                      onChanged: (value) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              controller
                                                  .fetchExchangeRate()
                                                  .then((_) {
                                                    _updateAllLineItems();
                                                  });
                                            });

                                        setState(() {
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                        });
                                      },
                                    ),
                                    _buildTextField(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.lineAmount,
                                      controller: itemController.lineAmount,
                                      isReadOnly: false,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                        });
                                      },
                                    ),
                                    _buildTextField(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.lineAmountInInr,
                                      controller: itemController.lineAmountINR,
                                      isReadOnly: false,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.items!.expenseTrans[index] =
                                              itemController
                                                  .toExpenseItemUpdateModel();
                                        });
                                      },
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
                                                  item.accountingDistributions
                                                      .map((e) {
                                                        return AccountingSplit(
                                                          paidFor: e
                                                              .dimensionValueId,
                                                          percentage: e
                                                              .allocationFactor,
                                                          amount: e.transAmount,
                                                        );
                                                      })
                                                      .toList(),
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
                                                shape:
                                                    const RoundedRectangleBorder(
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
                                                          itemController.split,
                                                      lineAmount: lineAmount,
                                                      onChanged:
                                                          (i, updatedSplit) {
                                                            if (!mounted)
                                                              return;
                                                            itemController
                                                                    .split[i] =
                                                                updatedSplit;
                                                          },
                                                      onDistributionChanged: (newList) {
                                                        if (!mounted) return;
                                                        item.accountingDistributions
                                                            .clear();
                                                        item.accountingDistributions
                                                            .addAll(newList);
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
                                                    TextDecoration.underline,
                                                decorationColor: Colors.blue,
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
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final historyList = snapshot.data!;
                        if (historyList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                AppLocalizations.of(context)!.noHistoryMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
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

                if (widget.items!.stepType == "Review")
                  Row(
                    children: [
                      // 🔵 Update Button
                      Obx(() {
                        final isUpdateLoading =
                            controller.buttonLoaders['update'] ?? false;
                        final isUpdateAcceptLoading =
                            controller.buttonLoaders['update_accept'] ?? false;
                        final isRejectLoading =
                            controller.buttonLoaders['reject'] ?? false;
                        final isAnyLoading = controller.buttonLoaders.values
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
                                    controller.setButtonLoading('update', true);
                                    controller.addToFinalItems(widget.items!);
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
                                : Text(
                                    AppLocalizations.of(context)!.update,
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
                            controller.buttonLoaders['update_accept'] ?? false;
                        final isRejectLoading =
                            controller.buttonLoaders['reject'] ?? false;
                        final isAnyLoading = controller.buttonLoaders.values
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
                                    controller.addToFinalItems(widget.items!);
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
                                : Flexible(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.updateAndAccept,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                if (widget.items!.stepType == "Review")
                  const SizedBox(height: 12), // space between rows
                //  if (controller.isEnable.value &&
                //       widget.items!.stepType == "Review")
                if (widget.items!.stepType == "Review")
                  Row(
                    children: [
                      Obx(() {
                        final isUpdateLoading =
                            controller.buttonLoaders['update'] ?? false;
                        final isUpdateAcceptLoading =
                            controller.buttonLoaders['update_accept'] ?? false;
                        final isRejectLoading =
                            controller.buttonLoaders['reject'] ?? false;
                        final isAnyLoading = controller.buttonLoaders.values
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
                                    controller.setButtonLoading('reject', true);
                                    controller.addToFinalItems(widget.items!);
                                    showActionPopup(context, "Reject");
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
                                    AppLocalizations.of(context)!.reject,
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.skipCurrentItem(
                              widget.items!.workitemrecid!,
                              context,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: Text(AppLocalizations.of(context)!.skip),
                        ),
                      ),
                    ],
                  ),

                if (widget.items!.stepType == "Approval")
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
                                : Text(
                                    AppLocalizations.of(context)!.approve,
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
                                : Text(
                                    AppLocalizations.of(context)!.reject,
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),

                if (widget.items!.stepType == "Approval")
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
                                : Text(
                                    AppLocalizations.of(context)!.escalate,
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
                            controller.skipCurrentItem(
                              widget.items!.workitemrecid!,
                              context,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: Text(AppLocalizations.of(context)!.skip),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
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
                            controller.closeField();
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
    final loc = AppLocalizations.of(context)!;
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
                      loc.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${loc.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${loc.user} *',
                          columnHeaders: [loc.userName, loc.userId],
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
                    Text(loc.comments, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: loc.enterCommentHere,
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
                          child: Text(loc.close),
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

                            final success = await controller
                                .approvalHubpostApprovalAction(
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
                                AppRoutes.approvalHubMain,
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
    List<TextInputFormatter>? inputFormatters, // ✅ optional inputFormatters
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isReadOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters, // ✅ apply if not null
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
