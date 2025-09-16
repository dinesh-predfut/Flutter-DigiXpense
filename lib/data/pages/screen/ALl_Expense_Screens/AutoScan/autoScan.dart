import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../../l10n/app_localizations.dart';

class AutoScanExpensePage extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> apiResponse;

  const AutoScanExpensePage({
    Key? key,
    required this.imageFile,
    required this.apiResponse,
  }) : super(key: key);

  @override
  State<AutoScanExpensePage> createState() => _AutoScanExpensePageState();
}

class _AutoScanExpensePageState extends State<AutoScanExpensePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> expenseTrans;
  final controller = Get.put(Controller());
  final controllerItems = Get.put(Controller());
  bool _isItemized = false;
  bool _isSubmitAttempted = false;
  bool _isReimbursable = true;
  bool _isBillable = false;

  late PageController _pageController;
  bool allowMultSelect = false;
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController merchantController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController cashAdvanceController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController totalInINRController = TextEditingController();

  final List<ItemizeSection> itemizeSections = [];
  final PhotoViewController _photoViewController = PhotoViewController();
  @override
  void initState() {
    super.initState();
    controller.configuration();
    controller.selectedDate ??= DateTime.now();
    controller.fetchPaidto();
    controller.fetchPaidwith();
    controller.fetchProjectName();
    controller.fetchTaxGroup();
    controller.fetchUnit();
    _pageController =
        PageController(initialPage: controller.currentIndex.value);
    controller.getUserPref();
    controller.fetchExpenseCategory();
    controller.configuration();
    controller.fetchPaidwith();
    _initializeUnits();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchExchangeRate();
      controller.currencyDropDown();
    });
    expenseTrans = List<Map<String, dynamic>>.from(
        widget.apiResponse['ExpenseTrans'] ?? []);
    _isItemized = expenseTrans.length > 1 ||
        (expenseTrans.isNotEmpty && expenseTrans[0]['Description'] != null);
    _initializeFormFromApiResponse();
  }

  Future<void> _initializeUnits() async {
    await controller.fetchUnit();

    final defaultUnit = controller.unit.firstWhere(
      (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
      orElse: () => controller.unit.first,
    );

    setState(() {
      controller.selectedunit ??= defaultUnit;
    });
  }

  void _initializeFormFromApiResponse() {
    final date = DateTime.fromMillisecondsSinceEpoch(
        widget.apiResponse['ReceiptDate'] ?? 0);
    receiptDateController.text = DateFormat('dd-MMM-yyyy').format(date);
    controller.selectedDate = date;
    controller.isManualEntryMerchant = true;
    controller.manualPaidToController.text =
        widget.apiResponse['Merchant'] ?? '';
    referenceController.text = widget.apiResponse['ReferenceNumber'] ?? '';
    controller.paidAmount.text =
        (widget.apiResponse['TotalAmount'] ?? 0).toString();
    taxAmountController.text =
        (widget.apiResponse['TaxAmount'] ?? 0).toString();
    descriptionController.text = widget.apiResponse['Description'] ?? '';
    paymentMethodController.text = widget.apiResponse['PaymentMethod'] ?? '';
    currencyController.text = widget.apiResponse['Currency'] ?? '';
    commentsController.text = widget.apiResponse['Comments'] ?? '';

    double total = double.tryParse(controller.paidAmount.text) ?? 0;
    double rate = double.tryParse(controller.unitRate.text) ?? 1;
    totalInINRController.text = (total * rate).toStringAsFixed(2);

    for (var i = 0; i < expenseTrans.length; i++) {
      final item = expenseTrans[i];
      itemizeSections.add(ItemizeSection(
        index: i + 1,
        category: item['ExpenseCategory'] ?? '',
        description: item['Description'] ?? '',
        quantity: (item['Quantity'] ?? 1).toString(),
        unitPrice: (item['UnitPriceTrans'] ?? 0).toString(),
        uomId: item['UomId'] ?? '',
        taxAmount: (item['TaxAmount'] ?? 0).toString(),
        isReimbursable: item['IsReimbursable'] ?? true,
        isBillable: item['IsBillable'] ?? false,
        onDelete: i > 0 ? () => _removeItemizeSection(i) : null,
        updateTotalAmount: _updateTotalAmount,
      ));
    }

    if (_isItemized) {
      _updateTotalAmount();
    }
  }

  void _updateTotalAmount() {
    double total = 0.0;
    for (var section in itemizeSections) {
      total += double.tryParse(section.lineAmountController.text) ?? 0.0;
    }
    setState(() {
      controller.paidAmount.text = total.toStringAsFixed(2);
      double rate = double.tryParse(controller.unitRate.text) ?? 1.0;
      totalInINRController.text = (total * rate).toStringAsFixed(2);
    });
  }

  void _addItemizeSection() {
    setState(() {
      itemizeSections.add(ItemizeSection(
        index: itemizeSections.length + 1,
        onDelete: itemizeSections.isNotEmpty
            ? () => _removeItemizeSection(itemizeSections.length)
            : null,
        updateTotalAmount: _updateTotalAmount,
      ));
    });
  }

  void _removeItemizeSection(int index) {
    setState(() {
      itemizeSections.removeAt(index);
      for (int i = index; i < itemizeSections.length; i++) {
        itemizeSections[i].index = i + 1;
      }
      _updateTotalAmount();
    });
  }

  void _submitForm(bool bool) {
    if (_formKey.currentState!.validate()) {
      print("Form is valid");
    } else {
      print("Form is invalid");
      return;
    }

    controller.taxAmount.text = taxAmountController.text;
    controller.descriptionController.text = descriptionController.text;
    controller.rememberMe = _isReimbursable;
    controller.isBillable.value = _isBillable;
    controller.referenceID.text = referenceController.text;
    controller.receiptDateController.text = receiptDateController.text;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.imageFile.existsSync()) {
    //     controller.imageFiles.add(widget.imageFile);
    //   }
    // });
    List<AccountingDistribution> distributions = [];
    controller.finalItems.clear();

    for (int i = 0; i < itemizeSections.length; i++) {
      final item = itemizeSections[i];
      for (final split in item.split) {
        distributions.add(
          AccountingDistribution(
            transAmount: split.amount ?? 0.0,
            reportAmount: split.amount ?? 0.0,
            allocationFactor: split.percentage,
            dimensionValueId: split.paidFor ?? '',
          ),
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.imageFile.existsSync()) {
          controller.imageFiles.add(widget.imageFile);
        }
      });
      controller.finalItems.add(
        ExpenseItem(
          expenseCategoryId: item.categoryController.text.trim(),
          quantity: double.tryParse(item.quantityController.text) ?? 0,
          uomId: item.uomIdController.text.trim(),
          unitPriceTrans: double.tryParse(item.unitPriceController.text) ?? 0,
          taxAmount: double.tryParse(item.taxAmountController.text) ?? 0,
          taxGroup: controller.selectedTax?.taxGroupId ?? '',
          lineAmountTrans: double.tryParse(item.lineAmountController.text) ?? 0,
          lineAmountReporting:
              double.tryParse(item.lineAmountINRController.text) ?? 0,
          projectId: controller.projectDropDowncontroller.text,
          description: item.descriptionController.text.trim(),
          isReimbursable: item._isReimbursable,
          isBillable: item.isBillable,
          accountingDistributions: item.accountingDistributions
              .whereType<AccountingDistribution>()
              .toList(),
        ),
      );
    }

    controller.saveGeneralExpense(context, bool, false);
  }

  // @override
  // void dispose() {
  //   receiptDateController.dispose();
  //   merchantController.dispose();
  //   referenceController.dispose();
  //   controller.paidAmount.dispose();
  //   taxAmountController.dispose();
  //   descriptionController.dispose();
  //   paymentMethodController.dispose();
  //   currencyController.dispose();
  //   cashAdvanceController.dispose();
  //   commentsController.dispose();
  //   totalInINRController.dispose();
  //   super.dispose();
  // }
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
      final croppedImage = File(croppedFile.path);
      // ignore: use_build_context_synchronously
      await controller.sendUploadedFileToServer(context, croppedImage);

      // Navigator.pushNamed(
      //   context,
      //   AppRoutes.autoScan,
      //   arguments: croppedImage,
      // );
    }

    return null;
  }

  void _zoomIn() {
    _photoViewController.scale = _photoViewController.scale! * 1.2;
  }

  void _zoomOut() {
    final currentScale =
        _photoViewController.scale ?? 1.0; // default scale if null
    _photoViewController.scale = currentScale / 1.2;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Show a confirmation dialog
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Form'),
              content: const Text(
                  'You will lose any unsaved data. Do you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // Stay here
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // Confirm exit
                  child: const Text('Yes'),
                ),
              ],
            ),
          );

          if (shouldExit ?? false) {
            controller.clearFormFields(); // ✅ Clear only if user confirms
            return true; // Allow navigation (pop)
          }

          return false; // Cancel navigation
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Auto Scan '),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Obx(() {
                  return GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: controller.imageFiles.isEmpty
                          ? Center(
                              child: Text(AppLocalizations.of(context)!
                                  .tapToUploadDocs),
                            )
                          : Stack(
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: controller.imageFiles.length,
                                  onPageChanged: (index) {
                                    setState(() {
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
                                        width: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepPurple),
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
                                    child: Obx(() => Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${controller.currentIndex.value + 1}/${controller.imageFiles.length}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        )),
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
                                              color: Colors.white, width: 2),
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
                  );
                }),
                const SizedBox(height: 20),
                Column(
                  children: [
                    TextFormField(
                      controller: receiptDateController,
                      decoration: InputDecoration(
                        labelText:
                            '${AppLocalizations.of(context)!.receiptDate} *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              receiptDateController.text =
                                  DateFormat('yyyy-MM-dd').format(date);
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select Receipt Date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    controller.isManualEntryMerchant =
                                        !controller.isManualEntryMerchant;
                                    if (controller.isManualEntryMerchant) {
                                      controller.selectedPaidto = null;
                                    } else {
                                      controller.manualPaidToController.clear();
                                    }
                                  });
                                },
                                // 🔥 disables the toggle button if not enabled
                                child: Text(
                                  controller.isManualEntryMerchant
                                      ? AppLocalizations.of(context)!
                                          .selectFromMerchantList
                                      : AppLocalizations.of(context)!
                                          .enterMerchantManually,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!controller.isManualEntryMerchant) ...[
                              SearchableMultiColumnDropdownField<MerchantModel>(
                                labelText: AppLocalizations.of(context)!
                                    .selectMerchant,
                                columnHeaders: [
                                  AppLocalizations.of(context)!.merchantName,
                                  AppLocalizations.of(context)!.merchantId
                                ],
                                items: controller.paidTo,
                                selectedValue: controller.selectedPaidto,
                                searchValue: (p) =>
                                    '${p.merchantNames} ${p.merchantId}',
                                displayText: (p) => p.merchantNames,
                                validator: (value) {
                                  print("validator$value");
                                  if (controller
                                      .paidToController.text.isEmpty) {
                                    return 'Please select a merchant';
                                  }
                                  return null;
                                },
                                onChanged: (p) {
                                  setState(() {
                                    controller.selectedPaidto = p;
                                    controller.paidToController.text =
                                        p!.merchantId;
                                  });
                                },
                                controller: controller.paidToController,
                                rowBuilder: (p, searchQuery) {
                                  Widget highlight(String text) {
                                    final lowerQuery =
                                        searchQuery.toLowerCase();
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
                                        Expanded(
                                            child: highlight(p.merchantNames)),
                                        Expanded(
                                            child: highlight(p.merchantId)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ] else
                              TextFormField(
                                controller: controller.manualPaidToController,
                                // 🔥 disables text field
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .enterMerchantName,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter merchant name';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!_isItemized)
                          SearchableMultiColumnDropdownField<Project>(
                            labelText:
                                '${AppLocalizations.of(context)!.projectName} *',
                            columnHeaders: [
                              AppLocalizations.of(context)!.projectName,
                              AppLocalizations.of(context)!.projectName
                            ],
                            items: controller.project,
                            selectedValue: controller.selectedProject,
                            searchValue: (p) => '${p.name} ${p.code}',
                            displayText: (p) => p.code,
                            validator: (value) {
                              if (controller
                                  .projectDropDowncontroller.text.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .fieldRequired;
                              }
                              return null;
                            },
                            onChanged: (p) {
                              setState(() {
                                controller.selectedProject = p;
                              });
                            },
                            controller: controller.projectDropDowncontroller,
                            rowBuilder: (p, searchQuery) {
                              Widget highlight(String text) {
                                final query = searchQuery.toLowerCase();
                                final lowerText = text.toLowerCase();
                                final matchIndex = lowerText.indexOf(query);

                                if (matchIndex == -1 || query.isEmpty)
                                  return Text(text);

                                final end = matchIndex + query.length;
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: text.substring(0, matchIndex),
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
                        if (!_isItemized) const SizedBox(height: 16),
                        SearchableMultiColumnDropdownField<PaymentMethodModel>(
                          labelText: AppLocalizations.of(context)!.paidWith,
                          columnHeaders: [
                            AppLocalizations.of(context)!.paymentName,
                            AppLocalizations.of(context)!.paymentId
                          ],
                          items: controller.paymentMethods,
                          selectedValue: controller.selectedPaidWith,
                          searchValue: (p) =>
                              '${p.paymentMethodName} ${p.paymentMethodId}',
                          displayText: (p) => p.paymentMethodName,
                          validator: (value) {
                            if (controller.paymentMethodeID == null) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            return null;
                          },
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

                              if (start == -1 || query.isEmpty)
                                return Text(text);

                              final end = start + query.length;
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: text.substring(0, start),
                                      style:
                                          const TextStyle(color: Colors.black),
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
                                      style:
                                          const TextStyle(color: Colors.black),
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
                                      child: highlight(p.paymentMethodName)),
                                  Expanded(child: highlight(p.paymentMethodId)),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (!_isItemized)
                          SearchableMultiColumnDropdownField<ExpenseCategory>(
                            labelText:
                                '${AppLocalizations.of(context)!.paidFor}*',
                            columnHeaders: [
                              AppLocalizations.of(context)!.categoryName,
                              AppLocalizations.of(context)!.categoryId
                            ],
                            items: controller.expenseCategory,
                            selectedValue: controller.selectedCategory,
                            searchValue: (p) =>
                                '${p.categoryName} ${p.categoryId}',
                            displayText: (p) => p.categoryId,
                            validator: (value) {
                              if (controller.categoryController.text.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .fieldRequired;
                              }
                              return null;
                            },
                            onChanged: (p) {
                              setState(() {
                                controller.selectedCategory = p;
                              });
                            },
                            controller: controller.categoryController,
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
                                        text: text.substring(0, matchIndex),
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
                                    Expanded(child: highlight(p.categoryName)),
                                    Expanded(child: highlight(p.categoryId)),
                                  ],
                                ),
                              );
                            },
                          ),
                        if (!_isItemized) const SizedBox(height: 16),
                        TextFormField(
                          controller: referenceController,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.referenceId}*',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (referenceController.text.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                controller: controller.paidAmount,
                                onChanged: (_) {
                                  // controller.fetchExchangeRate();

                                  final paid = double.tryParse(
                                          controller.paidAmount.text) ??
                                      0.0;
                                  final rate = double.tryParse(
                                          controller.unitRate.text) ??
                                      1.0;

                                  final result = paid * rate;

                                  controller.amountINR.text =
                                      result.toStringAsFixed(2);
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'^\d*\.?\d*')), // Only digits and dots allowed
                                ],
                                decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context)!.paidAmount} *',
                                  border: const OutlineInputBorder(
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
                                        value.toStringAsFixed(2);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                                child: Obx(() =>
                                    SearchableMultiColumnDropdownField<
                                        Currency>(
                                      enabled: controller.isEnable.value,
                                      alignLeft: -90,
                                      dropdownWidth: 280,
                                      labelText: "",
                                      columnHeaders: [
                                        AppLocalizations.of(context)!.code,
                                        AppLocalizations.of(context)!.name,
                                        AppLocalizations.of(context)!.symbol
                                      ],
                                      items: controller.currencies,
                                      selectedValue:
                                          controller.selectedCurrency.value,
                                      backgroundColor:
                                          const Color.fromARGB(255, 22, 2, 92),
                                      searchValue: (c) =>
                                          '${c.code} ${c.name} ${c.symbol}',
                                      displayText: (c) => c.code,
                                      inputDecoration: const InputDecoration(
                                        suffixIcon: Icon(
                                            Icons.arrow_drop_down_outlined),
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(55, 5, 23, 128),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (controller
                                            .currencyDropDowncontroller
                                            .text
                                            .isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .fieldRequired;
                                        }
                                        return null;
                                      },
                                      onChanged: (c) {
                                        controller.selectedCurrency.value = c;
                                        controller.fetchExchangeRate();
                                      },
                                      controller:
                                          controller.currencyDropDowncontroller,
                                      rowBuilder: (c, searchQuery) {
                                        Widget highlight(String text) {
                                          final query =
                                              searchQuery.toLowerCase();
                                          final lowerText = text.toLowerCase();
                                          final matchIndex =
                                              lowerText.indexOf(query);

                                          if (matchIndex == -1 ||
                                              query.isEmpty) {
                                            return Text(text,
                                                style: const TextStyle(
                                                    color: Colors.black));
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
                                                  child: highlight(c.code)),
                                              Expanded(
                                                  child: highlight(c.name)),
                                              Expanded(
                                                  child: highlight(c.symbol)),
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
                                  labelText: AppLocalizations.of(context)!.rate,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter rate';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  // Fetch exchange rate if needed
                                  // controller.fetchExchangeRate();

                                  final paid = double.tryParse(
                                          controller.paidAmount.text) ??
                                      0.0;
                                  final rate = double.tryParse(val) ?? 1.0;

                                  // ✅ Perform calculation
                                  final result = paid * rate;

                                  controller.amountINR.text =
                                      result.toStringAsFixed(2);
                                  controller.isVisible.value = true;

                                  print("Paid Amount: $paid");
                                  print("Rate: $rate");
                                  print(
                                      "Calculated INR Amount: ${controller.amountINR.text}");
                                },
                              ),
                            ),
                          ],
                        ),
                        if (!_isItemized) const SizedBox(height: 16),
                        if (!_isItemized)
                          SearchableMultiColumnDropdownField<TaxGroupModel>(
                            labelText:
                                '${AppLocalizations.of(context)!.taxGroup} *',
                            columnHeaders: [
                              AppLocalizations.of(context)!.taxGroup,
                              AppLocalizations.of(context)!.taxId
                            ],
                            items: controller.taxGroup,
                            selectedValue: controller.selectedTax,
                            searchValue: (tax) =>
                                '${tax.taxGroup} ${tax.taxGroupId}',
                            displayText: (tax) => tax.taxGroupId,
                            onChanged: (tax) {
                              setState(() {
                                controller.selectedTax = tax;
                              });
                            },
                            rowBuilder: (tax, searchQuery) {
                              Widget highlight(String text) {
                                final lowerQuery = searchQuery.toLowerCase();
                                final lowerText = text.toLowerCase();
                                final start = lowerText.indexOf(lowerQuery);
                                if (start == -1 || searchQuery.isEmpty)
                                  return Text(text);

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
                                    Expanded(child: highlight(tax.taxGroup)),
                                    Expanded(child: highlight(tax.taxGroupId)),
                                  ],
                                ),
                              );
                            },
                          ),
                        if (!_isItemized) const SizedBox(height: 16),
                        if (!_isItemized)
                          TextFormField(
                            controller: taxAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.taxAmount,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        if (!_isItemized) const SizedBox(height: 16),
                        if (!_isItemized)
                          TextFormField(
                            controller: commentsController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.comments,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_isItemized) _buildItemizedFields(),
                    Center(
                      child: Column(
                        children: [
                          // 🚨 Submit Button
                          Obx(() {
                            bool isSubmitLoading =
                                controller.buttonLoaders['submit'] ?? false;
                            bool isSaveLoading =
                                controller.buttonLoaders['save'] ?? false;
                            bool isCancelLoading =
                                controller.buttonLoaders['cancel'] ?? false;
                            bool isAnyLoading = controller.buttonLoaders.values
                                .any((loading) => loading);

                            return SizedBox(
                              width: 300,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (isSubmitLoading ||
                                        isSaveLoading ||
                                        isCancelLoading ||
                                        isAnyLoading)
                                    ? null
                                    : () async {
                                        _isSubmitAttempted = true;
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          controller.setButtonLoading(
                                              'submit', true);
                                          try {
                                            _submitForm(false);
                                          } finally {
                                            controller.setButtonLoading(
                                                'submit', false);
                                          }
                                        } else {
                                          setState(
                                              () {}); // Refresh UI for inline errors
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  backgroundColor: AppColors.gradientEnd,
                                ),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          // 💾 Save & Cancel Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Obx(() {
                                  bool isSubmitLoading =
                                      controller.buttonLoaders['submit'] ??
                                          false;
                                  bool isSaveLoading =
                                      controller.buttonLoaders['save'] ?? false;
                                  bool isCancelLoading =
                                      controller.buttonLoaders['cancel'] ??
                                          false;
                                  bool isAnyLoading = controller
                                      .buttonLoaders.values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                      onPressed: (isSubmitLoading ||
                                              isSaveLoading ||
                                              isCancelLoading ||
                                              isAnyLoading)
                                          ? null
                                          : () async {
                                              _isSubmitAttempted = true;
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                controller.setButtonLoading(
                                                    'save', true);
                                                try {
                                                  await controller
                                                      .saveGeneralExpense(
                                                          context,
                                                          false,
                                                          false);
                                                } finally {
                                                  controller.setButtonLoading(
                                                      'save', false);
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please fill all required fields.'),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                  ),
                                                );
                                                setState(
                                                    () {}); // Refresh UI for inline errors
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(130, 50),
                                        backgroundColor: const Color.fromARGB(
                                            241, 20, 94, 2),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: isSaveLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(AppLocalizations.of(context)!
                                              .save));
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Obx(() {
                                  bool isSubmitLoading =
                                      controller.buttonLoaders['submit'] ??
                                          false;
                                  bool isSaveLoading =
                                      controller.buttonLoaders['save'] ?? false;
                                  bool isCancelLoading =
                                      controller.buttonLoaders['cancel'] ??
                                          false;
                                  bool isAnyLoading = controller
                                      .buttonLoaders.values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                    onPressed: (isSubmitLoading ||
                                            isSaveLoading ||
                                            isCancelLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () async {
                                            controller.setButtonLoading(
                                                'cancel', true);
                                            try {
                                              controller.chancelButton(context);
                                            } finally {
                                              controller.setButtonLoading(
                                                  'cancel', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(130, 50),
                                      backgroundColor: Colors.grey,
                                    ),
                                    child: isCancelLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!
                                                .cancel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ]),
            ),
          ),
        ));
  }

  Widget _buildItemizedFields() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                AppLocalizations.of(context)!.itemize,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              children: [
                ...itemizeSections.map((section) {
                  return section.build(
                      context,
                      _addItemizeSection,
                      () => _removeItemizeSection(
                          itemizeSections.indexOf(section)),
                      _updateTotalAmount);
                }).toList(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _addItemizeSection,
                    child: const Text('Add Item'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ItemizeSection {
  int index;
  final String? category;
  final String? description;
  final String? quantity;
  final String? unitPrice;
  final String? uomId;
  final String? taxAmount;
  final bool isReimbursable;
  final bool isBillable;
  final VoidCallback? onDelete;
  final VoidCallback updateTotalAmount;
  final controller = Get.put(Controller());
  List<AccountingSplit> split = [AccountingSplit(percentage: 100.0)];

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController uomIdController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController lineAmountController = TextEditingController();
  final TextEditingController lineAmountINRController = TextEditingController();
  bool _isReimbursable;
  bool _isBillable;
  List<AccountingDistribution?> accountingDistributions = [];

  ItemizeSection({
    required this.index,
    this.category,
    this.description,
    this.quantity,
    this.unitPrice,
    this.uomId,
    this.taxAmount,
    this.isReimbursable = true,
    this.isBillable = false,
    this.onDelete,
    this.accountingDistributions = const [],
    required this.updateTotalAmount,
  })  : _isReimbursable = isReimbursable,
        _isBillable = isBillable {
    categoryController.text = category ?? '';
    descriptionController.text = description ?? '';
    quantityController.text = quantity ?? '1';
    unitPriceController.text = unitPrice ?? '0';
    uomIdController.text = uomId ?? '';
    taxAmountController.text = taxAmount ?? '0';

    _updateLineAmount();

    quantityController.addListener(_updateLineAmount);
    unitPriceController.addListener(_updateLineAmount);
  }

  void _updateLineAmount() {
    double qty = double.tryParse(quantityController.text) ?? 0;
    double unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    lineAmountController.text = (qty * unitPrice).toStringAsFixed(2);

    // Calculate line amount in INR
    double rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    lineAmountINRController.text = (qty * unitPrice * rate).toStringAsFixed(2);

    // Update the total amount in parent
    updateTotalAmount();
  }

  void dispose() {
    quantityController.removeListener(_updateLineAmount);
    unitPriceController.removeListener(_updateLineAmount);
    categoryController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    uomIdController.dispose();
    taxAmountController.dispose();
    commentsController.dispose();
    lineAmountController.dispose();
    lineAmountINRController.dispose();
  }

  Widget build(BuildContext context, void Function() addItemizeSection,
      void Function() removeItemizeSection, void Function() updateTotalAmount) {
    final controllerItems = Get.put(Controller());
    return Card(
      color: Colors.grey[10],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text('${AppLocalizations.of(context)!.item} $index'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: removeItemizeSection,
                    tooltip: 'Remove this item',
                  ),
                // IconButton(
                //   icon: const Icon(Icons.add, color: Colors.green),
                //   onPressed: addItemizeSection,
                //   tooltip: 'Add new item',
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SearchableMultiColumnDropdownField<Project>(
                    labelText: '${AppLocalizations.of(context)!.projectId} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.projectName,
                      AppLocalizations.of(context)!.projectId
                    ],
                    items: controller.project,
                    selectedValue: controller.selectedProject,
                    searchValue: (p) => '${p.name} ${p.code}',
                    displayText: (p) => p.code,
                    validator: (value) {
                      if (controller.projectDropDowncontroller.text.isEmpty) {
                        return AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },
                    onChanged: (p) {
                      controller.selectedProject = p;
                      controller.projectDropDowncontroller.text = p!.code;
                    },
                    controller: controller.projectDropDowncontroller,
                    rowBuilder: (p, searchQuery) {
                      Widget highlight(String text) {
                        final query = searchQuery.toLowerCase();
                        final lowerText = text.toLowerCase();
                        final matchIndex = lowerText.indexOf(query);

                        if (matchIndex == -1 || query.isEmpty)
                          return Text(text);

                        final end = matchIndex + query.length;
                        return RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: text.substring(0, matchIndex),
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
                  const SizedBox(height: 16),
                  SearchableMultiColumnDropdownField<ExpenseCategory>(
                    labelText: '${AppLocalizations.of(context)!.paidFor} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.categoryName,
                      AppLocalizations.of(context)!.categoryId
                    ],
                    items: controller.expenseCategory,
                    selectedValue: controller.selectedCategory,
                    searchValue: (p) => '${p.categoryName} ${p.categoryId}',
                    displayText: (p) => p.categoryId,
                    validator: (value) {
                      if (categoryController.text.isEmpty) {
                        return AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },
                    onChanged: (p) {
                      controller.selectedCategory = p;
                    },
                    controller: categoryController,
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
                                text: text.substring(0, matchIndex),
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
                            Expanded(child: highlight(p.categoryName)),
                            Expanded(child: highlight(p.categoryId)),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchableMultiColumnDropdownField<Unit>(
                    labelText: '${AppLocalizations.of(context)!.unit} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.uomId,
                      AppLocalizations.of(context)!.uomName
                    ],
                    items: controller.unit,
                    selectedValue: controller.selectedunit,
                    searchValue: (tax) => '${tax.code} ${tax.name}',
                    displayText: (tax) => tax.code,
                    validator: (tax) => tax == null
                        ? AppLocalizations.of(context)!.pleaseSelectUnit
                        : null,
                    onChanged: (tax) {
                      controller.selectedunit = tax;
                      uomIdController.text = tax!.code;
                    },
                    controller: uomIdController,
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
                                text: text.substring(0, matchIndex),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: commentsController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.comments,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: unitPriceController,
                          decoration: InputDecoration(
                            labelText:
                                "${AppLocalizations.of(context)!.unitAmount}*",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final qty =
                                double.tryParse(quantityController.text) ?? 0.0;
                            final unit =
                                double.tryParse(unitPriceController.text) ??
                                    0.0;
                            final calculatedLineAmount = qty * unit;
                            lineAmountController.text =
                                calculatedLineAmount.toStringAsFixed(2);
                            var finalValueCount = controllerItems
                                .getTotalLineAmount()
                                .toStringAsFixed(2);
                            updateTotalAmount();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .fieldRequired;
                            }
                            if (double.tryParse(value) == null) {
                              return AppLocalizations.of(context)!
                                  .enterValidRate;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText:
                                "${AppLocalizations.of(context)!.quantity} *",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            updateTotalAmount();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.field;
                            }
                            if (double.tryParse(value) == null) {
                              return AppLocalizations.of(context)!
                                  .enterValidAmount;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lineAmountController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.lineAmount,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: lineAmountINRController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.lineAmountInInr,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          readOnly: true,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SearchableMultiColumnDropdownField<TaxGroupModel>(
                    labelText: '${AppLocalizations.of(context)!.taxGroup} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.taxAmount,
                      AppLocalizations.of(context)!.taxId
                    ],
                    items: controller.taxGroup,
                    selectedValue: controller.selectedTax,
                    searchValue: (tax) => '${tax.taxGroup} ${tax.taxGroupId}',
                    displayText: (tax) => tax.taxGroupId,
                    validator: (value) {
                      if (controller.selectedTax == null) {
                        return AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },
                    onChanged: (tax) {
                      controller.selectedTax = tax;
                    },
                    rowBuilder: (tax, searchQuery) {
                      Widget highlight(String text) {
                        final lowerQuery = searchQuery.toLowerCase();
                        final lowerText = text.toLowerCase();
                        final start = lowerText.indexOf(lowerQuery);
                        if (start == -1 || searchQuery.isEmpty)
                          return Text(text);

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
                            Expanded(child: highlight(tax.taxGroup)),
                            Expanded(child: highlight(tax.taxGroupId)),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: taxAmountController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.taxAmount,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  Obx(() => SwitchListTile(
                        title: Text(
                            AppLocalizations.of(context)!.isReimbursable,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        value: controller.isReimbursiteCreate.value,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade300,
                        onChanged: (val) {
                          controller.isReimbursiteCreate.value = val;
                        },
                      )),
                  Obx(() => SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.isBillable,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        value: controller.isisBillablereate.value,
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade300,
                        onChanged: (val) {
                          controller.isisBillablereate.value = val;
                        },
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          final double lineAmount =
                              double.tryParse(lineAmountController.text) ?? 0.0;

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                                left: 16,
                                right: 16,
                                top: 24,
                              ),
                              child: SingleChildScrollView(
                                child: AccountingDistributionWidget(
                                  index: index,
                                  splits: split,
                                  lineAmount: lineAmount,
                                  onChanged: (i, updatedSplit) {
                                    split[i] = updatedSplit;
                                  },
                                  onDistributionChanged: (newList) {
                                    controller.accountingDistributions
                                        .addAll(newList);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                            AppLocalizations.of(context)!.accountDistribution),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
// import 'package:digi_xpense/core/comman/widgets/button.dart';
// import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
// import 'package:digi_xpense/data/models.dart';
// import 'package:digi_xpense/data/service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'dart:io';
// import 'package:intl/intl.dart';

// class AutoScanExpensePage extends StatefulWidget {
//   final File imageFile;
//   final Map<String, dynamic> apiResponse;

//   const AutoScanExpensePage({
//     Key? key,
//     required this.imageFile,
//     required this.apiResponse,
//   }) : super(key: key);

//   @override
//   State<AutoScanExpensePage> createState() => _AutoScanExpensePageState();
// }

// class _AutoScanExpensePageState extends State<AutoScanExpensePage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late List<Map<String, dynamic>> expenseTrans;
//   final controller = Get.put(Controller());
//    final controllerItems = Get.put(Controller());
//   bool _isItemized = false;
//   bool _isReimbursable = true;
//   bool _isBillable = false;

//   // Main form controllers
//   final TextEditingController receiptDateController = TextEditingController();
//   final TextEditingController merchantController = TextEditingController();
//   final TextEditingController referenceController = TextEditingController();
//   // final TextEditingController controller.paidAmount = TextEditingController();
//   final TextEditingController taxAmountController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController paymentMethodController = TextEditingController();
//   final TextEditingController currencyController = TextEditingController();
//   final TextEditingController cashAdvanceController = TextEditingController();
//   final TextEditingController commentsController = TextEditingController();
//   final TextEditingController totalInINRController = TextEditingController();

//   // Itemize sections
//   final List<ItemizeSection> itemizeSections = [];

//   @override
//   void initState() {
//     super.initState();
//     controller.configuration();
//     controller.selectedDate ??= DateTime.now();
//     controller.fetchPaidto();
//     controller.fetchPaidwith();
//     controller.fetchProjectName();
//     controller.fetchTaxGroup();
//     controller.fetchUnit();

//     controller.getUserPref();
//     controller.fetchExpenseCategory();
//     controller.configuration();
//     controller.fetchPaidwith();
//     _initializeUnits();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await controller.fetchExchangeRate();
//       controller.currencyDropDown();
//       // ✅ Only after exchange rate is fetched
//       print("Now continue with other logic...");
//     });
//     expenseTrans = List<Map<String, dynamic>>.from(
//         widget.apiResponse['ExpenseTrans'] ?? []);
//     _isItemized = expenseTrans.length > 1 ||
//         (expenseTrans.isNotEmpty && expenseTrans[0]['Description'] != null);
//     _initializeFormFromApiResponse();
//   }

//   Future<void> _initializeUnits() async {
//     await controller.fetchUnit();

//     final defaultUnit = controller.unit.firstWhere(
//       (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
//       orElse: () => controller.unit.first,
//     );

//     setState(() {
//       controller.selectedunit ??= defaultUnit;
//       controller.selectedunit ??= defaultUnit;
//     });
//   }

//   void _initializeFormFromApiResponse() {
//     // Parse receipt date (timestamp in milliseconds)
//     final date = DateTime.fromMillisecondsSinceEpoch(
//         widget.apiResponse['ReceiptDate'] ?? 0);
//     receiptDateController.text = DateFormat('yyyy-MM-dd').format(date);
//     controller.selectedDate = date;
//     // Map main fields
//     merchantController.text = widget.apiResponse['Merchant'] ?? '';
//     referenceController.text = widget.apiResponse['ReferenceNumber'] ?? '';
//     controller.paidAmount.text =
//         (widget.apiResponse['TotalAmount'] ?? 0).toString();
//     taxAmountController.text =
//         (widget.apiResponse['TaxAmount'] ?? 0).toString();
//     descriptionController.text = widget.apiResponse['Description'] ?? '';
//     paymentMethodController.text = widget.apiResponse['PaymentMethod'] ?? '';
//     currencyController.text = widget.apiResponse['Currency'] ?? '';
//     commentsController.text = widget.apiResponse['Comments'] ?? '';

//     // Calculate total in INR (placeholder - replace with actual calculation)
//     double total = double.tryParse(controller.paidAmount.text) ?? 0;
//     double rate = double.tryParse(controller.unitRate.text) ?? 1;
//     totalInINRController.text = (total * rate).toStringAsFixed(2);

//     // Create itemize sections from ExpenseTrans
//     for (var i = 0; i < expenseTrans.length; i++) {
//       final item = expenseTrans[i];
//       itemizeSections.add(ItemizeSection(
//         index: i + 1,
//         category: item['ExpenseCategory'] ?? '',
//         description: item['Description'] ?? '',
//         quantity: (item['Quantity'] ?? 1).toString(),
//         unitPrice: (item['UnitPriceTrans'] ?? 0).toString(),
//         uomId: item['UomId'] ?? '',
//         taxAmount: (item['TaxAmount'] ?? 0).toString(),
//         isReimbursable: item['IsReimbursable'] ?? true,
//         isBillable: item['IsBillable'] ?? false,
//         onDelete: i > 0 ? () => _removeItemizeSection(i) : null,
//       ));
//     }
//   }

//   void _addItemizeSection() {
//     setState(() {
//       itemizeSections.add(ItemizeSection(
//         index: itemizeSections.length + 1,
//         onDelete: itemizeSections.isNotEmpty
//             ? () => _removeItemizeSection(itemizeSections.length)
//             : null,
//       ));
//     });
//   }

//   void _removeItemizeSection(int index) {
//     setState(() {
//       itemizeSections.removeAt(index);
//     });
//   }

//   void _submitForm(bool bool) {
//     print("Form is invalid");
//     // if (!_formKey.currentState!.validate()) return;
//     if (_formKey.currentState!.validate()) {
//       print("Form is valid");
//     } else {
//       print("Form is invalid");
//     }
//     // Prepare the data to submit
//     // final formData = {
//     //   'ReceiptDate': receiptDateController.text,
//     //   'Merchant': merchantController.text,
//     //   'ReferenceNumber': referenceController.text,
//     //   'TotalAmount': double.tryParse(controller.paidAmount.text) ?? 0,
//     //   'TaxAmount': double.tryParse(taxAmountController.text) ?? 0,
//     //   'Description': descriptionController.text,
//     //   'PaymentMethod': paymentMethodController.text,
//     //   'Currency': currencyController.text,
//     //   'Comments': commentsController.text,
//     //   'IsItemized': _isItemized,
//     //   'IsReimbursable': _isReimbursable,
//     //   'IsBillable': _isBillable,
//     //   'ExpenseTrans': _isItemized
//     //       ? itemizeSections.map((section) => section.toMap()).toList()
//     //       : null,
//     //   'ImagePath': widget.imageFile.path,
//     // };
//     // controller.imageFiles=[];
//     // controller.paidAmount.text = controller.paidAmount.text;
//     controller.taxAmount.text = taxAmountController.text;
//     controller.descriptionController.text = descriptionController.text;
//     controller.rememberMe = _isReimbursable;
//     controller.isBillable = _isBillable;
//     controller.referenceController.text = referenceController.text;
//     controller.receiptDateController.text = receiptDateController.text;
//     if (widget.imageFile.existsSync()) {
//       controller.imageFiles.add(widget.imageFile);
//       print("✅ File added: ${widget.imageFile.path}");
//     } else {
//       print("❌ File does not exist: ${widget.imageFile.path}");
//     }
//     List<AccountingDistribution> distributions = [];
//     // print('Submitting form data: $formData');
//     controller.finalItems.clear();
//     for (int i = 0; i < itemizeSections.length; i++) {
//       final item = itemizeSections[i];
//       for (final split in item.split) {
//         distributions.add(
//           AccountingDistribution(
//             transAmount: split.amount ?? 0.0, // Safe null handling
//             reportAmount: split.amount ?? 0.0,
//             allocationFactor: split.percentage,
//             dimensionValueId: split.paidFor ?? '', // Safe null handling
//           ),
//         );
//       }
//       controller.finalItems.add(
//         ExpenseItem(
//           expenseCategoryId: item.categoryController.text.trim(),
//           quantity: double.tryParse(item.quantityController.text) ?? 0,
//           uomId: item.uomIdController.text.trim(),
//           unitPriceTrans: double.tryParse(item.unitPriceController.text) ?? 0,
//           taxAmount: double.tryParse(item.taxAmountController.text) ?? 0,
//           taxGroup: controller.selectedTax?.taxGroupId ?? '',
//           lineAmountTrans: double.tryParse(item.lineAmountController.text) ?? 0,
//           lineAmountReporting:
//               double.tryParse(item.lineAmountINRController.text) ?? 0,
//           projectId: controller.projectDropDowncontroller.text,
//           description: item.descriptionController.text.trim(),
//           isReimbursable: item._isReimbursable,
//           isBillable: item.isBillable,
//           accountingDistributions: item.accountingDistributions
//               .whereType<AccountingDistribution>()
//               .toList(),
//         ),
//       );
//     }

//     controller.saveGeneralExpense(context, bool);
//     // Navigate to success screen
//   }

//   @override
//   void dispose() {
//     receiptDateController.dispose();
//     merchantController.dispose();
//     referenceController.dispose();
//     controller.paidAmount.dispose();
//     taxAmountController.dispose();
//     descriptionController.dispose();
//     paymentMethodController.dispose();
//     currencyController.dispose();
//     cashAdvanceController.dispose();
//     commentsController.dispose();
//     totalInINRController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ignore: deprecated_member_use
//     return WillPopScope(
//         onWillPop: () async {
//           controller.clearFormFields();
//           return true; // allow back navigation
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Auto Scan '),
//           ),
//           body: Form(
//             key: _formKey,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Scanned image preview
//                   _buildImagePreview(),
//                   const SizedBox(height: 20),

//                   // Common fields for both itemized and non-itemized
//                   _buildCommonFieldsSection(),

//                   // Itemized or non-itemized specific fields
//                   if (_isItemized) _buildItemizedFields(),

//                   // Toggle buttons and action buttons
//                   _buildBottomSection(),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }

//   Widget _buildImagePreview() {
//     return Container(
//       height: 200,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Image.file(
//         widget.imageFile,
//         fit: BoxFit.cover,
//         width: double.infinity,
//       ),
//     );
//   }

//   Widget _buildCommonFieldsSection() {
//     return Column(
//       children: [
//         _buildDateField('Receipt Date *', receiptDateController),

//         SearchableMultiColumnDropdownField<MerchantModel>(
//           labelText: 'Paid To *',
//           columnHeaders: const ['Merchant Name', 'Merchant ID'],
//           items: controller.paidTo,
//           selectedValue: controller.selectedPaidto,
//           searchValue: (p) => '${p.merchantNames} ${p.merchantId}',
//           displayText: (p) => p.merchantNames,
//           validator: (value) => value == null ? 'Please select Paid To' : null,
//           onChanged: (p) {
//             if (p != null) {
//               setState(() {
//                 controller.selectedPaidto = p;
//                 merchantController.text = p.merchantNames;
//               });
//               print("merchantController: ${merchantController.text}");
//               print("Selected Merchant: $p");
//             } else {
//               print("Null value selected");
//             }
//           },
//           rowBuilder: (p, searchQuery) {
//             Widget highlight(String text) {
//               final query = searchQuery.toLowerCase();
//               final full = text.toLowerCase();
//               final start = full.indexOf(query);

//               if (start == -1 || query.isEmpty) return Text(text);

//               final end = start + query.length;
//               return RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: text.substring(0, start),
//                       
//                     ),
//                     TextSpan(
//                       text: text.substring(start, end),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: text.substring(end),
//                       
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(child: highlight(p.merchantNames)),
//                   Expanded(child: highlight(p.merchantId)),
//                 ],
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 16),
//         if (!_isItemized)
//           SearchableMultiColumnDropdownField<Project>(
//             labelText: 'Project *',
//             columnHeaders: const ['Project Name', 'Project ID'],
//             items: controller.project,
//             selectedValue: controller.selectedProject,
//             searchValue: (p) => '${p.name} ${p.code}',
//             displayText: (p) => p.code,
//             validator: (value) =>
//                 value == null ? 'Please select Project' : null,
//             onChanged: (p) {
//               setState(() {
//                 controller.selectedProject = p;
//               });
//             },
//             controller: controller.projectDropDowncontroller,
//             rowBuilder: (p, searchQuery) {
//               Widget highlight(String text) {
//                 final query = searchQuery.toLowerCase();
//                 final lowerText = text.toLowerCase();
//                 final matchIndex = lowerText.indexOf(query);

//                 if (matchIndex == -1 || query.isEmpty) return Text(text);

//                 final end = matchIndex + query.length;
//                 return RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: text.substring(0, matchIndex),
//                         
//                       ),
//                       TextSpan(
//                         text: text.substring(matchIndex, end),
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       TextSpan(
//                         text: text.substring(end),
//                         
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(child: highlight(p.name)),
//                     Expanded(child: highlight(p.code)),
//                   ],
//                 ),
//               );
//             },
//           ),
//         if (!_isItemized) const SizedBox(height: 16),

//         SearchableMultiColumnDropdownField<PaymentMethodModel>(
//           // enabled: controller.isEnable.value,
//           labelText: 'Paid With',
//           columnHeaders: const ['Payment Name', 'Payment ID'],
//           items: controller.paymentMethods,
//           selectedValue: controller.selectedPaidWith,
//           searchValue: (p) => '${p.paymentMethodName} ${p.paymentMethodId}',
//           displayText: (p) => p.paymentMethodName,
//           validator: (_) => null,
//           onChanged: (p) {
//             setState(() {
//               controller.selectedPaidWith = p;
//               controller.paymentMethodeID = p!.paymentMethodId;
//             });
//           },
//           rowBuilder: (p, searchQuery) {
//             Widget highlight(String text) {
//               final query = searchQuery.toLowerCase();
//               final lowerText = text.toLowerCase();
//               final start = lowerText.indexOf(query);

//               if (start == -1 || query.isEmpty) return Text(text);

//               final end = start + query.length;
//               return RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: text.substring(0, start),
//                       
//                     ),
//                     TextSpan(
//                       text: text.substring(start, end),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: text.substring(end),
//                       
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(child: highlight(p.paymentMethodName)),
//                   Expanded(child: highlight(p.paymentMethodId)),
//                 ],
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 16),
//         if (!_isItemized)
//           SearchableMultiColumnDropdownField<ExpenseCategory>(
//             labelText: 'Paid For *',
//             columnHeaders: const ['Category Name', 'Category ID'],
//             items: controller.expenseCategory,
//             selectedValue: controller.selectedCategory,
//             searchValue: (p) => '${p.categoryName} ${p.categoryId}',
//             displayText: (p) => p.categoryId,
//             validator: (value) =>
//                 value == null ? 'Please select Category' : null,
//             onChanged: (p) {
//               setState(() {
//                 controller.selectedCategory = p;
//               });
//             },
//             controller: controller.categoryController,
//             rowBuilder: (p, searchQuery) {
//               Widget highlight(String text) {
//                 final query = searchQuery.toLowerCase();
//                 final lower = text.toLowerCase();
//                 final matchIndex = lower.indexOf(query);

//                 if (matchIndex == -1 || query.isEmpty) return Text(text);

//                 final end = matchIndex + query.length;
//                 return RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: text.substring(0, matchIndex),
//                         
//                       ),
//                       TextSpan(
//                         text: text.substring(matchIndex, end),
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       TextSpan(
//                         text: text.substring(end),
//                         
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(child: highlight(p.categoryName)),
//                     Expanded(child: highlight(p.categoryId)),
//                   ],
//                 ),
//               );
//             },
//           ),
//         if (!_isItemized) const SizedBox(height: 16),

//         _buildTextField(label: 'Reference *', controller: referenceController),
//         // const SizedBox(height: 16),
//         // Rest of the non-itemized fields

//         // Row(
//         //   children: [
//         //     Expanded(
//         //       child: TextFormField(
//         //         controller: controller.paidAmount,
//         //         decoration: const InputDecoration(labelText: 'Paid Amount'),
//         //         keyboardType: TextInputType.number,
//         //         validator: (value) {
//         //           if (value == null || value.isEmpty) {
//         //             return 'Please enter amount';
//         //           }
//         //           if (double.tryParse(value) == null) {
//         //             return 'Please enter valid number';
//         //           }
//         //           return null;
//         //         },
//         //       ),
//         //     ),
//         //     const SizedBox(width: 16),
//         //     Expanded(
//         //       child: TextFormField(
//         //         controller: controller.unitRate,
//         //         decoration: const InputDecoration(labelText: 'Rate *'),
//         //         keyboardType: TextInputType.number,
//         //         validator: (value) {
//         //           if (value == null || value.isEmpty) {
//         //             return 'Please enter rate';
//         //           }
//         //           if (double.tryParse(value) == null) {
//         //             return 'Please enter valid number';
//         //           }
//         //           return null;
//         //         },
//         //       ),
//         //     ),
//         //     const SizedBox(width: 16),
//         //     Expanded(
//         //       child: TextFormField(
//         //         controller: totalInINRController,
//         //         decoration:
//         //             const InputDecoration(labelText: 'Total Amount In INR'),
//         //         readOnly: true,
//         //       ),
//         //     ),
//         //   ],
//         // ),
//         const SizedBox(height: 16),

//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 enabled: !_isItemized,
//                 controller: controller.paidAmount,
//                 onChanged: (_) {
//                   controller.fetchExchangeRate();

//                   final paid =
//                       double.tryParse(controller.paidAmount.text) ?? 0.0;
//                   final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

//                   final result = paid * rate;

//                   controller.amountINR.text = result.toStringAsFixed(2);
//                 },
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Paid Amount *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(0),
//                         bottomRight: Radius.circular(0),
//                         topLeft: Radius.circular(10),
//                         bottomLeft: Radius.circular(10)),
//                   ),
//                 ),
//                 onEditingComplete: () {
//                   String text = controller.paidAmount.text;
//                   double? value = double.tryParse(text);
//                   if (value != null) {
//                     controller.paidAmount.text =
//                         value.toStringAsFixed(2); // Format value
//                   }
//                   // Call once
//                 },
//               ),
//             ),
//             Expanded(
//                 child: Obx(() => SearchableMultiColumnDropdownField<Currency>(
//                       // enabled: controller.isEnable.value,
//                       alignLeft: -90,
//                       dropdownWidth: 280,
//                       labelText: "",
//                       columnHeaders: const ['Code', 'Name', 'Symbol'],
//                       items: controller.currencies,
//                       selectedValue: controller.selectedCurrency.value,
//                       backgroundColor: const Color.fromARGB(255, 22, 2, 92),
//                       searchValue: (c) => '${c.code} ${c.name} ${c.symbol}',
//                       displayText: (c) => c.code,
//                       inputDecoration: const InputDecoration(
//                         suffixIcon: Icon(Icons.arrow_drop_down_outlined),
//                         filled: true,
//                         fillColor: Color.fromARGB(55, 5, 23, 128),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(0),
//                             bottomLeft: Radius.circular(0),
//                             topRight: Radius.circular(10),
//                             bottomRight: Radius.circular(10),
//                           ),
//                         ),
//                       ),
//                       validator: (c) =>
//                           c == null ? 'Please pick a currency' : null,
//                       onChanged: (c) {
//                         controller.selectedCurrency.value = c;
//                         controller.fetchExchangeRate();
//                       },
//                       controller: controller.currencyDropDowncontroller,
//                       rowBuilder: (c, searchQuery) {
//                         Widget highlight(String text) {
//                           final query = searchQuery.toLowerCase();
//                           final lowerText = text.toLowerCase();
//                           final matchIndex = lowerText.indexOf(query);

//                           if (matchIndex == -1 || query.isEmpty) {
//                             return Text(text,
//                                 style: const TextStyle(color: Colors.white));
//                           }

//                           final end = matchIndex + query.length;
//                           return RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: text.substring(0, matchIndex),
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(matchIndex, end),
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(end),
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           child: Row(
//                             children: [
//                               Expanded(child: highlight(c.code)),
//                               Expanded(child: highlight(c.name)),
//                               Expanded(child: highlight(c.symbol)),
//                             ],
//                           ),
//                         );
//                       },
//                     ))),
//             const SizedBox(width: 10),
//             Expanded(
//               child: TextFormField(
//                 controller: controller.unitRate,
//                 decoration: InputDecoration(
//                   labelText: 'Rate *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 // initialValue: controller.unitRate,
//               ),
//             ),
//           ],
//         ),
//         if (!_isItemized) const SizedBox(height: 16),
//         if (!_isItemized)
//           SearchableMultiColumnDropdownField<TaxGroupModel>(
//             labelText: 'Tax Group *',
//             columnHeaders: const ['Tax Group', 'Tax ID'],
//             items: controller.taxGroup,
//             selectedValue: controller.selectedTax,
//             searchValue: (tax) => '${tax.taxGroup} ${tax.taxGroupId}',
//             displayText: (tax) => tax.taxGroupId,
//             validator: (value) =>
//                 value == null ? 'Please select Tax Group ' : null,
//             onChanged: (tax) {
//               setState(() {
//                 controller.selectedTax = tax;
//               });
//             },
//             rowBuilder: (tax, searchQuery) {
//               Widget highlight(String text) {
//                 final lowerQuery = searchQuery.toLowerCase();
//                 final lowerText = text.toLowerCase();
//                 final start = lowerText.indexOf(lowerQuery);
//                 if (start == -1 || searchQuery.isEmpty) return Text(text);

//                 final end = start + searchQuery.length;
//                 return RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: text.substring(0, start),
//                         
//                       ),
//                       TextSpan(
//                         text: text.substring(start, end),
//                         style: const TextStyle(
//                           color: Colors.black,
//                         ),
//                       ),
//                       TextSpan(
//                         text: text.substring(end),
//                         
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(child: highlight(tax.taxGroup)),
//                     Expanded(child: highlight(tax.taxGroupId)),
//                   ],
//                 ),
//               );
//             },
//           ),
//         if (!_isItemized) const SizedBox(height: 16),
//         if (!_isItemized) _buildNumberField('Tax Amount', taxAmountController),
//         if (!_isItemized) const SizedBox(height: 16),
//         if (!_isItemized)
//           _buildTextField(
//             label: "Comments",
//             controller: commentsController,
//           ),
//         if (!_isItemized)
//           Align(
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _isItemized = true;
//                   // Initialize with one empty item when switching to itemized
//                   if (itemizeSections.isEmpty) {
//                     _addItemizeSection();
//                   }
//                 });
//               },
//               child: const Text('Add Itemize'),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildItemizedFields() {
//     return Column(
//       children: [
//         _buildSection(
//           title: 'Itemized Expenses',
//           children: [
//             ...itemizeSections.asMap().entries.map((entry) {
//               int index = entry.key;
//               var section = entry.value;

//               return section.build(
//                 context,
//                 _addItemizeSection,
//                 () =>
//                     _removeItemizeSection(index), // 👈 bind current index here
//               );
//             }).toList(),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _addItemizeSection,
//                 child: const Text('Add Item'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildNonItemizedFields() {
//     return _buildSection(
//       title: 'Expense Details',
//       children: [
//         // Add a button to switch to itemized mode

//         // Rest of the non-itemized fields
//         SearchableMultiColumnDropdownField<Project>(
//           labelText: 'Project *',
//           columnHeaders: const ['Project Name', 'Project ID'],
//           items: controller.project,
//           selectedValue: controller.selectedProject,
//           searchValue: (p) => '${p.name} ${p.code}',
//           displayText: (p) => p.code,
//           validator: (value) => value == null ? 'Please select Project' : null,
//           onChanged: (p) {
//             setState(() {
//               controller.selectedProject = p;
//             });
//           },
//           controller: controller.projectDropDowncontroller,
//           rowBuilder: (p, searchQuery) {
//             Widget highlight(String text) {
//               final query = searchQuery.toLowerCase();
//               final lowerText = text.toLowerCase();
//               final matchIndex = lowerText.indexOf(query);

//               if (matchIndex == -1 || query.isEmpty) return Text(text);

//               final end = matchIndex + query.length;
//               return RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: text.substring(0, matchIndex),
//                       
//                     ),
//                     TextSpan(
//                       text: text.substring(matchIndex, end),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: text.substring(end),
//                       
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(child: highlight(p.name)),
//                   Expanded(child: highlight(p.code)),
//                 ],
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 16),
//         SearchableMultiColumnDropdownField<ExpenseCategory>(
//           labelText: 'Paid For *',
//           columnHeaders: const ['Category Name', 'Category ID'],
//           items: controller.expenseCategory,
//           selectedValue: controller.selectedCategory,
//           searchValue: (p) => '${p.categoryName} ${p.categoryId}',
//           displayText: (p) => p.categoryId,
//           validator: (value) => value == null ? 'Please select Category' : null,
//           onChanged: (p) {
//             setState(() {
//               controller.selectedCategory = p;
//             });
//           },
//           controller: controller.categoryController,
//           rowBuilder: (p, searchQuery) {
//             Widget highlight(String text) {
//               final query = searchQuery.toLowerCase();
//               final lower = text.toLowerCase();
//               final matchIndex = lower.indexOf(query);

//               if (matchIndex == -1 || query.isEmpty) return Text(text);

//               final end = matchIndex + query.length;
//               return RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: text.substring(0, matchIndex),
//                       
//                     ),
//                     TextSpan(
//                       text: text.substring(matchIndex, end),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: text.substring(end),
//                       
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(child: highlight(p.categoryName)),
//                   Expanded(child: highlight(p.categoryId)),
//                 ],
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: controller.paidAmount,
//                 decoration: const InputDecoration(labelText: 'Paid Amount'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter amount';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter valid number';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 controller: controller.unitRate,
//                 decoration: const InputDecoration(labelText: 'Rate *'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter rate';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter valid number';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 controller: totalInINRController,
//                 decoration:
//                     const InputDecoration(labelText: 'Total Amount In INR'),
//                 readOnly: true,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         SearchableMultiColumnDropdownField<TaxGroupModel>(
//           labelText: 'Tax Group *',
//           columnHeaders: const ['Tax Group', 'Tax ID'],
//           items: controller.taxGroup,
//           selectedValue: controller.selectedTax,
//           searchValue: (tax) => '${tax.taxGroup} ${tax.taxGroupId}',
//           displayText: (tax) => tax.taxGroupId,
//           validator: (value) =>
//               value == null ? 'Please select Tax Group ' : null,
//           onChanged: (tax) {
//             setState(() {
//               controller.selectedTax = tax;
//             });
//           },
//           rowBuilder: (tax, searchQuery) {
//             Widget highlight(String text) {
//               final lowerQuery = searchQuery.toLowerCase();
//               final lowerText = text.toLowerCase();
//               final start = lowerText.indexOf(lowerQuery);
//               if (start == -1 || searchQuery.isEmpty) return Text(text);

//               final end = start + searchQuery.length;
//               return RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: text.substring(0, start),
//                       
//                     ),
//                     TextSpan(
//                       text: text.substring(start, end),
//                       style: const TextStyle(
//                         color: Colors.black,
//                       ),
//                     ),
//                     TextSpan(
//                       text: text.substring(end),
//                       
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(child: highlight(tax.taxGroup)),
//                   Expanded(child: highlight(tax.taxGroupId)),
//                 ],
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 16),
//         _buildNumberField('Tax Amount', taxAmountController),
//         const SizedBox(height: 16),
//         _buildTextField(
//           label: "Comments",
//           controller: commentsController,
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomSection() {
//     return Column(
//       children: [
//         // TextButton(
//         //   onPressed: () {
//         //     // Handle Account Distribution
//         //   },
//         //   child: const Text('Account Distribution'),
//         // ),
//         const SizedBox(height: 20),
//         Obx(() {
//           return SizedBox(
//               width: double.infinity,
//               child: GradientButton(
//                 text: "Submit",
//                 isLoading: controller.buttonLoader.value,
//                 onPressed: () => {
//                   _submitForm(true),
//                 },
//               ));
//         }),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => {
//                   _submitForm(false),
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF8E6EFF)),
//                 child: const Text("Save"),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => {controller.chancelButton(context)},
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
//                 child: const Text("Cancel"),
//               ),
//             ),
//           ],
//         ),
//         // Row(
//         //   children: [
//         //     Expanded(
//         //       child: ElevatedButton(
//         //         onPressed: () {
//         //           // Save action
//         //           if (_formKey.currentState!.validate()) {
//         //             ScaffoldMessenger.of(context).showSnackBar(
//         //               const SnackBar(
//         //                   content: Text('Expense saved successfully')),
//         //             );
//         //           }
//         //         },
//         //         child: const Text('Save'),
//         //       ),
//         //     ),
//         //     const SizedBox(width: 16),
//         //     Expanded(
//         //       child: ElevatedButton(
//         //         onPressed: _submitForm,
//         //         style: ElevatedButton.styleFrom(
//         //           backgroundColor: Colors.green,
//         //         ),
//         //         child: const Text('Submit'),
//         //       ),
//         //     ),
//         //     const SizedBox(width: 16),
//         //     Expanded(
//         //       child: ElevatedButton(
//         //         onPressed: () {
//         //           Navigator.pop(context);
//         //         },
//         //         style: ElevatedButton.styleFrom(
//         //           backgroundColor: Colors.grey,
//         //         ),
//         //         child: const Text('Close'),
//         //       ),
//         //     ),
//         //   ],
//         // ),
//       ],
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
//       child: Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: ExpansionTile(
//           initiallyExpanded: true,
//           title: Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: Colors.deepPurple,
//             ),
//           ),
//           backgroundColor: Colors.white,
//           collapsedBackgroundColor: Colors.white,
//           textColor: Colors.deepPurple,
//           iconColor: Colors.deepPurple,
//           collapsedIconColor: Colors.grey,
//           childrenPadding:
//               const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           children: children,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             labelText: label,
//             contentPadding:
//                 const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(6),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }

//   Widget _buildNumberField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: () async {
//               final date = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime(2000),
//                 lastDate: DateTime(2100),
//               );
//               if (date != null) {
//                 controller.text = DateFormat('yyyy-MM-dd').format(date);
//               }
//             },
//           ),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please select $label';
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }

// class ItemizeSection {
//   int index;
//   final String? category;
//   final String? description;
//   final String? quantity;
//   final String? unitPrice;
//   final String? uomId;
//   final String? taxAmount;
//   final bool isReimbursable;
//   final bool isBillable;
//   VoidCallback? onDelete;
//   final controller = Get.put(Controller());
//   List<AccountingSplit> split = [AccountingSplit(percentage: 100.0)];

//   final TextEditingController categoryController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController quantityController = TextEditingController();
//   final TextEditingController unitPriceController = TextEditingController();
//   final TextEditingController uomIdController = TextEditingController();
//   final TextEditingController taxAmountController = TextEditingController();
//   final TextEditingController commentsController = TextEditingController();
//   final TextEditingController lineAmountController = TextEditingController();
//   final TextEditingController lineAmountINRController = TextEditingController();
//   bool _isReimbursable;
//   bool _isBillable;
//   List<AccountingDistribution?> accountingDistributions = [];
//   ItemizeSection({
//     required this.index,
//     this.category,
//     this.description,
//     this.quantity,
//     this.unitPrice,
//     this.uomId,
//     this.taxAmount,
//     this.isReimbursable = true,
//     this.isBillable = false,
//     this.onDelete,
//     this.accountingDistributions = const [],
//   })  : _isReimbursable = isReimbursable,
//         _isBillable = isBillable {
//     categoryController.text = category ?? '';
//     descriptionController.text = description ?? '';
//     quantityController.text = quantity ?? '1';
//     unitPriceController.text = unitPrice ?? '0';
//     uomIdController.text = uomId ?? '';
//     taxAmountController.text = taxAmount ?? '0';

//     // Calculate initial line amount
//     _updateLineAmount();

//     // Add listeners to update line amount when quantity or unit price changes
//     quantityController.addListener(_updateLineAmount);
//     unitPriceController.addListener(_updateLineAmount);
//   }

//   void _updateLineAmount() {
//     double qty = double.tryParse(quantityController.text) ?? 0;
//     double unitPrice = double.tryParse(unitPriceController.text) ?? 0;
//     lineAmountController.text = (qty * unitPrice).toStringAsFixed(2);
//     controller.paidAmount.text = (qty * unitPrice).toStringAsFixed(2);
//     // Calculate line amount in INR (placeholder - replace with actual rate)
//     double rate = double.tryParse(controller.unitRate.text) ?? 1;
//     lineAmountINRController.text = (qty * unitPrice * rate).toStringAsFixed(2);
//   }

//   void dispose() {
//     quantityController.removeListener(_updateLineAmount);
//     unitPriceController.removeListener(_updateLineAmount);
//     categoryController.dispose();
//     descriptionController.dispose();
//     quantityController.dispose();
//     unitPriceController.dispose();
//     uomIdController.dispose();
//     taxAmountController.dispose();
//     commentsController.dispose();
//     lineAmountController.dispose();
//     lineAmountINRController.dispose();
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'ExpenseCategory': categoryController.text,
//       'Description': descriptionController.text,
//       'Quantity': int.tryParse(quantityController.text) ?? 1,
//       'UnitPriceTrans': double.tryParse(unitPriceController.text) ?? 0,
//       'UomId': uomIdController.text,
//       'TaxAmount': double.tryParse(taxAmountController.text) ?? 0,
//       'Comments': commentsController.text,
//       'LineAmount': double.tryParse(lineAmountController.text) ?? 0,
//       'LineAmountINR': double.tryParse(lineAmountINRController.text) ?? 0,
//       'IsReimbursable': _isReimbursable,
//       'IsBillable': _isBillable,
//     };
//   }

//   Widget build(BuildContext context, void Function() addItemizeSection,
//       void Function() removeItemizeSection) {
//          final controllerItems = Get.put(Controller());
//     return Card(
//         color: Colors.grey[10],
//         margin: const EdgeInsets.only(bottom: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Theme(
//           data: Theme.of(context).copyWith(
//             dividerColor: Colors.transparent,
//           ),
//           child: ExpansionTile(
//             title: Text('Item $index'),
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   if (onDelete != null)
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: removeItemizeSection,
//                       tooltip: 'Remove this item',
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.add, color: Colors.green),
//                     onPressed: addItemizeSection,
//                     tooltip: 'Add new item',
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     SearchableMultiColumnDropdownField<Project>(
//                       labelText: 'Project *',
//                       columnHeaders: const ['Project Name', 'Project ID'],
//                       items: controller.project,
//                       selectedValue: controller.selectedProject,
//                       searchValue: (p) => '${p.name} ${p.code}',
//                       displayText: (p) => p.code,
//                       validator: (value) =>
//                           value == null ? 'Please select Project' : null,
//                       onChanged: (p) {
//                         controller.selectedProject = p;
//                         controller.projectDropDowncontroller.text = p!.code;
//                       },
//                       controller: controller.projectDropDowncontroller,
//                       rowBuilder: (p, searchQuery) {
//                         Widget highlight(String text) {
//                           final query = searchQuery.toLowerCase();
//                           final lowerText = text.toLowerCase();
//                           final matchIndex = lowerText.indexOf(query);

//                           if (matchIndex == -1 || query.isEmpty)
//                             return Text(text);

//                           final end = matchIndex + query.length;
//                           return RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: text.substring(0, matchIndex),
//                                   
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(matchIndex, end),
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(end),
//                                   
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           child: Row(
//                             children: [
//                               Expanded(child: highlight(p.name)),
//                               Expanded(child: highlight(p.code)),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     SearchableMultiColumnDropdownField<ExpenseCategory>(
//                       labelText: 'Paid For *',
//                       columnHeaders: const ['Category Name', 'Category ID'],
//                       items: controller.expenseCategory,
//                       selectedValue: controller.selectedCategory,
//                       searchValue: (p) => '${p.categoryName} ${p.categoryId}',
//                       displayText: (p) => p.categoryId,
//                       validator: (value) =>
//                           value == null ? 'Please select Category' : null,
//                       onChanged: (p) {
//                         controller.selectedCategory = p;
//                       },
//                       controller: categoryController,
//                       rowBuilder: (p, searchQuery) {
//                         Widget highlight(String text) {
//                           final query = searchQuery.toLowerCase();
//                           final lower = text.toLowerCase();
//                           final matchIndex = lower.indexOf(query);

//                           if (matchIndex == -1 || query.isEmpty)
//                             return Text(text);

//                           final end = matchIndex + query.length;
//                           return RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: text.substring(0, matchIndex),
//                                   
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(matchIndex, end),
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(end),
//                                   
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           child: Row(
//                             children: [
//                               Expanded(child: highlight(p.categoryName)),
//                               Expanded(child: highlight(p.categoryId)),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     SearchableMultiColumnDropdownField<Unit>(
//                       labelText: 'Unit *',
//                       columnHeaders: const ['Uom Id', 'Uom Name'],
//                       items: controller.unit,
//                       selectedValue: controller.selectedunit,
//                       searchValue: (tax) => '${tax.code} ${tax.name}',
//                       displayText: (tax) => tax.code,
//                       validator: (tax) =>
//                           tax == null ? 'Please select a Unit' : null,
//                       onChanged: (tax) {
//                         controller.selectedunit = tax;
//                         uomIdController.text = tax!.code;
//                       },
//                       controller: uomIdController,
//                       rowBuilder: (tax, searchQuery) {
//                         Widget highlight(String text) {
//                           final query = searchQuery.toLowerCase();
//                           final lower = text.toLowerCase();
//                           final matchIndex = lower.indexOf(query);

//                           if (matchIndex == -1 || query.isEmpty)
//                             return Text(text);

//                           final end = matchIndex + query.length;
//                           return RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: text.substring(0, matchIndex),
//                                   
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(matchIndex, end),
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(end),
//                                   
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           child: Row(
//                             children: [
//                               Expanded(child: highlight(tax.code)),
//                               Expanded(child: highlight(tax.name)),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: commentsController,
//                       decoration: InputDecoration(
//                           labelText: "Comment",
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 20, horizontal: 16),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           )),
//                       maxLines: 2,
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: unitPriceController,
//                             decoration: InputDecoration(
//                                 labelText: "Unit Amount *",
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 20, horizontal: 16),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 )),
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) {
//                               final qty =
//                                   double.tryParse(quantityController.text) ??
//                                       0.0;
//                               final unit =
//                                   double.tryParse(unitPriceController.text) ??
//                                       0.0;
//                               final calculatedLineAmount = qty * unit;
//                               lineAmountController.text =
//                                   calculatedLineAmount.toStringAsFixed(2);
//                               var finalValueCount =
//                                   controllerItems.getTotalLineAmount().toStringAsFixed(2);
//                               print(
//                                   "calculatedLineAmount: $qty x $unit = $calculatedLineAmount finalCount$finalValueCount");
//                             },
                            
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter amount';
//                               }
//                               if (double.tryParse(value) == null) {
//                                 return 'Please enter valid number';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: TextFormField(
//                             controller: quantityController,
//                             decoration: InputDecoration(
//                                 labelText: "Quantity *",
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 20, horizontal: 16),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 )),
//                             keyboardType: TextInputType.number,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter quantity';
//                               }
//                               if (double.tryParse(value) == null) {
//                                 return 'Please enter valid number';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: lineAmountController,
//                             decoration: InputDecoration(
//                                 labelText: "Line Amont",
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 20, horizontal: 16),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 )),
//                             readOnly: true,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: TextFormField(
//                             controller: lineAmountINRController,
//                             decoration: InputDecoration(
//                                 labelText: "Line Amount in INR",
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 20, horizontal: 16),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 )),
//                             readOnly: true,
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     SearchableMultiColumnDropdownField<TaxGroupModel>(
//                       labelText: 'Tax Group *',
//                       columnHeaders: const ['Tax Group', 'Tax ID'],
//                       items: controller.taxGroup,
//                       selectedValue: controller.selectedTax,
//                       searchValue: (tax) => '${tax.taxGroup} ${tax.taxGroupId}',
//                       displayText: (tax) => tax.taxGroupId,
//                       validator: (value) =>
//                           value == null ? 'Please select Tax Group ' : null,
//                       onChanged: (tax) {
//                         controller.selectedTax = tax;
//                       },
//                       rowBuilder: (tax, searchQuery) {
//                         Widget highlight(String text) {
//                           final lowerQuery = searchQuery.toLowerCase();
//                           final lowerText = text.toLowerCase();
//                           final start = lowerText.indexOf(lowerQuery);
//                           if (start == -1 || searchQuery.isEmpty)
//                             return Text(text);

//                           final end = start + searchQuery.length;
//                           return RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: text.substring(0, start),
//                                   
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(start, end),
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: text.substring(end),
//                                   
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           child: Row(
//                             children: [
//                               Expanded(child: highlight(tax.taxGroup)),
//                               Expanded(child: highlight(tax.taxGroupId)),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: taxAmountController,
//                       decoration: InputDecoration(
//                           labelText: "Tax Amount",
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 20, horizontal: 16),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           )),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 16),
//                     const SizedBox(height: 24),
//                     Obx(() => SwitchListTile(
//                         title: const Text("Is Reimbursable",
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87)),
//                         value: controller.isReimbursiteCreate.value,
//                         activeColor: Colors.green,
//                         inactiveThumbColor: Colors.grey.shade400,
//                         inactiveTrackColor: Colors.grey.shade300,
//                         onChanged: (val) {
//                           controller.isReimbursiteCreate.value = val;
//                         })),
//                     Obx(() => SwitchListTile(
//                         title: const Text("Is Billable",
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87)),
//                         value: controller.isisBillablereate.value,
//                         activeColor: Colors.blue,
//                         inactiveThumbColor: Colors.grey.shade400,
//                         inactiveTrackColor: Colors.grey.shade300,
//                         onChanged: (val) {
//                           controller.isisBillablereate.value = val;
//                         })),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             final double lineAmount =
//                                 double.tryParse(lineAmountController.text) ??
//                                     0.0;

//                             showModalBottomSheet(
//                               context: context,
//                               isScrollControlled: true,
//                               shape: const RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(16)),
//                               ),
//                               builder: (context) => Padding(
//                                 padding: EdgeInsets.only(
//                                   bottom:
//                                       MediaQuery.of(context).viewInsets.bottom,
//                                   left: 16,
//                                   right: 16,
//                                   top: 24,
//                                 ),
//                                 child: SingleChildScrollView(
//                                   child: AccountingDistributionWidget(
//                                     index: index,
//                                     splits: split,
//                                     lineAmount: lineAmount,
//                                     onChanged: (i, updatedSplit) {
//                                       split[i] = updatedSplit;
//                                     },
//                                     onDistributionChanged: (newList) {
//                                       controller.accountingDistributions
//                                           .addAll(newList);
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text('Account Distribution'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }
// }

// class SubmissionSuccessScreen extends StatelessWidget {
//   final File imageFile;
//   final Map<String, dynamic> formData;

//   const SubmissionSuccessScreen({
//     Key? key,
//     required this.imageFile,
//     required this.formData,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Submission Successful'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 100),
//             const SizedBox(height: 20),
//             const Text(
//               'Expense Submitted Successfully!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Return to Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
