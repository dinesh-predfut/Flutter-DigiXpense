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

import '../../../../core/comman/widgets/pageLoaders.dart';
import '../../../../l10n/app_localizations.dart';

class ViewCashAdvanseReturnForm extends StatefulWidget {
  final CashAdvanceRequestHeader? items;
    final bool isReadOnly;

  const ViewCashAdvanseReturnForm({Key? key, this.items,required this.isReadOnly,
}) : super(key: key);

  @override
  State<ViewCashAdvanseReturnForm> createState() =>
      _ViewCashAdvanseReturnFormState();
}

class _ViewCashAdvanseReturnFormState extends State<ViewCashAdvanseReturnForm>
    with TickerProviderStateMixin {
  final TextEditingController expenseIdController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  TextEditingController merhantName = TextEditingController();
  final PhotoViewController _photoViewController = PhotoViewController();
  String? paidToError;
  late Future<Map<String, bool>> _featureFuture;
  bool _showUnitAmountError = false;
  bool _showLocationError = false;
  int _currentIndex = 0;
  late PageController _pageController;
  final List<String> paidToOptions = ['Amazon', 'Flipkart', 'Ola'];
  final List<String> paidWithOptions = ['Card', 'Cash', 'UPI'];
  final controller = Get.put(Controller());
  Future<List<ExpenseHistory>>? historyFuture;
  String? selectedPaidTo;
  String? selectedPaidWith;
  bool _isEditingExisting = false;
  bool _showHistory = false;
  Timer? _debounce;
  int _itemizeCount = 1;
  
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

  @override
  void initState() {
    super.initState();
   
    expenseIdController.text = "";
    requestDateController.text = "";
    merhantName.text = "";
   _featureFuture = controller.getAllFeatureStates();
    projectConfig = controller.getFieldConfig("Project Id");
    taxGroupConfig = controller.getFieldConfig("Tax Group");
    taxAmountConfig = controller.getFieldConfig("Tax Amount");
    isReimbursibleConfig = controller.getFieldConfig("is Reimbursible");
    isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
    isBillableConfig = controller.getFieldConfig("Is Billable");
    isLocationConfig = controller.getFieldConfig("Location");

    WidgetsBinding.instance.addPostFrameCallback((_) {
       _pageController =
        PageController(initialPage: controller.currentIndex.value);
      controller.getconfigureFieldCashAdvance();
      controller.fetchLocation();
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.fetchBusinessjustification();
      controller.fetchExpenseDocImage(widget.items!.recId);
      print("widget.items!.stepType == " "${widget.items!.stepType}");
      historyFuture = controller.cashadvanceTracking(widget.items!.recId);


    final timestamp = widget.items!.requestDate;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatted = DateFormat('dd/MM/yyyy').format(dateTime);
    requestDateController.text = formatted;

    if (widget.items != null && widget.items!.prefferedPaymentMethod != null) {
      controller.paymentMethodID =
          widget.items!.prefferedPaymentMethod.toString();
    }

    expenseIdController.text = widget.items!.requisitionId.toString();
    controller.justificationController.text =
        widget.items!.businessJustification;
    print('--- AccountingDistributions Added ---');
    controller.referenceID.text = widget.items?.referenceId?.toString() ?? '';
    if (widget.items != null && widget.items!.prefferedPaymentMethod != null) {
      controller.paidWithController.text =
          widget.items!.prefferedPaymentMethod!;
    } else {
      controller.paidWithController.text = ''; 
    }

    selectedPaidTo = paidToOptions.first;
    selectedPaidWith = paidWithOptions.first;
    controller.locationController.text = widget.items!.location ?? '';
    controller.estimatedamountINR.text =
        widget.items!.totalEstimatedAmountInReporting.toString();
    controller.requestamountINR.text =
        widget.items!.totalRequestedAmountInReporting.toString();
controller.requestedPercentage.text =
    widget.items?.percentage?.toString() ?? '100';
    controller.unitRate.text =
        widget.items!.totalEstimatedAmountInReporting.toString();
    if (widget.items?.workitemrecid != null) {
      workitemrecid = widget.items!.workitemrecid!;
    }

    calculateAmounts(controller.exchangeRate.toString());
    controller.amountINR.text =
        widget.items!.totalEstimatedAmountInReporting.toString();
    controller.expenseID = widget.items!.referenceId;
    controller.recID = widget.items!.recId;

    _initializeItemizeControllers();
        });
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
        print("currentLineAmount${controllers.amountINRCA2.text}");
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

   
controller.amountINRCA1.text=item.lineEstimatedAmountInReporting.toString();
controller.amountINRCA2.text=item.lineRequestedAdvanceInReporting.toString();
controller.totalRequestedAmount.text=item.lineAdvanceRequested.toString();
print("checklineAdvanceRequested${item.lineAdvanceRequested.toString()}");
                      _initializeControllerAsyncData(controller, item);

    controller.projectDropDowncontroller.text = item.projectId ?? '';
controller.descriptionController.text = item.description ?? '';
controller.quantity.text = item.quantity?.toString() ?? '0';
controller.unitPriceTrans.text = item.unitEstimatedAmount?.toString() ?? '0';
controller.lineAmount.text = item.unitEstimatedAmount?.toString() ?? '0';
controller.lineAmountINR.text = item.unitEstimatedAmount?.toString() ?? '0';
controller.taxAmount.text = item.taxAmount?.toString() ?? '0';
controller.unitRateCA2.text = item.lineRequestedExchangerate?.toString() ?? '0';
controller.unitRateCA1.text = item.lineEstimatedExchangerate?.toString() ?? '0';

controller.categoryController.text = item.expenseCategoryId ?? '';
controller.selectedCategoryId = item.expenseCategoryId ?? '';

controller.uomId.text = item.uomId ?? '';
controller.locationController.text = item.location ?? '';

controller.unitAmount.text = item.unitEstimatedAmount?.toString() ?? '0';
controller.totalunitEstimatedAmount.text =
    item.lineEstimatedAmount?.toString() ?? '0';

controller.currencyDropDowncontrollerCA3.text =
    item.lineEstimatedCurrency ?? '';
controller.currencyDropDowncontrollerCA2.text =
    item.lineRequestedCurrency ?? '';
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

      return controller;
    }).toList();

    _itemizeCount = widget.items!.cshCashAdvReqTrans.length;
    
    for (int i = 0; i < itemizeControllers.length; i++) {
      _itemizeFormKeys[i] = GlobalKey<FormState>();
    }
  }

  void _initializeControllerAsyncData(
      Controller controller, CashAdvanceRequestItemize item) async {
    final paidAmountText = item.lineEstimatedAmount;
    final double? paidAmounts = item.lineAdvanceRequested;
    final currency = item.lineEstimatedCurrency;

    if (currency != null && paidAmountText != null) {
      try {
        final results = await Future.wait([
          controller.fetchExchangeRateCA(currency, paidAmountText.toString()),
          controller.fetchMaxAllowedPercentage(),
        ]);

        final exchangeResponse1 = results[0] as ExchangeRateResponse?;
        final maxPercentage = item.percentage;

        if (exchangeResponse1 != null) {
          controller.unitRateCA1.text =
              exchangeResponse1.exchangeRate.toString();
          controller.amountINRCA1.text =
              exchangeResponse1.totalAmount.toStringAsFixed(2);
          controller.isVisible.value = true;
        }

        if (maxPercentage != null && maxPercentage > 0 && paidAmounts != null) {
          final calculatedPercentage = (paidAmounts * maxPercentage) / 100;
          print("lineAdvanceRequesteds$maxPercentage");
          controller.totalRequestedAmount.text =
              item.lineAdvanceRequested.toString();
          controller.calculatedPercentage.value = calculatedPercentage;
controller.requestedPercentage.text = maxPercentage.toString();
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

    final result = paid * rate;
    controller.amountINR.text = result.toStringAsFixed(2);
    controller.isVisible.value = true;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      final unitPrice =
          double.tryParse(itemController.unitPriceTrans.text) ?? 0.0;

      final lineAmountInINR = unitPrice * rate;
      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);
    }
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
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

        widget.items!.cshCashAdvReqTrans.add(newItem);

        final newController = Controller();

        newController.currencyDropDowncontrollerCA3 =
            TextEditingController(text: 'INR');
        newController.currencyDropDowncontrollerCA2 =
            TextEditingController(text: 'INR');
        newController.isVisible = false.obs;
        newController.calculatedPercentage = 0.0.obs;
        newController.split = <AccountingSplit>[].obs;

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

        itemizeControllers = List.from(itemizeControllers)..add(newController);

        _itemizeCount++;
        _selectedItemizeIndex = _itemizeCount - 1;
        showItemizeDetails = true;
        
        _itemizeFormKeys[_itemizeCount - 1] = GlobalKey<FormState>();
      });
    }
  }

  void _syncControllerToModel(int index) {
    final itemController = itemizeControllers[index];
    final originalItem = widget.items!.cshCashAdvReqTrans[index];

    setState(() {
      widget.items!.cshCashAdvReqTrans[index] = CashAdvanceRequestItemize(
        cashAdvReqHeader: originalItem.cashAdvReqHeader,
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
        percentage:
            (double.tryParse(itemController.requestedPercentage.text) ?? 1)
                .toInt(),
        lineEstimatedCurrency:
               itemController.currencyDropDowncontrollerCA3.text,
        lineRequestedCurrency:
        
            itemController.currencyDropDowncontrollerCA2.text,
        lineEstimatedAmount:
            double.tryParse(itemController.totalunitEstimatedAmount.text) ??
                0.0,
        lineEstimatedAmountInReporting:
            double.tryParse(itemController.amountINRCA1.text) ??
                0.0,
          lineAdvanceRequested:
              double.tryParse(itemController.totalRequestedAmount.text) ?? 0.0, 
        lineRequestedAdvanceInReporting:
            double.tryParse(itemController.amountINRCA2.text) ??
                0.0,
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
            dimensionValueId: controller?.dimensionValueId ?? 'Branch001',
          );
        }).toList(),
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

  bool _validateForm() {
    bool isValid = true;

    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    for (int i = 0; i < itemizeControllers.length; i++) {
      if (_itemizeFormKeys[i]?.currentState?.validate() == false) {
        isValid = false;
      }
    }

    if (controller.justificationController.text.isEmpty) {
      setState(() {
        paidToError = 'Business Justification is required';
      });
      isValid = false;
    }

    if (controller.imageFiles.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please upload at least one receipt image",
        backgroundColor: Colors.red,
      );
      isValid = false;
    }

    return isValid;
  }

  String? _validateRequiredField(String value, String fieldName, bool isMandatory) {
    if (isMandatory && (value.isEmpty || value.trim().isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateNumericField(String value, String fieldName, bool isMandatory) {
    if (isMandatory && value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.isNotEmpty && double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  String? _validateDropdownField(String value, String fieldName, bool isMandatory) {
    if (isMandatory && value == null) {
      return 'Please select $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
           if (!controller.isEnable.value) {
  controller.clearFormFields();      return true;
    }

       final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title:  Text(AppLocalizations.of(context)!.exitForm),
            content:  Text(
              AppLocalizations.of(context)!.exitWarning ,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child:  Text(AppLocalizations.of(context)!.cancel),
              ),
               TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true),
                child:  Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: Colors.red)),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
            maxLines: 2,
          ),
          actions: [
      
              if (widget.isReadOnly && widget.items != null  &&
                  widget.items!.approvalStatus != "Cancelled" &&
                   widget.items!.approvalStatus != "Approved" &&
                  widget.items!.stepType != "Approval" && widget.items!.approvalStatus != "Pending" ) 
                    Obx(() { return IconButton(
                  icon: Icon( 
                    controller.isEnable.value
                        ? Icons.remove_red_eye 
                        : Icons.edit_document,
                  ),
                  onPressed: () {
                    controller.isEnable.value = !controller.isEnable.value;
                    print(controller.isEnable.value);
                  },
                );
                    }),

              if (widget.items != null &&
                  widget.items!.stepType == "Approval") 
                    Obx(() {
                  return IconButton(
                  icon: Icon(
                    controller.isApprovalEnable.value
                        ? Icons.remove_red_eye
                        : Icons.edit_document, 
                  ),
                  onPressed: () {
                    controller.isApprovalEnable.value =
                        !controller.isApprovalEnable.value;
                  },
                );
 }),

               const SizedBox.shrink()
      
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
                        const SizedBox(height: 10),
                Obx(() {
  return Stack(
    children: [
      GestureDetector(
        onTap: () {
          if (controller.imageFiles.isEmpty &&
              controller.isEnable.value &&
              !controller.isLoadingviewImage.value) {
            _pickImage(ImageSource.gallery);
          }
        },
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
                  AppLocalizations.of(context)!.tapToUploadDocs,
                ),
              );
            }

            return PageView.builder(
              controller: _pageController,
              itemCount: controller.imageFiles.length,
              onPageChanged: (index) {
                controller.currentIndex.value = index;
              },
              itemBuilder: (_, index) {
                final file = controller.imageFiles[index];
                return GestureDetector(
                  onTap: () => _showFullImage(file, index),
                  child: Container(
                    margin: const EdgeInsets.all(8),
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
          }),
        ),
      ),

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
                      Text(AppLocalizations.of(context)!.receiptDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: "${AppLocalizations.of(context)!.cashAdvanceRequisitionId} *",
                        controller: expenseIdController,
                        isReadOnly: false,
                        validator: (value) => _validateRequiredField(value!, "Cash Advance Requisition ID", true),
                      ),
                        const SizedBox(height: 6),
                      buildDateField(
                        AppLocalizations.of(context)!.requestDate,
                        requestDateController,
                        isReadOnly: !controller.isEnable.value,
                      ),
  const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          SearchableMultiColumnDropdownField<Businessjustification>(
                            labelText: '${AppLocalizations.of(context)!.businessJustification} * ',
                            enabled: controller.isEnable.value,
                            columnHeaders: [
                              AppLocalizations.of(context)!.id,
                              AppLocalizations.of(context)!.name
                            ],
                            items: controller.justification,
                            selectedValue: controller.selectedjustification,
                            searchValue: (p) => '${p.id} ${p.name}',
                            displayText: (p) => p.name,
                            validator: (p) => _validateDropdownField(controller.justificationController.text, "Business Justification", true),
                            onChanged: (p) {
                              setState(() {
                                controller.selectedjustification = p;
                                controller.justificationController.text = p!.name;
                                paidToError = null;
                              });
                            },
                            controller: controller.justificationController,
                            rowBuilder: (p, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
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
                            labelText: AppLocalizations.of(context)!.paidWith,
                            columnHeaders: [
                              AppLocalizations.of(context)!.paymentName,
                              AppLocalizations.of(context)!.paymentId
                            ],
                            items: controller.paymentMethods,
                            selectedValue: controller.selectedPaidWith,
                            searchValue: (p) => '${p.paymentMethodName} ${p.paymentMethodId}',
                            displayText: (p) => p.paymentMethodName,
                            validator: (p) => _validateDropdownField(controller.paidWithController.text, "Payment Method", true),
                            onChanged: (p) {
                              setState(() {
                                controller.selectedPaidWith = p;
                                controller.paymentMethodID = p!.paymentMethodId;
                                controller.paidWithController.text = p.paymentMethodId;
                              });
                            },
                            controller: controller.paidWithController,
                            rowBuilder: (p, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      const SizedBox(height: 6),
                  ...controller.configListAdvance
                            .where((field) => field['IsEnabled'] == true && field['FieldName'] == 'Refrence Id')
                            .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory = field['IsMandatory'] ?? false;

                              late Widget inputFields;

                              if (label == 'Refrence Id') {
                                inputFields = _buildTextField(
                                  label: AppLocalizations.of(context)!.referenceId,
                                  controller: controller.referenceID,
                                  isReadOnly: controller.isEnable.value,
                                  validator: (value) => isRefrenceIDConfig.isMandatory
                                      ? _validateRequiredField(value!, "Reference ID", true)
                                      : null,
                                );
                              } else {
                                inputFields = TextField(
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
                                  inputFields,
                                  const SizedBox(height: 16),
                                ],
                              );
                            })
                            .toList(),
                      TextFormField(
                        controller: controller.estimatedamountINR,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: '${AppLocalizations.of(context)!.totalEstimatedAmountInInr} *',
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
                          labelText: '${AppLocalizations.of(context)!.totalEstimatedAmountInInr} *',
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                              print("cshCashAdvReqTrans.length${widget.items!.cshCashAdvReqTrans.length}");
                              return Form(
                                key: _itemizeFormKeys[index],
                                child: Card(
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
                                              "${AppLocalizations.of(context)!.item} ${index + 1}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                if (controller.isEnable.value && widget.items!.cshCashAdvReqTrans.length > 1)
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
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ...controller.configListAdvance
                                                .where((field) => field['IsEnabled'] == true && field['FieldName'] != 'Location' && field['FieldName'] != 'Refrence Id' && field['FieldName'] != 'Is Billable' && field['FieldName'] != 'is Reimbursible')
                                                .map((field) {
                                                  final String label = field['FieldName'];
                                                  final bool isMandatory = field['IsMandatory'] ?? false;

                                                  Widget inputField;

                                                  if (label == 'Project Id') {
                                                    inputField = SearchableMultiColumnDropdownField<Project>(
                                                      enabled: controller.isEnable.value,
                                                      labelText: AppLocalizations.of(context)!.projectId,
                                                      columnHeaders: [
                                                        AppLocalizations.of(context)!.projectName,
                                                        AppLocalizations.of(context)!.projectId
                                                      ],
                                                      items: controller.project,
                                                      selectedValue: itemController.selectedProject,
                                                      searchValue: (p) => '${p.name} ${p.code}',
                                                      displayText: (p) => p.code,
                                                      validator: (p) => _validateDropdownField(itemController.projectDropDowncontroller.text, "Project", isMandatory),
                                                      onChanged: (p) {
                                                        setState(() {
                                                          controller.selectedProject = p;
                                                          itemController.selectedProject = p;
                                                          controller.projectDropDowncontroller.text = p!.code;
                                                        });
                                                        controller.fetchExpenseCategory();
                                                        _syncControllerToModel(index);
                                                        _calculateTotalLineAmount(itemController);
                                                        _calculateTotalLineAmount2(itemController);
                                                      },
                                                      controller: itemController.projectDropDowncontroller,
                                                      rowBuilder: (p, searchQuery) {
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                          child: Row(
                                                            children: [
                                                              Expanded(child: Text(p.name)),
                                                              Expanded(child: Text(p.code)),
                                                            ],
                                                          ),
                                                        );
                                                      },
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
                                         
                                          const SizedBox(height: 12),
                                          SearchableMultiColumnDropdownField<ExpenseCategory>(
                                            labelText: AppLocalizations.of(context)!.paidFor,
                                            enabled: controller.isEnable.value,
                                            columnHeaders: [
                                              AppLocalizations.of(context)!.categoryName,
                                              AppLocalizations.of(context)!.categoryId
                                            ],
                                            items: controller.expenseCategory,
                                            selectedValue: itemController.selectedCategory,
                                            searchValue: (p) => '${p.categoryName} ${p.categoryId}',
                                            displayText: (p) => p.categoryId,
                                            validator: (p) => _validateDropdownField(itemController.categoryController.text, "Expense Category", false),
                                            onChanged: (p) {
                                              setState(() {
                                                itemController.selectedCategory = p;
                                                itemController.selectedCategoryId = p!.categoryId;
                                                itemController.categoryController.text = p.categoryId;
                                                controller.selectedCategoryId = itemController.selectedCategoryId = p!.categoryId;
                                              });
                                              itemController.fetchMaxAllowedPercentage();
                                              _syncControllerToModel(index);
                                              _calculateTotalLineAmount(itemController);
                                              _calculateTotalLineAmount2(itemController);
                                            },
                                            controller: itemController.categoryController,
                                            rowBuilder: (p, searchQuery) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: Text(p.categoryName)),
                                                    Expanded(child: Text(p.categoryId)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          Obx(() {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: controller.configListAdvance
                                                  .where((field) => field['FieldName'] == 'Location' && field['IsEnabled'] == true)
                                                  .map((field) {
                                                final String label = field['FieldName'];
                                                final bool isMandatory = field['IsMandatory'] ?? false;

                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SearchableMultiColumnDropdownField<LocationModel>(
                                                      labelText: '${AppLocalizations.of(context)!.location} ${isMandatory ? "*" : ""}',
                                                      columnHeaders: [
                                                        AppLocalizations.of(context)!.location,
                                                        AppLocalizations.of(context)!.country
                                                      ],
                                                      enabled: controller.isEnable.value,
                                                      controller: itemController.locationController,
                                                      items: controller.location,
                                                      selectedValue: itemController.selectedLocation,
                                                      searchValue: (loc) => loc.location,
                                                      displayText: (loc) => loc.location,
                                                      validator: (loc) => _validateDropdownField(itemController.locationController.text, "Location", isMandatory),
                                                      onChanged: (loc) {
                                                        itemController.locationController.text = loc!.city;
                                                        controller.selectedLocation = loc;
                                                        itemController.fetchMaxAllowedPercentage();
                                                        field['Error'] = null;
                                                        final qty = double.tryParse(itemController.quantity.text) ?? 0.0;
                                                        final unit = double.tryParse(itemController.unitAmount.text) ?? 0.0;

                                                        final calculatedLineAmount = qty * unit;

                                                        itemController.totalunitEstimatedAmount.text = calculatedLineAmount.toStringAsFixed(2);
                                                        itemController.paidAmount.text = calculatedLineAmount.toStringAsFixed(2);
                                                        if (_debounce?.isActive ?? false)
                                                          _debounce!.cancel();

                                                        _debounce = Timer(const Duration(milliseconds: 400), () async {
                                                          final paidAmountText = itemController.totalunitEstimatedAmount.text.trim();
                                                          final double paidAmounts = double.tryParse(paidAmountText) ?? 0.0;
                                                          final currency = itemController.currencyDropDowncontrollerCA3.text;

                                                          if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
                                                            final results = await Future.wait([
                                                              itemController.fetchExchangeRateCA(currency, paidAmountText),
                                                              itemController.fetchMaxAllowedPercentage(),
                                                            ]);

                                                            final exchangeResponse1 = results[0] as ExchangeRateResponse?;
                                                            if (exchangeResponse1 != null) {
                                                              itemController.unitRateCA1.text = exchangeResponse1.exchangeRate.toString();
                                                              itemController.amountINRCA1.text = exchangeResponse1.totalAmount.toStringAsFixed(2);
                                                              itemController.isVisible.value = true;
                                                            }

                                                            final maxPercentage = results[1] as double?;

                                                            if (maxPercentage != null && maxPercentage > 0) {
                                                              final double calculatedPercentage = (paidAmounts * maxPercentage) / 100;

                                                              itemController.totalRequestedAmount.text = calculatedPercentage.toString();
                                                              itemController.calculatedPercentage.value = calculatedPercentage;
                                                              final percentageStr = maxPercentage.toInt().toString();
                                                              itemController.requestedPercentage.text = percentageStr;
                                                            }
                                                            final reqPaidAmount = itemController.totalRequestedAmount.text.trim();
                                                            final reqCurrency = itemController.currencyDropDowncontrollerCA2.text;
                                                            if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
                                                              final exchangeResponse = await itemController.fetchExchangeRateCA(reqCurrency, reqPaidAmount);

                                                              if (exchangeResponse != null) {
                                                                itemController.unitRateCA2.text = exchangeResponse.exchangeRate.toString();
                                                                itemController.amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                              }
                                                            }
                                                          }
                                                        });
                                                        _syncControllerToModel(index);
                                                        _calculateTotalLineAmount(itemController);
                                                        _calculateTotalLineAmount2(itemController);
                                                      },
                                                      rowBuilder: (loc, searchQuery) {
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                          child: Row(
                                                            children: [
                                                              Expanded(child: Text(loc.location)),
                                                              Expanded(child: Text(loc.country)),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    if (_showLocationError)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 4),
                                                        child: Text(
                                                          AppLocalizations.of(context)!.pleaseSelectLocation,
                                                          style: const TextStyle(color: Colors.red, fontSize: 12),
                                                        ),
                                                      ),
                                                    const SizedBox(height: 6),
                                                  ],
                                                );
                                              }).toList(),
                                            );
                                          }),
                                          _buildTextField(
                                            label: AppLocalizations.of(context)!.comments,
                                            controller: itemController.descriptionController,
                                            isReadOnly: controller.isEnable.value,
                                            onChanged: (value) {
                                              setState(() {
                                                _syncControllerToModel(index);
                                                _calculateTotalLineAmount(itemController);
                                                _calculateTotalLineAmount2(itemController);
                                              });
                                            },
                                            validator: (value) => _validateRequiredField(value!, "Description", false),
                                          ),
                                          SearchableMultiColumnDropdownField<Unit>(
                                            labelText: '${AppLocalizations.of(context)!.unit} *',
                                            enabled: controller.isEnable.value,
                                            columnHeaders: [
                                              AppLocalizations.of(context)!.uomId,
                                              AppLocalizations.of(context)!.uomName
                                            ],
                                            items: controller.unit,
                                            selectedValue: itemController.selectedunit,
                                            searchValue: (tax) => '${tax.code} ${tax.name}',
                                            displayText: (tax) => tax.name,
                                            validator: (tax) => _validateDropdownField(itemController.uomId.text, "Unit", true),
                                            onChanged: (tax) {
                                              setState(() {
                                                itemController.selectedunit = tax;
                                                itemController.uomId.text = tax!.code;
                                                _syncControllerToModel(index);
                                                _calculateTotalLineAmount(itemController);
                                                _calculateTotalLineAmount2(itemController);
                                              });
                                            },
                                            controller: itemController.uomId,
                                            rowBuilder: (tax, searchQuery) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                         TextField(
  controller: itemController.requestedPercentage,
  enabled: controller.isEnable.value,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: "${AppLocalizations.of(context)!.requestedPercentage} %",
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  onChanged: (value) {
    if (value.isEmpty) return;

    final double percentage = double.tryParse(value) ?? 0.0;
    if (percentage <= 0) return;

    // Cancel debounce
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      /// Base values
      final double unitAmount =
          double.tryParse(itemController.unitAmount.text) ?? 0.0;

      /// 1️⃣ Calculate estimated amount
      final double estimatedAmount = unitAmount * percentage / 100;

      itemController.totalunitEstimatedAmount.text =
          estimatedAmount.toStringAsFixed(2);
      itemController.paidAmount.text =
          estimatedAmount.toStringAsFixed(2);

      /// 2️⃣ Exchange rate (Paid Amount)
      final currency1 =
          itemController.currencyDropDowncontrollerCA3.text;

      if (currency1.isNotEmpty) {
        final exchangeResponse =
            await itemController.fetchExchangeRateCA(
                currency1, estimatedAmount.toString());

        if (exchangeResponse != null) {
          itemController.unitRateCA1.text =
              exchangeResponse.exchangeRate.toString();
          itemController.amountINRCA1.text =
              exchangeResponse.totalAmount.toStringAsFixed(2);
          itemController.isVisible.value = true;
        }
      }

      /// 3️⃣ Requested Amount calculation
      final maxAllowed =
          await itemController.fetchMaxAllowedPercentage();

      if (maxAllowed != null && maxAllowed > 0) {
        final double requestedAmount =
            (estimatedAmount * maxAllowed) / 100;

        itemController.totalRequestedAmount.text =
            requestedAmount.toStringAsFixed(2);
        itemController.calculatedPercentage.value =
            requestedAmount;
      }

      /// 4️⃣ Exchange rate (Requested Amount)
      final reqCurrency =
          itemController.currencyDropDowncontrollerCA2.text;
      final reqAmount =
          itemController.totalRequestedAmount.text;

      if (reqCurrency.isNotEmpty && reqAmount.isNotEmpty) {
        final exchangeResponse =
            await itemController.fetchExchangeRateCA(
                reqCurrency, reqAmount);

        if (exchangeResponse != null) {
          itemController.unitRateCA2.text =
              exchangeResponse.exchangeRate.toString();
          itemController.amountINRCA2.text =
              exchangeResponse.totalAmount.toStringAsFixed(2);

          _calculateTotalLineAmount(itemController);
          _calculateTotalLineAmount2(itemController);
        }
      }

      _syncControllerToModel(index);
    });
  },
),

                                          const SizedBox(height: 12),
                                          _buildTextField(
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                            ],
                                            label: "${AppLocalizations.of(context)!.quantity} *",
                                            controller: itemController.quantity,
                                            isReadOnly: controller.isEnable.value,
                                            validator: (value) => _validateNumericField(value!, "Quantity", true),
                                            onChanged: (value) {
                                              itemController.calculateLineAmounts(itemController);
                                              setState(() {});
                                              final qty = double.tryParse(value) ?? 0.0;
                                              final unit = double.tryParse(itemController.unitAmount.text) ?? 0.0;

                                              final calculatedLineAmount = qty * unit;

                                              itemController.totalunitEstimatedAmount.text = calculatedLineAmount.toStringAsFixed(2);
                                              itemController.paidAmount.text = calculatedLineAmount.toStringAsFixed(2);
                                              if (_debounce?.isActive ?? false)
                                                _debounce!.cancel();

                                              _debounce = Timer(const Duration(milliseconds: 400), () async {
                                                final paidAmountText = itemController.totalunitEstimatedAmount.text.trim();
                                                final double paidAmounts = double.tryParse(paidAmountText) ?? 0.0;
                                                final currency = itemController.currencyDropDowncontrollerCA3.text;

                                                if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
                                                  final results = await Future.wait([
                                                    itemController.fetchExchangeRateCA(currency, paidAmountText),
                                                    itemController.fetchMaxAllowedPercentage(),
                                                  ]);

                                                  final exchangeResponse1 = results[0] as ExchangeRateResponse?;
                                                  if (exchangeResponse1 != null) {
                                                    itemController.unitRateCA1.text = exchangeResponse1.exchangeRate.toString();
                                                    itemController.amountINRCA1.text = exchangeResponse1.totalAmount.toStringAsFixed(2);
                                                    itemController.isVisible.value = true;
                                                  }

                                                  final maxPercentage = results[1] as double?;

                                                  if (maxPercentage != null && maxPercentage > 0) {
                                                    final double calculatedPercentage = (paidAmounts * maxPercentage) / 100;

                                                    itemController.totalRequestedAmount.text = calculatedPercentage.toString();
                                                    itemController.calculatedPercentage.value = calculatedPercentage;
                                                    final percentageStr = maxPercentage.toInt().toString();
                                                    itemController.requestedPercentage.text = percentageStr;
                                                  }
                                                  final reqPaidAmount = itemController.totalRequestedAmount.text.trim();
                                                  final reqCurrency = itemController.currencyDropDowncontrollerCA2.text;
                                                  if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
                                                    final exchangeResponse = await itemController.fetchExchangeRateCA(reqCurrency, reqPaidAmount);

                                                    if (exchangeResponse != null) {
                                                      itemController.unitRateCA2.text = exchangeResponse.exchangeRate.toString();
                                                      itemController.amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                      _calculateTotalLineAmount(itemController);
                                                      _calculateTotalLineAmount2(itemController);
                                                    }
                                                  }
                                                }
                                                _syncControllerToModel(index);
                                              });
                                            },
                                          ),
                                          TextFormField(
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.done,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                            ],
                                            controller: itemController.unitAmount,
                                            enabled: controller.isEnable.value,
                                            validator: (value) => _validateNumericField(value!, "Unit Estimated Amount", true),
                                            onChanged: (value) {
                                               if (_debounce?.isActive ?? false) _debounce!.cancel();
                                              controller.fetchExchangeRate();

                                              setState(() {
                                                itemController.unitAmount.text = value;
                                                _showUnitAmountError = false;
                                              });
                                              final qty = double.tryParse(itemController.quantity.text) ?? 0.0;
                                              final unit = double.tryParse(itemController.unitAmount.text) ?? 0.0;

                                              final calculatedLineAmount = qty * unit;

                                              itemController.totalunitEstimatedAmount.text = calculatedLineAmount.toStringAsFixed(2);
                                              itemController.paidAmount.text = calculatedLineAmount.toStringAsFixed(2);
                                              if (_debounce?.isActive ?? false)
                                                _debounce!.cancel();

                                              _debounce = Timer(const Duration(milliseconds: 400), () async {
                                                final paidAmountText = itemController.totalunitEstimatedAmount.text.trim();
                                                final double paidAmounts = double.tryParse(paidAmountText) ?? 0.0;
                                                final currency = itemController.currencyDropDowncontrollerCA3.text;

                                                if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
                                                  final results = await Future.wait([
                                                    itemController.fetchExchangeRateCA(currency, paidAmountText),
                                                    itemController.fetchMaxAllowedPercentage(),
                                                  ]);

                                                  final exchangeResponse1 = results[0] as ExchangeRateResponse?;
                                                  if (exchangeResponse1 != null) {
                                                    itemController.unitRateCA1.text = exchangeResponse1.exchangeRate.toString();
                                                    itemController.amountINRCA1.text = exchangeResponse1.totalAmount.toStringAsFixed(2);
                                                    itemController.isVisible.value = true;
                                                  }

                                                  final maxPercentage = results[1] as double?;

                                                  if (maxPercentage != null && maxPercentage > 0) {
                                                    final double calculatedPercentage = (paidAmounts * maxPercentage) / 100;

                                                    itemController.totalRequestedAmount.text = calculatedPercentage.toString();
                                                    itemController.calculatedPercentage.value = calculatedPercentage;
                                                    final percentageStr = maxPercentage.toInt().toString();
                                                    itemController.requestedPercentage.text = percentageStr;
                                                  }
                                                  final reqPaidAmount = itemController.totalRequestedAmount.text.trim();
                                                  final reqCurrency = itemController.currencyDropDowncontrollerCA2.text;
                                                  if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
                                                    final exchangeResponse = await itemController.fetchExchangeRateCA(reqCurrency, reqPaidAmount);

                                                    if (exchangeResponse != null) {
                                                      itemController.unitRateCA2.text = exchangeResponse.exchangeRate.toString();
                                                      itemController.amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                      _calculateTotalLineAmount(itemController).toStringAsFixed(2);
                                                      _calculateTotalLineAmount2(itemController).toStringAsFixed(2);
                                                    }
                                                  }
                                                }
                                                _syncControllerToModel(index);
                                              });
                                            },
                                            onEditingComplete: () {
                                              FocusScope.of(context).unfocus();
                                              String text = itemController.unitAmount.text;
                                              double? value = double.tryParse(text);
                                              if (value != null) {
                                                itemController.unitAmount.text = value.toStringAsFixed(2);
                                                itemController.paidAmount.text = value.toStringAsFixed(2);
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: "${AppLocalizations.of(context)!.unitEstimatedAmount} *",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(width: 2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${AppLocalizations.of(context)!.totalEstimatedAmountInInr} *',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(height: 4),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        controller: itemController.totalunitEstimatedAmount,
                                                        enabled: !showItemizeDetails,
                                                        keyboardType: TextInputType.number,
                                                        validator: (value) => _validateNumericField(value!, "Total Estimated Amount", true),
                                                        decoration: InputDecoration(
                                                          hintText: AppLocalizations.of(context)!.paidAmount,
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

                                                          _debounce = Timer(const Duration(milliseconds: 400), () async {
                                                            final paidAmountText = itemController.totalunitEstimatedAmount.text.trim();
                                                            itemController.unitAmount.text = itemController.totalunitEstimatedAmount.text;
                                                            final double paidAmounts = double.tryParse(paidAmountText) ?? 0.0;
                                                            final currency = itemController.currencyDropDowncontrollerCA3.text;

                                                            if (currency.isNotEmpty && paidAmountText.isNotEmpty) {
                                                              final results = await Future.wait([
                                                                itemController.fetchExchangeRateCA(currency, paidAmountText),
                                                                itemController.fetchMaxAllowedPercentage(),
                                                              ]);

                                                              final exchangeResponse1 = results[0] as ExchangeRateResponse?;
                                                              if (exchangeResponse1 != null) {
                                                                itemController.unitRateCA1.text = exchangeResponse1.exchangeRate.toString();
                                                                itemController.amountINRCA1.text = exchangeResponse1.totalAmount.toStringAsFixed(2);
                                                                itemController.isVisible.value = true;
                                                              }

                                                              final maxPercentage = results[1] as double?;

                                                              if (maxPercentage != null && maxPercentage > 0) {
                                                                final double calculatedPercentage = (paidAmounts * maxPercentage) / 100;

                                                                itemController.totalRequestedAmount.text = calculatedPercentage.toString();
                                                                itemController.calculatedPercentage.value = calculatedPercentage;

                                                                final percentageStr = maxPercentage.toInt().toString();
                                                                itemController.requestedPercentage.text = '$percentageStr %';

                                                                if (calculatedPercentage > 100) {
                                                                  Fluttertoast.showToast(
                                                                    msg: AppLocalizations.of(context)!.paidAmountExceedsMaxPercentage,
                                                                    backgroundColor: Colors.red,
                                                                    textColor: Colors.white,
                                                                  );
                                                                }
                                                              }
                                                              final reqPaidAmount = itemController.totalRequestedAmount.text.trim();
                                                              final reqCurrency = itemController.currencyDropDowncontrollerCA2.text;
                                                              if (reqCurrency.isNotEmpty && reqPaidAmount.isNotEmpty) {
                                                                final exchangeResponse = await itemController.fetchExchangeRateCA(reqCurrency, reqPaidAmount);

                                                                if (exchangeResponse != null) {
                                                                  itemController.unitRateCA2.text = exchangeResponse.exchangeRate.toString();
                                                                  itemController.amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                                  _syncControllerToModel(index);
                                                                  _calculateTotalLineAmount(itemController);
                                                                  _calculateTotalLineAmount2(itemController);
                                                                }
                                                              }
                                                            }
                                                          });
                                                        },
                                                        onEditingComplete: () {
                                                          String text = itemController.totalunitEstimatedAmount.text;
                                                          double? value = double.tryParse(text);
                                                          if (value != null) {
                                                            itemController.totalunitEstimatedAmount.text = value.toStringAsFixed(2);
                                                          }
                                                        },
                                                      ),
                                                    ),

                                                    Obx(
                                                      () => SizedBox(
                                                        width: 90,
                                                        child: SearchableMultiColumnDropdownField<Currency>(
                                                          labelText: AppLocalizations.of(context)!.currency,
                                                          alignLeft: -90,
                                                          dropdownWidth: 280,
                                                          columnHeaders: [
                                                            AppLocalizations.of(context)!.code,
                                                            AppLocalizations.of(context)!.name,
                                                            AppLocalizations.of(context)!.symbol
                                                          ],
                                                          controller: itemController.currencyDropDowncontrollerCA3,
                                                          items: controller.currencies,
                                                          selectedValue: itemController.selectedCurrencyCA1.value,
                                                          searchValue: (c) => '${c.code} ${c.name} ${c.symbol}',
                                                          displayText: (c) => c.code,
                                                          enabled: controller.isEnable.value,
                                                          validator: (c) => _validateDropdownField(itemController.currencyDropDowncontrollerCA3.text, "Currency", true),
                                                          inputDecoration: const InputDecoration(
                                                            suffixIcon: Icon(Icons.arrow_drop_down_outlined),
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
                                                            itemController.selectedCurrencyCA1.value = c;
                                                            itemController.currencyDropDowncontrollerCA3.text = c?.code ?? '';

                                                            final paidAmount = itemController.totalunitEstimatedAmount.text.trim();
                                                            if (paidAmount.isNotEmpty) {
                                                              final exchangeResponse = await itemController.fetchExchangeRateCA(
                                                                c!.code,
                                                                paidAmount,
                                                              );

                                                              if (exchangeResponse != null) {
                                                                itemController.unitRateCA1.text = exchangeResponse.exchangeRate.toString();
                                                                itemController.amountINRCA1.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                              }
                                                            }
                                                          },
                                                          rowBuilder: (c, searchQuery) {
                                                            return Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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

                                                    const SizedBox(width: 8),

                                                    Expanded(
                                                      child: TextFormField(
                                                        enabled: false,
                                                        controller: itemController.unitRateCA1,
                                                        decoration: InputDecoration(
                                                          hintText: AppLocalizations.of(context)!.rate,
                                                          isDense: true,
                                                          border: const OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 10),
                                                TextFormField(
                                                  controller: itemController.amountINRCA1,
                                                  enabled: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText: '${AppLocalizations.of(context)!.amountInInr} *',
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  '${AppLocalizations.of(context)!.totalRequestedAmount}  *',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(height: 4),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        controller: itemController.totalRequestedAmount,
                                                        enabled: false,
                                                        keyboardType: TextInputType.number,
                                                        validator: (value) => _validateNumericField(value!, "Total Requested Amount", true),
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          hintText: AppLocalizations.of(context)!.paidAmount,
                                                          border: const OutlineInputBorder(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(10),
                                                              bottomLeft: Radius.circular(10),
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (_) async {
                                                          final paidAmount = itemController.totalRequestedAmount.text.trim();
                                                          final currency = itemController.currencyDropDowncontrollerCA2.text;

                                                          if (currency.isNotEmpty && paidAmount.isNotEmpty) {
                                                            final exchangeResponse = await itemController.fetchExchangeRateCA(currency, paidAmount);

                                                            if (exchangeResponse != null) {
                                                              itemController.unitRateCA2.text = exchangeResponse.exchangeRate.toString();
                                                              itemController.amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                              itemController.isVisible.value = true;
                                                            }
                                                          }
                                                        },
                                                        onEditingComplete: () {
                                                          String text = itemController.totalRequestedAmount.text;
                                                          double? value = double.tryParse(text);
                                                          if (value != null) {
                                                            itemController.totalRequestedAmount.text = value.toStringAsFixed(2);
                                                          }
                                                        },
                                                      ),
                                                    ),

                                                    Obx(
                                                      () => SizedBox(
                                                        width: 90,
                                                        child: SearchableMultiColumnDropdownField<Currency>(
                                                          labelText: AppLocalizations.of(context)!.currency,
                                                          alignLeft: -90,
                                                          enabled: controller.isEnable.value,
                                                          dropdownWidth: 280,
                                                          columnHeaders: [
                                                            AppLocalizations.of(context)!.code,
                                                            AppLocalizations.of(context)!.name,
                                                            AppLocalizations.of(context)!.symbol
                                                          ],
                                                          controller: itemController.currencyDropDowncontrollerCA2,
                                                          items: controller.currencies,
                                                          selectedValue: itemController.selectedCurrencyCA2.value,
                                                          backgroundColor: Colors.white,
                                                          searchValue: (c) => '${c.code} ${c.name} ${c.symbol}',
                                                          displayText: (c) => c.code,
                                                          validator: (c) => _validateDropdownField(itemController.currencyDropDowncontrollerCA2.text, "Currency", true),
                                                          inputDecoration: const InputDecoration(
                                                            isDense: true,
                                                            suffixIcon: Icon(Icons.arrow_drop_down_outlined),
                                                            filled: true,
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(10),
                                                                bottomRight: Radius.circular(10),
                                                              ),
                                                            ),
                                                          ),
                                                          onChanged: (c) async {
                                                            itemController.selectedCurrencyCA2.value = c;
                                                            controller.currencyDropDowncontrollerCA2.text = c?.code ?? '';

                                                            final paidAmount = itemController.totalRequestedAmount.text.trim();
                                                            if (paidAmount.isNotEmpty) {
                                                              final exchangeResponse = await itemController.fetchExchangeRateCA(c!.code, paidAmount);

                                                              if (exchangeResponse != null) {
                                                                itemController.unitRateCA2.text = exchangeResponse.exchangeRate.toString();
                                                                itemController.amountINRCA2.text = exchangeResponse.totalAmount.toStringAsFixed(2);
                                                                _syncControllerToModel(index);
                                                                _calculateTotalLineAmount(itemController);
                                                                _calculateTotalLineAmount2(itemController);
                                                              }
                                                            }
                                                          },
                                                          rowBuilder: (c, searchQuery) {
                                                            return Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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

                                                    const SizedBox(width: 8),

                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: itemController.unitRateCA2,
                                                        enabled: false,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          hintText: AppLocalizations.of(context)!.rate,
                                                          border: const OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 10),
                                                TextFormField(
                                                  controller: itemController.amountINRCA2,
                                                  enabled: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText: '${AppLocalizations.of(context)!.amountInInr} *',
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
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
                                                    final double lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
                                                    if (itemController.split.isEmpty && item.accountingDistributions!.isNotEmpty) {
                                                      itemController.split.assignAll(
                                                        item.accountingDistributions!.map((e) {
                                                          return AccountingSplit(
                                                            paidFor: e.dimensionValueId,
                                                            percentage: e.allocationFactor,
                                                            amount: e.transAmount,
                                                          );
                                                        }).toList(),
                                                      );
                                                    } else if (itemController.split.isEmpty) {
                                                      itemController.split.add(AccountingSplit(percentage: 100.0));
                                                    }

                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                                                            splits: itemController.split,
                                                            lineAmount: lineAmount,
                                                            onChanged: (i, updatedSplit) {
                                                              if (!mounted) return;
                                                              itemController.split[i] = updatedSplit;
                                                              _syncControllerToModel(index);
                                                            },
                                                            onDistributionChanged: (newList) {
                                                              if (!mounted) return;
                                                              item.accountingDistributions!.clear();
                                                              item.accountingDistributions!.addAll(newList);
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
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
                      if (widget.items!.workitemrecid == null) ...[
                        if (controller.isEnable.value && widget.items!.approvalStatus == "Rejected")
                          Obx(() {
                            final isResubmitLoading = controller.buttonLoaders['resubmit'] ?? false;
                            final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading);

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

                                        controller.saveinEditCashAdvance(context, true, true, widget.items!.recId, widget.items!.requisitionId)
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
                        if (controller.isEnable.value && widget.items!.approvalStatus == "Rejected")
                          Row(
                            children: [
                              Obx(() {
                                final isUpdateLoading = controller.buttonLoaders['update'] ?? false;
                                final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading);

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
                                            controller.saveinEditCashAdvance(context, false, false, widget.items!.recId, widget.items!.requisitionId)
                                                .whenComplete(() {
                                              controller.setButtonLoading('update', false);
                                            });
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
                                  onPressed: () {
                                    controller.chancelButton(context);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (controller.isEnable.value && widget.items!.approvalStatus == "Created") ...[
                          Obx(() {
                            final isSubmitLoading = controller.buttonLoaders['submit'] ?? false;
                            final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading);

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
                                        final items = itemizeControllers.map((c) => c.toCashAdvanceRequestItemize()).toList();
                                        controller.cashAdvanceReturnFinalItem(widget.items!);

                                        controller.saveinEditCashAdvance(context, true, false, widget.items!.recId, widget.items!.requisitionId)
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
                                final isSaveLoading = controller.buttonLoaders['saveGE'] ?? false;
                                final isSubmitLoading = controller.buttonLoaders['submit'] ?? false;
                                final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: (isSaveLoading || isSubmitLoading || isAnyLoading)
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
                                            controller.cashAdvanceReturnFinalItem(widget.items!);

                                            controller.saveinEditCashAdvance(context, false, false, widget.items!.recId, widget.items!.requisitionId)
                                                .whenComplete(() {
                                              controller.setButtonLoading('saveGE', false);
                                            });
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
                                final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading);

                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isAnyLoading
                                        ? null
                                        : () {
                                            Navigator.pushNamed(context, AppRoutes.cashAdvanceRequestDashboard);
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
                        if (widget.isReadOnly && widget.items!.approvalStatus == "Pending")
                          Row(
                            children: [
                              Obx(() {
                                final isLoading = controller.buttonLoaders['cancel'] ?? false;
                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            controller.setButtonLoading('cancel', true);
                                            controller.cancelCashadvance(context, widget.items!.recId.toString())
                                                .whenComplete(() {
                                              controller.setButtonLoading('cancel', false);
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
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                  child: Text(
                                    AppLocalizations.of(context)!.close,
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
                            child: Text(
                              AppLocalizations.of(context)!.close,
                            ),
                          ),
                      ] else ...[
                        if (controller.isEnable.value && widget.items!.stepType == "Review")
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final isLoadingAccept = controller.buttonLoaders['update_accept'] ?? false;
                                  final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);

                                  return ElevatedButton(
                                    onPressed: (isLoadingAccept || isAnyLoading)
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
                                            controller.cashAdvanceReturnFinalItem(widget.items!);

                                            try {
                                              await controller.reviewandUpdateCashAdvance(context, true, widget.items!.recId, widget.items!.requisitionId, widget.items!.workitemrecid);
                                            } finally {
                                              controller.setButtonLoading('update_accept', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                                    ),
                                    child: isLoadingAccept
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
                                  final isLoadingUpdate = controller.buttonLoaders['update_review'] ?? false;
                                  final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);

                                  return ElevatedButton(
                                    onPressed: (isLoadingUpdate || isAnyLoading)
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
                                            controller.cashAdvanceReturnFinalItem(widget.items!);

                                            try {
                                              await controller.reviewandUpdateCashAdvance(context, false, widget.items!.recId, widget.items!.requisitionId, widget.items!.workitemrecid);
                                            } finally {
                                              controller.setButtonLoading('update_review', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                                    ),
                                    child: isLoadingUpdate
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
                        if (controller.isEnable.value && widget.items!.stepType == "Review")
                          const SizedBox(height: 12),

                        if (controller.isEnable.value && widget.items!.stepType == "Review")
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final isLoadingReject = controller.buttonLoaders['reject_review'] ?? false;
                                  final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);

                                  return ElevatedButton(
                                    onPressed: (isLoadingReject || isAnyLoading)
                                        ? null
                                        : () async {
                                            controller.setButtonLoading('reject_review', true);
                                            try {
                                              showActionPopup(context, "Reject");
                                            } finally {
                                              controller.setButtonLoading('reject_review', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                                    ),
                                    child: isLoadingReject
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
                                  final isLoadingClose = controller.buttonLoaders['close_review'] ?? false;
                                  final isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);

                                  return ElevatedButton(
                                    onPressed: (isLoadingClose || isAnyLoading)
                                        ? null
                                        : () async {
                                            controller.setButtonLoading('close_review', true);
                                            try {
                                              controller.chancelButton(context);
                                            } finally {
                                              controller.setButtonLoading('close_review', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                    child: isLoadingClose
                                        ? const CircularProgressIndicator(
                                            strokeWidth: 2,
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!.close,
                                          ),
                                  );
                                }),
                              ),
                            ],
                          ),

                        if (controller.isApprovalEnable.value && widget.items!.stepType == "Approval")
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final isLoading = controller.buttonLoaders['approve'] ?? false;
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
                                  final isLoading = controller.buttonLoaders['reject_approval'] ?? false;
                                  return ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            controller.setButtonLoading('reject_approval', true);
                                            try {
                                              showActionPopup(context, "Reject");
                                            } finally {
                                              controller.setButtonLoading('reject_approval', false);
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
                        if (controller.isApprovalEnable.value && widget.items!.stepType == "Approval")
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final isLoading = controller.buttonLoaders['escalate'] ?? false;
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
                                  final isLoading = controller.buttonLoaders['close_approval'] ?? false;
                                  return ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            controller.setButtonLoading('close_approval', true);
                                            try {
                                              controller.chancelButton(context);
                                            } finally {
                                              controller.setButtonLoading('close_approval', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            strokeWidth: 2,
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!.close,
                                          ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        if (!controller.isEnable.value & !controller.isApprovalEnable.value)
                          ElevatedButton(
                            onPressed: () async {
                              controller.setButtonLoading('close_review', true);
                              try {
                                controller.chancelButton(context);
                              } finally {
                                controller.setButtonLoading('close_review', false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.close,
                            ),
                          ),
                         
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ));
        }),
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
                          searchValue: (user) => '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            controller.userIdController.text = user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                        hintText: AppLocalizations.of(context)!.enterCommentHere,
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
                        errorText: isCommentError ? AppLocalizations.of(context)!.commentRequired : null,
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
                          onPressed: () {
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

                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(context, AppRoutes.approvalDashboardForDashboard);
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to submit action')),
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
      IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: false,
      ),
    ],
  );

  if (croppedFile != null) {
    final croppedImage = File(croppedFile.path); return croppedImage;
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
      readOnly: true,
      enabled: !isReadOnly,
      validator: (value) => _validateRequiredField(value!, "Request Date", true),
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
                      initialDate = DateFormat('dd-MM-yyyy').parseStrict(controllers.text.trim());
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
                  Text(item.eventType, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        )
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
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            children: children,
          ),
        ),
      ),
    );
  }
}