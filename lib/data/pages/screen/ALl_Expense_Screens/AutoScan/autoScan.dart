import 'dart:convert' show base64Decode;

import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
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
import 'dart:io';
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
  final List<ItemizeSection> itemizeSections = [];
  late FocusNode _focusNode;
  bool _isTyping = false;

  final PhotoViewController _photoViewController = PhotoViewController();

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.isLoadingOCR.value = true;
      controller.isEnable.value = true;
      await controller.loadSequenceModules();
      await controller.configuration();
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
      // controller.getUserPref(context);

      controller.fetchPaidwith();
      _initializeUnits();
      controller.isLoadingOCR.value = false;
    });
    _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );

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
        'dd-MM-yyyy',
      ).format(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchExchangeRate();
      controller.currencyDropDown();
    });
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
              final compressedImage = await _compressImage(croppedImage); // ✅ Compress after crop
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

    /// Compresses the image and returns a new [File], or null on failure.
    Future<File?> _compressImage(File file) async {
      try {
        final dir = await getTemporaryDirectory();
        final targetPath =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: 70,        // 0–100 — lower = smaller file
          minWidth: 1024,     // max width in px
          minHeight: 1024,    // max height in px
          format: CompressFormat.jpeg,
        );

        if (compressedFile == null) return null;

        final originalSize = await file.length();
        final compressedSize = await compressedFile.length();
        debugPrint(
          '🗜️ Compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)}',
        );

        return File(compressedFile.path);
      } catch (e) {
        debugPrint('❌ Compression error: $e');
        return null;
      }
    }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
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
        ? DateTime.fromMillisecondsSinceEpoch(receiptTimestamp,isUtc: true)
        : DateTime.now();

    receiptDateController.text = DateFormat('dd-MM-yyyy').format(date);

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

    double total = double.tryParse(controller.paidAmount.text) ?? 0;
    double rate = double.tryParse(controller.unitRate.text) ?? 1;
    totalInINRController.text = (total * rate).toStringAsFixed(2);

    for (var i = 0; i < expenseTrans.length; i++) {
      final item = expenseTrans[i];
      itemizeSections.add(
        ItemizeSection(
          index: i + 1,
          category: item['ExpenseCategory'] ?? '',
          description: item['Description'] ?? '',
          quantity: (item['Quantity'] ?? 1).toStringAsFixed(2),
          unitPrice: (item['UnitPriceTrans'] ?? 0).toStringAsFixed(2),
          uomId: item['UomId'] ?? '',
          taxAmount: (item['TaxAmount'] ?? 0).toStringAsFixed(2),
          isReimbursable: item['IsReimbursable'] ?? true,
          isBillable: item['IsBillable'] ?? false,
          onDelete: i > 0 ? () => _removeItemizeSection(i) : null,
          updateTotalAmount: _updateTotalAmount,
        ),
      );
    }

    if (_isItemized) {
      _updateTotalAmount();
    }
    waitForDropdownDataAndSetValues();
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
    _isItemized = false;

    final isFirst = itemizeSections.isEmpty;
    final double paidAmount =
        double.tryParse(controller.paidAmount.text) ?? 0.0;

    setState(() {
      itemizeSections.add(
        ItemizeSection(
          index: itemizeSections.length + 1,
          quantity: isFirst ? "1.00" : "",
          unitPrice: isFirst ? paidAmount.toStringAsFixed(2) : "",
          onDelete: itemizeSections.isNotEmpty
              ? () => _removeItemizeSection(itemizeSections.length)
              : null,
          updateTotalAmount: _updateTotalAmount,
        ),
      );
    });

    _updateTotalAmount();
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

  Future<void> _submitForm(bool value) async {
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
          discount: 0,
          quantity: double.tryParse(item.quantityController.text) ?? 0,
          uomId: item.uomIdController.text.trim(),
          unitPriceTrans: double.tryParse(item.unitPriceController.text) ?? 0,
          taxAmount: double.tryParse(item.taxAmountController.text) ?? 0,
          taxGroup: (controller.selectedTax?.taxGroupId?.isNotEmpty ?? false)
              ? controller.selectedTax!.taxGroupId
              : null,
          lineAmountTrans: double.tryParse(item.lineAmountController.text) ?? 0,
          lineAmountReporting:
              double.tryParse(item.lineAmountINRController.text) ?? 0,
          projectId: controller.projectDropDowncontroller.text.trim().isEmpty
              ? null
              : controller.projectDropDowncontroller.text.trim(),
          description: item.descriptionController.text.trim(),
          isReimbursable: item._isReimbursable.value,
          isBillable: item.isBillable,
          accountingDistributions: item.accountingDistributions
              .whereType<AccountingDistribution>()
              .toList(),
        ),
      );
    }

    await controller.saveGeneralExpense(context, value, false);
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

      // ✅ Set category-related limits from 2nd code
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

  void _zoomIn() {
    _photoViewController.scale = _photoViewController.scale! * 1.2;
  }

  void _zoomOut() {
    final currentScale = _photoViewController.scale ?? 1.0;
    _photoViewController.scale = currentScale / 1.2;
  }

  void _deleteImage() {
    setState(() {
      controller.imageFile = null;
    });
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

  // ─── UI helpers (from 2nd code style) ───────────────────────────────────────

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
        // const SizedBox(height: 12),
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
                        'dd-MM-yyyy',
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
                    controllers.text = DateFormat('dd-MM-yyyy').format(picked);
                    controller.selectedDate = picked;
                  }
                },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ─── Image / file viewer (same as 2nd code) ─────────────────────────────────

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

                          // Page count
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

                          // Add button
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

          // Loading overlay
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

  // ─── Status / icon badges ────────────────────────────────────────────────────

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
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedOpacity(
                    opacity: _isTyping ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: _buildCategoryIcon(iconPath),
                  ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                        // ── File viewer ───────────────────────────────────
                        _buildFileViewer(),
                        const SizedBox(height: 20),

                        // ── Status badges ─────────────────────────────────
                        _buildStatusBadges(),
                        const SizedBox(height: 16),

                        // ── Receipt details header ─────────────────────────
                        Text(
                          AppLocalizations.of(context)!.receiptDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // ── Expense ID (sequence) ─────────────────────────
                        Obx(() {
                          if (controller.isSequenceLoading.value) {
                            return const SizedBox();
                          }
                          final hideField = controller.hasModule("Expense");
                          if (hideField) return const SizedBox.shrink();
                          return _buildTextField(
                            label:
                                '${AppLocalizations.of(context)!.expenseId} *',
                            controller: controller.expenseIdController,
                            isReadOnly: true,
                          );
                        }),

                        // ── Receipt date ──────────────────────────────────
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

                        // ── Paid To ───────────────────────────────────────
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
                                onChanged: (val) {
                                  setState(() {});
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

                        // ── Cash Advance ──────────────────────────────────
                     
                        if (allowCashAd)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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

                        // ── Paid With ─────────────────────────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              validator: (value) => null,
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
                        // const SizedBox(height: 8),

                        // ── Config fields (Reference ID, Project, etc.) ───
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] != 'Location' &&
                                  field['FieldName'] != 'Is Billable' &&
                                  field['FieldName'] != 'Tax Amount' &&
                                  field['FieldName'] != 'Tax Group' &&
                                  field['FieldName'] != 'Is Reimbursible' &&
                                  field['FieldName'] != 'Project Id',
                            )
                            .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              Widget inputField;

                              if (label == 'Project Id') {
                                inputField =
                                    SearchableMultiColumnDropdownField<Project>(
                                      enabled: !_isItemized,
                                      labelText:
                                          "${AppLocalizations.of(context)!.projectName}${isMandatory ? " *" : ""}",
                                      columnHeaders: [
                                        AppLocalizations.of(
                                          context,
                                        )!.projectName,
                                        AppLocalizations.of(
                                          context,
                                        )!.projectName,
                                      ],
                                      items: controller.project,
                                      selectedValue: controller.selectedProject,
                                      searchValue: (p) => '${p.name} ${p.code}',
                                      displayText: (p) => p.code,
                                      onChanged: (p) {
                                        setState(() {
                                          controller.selectedProject = p;
                                        });
                                      },
                                      controller:
                                          controller.projectDropDowncontroller,
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
                                    );
                              } else if (label == 'Refrence Id') {
                                inputField = _buildTextField(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.referenceId,
                                  controller: referenceController,
                                  isReadOnly: true,
                                );
                              } else {
                                inputField = TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                        "$label${isMandatory ? " *" : ""}",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  inputField,
                                ],
                              );
                            })
                            .toList(),
                        if (!_isItemized) ...[
                          ...controller.configList
                              .where(
                                (field) =>
                                    field['IsEnabled'] == true &&
                                    field['FieldName'] != 'Location' &&
                                    field['FieldName'] != 'Is Billable' &&
                                    field['FieldName'] != 'Tax Amount' &&
                                    field['FieldName'] != 'Tax Group' &&
                                    field['FieldName'] != 'Is Reimbursible' &&
                                    field['FieldName'] != 'Refrence Id',
                              )
                              .map((field) {
                                final String label = field['FieldName'];
                                final bool isMandatory =
                                    field['IsMandatory'] ?? false;

                                Widget inputField;

                                if (label == 'Project Id') {
                                  inputField =
                                      SearchableMultiColumnDropdownField<
                                        Project
                                      >(
                                        enabled: !_isItemized,
                                        labelText:
                                            "${AppLocalizations.of(context)!.projectName}${isMandatory ? " *" : ""}",
                                        columnHeaders: [
                                          AppLocalizations.of(
                                            context,
                                          )!.projectName,
                                          AppLocalizations.of(
                                            context,
                                          )!.projectName,
                                        ],
                                        items: controller.project,
                                        selectedValue:
                                            controller.selectedProject,
                                        searchValue: (p) =>
                                            '${p.name} ${p.code}',
                                        displayText: (p) => p.code,
                                        onChanged: (p) {
                                          setState(() {
                                            controller.selectedProject = p;
                                          });
                                        },
                                        controller: controller
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
                                      );
                                } else if (label == 'Refrence Id') {
                                  inputField = _buildTextField(
                                    label: AppLocalizations.of(
                                      context,
                                    )!.referenceId,
                                    controller: referenceController,
                                    isReadOnly: true,
                                  );
                                } else {
                                  inputField = TextFormField(
                                    decoration: InputDecoration(
                                      labelText:
                                          "$label${isMandatory ? " *" : ""}",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    inputField,
                                  ],
                                );
                              })
                              .toList(),
                        ],
                        // ── Paid For (category) – only when not itemized ──
                        if (!_isItemized) ...[
                          const SizedBox(height: 16),
                          SearchableMultiColumnDropdownField<ExpenseCategory>(
                            labelText:
                                '${AppLocalizations.of(context)!.paidFor} *',
                            columnHeaders: [
                              AppLocalizations.of(context)!.categoryName,
                              AppLocalizations.of(context)!.categoryId,
                            ],
                            items: controller.expenseCategory,
                            selectedValue: controller.selectedCategory,
                            searchValue: (p) =>
                                '${p.categoryName} ${p.categoryId}',
                            displayText: (p) => p.categoryId,
                            validator: (value) {
                              if (controller.categoryController.text.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.fieldRequired;
                              }
                              return null;
                            },
                            onChanged: (p) {
                              controller.selectedIcon.value = '';
                              controller.selectedCategory = p;
                              if (p != null && p.expenseCategoryIcon != null) {
                                controller.selectedIcon.value =
                                    p.expenseCategoryIcon!;
                              }
                              controller.categoryController.text =
                                  p?.categoryId ?? '';

                              // ✅ From 2nd code
                              if (p != null) {
                                controller.itemisationMandatory.value =
                                    p.itemisationMandatory;
                                controller.minExpenseAmount.value =
                                    (p.minExpensesAmount ?? 0).toDouble();
                                controller.maxExpenseAmount.value =
                                    (p.maxExpenseAmount ?? 0).toDouble();
                                controller.receiptRequiredLimit.value =
                                    (p.receiptRequiredLimit ?? 0).toDouble();
                              }
                            },
                            controller: controller.categoryController,
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
                        ],

                        // ── Amount / Currency / Rate row ──────────────────
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: !_isItemized,
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
                                  controller.amountINR.text = (paid * rate)
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
                                  final value = double.tryParse(
                                    controller.paidAmount.text,
                                  );
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
                                      validator: (value) {
                                        if (controller
                                            .currencyDropDowncontroller
                                            .text
                                            .isEmpty) {
                                          return AppLocalizations.of(
                                            context,
                                          )!.fieldRequired;
                                        }
                                        return null;
                                      },
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
                                  final paid =
                                      double.tryParse(
                                        controller.paidAmount.text,
                                      ) ??
                                      0.0;
                                  final rate = double.tryParse(val) ?? 1.0;
                                  controller.amountINR.text = (paid * rate)
                                      .toStringAsFixed(2);
                                  controller.isVisible.value = true;
                                },
                              ),
                            ),
                          ],
                        ),

                        // ── Total in INR ──────────────────────────────────
                        const SizedBox(height: 20),
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

                        // ── Comments (non-itemized) ───────────────────────
                        if (!_isItemized) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: AppLocalizations.of(context)!.comments,
                            controller: descriptionController,
                            isReadOnly: true,
                          ),
                        ],

                        // ── Is Reimbursable (non-itemized) ────────────────
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] == 'Is Reimbursible' &&
                                  !_isItemized,
                            )
                            .map((field) {
                              if (!controller.isReimbursableEnabled.value &&
                                  controller.isReimbursiteCreate.value) {
                                controller.isReimbursable = false;
                                controller.isReimbursiteCreate.value = false;
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      switchTheme: SwitchThemeData(
                                        thumbColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((states) {
                                              final selected = states.contains(
                                                WidgetState.selected,
                                              );
                                              if (states.contains(
                                                WidgetState.disabled,
                                              )) {
                                                return selected
                                                    ? Colors.green
                                                    : null;
                                              }
                                              return selected
                                                  ? Colors.green
                                                  : null;
                                            }),
                                        trackColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((states) {
                                              final selected = states.contains(
                                                WidgetState.selected,
                                              );
                                              if (states.contains(
                                                WidgetState.disabled,
                                              )) {
                                                return selected
                                                    ? Colors.green.withOpacity(
                                                        0.5,
                                                      )
                                                    : null;
                                              }
                                              return selected
                                                  ? Colors.green.withOpacity(
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
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      value: controller.isReimbursable,
                                      onChanged:
                                          controller.isReimbursableEnabled.value
                                          ? (val) {
                                              setState(() {
                                                controller.isReimbursable = val;
                                                controller.isReimbursite = val;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(),

                        // ── Is Billable (non-itemized) ────────────────────
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] == 'Is Billable' &&
                                  !_isItemized,
                            )
                            .map((field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
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
                                                return controller
                                                        .isBillableCreate
                                                    ? Colors.blue
                                                    : Colors.grey.shade400;
                                              }
                                              if (states.contains(
                                                MaterialState.selected,
                                              )) {
                                                return Colors.blue;
                                              }
                                              return Colors.grey.shade400;
                                            }),
                                        trackColor:
                                            MaterialStateProperty.resolveWith<
                                              Color?
                                            >((states) {
                                              if (states.contains(
                                                MaterialState.disabled,
                                              )) {
                                                return controller
                                                        .isBillableCreate
                                                    ? Colors.blue.withOpacity(
                                                        0.5,
                                                      )
                                                    : Colors.grey.shade300;
                                              }
                                              if (states.contains(
                                                MaterialState.selected,
                                              )) {
                                                return Colors.blue.withOpacity(
                                                  0.5,
                                                );
                                              }
                                              return Colors.grey.shade300;
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
                                        ),
                                      ),
                                      value: controller.isBillableCreate,
                                      onChanged: (val) {
                                        setState(() {
                                          controller.isBillableCreate = val;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(),

                        // ── Itemize section ───────────────────────────────
                        const SizedBox(height: 16),
                        _buildItemizedFields(),

                        // ── Action buttons ────────────────────────────────
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              // Submit button
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

                              // Save + Cancel row
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

  Widget _buildItemizedFields() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              children: [
                ...itemizeSections.map((section) {
                  return section.build(
                    context,
                    _addItemizeSection,
                    () =>
                        _removeItemizeSection(itemizeSections.indexOf(section)),
                    _updateTotalAmount,
                  );
                }).toList(),
                FutureBuilder<Map<String, bool>>(
                  future: _featureFuture,
                  builder: (context, snapshot) {
                    final theme = Theme.of(context);
                    final loc = AppLocalizations.of(context)!;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    final featureStates = snapshot.data!;
                    final isEnabled =
                        featureStates['EnableItemization'] ?? false;

                    if (!isEnabled) return const SizedBox.shrink();

                    return OutlinedButton.icon(
                      onPressed: () {
                        _addItemizeSection();
                        _isItemized = true;
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onPrimary,
                        side: BorderSide(color: theme.colorScheme.onPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(loc.itemize),
                    );
                  },
                ),
              ],
            ),
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
}

// ════════════════════════════════════════════════════════════════════════════════
// ItemizeSection
// ════════════════════════════════════════════════════════════════════════════════

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
  final RxBool _isReimbursable = false.obs;
  bool _isReimbursables;
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
  }) : _isReimbursables = isReimbursable,
       _isBillable = isBillable {
    if (category != null) {
      final matchingCategory = controller.expenseCategory.firstWhere(
        (e) => e.categoryId == category || e.categoryName == category,
        orElse: () => controller.expenseCategory.first,
      );
      controller.selectedCategory = matchingCategory;
      categoryController.text = matchingCategory.categoryId;

      // ✅ From 2nd code
      controller.itemisationMandatory.value =
          matchingCategory.itemisationMandatory;
      controller.minExpenseAmount.value =
          (matchingCategory.minExpensesAmount ?? 0).toDouble();
      controller.maxExpenseAmount.value =
          (matchingCategory.maxExpenseAmount ?? 0).toDouble();
      controller.receiptRequiredLimit.value =
          (matchingCategory.receiptRequiredLimit ?? 0).toDouble();
    }

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

    double rate = double.tryParse(controller.unitRate.text) ?? 1.0;
    lineAmountINRController.text = (qty * unitPrice * rate).toStringAsFixed(2);

    updateTotalAmount();
  }

  Widget build(
    BuildContext context,
    void Function() addItemizeSection,
    void Function() removeItemizeSection,
    void Function() updateTotalAmount,
  ) {
    final controllerItems = Get.put(Controller());
    return Card(
      color: Colors.grey[10],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text('${AppLocalizations.of(context)!.item} $index'),
          children: [
            // ── Header row with delete / add ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: removeItemizeSection,
                    tooltip: 'Remove this item',
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Category ────────────────────────────────────────
                  SearchableMultiColumnDropdownField<ExpenseCategory>(
                    labelText: '${AppLocalizations.of(context)!.paidFor} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.categoryName,
                      AppLocalizations.of(context)!.categoryId,
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
                      controller.selectedIcon.value = "";
                      controller.selectedCategory = p;
                      categoryController.text = p!.categoryId;

                      // ✅ From 2nd code
                      controller.itemisationMandatory.value =
                          p.itemisationMandatory;
                      controller.minExpenseAmount.value =
                          (p.minExpensesAmount ?? 0).toDouble();
                      controller.maxExpenseAmount.value =
                          (p.maxExpenseAmount ?? 0).toDouble();
                      controller.receiptRequiredLimit.value =
                          (p.receiptRequiredLimit ?? 0).toDouble();
                    },
                    controller: categoryController,
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
                  const SizedBox(height: 16),

                  // ── Unit ────────────────────────────────────────────
                  SearchableMultiColumnDropdownField<Unit>(
                    labelText: '${AppLocalizations.of(context)!.unit} *',
                    columnHeaders: [
                      AppLocalizations.of(context)!.uomId,
                      AppLocalizations.of(context)!.uomName,
                    ],
                    items: controller.unit,
                    selectedValue: controller.selectedunit,
                    searchValue: (tax) => '${tax.code} ${tax.name}',
                    displayText: (tax) => tax.code,
                    validator: (tax) => uomIdController.text.isEmpty
                        ? AppLocalizations.of(context)!.pleaseSelectUnit
                        : null,
                    onChanged: (tax) {
                      controller.selectedunit = tax;
                      uomIdController.text = tax!.code;
                    },
                    controller: uomIdController,
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
                  const SizedBox(height: 16),

                  // ── Description / Comments ───────────────────────────
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.comments,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // ── Config fields inside itemize ─────────────────────
                  ...controller.configList
                      .where(
                        (field) =>
                            field['IsEnabled'] == true &&
                            field['FieldName'] != 'Location' &&
                            field['FieldName'] != 'Is Billable' &&
                            field['FieldName'] != 'Is Reimbursible' &&
                            field['FieldName'] != 'Refrence Id',
                      )
                      .map((field) {
                        final String label = field['FieldName'];
                        final bool isMandatory = field['IsMandatory'] ?? false;

                        Widget inputField;

                        if (label == 'Project Id') {
                          inputField = SearchableMultiColumnDropdownField<Project>(
                            labelText:
                                "${AppLocalizations.of(context)!.projectName}${isMandatory ? " *" : ""}",
                            columnHeaders: [
                              AppLocalizations.of(context)!.projectName,
                              AppLocalizations.of(context)!.projectName,
                            ],
                            items: controller.project,
                            selectedValue: controller.selectedProject,
                            searchValue: (p) => '${p.name} ${p.code}',
                            displayText: (p) => p.code,
                            validator: (value) {
                              if (controller
                                      .projectDropDowncontroller
                                      .text
                                      .isEmpty &&
                                  isMandatory) {
                                return AppLocalizations.of(
                                  context,
                                )!.fieldRequired;
                              }
                              return null;
                            },
                            onChanged: (p) {
                              controller.selectedProject = p;
                              controller.projectDropDowncontroller.text =
                                  p!.code;
                            },
                            controller: controller.projectDropDowncontroller,
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
                          );
                        } else if (label == 'Tax Group') {
                          inputField =
                              SearchableMultiColumnDropdownField<TaxGroupModel>(
                                labelText:
                                    '${AppLocalizations.of(context)!.taxGroup}',
                                columnHeaders: [
                                  AppLocalizations.of(context)!.taxAmount,
                                  AppLocalizations.of(context)!.taxId,
                                ],
                                items: controller.taxGroup,
                                selectedValue: controller.selectedTax,
                                searchValue: (tax) =>
                                    '${tax.taxGroup} ${tax.taxGroupId}',
                                displayText: (tax) => tax.taxGroupId,
                                onChanged: (tax) {
                                  controller.selectedTax = tax;
                                },
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
                              );
                        } else if (label == 'Tax Amount') {
                          inputField = TextFormField(
                            controller: taxAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText:
                                  "${AppLocalizations.of(context)!.taxAmount}${isMandatory ? " *" : ""}",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } else {
                          inputField = TextFormField(
                            decoration: InputDecoration(
                              labelText: "$label${isMandatory ? " *" : ""}",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [const SizedBox(height: 12), inputField],
                        );
                      })
                      .toList(),

                  const SizedBox(height: 16),

                  // ── Unit price + Quantity ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: unitPriceController,
                          decoration: InputDecoration(
                            labelText:
                                "${AppLocalizations.of(context)!.unitAmount}*",
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          onChanged: (value) {
                            final qty =
                                double.tryParse(quantityController.text) ?? 0.0;
                            final unit =
                                double.tryParse(unitPriceController.text) ??
                                0.0;
                            lineAmountController.text = (qty * unit)
                                .toStringAsFixed(2);
                            controllerItems
                                .getTotalLineAmount()
                                .toStringAsFixed(2);
                            updateTotalAmount();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.fieldRequired;
                            }
                            if (double.tryParse(value) == null) {
                              return AppLocalizations.of(
                                context,
                              )!.enterValidRate;
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
                              vertical: 20,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          onChanged: (value) {
                            updateTotalAmount();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.field;
                            }
                            if (double.tryParse(value) == null) {
                              return AppLocalizations.of(
                                context,
                              )!.enterValidAmount;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Line amount row ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lineAmountController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.lineAmount,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
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
                                '${AppLocalizations.of(context)!.lineAmountInInr} ${controller.organizationCurrency}',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Is Reimbursable ──────────────────────────────────
                  ...controller.configList
                      .where(
                        (field) =>
                            field['IsEnabled'] == true &&
                            field['FieldName'] == 'Is Reimbursible',
                      )
                      .map((field) {
                        if (!controller.isReimbursableEnabled.value &&
                            controller.isReimbursiteCreate.value) {
                          controller.isReimbursable = false;
                          controller.isReimbursiteCreate.value = false;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                switchTheme: SwitchThemeData(
                                  thumbColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
                                        final selected = states.contains(
                                          WidgetState.selected,
                                        );
                                        if (states.contains(
                                          WidgetState.disabled,
                                        )) {
                                          return selected ? Colors.green : null;
                                        }
                                        return selected ? Colors.green : null;
                                      }),
                                  trackColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
                                        final selected = states.contains(
                                          WidgetState.selected,
                                        );
                                        if (states.contains(
                                          WidgetState.disabled,
                                        )) {
                                          return selected
                                              ? Colors.green.withOpacity(0.5)
                                              : null;
                                        }
                                        return selected
                                            ? Colors.green.withOpacity(0.5)
                                            : null;
                                      }),
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  AppLocalizations.of(context)!.isReimbursable,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: controller.isReimbursable,
                                onChanged:
                                    controller.isReimbursableEnabled.value
                                    ? (val) {
                                        _isReimbursable.value = val;
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(),

                  // ── Is Billable ──────────────────────────────────────
                  ...controller.configList
                      .where(
                        (field) =>
                            field['IsEnabled'] == true &&
                            field['FieldName'] == 'Is Billable',
                      )
                      .map((field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                switchTheme: SwitchThemeData(
                                  thumbColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return controller.isBillableCreate
                                                ? Colors.blue
                                                : Colors.grey.shade400;
                                          }
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.blue;
                                          }
                                          return Colors.grey.shade400;
                                        },
                                      ),
                                  trackColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return controller.isBillableCreate
                                                ? Colors.blue.withOpacity(0.5)
                                                : Colors.grey.shade300;
                                          }
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.blue.withOpacity(0.5);
                                          }
                                          return Colors.grey.shade300;
                                        },
                                      ),
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  AppLocalizations.of(context)!.isBillable,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: controller.isisBillablereate.value,
                                activeColor: Colors.blue,
                                inactiveThumbColor: Colors.grey.shade400,
                                inactiveTrackColor: Colors.grey.shade300,
                                onChanged: (val) {
                                  controller.isisBillablereate.value = val;
                                },
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(),
                ],
              ),
            ),

            // ── Account Distribution ───────────────────────────────────
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
                          top: Radius.circular(16),
                        ),
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
                            index: index,
                            splits: split,
                            lineAmount: lineAmount,
                            onChanged: (i, updatedSplit) {
                              split[i] = updatedSplit;
                            },
                            onDistributionChanged: (newList) {
                              controller.accountingDistributions.addAll(
                                newList,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.accountDistribution,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
