import 'dart:async';

import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../../../l10n/app_localizations.dart';
import '../../../../service.dart';

class CashAdvanceReturnForm extends StatefulWidget {
  const CashAdvanceReturnForm({super.key});

  @override
  State<CashAdvanceReturnForm> createState() => _CashAdvanceReturnFormState();
}

class _CashAdvanceReturnFormState extends State<CashAdvanceReturnForm>
    with TickerProviderStateMixin {
  final controller = Get.put(Controller());
  final controllerItems = Get.put(Controller());
  // final _formKey = GlobalKey<FormState>();
  List<Controller> itemizeControllers = [];
  RxList<CashAdvanceDropDownModel> cashAdvanceList =
      <CashAdvanceDropDownModel>[].obs;
  int _currentStep = 0;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  int _selectedCategoryIndex = -1;
  // bool _controller.showPaidForError.value = false;
  bool _showPaidWithError = false;
  //  bool cashAdvanceField = false;
  // bool controller.showQuantityError.value = false;
  // bool controller.showUnitAmountError.value = false;
  bool _showUnitError = false;
  // bool _showProjectError = false;
  // bool controller.setQuality.value = true;
  bool allowMultSelect = false;
  late Future<Map<String, bool>> _featureFuture;

 bool _isTyping = false;
 late FocusNode _focusNode;
  bool clearField = false;
  bool _showTaxAmountError = false;
  bool showItemizeDetails = false;
  String? _paidTo;
  bool? isThereReferenceID = false;
  String? paidToError;
  final RxnString paidwithError = RxnString();
  final RxnString cashAdvanceField = RxnString();
  String? selectDate;
  String? selectReferenceIDError;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
     _focusNode = FocusNode();
    controller.selectedDate ??= DateTime.now();
  _focusNode.addListener(() {
    setState(() {
      _isTyping = _focusNode.hasFocus;
    });
  });
  _featureFuture = controller.getAllFeatureStates(); 

    // controller.clearFormFields();

    controller.selectedDate ??= DateTime.now();

    // controller.fetchPaidto();

    itemizeControllers.add(Controller());

    controller.isManualEntryMerchant = false;
    _initializeUnits();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Safe to update observables here
      controller.configuration();
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.getUserPref(context);
      controller.fetchExpenseCategory();
      _loadSettings();
                                          loadAndAppendCashAdvanceList();

// controller.isLoadingGE2.value = false
      // controller.fetchExchangeRate();
    });
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();
      controller.cashAdvanceListDropDown.addAll(newItems); // ✅ Append here
      print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
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

  bool isFieldMandatory(String fieldName) {
    return controller.configList.any(
      (f) =>
          (f['FieldName']?.toString().trim().toLowerCase() ==
              fieldName.trim().toLowerCase()) &&
          (f['IsEnabled'].toString().toLowerCase() == 'true') &&
          (f['IsMandatory'].toString().toLowerCase() == 'true'),
    );
  }

  bool validateDropdowns() {
    bool isValid = true;

    if (allowMultSelect) {
      print("allowMultSelect$allowMultSelect");
        setState(() {
          // selectReferenceIDError = null;
          cashAdvanceField.value = null;
        });
    } else {
      if (controller.singleSelectedItem == null) {
        cashAdvanceField.value = AppLocalizations.of(
          context,
        )!.pleaseSelectCashAdvanceField;
        ;
        isValid = false;
      }
      setState(() {
        // selectReferenceIDError = null;
        cashAdvanceField.value = null;
      });
    }
      setState(() {
        paidwithError.value = null;
      });

    // Validate Date
    // if (controller.selectedDate == null) {
    //   setState(() {
    //     paidwithError = 'Please select a Date';
    //   });
    //   isValid = false;
    // } else {
    //   setState(() {
    //     paidwithError = null;
    //   });
    // }

    // Validate Reference ID
    if (isThereReferenceID == true && controller.referenceID.text.isEmpty) {
      setState(() {
        selectReferenceIDError = 'Please select a Reference ID';
      });
      isValid = false;
    } else {
      setState(() {
        selectReferenceIDError = null;
      });
    }

    return isValid;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != controller.selectedDate) {
      setState(() {
        controller.selectedDate = picked;
        selectDate = null;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  final List<Color> categoryColors = [
    Colors.green,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.grey.shade400,
    Colors.red.shade700,
    Colors.pink.shade200,
  ];
  Future<void> _initializeUnits() async {
    await controller.fetchUnit(); // Wait for units to be fetched
    Timer(const Duration(seconds: 5), () {
      print("controller.unit${controller.selectedunit}");
      if (controller.selectedunit == null) {
        final defaultUnit = controller.unit.firstWhere(
          (unit) => unit.code == 'Uom-004' && unit.name == 'Each',
          orElse: () => controller.unit.first,
        );
        setState(() {
          controller.selectedunit ??= defaultUnit;
          controller.selectedunit ??= defaultUnit;
        });
      }
    });
  }

  void _addItemize() {
    if (!showItemizeDetails) {
      print("Check$showItemizeDetails");
      setState(() {
        showItemizeDetails = true;
      });
    } else {
          if (_validateCurrentItemizeForm()) {
      if (_itemizeCount < 5) {
        setState(() {
          itemizeControllers.add(Controller());
          _itemizeCount++;
          _selectedItemizeIndex = _itemizeCount - 1;
          showItemizeDetails = true;
        });
      }
    }
    }
  }

  void _removeItemize(int selectedItemizeIndex) {
    if (_itemizeCount < 1) {
      showItemizeDetails = false;
    }
    if (selectedItemizeIndex == 0) {
      setState(() {
        itemizeControllers.removeAt(0);
        _itemizeCount--;
      });
    }
    if (_itemizeCount > 1 &&
        _selectedItemizeIndex >= 0 &&
        _selectedItemizeIndex < itemizeControllers.length) {
      setState(() {
        itemizeControllers.removeAt(_selectedItemizeIndex);
        _itemizeCount--;

        // Adjust selected index if needed
        if (_selectedItemizeIndex >= _itemizeCount) {
          _selectedItemizeIndex = _itemizeCount - 1;
        }
      });
    }
  }

  Widget _buildStep(int index) {
    final isActive = index == _currentStep;
    final isCompleted = index < _currentStep;
    final List<String> _titles = [
      AppLocalizations.of(context)!.paymentInfo,
      AppLocalizations.of(context)!.itemize,
      AppLocalizations.of(context)!.expenseDetails,
    ];
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive
              ? Colors.orange
              : isCompleted
              ? Colors.orange
              : Colors.grey,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _titles[index],
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted ? Colors.orange : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int segmentIndex) {
    final isCompleted = segmentIndex < _currentStep;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0), // adjust as needed
        child: Container(
          height: 2,
          width: 50,
          color: isCompleted ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        _buildStep(0),
        _buildStepLine(0),
        _buildStep(1),
        _buildStepLine(1),
        _buildStep(2),
      ],
    );
  }

  bool validateExpenseForm() {
    bool isValid = true;

    setState(() {
      // Reset all error states
      controller.showQuantityError.value = false;
      controller.showUnitAmountError.value = false;
      _showUnitError = false;
      controller.showTaxAmountError.value = false;
      controller.showPaidForError.value = false;
    });

    // Validate Paid For (category)
    if (controller.selectedCategoryId.isEmpty) {
      controller.showPaidForError.value = true;
      isValid = false;
    }

    // Validate Tax Amount if mandatory
    final taxAmountMandatory = controller.configList.any(
      (f) => f['FieldName'] == 'Tax Amount' && f['IsMandatory'] == true,
    );
    if (taxAmountMandatory && controller.taxAmount.text.trim().isEmpty) {
      controller.showTaxAmountError.value = true;
      isValid = false;
    }

    // Validate Itemized fields if enabled
    if (_itemizeCount > 1) {
      if (controller.quantity.text.trim().isEmpty) {
        controller.showQuantityError.value = true;
        isValid = false;
      }

      if (controller.unitAmount.text.trim().isEmpty) {
        controller.showUnitAmountError.value = true;
        isValid = false;
      }

      if (controller.selectedunit == null) {
        _showUnitError = true;
        isValid = false;
      }
    }

    return isValid;
  }

  Widget _buildItemizePage() {
    final loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: _itemizeCount,
      initialIndex: _selectedItemizeIndex,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
            onTap: (index) {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            tabs: List.generate(
              _itemizeCount,
              (index) => Tab(text: "${loc.itemize} ${index + 1}"),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: List.generate(
                _itemizeCount,
                (index) => Center(
                  child: expenseCreateForm2(context, itemizeControllers[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 void backButton() {
    print("Its BAck");
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
   bool _validateCurrentItemizeForm() {
  final currentController = itemizeControllers[_selectedItemizeIndex];
  bool isValid = true;

  // Reset all error states
  setState(() {
    currentController.showQuantityError.value = false;
    currentController.showUnitAmountError.value = false;
    _showUnitError = false;
    currentController.showTaxAmountError.value = false;
    currentController.showProjectError.value = false;
    currentController.showPaidForError.value = false;
    currentController.enableNextBtn.value = false;
    currentController.showTaxGroupError.value=false;
  });

  // 1. Validate Category (Paid For)
  if (currentController.selectedCategoryId.isEmpty) {
    setState(() => currentController.showPaidForError.value = true);
    isValid = false;
  }

  // 2. Validate Quantity
  if (currentController.quantity.text.isEmpty) {
    setState(() => currentController.showQuantityError.value = true);
    isValid = false;
  }

  // 3. Validate Unit Amount
  if (currentController.unitAmount.text.isEmpty) {
    setState(() => currentController.showUnitAmountError.value = true);
    isValid = false;
  }

  // 4. Validate Unit
  if (currentController.selectedunit == null) {
    setState(() => _showUnitError = true);
    isValid = false;
  }

  // 5. Validate Tax Amount if mandatory
  final taxAmountMandatory = isFieldMandatory('Tax Amount');
  if (currentController.taxAmount.text.isEmpty && taxAmountMandatory) {
    setState(() => currentController.showTaxAmountError.value = true);
    isValid = false;
  }
final taxGroupMandatory = isFieldMandatory('Tax Group');
  if (currentController.taxGroupController.text.isEmpty && taxGroupMandatory) {
    setState(() => currentController.showTaxGroupError.value = true);
    isValid = false;
  }
  // 6. Validate Project if mandatory
  final projectIdMandatory = isFieldMandatory('Project Id');
  if (projectIdMandatory && currentController.selectedProject == null) {
    setState(() => currentController.showProjectError.value = true);
    isValid = false;
  }
currentController.enableNextBtn.value = isValid;

  return isValid;
}
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
      final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title:  Text(AppLocalizations.of(context)!.exitForm),
            content:  Text(
              AppLocalizations.of(context)!.exitWarning ,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay
                child:  Text(AppLocalizations.of(context)!.cancel),
              ),
               TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirm exit
                child:  Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          // ✅ Only navigate & clear fields if user confirms
          Navigator.pushNamed(context, AppRoutes.generalExpense);
          controller.clearFormFields();
          return true; // allow navigation
        }

        return false; // cancel back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.cashAdvanceReturnForm,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProgressBar(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  expenseCreationFormStep1(context),
                  _buildItemizePage(),
                   CreateExpensePage( backButton: backButton),
                ],
              ),
            ),
          ],
        ),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     children: [
        //       if (_currentStep == 2)
        //         OutlinedButton.icon(
        //           onPressed: () {
        //             setState(() {
        //               _currentStep--;
        //               _pageController.animateToPage(
        //                 _currentStep,
        //                 duration: const Duration(milliseconds: 300),
        //                 curve: Curves.easeInOut,
        //               );
        //             });
        //           },
        //           style: OutlinedButton.styleFrom(
        //             side: const BorderSide(color: Colors.grey),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //           ),
        //           icon: const Icon(Icons.arrow_back),
        //           label: Text(loc.back),
        //         ),
        //       if (_currentStep > 0)
        //         const SizedBox(height: 100)
        //       else
        //         const SizedBox(), // Empty space if back is not shown
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget expenseCreateForm2(BuildContext context, Controller controller) {
    final loc = AppLocalizations.of(context)!;
    // Use the provided controller parameter consistently
    controller.selectedunit ??= controllerItems.selectedunit;
    controller.selectedDate = controllerItems.selectedDate;
    // controller.isReimbursite.vale = true;
    print("selecteduni${controller.selectedunit}");
    if (controller.setQuality.value) {
      if (controller.quantity.text.isEmpty) {
        controller.quantity.text = '1.00';
      }
    }
    if (clearField) {
      controller.quantity.clear();
      controller.selectedProject = null;
      controller.paidAmount.clear();
      controller.lineAmount.clear();
      controller.selectedProject = null;
      controller.selectedTax = null;
      controller.selectedCategoryId = '';
      controller.taxAmount.clear();
      controller.unitAmount.clear();
      controller.descriptionController;
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...controllerItems.configList
                  .where(
                    (field) =>
                        field['IsEnabled'] == true &&
                        field['FieldName'] != 'Location' &&
                        field['FieldName'] != 'Refrence Id' &&
                        field['FieldName'] != 'Is Billable' &&
                        field['FieldName'] != 'is Reimbursible',
                  )
                  .map((field) {
                    final String label = field['FieldName'];
                    final bool isMandatory = field['IsMandatory'] ?? false;

                    Widget inputField;

                    if (label == 'Project Id') {
                      inputField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchableMultiColumnDropdownField<Project>(
                            labelText:
                                '${loc.projectId} ${isMandatory ? "*" : ""}',
                            columnHeaders: const ['Project Name', 'Project Id'],
                            items: controllerItems.project,
                            selectedValue: controller.selectedProject,
                            searchValue: (proj) => '${proj.name} ${proj.code}',
                            displayText: (proj) => proj.code,
                            onChanged: (proj) {
                              setState(() {
                                controller.selectedProject = proj;
                                controllerItems.selectedProject = proj;
                                // Clear validation error when a project is selected
                                if (proj != null) {
                                  controller.showProjectError.value = false;
                                }
                              });
                              controller.fetchExpenseCategory();
                            },
                            rowBuilder: (proj, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(proj.name)),
                                    Expanded(child: Text(proj.code)),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (controller.showProjectError.value) // 👈 Show error below dropdown
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                loc.pleaseSelectProject,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    } else if (label == 'Tax Group') {
                      inputField =
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchableMultiColumnDropdownField<TaxGroupModel>(
                            labelText:
                                '${loc.taxGroup} ${isMandatory ? "*" : ""}',
                            columnHeaders: const ['Tax Group', 'Tax ID'],
                            items: controllerItems.taxGroup,
                            selectedValue: controller.selectedTax,
                            controller: controller.taxGroupController,
                            searchValue: (tax) =>
                                '${tax.taxGroup} ${tax.taxGroupId}',
                            displayText: (tax) => tax.taxGroupId,
                           validator: (tax) => isMandatory &&  controller.taxGroupController.text.isEmpty
                                ? '${loc.pleaseSelectTaxGroup} '

                                : null,
                            onChanged: (tax) {
                              setState(() {
                                controller.selectedTax = tax;
                                controllerItems.selectedTax = tax;
                                 if (tax != null) {
                                  controller.showTaxGroupError.value = false;
                                }
                              });
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
                          ),
                           if (controller
                              .showTaxGroupError
                              .value) 
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                loc.pleaseSelectTaxGroup,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ]);
                    } else if (label == 'Tax Amount') {
                      inputField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],
                            controller: controller.taxAmount,
                            onChanged: (tax) {
                              setState(() {
                                controller.taxAmount.text = tax;
                                // Clear error once the user starts typing
                                if (tax.isNotEmpty) {
                                  controller.showTaxAmountError.value = false;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText:
                                  '${loc.taxAmount}${isMandatory ? " *" : ""}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          if (controller.showTaxAmountError.value) // 👈 Show error only when flag is true
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                '${loc.taxAmountRequired} ',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
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
                        // const SizedBox(height: 20),
                      ],
                    );
                  })
                  .toList(),
              const SizedBox(height: 16),
              Text("${loc.paidFor} *"),
              const SizedBox(height: 20),
              if (controller.showPaidForError.value)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${loc.pleaseSelectCategory} ',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              Obx(() {
                final fetchCategory = (controller.expenseCategory.isNotEmpty)
                    ? controller.expenseCategory
                    : controllerItems.expenseCategory;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: fetchCategory.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final color = categoryColors[index % categoryColors.length];

                    return _buildCategoryButton(
                      index,
                      item,
                      item.categoryId,
                      color,
                      color,
                      item.expenseCategoryIcon.toString(),
                      controller,
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  if (showItemizeDetails)
                    SearchableMultiColumnDropdownField<Unit>(
                      labelText: '${loc.unit}  *',
                      columnHeaders: ['${loc.uomId} ', loc.uomName],
                      items: controllerItems.unit,
                      selectedValue: controller.selectedunit,
                      searchValue: (tax) => '${tax.code} ${tax.name}',
                      displayText: (tax) => tax.name,
                      onChanged: (tax) {
                        setState(() {
                          controller.selectedunit = tax;
                          _showUnitError = false;
                        });
                      },
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
                  if (showItemizeDetails)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],
                            controller: controller.unitAmount,
                            onChanged: (value) {
                              controllerItems.fetchExchangeRate();
                              controllerItems.unitAmount.text = value;
                              setState(() {
                                controller.unitAmount.text = value;
                                controller.showUnitAmountError.value = false;
                              });
                              final qty =
                                  double.tryParse(controller.quantity.text) ??
                                  0.0;
                              final unit =
                                  double.tryParse(controller.unitAmount.text) ??
                                  0.0;

                              final calculatedLineAmount = qty * unit;

                              controller.paidAmount.text = calculatedLineAmount
                                  .toStringAsFixed(2);
                              controllerItems.paidAmontIsEditable.value = false;
                              controller.lineAmount.text = calculatedLineAmount
                                  .toStringAsFixed(2);
                              controller.lineAmountINR.text =
                                  calculatedLineAmount.toStringAsFixed(2);
                            },
                            onEditingComplete: () {
                              String text = controller.unitAmount.text;
                              double? value = double.tryParse(text);
                              if (value != null) {
                                controller.unitAmount.text = value
                                    .toStringAsFixed(2);
                                controller.paidAmount.text = value
                                    .toStringAsFixed(2);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "${loc.unitAmount}  *",
                              errorText: controller.showUnitAmountError.value
                                  ? loc.unitAmountRequired
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        if (showItemizeDetails) const SizedBox(width: 12),
                        if (showItemizeDetails)
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              controller: controller.quantity,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ), // Allows numbers with up to 2 decimal places
                              ],
                              onChanged: (value) {
                                setState(() {
                                  controller.quantity.text = value;
                                  controller.showQuantityError.value = false;
                                  controller.setQuality.value = false;
                                });
                                final qty =
                                    double.tryParse(controller.quantity.text) ??
                                    0.0;
                                final unit =
                                    double.tryParse(
                                      controller.unitAmount.text,
                                    ) ??
                                    0.0;

                                final calculatedLineAmount = qty * unit;
                                print(
                                  "calculatedLineAmount: $qty x $unit = $calculatedLineAmount",
                                );
                                controller.paidAmount.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.paidAmontIsEditable.value = false;
                                controller.lineAmount.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                                controller.lineAmountINR.text =
                                    calculatedLineAmount.toStringAsFixed(2);
                              },
                              decoration: InputDecoration(
                                labelText: "${loc.quantity} *",
                                errorText: controller.showQuantityError.value
                                    ? '${loc.quantityRequired} '
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (showItemizeDetails) const SizedBox(height: 16),
                  if (showItemizeDetails)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            "${loc.lineAmount}  *",
                            controller.lineAmount,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextInput(
                            "${loc.lineAmountInInr}  *",
                            controller.lineAmountINR,
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  if (controller.lineAmount.text.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final double lineAmount =
                                double.tryParse(controller.lineAmount.text) ??
                                0.0;

                            // Only initialize splits if empty
                            if (controller.split.isEmpty &&
                                controller.accountingDistributions.isNotEmpty) {
                              controller.split.assignAll(
                                controller.accountingDistributions.map((e) {
                                  return AccountingSplit(
                                    paidFor: e!.dimensionValueId,
                                    percentage: e.allocationFactor,
                                    amount: e.transAmount,
                                  );
                                }).toList(),
                              );
                            } else if (controller.split.isEmpty) {
                              controller.split.add(
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
                                    splits: controller.split,
                                    lineAmount: lineAmount,
                                    onChanged: (i, updatedSplit) {
                                      if (!mounted) return;
                                      controller.split[i] = updatedSplit;
                                    },
                                    onDistributionChanged: (newList) {
                                      if (!mounted) return;
                                      controller.accountingDistributions
                                          .clear();
                                      controller.accountingDistributions.addAll(
                                        newList,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(loc.accountDistribution),
                        ),
                      ],
                    ),
                  if (showItemizeDetails) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.totalAmount,
                            // ignore: prefer_const_constructors
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _calculateTotalLineAmount(
                              controller,
                            ).toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.comments,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_itemizeCount > 1)
                        OutlinedButton.icon(
                          onPressed: () =>
                              _removeItemize(_selectedItemizeIndex),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.gradientEnd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 233, 8, 8),
                          ),
                          label: Text(
                            loc.remove,
                            style: const TextStyle(
                              color: AppColors.gradientEnd,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                    FutureBuilder<Map<String, bool>>(
  future: _featureFuture,
  builder: (context, snapshot) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // While waiting for API → show nothing (or a small placeholder if needed)
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox.shrink();
    }

    if (!snapshot.hasData) {
      return const SizedBox.shrink();
    }

    final featureStates = snapshot.data!;
    final isEnabled = featureStates['EnableItemization'] ?? false;

    // ❌ Hide button completely if feature disabled
    if (!isEnabled) return const SizedBox.shrink();

    // ✅ Show button only when feature is enabled
    return OutlinedButton.icon(
      onPressed: () {
        // Validate current form before adding new itemize
        if (validateDropdowns()) {
          _addItemize();
        } else {
          // Optional: Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.pleaseFillAllRequiredFields),
              backgroundColor: Colors.red,
            ),
          );
        }
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
)

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                                _pageController.animateToPage(
                                  _currentStep,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            label: Text(loc.back),
                          )
                        else
                          const SizedBox(),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if(showItemizeDetails){
                              if (_validateCurrentItemizeForm()) {
                              setState(() {
                                controller.showQuantityError.value = false;
                                controller.showUnitAmountError.value = false;
                                _showUnitError = false;
                                controller.showTaxAmountError.value = false;
                              });

                              bool isValid = true;

                              if (controller.selectedCategoryId.isEmpty) {
                                setState(
                                  () =>
                                      controller.showPaidForError.value = true,
                                );
                                isValid = false;
                              }

                              if (_itemizeCount >= 1) {
                                print(
                                  "controller.unitAmount.text${_itemizeCount}",
                                );

                                if (controller.quantity.text.isEmpty) {
                                  setState(
                                    () => controller.showQuantityError.value =
                                        true,
                                  );
                                  isValid = false;
                                }
                                if (showItemizeDetails) {
                                  if (controller.unitAmount.text.isEmpty) {
                                    setState(
                                      () =>
                                          controller.showUnitAmountError.value =
                                              true,
                                    );
                                    isValid = false;
                                  }

                                  if (controller.selectedunit == null) {
                                    setState(() => _showUnitError = true);
                                    isValid = false;
                                  }
                                }
                                final taxAmountMandatory = isFieldMandatory(
                                  'Tax Amount',
                                );
                                // Validate other mandatory fields
                                if (controller.taxAmount.text.isEmpty &&
                                    taxAmountMandatory) {
                                  setState(
                                    () => controller.showTaxAmountError.value =
                                        true,
                                  );
                                  isValid = false;
                                }
                              }

                              // Validate Project Id if mandatory
                              final projectIdMandatory = isFieldMandatory(
                                'Project Id',
                              );

                              print("projectIdMandatory$projectIdMandatory");
                              print(
                                "projectIdMandatory${controller.selectedProject == null}",
                              );
                              if (projectIdMandatory &&
                                  controller.selectedProject == null) {
                                setState(
                                  () =>
                                      controller.showProjectError.value = true,
                                );
                                isValid = false;
                              } else {
                                setState(
                                  () =>
                                      controller.showProjectError.value = false,
                                );
                              }

                              print('isValid$isValid');
                              print('isValid${itemizeControllers.length}');
                              if (isValid) {
                                if (showItemizeDetails) {
                                  controllerItems.finalItems =
                                      itemizeControllers
                                          .map((c) => c.toExpenseItemModel())
                                          .toList();
                                  _nextStep();
                                  FocusScope.of(context).unfocus();
                                } else {
                                  _nextStep();
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please check all Field",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                           }
                          else{
                              if (validateExpenseForm()) {
                              setState(() {
                                controller.showQuantityError.value = false;
                                controller.showUnitAmountError.value = false;
                                _showUnitError = false;
                                controller.showTaxAmountError.value = false;
                              });

                              bool isValid = true;

                              if (controller.selectedCategoryId.isEmpty) {
                                setState(
                                  () =>
                                      controller.showPaidForError.value = true,
                                );
                                isValid = false;
                              }

                              if (_itemizeCount >= 1) {
                                print(
                                  "controller.unitAmount.text${_itemizeCount}",
                                );

                                if (controller.quantity.text.isEmpty) {
                                  setState(
                                    () => controller.showQuantityError.value =
                                        true,
                                  );
                                  isValid = false;
                                }
                                if (showItemizeDetails) {
                                  if (controller.unitAmount.text.isEmpty) {
                                    setState(
                                      () =>
                                          controller.showUnitAmountError.value =
                                              true,
                                    );
                                    isValid = false;
                                  }

                                  if (controller.selectedunit == null) {
                                    setState(() => _showUnitError = true);
                                    isValid = false;
                                  }
                                }
                                final taxAmountMandatory = isFieldMandatory(
                                  'Tax Amount',
                                );
                                // Validate other mandatory fields
                                if (controller.taxAmount.text.isEmpty &&
                                    taxAmountMandatory) {
                                  setState(
                                    () => controller.showTaxAmountError.value =
                                        true,
                                  );
                                  isValid = false;
                                }
                              }

                              // Validate Project Id if mandatory
                              final projectIdMandatory = isFieldMandatory(
                                'Project Id',
                              );

                              print("projectIdMandatory$projectIdMandatory");
                              print(
                                "projectIdMandatory${controller.selectedProject == null}",
                              );
                              if (projectIdMandatory &&
                                  controller.selectedProject == null) {
                                setState(
                                  () =>
                                      controller.showProjectError.value = true,
                                );
                                isValid = false;
                              } else {
                                setState(
                                  () =>
                                      controller.showProjectError.value = false,
                                );
                              }

                              print('isValid$isValid');
                              print('isValid${itemizeControllers.length}');
                              if (isValid) {
                                if (showItemizeDetails) {
                                  controllerItems.finalItems =
                                      itemizeControllers
                                          .map((c) => c.toExpenseItemModel())
                                          .toList();
                                  _nextStep();
                                  FocusScope.of(context).unfocus();
                                } else {
                                  _nextStep();
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please check all Field",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.gradientEnd,
                            side: const BorderSide(
                              color: AppColors.gradientEnd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _currentStep == 2
                                ? '${loc.finish} '
                                : '${loc.next} ',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalLineAmount(Controller controllers) {
    double total = 0.0;

    final currentLineAmount =
        double.tryParse(controllers.lineAmount.text) ?? 0.0;
    total += currentLineAmount;

    for (var itemController in itemizeControllers) {
      if (itemController != controllers) {
        final amount = double.tryParse(itemController.lineAmount.text) ?? 0.0;
        total += amount;
      }
    }
    controller.paidAmount.text = total.toString();
    print("total$total");
    return total;
  }

  Widget _buildCategoryButton(
  int index,
  ExpenseCategory item,
  String iD,
  Color color,
  Color textColor,
  String? icon,
  Controller controllers,
) {
  final isSelected = controllers.selectedCategoryId == item.categoryId;

  // ✅ Static cache (prevents re-decoding flicker)
  final Map<String, Uint8List> _base64Cache = {};

  Widget _buildIcon(String? icon) {
    const fallbackUrl =
        "https://icons.veryicon.com/png/o/commerce-shopping/icon-of-lvshan-valley-mobile-terminal/home-category.png";

    try {
      if (icon != null && icon.isNotEmpty) {
        if (icon.startsWith('data:image')) {
          // Base64 with prefix
          final base64Str = icon.split(',').last;
          if (!_base64Cache.containsKey(base64Str)) {
            _base64Cache[base64Str] = base64Decode(base64Str);
          }
          return Image.memory(
            _base64Cache[base64Str]!,
            width: 30,
            height: 30,
            gaplessPlayback: true, // prevents blinking
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 30),
          );
        } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(icon)) {
          // Plain Base64 (no prefix)
          if (!_base64Cache.containsKey(icon)) {
            _base64Cache[icon] = base64Decode(icon);
          }
          return Image.memory(
            _base64Cache[icon]!,
            width: 30,
            height: 30,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 30),
          );
        } else {
          // ✅ URL or asset
          return Image.asset(
            icon,
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 30),
          );
        }
      }
    } catch (_) {}

    // ✅ Fallback if icon is null or invalid
    return Image.network(
      fallbackUrl,
      width: 30,
      height: 30,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, size: 30),
    );
  }

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCategoryIndex = index;
      });
      controllers.showPaidForError.value = false;
      controllers.selectedCategoryId = item.categoryId;
      controller.selectedCategoryId = item.categoryId;

      print("Tapped Category Name: ${item.categoryName}");
      print("Tapped Category ID: ${controllers.selectedCategoryId}");
    },
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: isSelected
            ? Border.all(
                color: const Color.fromARGB(255, 163, 11, 11),
                width: 3,
              )
            : null,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 👇 Use this if you want to hide icons while typing
          AnimatedOpacity(
            opacity: _isTyping ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: _buildIcon(icon),
          ),
          const SizedBox(height: 8),
          Text(
            item.categoryId,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTextInput(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'),
            ), // Allows numbers with up to 2 decimal places
          ],
          decoration: InputDecoration(
            labelText: label,
            filled: !enabled ? true : false,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget expenseCreationFormStep1(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Obx(() {
        return controller.isLoadingGE2.value
            ? const SkeletonLoaderPage()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  // key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      FormField<DateTime>(
                        validator: (value) {
                          if (controller.selectedDate == null) {
                            return '${loc.selectDateFormat} ';
                          }
                          return null;
                        },
                        builder: (FormFieldState<DateTime> field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _selectDate(context);
                                  field.didChange(controller.selectedDate);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: '${loc.requestDate} *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    errorText: field.errorText,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.selectedDate == null
                                            ? '${loc.selectDate} '
                                            : DateFormat('dd/MM/yyyy').format(
                                                controller.selectedDate!,
                                              ),
                                        style: TextStyle(
                                          color: controller.selectedDate == null
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 6),

                      // Reference ID Field
                      Obx(() {
                        return Column(
                          children: controller.configList
                              .where(
                                (field) =>
                                    field['IsEnabled'] == true &&
                                    field['FieldName'] == 'Refrence Id',
                              )
                              .map((field) {
                                final String label = field['FieldName'];
                                final bool isMandatory =
                                    field['IsMandatory'] ?? false;
                                isThereReferenceID =
                                    field['IsMandatory'] ?? false;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    FormField<String>(
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null || value.isEmpty)) {
                                          return 'This field is required';
                                        }
                                        return null;
                                      },
                                      builder: (FormFieldState<String> field) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextField(
                                              controller:
                                                  controller.referenceID,
                                              onChanged: (value) {
                                                field.didChange(value);
                                                selectReferenceIDError = null;
                                              },
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                errorText: field.errorText,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if (selectReferenceIDError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          selectReferenceIDError.toString(),
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              })
                              .toList(),
                        );
                      }),

                      // const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Obx(
                          //   () =>
                          MultiSelectMultiColumnDropdownField<
                            CashAdvanceDropDownModel
                          >(
                            labelText: loc.cashAdvanceRequest,
                            controller: controller.cashAdvanceIds,
                            items: controller.cashAdvanceListDropDown,
                            isMultiSelect: allowMultSelect ?? false,
                            selectedValue: controller.singleSelectedItem,
                            selectedValues: controller.multiSelectedItems,

                            // enabled: controller.isEnable.value,
                            searchValue: (proj) => proj.cashAdvanceReqId,
                            displayText: (proj) => proj.cashAdvanceReqId,
                            validator: (proj) => proj == null
                                ? '${loc.cashAdvanceRequest} '
                                : null,
                            onChanged: (item) {
                              controller.singleSelectedItem = item;
                            },
                            onMultiChanged: (items) {
                              controller.multiSelectedItems.assignAll(items);
                            },
                            columnHeaders: [loc.requestId, loc.requestDate],
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
                          // ),
                          // if (selectReferenceIDError != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(
                          //       left: 8.0,
                          //       bottom: 8,
                          //     ),
                          //     child: Text(
                          //       selectReferenceIDError.toString(),
                          //       style: const TextStyle(color: Colors.red),
                          //     ),
                          //   ),
                          if (cashAdvanceField.value != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                bottom: 8,
                              ),
                              child: Text(
                                cashAdvanceField.value!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${loc.paidWith}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Paid With Radio Buttons
                      Obx(() {
                        // if (controller.paidWith == null &&
                        //     controller.paymentMethods.isNotEmpty) {
                        //   controller.paidWith =
                        //       controller.paymentMethods.first.paymentMethodId;
                        //   controller.paymentMethodeID =
                        //       controller.paymentMethods.first.paymentMethodId;
                        // }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Payment methods list
                            ...List.generate(controller.paymentMethods.length, (
                              index,
                            ) {
                              final method = controller.paymentMethods[index];

                              List<Color> colors = [
                                Colors.red.shade100,
                                Colors.green.shade100,
                                Colors.blue.shade100,
                                Colors.orange.shade100,
                              ];

                              List<IconData> icons = [
                                Icons.credit_card,
                                Icons.money,
                                Icons.payment,
                                Icons.account_balance_wallet,
                              ];

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: RadioListTile<String>(
                                  title: Row(
                                    children: [
                                      Icon(
                                        icons[index % icons.length],
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          method.paymentMethodName,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: method.paymentMethodId,
                                  groupValue:
                                      controller.paidWithCashAdvance.value,
                                  onChanged: (String? value) {
                                    // print(value);
                                    loadAndAppendCashAdvanceList();
                                    setState(() {
                                      if (controller
                                              .paidWithCashAdvance
                                              .value ==
                                          value) {
                                        // Unselect if same item clicked
                                        controller.paidWithCashAdvance.value =
                                            null;
                                        controller
                                                .paymentMethodeIDCashAdvance
                                                .value =
                                            null;
                                      } else {
                                        controller.paidWithCashAdvance.value =
                                            value;
                                        controller
                                                .paymentMethodeIDCashAdvance
                                                .value =
                                            value;
                                      }
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  tileColor: Colors.transparent,
                                ),
                              );
                            }),

                            // Error message below the list
                            const SizedBox(height: 8),
                            // Small red button to clear selection
                            if (controller.paidWithCashAdvance.value != null &&
                                controller
                                    .paidWithCashAdvance
                                    .value!
                                    .isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.paidWithCashAdvance.value = "";
                                    controller
                                            .paymentMethodeIDCashAdvance
                                            .value =
                                        "";
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size(
                                      60,
                                      30,
                                    ), // Small size
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    loc.clear,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            // if (paidwithError.value != null)
                            //   Padding(
                            //     padding:
                            //         const EdgeInsets.only(left: 8.0, bottom: 8),
                            //     child: Text(
                            //       paidwithError.value!,
                            //       style: const TextStyle(color: Colors.red),
                            //     ),
                            //   ),
                          ],
                        );
                      }),

                      // Show validation error under Paid With (if any)

                      // const SizedBox(height: 20),

                      // // Submit Button
                      //   SizedBox(
                      //     width: double.infinity,
                      //     child: ElevatedButton(
                      //     onPressed: () {
                      //       final isValid = _formKey.currentState!.validate();
                      //       final isPaidWithValid = _paidWith != null;

                      //       setState(() {
                      //         _showPaidWithError = !isPaidWithValid;
                      //       });

                      //       if (isValid && isPaidWithValid) {
                      //         print('Form is valid. Proceed with submission.');
                      //         // Continue to API or next step...
                      //       } else {
                      //         print('Validation failed');
                      //       }
                      //     },
                      //     child: const Text('Submit'),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _currentStep--;
                                    _pageController.animateToPage(
                                      _currentStep,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                label: Text(loc.back),
                              )
                            else
                              const SizedBox(), // Empty space if back is not shown

                            const Spacer(),

                            ElevatedButton(
                              onPressed: () {
                                if (validateDropdowns()) {
                                  // final isValid =
                                  //     _formKey.currentState!.validate();
                                  // final isPaidWithValid =
                                  //     controller.paidWith != null;

                                  // setState(() {
                                  //   _showPaidWithError = !isPaidWithValid;
                                  // });

                                  // if (isPaidWithValid) {
                                  //   _nextStep();
                                  // } else {
                                  //   print('Validation failed');
                                  // }
                                  _nextStep();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.gradientEnd,
                                side: const BorderSide(
                                  color: AppColors.gradientEnd,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentStep == 2 ? loc.finish : loc.next,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}

class CreateExpensePage extends StatefulWidget {
    final VoidCallback backButton;
  const CreateExpensePage({super.key,required this.backButton,});

  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  // bool controller._isVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitAttempted = false;
  final FocusNode _focusNode = FocusNode();
  final PhotoViewController _photoViewController = PhotoViewController();
  final controller = Get.put(Controller());
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

  // void _showFullImage(File file, int index) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.black,
  //         child: Stack(
  //           children: [
  //             PhotoView(
  //               imageProvider: FileImage(file),
  //               backgroundDecoration: const BoxDecoration(color: Colors.black),
  //               minScale: PhotoViewComputedScale.contained,
  //               maxScale: PhotoViewComputedScale.covered * 3.0,
  //             ),
  //             Positioned(
  //               top: 10,
  //               right: 10,
  //               child: Column(
  //                 children: [
  //                   // FloatingActionButton.small(
  //                   //   heroTag: "zoom_in_$index",
  //                   //   onPressed: _zoomIn,
  //                   //   child: const Icon(Icons.zoom_in),
  //                   //   backgroundColor: Colors.deepPurple,
  //                   // ),
  //                   // const SizedBox(height: 8),
  //                   // FloatingActionButton.small(
  //                   //   heroTag: "zoom_out_$index",
  //                   //   onPressed: _zoomOut,
  //                   //   child: const Icon(Icons.zoom_out),
  //                   //   backgroundColor: Colors.deepPurple,
  //                   // ),
  //                   const SizedBox(height: 8),
  //                   FloatingActionButton.small(
  //                     heroTag: "edit_$index",
  //                     onPressed: () => _cropImage(file),
  //                     child: const Icon(Icons.edit),
  //                     backgroundColor: Colors.deepPurple,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   FloatingActionButton.small(
  //                     heroTag: "delete_$index",
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       setState(() {
  //                         controller.imageFiles.removeAt(index);
  //                       });
  //                     },
  //                     backgroundColor: Colors.red,
  //                     child: const Icon(Icons.delete),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
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
  Widget _buildImageArea() {
    final loc = AppLocalizations.of(context)!;

    final PageController _pageController = PageController(
      initialPage: controller.currentIndex.value,
    );
    @override
    void initState() {
      super.initState();

      if (controller.paidAmount.text.isNotEmpty) {
        // final amount = double.tryParse(controller.paidAmount.text) ?? 0.0;
        // final unit = double.tryParse(controller.unitRate.text) ?? 0.0;
        // final result = amount * unit;
        // controller.amountINR.text = result.toString();
        controller.fetchExchangeRate();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => {
            if (controller.imageFiles.isEmpty)
              {_pickImage(ImageSource.gallery)},
          },
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.9, // 90% of screen width
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
                return Center(child: Text(loc.tapToUploadDocs));
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
                    // Positioned(
                    //   bottom: 16,
                    //   right: 16,
                    //   child: GestureDetector(
                    //     onTap: () => _pickImage(ImageSource.gallery),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.deepPurple,
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: Colors.white, width: 2),
                    //       ),
                    //       padding: const EdgeInsets.all(8),
                    //       child: const Icon(
                    //         Icons.add,
                    //         color: Colors.white,
                    //         size: 28,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    if (controller.paidAmount.text.isNotEmpty) {
      final paid = double.tryParse(controller.paidAmount.text) ?? 0.0;
      final rate = double.tryParse(controller.unitRate.text) ?? 1.0;

      final result = paid * rate;

      controller.amountINR.text = result.toStringAsFixed(2);
    }
    // Listen for focus changes
    // _focusNode.addListener(() {
    //   if (!_focusNode.hasFocus) {
    //     setState(() {
    //       // Toggle visibility when focus is lost
    //       // controller.fetchExchangeRate();
    //     });
    //   }
    // });
  }

  
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Add form key for validation
            child: Column(
              children: [
                _buildImageArea(),
                const SizedBox(height: 20),

                // Upload & Capture Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(loc.upload),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(loc.capture),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paid Amount + Currency + Rate
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.paidAmount,
                            enabled: controller.paidAmontIsEditable.value,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ), // Only digits and dots allowed
                            ],
                            decoration: InputDecoration(
                              labelText: '${loc.paidAmount}  *',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '${loc.paidAmountRequired} ';
                              }
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return '${loc.enterValidAmount} ';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              final paid =
                                  double.tryParse(controller.paidAmount.text) ??
                                  0.0;
                              final rate = double.tryParse(
                                controller.unitRate.text,
                              );
                              if (rate != null) {
                                final result = paid * rate;
                                controller.amountINR.text = result
                                    .toStringAsFixed(2);
                                controller.isVisible.value = true;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            return SearchableMultiColumnDropdownField<Currency>(
                              alignLeft: -210,
                              dropdownWidth: 200,

                              labelText: "${loc.currency} *",
                              columnHeaders: [loc.code, loc.name, loc.symbol],
                              items: controller.currencies,
                              selectedValue: controller.selectedCurrency.value,
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
                                suffixIcon: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    Icons.arrow_drop_down_outlined,
                                    size: 20,
                                  ),
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minHeight: 55,
                                  minWidth: 30,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 18,
                                ),

                                filled: true,
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
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
                                  c == null ? loc.pleaseSelectCurrency : null,
                              onChanged: (c) {
                                controller.selectedCurrency.value = c;
                                controller.currencyDropDowncontroller.text =
                                    c!.code;
                                controller.fetchExchangeRate();
                              },
                              controller: controller.currencyDropDowncontroller,
                              rowBuilder: (c, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.code,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          c.symbol,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ), // Allows numbers with up to 2 decimal places
                            ],
                            controller: controller.unitRate,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: '${loc.rate}  *',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '${loc.rateRequired} ';
                              }
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid rate';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              final paid =
                                  double.tryParse(controller.paidAmount.text) ??
                                  0.0;
                              final rate = double.tryParse(val) ?? 1.0;
                              final result = paid * rate;
                              controller.amountINR.text = result
                                  .toStringAsFixed(2);
                              controller.isVisible.value = true;
                            },
                          ),
                        ),
                      ],
                    ),

                    // Account Distribution Button
                    Obx(() {
                      return Column(
                        children: [
                          if (controller.isVisible.value &&
                              controller.paidAmontIsEditable.value)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    final double lineAmount =
                                        double.tryParse(
                                          controller.paidAmount.text,
                                        ) ??
                                        0.0;
                                    if (controller.split.isEmpty &&
                                        controller
                                            .accountingDistributions
                                            .isNotEmpty) {
                                      controller.split.assignAll(
                                        controller.accountingDistributions.map((
                                          e,
                                        ) {
                                          return AccountingSplit(
                                            paidFor: e!.dimensionValueId,
                                            percentage: e.allocationFactor,
                                            amount: e.transAmount,
                                          );
                                        }).toList(),
                                      );
                                    } else if (controller.split.isEmpty) {
                                      controller.split.add(
                                        AccountingSplit(percentage: 100.0),
                                      );
                                    }
                                    print(lineAmount);
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
                                            splits: controller.split,
                                            lineAmount: lineAmount,
                                            onChanged: (i, updatedSplit) {
                                              if (!mounted) return;
                                              controller.split[i] =
                                                  updatedSplit;
                                            },
                                            onDistributionChanged: (newList) {
                                              if (!mounted) return;

                                              // 🔥 Print each item in newList for debugging
                                              for (var dist in newList) {
                                                print("onDistributionChanged:");
                                                print(
                                                  "  TransAmount: ${dist.transAmount}",
                                                );
                                                print(
                                                  "  ReportAmount: ${dist.reportAmount}",
                                                );
                                                print(
                                                  "  AllocationFactor: ${dist.allocationFactor}",
                                                );
                                                print(
                                                  "  DimensionValueId: ${dist.dimensionValueId}",
                                                );
                                              }

                                              controller.accountingDistributions
                                                  .clear();
                                              controller.accountingDistributions
                                                  .addAll(newList);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(loc.accountDistribution),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),

                    // Amount in INR (readonly)
                    TextFormField(
                      controller: controller.amountINR,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: '${loc.amountInInr}  *',
                        filled: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Policy Violations
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       loc.policyViolations,
                    //       style: const TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //     Text(
                    //       loc.checkPolicies,
                    //       style: const TextStyle(color: Colors.blue),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 12),
                    // _buildPolicyCard(),
                    // const SizedBox(height: 40),

                    // Buttons: Submit, Save, Cancel
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
                                onPressed:
                                    (isSubmitLoading ||
                                        isSaveLoading ||
                                        isCancelLoading ||
                                        isAnyLoading)
                                    ? null
                                    : () async {
                                        _isSubmitAttempted = true;
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          controller.setButtonLoading(
                                            'submit',
                                            true,
                                          );
                                          try {
                                            await controller
                                                .createcashAdvanceReturn(
                                                  context,
                                                  true,
                                                  false,
                                                  0,
                                                  null,
                                                );
                                          } finally {
                                            controller.setButtonLoading(
                                              'submit',
                                              false,
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${loc.fieldRequired} ',
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                          setState(
                                            () {},
                                          ); // Refresh UI for inline errors
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
                                        loc.submit,
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
                                      .buttonLoaders
                                      .values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                    onPressed:
                                        (isSubmitLoading ||
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
                                                'save',
                                                true,
                                              );
                                              try {
                                                await controller
                                                    .createcashAdvanceReturn(
                                                      context,
                                                      false,
                                                      false,
                                                      0,
                                                      null,
                                                    );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'save',
                                                  false,
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please fill all required fields.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                              setState(
                                                () {},
                                              ); // Refresh UI for inline errors
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(130, 50),
                                      backgroundColor: const Color.fromARGB(
                                        241,
                                        20,
                                        94,
                                        2,
                                      ),
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
                                        : Text(
                                            AppLocalizations.of(context)!.save,
                                          ),
                                  );
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
                                      .buttonLoaders
                                      .values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                    onPressed:
                                        (isSubmitLoading ||
                                            isSaveLoading ||
                                            isCancelLoading ||
                                            isAnyLoading)
                                        ? null
                                        : () async {
                                            controller.setButtonLoading(
                                              'cancel',
                                              true,
                                            );
                                            try {
                                              controller.chancelButton(context);
                                            } finally {
                                              controller.setButtonLoading(
                                                'cancel',
                                                false,
                                              );
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
                                            AppLocalizations.of(
                                              context,
                                            )!.cancel,
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
                    ),
                    const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: widget.backButton,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppLocalizations.of(context)!.back),
                  ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.policy1001,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(loc.expenseAmountUnderLimit)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(loc.receiptRequiredAmount)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.close, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.descriptionMandatory,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(loc.expiredPolicy)),
            ],
          ),
        ],
      ),
    );
  }
}
