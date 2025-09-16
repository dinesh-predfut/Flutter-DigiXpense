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

import '../../../../../core/comman/widgets/pageLoaders.dart';

class ViewMyteamCashAdvanceExpensePage extends StatefulWidget {
  final CashAdvanceRequestHeader? items;
  const ViewMyteamCashAdvanceExpensePage({Key? key, this.items})
      : super(key: key);

  @override
  State<ViewMyteamCashAdvanceExpensePage> createState() =>
      _ViewMyteamCashAdvanceExpensePageState();
}

class _ViewMyteamCashAdvanceExpensePageState
    extends State<ViewMyteamCashAdvanceExpensePage>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
    final TextEditingController employeename = TextEditingController();
      final TextEditingController employeeId = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
  String? paidToError;
  bool _showUnitAmountError = false;
  bool _showLocationError = false;
  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  Future<List<ExpenseHistory>>? historyFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _isEditingExisting = false;
  bool _showHistory = false;
  Timer? _debounce;
  // New state variables for itemize management
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];
  late int workitemrecid;
  @override
  void initState() {
    super.initState();
    expenseIdController.text = "";
    requestDateController.text = "";
    merhantName.text = "";
    controller.getconfigureFieldCashAdvance();
    controller.fetchLocation();
    controller.fetchPaidto();
    controller.fetchPaidwith();
    controller.fetchProjectName();
    controller.fetchExpenseCategory();
    controller.fetchUnit();
    // controller.fetchTaxGroup();
    controller.currencyDropDown();
    controller.fetchExpenseCategory();
    controller.fetchBusinessjustification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchExpenseDocImage(widget.items!.recId);

      historyFuture = controller.cashadvanceTracking(widget.items!.recId);
    });

    final timestamp = widget.items!.requestDate; // assuming this is int
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatted = DateFormat('dd/MM/yyyy').format(dateTime);
    requestDateController.text = formatted;

    if (widget.items != null && widget.items!.prefferedPaymentMethod != null) {
      controller.paymentMethodID =
          widget.items!.prefferedPaymentMethod.toString();
    }

    expenseIdController.text = widget.items!.requisitionId.toString();
    // requestDateController.text = formatted;
    controller.justificationController.text =
        widget.items!.businessJustification;
    print('--- AccountingDistributions Added ---');
    controller.referenceID.text = widget.items?.referenceId?.toString() ?? '';
    if (widget.items != null && widget.items!.prefferedPaymentMethod != null) {
      controller.paidWithController.text =
          widget.items!.prefferedPaymentMethod!;
    } else {
      controller.paidWithController.text = ''; // or set a default value
    }
employeename.text=widget.items!.employeeName;
employeeId.text=widget.items!.employeeId;

    selectedPaidTo = paidToOptions.first;
    selectedPaidWith = paidWithOptions.first;
    controller.locationController.text = widget.items!.location ?? '';
    controller.estimatedamountINR.text =
        widget.items!.totalEstimatedAmountInReporting.toString();
    controller.requestamountINR.text =
        widget.items!.totalRequestedAmountInReporting.toString();
    controller.requestedPercentage.text = widget.items!.percentage.toString();
    controller.unitRate.text =
        widget.items!.totalEstimatedAmountInReporting.toString();
    if (widget.items?.workitemrecid != null) {
      workitemrecid = widget.items!.workitemrecid!;
    }

    // calculateAmounts(controller.exchangeRate.text);
    controller.amountINR.text =
        widget.items!.totalEstimatedAmountInReporting.toString();
    controller.expenseID = widget.items!.referenceId;
    controller.recID = widget.items!.recId;

    // Initialize itemize controllers
    _initializeItemizeControllers();
  }

  double _calculateTotalLineAmount(Controller controllers) {
    double total = 0.0;

    final currentLineAmount =
        double.tryParse(controllers.amountINRCA1.text) ?? 0.0;
    total += currentLineAmount;

    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.amountINRCA1.text) ?? 0.0;
        total += amount;
      }
    }
    controller.estimatedamountINR.text = total.toString();
    print("total$total");
    return total;
  }

  double _calculateTotalLineAmount2(Controller controllers) {
    double total = 0.0;

    final currentLineAmount =
        double.tryParse(controllers.amountINRCA2.text) ?? 0.0;
    total += currentLineAmount;

    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.amountINRCA2.text) ?? 0.0;
        total += amount;
      }
    }
    controller.requestamountINR.text = total.toString();
    print("total222$total");
    return total;
  }

  void _initializeItemizeControllers() {
    itemizeControllers = widget.items!.cshCashAdvReqTrans.map((item) {
      final controller = Controller();

      controller.projectDropDowncontroller.text = item.projectId ?? '';
      controller.descriptionController.text = item.description ?? '';
      controller.quantity.text = item.quantity.toString();
      controller.unitPriceTrans.text = item.unitEstimatedAmount.toString();
      controller.lineAmount.text = item.unitEstimatedAmount.toString();
      controller.lineAmountINR.text = item.unitEstimatedAmount.toString();
      controller.taxAmount.text = item.taxAmount.toString();

      controller.categoryController.text = item.expenseCategoryId!;
      controller.selectedCategoryId = item.expenseCategoryId!;
      controller.uomId.text = item.uomId!;
      controller.locationController.text = item.location!;
      controller.unitAmount.text = item.unitEstimatedAmount.toString();
      controller.totalunitEstimatedAmount.text =
          item.unitEstimatedAmount.toString();
      controller.currencyDropDowncontrollerCA3.text =
          item.lineEstimatedCurrency!;
      controller.currencyDropDowncontrollerCA2.text =
          item.lineRequestedCurrency!;
      if (item.accountingDistributions != null) {
        controller.split = (item.accountingDistributions ?? []).map((dist) {
          return AccountingSplit(
            paidFor: dist.dimensionValueId ?? '',
            percentage: dist.allocationFactor ?? 0.0,
            amount: dist.transAmount ?? 0.0,
          );
        }).toList();
      }
      if (controller.location.isNotEmpty) {
        controller.selectedLocation = controller.location.firstWhere(
          (e) => e.city == item.location,
          orElse: () => controller.location.first,
        );
      }
      if (item.accountingDistributions != null) {
        controller.accountingDistributions.clear();
        controller.accountingDistributions.addAll(
          item.accountingDistributions!.map((dist) {
            return AccountingDistribution(
              transAmount: dist.transAmount ?? 0.0,
              reportAmount: dist.reportAmount ?? 0.0,
              allocationFactor: dist.allocationFactor ?? 0.0,
              dimensionValueId: dist.dimensionValueId ?? '',
            );
          }),
        );

        print('--- AccountingDistributions Added ---');
        for (var dist in controller.accountingDistributions) {
          print(
              'TransAmount: ${dist!.transAmount}, ReportAmount: ${dist.reportAmount}, '
              'AllocationFactor: ${dist.allocationFactor}, DimensionValueId: ${dist.dimensionValueId}');
        }
        print('--------------------------------------');
      }
      _initializeControllerAsyncData(controller, item);

      /// --- End your logic ---

      return controller;
    }).toList();

    _itemizeCount = widget.items!.cshCashAdvReqTrans.length;
    controller.calculateAndFetchAmounts();
  }

  void _initializeControllerAsyncData(
      Controller controller, CashAdvanceRequestItemize item) async {
    final paidAmountText = item.unitEstimatedAmount;
    final double? paidAmounts = item.unitEstimatedAmount;
    final currency = item.lineEstimatedCurrency;

    if (currency != null && paidAmountText != null) {
      try {
        final results = await Future.wait([
          controller.fetchExchangeRateCA(currency, paidAmountText.toString()),
          controller.fetchMaxAllowedPercentage(),
        ]);

        final exchangeResponse1 = results[0] as ExchangeRateResponse?;
        final maxPercentage = results[1] as double?;

        if (exchangeResponse1 != null) {
          controller.unitRateCA1.text =
              exchangeResponse1.exchangeRate.toString();
          controller.amountINRCA1.text =
              exchangeResponse1.totalAmount.toStringAsFixed(2);
          controller.isVisible.value = true;
        }

        if (maxPercentage != null && maxPercentage > 0 && paidAmounts != null) {
          final calculatedPercentage = (paidAmounts * maxPercentage) / 100;
          controller.totalRequestedAmount.text =
              calculatedPercentage.toString();
          controller.calculatedPercentage.value = calculatedPercentage;
          controller.requestedPercentage.text = '${maxPercentage.toInt()} %';
        }

        final reqPaidAmount = controller.totalRequestedAmount.text.trim();
        final reqCurrency = controller.currencyDropDowncontrollerCA2.text;
        if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
          final exchangeResponse =
              await controller.fetchExchangeRateCA(reqCurrency, reqPaidAmount);
          if (exchangeResponse != null) {
            controller.unitRateCA2.text =
                exchangeResponse.exchangeRate.toString();
            controller.amountINRCA2.text =
                exchangeResponse.totalAmount.toStringAsFixed(2);
          }
        }
      } catch (e) {
        print('Error fetching async data: $e');
      }
    }
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
        (e) => e.paymentMethodId == widget.items!.prefferedPaymentMethod,
        orElse: () => controller.paymentMethods.first,
      );
    }

    if (controller.project.isNotEmpty) {
      controller.selectedProject = controller.project.firstWhere(
        (e) => e.code == widget.items!.projectId,
        orElse: () => controller.project.first,
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

      final lineAmountInINR = unitPrice * rate;
      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);

      // Sync with the model
      // widget.items!.cshCashAdvReqTrans[i] = itemController.toExpenseItemUpdateModel();
    }
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        // Create new CashAdvanceRequestItemize with default values
        final newItem = CashAdvanceRequestItemize(
          description: '',
          quantity: 1,
          uomId: '',
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
        );

        debugPrint("Added new item: ${newItem.toString()}");

        // Add the new item to the list
        widget.items!.cshCashAdvReqTrans.add(newItem);

        // Create and initialize new controller
        final newController = Controller();

        // Initialize controller with default values from the new item
        // newController.descriptionController.text = newItem.description ?? '';
        // newController.quantity.text = newItem.quantity.toString();
        // newController.unitPriceTrans.text = '0';
        // newController.lineAmount.text = newItem.lineEstimatedAmount.toString();
        // newController.lineAmountINR.text =
        //     newItem.lineEstimatedAmountInReporting.toString();
        // newController.taxAmount.text = newItem.taxAmount.toString();
        // newController.projectDropDowncontroller.text = newItem.projectId ?? '';
        // newController.categoryController.text = newItem.expenseCategoryId ?? '';
        // newController.uomId.text = newItem.uomId ?? '';

        // Initialize additional fields needed for your UI
        // newController.unitAmount = TextEditingController(text: '0');
        // newController.totalunitEstimatedAmount = TextEditingController(text: '0');
        // newController.paidAmount = TextEditingController(text: '0');
        // newController.requestedPercentage = TextEditingController(text: '100 %');
        // newController.unitRateCA1 = TextEditingController(text: '1');
        // newController.amountINRCA1 = TextEditingController(text: '0');
        // newController.totalRequestedAmount = TextEditingController(text: '0');
        // newController.unitRateCA2 = TextEditingController(text: '1');
        // newController.amountINRCA2 = TextEditingController(text: '0');
        newController.currencyDropDowncontrollerCA3 =
            TextEditingController(text: 'INR');
        newController.currencyDropDowncontrollerCA2 =
            TextEditingController(text: 'INR');
        // newController.locationController = TextEditingController(text: newItem.location ?? '');
        // newController.selectedCurrencyCA1 = Rx<Currency?>(null);
        // newController.selectedCurrencyCA2 = Rx<Currency?>(null);
        newController.isVisible = false.obs;
        newController.calculatedPercentage = 0.0.obs;
        newController.split = <AccountingSplit>[].obs;

        // Set dropdown selections if available
        if (controller.project.isNotEmpty) {
          newController.selectedProject = controller.project.firstWhere(
            (p) => p.code == newItem.projectId,
            orElse: () => controller.project.first,
          );
        }

        if (controller.expenseCategory.isNotEmpty) {
          newController.selectedCategory =
              controller.expenseCategory.firstWhere(
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

        debugPrint(
            "Controller added with unit: ${newController.selectedunit?.name}");

        // Add to controllers list (new reference for rebuild)
        itemizeControllers = List.from(itemizeControllers)..add(newController);

        // Update counters
        _itemizeCount++;
        _selectedItemizeIndex = _itemizeCount - 1;
        showItemizeDetails = true;
      });
    }
  }

  void _syncControllerToModel(int index) {
    final itemController = itemizeControllers[index];
    final originalItem = widget.items!.cshCashAdvReqTrans[index];
    // final recCheck = originalItem.recId == null;

    // if (!recCheck) {
    //   print("Its recCheck$recCheck");
    setState(() {
      widget.items!.cshCashAdvReqTrans[index] = CashAdvanceRequestItemize(
        // Editable fields (from controllers)
        recId: originalItem.recId,
        description: itemController.descriptionController.text,
        quantity: int.tryParse(itemController.quantity.text) ??
            originalItem.quantity ??
            1,
        location: itemController.locationController.text,
        projectId: itemController.projectDropDowncontroller.text,
        expenseCategoryId: itemController.selectedCategoryId,
        uomId: itemController.uomId.text,
        unitEstimatedAmount:
            double.tryParse(itemController.unitAmount.text) ?? 1,
        // Non-editable fields (preserve original values)
        percentage:
            (double.tryParse(itemController.requestedPercentage.text) ?? 1)
                .toInt(),
        lineEstimatedCurrency:
            itemController.currencyDropDowncontrollerCA2.text,
        lineRequestedCurrency:
            itemController.currencyDropDowncontrollerCA3.text,
        lineEstimatedAmount:
            double.tryParse(itemController.totalunitEstimatedAmount.text) ??
                0.0,
        lineEstimatedAmountInReporting:
            double.tryParse(itemController.totalunitEstimatedAmount.text) ??
                0.0,
        lineAdvanceRequested:
            double.tryParse(itemController.totalRequestedAmount.text) ?? 0.0,
        lineRequestedAdvanceInReporting:
            double.tryParse(itemController.totalRequestedAmount.text) ??
                0.0, // ✅ CORRECT
        lineRequestedExchangerate:
            double.tryParse(itemController.unitRateCA2.text) ?? 0.0,
        lineEstimatedExchangerate:
            double.tryParse(itemController.unitRateCA1.text) ?? 0.0,
        maxAllowedPercentage:
            (double.tryParse(itemController.requestedPercentage.text) ?? 1)
                .toInt(),
        baseUnit: originalItem.baseUnit,
        baseUnitRequested: originalItem.baseUnitRequested,
        accountingDistributions:
            itemController.accountingDistributions.map((controller) {
          return AccountingDistribution(
              transAmount:
                  double.tryParse(controller?.transAmount.toString() ?? '') ??
                      0.0,
              reportAmount:
                  double.tryParse(controller?.reportAmount.toString() ?? '') ??
                      0.0,
              allocationFactor: controller?.allocationFactor ?? 0.0,
              dimensionValueId: controller?.dimensionValueId ?? 'Branch001');
              // currency: itemController.selectedCurrency.value?.code ?? "IND");
        }).toList(),

        // Add all other fields from originalItem that shouldn't change
        // ...
      );
    });
  }

  void _removeItemize(int index) {
    if (_itemizeCount <= 1) {
      setState(() {
        showItemizeDetails = false;
      });
    } else if (index >= 0 && index < widget.items!.cshCashAdvReqTrans.length) {
      setState(() {
        widget.items!.cshCashAdvReqTrans.removeAt(index);
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
        controller.clearFormFields();
        controller.isEnable.value = false;
        controller.isLoadingGE1.value = false;
        widget.items?.cshCashAdvReqTrans.clear();
        Navigator.pushNamed(context, AppRoutes.myTeamcashAdvanceDashboard);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'View My Teams Cash Advance Return',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: !controller.isEnable.value
                  ? null
                  : () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  print("isLoading: ${controller.isLoadingviewImage.value}");
                  print("imageFiles length: ${controller.imageFiles.length}");
                  if (controller.imageFiles.isEmpty) {
                    return const Center(
                        child: Text('Tap to Upload Document(s)'));
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.imageFiles.length,
                      itemBuilder: (context, index) {
                        final file = controller.imageFiles[index];
                        return GestureDetector(
                          onTap: () => _showFullImage(file, index),
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(8),
                            width: 100,
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
                    );
                  }
                }),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Receipt Details",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              label: "Cash Advance Requisition ID *",
              controller: expenseIdController,
              isReadOnly: false,
            ),
            _buildTextField(
              label: "Employee Name*",
              controller:employeename ,
              isReadOnly: false,
            ),
            _buildTextField(
              label: "Employee ID*",
              controller: employeeId,
              isReadOnly: false,
            ),
            buildDateField(
              "Request Date",
              requestDateController,
              isReadOnly: !controller.isEnable.value, // pass manually
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                SearchableMultiColumnDropdownField<Businessjustification>(
                  labelText: 'Business Justification * ',
                  enabled: controller.isEnable.value,
                  columnHeaders: const ['ID', 'Name'],
                  items: controller.justification,
                  selectedValue: controller.selectedjustification,
                  searchValue: (p) => '${p.id} ${p.name}',
                  displayText: (p) => p.name,
                  validator: (_) => null,
                  onChanged: (p) {
                    setState(() {
                      controller.selectedjustification = p;
                      controller.justificationController.text = p!.name;
                      paidToError = null;
                    });
                  },
                  controller: controller.justificationController,
                  rowBuilder: (p, searchQuery) {
                    Widget highlight(String text) {
                      final lowerQuery = searchQuery.toLowerCase();
                      final lowerText = text.toLowerCase();
                      final start = lowerText.indexOf(lowerQuery);

                      if (start == -1 || searchQuery.isEmpty) {
                        return Text(text);
                      }

                      final end = start + searchQuery.length;
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: text.substring(0, start),
                              
                            ),
                            TextSpan(
                              text: text.substring(start, end),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: text.substring(end),
                              
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: highlight(p.name)),
                          Expanded(child: highlight(p.id)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (paidToError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                    child: Text(
                      paidToError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                SearchableMultiColumnDropdownField<PaymentMethodModel>(
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
                      controller.paymentMethodID = p!.paymentMethodId;
                      controller.paidWithController.text = p.paymentMethodId;
                    });
                  },
                  controller: controller.paidWithController,
                  rowBuilder: (p, searchQuery) {
                    Widget highlight(String text) {
                      final query = searchQuery.toLowerCase();
                      final lowerText = text.toLowerCase();
                      final start = lowerText.indexOf(query);

                      if (start == -1 || query.isEmpty) return Text(text);

                      final end = start + query.length;
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: text.substring(0, start),
                              
                            ),
                            TextSpan(
                              text: text.substring(start, end),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: text.substring(end),
                              
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: highlight(p.paymentMethodName)),
                          Expanded(child: highlight(p.paymentMethodId)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildTextField(
              label: "Reference",
              controller: controller.referenceID,
              isReadOnly: controller.isEnable.value,
            ),
            TextFormField(
              controller: controller.estimatedamountINR,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Total Estimated Amount In INR *',
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
                labelText: 'Total Request Amount In INR *',
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.items!.cshCashAdvReqTrans.length,
                  itemBuilder: (context, index) {
                    final item = widget.items!.cshCashAdvReqTrans[index];
                    final itemController = itemizeControllers[index];
                    print(
                        "cshCashAdvReqTrans.length${widget.items!.cshCashAdvReqTrans.length}");
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
                                  "Item ${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (controller.isEnable.value &&
                                        widget.items!.cshCashAdvReqTrans
                                                .length >
                                            1)
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _removeItemize(index),
                                        tooltip: 'Remove this item',
                                      ),
                                    if (controller.isEnable.value)
                                      IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.green),
                                        onPressed: _addItemize,
                                        tooltip: 'Add new item',
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SearchableMultiColumnDropdownField<Project>(
                                  enabled: controller.isEnable.value,
                                  labelText: 'Project',
                                  columnHeaders: const [
                                    'Project Name',
                                    'Project ID'
                                  ],
                                  items: controller.project,
                                  selectedValue: itemController.selectedProject,
                                  searchValue: (p) => '${p.name} ${p.code}',
                                  displayText: (p) => p.code,
                                  validator: (_) => null,
                                  onChanged: (p) {
                                    setState(() {
                                      controller.selectedProject = p;
                                      itemController.selectedProject =
                                          p; // update controller state
                                      controller.projectDropDowncontroller
                                          .text = p!.code;
                                      // widget.items!.expenseTrans[index] =
                                      //     itemController
                                      //         .toExpenseItemUpdateModel(); // sync with parent list
                                    });
                                    controller.fetchExpenseCategory();
                                    _syncControllerToModel(index);
                                    _calculateTotalLineAmount(itemController);
                                    _calculateTotalLineAmount2(itemController);
                                  },
                                  controller:
                                      itemController.projectDropDowncontroller,
                                  rowBuilder: (p, searchQuery) {
                                    Widget highlight(String text) {
                                      final query = searchQuery.toLowerCase();
                                      final lowerText = text.toLowerCase();
                                      final matchIndex =
                                          lowerText.indexOf(query);

                                      if (matchIndex == -1 || query.isEmpty)
                                        return Text(text);

                                      final end = matchIndex + query.length;
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  text.substring(0, matchIndex),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: text.substring(
                                                  matchIndex, end),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: text.substring(end),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: highlight(p.name)),
                                          Expanded(child: highlight(p.code)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                SearchableMultiColumnDropdownField<
                                    ExpenseCategory>(
                                  labelText: 'Paid For',
                                  enabled: controller.isEnable.value,
                                  columnHeaders: const [
                                    'Category Name',
                                    'Category ID'
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
                                      // widget.items!.expenseTrans[index] =
                                      //     itemController
                                      //         .toExpenseItemUpdateModel();
                                      itemController.categoryController.text =
                                          p.categoryId;
                                      controller.selectedCategoryId =
                                          itemController.selectedCategoryId =
                                              p!.categoryId;
                                    });
                                    itemController.fetchMaxAllowedPercentage();
                                    _syncControllerToModel(index);
                                    _calculateTotalLineAmount(itemController);
                                    _calculateTotalLineAmount2(itemController);
                                  },
                                  controller: itemController.categoryController,
                                  rowBuilder: (p, searchQuery) {
                                    Widget highlight(String text) {
                                      final query = searchQuery.toLowerCase();
                                      final lower = text.toLowerCase();
                                      final matchIndex = lower.indexOf(query);

                                      if (matchIndex == -1 || query.isEmpty)
                                        return Text(text);

                                      final end = matchIndex + query.length;
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  text.substring(0, matchIndex),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: text.substring(
                                                  matchIndex, end),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: text.substring(end),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: highlight(p.categoryName)),
                                          Expanded(
                                              child: highlight(p.categoryId)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Obx(() {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: controller.configListAdvance
                                        .where((field) =>
                                            field['FieldName'] == 'Location' &&
                                            field['IsEnabled'] == true)
                                        .map((field) {
                                      final String label = field['FieldName'];
                                      final bool isMandatory =
                                          field['IsMandatory'] ?? false;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SearchableMultiColumnDropdownField<
                                              LocationModel>(
                                            labelText:
                                                '$label ${isMandatory ? "*" : ""}',
                                            enabled: controller.isEnable.value,
                                            columnHeaders: const [
                                              'Location',
                                              'Country'
                                            ],
                                            // enabled: controller.isEditModePerdiem,
                                            controller: itemController
                                                .locationController,
                                            items: controller.location,
                                            selectedValue:
                                                controller.selectedLocation,
                                            searchValue: (loc) => loc.location,
                                            displayText: (loc) => loc.location,
                                            validator: (loc) =>
                                                isMandatory && loc == null
                                                    ? 'Please select a Location'
                                                    : null,
                                            onChanged: (loc) {
                                              itemController.locationController
                                                  .text = loc!.city;
                                              controller.selectedLocation = loc;
                                              itemController
                                                  .fetchMaxAllowedPercentage();
                                              field['Error'] =
                                                  null; // Clear error when value selected
                                              _syncControllerToModel(index);
                                              _calculateTotalLineAmount(
                                                  itemController);
                                              _calculateTotalLineAmount2(
                                                  itemController);
                                            },
                                            rowBuilder: (loc, searchQuery) {
                                              Widget highlight(String text) {
                                                final lowerQuery =
                                                    searchQuery.toLowerCase();
                                                final lowerText =
                                                    text.toLowerCase();
                                                final start = lowerText
                                                    .indexOf(lowerQuery);
                                                if (start == -1 ||
                                                    searchQuery.isEmpty) {
                                                  return Text(text);
                                                }

                                                final end =
                                                    start + searchQuery.length;
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: text.substring(
                                                            0, start),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      TextSpan(
                                                        text: text.substring(
                                                            start, end),
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            text.substring(end),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child:
                                                            Text(loc.location)),
                                                    Expanded(
                                                        child:
                                                            Text(loc.country)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          if (_showLocationError)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                'Please select a Location',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                }),
                                // const SizedBox(height: 6),
                                _buildTextField(
                                  label: "Comments",
                                  controller:
                                      itemController.descriptionController,
                                  isReadOnly: controller.isEnable.value,
                                  onChanged: (value) {
                                    setState(() {
                                      // widget.items!.expenseTrans[index] =
                                      //     itemController
                                      //         .toExpenseItemUpdateModel();
                                      _syncControllerToModel(index);
                                      _calculateTotalLineAmount(itemController);
                                      _calculateTotalLineAmount2(
                                          itemController);
                                    });
                                  },
                                ),
                                SearchableMultiColumnDropdownField<Unit>(
                                  labelText: 'Unit *',
                                  enabled: controller.isEnable.value,
                                  columnHeaders: const ['Uom Id', 'Uom Name'],
                                  items: controller.unit,
                                  selectedValue: itemController.selectedunit,
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
                                      // widget.items!.expenseTrans[index] =
                                      //     itemController
                                      //         .toExpenseItemUpdateModel();
                                      _syncControllerToModel(index);
                                      _calculateTotalLineAmount(itemController);
                                      _calculateTotalLineAmount2(
                                          itemController);
                                    });
                                  },
                                  controller: itemController.uomId,
                                  rowBuilder: (tax, searchQuery) {
                                    Widget highlight(String text) {
                                      final query = searchQuery.toLowerCase();
                                      final lower = text.toLowerCase();
                                      final matchIndex = lower.indexOf(query);

                                      if (matchIndex == -1 || query.isEmpty) {
                                        return Text(text);
                                      }

                                      final end = matchIndex + query.length;
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  text.substring(0, matchIndex),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: text.substring(
                                                  matchIndex, end),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: text.substring(end),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: highlight(tax.code)),
                                          Expanded(child: highlight(tax.name)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller:
                                      itemController.requestedPercentage,
                                  
                                  decoration: InputDecoration(
                                    labelText: "Requested Percentage %",
                                    enabled: false,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  label: "Quantity *",
                                  controller: itemController.quantity,
                                  isReadOnly: controller.isEnable.value,
                                  onChanged: (value) {
                                    itemController
                                        .calculateLineAmounts(itemController);
                                    setState(() {
                                      // widget.items!.expenseTrans[index] =
                                      //     itemController
                                      //         .toExpenseItemUpdateModel();
                                    });
                                    _syncControllerToModel(index);
                                    _calculateTotalLineAmount(itemController);
                                    _calculateTotalLineAmount2(itemController);
                                  },
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: itemController.unitAmount,
                                  enabled: controller.isEnable.value,
                                  
                                  onChanged: (value) {
                                    controller.fetchExchangeRate();

                                    setState(() {
                                      itemController.unitAmount.text = value;
                                      _showUnitAmountError = false;
                                    });
                                    final qty = double.tryParse(
                                            itemController.quantity.text) ??
                                        0.0;
                                    final unit = double.tryParse(
                                            itemController.unitAmount.text) ??
                                        0.0;

                                    final calculatedLineAmount = qty * unit;

                                    itemController
                                            .totalunitEstimatedAmount.text =
                                        calculatedLineAmount.toStringAsFixed(2);
                                    itemController.paidAmount.text =
                                        calculatedLineAmount.toStringAsFixed(2);
                                    if (_debounce?.isActive ?? false)
                                      _debounce!.cancel();

                                    // Start a new debounce timer
                                    _debounce =
                                        Timer(const Duration(milliseconds: 400),
                                            () async {
                                      final paidAmountText = itemController
                                          .totalunitEstimatedAmount.text
                                          .trim();

                                      final double paidAmounts =
                                          double.tryParse(paidAmountText) ??
                                              0.0;
                                      final currency = itemController
                                          .currencyDropDowncontrollerCA3.text;

                                      // Only proceed if currency and amount are provided
                                      if (currency.isNotEmpty &&
                                          paidAmountText.isNotEmpty) {
                                        // Fire API calls concurrently
                                        final results = await Future.wait([
                                          itemController.fetchExchangeRateCA(
                                              currency, paidAmountText),
                                          itemController
                                              .fetchMaxAllowedPercentage(),
                                        ]);

                                        // Process the first exchange rate response
                                        final exchangeResponse1 =
                                            results[0] as ExchangeRateResponse?;
                                        if (exchangeResponse1 != null) {
                                          itemController.unitRateCA1.text =
                                              exchangeResponse1.exchangeRate
                                                  .toString();
                                          itemController.amountINRCA1.text =
                                              exchangeResponse1.totalAmount
                                                  .toStringAsFixed(2);
                                          itemController.isVisible.value = true;
                                        }

                                        // Process max allowed percentage
                                        final maxPercentage =
                                            results[1] as double?;

                                        if (maxPercentage != null &&
                                            maxPercentage > 0) {
                                          final double calculatedPercentage =
                                              (paidAmounts * maxPercentage) /
                                                  100;

                                          itemController
                                                  .totalRequestedAmount.text =
                                              calculatedPercentage.toString();
                                          itemController.calculatedPercentage
                                              .value = calculatedPercentage;
                                          final percentageStr =
                                              maxPercentage.toInt().toString();
                                          itemController.requestedPercentage
                                              .text = percentageStr;
                                        }
                                        final reqPaidAmount = itemController
                                            .totalRequestedAmount.text
                                            .trim();
                                        final reqCurrency = itemController
                                            .currencyDropDowncontrollerCA2.text;
                                        if (reqCurrency.isNotEmpty &&
                                            reqPaidAmount.isNotEmpty) {
                                          final exchangeResponse =
                                              await itemController
                                                  .fetchExchangeRateCA(
                                                      reqCurrency,
                                                      reqPaidAmount);

                                          if (exchangeResponse != null) {
                                            itemController.unitRateCA2.text =
                                                exchangeResponse.exchangeRate
                                                    .toString();
                                            itemController.amountINRCA2.text =
                                                exchangeResponse.totalAmount
                                                    .toStringAsFixed(2);
                                            // itemController.isVisible.value = true;
                                          }
                                        }
                                      }
                                    });
                                    _syncControllerToModel(index);
                                    _calculateTotalLineAmount(itemController);
                                    _calculateTotalLineAmount2(itemController);
                                  },
                                  onEditingComplete: () {
                                    String text =
                                        itemController.unitAmount.text;
                                    double? value = double.tryParse(text);
                                    if (value != null) {
                                      itemController.unitAmount.text =
                                          value.toStringAsFixed(2);
                                      itemController.paidAmount.text =
                                          value.toStringAsFixed(2);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Unit Estimated Amount *",
                                    // errorText: _showUnitAmountError
                                    //     ? 'Unit Amount is required'
                                    //     : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                //  const SizedBox(height: 9),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Estimated Amount *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          /// Paid Amount Field
                                          Expanded(
                                            flex: 2,
                                            child: TextFormField(
                                              controller: itemController
                                                  .totalunitEstimatedAmount,
                                              enabled: !showItemizeDetails,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                hintText: 'Paid Amount',
                                                isDense: true,
                                                // contentPadding:
                                                //     EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              onChanged: (_) async {
                                                // Cancel previous debounce timer if still active
                                                if (_debounce?.isActive ??
                                                    false) _debounce!.cancel();

                                                // Start a new debounce timer
                                                _debounce = Timer(
                                                    const Duration(
                                                        milliseconds: 400),
                                                    () async {
                                                  final paidAmountText =
                                                      itemController
                                                          .totalunitEstimatedAmount
                                                          .text
                                                          .trim();
                                                  itemController
                                                          .unitAmount.text =
                                                      itemController
                                                          .totalunitEstimatedAmount
                                                          .text;
                                                  final double paidAmounts =
                                                      double.tryParse(
                                                              paidAmountText) ??
                                                          0.0;
                                                  final currency = itemController
                                                      .currencyDropDowncontrollerCA3
                                                      .text;

                                                  // Only proceed if currency and amount are provided
                                                  if (currency.isNotEmpty &&
                                                      paidAmountText
                                                          .isNotEmpty) {
                                                    // Fire API calls concurrently
                                                    final results =
                                                        await Future.wait([
                                                      itemController
                                                          .fetchExchangeRateCA(
                                                              currency,
                                                              paidAmountText),
                                                      itemController
                                                          .fetchMaxAllowedPercentage(),
                                                    ]);

                                                    // Process the first exchange rate response
                                                    final exchangeResponse1 =
                                                        results[0]
                                                            as ExchangeRateResponse?;
                                                    if (exchangeResponse1 !=
                                                        null) {
                                                      itemController.unitRateCA1
                                                              .text =
                                                          exchangeResponse1
                                                              .exchangeRate
                                                              .toString();
                                                      itemController
                                                              .amountINRCA1
                                                              .text =
                                                          exchangeResponse1
                                                              .totalAmount
                                                              .toStringAsFixed(
                                                                  2);
                                                      itemController.isVisible
                                                          .value = true;
                                                    }

                                                    // Process max allowed percentage
                                                    final maxPercentage =
                                                        results[1] as double?;

                                                    if (maxPercentage != null &&
                                                        maxPercentage > 0) {
                                                      final double
                                                          calculatedPercentage =
                                                          (paidAmounts *
                                                                  maxPercentage) /
                                                              100;

                                                      itemController
                                                              .totalRequestedAmount
                                                              .text =
                                                          calculatedPercentage
                                                              .toString();
                                                      itemController
                                                              .calculatedPercentage
                                                              .value =
                                                          calculatedPercentage;

                                                      final percentageStr =
                                                          maxPercentage
                                                              .toInt()
                                                              .toString();
                                                      itemController
                                                              .requestedPercentage
                                                              .text =
                                                          '$percentageStr %';

                                                      if (calculatedPercentage >
                                                          100) {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              'Paid amount exceeds maximum allowed percentage!',
                                                          backgroundColor:
                                                              Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                        );
                                                      }
                                                    }
                                                    final reqPaidAmount =
                                                        itemController
                                                            .totalRequestedAmount
                                                            .text
                                                            .trim();
                                                    final reqCurrency =
                                                        itemController
                                                            .currencyDropDowncontrollerCA2
                                                            .text;
                                                    if (reqCurrency
                                                            .isNotEmpty &&
                                                        reqPaidAmount
                                                            .isNotEmpty) {
                                                      final exchangeResponse =
                                                          await itemController
                                                              .fetchExchangeRateCA(
                                                                  reqCurrency,
                                                                  reqPaidAmount);

                                                      if (exchangeResponse !=
                                                          null) {
                                                        itemController
                                                                .unitRateCA2
                                                                .text =
                                                            exchangeResponse
                                                                .exchangeRate
                                                                .toString();
                                                        itemController
                                                                .amountINRCA2
                                                                .text =
                                                            exchangeResponse
                                                                .totalAmount
                                                                .toStringAsFixed(
                                                                    2);
                                                        _syncControllerToModel(
                                                            index);
                                                        _calculateTotalLineAmount(
                                                            itemController);
                                                        _calculateTotalLineAmount2(
                                                            itemController);
                                                        // itemController.isVisible.value = true;
                                                      }
                                                    }
                                                  }
                                                });
                                              },
                                              onEditingComplete: () {
                                                String text = itemController
                                                    .totalunitEstimatedAmount
                                                    .text;
                                                double? value =
                                                    double.tryParse(text);
                                                if (value != null) {
                                                  itemController
                                                          .totalunitEstimatedAmount
                                                          .text =
                                                      value.toStringAsFixed(2);
                                                }
                                              },
                                            ),
                                          ),

                                          /// Currency Dropdown
                                          Obx(
                                            () => SizedBox(
                                              width: 90,
                                              child:
                                                  SearchableMultiColumnDropdownField<
                                                      Currency>(
                                                labelText: "",
                                                alignLeft: -90,
                                                dropdownWidth: 280,
                                                columnHeaders: const [
                                                  'Code',
                                                  'Name',
                                                  'Symbol'
                                                ],
                                                controller: itemController
                                                    .currencyDropDowncontrollerCA3,
                                                items:
                                                    itemController.currencies,
                                                selectedValue: itemController
                                                    .selectedCurrencyCA1.value,
                                                backgroundColor: Colors.white,
                                                searchValue: (c) =>
                                                    '${c.code} ${c.name} ${c.symbol}',
                                                displayText: (c) => c.code,
                                                enabled:
                                                    controller.isEnable.value,
                                                inputDecoration:
                                                    const InputDecoration(
                                                  suffixIcon: Icon(Icons
                                                      .arrow_drop_down_outlined),
                                                  filled: true,
                                                  fillColor: Color(0xFFF7F7F7),
                                                  isDense: true,
                                                  // contentPadding: EdgeInsets.symmetric(
                                                  //     horizontal: 8, vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                validator: (c) => c == null
                                                    ? 'Please select a currency'
                                                    : null,
                                                onChanged: (c) async {
                                                  itemController
                                                      .selectedCurrencyCA1
                                                      .value = c;
                                                  itemController
                                                      .currencyDropDowncontrollerCA3
                                                      .text = c?.code ?? '';

                                                  final paidAmount = itemController
                                                      .totalunitEstimatedAmount
                                                      .text
                                                      .trim();
                                                  if (paidAmount.isNotEmpty) {
                                                    final exchangeResponse =
                                                        await itemController
                                                            .fetchExchangeRateCA(
                                                      c!.code,
                                                      paidAmount,
                                                    );

                                                    if (exchangeResponse !=
                                                        null) {
                                                      itemController.unitRateCA1
                                                              .text =
                                                          exchangeResponse
                                                              .exchangeRate
                                                              .toString();
                                                      itemController
                                                              .amountINRCA1
                                                              .text =
                                                          exchangeResponse
                                                              .totalAmount
                                                              .toStringAsFixed(
                                                                  2);
                                                    }
                                                  }
                                                },
                                                rowBuilder: (c, searchQuery) {
                                                  Widget highlight(
                                                      String text) {
                                                    final lowerQuery =
                                                        searchQuery
                                                            .toLowerCase();
                                                    final lowerText =
                                                        text.toLowerCase();
                                                    final start = lowerText
                                                        .indexOf(lowerQuery);
                                                    if (start == -1 ||
                                                        searchQuery.isEmpty) {
                                                      return Text(text,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      12));
                                                    }
                                                    final end = start +
                                                        searchQuery.length;
                                                    return RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                text.substring(
                                                                    0, start),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                text.substring(
                                                                    start, end),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: text
                                                                .substring(end),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }

                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6,
                                                        horizontal: 8),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            child: highlight(
                                                                c.code)),
                                                        Expanded(
                                                            child: highlight(
                                                                c.name)),
                                                        Expanded(
                                                            child: highlight(
                                                                c.symbol)),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          /// Rate Field
                                          Expanded(
                                            child: TextFormField(
                                              enabled: false,
                                              controller:
                                                  itemController.unitRateCA1,
                                              decoration: const InputDecoration(
                                                hintText: 'Rate',
                                                isDense: true,

                                                // contentPadding:
                                                //     EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Amount in INR
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: itemController.amountINRCA1,
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Amount in INR *',
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Total Requested Amount  *',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          // Paid Amount Text Field
                                          Expanded(
                                            flex: 2,
                                            child: TextFormField(
                                              controller: itemController
                                                  .totalRequestedAmount,
                                              enabled: false,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                hintText: 'Paid Amount',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              onChanged: (_) async {
                                                final paidAmount =
                                                    itemController
                                                        .totalRequestedAmount
                                                        .text
                                                        .trim();
                                                final currency = itemController
                                                    .currencyDropDowncontrollerCA2
                                                    .text;

                                                if (currency.isNotEmpty &&
                                                    paidAmount.isNotEmpty) {
                                                  final exchangeResponse =
                                                      await itemController
                                                          .fetchExchangeRateCA(
                                                              currency,
                                                              paidAmount);

                                                  if (exchangeResponse !=
                                                      null) {
                                                    itemController
                                                            .unitRateCA2.text =
                                                        exchangeResponse
                                                            .exchangeRate
                                                            .toString();
                                                    itemController
                                                            .amountINRCA2.text =
                                                        exchangeResponse
                                                            .totalAmount
                                                            .toStringAsFixed(2);
                                                    itemController
                                                        .isVisible.value = true;
                                                  }
                                                }
                                              },
                                              onEditingComplete: () {
                                                String text = itemController
                                                    .totalRequestedAmount.text;
                                                double? value =
                                                    double.tryParse(text);
                                                if (value != null) {
                                                  itemController
                                                          .totalRequestedAmount
                                                          .text =
                                                      value.toStringAsFixed(2);
                                                }
                                              },
                                            ),
                                          ),

                                          // Currency Dropdown
                                          Obx(
                                            () => SizedBox(
                                              width: 90,
                                              child:
                                                  SearchableMultiColumnDropdownField<
                                                      Currency>(
                                                labelText: "",
                                                alignLeft: -90,
                                                enabled:
                                                    controller.isEnable.value,
                                                dropdownWidth: 280,
                                                columnHeaders: const [
                                                  'Code',
                                                  'Name',
                                                  'Symbol'
                                                ],
                                                controller: itemController
                                                    .currencyDropDowncontrollerCA2,
                                                items: controller.currencies,
                                                selectedValue: itemController
                                                    .selectedCurrencyCA2.value,
                                                backgroundColor: Colors.white,
                                                searchValue: (c) =>
                                                    '${c.code} ${c.name} ${c.symbol}',
                                                displayText: (c) => c.code,
                                                inputDecoration:
                                                    const InputDecoration(
                                                  isDense: true,
                                                  suffixIcon: Icon(Icons
                                                      .arrow_drop_down_outlined),
                                                  filled: true,
                                                  fillColor: Color(0xFFF7F7F7),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                validator: (c) => c == null
                                                    ? 'Please select currency'
                                                    : null,
                                                onChanged: (c) async {
                                                  itemController
                                                      .selectedCurrencyCA2
                                                      .value = c;
                                                  controller
                                                      .currencyDropDowncontrollerCA2
                                                      .text = c?.code ?? '';

                                                  final paidAmount =
                                                      itemController
                                                          .totalRequestedAmount
                                                          .text
                                                          .trim();
                                                  if (paidAmount.isNotEmpty) {
                                                    final exchangeResponse =
                                                        await itemController
                                                            .fetchExchangeRateCA(
                                                                c!.code,
                                                                paidAmount);

                                                    if (exchangeResponse !=
                                                        null) {
                                                      itemController.unitRateCA2
                                                              .text =
                                                          exchangeResponse
                                                              .exchangeRate
                                                              .toString();
                                                      itemController
                                                              .amountINRCA2
                                                              .text =
                                                          exchangeResponse
                                                              .totalAmount
                                                              .toStringAsFixed(
                                                                  2);
                                                      _syncControllerToModel(
                                                          index);
                                                      _calculateTotalLineAmount(
                                                          itemController);
                                                      _calculateTotalLineAmount2(
                                                          itemController);
                                                    }
                                                  }
                                                },
                                                rowBuilder: (c, searchQuery) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6,
                                                        horizontal: 8),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            child:
                                                                Text(c.code)),
                                                        Expanded(
                                                            child:
                                                                Text(c.name)),
                                                        Expanded(
                                                            child:
                                                                Text(c.symbol)),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          // Rate Field
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  itemController.unitRateCA2,
                                              enabled: false,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                hintText: 'Rate',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                      // Amount in INR
                                      TextFormField(
                                        controller: itemController.amountINRCA2,
                                        enabled: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Amount in INR *',
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (controller.isEnable.value)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          final double lineAmount =
                                              double.tryParse(itemController
                                                      .lineAmount.text) ??
                                                  0.0;
                                          if (itemController.split.isEmpty &&
                                              item.accountingDistributions!
                                                  .isNotEmpty) {
                                            itemController.split.assignAll(
                                              item.accountingDistributions!
                                                  .map((e) {
                                                return AccountingSplit(
                                                  paidFor: e.dimensionValueId,
                                                  percentage:
                                                      e.allocationFactor,
                                                  amount: e.transAmount,
                                                );
                                              }).toList(),
                                            );
                                          } else if (itemController
                                              .split.isEmpty) {
                                            itemController.split.add(
                                                AccountingSplit(
                                                    percentage: 100.0));
                                          }

                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                            ),
                                            builder: (context) => Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                                left: 16,
                                                right: 16,
                                                top: 24,
                                              ),
                                              child: SingleChildScrollView(
                                                child:
                                                    AccountingDistributionWidget(
                                                  splits: itemController.split,
                                                  lineAmount: lineAmount,
                                                  onChanged: (i, updatedSplit) {
                                                    if (!mounted) return;
                                                    itemController.split[i] =
                                                        updatedSplit;
                                                    _syncControllerToModel(
                                                        index);
                                                  },
                                                  onDistributionChanged:
                                                      (newList) {
                                                    if (!mounted) return;
                                                    item.accountingDistributions!
                                                        .clear();
                                                    item.accountingDistributions!
                                                        .addAll(newList);
                                                    _syncControllerToModel(
                                                        index);
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
              title: "Tracking History",
              children: [
                const SizedBox(height: 12),
                FutureBuilder<List<ExpenseHistory>>(
                  future: historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
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
            if (widget.items!.workitemrecid == null) ...[
              if (controller.isEnable.value &&
                  widget.items!.approvalStatus == "Rejected")
                Obx(() {
                  final isResubmitLoading =
                      controller.buttonLoaders['resubmit'] ?? false;
                  final isAnyLoading =
                      controller.buttonLoaders.values.any((loading) => loading);

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Color.fromARGB(
                            255, 29, 1, 128), // Purple gradient replaced
                      ),
                      onPressed: (isResubmitLoading || isAnyLoading)
                          ? null
                          : () {
                              controller.setButtonLoading('resubmit', true);
                              controller.cashAdvanceReturnFinalItem(widget
                                  .items!); // ✅ Now only 1 argument needed

                              controller
                                  .saveinEditCashAdvance(
                                      context,
                                      true,
                                      true,
                                      widget.items!.recId,
                                      widget.items!.requisitionId)
                                  .whenComplete(() {
                                controller.setButtonLoading('resubmit', false);
                              });
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
                          : const Text(
                              "Resubmit",
                              style: TextStyle(
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
                      final isAnyLoading = controller.buttonLoaders.values
                          .any((loading) => loading);

                      return Expanded(
                        child: ElevatedButton(
                          onPressed: (isUpdateLoading || isAnyLoading)
                              ? null
                              : () {
                                  controller.setButtonLoading('update', true);
                                  // controller.addToFinalItems(widget.items!);
                                  controller
                                      .saveinEditCashAdvance(
                                          context,
                                          false,
                                          false,
                                          widget.items!.recId,
                                          widget.items!.requisitionId)
                                      .whenComplete(() {
                                    controller.setButtonLoading(
                                        'update', false);
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1E7503), // Green button
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.chancelButton(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text(
                          "Cancel",
                       
                        ),
                      ),
                    ),
                  ],
                )
              else if (controller.isEnable.value &&
                  widget.items!.approvalStatus == "Created") ...[
                Obx(() {
                  final isSubmitLoading =
                      controller.buttonLoaders['submit'] ?? false;
                  final isAnyLoading =
                      controller.buttonLoaders.values.any((loading) => loading);

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
                              controller.setButtonLoading('submit', true);

                              controller
                                  .cashAdvanceReturnFinalItem(widget.items!);

                              // controller.addToFinalItems(widget.items!);
                              controller
                                  .saveinEditCashAdvance(
                                      context,
                                      true,
                                      false,
                                      widget.items!.recId,
                                      widget.items!.requisitionId)
                                  .whenComplete(() {
                                controller.setButtonLoading('submit', false);
                              });
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
                          : const Text(
                              "Submit",
                              style: TextStyle(
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
                      final isAnyLoading = controller.buttonLoaders.values
                          .any((loading) => loading);

                      return Expanded(
                        child: ElevatedButton(
                          onPressed: (isSaveLoading ||
                                  isSubmitLoading ||
                                  isAnyLoading)
                              ? null
                              : () {
                                  controller.setButtonLoading('saveGE', true);
                                  controller.cashAdvanceReturnFinalItem(
                                      widget.items!);

                                  controller
                                      .saveinEditCashAdvance(
                                          context,
                                          false,
                                          false,
                                          widget.items!.recId,
                                          widget.items!.requisitionId)
                                      .whenComplete(() {
                                    controller.setButtonLoading(
                                        'saveGE', false);
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1E7503), // Green button
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
                              : const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      );
                    }),
                    const SizedBox(width: 12),

                    // 🟠 Cancel Button
                    Obx(() {
                      final isAnyLoading = controller.buttonLoaders.values
                          .any((loading) => loading);

                      return Expanded(
                        child: ElevatedButton(
                          onPressed: isAnyLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(context,
                                      AppRoutes.cashAdvanceRequestDashboard);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Cancel",
                         
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                // Add space before Submit button

                // 🟣 Submit Button
              ],
              if (controller.isEnable.value &&
                  widget.items!.approvalStatus == "Pending")
                Row(
                  children: [
                    // Obx(() {
                    //   final isLoading =
                    //       controller.buttonLoaders['cancel'] ?? false;
                    //   return Expanded(
                    //     child: ElevatedButton(
                    //       onPressed: isLoading
                    //           ? null
                    //           : () {
                    //               controller.setButtonLoading('cancel', true);
                    //               controller
                    //                   .cancelExpense(context,
                    //                       widget.items!.recId.toString())
                    //                   .whenComplete(() {
                    //                 controller.setButtonLoading(
                    //                     'cancel', false);
                    //               });
                    //             },
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor:
                    //             const Color(0xFFE99797), // Red cancel button
                    //       ),
                    //       child: isLoading
                    //           ? const SizedBox(
                    //               height: 20,
                    //               width: 20,
                    //               child: CircularProgressIndicator(
                    //                 color: Colors.red,
                    //                 strokeWidth: 2,
                    //               ),
                    //             )
                    //           : const Text(
                    //               "Cancel",
                    //               style: TextStyle(color: Colors.red),
                    //             ),
                    //     ),
                    //   );
                    // }),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.chancelButton(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text(
                          "Close",
                       
                        ),
                      ),
                    ),
                  ],
                )
              else if (!controller.isEnable.value)
                ElevatedButton(
                  onPressed: () {
                    controller.chancelButton(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text(
                    "Cancel",
                 
                  ),
                ),
            ] else ...[
              if (controller.isEnable.value &&
                  widget.items!.stepType == "Review")
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🔵 Row 1: Update & Accept + Update
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final isLoadingAccept =
                                  controller.buttonLoaders['update_accept'] ??
                                      false;
                              final isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingAccept || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'update_accept', true);
                                        controller.cashAdvanceReturnFinalItem(
                                            widget.items!);

                                        try {
                                          await controller
                                              .reviewandUpdateCashAdvance(
                                                  context,
                                                  true,
                                                  widget.items!.recId,
                                                  widget.items!.requisitionId);
                                        } finally {
                                          controller.setButtonLoading(
                                              'update_accept', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 20, 117),
                                ),
                                child: isLoadingAccept
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Update & Accept",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final isLoadingUpdate =
                                  controller.buttonLoaders['update_review'] ??
                                      false;
                              final isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingUpdate || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'update_review', true);
                                        controller.cashAdvanceReturnFinalItem(
                                            widget.items!);

                                        try {
                                          await controller
                                              .reviewandUpdateCashAdvance(
                                                  context,
                                                  false,
                                                  widget.items!.recId,
                                                  widget.items!.requisitionId);
                                        } finally {
                                          controller.setButtonLoading(
                                              'update_review', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 20, 117),
                                ),
                                child: isLoadingUpdate
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Update",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🔴 Row 2: Reject + Close
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final isLoadingReject =
                                  controller.buttonLoaders['reject_review'] ??
                                      false;
                              final isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingReject || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'reject_review', true);
                                        try {
                                          showActionPopup(context, "Reject");
                                        } finally {
                                          controller.setButtonLoading(
                                              'reject_review', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 238, 20, 20),
                                ),
                                child: isLoadingReject
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Reject",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final isLoadingClose =
                                  controller.buttonLoaders['close_review'] ??
                                      false;
                              final isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingClose || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'close_review', true);
                                        try {
                                          controller.chancelButton(context);
                                        } finally {
                                          controller.setButtonLoading(
                                              'close_review', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: isLoadingClose
                                    ? const CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Close",
                                     
                                      ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // APPROVAL SECTION
              if (controller.isEnable.value &&
                  widget.items!.stepType == "Approval")
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                        controller.setButtonLoading(
                                            'approve', true);
                                        try {
                                          showActionPopup(context, "Approve");
                                        } finally {
                                          controller.setButtonLoading(
                                              'approve', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 30, 117, 3),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Approve",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final isLoading =
                                  controller.buttonLoaders['reject_approval'] ??
                                      false;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'reject_approval', true);
                                        try {
                                          showActionPopup(context, "Reject");
                                        } finally {
                                          controller.setButtonLoading(
                                              'reject_approval', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 238, 20, 20),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Reject",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                        ],
                      ),
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
                                        controller.setButtonLoading(
                                            'escalate', true);
                                        try {
                                          showActionPopup(context, "Escalate");
                                        } finally {
                                          controller.setButtonLoading(
                                              'escalate', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 20, 117),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Escalate",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final isLoading =
                                  controller.buttonLoaders['close_approval'] ??
                                      false;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'close_approval', true);
                                        try {
                                          controller.chancelButton(context);
                                        } finally {
                                          controller.setButtonLoading(
                                              'close_approval', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Close",
                                     
                                      ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ]),
        ),
      ),
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
                        columnHeaders: const [
                          'User Name',
                          'User ID',
                        ],
                        items: controller.userList,
                        selectedValue: controller.selectedUser.value,
                        searchValue: (user) => '${user.userName} ${user.userId}',
                        displayText: (user) => user.userId,
                        onChanged: (user) {
                          controller.userIdController.text = user?.userId ?? '';
                          controller.selectedUser.value = user;
                        },
                        controller: controller.userIdController,
                        rowBuilder: (user, searchQuery) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
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
                  const Text(
                    'Comment',
                    style: TextStyle(fontSize: 16),
                  ),
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
                      errorText: isCommentError ? 'Comment is required.' : null,
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
                            builder: (ctx) => const Center(
                              child: SkeletonLoaderPage(),
                            ),
                          );

                          final success = await controller.postApprovalActioncashAdvance(
                            context,
                            workitemrecid: [workitemrecid!],
                            decision: status,
                            comment: commentController.text,
                          );

                          // Hide the loading indicator
                          if (Navigator.of(context, rootNavigator: true).canPop()) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pushNamed(
                                context, AppRoutes.approvalHubMain);
                            controller.isApprovalEnable.value = false;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to submit action')),
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
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  // ... (keep all your existing helper methods below)
  Future<File?> _cropImage(File file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        )
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
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
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(file),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    // FloatingActionButton.small(
                    //   heroTag: "zoom_in_$index",
                    //   onPressed: _zoomIn,
                    //   backgroundColor: Colors.deepPurple,
                    //   child: const Icon(Icons.zoom_in),
                    // ),
                    // const SizedBox(height: 8),
                    // FloatingActionButton.small(
                    //   heroTag: "zoom_out_$index",
                    //   onPressed: _zoomOut,
                    //   backgroundColor: Colors.deepPurple,
                    //   child: const Icon(Icons.zoom_out),
                    // ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "edit_$index",
                      onPressed: () => _cropImage(file),
                      child: const Icon(Icons.edit),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "delete_$index",
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          controller.imageFiles.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.delete),
                      backgroundColor: Colors.red,
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
                          DateFormat('yyyy-MM-dd') // Adjust your format
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
                    controllers.text = DateFormat('yyyy-MM-dd').format(picked);
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
                  Text(item.eventType,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
        )
      ],
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
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
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
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onChanged: isReadOnly ? null : onChanged,
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ))
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
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: child,
          )
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            children: children,
          ),
        ),
      ),
    );
  }
}
