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

class ViewCashAdvanseReturnForm extends StatefulWidget {
  final CashAdvanceRequestHeader? items;
  const ViewCashAdvanseReturnForm({Key? key, this.items})
      : super(key: key);

  @override
  State<ViewCashAdvanseReturnForm> createState() => _ViewCashAdvanseReturnFormState();
}

class _ViewCashAdvanseReturnFormState extends State<ViewCashAdvanseReturnForm>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();

  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  late Future<List<ExpenseHistory>> historyFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _showHistory = false;

  // New state variables for itemize management
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  bool showItemizeDetails = true;
  List<Controller> itemizeControllers = [];

  @override
  void initState() {
    super.initState();
    expenseIdController.text = "";
    requestDateController.text = "";
    merhantName.text = "";

    controller.fetchPaidto();
    controller.fetchPaidwith();
    controller.fetchProjectName();
    controller.fetchExpenseCategory();
    controller.fetchUnit();
    controller.fetchTaxGroup();
    controller.currencyDropDown();
    // controller.fetchExchangeRate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
     
      // calculateAmounts(widget.items!..toString());
    });
    controller.fetchExpenseDocImage(widget.items!.recId);

    historyFuture = controller.fetchExpenseHistory(widget.items!.recId);

    // final formatted =
    //     DateFormat('dd/MM/yyyy').format(widget.items!.requestDate as DateTime);
    // controller.selectedDate = widget.items!.requestDate;
    // requestDateController.text = formatted;
    if (widget.items != null && widget.items!.prefferedPaymentMethod != null) {
      controller.paymentMethodID = widget.items!.prefferedPaymentMethod.toString();
    }

    expenseIdController.text = widget.items!.referenceId.toString();
    // requestDateController.text = formatted;
   

 

    print('--- AccountingDistributions Added ---');
    controller.referenceID.text =
        widget.items?.referenceId?.toString() ?? '';
    if (widget.items != null && widget.items!.prefferedPaymentMethod != null) {
      controller.paidWithController.text = widget.items!.prefferedPaymentMethod!;
    } else {
      controller.paidWithController.text = ''; // or set a default value
    }

    selectedPaidTo = paidToOptions.first;
    selectedPaidWith = paidWithOptions.first;
    controller.paidAmount.text = widget.items!.totalEstimatedAmountInReporting.toString();
    controller.unitAmount.text = widget.items!.totalEstimatedAmountInReporting.toString();
    controller.unitRate.text = widget.items!.totalEstimatedAmountInReporting.toString();
    // calculateAmounts(controller.exchangeRate.text);
    controller.amountINR.text = widget.items!.totalEstimatedAmountInReporting.toString();
    controller.expenseID = widget.items!.referenceId;
    controller.recID = widget.items!.recId;
 
  

    // Initialize itemize controllers
    _initializeItemizeControllers();
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
      controller.taxGroupController.text = item.taxGroup ?? '';
      controller.categoryController.text = item.expenseCategoryId!;
      controller.uomId.text = item.uomId!;
  
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
          item.accountingDistributions!.map((dist) {
            return AccountingDistribution(
              transAmount: dist.transAmount ?? 0.0,
              reportAmount: dist.reportAmount ?? 0.0,
              allocationFactor: dist.allocationFactor ?? 0.0,
              dimensionValueId: dist.dimensionValueId ?? '',
              // recId: dist.recId ?? 0,
            );
          }),
        );
        print('--- AccountingDistributions Added ---');
        for (var dist in controller.accountingDistributions) {
          print(
              'TransAmount: ${dist?.transAmount}, ReportAmount: ${dist?.reportAmount}, '
              'AllocationFactor: ${dist?.allocationFactor}, DimensionValueId: ${dist?.dimensionValueId}');
        }
        print('--------------------------------------');
      }
      return controller;
    }).toList();
    _itemizeCount = widget.items!.cshCashAdvReqTrans.length;
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
        // Create new ExpenseItem with default values
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
          uomId: controller.unit.isNotEmpty ? controller.unit.first.code : '',
          taxGroup: controller.taxGroup.isNotEmpty
              ? controller.taxGroup.first.taxGroupId
              : '',
          accountingDistributions: [],
        );
        debugPrint("Added new item: ${newItem.toString()}");

        // widget.items!.cshCashAdvReqTrans.add(newItem);

        // Create and initialize new controller
        final newController = Controller();

        // Initialize controller with default values
        newController.descriptionController.text = newItem.description ?? '';
        newController.quantity.text = newItem.quantity.toString();
        newController.unitPriceTrans.text = newItem.unitPriceTrans.toString();
        newController.lineAmount.text = newItem.lineAmountTrans.toString();
        newController.lineAmountINR.text =
            newItem.lineAmountReporting.toString();
        newController.taxAmount.text = newItem.taxAmount.toString();
        newController.projectDropDowncontroller.text = newItem.projectId ?? '';
        newController.categoryController.text = newItem.expenseCategoryId;
        newController.uomId.text = newItem.uomId;
        newController.taxGroupController.text = newItem.taxGroup ?? '';
        newController.isReimbursable = newItem.isReimbursable;
        newController.isBillableCreate = newItem.isBillable;

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

        if (controller.taxGroup.isNotEmpty) {
          newController.selectedTax = controller.taxGroup.firstWhere(
            (t) => t.taxGroupId == newItem.taxGroup,
            orElse: () => controller.taxGroup.first,
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
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              controller.isEnable.value ? 'Edit Expense' : 'Views Expense'),
          actions: [
            if (
                widget.items != null &&
                widget.items!.approvalStatus != "Approved" &&
                widget.items!.approvalStatus != "Cancelled")
              IconButton(
                icon: const Icon(Icons.edit_document),
                onPressed: () {
                  // controller.fetchExchangeRate();
                  setState(() {
                    controller.isEnable.value = true;
                  });
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
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
                label: "Expense ID *",
                controller: expenseIdController,
                isReadOnly: false,
              ),
              buildDateField(
                "Receipt Date",
                requestDateController,
                isReadOnly: !controller.isEnable.value, // pass manually
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
                                  if (controller.isManualEntryMerchant) {
                                    controller.selectedPaidto = null;
                                  } else {
                                    controller.manualPaidToController.clear();
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
                  if (!controller.isManualEntryMerchant)
                    AbsorbPointer(
                      absorbing: !controller.isEnable.value,
                      child: SearchableMultiColumnDropdownField<MerchantModel>(
                        enabled: controller.isEnable.value,
                        labelText: 'Select Merchant',
                        columnHeaders: const ['Merchant Name', 'Merchant ID'],
                        items: controller.paidTo,
                        selectedValue: controller.selectedPaidto,
                        searchValue: (p) =>
                            '${p.merchantNames} ${p.merchantId}',
                        displayText: (p) => p.merchantNames,
                        validator: (_) => null,
                        onChanged: (p) {
                          setState(() {
                            controller.selectedPaidto = p;
                            controller.paidToController.text = p!.merchantId;
                          });
                        },
                        controller: controller.paidToController,
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
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: text.substring(start, end),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: text.substring(end),
                                    style: const TextStyle(color: Colors.black),
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
                                Expanded(child: highlight(p.merchantNames)),
                                Expanded(child: highlight(p.merchantId)),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  else
                    TextFormField(
                      controller: controller.manualPaidToController,
                      enabled:
                          controller.isEnable.value, // 🔥 disables text field
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
                  Widget highlight(String text) {
                    final lowerQuery = searchQuery.toLowerCase();
                    final lowerText = text.toLowerCase();
                    final start = lowerText.indexOf(lowerQuery);
                    if (start == -1 || searchQuery.isEmpty) return Text(text);

                    final end = start + searchQuery.length;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: text.substring(0, start),
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: text.substring(start, end),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: text.substring(end),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                style: const TextStyle(color: Colors.black),
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
                                style: const TextStyle(color: Colors.black),
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
              const SizedBox(height: 12),
              _buildTextField(
                label: "Reference",
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
                            double.tryParse(controller.paidAmount.text) ?? 0.0;
                        final rate =
                            double.tryParse(controller.unitRate.text) ?? 1.0;

                        final result = paid * rate;

                        controller.amountINR.text = result.toStringAsFixed(2);
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Paid Amount *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
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
                      child: Obx(() =>
                          SearchableMultiColumnDropdownField<Currency>(
                            enabled: controller.isEnable.value,
                            alignLeft: -90,
                            dropdownWidth: 280,
                            labelText: "",
                            columnHeaders: const ['Code', 'Name', 'Symbol'],
                            items: controller.currencies,
                            selectedValue: controller.selectedCurrency.value,
                            backgroundColor:
                                const Color.fromARGB(255, 22, 2, 92),
                            searchValue: (c) =>
                                '${c.code} ${c.name} ${c.symbol}',
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
                            validator: (c) =>
                                c == null ? 'Please pick a currency' : null,
                            onChanged: (c) {
                              controller.selectedCurrency.value = c;
                              controller.fetchExchangeRate();
                            },
                            controller: controller.currencyDropDowncontroller,
                            rowBuilder: (c, searchQuery) {
                              Widget highlight(String text) {
                                final query = searchQuery.toLowerCase();
                                final lowerText = text.toLowerCase();
                                final matchIndex = lowerText.indexOf(query);

                                if (matchIndex == -1 || query.isEmpty) {
                                  return Text(text,
                                      style:
                                          const TextStyle(color: Colors.black));
                                }

                                final end = matchIndex + query.length;
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: text.substring(0, matchIndex),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: text.substring(matchIndex, end),
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
                                    Expanded(child: highlight(c.code)),
                                    Expanded(child: highlight(c.name)),
                                    Expanded(child: highlight(c.symbol)),
                                  ],
                                ),
                              );
                            },
                          ))),
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
                            double.tryParse(controller.paidAmount.text) ?? 0.0;
                        final rate = double.tryParse(val) ?? 1.0;

                        // ✅ Perform calculation
                        final result = paid * rate;

                        controller.amountINR.text = result.toStringAsFixed(2);
                        controller.isVisible.value = true;
                        for (int i = 0; i < itemizeControllers.length; i++) {
                          final itemController = itemizeControllers[i];
                          final unitPrice = double.tryParse(
                                  itemController.unitPriceTrans.text) ??
                              0.0;

                          final lineAmountInINR = unitPrice * rate;
                          itemController.lineAmountINR.text =
                              lineAmountInINR.toStringAsFixed(2);

                          // Sync with the model
                          // widget.items!.cshCashAdvReqTrans[i] =
                          //     itemController.toExpenseItemUpdateModel();
                        }

                        // ✅ Trigger UI update
                        setState(() {});
                        print("Paid Amount: $paid");
                        print("Rate: $rate");
                        print(
                            "Calculated INR Amount: ${controller.amountINR.text}");
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
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (controller.isEnable.value &&
                                          widget.items!.cshCashAdvReqTrans.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _removeItemize(index),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                                        controller.projectDropDowncontroller
                                            .text = p!.code;
                                        // widget.items!.expenseTrans[index] =
                                        //     itemController
                                        //         .toExpenseItemUpdateModel(); // sync with parent list
                                      });
                                      controller.fetchExpenseCategory();
                                    },
                                    controller: itemController
                                        .projectDropDowncontroller,
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
                                                text: text.substring(
                                                    0, matchIndex),
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
                                      });
                                    },
                                    controller:
                                        itemController.categoryController,
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
                                                text: text.substring(
                                                    0, matchIndex),
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
                                                child:
                                                    highlight(p.categoryName)),
                                            Expanded(
                                                child: highlight(p.categoryId)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
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
                                                text: text.substring(
                                                    0, matchIndex),
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
                                                child: highlight(tax.code)),
                                            Expanded(
                                                child: highlight(tax.name)),
                                          ],
                                        ),
                                      );
                                    },
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
                                    },
                                  ),
                                  _buildTextField(
                                    label: "Unit Amount *",
                                    controller: itemController.unitPriceTrans,
                                    isReadOnly: controller.isEnable.value,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                          10), // Max 10 digits
                                    ],
                                    onChanged: (value) {
                                      itemController
                                          .calculateLineAmounts(itemController);
                                      setState(() {
                                        // widget.items!.expenseTrans[index] =
                                        //     itemController
                                        //         .toExpenseItemUpdateModel();
                                      });
                                    },
                                  ),
                                  _buildTextField(
                                    label: "Line Amount",
                                    controller: itemController.lineAmount,
                                    isReadOnly: false,
                                    onChanged: (value) {
                                      setState(() {
                                        // widget.items!.expenseTrans[index] =
                                            // itemController
                                            //     .toExpenseItemUpdateModel();
                                      });
                                    },
                                  ),
                                  _buildTextField(
                                    label: "Line Amount in INR",
                                    controller: itemController.lineAmountINR,
                                    isReadOnly: false,
                                    onChanged: (value) {
                                      setState(() {
                                        // widget.items!.expenseTrans[index] =
                                        //     itemController
                                        //         .toExpenseItemUpdateModel();
                                      });
                                    },
                                  ),
                                  SearchableMultiColumnDropdownField<
                                      TaxGroupModel>(
                                    enabled: controller.isEnable.value,
                                    labelText: "Tax Group",
                                    columnHeaders: const [
                                      'Tax Group',
                                      'Tax ID'
                                    ],
                                    items: controller.taxGroup,
                                    selectedValue: itemController.selectedTax,
                                    searchValue: (tax) =>
                                        '${tax.taxGroup} ${tax.taxGroupId}',
                                    displayText: (tax) => tax.taxGroupId,
                                    onChanged: (tax) {
                                      setState(() {
                                        itemController.selectedTax = tax;
                                        // widget.items!.expenseTrans[index] =
                                        //     itemController
                                        //         .toExpenseItemUpdateModel();
                                        itemController.taxGroupController.text =
                                            tax!.taxGroupId;
                                      });
                                    },
                                    controller:
                                        itemController.taxGroupController,
                                    rowBuilder: (tax, searchQuery) {
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
                                                text: text.substring(
                                                    0, matchIndex),
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

                                      return Container(
                                        // color: Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: highlight(tax.taxGroup)),
                                            Expanded(
                                                child:
                                                    highlight(tax.taxGroupId)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    label: "Tax Amount",
                                    controller: itemController.taxAmount,
                                    isReadOnly: controller.isEnable.value,
                                    onChanged: (value) {
                                      setState(() {
                                        // widget.items!.expenseTrans[index] =
                                        //     itemController
                                        //         .toExpenseItemUpdateModel();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  SwitchListTile(
                                    title: const Text("Is Reimbursable",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87)),
                                    value: itemController.isReimbursable,
                                    activeColor: Colors.green,
                                    inactiveThumbColor: Colors.grey.shade400,
                                    inactiveTrackColor: Colors.grey.shade300,
                                    onChanged: controller.isEnable.value
                                        ? (val) {
                                            setState(() {
                                              itemController.isReimbursable =
                                                  val;
                                              controller.isReimbursite = val;
                                              // widget.items!
                                              //         .expenseTrans[index] =
                                              //     itemController
                                              //         .toExpenseItemUpdateModel();
                                            });
                                          }
                                        : null,
                                  ),
                                  Obx(() => SwitchListTile(
                                        title: const Text("Is Billable",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87)),
                                        value: controller
                                            .isBillableCreate, // ✅ Add .value
                                        activeColor: Colors.blue,
                                        inactiveThumbColor:
                                            Colors.grey.shade400,
                                        inactiveTrackColor:
                                            Colors.grey.shade300,
                                        onChanged: controller.isEnable.value
                                            ? (val) {
                                                setState(() {
                                                  // widget.items!
                                                  //         .expenseTrans[index] =
                                                  //     itemController
                                                  //         .toExpenseItemUpdateModel();
                                                  controller.isBillableCreate =
                                                      val;
                                                  itemController
                                                      .isBillableCreate = val;
                                                });
                                              }
                                            : null,
                                      )),
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
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            16)),
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
                                                    splits:
                                                        itemController.split,
                                                    lineAmount: lineAmount,
                                                    onChanged:
                                                        (i, updatedSplit) {
                                                      if (!mounted) return;
                                                      itemController.split[i] =
                                                          updatedSplit;
                                                    },
                                                    onDistributionChanged:
                                                        (newList) {
                                                      if (!mounted) return;
                                                      item.accountingDistributions!
                                                          .clear();
                                                      item.accountingDistributions!
                                                          .addAll(newList);
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
                              // controller.addToFinalItems(widget.items!);
                              controller
                                  .saveinviewPageGeneralExpense(
                                      context, true, true, widget.items!.recId)
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
                                      .saveinviewPageGeneralExpense(context,
                                          false, false, widget.items!.recId)
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
                          style: TextStyle(color: Colors.black),
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
                              // controller.addToFinalItems(widget.items!);
                              controller
                                  .saveinviewPageGeneralExpense(
                                      context, true, false, widget.items!.recId)
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
                                  // controller.addToFinalItems(widget.items!);
                                  controller
                                      .saveinviewPageGeneralExpense(context,
                                          false, false, widget.items!.recId)
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
                                  controller.chancelButton(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
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
                    Obx(() {
                      final isLoading =
                          controller.buttonLoaders['cancel'] ?? false;
                      return Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  controller.setButtonLoading('cancel', true);
                                  controller
                                      .cancelExpense(context,
                                          widget.items!.recId.toString())
                                      .whenComplete(() {
                                    controller.setButtonLoading(
                                        'cancel', false);
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFE99797), // Red cancel button
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
                            backgroundColor: Colors.grey),
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.black),
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
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
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
                    FloatingActionButton.small(
                      heroTag: "zoom_in_$index",
                      onPressed: _zoomIn,
                      backgroundColor: Colors.deepPurple,
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "zoom_out_$index",
                      onPressed: _zoomOut,
                      backgroundColor: Colors.deepPurple,
                      child: const Icon(Icons.zoom_out),
                    ),
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
