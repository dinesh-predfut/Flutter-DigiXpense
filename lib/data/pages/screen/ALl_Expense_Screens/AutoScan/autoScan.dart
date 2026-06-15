import 'dart:convert' show base64Decode;
import 'dart:async';
import 'dart:io';

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart' show OpenFilex;
import 'package:photo_view/photo_view.dart';

import '../../../../../l10n/app_localizations.dart';

class AutoScanExpensePage extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic>? apiResponse;

  const AutoScanExpensePage({
    Key? key,
    required this.imageFile,
    this.apiResponse,
  }) : super(key: key);

  @override
  State<AutoScanExpensePage> createState() => _AutoScanExpensePageState();
}

class _AutoScanExpensePageState extends State<AutoScanExpensePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> expenseTrans;
  late final Controller controller;
  final Map<String, TextEditingController> fieldControllers = {};

  bool _isItemized = false;
  bool _isSubmitAttempted = false;
  bool _isReimbursable = true;
  bool _isBillable = false;
  late Future<Map<String, bool>> _featureFuture;

  String? selectedIcon;

  late PageController _pageController;
  bool allowMultSelect = false;
  bool allowCashAd = false;
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
  late GESpeficExpense expense;

  // Itemize controllers list
  List<Controller> itemizeControllers = [];
  int _itemizeCount = 1;

  late FocusNode _focusNode;
  bool _isTyping = false;

  final PhotoViewController _photoViewController = PhotoViewController();

  // Config flags
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
    controller = Get.find<Controller>();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    _featureFuture = controller.getAllFeatureStates();
     final newController = Controller();
if (controller.customFields.isNotEmpty) {
      newController.cloneCustomFieldsFromRx(controller.customFields);
    }
    // Initialize config
    projectConfig = controller.getFieldConfig("Project Id");
    taxGroupConfig = controller.getFieldConfig("Tax Group");
    taxAmountConfig = controller.getFieldConfig("Tax Amount");
    isReimbursibleConfig = controller.getFieldConfig("Is Reimbursible");
    isRefrenceIDConfig = controller.getFieldConfig("Refrence Id");
    isBillableConfig = controller.getFieldConfig("Is Billable");
    isLocationConfig = controller.getFieldConfig("Location");

    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.isLoadingOCR.value = true;
      controller.isEnable.value = true;
      await controller.loadSequenceModules();
      await controller.configuration();
      controller.loadAllCustomFieldValues();
      await controller.fetchAndStoreFeatures(Params.userToken, context);
      controller.selectedDate ??= DateTime.now();
      await controller.fetchPaidto();
      await controller.fetchPaidwith();
      await controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.fetchExpenseCategory();
      _loadSettings();
      if (widget.apiResponse == null) {
        controller.getUserPref(context);
      }

      controller.fetchPaidwith();
      _initializeUnits();
      controller.isLoadingOCR.value = false;
    });

    if (widget.apiResponse != null) {
      expense = GESpeficExpense.fromJson(widget.apiResponse!);
      controller.addToFinalItems(expense);
      expenseTrans = List<Map<String, dynamic>>.from(
        widget.apiResponse!['ExpenseTrans'] ?? [],
      );
      _isItemized =
          expenseTrans.length > 1 ||
          (expenseTrans.isNotEmpty && expenseTrans[0]['Description'] != null);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _initializeFormFromApiResponse();
      });
    } else {
      receiptDateController.text = DateFormat(
        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
      ).format(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchExchangeRate();
      controller.currencyDropDown();
    });
  }

  void _loadCategoryCustomFields(
    ExpenseCategory category,
    Controller targetController,
  ) {
    if (category.customFields != null && category.customFields!.isNotEmpty) {
      targetController.customFieldsItems.removeWhere(
        (field) => field['ObjectName'] == 'ExpenseCategories',
      );

      for (var categoryField in category.customFields!) {
        final Map<String, dynamic> field = Map<String, dynamic>.from(
          categoryField,
        );
        field['ObjectName'] = 'ExpenseCategories';
        field['ExpenseType'] = 'General Expenses';

        final defaultVal = field['DefaultValue']?.toString() ?? '';
        field['EnteredValue'] = defaultVal;

        final fieldType = field['FieldType'];

        if (fieldType == 'List' ||
            fieldType == 'CustomList' ||
            fieldType == 'SystemList') {
          final options = field['Options'] as List<CustomDropdownValue>?;
          CustomDropdownValue? matchedOption;
          if (options != null && defaultVal.isNotEmpty) {
            matchedOption = options.firstWhereOrNull(
              (opt) => opt.valueName == defaultVal || opt.valueId == defaultVal,
            );
          }
          field['SelectedValue'] = matchedOption;
          field['_rxSelectedValue'] = Rx<CustomDropdownValue?>(matchedOption);
        } else if (fieldType == 'Checkbox') {
          final boolValue = defaultVal.toLowerCase() == 'true';
          field['_rxCheckboxValue'] = Rx<bool>(boolValue);
        } else if (fieldType == 'Date' || fieldType == 'Date&Time') {
          DateTime? dateValue;
          if (defaultVal.isNotEmpty) {
            try {
              dateValue = DateTime.parse(defaultVal);
            } catch (e) {
              print("Error parsing date: $e");
            }
          }
          field['_rxDateValue'] = Rx<DateTime?>(dateValue);
        } else if (fieldType == 'LongInteger') {
          field['_rxIntValue'] = Rx<int?>(int.tryParse(defaultVal));
        } else if (fieldType == 'Decimal') {
          field['_rxDoubleValue'] = Rx<double?>(double.tryParse(defaultVal));
        } else if (fieldType == 'Email') {
          field['_rxStringValue'] = Rx<String?>(defaultVal);
          field['_controller'] = TextEditingController(text: defaultVal);
          field['_focusNode'] = FocusNode();
        } else if (fieldType == 'MobileNumber') {
          field['_rxStringValue'] = Rx<String?>(defaultVal);
          field['_controller'] = TextEditingController(text: defaultVal);
          field['_focusNode'] = FocusNode();
        } else {
          field['_rxStringValue'] = Rx<String?>(defaultVal);
          field['_controller'] = TextEditingController(text: defaultVal);
          field['_focusNode'] = FocusNode();
        }

        field['Error'] = null;
        targetController.customFieldsItems.add(field);
      }
    }
    targetController.customFieldsItems.refresh();
  }

  void _initializeItemizeControllers() {
    itemizeControllers.clear();
    final mainController = Get.find<Controller>();
    if (expenseTrans.isEmpty) {
      final newController = Controller();
      itemizeControllers.add(newController);
      _itemizeCount = 1;
      return;
    }

    for (int index = 0; index < expenseTrans.length; index++) {
      final item = expenseTrans[index];
      final newController = Controller();

      // Set basic fields
      newController.categoryController.text = item['ExpenseCategory'] ?? '';
      newController.descriptionController.text = item['Description'] ?? '';
      newController.quantity.text = (item['Quantity'] ?? 1).toStringAsFixed(2);
      newController.unitPriceTrans.text = (item['UnitPriceTrans'] ?? 0)
          .toStringAsFixed(2);
      newController.uomId.text = item['UomId'] ?? '';
      newController.taxAmount.text = (item['TaxAmount'] ?? 0).toStringAsFixed(
        2,
      );
      newController.isReimbursable = item['IsReimbursable'] ?? true;
      newController.isBillableCreate = item['IsBillable'] ?? false;

      newController.calculateLineAmounts(newController);

      // Load category custom fields
      final matchingCategory = controller.expenseCategory.firstWhereOrNull(
        (c) => c.categoryId == item['ExpenseCategory'],
      );
      if (matchingCategory != null) {
        _loadCategoryCustomFields(matchingCategory, newController);
      }

      itemizeControllers.add(newController);
    }

    _itemizeCount = expenseTrans.length;
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        final newController = Controller();
        itemizeControllers.add(newController);
        _itemizeCount++;
      });
    }
  }

  void _removeItemize(int index) {
    if (_itemizeCount > 1) {
      setState(() {
        itemizeControllers.removeAt(index);
        _itemizeCount--;
      });
    }
  }

  void _updateAllLineItems() {
    final rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    double total = 0.0;

    for (int i = 0; i < itemizeControllers.length; i++) {
      final itemController = itemizeControllers[i];
      itemController.calculateLineAmounts(itemController);

      final lineAmount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
      final lineAmountInINR = lineAmount * rate;
      itemController.lineAmountINR.text = lineAmountInINR.toStringAsFixed(2);
      total += lineAmount;
    }

    controller.paidAmount.text = total.toStringAsFixed(2);
    controller.amountINR.text = (total * rate).toStringAsFixed(2);
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
          referenceController.text,
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

      check(
        _validateNumericField(
          item.unitPriceTrans.text,
          "Item ${i + 1} Unit Amount",
          true,
        ),
      );

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

    if (firstError != null) {
      print("Validation Error: $firstError");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firstError!), backgroundColor: Colors.red),
      );
      return false;
    }

    return true;
  }

  Future<void> _submitForm(bool value) async {
    if (!_validateForm()) {
      return;
    }

    controller.taxAmount.text = taxAmountController.text;
    controller.descriptionController.text = descriptionController.text;
    controller.rememberMe = _isReimbursable;
    controller.isBillable.value = _isBillable;
    controller.referenceID.text = referenceController.text;
    controller.receiptDateController.text = receiptDateController.text;

    controller.finalItems.clear();

    for (int i = 0; i < itemizeControllers.length; i++) {
      final item = itemizeControllers[i];

      // Collect custom fields for this item
      List<Map<String, dynamic>> itemCustomFieldValues = [];
      for (var field in item.customFieldsItems) {
        final fieldId = field['FieldId'];
        final enteredValue = field['EnteredValue'];
        if (fieldId != null &&
            enteredValue != null &&
            enteredValue.toString().isNotEmpty) {
          itemCustomFieldValues.add({
            'FieldId': fieldId.toString(),
            'FieldValue': enteredValue,
          });
        }
      }

      controller.finalItems.add(
        ExpenseItem(
          expenseCategoryId: item.categoryController.text.trim(),
          quantity: double.tryParse(item.quantity.text) ?? 0,
          uomId: item.uomId.text.trim(),
          unitPriceTrans: double.tryParse(item.unitPriceTrans.text) ?? 0,
          taxAmount: double.tryParse(item.taxAmount.text) ?? 0,
          taxGroup: (controller.selectedTax?.taxGroupId?.isNotEmpty ?? false)
              ? controller.selectedTax!.taxGroupId
              : null,
          lineAmountTrans: double.tryParse(item.lineAmount.text) ?? 0,
          lineAmountReporting: double.tryParse(item.lineAmountINR.text) ?? 0,
          projectId: item.projectDropDowncontroller.text.trim().isEmpty
              ? null
              : item.projectDropDowncontroller.text.trim(),
          description: item.descriptionController.text.trim(),
          isReimbursable: item.isReimbursable,
          isBillable: item.isBillableCreate,
          accountingDistributions: item.accountingDistributions
              .whereType<AccountingDistribution>()
              .toList(),
          expenseTransCustomFieldValues: itemCustomFieldValues,
        ),
      );
    }

    // Collect header custom fields
    List<Map<String, dynamic>> headerCustomFieldValues = [];
    for (var field in controller.customFieldsItems) {
      if (field['ObjectName'] == 'ExpenseHeader') {
        final fieldId = field['FieldId'];
        final enteredValue = field['EnteredValue'];
        if (fieldId != null &&
            enteredValue != null &&
            enteredValue.toString().isNotEmpty) {
          headerCustomFieldValues.add({
            'FieldId': fieldId.toString(),
            'FieldValue': enteredValue,
          });
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imageFile.existsSync()) {
        controller.imageFiles.add(widget.imageFile);
      }
    });

    await controller.saveGeneralExpense(context, value, false);
  }

  Future<void> _pickFile() async {
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

        if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
          final croppedFile = await _cropImage(file);
          if (croppedFile != null) {
            final croppedImage = File(croppedFile.path);
            final compressedImage = await _compressImage(croppedImage);
            await _processSelectedFile(compressedImage ?? croppedImage);
          }
        } else {
          await _processSelectedFile(file);
        }
      }
    } catch (e) {
      debugPrint("❌ File pick error: $e");
    } finally {
      controller.isImageLoading.value = false;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) return null;
      return File(compressedFile.path);
    } catch (e) {
      debugPrint('❌ Compression error: $e');
      return null;
    }
  }

  Future<void> _processSelectedFile(File file) async {
    final featureStates = await controller.getAllFeatureStates();

    if (controller.digiScanEnable!) {
      await controller.sendUploadedFileToServer(context, file);
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.autoScan,
        arguments: {'imageFile': file, 'apiResponse': {}},
      );
    }
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
            allowCashAd = settings.allowCashAdvAgainstExpenseReg;
          });
        }
      });
    }
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

  void _showDuplicateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.duplicateReceiptDetected),
        content: Text(AppLocalizations.of(context)!.duplicateReceiptWarning),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.dashboard_Main);
              controller.isDuplicated = false;
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.continueText),
          ),
        ],
      ),
    );
  }

  void _initializeFormFromApiResponse() {
    final receiptTimestamp = widget.apiResponse?['ReceiptDate'];
    final date = (receiptTimestamp != null && receiptTimestamp != 0)
        ? DateTime.fromMillisecondsSinceEpoch(receiptTimestamp, isUtc: true)
        : DateTime.now();

    receiptDateController.text = DateFormat(
      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
    ).format(date);

    controller.selectedDate = date;
    controller.isManualEntryMerchant = true;
    controller.manualPaidToController.text =
        widget.apiResponse!['Merchant'] ?? '';
    referenceController.text = widget.apiResponse!['ReferenceNumber'] ?? '';
    controller.paidAmount.text = (widget.apiResponse!['TotalAmountTrans'] ?? 0)
        .toStringAsFixed(2);
    taxAmountController.text = (widget.apiResponse!['TaxAmount'] ?? 0)
        .toStringAsFixed(2);
    descriptionController.text = widget.apiResponse!['Description'] ?? '';
    controller.paidWithController.text =
        widget.apiResponse!['PaymentMethodId'] ?? '';
    controller.currencyDropDowncontroller.text =
        widget.apiResponse!['Currency'] ?? '';

    commentsController.text = widget.apiResponse!['Comments'] ?? '';
    controller.isAlcohol = widget.apiResponse!['IsAlcohol'] ?? false;
    controller.isTobacco = widget.apiResponse!['IsTobacco'] ?? false;
    controller.isDuplicated = widget.apiResponse!['IsDuplicated'] ?? false;
    controller.categoryController.text =
        widget.apiResponse!['ExpenseCategoryId'] ?? '';

    if (controller.isDuplicated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDuplicateDialog(context);
      });
    }

    // Load header custom fields
    final savedCustomFields =
        widget.apiResponse?['ExpenseHeaderCustomFieldValues'] as List?;
    if (savedCustomFields != null && savedCustomFields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadAllCustomFieldValues(
          savedValues: savedCustomFields.cast<Map<String, dynamic>>(),
        );
      });
    }

    _initializeItemizeControllers();
    waitForDropdownDataAndSetValues();
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
        (e) => e.paymentMethodId == controller.paidWithController.text,
        orElse: () => controller.paymentMethods.first,
      );
      controller.isReimbursableEnabled.value =
          controller.selectedPaidWith!.reimbursible;
    }
    if (controller.expenseCategory.isNotEmpty) {
      controller.selectedCategory = controller.expenseCategory.firstWhere(
        (c) => c.categoryId == controller.categoryController.text,
        orElse: () => controller.expenseCategory.first,
      );

      if (controller.selectedCategory != null) {
        controller.itemisationMandatory.value =
            controller.selectedCategory!.itemisationMandatory;
        controller.minExpenseAmount.value =
            (controller.selectedCategory!.minExpensesAmount ?? 0).toDouble();
        controller.maxExpenseAmount.value =
            (controller.selectedCategory!.maxExpenseAmount ?? 0).toDouble();
        controller.receiptRequiredLimit.value =
            (controller.selectedCategory!.receiptRequiredLimit ?? 0).toDouble();
      }
    }

    setState(() {});
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
          title: AppLocalizations.of(context)!.cropImage,
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      final croppedImage = File(croppedFile.path);
      return croppedImage;
    }

    return null;
  }

  bool _isImage(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }

  bool _isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  bool _isExcel(String path) {
    return path.toLowerCase().endsWith('.xls') ||
        path.toLowerCase().endsWith('.xlsx');
  }

  void _openFile(File file) {
    OpenFilex.open(file.path);
  }

  // UI Helpers
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
      ],
    );
  }

  Widget _buildDateField(
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
                        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                      ).parseStrict(controllers.text.trim());
                    } catch (e) {
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
                    controllers.text = DateFormat(
                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                    ).format(picked);
                    controller.selectedDate = picked;
                  }
                },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFileViewer() {
    return Obx(() {
      return Stack(
        children: [
          Obx(() {
            return GestureDetector(
              onTap: () {
                if (controller.imageFiles.isEmpty &&
                    controller.isEnable.value) {
                  _pickFile();
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: controller.imageFiles.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.tapToUploadDocs,
                        ),
                      )
                    : Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: controller.imageFiles.length,
                            onPageChanged: (index) {
                              controller.currentIndex.value = index;
                            },
                            itemBuilder: (_, index) {
                              final file = controller.imageFiles[index];
                              final path = file.path;

                              return GestureDetector(
                                onTap: () => _openFile(file),
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.deepPurple,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _isImage(path)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : _isPdf(path)
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.picture_as_pdf,
                                              size: 70,
                                              color: Colors.red,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                file.path.split('/').last,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        )
                                      : _isExcel(path)
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.table_chart,
                                              size: 70,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              file.path.split('/').last,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.insert_drive_file,
                                              size: 70,
                                            ),
                                            Text(
                                              file.path.split('/').last,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
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
                                onTap: _pickFile,
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
                      ),
              ),
            );
          }),
          if (controller.isImageLoading.value)
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
    });
  }

  Widget _buildStatusBadges() {
    return Row(
      children: [
        if (controller.isAlcohol)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Image.asset('assets/alcohol.png', height: 24, width: 24),
          ),
        if (controller.isAlcohol) const SizedBox(width: 10),
        Obx(() {
          final iconPath = controller.selectedIcon.value;
          final showIcon = iconPath.isNotEmpty;
          return Row(
            children: [
              if (showIcon)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: _buildCategoryIcon(iconPath),
                ),
            ],
          );
        }),
        if (controller.isTobacco) const SizedBox(width: 10),
        if (controller.isTobacco)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Image.asset('assets/Tobacco.jpg', height: 24, width: 24),
          ),
        const SizedBox(width: 10),
        if (controller.isDuplicated)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Image.asset(
              'assets/duplicateIcons.png',
              height: 24,
              width: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryIcon(String iconPath) {
    if (iconPath.startsWith('data:image')) {
      try {
        final base64Data = iconPath.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(bytes, height: 24, width: 24, fit: BoxFit.contain);
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.redAccent);
      }
    } else {
      return const Icon(Icons.broken_image, color: Colors.redAccent);
    }
  }
VoidCallback _getIntListener(
    Map<String, dynamic> field,
    Rx<int?> rxValue,
    TextEditingController controller,
  ) {
    return () {
      final value = controller.text;
      if (value.isEmpty) {
        if (rxValue.value != null) {
          rxValue.value = null;
          field['EnteredValue'] = null;
        }
      } else {
        final intValue = int.tryParse(value);
        if (intValue != rxValue.value) {
          rxValue.value = intValue;
          field['EnteredValue'] = intValue;
        }
      }
      field['Error'] = null;
    };
  }

  // Helper method for Double fields
  VoidCallback _getDoubleListener(
    Map<String, dynamic> field,
    Rx<double?> rxValue,
    TextEditingController controller,
  ) {
    return () {
      final value = controller.text;
      if (value.isEmpty) {
        if (rxValue.value != null) {
          rxValue.value = null;
          field['EnteredValue'] = null;
        }
      } else {
        final doubleValue = double.tryParse(value);
        if (doubleValue != rxValue.value) {
          rxValue.value = doubleValue;
          field['EnteredValue'] = doubleValue;
        }
      }
      field['Error'] = null;
    };
  }
  Widget _buildItemizeFields() {
     VoidCallback _getStringListener(
    Map<String, dynamic> field,
    Rx<String?> rxValue,
    TextEditingController controller,
  ) {
    return () {
      final value = controller.text;
      if (value != rxValue.value) {
        rxValue.value = value;
        field['EnteredValue'] = value;
        field['Error'] = null;
      }
    };
  }

  // Helper method for Integer fields
  VoidCallback _getIntListener(
    Map<String, dynamic> field,
    Rx<int?> rxValue,
    TextEditingController controller,
  ) {
    return () {
      final value = controller.text;
      if (value.isEmpty) {
        if (rxValue.value != null) {
          rxValue.value = null;
          field['EnteredValue'] = null;
        }
      } else {
        final intValue = int.tryParse(value);
        if (intValue != rxValue.value) {
          rxValue.value = intValue;
          field['EnteredValue'] = intValue;
        }
      }
      field['Error'] = null;
    };
  }
    return Column(
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
          itemCount: itemizeControllers.length,
          itemBuilder: (context, index) {
            final itemController = itemizeControllers[index];
             final currentCustomFields = controller.customFieldsItems;
               if (currentCustomFields.isEmpty && controller.customFields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.cloneCustomFieldsFromRx(controller.customFields);
      });
    }
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
                          "${AppLocalizations.of(context)!.item} ${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            if (controller.isEnable.value &&
                                itemizeControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItemize(index),
                                tooltip: 'Remove this item',
                              ),
                            if (controller.isEnable.value)
                              FutureBuilder<Map<String, bool>>(
                                future: _featureFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return const SizedBox.shrink();
                                  final isEnabled =
                                      snapshot.data!['EnableItemization'] ??
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Dropdown
                        SearchableMultiColumnDropdownField<ExpenseCategory>(
                          labelText:
                              '${AppLocalizations.of(context)!.paidFor} *',
                          enabled: controller.isEnable.value,
                          columnHeaders: [
                            AppLocalizations.of(context)!.categoryName,
                            AppLocalizations.of(context)!.categoryId,
                          ],
                          items: controller.expenseCategory,
                          selectedValue: itemController.selectedCategory,
                          searchValue: (p) =>
                              '${p.categoryName} ${p.categoryId}',
                          displayText: (p) => p.categoryId,
                          validator: (value) => _validateRequiredField(
                            itemController.categoryController.text,
                            AppLocalizations.of(context)!.paidFor,
                            true,
                          ),
                          onChanged: (p) {
                            if (p == null) return;
                            setState(() {
                              itemController.selectedCategory = p;
                              itemController.categoryController.text =
                                  p.categoryId;
                              _loadCategoryCustomFields(p, itemController);
                              itemController.itemisationMandatory.value =
                                  p.itemisationMandatory;
                              itemController.minExpenseAmount.value =
                                  (p.minExpensesAmount ?? 0).toDouble();
                              itemController.maxExpenseAmount.value =
                                  (p.maxExpenseAmount ?? 0).toDouble();
                              itemController.receiptRequiredLimit.value =
                                  (p.receiptRequiredLimit ?? 0).toDouble();
                            });
                          },
                          controller: itemController.categoryController,
                          rowBuilder: (p, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(p.categoryName)),
                                  Expanded(child: Text(p.categoryId)),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Project field (if enabled)
                        if (projectConfig.isEnabled)
                          SearchableMultiColumnDropdownField<Project>(
                            enabled: controller.isEnable.value,
                            labelText:
                                "${AppLocalizations.of(context)!.projectId} ${projectConfig.isMandatory ? "*" : ""}",
                            columnHeaders: const ['Project Name', 'Project ID'],
                            items: controller.project,
                            selectedValue: itemController.selectedProject,
                            searchValue: (p) => '${p.name} ${p.code}',
                            displayText: (p) => p.code,
                            onChanged: (p) {
                              setState(() {
                                itemController.selectedProject = p;
                                itemController.projectDropDowncontroller.text =
                                    p!.code;
                              });
                            },
                            controller:
                                itemController.projectDropDowncontroller,
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
                        const SizedBox(height: 8),

                        // Tax Group field (if enabled)
                        if (taxGroupConfig.isEnabled)
                          SearchableMultiColumnDropdownField<TaxGroupModel>(
                            enabled: controller.isEnable.value,
                            labelText:
                                "${AppLocalizations.of(context)!.taxGroup} ${taxGroupConfig.isMandatory ? "*" : ""}",
                            columnHeaders: [
                              AppLocalizations.of(context)!.taxGroup,
                              AppLocalizations.of(context)!.taxId,
                            ],
                            items: controller.taxGroup,
                            selectedValue: itemController.selectedTax,
                            searchValue: (tax) =>
                                '${tax.taxGroup} ${tax.taxGroupId}',
                            displayText: (tax) => tax.taxGroupId,
                            onChanged: (tax) {
                              setState(() {
                                itemController.selectedTax = tax;
                                itemController.taxGroupController.text =
                                    tax!.taxGroupId;
                              });
                            },
                            controller: itemController.taxGroupController,
                            rowBuilder: (tax, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(tax.taxGroup)),
                                    Expanded(child: Text(tax.taxGroupId)),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 8),

                        // Tax Amount field (if enabled)
                        if (taxAmountConfig.isEnabled)
                          _buildTextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            label:
                                "${AppLocalizations.of(context)!.taxAmount} ${taxAmountConfig.isMandatory ? "*" : ""}",
                            controller: itemController.taxAmount,
                            isReadOnly: controller.isEnable.value,
                            onChanged: (value) => _updateAllLineItems(),
                          ),
                        const SizedBox(height: 8),
                        Obx(() {
                return Column(
                  children: currentCustomFields.asMap().entries.map((entry) {
                    final index = entry.key;
                    final field = entry.value;

                    final objectName = field['ObjectName'] ?? field['FR'] ?? '';
                    final expenseType = field['ExpenseType'];

                    final shouldShow =
                        (objectName == 'ExpenseTrans' &&
                            (expenseType == 'General Expenses' ||
                                expenseType == null)) ||
                        (objectName == 'ExpenseCategories');

                    if (!shouldShow) {
                      return const SizedBox.shrink();
                    }

                    final String label =
                        field['FieldLabel'] ?? field['FieldName'];
                    final bool isMandatory = field['IsMandatory'] ?? false;
                    final String fieldType = field['FieldType'];

                    /// UNIQUE KEY FOR EVERY FIELD
                    final String fieldKey =
                        '${controller.hashCode}_${field['FieldName']}_${field['LineId'] ?? index}_${field['RecId'] ?? index}';

                    Widget inputField;

                    if (field['FieldType'] == 'List' ||
                        field['FieldType'] == 'CustomList' ||
                        field['FieldType'] == 'SystemList') {
                      List<CustomDropdownValue> options = [];
                      if (field['Options'] != null &&
                          field['Options'] is List) {
                        options = List<CustomDropdownValue>.from(
                          field['Options'],
                        );
                      }

                      field['_controller'] ??= TextEditingController();
                      final TextEditingController fieldController =
                          field['_controller'];

                      CustomDropdownValue? selectedValue =
                          field['SelectedValue'];

                      if (selectedValue == null &&
                          field['DefaultValue'] != null) {
                        final matches = options.where(
                          (opt) =>
                              opt.valueId == field['DefaultValue'] ||
                              opt.valueName == field['DefaultValue'],
                        );
                        selectedValue = matches.isNotEmpty
                            ? matches.first
                            : null;

                        if (selectedValue != null) {
                          field['SelectedValue'] = selectedValue;
                          field['EnteredValue'] = selectedValue.valueId;
                        }
                      }

                      // Update controller text without triggering rebuild
                      final newText =
                          selectedValue?.valueName ??
                          field['DefaultValue']?.toString() ??
                          '';
                      if (fieldController.text != newText) {
                        fieldController.text = newText;
                      }

                      // If no matched selectedValue but DefaultValue exists
                      if (selectedValue == null &&
                          field['DefaultValue'] != null) {
                        selectedValue = CustomDropdownValue(
                          valueId: field['DefaultValue'].toString(),
                          valueName: field['DefaultValue'].toString(),
                        );
                        final alreadyExists = options.any(
                          (opt) => opt.valueId == selectedValue!.valueId,
                        );
                        if (!alreadyExists) {
                          options = [selectedValue, ...options];
                        }
                        field['SelectedValue'] = selectedValue;
                        field['EnteredValue'] = selectedValue.valueId;
                      }

                      inputField =
                          SearchableMultiColumnDropdownField<
                            CustomDropdownValue
                          >(
                            key: ValueKey('dropdown_$fieldKey'),
                            labelText: '$label${isMandatory ? " *" : ""}',
                            items: options,
                            selectedValue: selectedValue,
                            searchValue: (val) => val.valueName,
                            displayText: (val) => val.valueName,
                            controller: fieldController,
                            columnHeaders: const ['Value ID', 'Value Name'],
                            rowBuilder: (val, searchQuery) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      val.valueId,
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      val.valueName,
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (val) {
                              field['SelectedValue'] = val;
                              field['EnteredValue'] = val?.valueId;
                              field['Error'] = null;
                              fieldController.text = val?.valueName ?? '';
                              controller.customFields.refresh();
                            },
                          );
                    }
                    // Date and DateTime types - Make Reactive
                    else if (fieldType == 'Date' || fieldType == 'Date&Time') {
                      final bool isDateTime = fieldType == 'Date&Time';

                      // Create Rx value if not exists
                      if (field['_rxDateValue'] == null) {
                        field['_rxDateValue'] = Rx<DateTime?>(
                          field['EnteredValue'] as DateTime?,
                        );
                      }

                      // Create stable controller
                      field['_dateController'] ??= TextEditingController();
                      final dateController =
                          field['_dateController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxDateValue =
                            field['_rxDateValue'] as Rx<DateTime?>;
                        final currentDate = rxDateValue.value;

                        // Update controller only if value changed
                        String newText = '';
                        if (currentDate != null) {
                          if (isDateTime) {
                            newText = DateFormat(
                              'dd/MM/yyyy hh:mm a',
                            ).format(currentDate);
                          } else {
                            newText = DateFormat(
                              'dd/MM/yyyy',
                            ).format(currentDate);
                          }
                        }
                        if (dateController.text != newText) {
                          dateController.text = newText;
                        }

                        return TextFormField(
                          key: ValueKey('date_$fieldKey'),
                          readOnly: true,
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: const OutlineInputBorder(),
                            errorText: field['Error'],
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? currentDate =
                                rxDateValue.value ?? DateTime.now();

                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: currentDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate == null) return;

                            if (isDateTime) {
                              TimeOfDay initialTime = TimeOfDay.now();
                              if (rxDateValue.value != null) {
                                initialTime = TimeOfDay.fromDateTime(
                                  rxDateValue.value!,
                                );
                              }

                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: initialTime,
                                  );

                              if (pickedTime == null) return;

                              final fullDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );

                              rxDateValue.value = fullDateTime;
                              field['EnteredValue'] = fullDateTime;
                            } else {
                              rxDateValue.value = pickedDate;
                              field['EnteredValue'] = pickedDate;
                            }

                            field['Error'] = null;
                          },
                          validator: (value) {
                            if (isMandatory && rxDateValue.value == null) {
                              return '$label is required';
                            }
                            return null;
                          },
                        );
                      });
                    }
                    // LongInteger (Integer) type - Make Reactive
                    else if (fieldType == 'LongInteger') {
                      if (field['_rxIntValue'] == null) {
                        field['_rxIntValue'] = Rx<int?>(
                          field['EnteredValue'] as int?,
                        );
                      }

                      // Create stable controller
                      field['_intController'] ??= TextEditingController();
                      final intController =
                          field['_intController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxIntValue'] as Rx<int?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value?.toString() ?? '';
                        if (intController.text != newText) {
                          intController.text = newText;
                        }

                        // Remove old listener and add new one
                        intController.removeListener(
                          _getIntListener(field, rxValue, intController),
                        );
                        intController.addListener(
                          _getIntListener(field, rxValue, intController),
                        );

                        return TextFormField(
                          key: ValueKey('int_$fieldKey'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: intController,
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: const OutlineInputBorder(),
                            errorText: field['Error'],
                          ),
                          validator: (value) {
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
                              return '$label is required';
                            }
                            return null;
                          },
                        );
                      });
                    }
                    // Decimal type - Make Reactive
                    else if (fieldType == 'Decimal') {
                      if (field['_rxDoubleValue'] == null) {
                        field['_rxDoubleValue'] = Rx<double?>(
                          field['EnteredValue'] as double?,
                        );
                      }

                      // Create stable controller
                      field['_doubleController'] ??= TextEditingController();
                      final doubleController =
                          field['_doubleController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxDoubleValue'] as Rx<double?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value?.toString() ?? '';
                        if (doubleController.text != newText) {
                          doubleController.text = newText;
                        }

                        // Remove old listener and add new one
                        doubleController.removeListener(
                          _getDoubleListener(field, rxValue, doubleController),
                        );
                        doubleController.addListener(
                          _getDoubleListener(field, rxValue, doubleController),
                        );

                        return TextFormField(
                          key: ValueKey('double_$fieldKey'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*'),
                            ),
                          ],
                          controller: doubleController,
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: const OutlineInputBorder(),
                            errorText: field['Error'],
                          ),
                          validator: (value) {
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
                              return '$label is required';
                            }
                            return null;
                          },
                        );
                      });
                    }
                    // Email type - Make Reactive
                    else if (fieldType == 'Email') {
                      if (field['_rxStringValue'] == null) {
                        field['_rxStringValue'] = Rx<String?>(
                          field['EnteredValue'] as String?,
                        );
                      }

                      // Create stable controller
                      field['_emailController'] ??= TextEditingController();
                      final emailController =
                          field['_emailController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxStringValue'] as Rx<String?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value ?? '';
                        if (emailController.text != newText) {
                          emailController.text = newText;
                        }

                        // Remove old listener and add new one
                        emailController.removeListener(
                          _getStringListener(field, rxValue, emailController),
                        );
                        emailController.addListener(
                          _getStringListener(field, rxValue, emailController),
                        );

                        return TextFormField(
                          key: ValueKey('email_$fieldKey'),
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: const OutlineInputBorder(),
                            errorText: field['Error'],
                            suffixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
                              return '$label is required';
                            }
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                            }
                            return null;
                          },
                        );
                      });
                    }
                    // MobileNumber type - Make Reactive
                    else if (fieldType == 'MobileNumber') {
                      // Initialize persistent controllers and values if not exists
                      if (field['_phoneController'] == null) {
                        final defaultValue =
                            field['DefaultValue']?.toString() ?? '';
                        final existingValue = field['EnteredValue'] as String?;
                        final initialValue = existingValue ?? defaultValue;

                        // Parse existing phone number to extract country code and number
                        String countryCode = '+91'; // Default India
                        String phoneNumber = '';

                        if (initialValue.isNotEmpty) {
                          if (initialValue.startsWith('+')) {
                            final RegExp regex = RegExp(r'^\+(\d+)\s*(.*)$');
                            final match = regex.firstMatch(initialValue);
                            if (match != null) {
                              countryCode = '+${match.group(1)}';
                              phoneNumber = match.group(2) ?? '';
                            } else {
                              phoneNumber = initialValue;
                            }
                          } else {
                            phoneNumber = initialValue;
                          }
                        }

                        // Create controllers
                        field['_countryCodeController'] = TextEditingController(
                          text: countryCode,
                        );
                        field['_phoneController'] = TextEditingController(
                          text: phoneNumber,
                        );
                        field['_rxStringValue'] = Rx<String?>(initialValue);
                        field['_focusNode'] = FocusNode();
                        field['EnteredValue'] = initialValue;

                        // Update EnteredValue when phone number changes
                        field['_phoneController'].addListener(() {
                          final phoneVal = field['_phoneController'].text;
                          final codeVal = field['_countryCodeController'].text;
                          final fullNumber = phoneVal.isNotEmpty
                              ? '$codeVal $phoneVal'
                              : '';

                          if (fullNumber != field['_rxStringValue'].value) {
                            field['_rxStringValue'].value = fullNumber;
                            field['EnteredValue'] = fullNumber;
                          }
                          field['Error'] = null;
                        });

                        // Update EnteredValue when country code changes
                        field['_countryCodeController'].addListener(() {
                          final phoneVal = field['_phoneController'].text;
                          final codeVal = field['_countryCodeController'].text;
                          final fullNumber = phoneVal.isNotEmpty
                              ? '$codeVal $phoneVal'
                              : '';

                          if (fullNumber != field['_rxStringValue'].value) {
                            field['_rxStringValue'].value = fullNumber;
                            field['EnteredValue'] = fullNumber;
                          }
                          field['Error'] = null;
                        });
                      }

                      final phoneController =
                          field['_phoneController'] as TextEditingController;
                      final countryCodeController =
                          field['_countryCodeController']
                              as TextEditingController;
                      final focusNode = field['_focusNode'] as FocusNode;

                      inputField = SizedBox(
                        child: IntlPhoneField(
                          key: ValueKey('phone_$fieldKey'),
                          controller: phoneController,
                          focusNode: focusNode,
                          initialCountryCode:
                              field['_selectedCountryCode'] ?? 'IN',
                          onChanged: (phone) {
                            countryCodeController.text =
                                '+${phone.countryCode}';
                            phoneController.text = phone.number;
                          },
                          onCountryChanged: (country) {
                            countryCodeController.text = '+${country.dialCode}';
                            field['_selectedCountryCode'] = country.code;
                          },
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: field['Error'],
                            counterText: "",
                          ),
                        ),
                      );
                    }
                    // Default Text type - Make Reactive
                    else {
                      if (field['_rxStringValue'] == null) {
                        field['_rxStringValue'] = Rx<String?>(
                          field['EnteredValue'] as String?,
                        );
                      }

                      // Create stable controller
                      field['_textController'] ??= TextEditingController();
                      final textController =
                          field['_textController'] as TextEditingController;

                      inputField = Obx(() {
                        final rxValue = field['_rxStringValue'] as Rx<String?>;

                        // Update controller without triggering rebuild
                        final newText = rxValue.value ?? '';
                        if (textController.text != newText) {
                          textController.text = newText;
                        }

                        // Remove old listener and add new one
                        textController.removeListener(
                          _getStringListener(field, rxValue, textController),
                        );
                        textController.addListener(
                          _getStringListener(field, rxValue, textController),
                        );

                        return TextFormField(
                          key: ValueKey('text_$fieldKey'),
                          enabled: controller.isEnable.value,
                          keyboardType: TextInputType.text,
                          controller: textController,
                          decoration: InputDecoration(
                            labelText: '$label${isMandatory ? " *" : ""}',
                            border: const OutlineInputBorder(),
                            errorText: field['Error'],
                          ),
                          validator: (value) {
                            if (isMandatory &&
                                (value == null || value.trim().isEmpty)) {
                              return '$label is required';
                            }
                            return null;
                          },
                        );
                      });
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: inputField,
                    );
                  }).toList(),
                );
              }),
                        // Unit Dropdown
                        SearchableMultiColumnDropdownField<Unit>(
                          labelText: '${AppLocalizations.of(context)!.unit} *',
                          enabled: controller.isEnable.value,
                          columnHeaders: [
                            AppLocalizations.of(context)!.uomId,
                            AppLocalizations.of(context)!.uomName,
                          ],
                          items: controller.unit,
                          selectedValue: itemController.selectedunit,
                          searchValue: (tax) => '${tax.code} ${tax.name}',
                          displayText: (tax) => tax.code,
                          validator: (value) => _validateRequiredField(
                            itemController.uomId.text,
                            AppLocalizations.of(context)!.unit,
                            true,
                          ),
                          onChanged: (tax) {
                            setState(() {
                              itemController.selectedunit = tax;
                              itemController.uomId.text = tax!.code;
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
                        const SizedBox(height: 8),

                        // Quantity
                        _buildTextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          label: "${AppLocalizations.of(context)!.quantity} *",
                          controller: itemController.quantity,
                          isReadOnly: controller.isEnable.value,
                          validator: (value) => _validateNumericField(
                            value!,
                            AppLocalizations.of(context)!.quantity,
                            true,
                          ),
                          onChanged: (value) {
                            _updateAllLineItems();
                          },
                        ),
                        const SizedBox(height: 8),

                        // Unit Amount
                        _buildTextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          label:
                              "${AppLocalizations.of(context)!.unitAmount} *",
                          controller: itemController.unitPriceTrans,
                          isReadOnly: controller.isEnable.value,
                          validator: (value) => _validateNumericField(
                            value!,
                            AppLocalizations.of(context)!.unitAmount,
                            true,
                          ),
                          onChanged: (value) {
                            _updateAllLineItems();
                          },
                        ),
                        const SizedBox(height: 8),

                        // Line Amount
                        _buildTextField(
                          label: AppLocalizations.of(context)!.lineAmount,
                          controller: itemController.lineAmount,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 8),

                        // Line Amount in INR
                        _buildTextField(
                          label:
                              '${AppLocalizations.of(context)!.lineAmountInInr} ${controller.organizationCurrency}',
                          controller: itemController.lineAmountINR,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 8),

                        // Description
                        TextFormField(
                          controller: itemController.descriptionController,
                          enabled: controller.isEnable.value,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.comments,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),

                        // Is Reimbursable Switch
                        if (isReimbursibleConfig.isEnabled)
                          SwitchListTile(
                            title: Text(
                              AppLocalizations.of(context)!.isReimbursable,
                            ),
                            value: itemController.isReimbursable,
                            onChanged:
                                controller.isEnable.value &&
                                    controller.isReimbursableEnabled.value
                                ? (val) {
                                    setState(() {
                                      itemController.isReimbursable = val;
                                    });
                                  }
                                : null,
                          ),

                        // Is Billable Switch
                        if (isBillableConfig.isEnabled)
                          SwitchListTile(
                            title: Text(
                              AppLocalizations.of(context)!.isBillable,
                            ),
                            value: itemController.isBillableCreate,
                            onChanged: controller.isEnable.value
                                ? (val) {
                                    setState(() {
                                      itemController.isBillableCreate = val;
                                    });
                                  }
                                : null,
                          ),
                        const SizedBox(height: 8),

                        // Account Distribution
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                final double lineAmount =
                                    double.tryParse(
                                      itemController.lineAmount.text,
                                    ) ??
                                    0.0;
                                if (itemController.split.isEmpty) {
                                  itemController.split.add(
                                    AccountingSplit(percentage: 100.0),
                                  );
                                }
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
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
                                        splits: itemController.split,
                                        isEnable: controller.isEnable.value,
                                        lineAmount: lineAmount,
                                        onChanged: (i, updatedSplit) {
                                          if (mounted) {
                                            itemController.split[i] =
                                                updatedSplit;
                                          }
                                        },
                                        onDistributionChanged: (newList) {
                                          if (mounted) {
                                            itemController
                                                .accountingDistributions
                                                .clear();
                                            itemController
                                                .accountingDistributions
                                                .addAll(newList);
                                          }
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
                                  decoration: TextDecoration.underline,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
                onPressed: () {
                  controller.closeField();
                  Navigator.pushNamed(context, AppRoutes.dashboard_Main);
                },
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          controller.clearFormFields();
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.expenseReport),
        ),
        body: Obx(() {
          return controller.isLoadingOCR.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFileViewer(),
                        const SizedBox(height: 20),
                        _buildStatusBadges(),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.receiptDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Expense ID
                        Obx(() {
                          if (controller.isSequenceLoading.value)
                            return const SizedBox();
                          final hideField = controller.hasModule("Expense");
                          if (hideField) return const SizedBox.shrink();
                          return _buildTextField(
                            label:
                                '${AppLocalizations.of(context)!.expenseId} *',
                            controller: controller.expenseIdController,
                            isReadOnly: true,
                          );
                        }),

                        // Receipt Date
                        _buildDateField(
                          '${AppLocalizations.of(context)!.receiptDate} *',
                          receiptDateController,
                          isReadOnly: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Paid To
                        Text(
                          '${AppLocalizations.of(context)!.paidTo} *',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            if (!controller.isManualEntryMerchant)
                              SearchableMultiColumnDropdownField<MerchantModel>(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.selectMerchant,
                                columnHeaders: [
                                  AppLocalizations.of(context)!.merchantName,
                                  AppLocalizations.of(context)!.merchantId,
                                ],
                                items: controller.paidTo,
                                selectedValue: controller.selectedPaidto,
                                searchValue: (p) =>
                                    '${p.merchantNames} ${p.merchantId}',
                                displayText: (p) => p.merchantNames,
                                validator: (value) {
                                  if (controller
                                      .paidToController
                                      .text
                                      .isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.fieldRequired;
                                  }
                                  return null;
                                },
                                onChanged: (p) {
                                  setState(() {
                                    controller.selectedPaidto = p;
                                    controller.paidToController.text =
                                        p!.merchantNames;
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
                                        Expanded(child: Text(p.merchantNames)),
                                        Expanded(child: Text(p.merchantId)),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              TextFormField(
                                controller: controller.manualPaidToController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.enterMerchantName,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterMerchantName;
                                  }
                                  return null;
                                },
                              ),
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

                        // Cash Advance
                        if (allowCashAd)
                          Column(
                            children: [
                              Obx(
                                () =>
                                    MultiSelectMultiColumnDropdownField<
                                      CashAdvanceDropDownModel
                                    >(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.cashAdvanceRequest,
                                      items: controller.cashAdvanceListDropDown,
                                      isMultiSelect: allowMultSelect,
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
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Paid With
                        Column(
                          children: [
                            SearchableMultiColumnDropdownField<
                              PaymentMethodModel
                            >(
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
                              onChanged: (p) {
                                setState(() {
                                  controller.selectedPaidWith = p;
                                  controller.paidWithController.text =
                                      p!.paymentMethodId;
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
                        const SizedBox(height: 8),

                        // Reference ID field
                        if (isRefrenceIDConfig.isEnabled)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.referenceId}${isRefrenceIDConfig.isMandatory ? " *" : ""}",
                            controller: referenceController,
                            isReadOnly: true,
                          ),

                        // Header Custom Fields
                        Obx(() {
                          return Column(
                            children: controller.customFields
                                .where(
                                  (field) =>
                                      field['ObjectName'] == 'ExpenseHeader' &&
                                      field['ExpenseType'] ==
                                          'General Expenses',
                                )
                                .map((field) {
                                  final String label =
                                      field['FieldLabel'] ?? field['FieldName'];
                                  final bool isMandatory =
                                      field['IsMandatory'] ?? false;
                                  final String fieldKey = field['FieldName'];
                                  final String fieldType =
                                      field['FieldType'] ?? 'Text';

                                  if (!fieldControllers.containsKey(fieldKey)) {
                                    fieldControllers[fieldKey] =
                                        TextEditingController();
                                  }

                                  Widget inputField = TextFormField(
                                    enabled: controller.isEnable.value,
                                    controller: fieldControllers[fieldKey],
                                    decoration: InputDecoration(
                                      labelText:
                                          '$label${isMandatory ? " *" : ""}',
                                      border: const OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      field['EnteredValue'] = value;
                                    },
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: inputField,
                                  );
                                })
                                .toList(),
                          );
                        }),

                        // Amount / Currency / Rate row
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                controller: controller.paidAmount,
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
                              ),
                            ),
                            Expanded(
                              child: Obx(
                                () =>
                                    SearchableMultiColumnDropdownField<
                                      Currency
                                    >(
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
                                      onChanged: (c) {
                                        controller.selectedCurrency.value = c;
                                        controller.fetchExchangeRate();
                                        controller
                                                .currencyDropDowncontroller
                                                .text =
                                            c!.code;
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
                                controller: controller.unitRate,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.rate,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidNumber;
                                  }
                                  if (double.tryParse(value) == null) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidNumber;
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  _updateAllLineItems();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Total in INR
                        TextFormField(
                          controller: controller.amountINR,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.totalAmountIN} ${controller.organizationCurrency}',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Itemize Fields
                        if (_isItemized || itemizeControllers.isNotEmpty)
                          _buildItemizeFields(),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Center(
                          child: Column(
                            children: [
                              Obx(() {
                                final isSubmitLoading =
                                    controller.buttonLoaders['submit'] ?? false;
                                final isAnyLoading = controller
                                    .buttonLoaders
                                    .values
                                    .any((l) => l);
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
                                            if (_formKey.currentState!
                                                .validate()) {
                                              controller.setButtonLoading(
                                                'submit',
                                                true,
                                              );
                                              _submitForm(true).whenComplete(
                                                () {
                                                  controller.setButtonLoading(
                                                    'submit',
                                                    false,
                                                  );
                                                },
                                              );
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
                                            AppLocalizations.of(
                                              context,
                                            )!.submit,
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
                                        controller.buttonLoaders['saveGE'] ??
                                        false;
                                    final isSubmitLoading =
                                        controller.buttonLoaders['submit'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((l) => l);
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
                                                  _submitForm(
                                                    false,
                                                  ).whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'submit',
                                                      false,
                                                    );
                                                  });
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1E7503,
                                          ),
                                        ),
                                        child: isSaveLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.save,
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
                                        .any((l) => l);
                                    return Expanded(
                                      child: ElevatedButton(
                                        onPressed: isAnyLoading
                                            ? null
                                            : () {
                                                controller.chancelButton(
                                                  context,
                                                );
                                                controller.closeField();
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
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );
  }
  
}
