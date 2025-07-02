import 'dart:async';
import 'dart:io';

import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class ViewEditExpensePage extends StatefulWidget {
  final bool isReadOnly;
  final GESpeficExpense? items;
  const ViewEditExpensePage({Key? key, this.items, required this.isReadOnly})
      : super(key: key);

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
  final controller = Get.put(Controller());
  late Future<List<ExpenseHistory>> historyFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    expenseIdController.text = "";
    receiptDateController.text = "";
    merhantName.text = "";
    controller.fetchPaidto();
    controller.fetchPaidwith();
    controller.fetchProjectName();
    controller.fetchExpenseCategory();
    controller.fetchUnit();
    controller.fetchTaxGroup();
    // controller.fetchExpenseCategory()
    waitForDropdownDataAndSetValues();
    controller.currencyDropDown();
    controller.fetchExchangeRate();
    if (controller.imageFiles.isEmpty) {
      controller.fetchExpenseDocImage(widget.items!.recId);
    }

    historyFuture = controller.fetchExpenseHistory(widget.items!.recId);
    final formatted =
        DateFormat('dd/MM/yyyy').format(widget.items!.receiptDate);

    print(
        "First Transaction Description: ${widget.items!.expenseTrans[0].description}");
    print(
        "First Transaction Quantity: ${widget.items!.expenseTrans[0].quantity}");

    // controller.selectedPaidto = controller.paidTo.firstWhere(
    //   (merchant) =>
    //       merchant.merchantId ==
    //       widget.items!.merchantId, // assuming `paidTo` is an ID
    //   orElse: () => controller.paidTo.first,
    // );]
    controller.receiptDateController.text = formatted;
    controller.paymentMethodID = widget.items!.paymentMethod.toString();
    expenseIdController.text = widget.items!.expenseId.toString();
    receiptDateController.text = formatted;
    merhantName.text = widget.items!.merchantName.toString();
    referenceController.text = widget.items!.referenceNumber.toString();
    selectedPaidTo = paidToOptions.first;
    selectedPaidWith = paidWithOptions.first;
    controller.paidAmount.text = widget.items!.totalAmountTrans.toString();
    controller.unitRate.text = widget.items!.exchRate.toString();
    controller.amountINR.text = widget.items!.totalAmountReporting.toString();
    controller.currencyDropDowncontroller.text =
        widget.items!.currency.toString();
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

    // if (controller.expenseCategory.isNotEmpty) {
    //   controller.selectedCategory = controller.expenseCategory.firstWhere(
    //     (e) => e.categoryId == widget.items!.expenseCategoryId,
    //     orElse: () => controller.expenseCategory.first,
    //   );
    // }
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
        Navigator.pushNamed(context, AppRoutes.generalExpense);
        return true; // allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(controller.isEnable.value ? 'Edit Expense' : 'View Expense'),
          actions: [
            if (widget.isReadOnly)
              IconButton(
                icon: const Icon(Icons.edit_document),
                onPressed: () {
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
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() {
                    if (controller.isLoadingviewImage.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.imageFiles.isEmpty) {
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
                isReadOnly: controller.isEnable.value,
              ),
              _buildTextField(
                label: "Receipt Date",
                controller: receiptDateController,
                isReadOnly: controller.isEnable.value,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  SearchableMultiColumnDropdownField<MerchantModel>(
                    enabled: controller.isEnable.value,
                    labelText: 'Paid To',
                    columnHeaders: const ['Merchant Name', 'Merchant ID'],
                    items: controller.paidTo,
                    selectedValue: controller.selectedPaidto,
                    searchValue: (p) =>
                        '${p.merchantNames} ${p.merchantId}', // support both
                    displayText: (p) => p.merchantNames,
                    validator: (_) => null,
                    onChanged: (p) {
                      setState(() {
                        controller.selectedPaidto = p;
                      });
                    },
                    controller: merhantName,
                    rowBuilder: (p, searchQuery) {
                      Widget highlight(String text) {
                        final query = searchQuery.toLowerCase();
                        final full = text.toLowerCase();
                        final start = full.indexOf(query);

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
                            Expanded(child: highlight(p.merchantNames)),
                            Expanded(child: highlight(p.merchantId)),
                          ],
                        ),
                      );
                    },
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
                        controller.paymentMethodeID = p!.paymentMethodId;
                      });
                    },
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
                controller: referenceController,
                isReadOnly: controller.isEnable.value,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: controller.isEnable.value,
                      controller: controller.paidAmount,
                      onChanged: (_) {
                        controller.fetchExchangeRate();

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
                          controller.paidAmount.text =
                              value.toStringAsFixed(2); // Format value
                        }
                        // Call once
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
                                          const TextStyle(color: Colors.white));
                                }

                                final end = matchIndex + query.length;
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: text.substring(0, matchIndex),
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                            color: Colors.white),
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
                      // initialValue: controller.unitRate,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 20),
              // Amount in INR
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items!.expenseTrans.length,
                itemBuilder: (context, index) {
                  final item = widget.items!.expenseTrans[index];
                  print("itemsssitem$item");
                  controller.projectDropDowncontroller.text = item.projectId;
                  if (controller.project.isNotEmpty) {
                    controller.selectedProjectForView =
                        controller.project.firstWhere(
                      (merchant) =>
                          merchant.code ==
                          item.projectId, // assuming `paidTo` is an ID
                      orElse: () => controller.project.first,
                    );
                  }
                  ;

                  // controller.unitRate.text = item.uomId;
                  controller.projectDropDowncontroller.text = item.projectId;
                  controller.descriptionController.text = item.description;
                  controller.unitAmountView.text =
                      item.unitPriceTrans.toString();
                  controller.lineAmount.text = item.lineAmountTrans.toString();
                  controller.lineAmountINR.text =
                      item.lineAmountReporting.toString();
                  controller.taxAmount.text = item.taxAmount.toString();
                  controller.taxGroupController.text = item.taxGroup.toString();
                  controller.categoryController.text =
                      item.expenseCategoryId.toString();
                  controller.unitRateID.text = item.uomId;
                  // controller.selectedunit =
                  //     controller.unit.firstWhere(
                  //   (merchant) =>
                  //       merchant.code == widget.items!.:,
                  //   orElse: () => controller.expenseCategory.first,
                  // );
                  return Card(
                      // margin: const EdgeInsets.symmetric(vertical: 6),
                      color: Colors.transparent,
                      elevation: 0,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSection(
                                    title: "Itemize ${index + 1}",
                                    children: [
                                      const SizedBox(height: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SearchableMultiColumnDropdownField<
                                              Project>(
                                            enabled: controller.isEnable.value,
                                            labelText: 'Project',
                                            columnHeaders: const [
                                              'Project Name',
                                              'Project ID'
                                            ],
                                            items: controller.project,
                                            selectedValue:
                                                controller.selectedProject,
                                            searchValue: (p) =>
                                                '${p.name} ${p.code}',
                                            displayText: (p) => p.code,
                                            validator: (_) => null,
                                            onChanged: (p) {
                                              setState(() {
                                                controller.selectedProject = p;
                                                controller
                                                    .projectDropDowncontroller
                                                    .text = p!.code;
                                              });
                                            },
                                            controller: controller
                                                .projectDropDowncontroller,
                                            rowBuilder: (p, searchQuery) {
                                              Widget highlight(String text) {
                                                final query =
                                                    searchQuery.toLowerCase();
                                                final lowerText =
                                                    text.toLowerCase();
                                                final matchIndex =
                                                    lowerText.indexOf(query);

                                                if (matchIndex == -1 ||
                                                    query.isEmpty)
                                                  return Text(text);

                                                final end =
                                                    matchIndex + query.length;
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: text.substring(
                                                            0, matchIndex),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      TextSpan(
                                                        text: text.substring(
                                                            matchIndex, end),
                                                        style: const TextStyle(
                                                          color: Colors.black,
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
                                                            highlight(p.name)),
                                                    Expanded(
                                                        child:
                                                            highlight(p.code)),
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
                                                controller.selectedCategory,
                                            searchValue: (p) =>
                                                '${p.categoryName} ${p.categoryId}',
                                            displayText: (p) => p.categoryId,
                                            validator: (_) => null,
                                            onChanged: (p) {
                                              setState(() {
                                                controller.selectedCategory = p;
                                              });
                                            },
                                            controller:
                                                controller.categoryController,
                                            rowBuilder: (p, searchQuery) {
                                              Widget highlight(String text) {
                                                final query =
                                                    searchQuery.toLowerCase();
                                                final lower =
                                                    text.toLowerCase();
                                                final matchIndex =
                                                    lower.indexOf(query);

                                                if (matchIndex == -1 ||
                                                    query.isEmpty)
                                                  return Text(text);

                                                final end =
                                                    matchIndex + query.length;
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: text.substring(
                                                            0, matchIndex),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      TextSpan(
                                                        text: text.substring(
                                                            matchIndex, end),
                                                        style: const TextStyle(
                                                          color: Colors.black,
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
                                                        child: highlight(
                                                            p.categoryName)),
                                                    Expanded(
                                                        child: highlight(
                                                            p.categoryId)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _buildTextField(
                                            label: "Comments",
                                            controller: controller
                                                .descriptionController,
                                            isReadOnly:
                                                controller.isEnable.value,
                                          ),
                                          SearchableMultiColumnDropdownField<
                                              Unit>(
                                            labelText: 'Unit *',
                                            enabled: controller.isEnable.value,
                                            columnHeaders: const [
                                              'Uom Id',
                                              'Uom Name'
                                            ],
                                            items: controller.unit,
                                            selectedValue:
                                                controller.selectedunit,
                                            searchValue: (tax) =>
                                                '${tax.code} ${tax.name}',
                                            displayText: (tax) => tax.name,
                                            validator: (tax) => tax == null
                                                ? 'Please select a Unit'
                                                : null,
                                            onChanged: (tax) {
                                              setState(() {
                                                controller.selectedunit = tax;
                                              });
                                            },
                                            controller: controller.unitRateID,
                                            rowBuilder: (tax, searchQuery) {
                                              Widget highlight(String text) {
                                                final query =
                                                    searchQuery.toLowerCase();
                                                final lower =
                                                    text.toLowerCase();
                                                final matchIndex =
                                                    lower.indexOf(query);

                                                if (matchIndex == -1 ||
                                                    query.isEmpty)
                                                  return Text(text);

                                                final end =
                                                    matchIndex + query.length;
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: text.substring(
                                                            0, matchIndex),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      TextSpan(
                                                        text: text.substring(
                                                            matchIndex, end),
                                                        style: const TextStyle(
                                                          color: Colors.black,
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
                                                        child: highlight(
                                                            tax.code)),
                                                    Expanded(
                                                        child: highlight(
                                                            tax.name)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _buildTextField(
                                            label: "Unit Amount *",
                                            controller:
                                                controller.unitAmountView,
                                            isReadOnly:
                                                controller.isEnable.value,
                                          ),
                                          _buildTextField(
                                            label: "Line Amount",
                                            controller: controller.lineAmount,
                                            isReadOnly:
                                                controller.isEnable.value,
                                          ),
                                          _buildTextField(
                                            label: "Line Amount in INR",
                                            controller:
                                                controller.lineAmountINR,
                                            isReadOnly:
                                                controller.isEnable.value,
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
                                            selectedValue:
                                                controller.selectedTax,
                                            searchValue: (tax) =>
                                                '${tax.taxGroup} ${tax.taxGroupId}',
                                            displayText: (tax) =>
                                                tax.taxGroupId,
                                            onChanged: (tax) {
                                              setState(() {
                                                controller.selectedTax = tax;
                                              });
                                            },
                                            controller:
                                                controller.taxGroupController,
                                            rowBuilder: (tax, searchQuery) {
                                              Widget highlight(String text) {
                                                final query =
                                                    searchQuery.toLowerCase();
                                                final lower =
                                                    text.toLowerCase();
                                                final matchIndex =
                                                    lower.indexOf(query);

                                                if (matchIndex == -1 ||
                                                    query.isEmpty)
                                                  return Text(text);

                                                final end =
                                                    matchIndex + query.length;
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: text.substring(
                                                            0, matchIndex),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      TextSpan(
                                                        text: text.substring(
                                                            matchIndex, end),
                                                        style: const TextStyle(
                                                          color: Colors.black,
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

                                              return Container(
                                                color: Colors.grey[300],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: highlight(
                                                            tax.taxGroup)),
                                                    Expanded(
                                                        child: highlight(
                                                            tax.taxGroupId)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _buildTextField(
                                            label: "Tax Amount",
                                            controller: controller.taxAmount,
                                            isReadOnly:
                                                controller.isEnable.value,
                                          ),
                                          const SizedBox(height: 12),
                                          SwitchListTile(
                                            title:
                                                const Text("Is Reimbursable"),
                                            value: item.isReimbursable,
                                            onChanged: (val) {
                                              setState(() {
                                                // controller.isReimbursite = val;
                                              });
                                            },
                                          ),
                                          SwitchListTile(
                                            title: const Text("Is Billable"),
                                            value: item.isReimbursable,
                                            onChanged: (val) {
                                              setState(() {});
                                            },
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () {},
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
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ])));
                },
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

              if (controller.isEnable.value)
                Obx(() {
                  return SizedBox(
                    width: double.infinity, // Make button full width
                    child: GradientButton(
                        text: "Submit",
                        isLoading: controller.buttonLoader.value,
                        onPressed: () {
                          controller.saveGeneralExpense(context, true);
                        }),
                  );
                }),
              if (controller.isEnable.value) const SizedBox(height: 20),
              if (controller.isEnable.value)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.saveinviewPageGeneralExpense(
                              context, false);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E6EFF)),
                        child: const Text("Save"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Cancel"),
                )
            ],
          ),
        ),
      ),
    );
  }

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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isReadOnly,
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
